import 'dart:io';
import 'dart:math';

// region parser
const String _startTerm = 'startTerm';
const String _eofTokenName = 'eofToken';

/// This is a parser for running tokens against a grammar to see
/// if the tokens are part of that grammar.
class Parser {
  _Table _table;
  Grammar _grammar;
  Tokenizer _tokenizer;

  static String getDebugStateString(Grammar grammar) {
    final _Builder builder = _Builder(grammar.copy());
    builder.determineStates();
    final StringBuffer buf = StringBuffer();
    for (final _State state in builder._states) {
      buf.write(state.toString());
    }
    return buf.toString();
  }

  /// Creates a new grammar.
  Parser._(this._table, this._grammar, this._tokenizer);

  /// Creates a new parser with the given grammar.
  factory Parser.fromGrammar(Grammar grammar, Tokenizer tokenizer) {
    final String errors = grammar.validate();
    if (errors.isNotEmpty) throw Exception('Error: Parser can not use invalid grammar:\n' + errors);

    grammar = grammar.copy();
    final _Builder builder = _Builder(grammar);
    builder.determineStates();
    builder.fillTable();
    final String errs = builder.buildErrors;
    if (errs.isNotEmpty) {
      throw Exception('Errors while building parser:\n' + builder.toString(showTable: false));
    } else {
      return Parser._(builder.table, grammar, tokenizer);
    }
  }

  /// Creates a parser from the given JSON serialization.
  factory Parser.deserialize(
    final Deserializer data,
  ) {
    final int version = data.readInt();
    if (version != 1) {
      throw Exception('Unknown version, $version, for parser serialization.');
    }
    final grammar = Grammar.deserialize(data.readSer());
    final table = _Table.deserialize(data.readSer(), grammar);
    final tokenizer = Tokenizer.deserialize(data.readSer());
    return Parser._(table, grammar, tokenizer);
  }

  /// Creates a parser from a parser definition file.
  factory Parser.fromDefinition(String input) => (Loader()..load(input)).parser;

  /// Creates a parser from a parser definition string.
  factory Parser.fromDefinitionChar(Iterator<int> input) => (Loader()..loadChars(input)).parser;

  /// Serializes the parser into a JSON serialization.
  Serializer serialize() => Serializer()
    ..writeInt(1) // Version 1
    ..writeSer(this._grammar.serialize())
    ..writeSer(this._table.serialize())
    ..writeSer(this._tokenizer.serialize());

  /// Gets the grammar for this parser.
  /// This should be treated as a constant, modifying it could cause the parser to fail.
  Grammar get grammar => this._grammar;

  /// Gets the tokenizer for this parser.
  /// This should be treated as a constant, modifying it could cause the parser to fail.
  Tokenizer get tokenizer => this._tokenizer;

  /// This parses the given string and returns the results.
  Result parse(String input) => this.parseTokens(this._tokenizer.tokenize(input));

  /// This parses the given characters and returns the results.
  Result parseChars(Iterator<int> iterator) => this.parseTokens(this._tokenizer.tokenizeChars(iterator));

  /// This parses the given tokens and returns the results.
  Result parseTokens(Iterable<Token> tokens, [int errorCap = 0]) {
    final _Runner runner = _Runner(this._table, errorCap);
    for (final Token token in tokens) {
      if (!runner.add(token)) return runner.result;
    }
    runner.add(Token(_eofTokenName, _eofTokenName, -1));
    return runner.result;
  }
}

/// An action indicates what to perform for a cell of the parse table.
abstract class _Action {}

/// A shift indicates to put the token into the parse set and move to the next state.
class _Shift implements _Action {
  /// The state number to move to.
  final int state;

  /// Creates a new shift action.
  _Shift(this.state);

  /// Gets the debug string for this action.
  @override
  String toString() => "shift ${this.state}";
}

/// A goto indicates that the current token will be
/// handled by another action and simply move to the next state.
class _Goto implements _Action {
  /// The state number to goto.
  final int state;

  /// Creates a new goto action.
  _Goto(this.state);

  /// Gets the debug string for this action.
  @override
  String toString() => "goto ${this.state}";
}

/// A reduce indicates that the current token will be
/// handled by another action and the current rule
/// is used to reduce the parse set down to a term.
class _Reduce implements _Action {
  /// The rule to reduce from the parse set.
  final Rule rule;

  /// Creates a new reduce action.
  _Reduce(this.rule);

  /// Gets the debug string for this action.
  @override
  String toString() => "reduce ${rule.toString()}";
}

/// An accept indicates that the full input has been
/// checked by the grammar and fits to the grammar.
class _Accept implements _Action {
  /// Creates a new accept action.
  _Accept();

  /// Gets the debug string for this action.
  @override
  String toString() => "accept";
}

/// An error indicates that the given token can not
/// be processed from the current state.
/// A null action is a generic error, this one gives specific information.
class _Error implements _Action {
  /// The error message to return for this action.
  final String error;

  /// Creates a new error action.
  _Error(this.error);

  /// Gets the debug string for this action.
  @override
  String toString() => "error ${this.error}";
}

/// This is a builder used to generate a parser giving a grammar.
class _Builder {
  final Grammar _grammar;
  final List<_State> _states = [];
  final Set<Item> _items = {};
  final _Table _table = _Table();
  final StringBuffer _errors = StringBuffer();

  /// Constructs of a new parser builder.
  _Builder(this._grammar) {
    final Term? oldStart = this._grammar.startTerm;
    this._grammar.start(_startTerm);
    this._grammar.newRule(_startTerm).addTerm(oldStart?.name ?? '').addToken(_eofTokenName);

    for (final Term term in this._grammar.terms) {
      this._items.add(term);
      for (final Rule rule in term.rules) {
        for (final Item item in rule.items) {
          if (item is! Trigger) this._items.add(item);
        }
      }
    }
  }

  /// Finds a state with the given offset index for the given rule.
  _State? find(int index, Rule rule) {
    for (final _State state in this._states) {
      for (int i = 0; i < state.indices.length; i++) {
        if ((state.indices[i] == index) && (state.rules[i] == rule)) return state;
      }
    }
    return null;
  }

  /// Determines all the parser states for the grammar.
  void determineStates() {
    final _State startState = _State(0);
    for (final Rule rule in this._grammar.startTerm?.rules ?? []) {
      startState.addRule(0, rule);
    }
    this._states.add(startState);
    final List<_State> changed = [startState];

    while (changed.isNotEmpty) {
      final _State state = changed.removeLast();
      changed.addAll(this.nextStates(state));
    }
  }

  /// Determines the next states following the given state.
  List<_State> nextStates(_State state) {
    final List<_State> changed = [];
    for (int i = 0; i < state.indices.length; i++) {
      final int index = state.indices[i];
      final Rule rule = state.rules[i];
      final List<Item> items = rule.basicItems;
      if (index < items.length) {
        final Item item = items[index];

        if ((item is TokenItem) && (item.name == _eofTokenName)) {
          state.setAccept();
        } else {
          _State? next = state.findGoto(item);
          if (next == null) {
            next = this.find(index + 1, rule);
            if (next == null) {
              next = _State(this._states.length);
              this._states.add(next);
            }
            state.addGoto(item, next);
          }

          if (next.addRule(index + 1, rule)) {
            changed.add(next);
          }
        }
      }
    }
    return changed;
  }

  /// Fills the parse table with the information from the states.
  void fillTable() {
    for (final _State state in this._states) {
      if (state.hasAccept) this._table.writeShift(state.number, _eofTokenName, _Accept());

      for (int i = 0; i < state.rules.length; i++) {
        final Rule rule = state.rules[i];
        final int index = state.indices[i];
        final List<Item> items = rule.basicItems;
        if (items.length <= index) {
          final List<TokenItem> follows = rule.term?.determineFollows() ?? [];
          if (follows.isNotEmpty) {
            // Add the reduce action to all the follow items.
            final _Reduce reduce = _Reduce(rule);
            for (final TokenItem follow in follows) {
              this._table.writeShift(state.number, follow.name, reduce);
            }
          }
        }
      }

      for (int i = 0; i < state.gotos.length; i++) {
        final Item onItem = state.onItems[i];
        final int goto = state.gotos[i].number;
        if (onItem is Term) {
          this._table.writeGoto(state.number, onItem.name, _Goto(goto));
        } else {
          this._table.writeShift(state.number, onItem.name, _Shift(goto));
        }
      }
    }

    // Check for goto loops.
    for (final Term term in this._grammar.terms) {
      final List<int> checked = [];
      for (int i = 0; i < this._states.length; i++) {
        if (checked.contains(i)) continue;
        checked.add(i);

        _Action? action = this._table.readGoto(i, term.name);
        final List<int> reached = [];
        while (action is _Goto) {
          reached.add(i);
          checked.add(i);
          i = action.state;
          if (reached.contains(i)) {
            final List<int> loop = reached.sublist(reached.indexOf(i));
            this._errors.writeln('Infinite goto loop found in term ${term.name} between the state(s) $loop.');
            break;
          }
          action = this._table.readGoto(i, term.name);
        }
      }
    }
  }

  /// Gets all the error which occurred during the build,
  /// or an empty string if no error occurred.
  String get buildErrors => this._errors.toString();

  /// The table from the builder.
  _Table get table => this._table;

  /// Returns a human readable string for debugging of the parser being built.
  @override
  String toString({bool showState = true, bool showTable = true, bool showError = true}) {
    final StringBuffer buf = StringBuffer();
    if (showState) {
      for (final _State state in this._states) {
        buf.write(state.toString());
      }
    }
    if (showTable) {
      if (buf.isNotEmpty) buf.writeln();
      buf.writeln(this._table.toString());
    }
    if (showError && (this._errors.isNotEmpty)) {
      if (buf.isNotEmpty) buf.writeln();
      buf.write(this._errors.toString());
    }
    return buf.toString();
  }
}

/// Loader is a parser and interpreter for reading a tokenizer and grammar
/// definition from a string to create a parser.
class Loader {
  /// Gets the tokenizer used for loading a parser definition.
  static Tokenizer getTokenizer() {
    final tok = Tokenizer();
    tok.start("start");
    tok.join("start", "whitespace").addSet(" \n\r\t");
    tok.join("whitespace", "whitespace").addSet(" \n\r\t");
    tok.setToken("whitespace", "whitespace").consume();
    tok.joinToToken("start", "openParen").addSet("(");
    tok.joinToToken("start", "closeParen").addSet(")");
    tok.joinToToken("start", "openBracket").addSet("[");
    tok.joinToToken("start", "closeBracket").addSet("]");
    tok.joinToToken("start", "openAngle").addSet("<");
    tok.joinToToken("start", "closeAngle").addSet(">");
    tok.joinToToken("start", "openCurly").addSet("{");
    tok.joinToToken("start", "closeCurly").addSet("}");
    tok.joinToToken("start", "or").addSet("|");
    tok.joinToToken("start", "not").addSet("!");
    tok.joinToToken("start", "consume").addSet("^");
    tok.joinToToken("start", "colon").addSet(":");
    tok.joinToToken("start", "semicolon").addSet(";");
    tok.joinToToken("colon", "assign").addSet("=");
    tok.joinToToken("start", "comma").addSet(",");
    tok.joinToToken("start", "any").addSet("*");
    tok.joinToToken("start", "lambda").addSet("_");
    tok.join("start", "comment").addSet("#");
    tok.join("comment", "commentEnd").addSet("\n");
    tok.join("comment", "comment").addAll();
    tok.setToken("commentEnd", "comment").consume();
    tok.join("start", "equal").addSet("=");
    tok.join("equal", "arrow").addSet(">");
    tok.setToken("arrow", "arrow");
    tok.join("start", "startRange").addSet(".");
    tok.joinToToken("startRange", "range").addSet(".");
    final hexMatcher = Group()
      ..addRange('0', '9')
      ..addRange('A', 'F')
      ..addRange('a', 'f');
    final idLetter = Group()
      ..addRange('a', 'z')
      ..addRange('A', 'Z')
      ..addRange('0', '9')
      ..addSet("_.-");
    tok.joinToToken("start", "id").add(idLetter);
    tok.join("id", "id").add(idLetter);
    tok.join("start", "singleQuote.open")
      ..addSet("'")
      ..consume = true;
    tok.join("singleQuote.open", "singleQuote.escape").addSet("\\");
    tok.join("singleQuote.open", "singleQuote.body").addAll();
    tok.join("singleQuote.body", "singleQuote")
      ..addSet("'")
      ..consume = true;
    tok.join("singleQuote.body", "singleQuote.escape").addSet("\\");
    tok.join("singleQuote.escape", "singleQuote.body").addSet("\\nrt'");
    tok.join("singleQuote.escape", "singleQuote.hex1").addSet("x");
    tok.join("singleQuote.hex1", "singleQuote.hex2").add(hexMatcher);
    tok.join("singleQuote.hex2", "singleQuote.body").add(hexMatcher);
    tok.join("singleQuote.escape", "singleQuote.unicode1").addSet("u");
    tok.join("singleQuote.unicode1", "singleQuote.unicode2").add(hexMatcher);
    tok.join("singleQuote.unicode2", "singleQuote.unicode3").add(hexMatcher);
    tok.join("singleQuote.unicode3", "singleQuote.unicode4").add(hexMatcher);
    tok.join("singleQuote.unicode4", "singleQuote.body").add(hexMatcher);
    tok.join("singleQuote.body", "singleQuote.body").addAll();
    tok.setToken("singleQuote", "string");
    tok.join("start", "doubleQuote.open")
      ..addSet('"')
      ..consume = true;
    tok.join("doubleQuote.open", "doubleQuote.escape").addSet("\\");
    tok.join("doubleQuote.open", "doubleQuote.body").addAll();
    tok.join("doubleQuote.body", "doubleQuote")
      ..addSet('"')
      ..consume = true;
    tok.join("doubleQuote.body", "doubleQuote.escape").addSet("\\");
    tok.join("doubleQuote.escape", "doubleQuote.body").addSet('\\nrt"');
    tok.join("doubleQuote.escape", "doubleQuote.hex1").addSet("x");
    tok.join("doubleQuote.hex1", "doubleQuote.hex2").add(hexMatcher);
    tok.join("doubleQuote.hex2", "doubleQuote.body").add(hexMatcher);
    tok.join("doubleQuote.escape", "doubleQuote.unicode1").addSet("u");
    tok.join("doubleQuote.unicode1", "doubleQuote.unicode2").add(hexMatcher);
    tok.join("doubleQuote.unicode2", "doubleQuote.unicode3").add(hexMatcher);
    tok.join("doubleQuote.unicode3", "doubleQuote.unicode4").add(hexMatcher);
    tok.join("doubleQuote.unicode4", "doubleQuote.body").add(hexMatcher);
    tok.join("doubleQuote.body", "doubleQuote.body").addAll();
    tok.setToken("doubleQuote", "string");
    return tok;
  }

  /// Gets the grammar used for loading a parser definition.
  static Grammar getGrammar() {
    final gram = Grammar();
    gram.start("def.set");
    gram.newRule("def.set").addTerm("def.set").addTerm("def").addToken("semicolon");
    gram.newRule("def.set");
    gram
        .newRule("def")
        .addTrigger("new.def")
        .addToken("closeAngle")
        .addTerm("stateID")
        .addTrigger("start.state")
        .addTerm("def.state.optional");
    gram.newRule("def").addTrigger("new.def").addTerm("stateID").addTerm("def.state");
    gram.newRule("def").addTrigger("new.def").addTerm("tokenStateID").addTerm("def.token");
    gram.newRule("def.state.optional");
    gram.newRule("def.state.optional").addTerm("def.state");
    gram
        .newRule("def.state")
        .addToken("colon")
        .addTerm("matcher.start")
        .addToken("arrow")
        .addTerm("stateID")
        .addTrigger("join.state")
        .addTerm("def.state.optional");
    gram
        .newRule("def.state")
        .addToken("colon")
        .addTerm("matcher.start")
        .addToken("arrow")
        .addTerm("tokenStateID")
        .addTrigger("join.token")
        .addTerm("def.token.optional");
    gram
        .newRule("def.state")
        .addToken("arrow")
        .addTerm("tokenStateID")
        .addTrigger("assign.token")
        .addTerm("def.token.optional");
    gram
        .newRule("stateID")
        .addToken("openParen")
        .addToken("id")
        .addToken("closeParen")
        .addTrigger("new.state");
    gram
        .newRule("tokenStateID")
        .addToken("openBracket")
        .addToken("id")
        .addToken("closeBracket")
        .addTrigger("new.token.state");
    gram
        .newRule("tokenStateID")
        .addToken("consume")
        .addToken("openBracket")
        .addToken("id")
        .addToken("closeBracket")
        .addTrigger("new.token.consume");
    gram.newRule("termID").addToken("openAngle").addToken("id").addToken("closeAngle").addTrigger("new.term");
    gram
        .newRule("tokenItemID")
        .addToken("openBracket")
        .addToken("id")
        .addToken("closeBracket")
        .addTrigger("new.token.item");
    gram
        .newRule("triggerID")
        .addToken("openCurly")
        .addToken("id")
        .addToken("closeCurly")
        .addTrigger("new.trigger");

    gram.newRule("matcher.start").addToken("any").addTrigger("match.any");
    gram.newRule("matcher.start").addTerm("matcher");
    gram.newRule("matcher.start").addToken("consume").addTerm("matcher").addTrigger("match.consume");

    gram.newRule("matcher").addTerm("charSetRange");
    gram.newRule("matcher").addTerm("matcher").addToken("comma").addTerm("charSetRange");

    gram.newRule("charSetRange").addToken("string").addTrigger("match.set");
    gram.newRule("charSetRange").addToken("not").addToken("string").addTrigger("match.set.not");
    gram
        .newRule("charSetRange")
        .addToken("string")
        .addToken("range")
        .addToken("string")
        .addTrigger("match.range");
    gram
        .newRule("charSetRange")
        .addToken("not")
        .addToken("string")
        .addToken("range")
        .addToken("string")
        .addTrigger("match.range.not");
    gram
        .newRule("charSetRange")
        .addToken("not")
        .addToken("openParen")
        .addTrigger("not.group.start")
        .addTerm("matcher")
        .addToken("closeParen")
        .addTrigger("not.group.end");
    gram.newRule("def.token.optional");
    gram.newRule("def.token.optional").addTerm("def.token");
    gram
        .newRule("def.token")
        .addToken("colon")
        .addTerm("replaceText")
        .addToken("arrow")
        .addTerm("tokenStateID")
        .addTrigger("replace.token");
    gram.newRule("replaceText").addToken("string").addTrigger("add.replace.text");
    gram
        .newRule("replaceText")
        .addTerm("replaceText")
        .addToken("comma")
        .addToken("string")
        .addTrigger("add.replace.text");
    gram
        .newRule("def")
        .addTrigger("new.def")
        .addToken("closeAngle")
        .addTerm("termID")
        .addTrigger("start.term")
        .addTerm("start.rule.optional");
    gram
        .newRule("def")
        .addTrigger("new.def")
        .addTerm("termID")
        .addToken("assign")
        .addTrigger("start.rule")
        .addTerm("start.rule")
        .addTerm("next.rule.optional");
    gram.newRule("start.rule.optional");
    gram
        .newRule("start.rule.optional")
        .addToken("assign")
        .addTrigger("start.rule")
        .addTerm("start.rule")
        .addTerm("next.rule.optional");
    gram.newRule("next.rule.optional");
    gram
        .newRule("next.rule.optional")
        .addTerm("next.rule.optional")
        .addToken("or")
        .addTrigger("start.rule")
        .addTerm("start.rule");
    gram.newRule("start.rule").addTerm("tokenItemID").addTrigger("item.token").addTerm("rule.item");
    gram.newRule("start.rule").addTerm("termID").addTrigger("item.term").addTerm("rule.item");
    gram.newRule("start.rule").addTerm("triggerID").addTrigger("item.trigger").addTerm("rule.item");
    gram.newRule("start.rule").addToken("lambda");
    gram.newRule("rule.item");
    gram.newRule("rule.item").addTerm("rule.item").addTerm("tokenItemID").addTrigger("item.token");
    gram.newRule("rule.item").addTerm("rule.item").addTerm("termID").addTrigger("item.term");
    gram.newRule("rule.item").addTerm("rule.item").addTerm("triggerID").addTrigger("item.trigger");
    return gram;
  }

  /// Creates a new parser for loading tokenizer and grammar definitions.
  static Parser getParser() => Parser.fromGrammar(
        Loader.getGrammar(),
        Loader.getTokenizer(),
      );

  /// This will convert an escaped strings from a tokenized language into
  /// the correct characters for the string.
  static String unescapeString(String value) {
    final StringBuffer buf = StringBuffer();
    int start = 0;
    while (start < value.length) {
      int stop = value.indexOf('\\', start);
      if (stop < 0) {
        buf.write(value.substring(start));
        break;
      }
      buf.write(value.substring(start, stop));
      //  "\\", "\n", "\"", "\'", "\t", "\r", "\xFF", "\uFFFF"
      switch (value[stop + 1]) {
        case '\\':
          buf.write('\\');
          break;
        case 'n':
          buf.write('\n');
          break;
        case 't':
          buf.write('\t');
          break;
        case 'r':
          buf.write('\r');
          break;
        case '\'':
          buf.write('\'');
          break;
        case '"':
          buf.write('"');
          break;
        case 'x':
          final hex = value.substring(stop + 2, stop + 4);
          final charCode = int.parse(hex, radix: 16);
          buf.writeCharCode(charCode);
          stop += 2;
          break;
        case 'u':
          final hex = value.substring(stop + 2, stop + 6);
          final charCode = int.parse(hex, radix: 16);
          buf.writeCharCode(charCode);
          stop += 4;
          break;
      }
      start = stop + 2;
    }
    return buf.toString();
  }

  final Map<String, TriggerHandle> _handles = {};
  final Grammar _grammar = Grammar();
  final Tokenizer _tokenizer = Tokenizer();

  final List<State> _states = [];
  final List<TokenState> _tokenStates = [];
  final List<Term> _terms = [];
  final List<TokenItem> _tokenItems = [];
  final List<Trigger> _triggers = [];
  final List<Group> _curTransGroups = [];
  bool _curTransConsume = false;
  final List<String> _replaceText = [];
  Rule? _curRule;

  /// Creates a new loader.
  Loader() {
    this._handles.addAll({
      'new.def': this._newDef,
      'start.state': this._startState,
      'join.state': this._joinState,
      'join.token': this._joinToken,
      'assign.token': this._assignToken,
      'new.state': this._newState,
      'new.token.state': this._newTokenState,
      'new.token.consume': this._newTokenConsume,
      'new.term': this._newTerm,
      'new.token.item': this._newTokenItem,
      'new.trigger': this._newTrigger,
      'match.any': this._matchAny,
      'match.consume': this._matchConsume,
      'match.set': this._matchSet,
      'match.set.not': this._matchSetNot,
      'match.range': this._matchRange,
      'match.range.not': this._matchRangeNot,
      'not.group.start': this._notGroupStart,
      'not.group.end': this._notGroupEnd,
      'add.replace.text': this._addReplaceText,
      'replace.token': this._replaceToken,
      'start.term': this._startTerm,
      'start.rule': this._startRule,
      'item.token': this._itemToken,
      'item.term': this._itemTerm,
      'item.trigger': this._itemTrigger
    });
  }

  /// Adds several blocks of definitions to the grammar and tokenizer
  /// which are being loaded via a string containing the definition.
  void load(String input) => this.loadChars(input.codeUnits.iterator);

  /// Adds several blocks of definitions to the grammar and tokenizer
  /// which are being loaded via a list of characters containing the definition.
  void loadChars(Iterator<int> iterator) {
    final Result result = getParser().parseChars(iterator);
    if (result.errors.isNotEmpty) throw Exception('Error in provided language definition:\n${result.errors}');
    result.tree?.process(this._handles);
  }

  /// Gets the grammar which is being loaded.
  Grammar get grammar => this._grammar;

  /// Gets the tokenizer which is being loaded.
  Tokenizer get tokenizer => this._tokenizer;

  /// Creates a parser with the loaded tokenizer and grammar.
  Parser get parser => Parser.fromGrammar(this._grammar, this._tokenizer);

  /// A trigger handle for starting a new definition block.
  void _newDef(TriggerArgs args) {
    args.tokens.clear();
    this._states.clear();
    this._tokenStates.clear();
    this._terms.clear();
    this._tokenItems.clear();
    this._triggers.clear();
    this._curTransGroups.clear();
    this._curTransConsume = false;
    this._replaceText.clear();
    this._curRule = null;
  }

  /// A trigger handle for setting the starting state of the tokenizer.
  void _startState(TriggerArgs args) => this._tokenizer.start(this._states.last.name);

  /// A trigger handle for joining two states with the defined matcher.
  void _joinState(TriggerArgs args) {
    final start = this._states[this._states.length - 2];
    final end = this._states.last;
    final trans = start.join(end.name);
    trans.matchers.addAll(this._curTransGroups[0].matchers);
    trans.consume = this._curTransConsume;
    this._curTransGroups.clear();
    this._curTransConsume = false;
  }

  /// A trigger handle for joining a state to a token with the defined matcher.
  void _joinToken(TriggerArgs args) {
    final start = this._states.last;
    final end = this._tokenStates.last;
    final trans = start.join(end.name);
    trans.matchers.addAll(this._curTransGroups[0].matchers);
    trans.consume = this._curTransConsume;
    this._tokenizer.state(end.name).setToken(end.name);
    this._curTransGroups.clear();
    this._curTransConsume = false;
  }

  /// A trigger handle for assigning a token to a state.
  void _assignToken(TriggerArgs args) {
    final start = this._states.last;
    final end = this._tokenStates.last;
    start.setToken(end.name);
  }

  /// A trigger handle for adding a new state to the tokenizer.
  void _newState(TriggerArgs args) {
    final name = args.recent(2)?.text ?? '';
    final state = this._tokenizer.state(name);
    this._states.add(state);
  }

  /// A trigger handle for adding a new token to the tokenizer.
  void _newTokenState(TriggerArgs args) {
    final name = args.recent(2)?.text ?? '';
    final token = this._tokenizer.token(name);
    this._tokenStates.add(token);
  }

  /// A trigger handle for adding a new token to the tokenizer
  /// and setting it to consume that token.
  void _newTokenConsume(TriggerArgs args) {
    final name = args.recent(2)?.text ?? '';
    final token = this._tokenizer.token(name);
    token.consume();
    this._tokenStates.add(token);
  }

  /// A trigger handle for adding a new term to the grammar.
  void _newTerm(TriggerArgs args) {
    final name = args.recent(2)?.text ?? '';
    final term = this._grammar.term(name);
    this._terms.add(term);
  }

  /// A trigger handle for adding a new token to the grammar.
  void _newTokenItem(TriggerArgs args) {
    final name = args.recent(2)?.text ?? '';
    final token = this._grammar.token(name);
    this._tokenItems.add(token);
  }

  /// A trigger handle for adding a new trigger to the grammar.
  void _newTrigger(TriggerArgs args) {
    final name = args.recent(2)?.text ?? '';
    final trigger = this._grammar.trigger(name);
    this._triggers.add(trigger);
  }

  /// A trigger handle for setting the currently building matcher to match any.
  void _matchAny(TriggerArgs args) {
    if (this._curTransGroups.isEmpty) {
      this._curTransGroups.add(Group());
    }
    this._curTransGroups.last.addAll();
  }

  /// A trigger handle for setting the currently building matcher to be consumed.
  void _matchConsume(TriggerArgs args) => this._curTransConsume = true;

  /// A trigger handle for setting the currently building matcher to match to a character set.
  void _matchSet(TriggerArgs args) {
    final Token? token = args.recent(1);
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(Group());
    this._curTransGroups.last.addSet(unescapeString(token?.text ?? ''));
  }

  /// A trigger handle for setting the currently building matcher to not match to a character set.
  void _matchSetNot(TriggerArgs args) {
    this._notGroupStart(args);
    this._matchSet(args);
    this._notGroupEnd(args);
  }

  /// A trigger handle for setting the currently building matcher to match to a character range.
  void _matchRange(TriggerArgs args) {
    final Token? lowChar = args.recent(3);
    final Token? highChar = args.recent(1);
    final String lowText = unescapeString(lowChar?.text ?? '');
    final String highText = unescapeString(highChar?.text ?? '');
    if (lowText.length != 1) {
      throw Exception('May only have one character for the low char of a range. $lowChar does not.');
    }
    if (highText.length != 1) {
      throw Exception('May only have one character for the high char of a range. $highChar does not.');
    }
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(Group());
    this._curTransGroups.last.addRange(lowText, highText);
  }

  /// A trigger handle for setting the currently building matcher to not match to a character range.
  void _matchRangeNot(TriggerArgs args) {
    this._notGroupStart(args);
    this._matchRange(args);
    this._notGroupEnd(args);
  }

  /// A trigger handle for starting a not group of matchers.
  void _notGroupStart(TriggerArgs args) {
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(Group());
    this._curTransGroups.add(this._curTransGroups.last.addNot());
  }

  /// A trigger handle for ending a not group of matchers.
  void _notGroupEnd(TriggerArgs args) => this._curTransGroups.removeLast();

  /// A trigger handle for adding a new replacement string to the loader.
  void _addReplaceText(TriggerArgs args) => this._replaceText.add(unescapeString(args.recent(1)?.text ?? ''));

  /// A trigger handle for setting a set of replacements between two
  /// tokens with a previously set replacement string set.
  void _replaceToken(TriggerArgs args) {
    final TokenState start = this._tokenStates[this._tokenStates.length - 2];
    final TokenState end = this._tokenStates.last;
    start.replace(end.name, this._replaceText);
    this._replaceText.clear();
  }

  /// A trigger handle for starting a grammar definition of a term.
  void _startTerm(TriggerArgs args) => this._grammar.start(this._terms.last.name);

  /// A trigger handle for starting defining a rule for the current term.
  void _startRule(TriggerArgs args) => this._curRule = this._terms.last.newRule();

  /// A trigger handle for adding a token to the current rule being built.
  void _itemToken(TriggerArgs args) => this._curRule?.addToken(this._tokenItems.removeLast().name);

  /// A trigger handle for adding a term to the current rule being built.
  void _itemTerm(TriggerArgs args) => this._curRule?.addTerm(this._terms.removeLast().name);

  /// A trigger handle for adding a trigger to the current rule being built.
  void _itemTrigger(TriggerArgs args) => this._curRule?.addTrigger(this._triggers.removeLast().name);
}

/// This is the result from a parse of a stream of tokens.
class Result {
  /// Any errors which occurred during the parse.
  final List<String> errors;

  /// The tree of the parsed tokens into grammar rules.
  /// This will be null if there are any errors.
  final TreeNode? tree;

  /// Creates a new parser result.
  Result(this.errors, this.tree);

  /// Gets the human-readable debug string for these results.
  @override
  String toString() {
    final StringBuffer buf = StringBuffer();
    for (final String error in this.errors) {
      if (buf.isNotEmpty) buf.writeln();
      buf.write(error);
    }
    if (tree != null) buf.write(tree.toString());
    return buf.toString();
  }
}

/// The runner performs a parse step by step as tokens are added.
class _Runner {
  final _Table _table;
  final int _errorCap;
  final List<String> _errors = [];
  final List<TreeNode> _itemStack = [];
  final List<int> _stateStack = [0];
  bool _accepted = false;
  final bool _verbose = false;

  /// Creates a new runner, only the parser may create a runner.
  _Runner(this._table, this._errorCap);

  /// Gets the results from the runner.
  Result get result {
    if (this._errors.isNotEmpty) return Result(List.unmodifiable(this._errors), null);
    if (!this._accepted) {
      this._errors.add('Unexpected end of input.');
      return Result(List.unmodifiable(this._errors), null);
    }
    return Result([], this._itemStack[0]);
  }

  /// Determines if the error limit has been reached.
  bool get _errorLimitReached => (this._errorCap > 0) && (this._errors.length >= this._errorCap);

  /// Handles when a default error action has been reached.
  bool _nullAction(int curState, Token token, String indent) {
    if (this._verbose) print('${indent}null error');
    final List<String> tokens = this._table.getAllTokens(curState);
    this._errors.add('Unexpected item, $token, in state $curState. Expected: ${tokens.join(', ')}.');
    if (this._errorLimitReached) return false;
    // Discard token and continue.
    return true;
  }

  /// Handles when a specified error action has been reached.
  bool _errorAction(_Error action, String indent) {
    if (this._verbose) print('${indent}error');
    this._errors.add(action.error);
    if (this._errorLimitReached) return false;
    // Discard token and continue.
    return true;
  }

  /// Handles when a shift action has been reached.
  bool _shiftAction(_Shift action, Token token, String indent) {
    if (this._verbose) print('${indent}shift ${action.state} on $token');
    this._itemStack.add(TokenNode(token));
    this._stateStack.add(action.state);
    return true;
  }

  /// Handles when a reduce action has been reached.
  bool _reduceAction(_Reduce action, Token token, String indent) {
    // Pop the items off the stack for this action.
    // Also check that the items match the expected rule.
    final int count = action.rule.items.length;
    final List<TreeNode> items = [];
    for (int i = count - 1; i >= 0; i--) {
      final Item ruleItem = action.rule.items[i];
      if (ruleItem is Trigger) {
        items.insert(0, TriggerNode(ruleItem.name));
      } else {
        this._stateStack.removeLast();
        final TreeNode item = this._itemStack.removeLast();
        items.insert(0, item);

        if (ruleItem is Term) {
          if (item is RuleNode) {
            if (ruleItem.name != item.rule.term?.name) {
              throw Exception(
                  'The action, $action, could not reduce item $i, $item: the term names did not match.');
            }
          } else {
            throw Exception(
                'The action, $action, could not reduce item $i, $item: the item is not a rule node.');
          }
        } else {
          // if (ruleItem is Grammar.TokenItem) {
          if (item is TokenNode) {
            if (ruleItem.name != item.token.name) {
              throw Exception(
                  'The action, $action, could not reduce item $i, $item: the token names did not match.');
            }
          } else {
            throw Exception(
                'The action, $action, could not reduce item $i, $item: the item is not a token node.');
          }
        }
      }
    }

    // Create a new item with the items for this rule in it
    // and put it onto the stack.
    final RuleNode node = RuleNode(action.rule, items);
    this._itemStack.add(node);
    if (this._verbose) print('${indent}reduce ${action.rule}');

    // Use the state reduced back to and the new item to seek,
    // via the goto table, the next state to continue from.
    int curState = this._stateStack.last;
    for (;;) {
      final _Action? action = this._table.readGoto(curState, node.rule.term?.name ?? '');
      if (action == null) {
        break;
      } else if (action is _Goto) {
        curState = action.state;
        if (this._verbose) print('${indent}goto ${curState}');
      } else {
        throw Exception('Unexpected goto type: $action');
      }
    }
    this._stateStack.add(curState);

    // Continue with parsing the current token.
    return this._addToken(token, indent + '  ');
  }

  /// Handles when an accept has been reached.
  bool _acceptAction(_Accept action, String indent) {
    if (this._verbose) print('${indent}accept');
    this._accepted = true;
    return true;
  }

  /// Inserts the next look ahead token into the parser.
  bool add(Token token) {
    if (this._accepted) {
      this._errors.add('unexpected token after end: $token');
      return false;
    }
    return this._addToken(token, '');
  }

  /// Inserts the next look ahead token into the parser.
  /// This is the internal method for `add` which can be called recursively.
  bool _addToken(Token token, String indent) {
    if (this._verbose) print('$indent$token =>');
    final int curState = this._stateStack.last;
    final _Action? action = this._table.readShift(curState, token.name);
    bool result;
    if (action == null) {
      result = this._nullAction(curState, token, indent);
    } else if (action is _Shift) {
      result = this._shiftAction(action, token, indent);
    } else if (action is _Reduce) {
      result = this._reduceAction(action, token, indent);
    } else if (action is _Accept) {
      result = this._acceptAction(action, indent);
    } else if (action is _Error) {
      result = this._errorAction(action, indent);
    } else {
      throw Exception('Unexpected action type: $action');
    }
    if (this._verbose) print('$indent=> ${this._stackToString()}');
    return result;
  }

  /// Gets a string for the current parser stack.
  String _stackToString() {
    final StringBuffer buf = StringBuffer();
    final int _max = max(this._itemStack.length, this._stateStack.length);
    for (int i = 0; i < _max; ++i) {
      if (i != 0) buf.write(', ');
      bool hasState = false;
      if (i < this._stateStack.length) {
        buf.write('${this._stateStack[i]}');
        hasState = true;
      }
      if (i < this._itemStack.length) {
        if (hasState) buf.write(':');
        final item = this._itemStack[i];
        if (item is RuleNode) {
          buf.write('<${item.rule.term?.name ?? ''}>');
        } else if (item is TokenNode) {
          buf.write('[${item.token.name}]');
        } else if (item is TriggerNode) {
          buf.write('{${item.trigger}}');
        }
      }
    }
    return buf.toString();
  }
}

/// This is a state in the parser builder.
/// The state is a collection of rules with offset indices.
/// These states are used for generating the parser table.
class _State {
  final List<int> _indices = [];
  final List<Rule> _rules = [];
  final List<Item> _onItems = [];
  final List<_State> _gotos = [];
  bool _accept = false;

  /// This is the index of the state in the builder.
  final int number;

  /// Creates a new state for the parser builder.
  _State(this.number);

  /// The indices which indicated the offset into the matching rule.
  List<int> get indices => this._indices;

  /// The rules for this state which match up with the indices.
  List<Rule> get rules => this._rules;

  /// This is the items which connect two states together.
  /// This matches with the goto values to create a connection.
  List<Item> get onItems => this._onItems;

  /// This is the goto which indicates which state to go to for the matched items.
  /// This matches with the `onItems` to create a connection.
  List<_State> get gotos => this._gotos;

  /// Indicates if this state can acceptance for this grammar.
  bool get hasAccept => this._accept;

  /// Sets this state as an accept state for the grammar.
  void setAccept() => this._accept = true;

  /// Checks if the given index and rule exist in this state.
  bool hasRule(int index, Rule rule) {
    for (int i = this._indices.length - 1; i >= 0; i--) {
      if ((this._indices[i] == index) && (this._rules[i] == rule)) return true;
    }
    return false;
  }

  /// Adds the given index and rule to this state.
  /// Returns false if it already exists, true if added.
  bool addRule(int index, Rule rule) {
    if (this.hasRule(index, rule)) return false;
    this._indices.add(index);
    this._rules.add(rule);

    final List<Item> items = rule.basicItems;
    if (index < items.length) {
      final Item item = items[index];
      if (item is Term) {
        for (final Rule rule in item.rules) {
          this.addRule(0, rule);
        }
      }
    }
    return true;
  }

  /// Finds the go to state from the given item,
  /// null is returned if none is found.
  _State? findGoto(Item item) {
    for (int i = this._onItems.length - 1; i >= 0; i--) {
      if (this._onItems[i] == item) return this._gotos[i];
    }
    return null;
  }

  /// Adds a goto connection on the given item to the given state.
  bool addGoto(Item item, _State state) {
    if (this.findGoto(item) == state) return false;
    this._onItems.add(item);
    this._gotos.add(state);
    return true;
  }

  /// Determines if this state is equal to the given state.
  bool equals(_State? other) {
    if (other == null) return false;
    if (other.number != this.number) return false;
    if (other._indices.length != this._indices.length) return false;
    if (other._onItems.length != this._onItems.length) return false;
    for (int i = this._indices.length - 1; i >= 0; i--) {
      if (!this.hasRule(other._indices[i], other._rules[i])) return false;
    }
    for (int i = this._onItems.length - 1; i >= 0; i--) {
      if (this.findGoto(other._onItems[i]) != other._gotos[i]) return false;
    }
    return true;
  }

  /// Gets a string for this state for debugging the builder.
  @override
  String toString([String indent = ""]) {
    final StringBuffer buf = StringBuffer();
    buf.writeln('state ${this.number}:');
    for (int i = 0; i < this._rules.length; i++) {
      buf.writeln(indent + '  ' + this._rules[i].toString(this._indices[i]));
    }
    for (int i = 0; i < this._onItems.length; i++) {
      buf.writeln(indent + '  ${this._onItems[i]}: goto state ${this._gotos[i].number}');
    }
    return buf.toString();
  }
}

/// This is a table to define the actions to take when
/// a new token is added to the parse.
class _Table {
  Set<String> _shiftColumns = {};
  Set<String> _gotoColumns = {};
  final List<Map<String, _Action?>> _shiftTable = [];
  final List<Map<String, _Action?>> _gotoTable = [];

  /// Creates a new parse table.
  _Table();

  /// Deserializes the given serialized data into this table.
  factory _Table.deserialize(Deserializer data, Grammar grammar) {
    final int version = data.readInt();
    if (version != 1) throw Exception('Unknown version, $version, for parser table serialization.');

    final _Table table = _Table();
    table._shiftColumns = Set<String>.from(data.readStrList());
    table._gotoColumns = Set<String>.from(data.readStrList());

    final int shiftCount = data.readInt();
    for (int i = 0; i < shiftCount; i++) {
      final Map<String, _Action?> shiftMap = {};
      final int keysCount = data.readInt();
      for (int j = 0; j < keysCount; j++) {
        final String key = data.readStr();
        final _Action? action = table._deserializeAction(data, grammar);
        shiftMap[key] = action;
      }
      table._shiftTable.add(shiftMap);
    }

    final int gotoCount = data.readInt();
    for (int i = 0; i < gotoCount; i++) {
      final Map<String, _Action?> gotoMap = {};
      final int keysCount = data.readInt();
      for (int j = 0; j < keysCount; j++) {
        final String key = data.readStr();
        final _Action? action = table._deserializeAction(data, grammar);
        gotoMap[key] = action;
      }
      table._gotoTable.add(gotoMap);
    }

    return table;
  }

  /// Creates an action from the given data.
  _Action? _deserializeAction(Deserializer data, Grammar grammar) {
    switch (data.readInt()) {
      case 1:
        return _Shift(data.readInt());
      case 2:
        return _Goto(data.readInt());
      case 3:
        final Term term = grammar.term(data.readStr());
        final Rule rule = term.rules[data.readInt()];
        return _Reduce(rule);
      case 4:
        return _Accept();
      case 5:
        return _Error(data.readStr());
    }
    return null;
  }

  /// Serializes the table.
  Serializer serialize() {
    final Serializer data = Serializer();
    data.writeInt(1); // Version 1
    data.writeStrList(this._shiftColumns.toList());
    data.writeStrList(this._gotoColumns.toList());
    data.writeInt(this._shiftTable.length);
    for (final Map<String, _Action?> shiftMap in this._shiftTable) {
      data.writeInt(shiftMap.keys.length);
      for (final String key in shiftMap.keys) {
        data.writeStr(key);
        this._serializeAction(data, shiftMap[key]);
      }
    }
    data.writeInt(this._gotoTable.length);
    for (final Map<String, _Action?> gotoMap in this._gotoTable) {
      data.writeInt(gotoMap.keys.length);
      for (final String key in gotoMap.keys) {
        data.writeStr(key);
        this._serializeAction(data, gotoMap[key]);
      }
    }
    return data;
  }

  /// Sets up the data for serializing an action.
  void _serializeAction(Serializer data, _Action? action) {
    if (action is _Shift) {
      data.writeInt(1);
      data.writeInt(action.state);
    } else if (action is _Goto) {
      data.writeInt(2);
      data.writeInt(action.state);
    } else if (action is _Reduce) {
      data.writeInt(3);
      final Term? term = action.rule.term;
      final int ruleNum = term?.rules.indexOf(action.rule) ?? -1;
      data.writeStr(term?.name ?? '');
      data.writeInt(ruleNum);
    } else if (action is _Accept) {
      data.writeInt(4);
    } else if (action is _Error) {
      data.writeInt(5);
      data.writeStr(action.error);
    }
  }

  /// Gets all the tokens for the row which are not null or error.
  List<String> getAllTokens(int row) {
    final List<String> result = [];
    if ((row >= 0) && (row < this._shiftTable.length)) {
      final Map<String, _Action?> rowData = this._shiftTable[row];
      for (final String key in rowData.keys) {
        final _Action? action = rowData[key];
        if ((action != null) || (action is! _Error)) result.add(key);
      }
    }
    return result;
  }

  /// Reads an action from the table,
  /// returns null if no action set.
  _Action? _read(int row, String column, List<Map<String, _Action?>> table) {
    if ((row >= 0) && (row < table.length)) {
      final Map<String, _Action?> rowData = table[row];
      if (rowData.containsKey(column)) return rowData[column];
    }
    return null;
  }

  /// Reads a shift action from the table,
  /// returns null if no action set.
  _Action? readShift(int row, String column) => this._read(row, column, this._shiftTable);

  /// Reads a goto action from the table,
  /// returns null if no action set.
  _Action? readGoto(int row, String column) => this._read(row, column, this._gotoTable);

  /// Writes a new action to the table.
  void _write(int row, String column, _Action value, Set<String> columns, List<Map<String, _Action?>> table) {
    if (row < 0) throw ArgumentError('row must be zero or more');

    Map<String, _Action?> rowData = {};
    if (row < table.length) {
      rowData = table[row];
    } else {
      while (row >= table.length) {
        rowData = <String, _Action?>{};
        table.add(rowData);
      }
    }
    if (!rowData.containsKey(column)) columns.add(column);
    rowData[column] = value;
  }

  /// Writes a new shift action to the table.
  void writeShift(int row, String column, _Action value) =>
      this._write(row, column, value, this._shiftColumns, this._shiftTable);

  /// Writes a new goto action to the table.
  void writeGoto(int row, String column, _Action value) =>
      this._write(row, column, value, this._gotoColumns, this._gotoTable);

  /// Gets a string output of the table for debugging.
  @override
  String toString() {
    final List<List<String>> grid = [];
    // Add Column labels...
    final List<String> columnLabels = ['']; // blank space for row labels
    final List<String> shiftColumns = this._shiftColumns.toList();
    shiftColumns.sort();
    for (int j = 0; j < shiftColumns.length; j++) {
      columnLabels.add(shiftColumns[j].toString());
    }
    final List<String> gotoColumns = this._gotoColumns.toList();
    gotoColumns.sort();
    for (int j = 0; j < gotoColumns.length; j++) {
      columnLabels.add(gotoColumns[j].toString());
    }
    grid.add(columnLabels);
    // Add all the data into the table...
    final int maxRowCount = max(this._shiftTable.length, this._gotoTable.length);
    for (int row = 0; row < maxRowCount; row++) {
      final List<String> values = ['$row'];
      for (int i = 0; i < shiftColumns.length; i++) {
        final _Action? action = this.readShift(row, shiftColumns[i]);
        if (action == null) {
          values.add('-');
        } else {
          values.add(action.toString());
        }
      }
      for (int i = 0; i < gotoColumns.length; i++) {
        final _Action? action = this.readGoto(row, gotoColumns[i]);
        if (action == null) {
          values.add('-');
        } else {
          values.add(action.toString());
        }
      }
      grid.add(values);
    }
    // Make all the items in a column the same width...
    final int colCount = shiftColumns.length + gotoColumns.length + 1;
    final int rowCount = grid.length;
    for (int j = 0; j < colCount; j++) {
      int maxWidth = 0;
      for (int i = 0; i < rowCount; i++) {
        maxWidth = max(maxWidth, grid[i][j].length);
      }
      for (int i = 0; i < rowCount; i++) {
        grid[i][j] = grid[i][j].padRight(maxWidth);
      }
    }
    // Write the table...
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < rowCount; i++) {
      if (i > 0) buf.writeln();
      for (int j = 0; j < colCount; j++) {
        if (j > 0) buf.write('|');
        buf.write(grid[i][j]);
      }
    }
    return buf.toString();
  }
}
// endregion

// region simple
/// Deserializes a previous serialized string of data.
class Deserializer {
  int _index = 0;
  final String _data;

  /// Creates a new deserializer with the given data.
  Deserializer(
      final this._data,
      );

  /// Gets the serialized string of data.
  @override
  String toString() => this._data.substring(0, this._index) + '•' + this._data.substring(this._index);

  /// Indicates if the deserializer has reached the end.
  bool get hasMore => this._index < this._data.length;

  /// Checks if the end of the data has been reached.
  void _eofException() {
    if (!this.hasMore) {
      throw Exception('Unexpected end of serialized data');
    }
  }

  /// Reads a Boolean from the data.
  bool readBool() {
    this._eofException();
    final c = this._data[this._index];
    this._index++;
    if (c == 'T') {
      return true;
    }
    if (c == 'F') {
      return false;
    }
    throw Exception('Expected T or F but got $c');
  }

  /// Reads an integer from the data.
  int readInt() {
    this._eofException();
    final int start = this._index;
    for (; this._index < this._data.length; this._index++) {
      if (this._data[this._index] == ' ') {
        break;
      }
    }
    this._index++;
    final value = this._data.substring(start, this._index - 1);
    return int.parse(value);
  }

  /// Reads a string from the data.
  String readStr() {
    final length = this.readInt();
    final start = this._index;
    this._index += length;
    return this._data.substring(start, start + length);
  }

  /// Reads a serialization from the data.
  Deserializer readSer() {
    final data = this.readStr();
    return Deserializer(data);
  }

  /// Reads a list of integers from the data.
  List<int> readIntList() {
    final count = this.readInt();
    final list = <int>[];
    for (int i = 0; i < count; i++) {
      list.add(this.readInt());
    }
    return list;
  }

  /// Reads a list of strings from the data.
  List<String> readStrList() {
    final count = this.readInt();
    final list = <String>[];
    for (int i = 0; i < count; i++) {
      list.add(this.readStr());
    }
    return list;
  }

  /// Reads a map of strings to strings from the data.
  Map<String, String> readStringStringMap() {
    final map = <String, String>{};
    final count = this.readInt();
    for (int i = 0; i < count; i++) {
      final key = this.readStr();
      final value = this.readStr();
      map[key] = value;
    }
    return map;
  }
}

/// This is a simple serializer designed for fast serialization and deserialization.
class Serializer {
  final StringBuffer _data = StringBuffer();

  /// Creates a new serializer.
  Serializer();

  /// Gets the serialized string of data.
  @override
  String toString() => this._data.toString();

  /// Writes a Boolean to the data.
  void writeBool(bool value) => this._data.write(value ? 'T' : 'F');

  /// Writes an integer to the data.
  void writeInt(int value) => this._data.write('$value ');

  /// Writes a string to the data.
  void writeStr(String value) => this._data.write('${value.length} $value');

  /// Writes another serializer to the data.
  void writeSer(Serializer? value) => this.writeStr(value?._data.toString() ?? '');

  /// Writes a list of integers to the data.
  void writeIntList(List<int> value) {
    this.writeInt(value.length);
    // ignore: prefer_foreach
    for (final intVal in value) {
      this.writeInt(intVal);
    }
  }

  /// Writes a list of strings to the data.
  void writeStrList(
      final List<String> value,
      ) {
    this.writeInt(value.length);
    // ignore: prefer_foreach
    for (final strVal in value) {
      this.writeStr(strVal);
    }
  }

  /// Writes a map of strings to strings to the data.
  void writeStringStringMap(
      final Map<String, String> value,
      ) {
    this.writeInt(value.length);
    for (final key in value.keys) {
      this.writeStr(key);
      this.writeStr(value[key] ?? '');
    }
  }
}
// endregion

// region tokenizer
/// A tokenizer for breaking a string into tokens.
class Tokenizer {
  final Map<String, State?> _states = {};
  final Map<String, TokenState?> _token = {};
  Set<String> _consume = {};
  State? _start;

  /// Creates a new tokenizer.
  Tokenizer();

  /// Loads a whole tokenizer from the given deserializer.
  factory Tokenizer.deserialize(
      final Deserializer data,
      ) {
    final version = data.readInt();
    if (version != 1) {
      throw Exception('Unknown version, $version, for tokenizer serialization.');
    }
    final tokenizer = Tokenizer();
    final tokenCount = data.readInt();
    for (int i = 0; i < tokenCount; i++) {
      final key = data.readStr();
      final token = TokenState._(tokenizer, key);
      token._replace = data.readStringStringMap();
      tokenizer._token[key] = token;
    }
    final stateCount = data.readInt();
    final keys = <String>[];
    for (int i = 0; i < stateCount; i++) {
      final key = data.readStr();
      tokenizer._states[key] = State._(tokenizer, key);
      keys.add(key);
    }
    for (final key in keys) {
      tokenizer._states[key]?._deserialize(data.readSer());
    }
    tokenizer._consume = Set.from(data.readStrList());
    if (data.readBool()) tokenizer._start = tokenizer._states[data.readStr()];
    return tokenizer;
  }

  /// Creates a serializer to represent the whole tokenizer.
  Serializer serialize() {
    final data = Serializer();
    data.writeInt(1); // Version 1
    data.writeInt(this._token.length);
    for (final key in this._token.keys) {
      data.writeStr(key);
      data.writeStringStringMap(this._token[key]?._replace ?? {});
    }
    data.writeInt(this._states.length);
    // ignore: prefer_foreach
    for (final key in this._states.keys) {
      data.writeStr(key);
    }
    for (final key in this._states.keys) {
      data.writeSer(this._states[key]?._serialize());
    }
    data.writeStrList(this._consume.toList());
    final bool hasStart = this._start != null;
    data.writeBool(hasStart);
    if (hasStart) data.writeStr(this._start?._name ?? '');
    return data;
  }

  /// Sets the start state for the tokenizer to a state with the name [stateName].
  /// If that state doesn't exist it will be created.
  State start(
      final String stateName,
      ) =>
      this._start = this.state(stateName);

  /// Creates and adds a state by the given name [stateName].
  /// If a state already exists it is returned,
  /// otherwise the new state is returned.
  State state(
      final String stateName,
      ) {
    State? state = this._states[stateName];
    if (state == null) {
      state = State._(this, stateName);
      this._states[stateName] = state;
    }
    return state;
  }

  /// Creates and add an acceptance token with the given name [tokenName].
  /// A new acceptance token is not connected to any state.
  /// If a token by that name already exists it will be returned,
  /// otherwise the new token is returned.
  TokenState token(String tokenName) {
    TokenState? token = this._token[tokenName];
    if (token == null) {
      token = TokenState._(this, tokenName);
      this._token[tokenName] = token;
    }
    return token;
  }

  /// Joins the two given states and returns the new or
  /// already existing transition.
  Transition join(String startStateName, String endStateName) =>
      this.state(startStateName).join(endStateName);

  /// This is short hand for a join and setToken
  /// where the state name and token name are the same.
  Transition joinToToken(String startStateName, String endStateName) {
    this.state(endStateName).setToken(endStateName);
    return this.state(startStateName).join(endStateName);
  }

  /// Sets the token for the given state and returns the acceptance token.
  TokenState setToken(String stateName, String tokenName) => this.state(stateName).setToken(tokenName);

  /// Sets which tokens should be consumed and not emitted.
  void consume(Iterable<String> tokens) => this._consume.addAll(tokens);

  /// Tokenizes the given input string with the current configured
  /// tokenizer and returns the iterator of tokens for the input.
  /// This will throw an exception if the input is not tokenizable.
  Iterable<Token> tokenize(String input) => this.tokenizeChars(input.codeUnits.iterator);

  /// Tokenizes the given iterator of characters with the current configured
  /// tokenizer and returns the iterator of tokens for the input.
  /// This will throw an exception if the input is not tokenizable.
  Iterable<Token> tokenizeChars(Iterator<int> iterator) sync* {
    Token? lastToken;
    State? state = this._start;
    int index = 0;
    int lastIndex = 0;
    int lastLength = 0;
    List<int> outText = [];
    List<int> allInput = [];
    final List<int> retoken = [];
    for (;;) {
      int c;
      if (retoken.isNotEmpty) {
        c = retoken.removeAt(0);
      } else {
        if (!iterator.moveNext()) break;
        c = iterator.current;
      }
      allInput.add(c);
      index++;
      // Transition to the next state with the current character.
      final Transition? trans = state?.findTansition(c);
      if (trans == null) {
        // No transition found.
        if (lastToken == null) {
          // No previous found token state, therefore this part
          // of the input isn't tokenizable with this tokenizer.
          final String text = String.fromCharCodes(allInput);
          throw Exception('Untokenizable string [state: ${state?.name}, index $index]: "$text"');
        }
        // Reset to previous found token's state.
        final Token resultToken = lastToken;
        index = lastIndex;
        allInput.removeRange(0, lastLength);
        retoken.addAll(allInput);
        allInput = [];
        outText = [];
        lastToken = null;
        lastLength = 0;
        state = this._start;
        if (!this._consume.contains(resultToken.name)) {
          yield resultToken;
        }
      } else {
        // Transition to the next state and check if it is an acceptance state.
        // Store acceptance state to return to if needed.
        if (!trans.consume) outText.add(c);
        state = trans.target;
        if (state?.token != null) {
          final String text = String.fromCharCodes(outText);
          lastToken = state?.token?.getToken(text, index);
          lastLength = allInput.length;
          lastIndex = index;
        }
      }
    }
    if ((lastToken != null) && (!this._consume.contains(lastToken.name))) {
      yield lastToken;
    }
  }

  /// Gets the human readable debug string.
  @override
  String toString() {
    final buf = StringBuffer();
    if (this._start != null) buf.writeln(this._start?._toDebugString());
    for (final state in this._states.values) {
      if (state != this._start) buf.writeln(state?._toDebugString());
    }
    return buf.toString();
  }
}

/// A state in the tokenizer used as a character
/// point in the tokenizer state machine.
class State {
  final Tokenizer _tokenizer;
  final String _name;
  final List<Transition> _trans = [];
  TokenState? _token;

  /// Creates a new state for this given tokenizer.
  State._(this._tokenizer, this._name);

  /// Loads a matcher group from the given deserializer.
  void _deserializeGroup(Group group, Deserializer data) {
    final int matcherCount = data.readInt();
    for (int i = 0; i < matcherCount; i++) {
      switch (data.readInt()) {
        case 0:
          this._deserializeGroup(group.addNot(), data);
          break;
        case 1:
          final Group other = Group();
          this._deserializeGroup(other, data);
          group.add(other);
          break;
        case 2:
          group.addAll();
          break;
        case 3:
          group.add(Range.fromCodeUnits(data.readInt(), data.readInt()));
          break;
        case 4:
          group.addSet(data.readStr());
          break;
      }
    }
  }

  /// Loads a state from the given deserializer.
  void _deserialize(Deserializer data) {
    final int transCount = data.readInt();
    for (int i = 0; i < transCount; i++) {
      final String key = data.readStr();
      final State? target = this._tokenizer._states[key];
      final Transition trans = Transition._(target);
      trans.consume = data.readBool();
      this._deserializeGroup(trans, data);
      this._trans.add(trans);
    }
    if (data.readBool()) {
      this._token = this._tokenizer._token[data.readStr()];
    }
  }

  /// Creates a serializer to represent the matcher group.
  void _serializeGroup(Serializer data, Group group) {
    data.writeInt(group.matchers.length);
    for (final Matcher matcher in group.matchers) {
      if (matcher is Not) {
        data.writeInt(0);
        this._serializeGroup(data, matcher);
      } else if (matcher is Group) {
        data.writeInt(1);
        this._serializeGroup(data, matcher);
      } else if (matcher is All) {
        data.writeInt(2);
      } else if (matcher is Range) {
        data.writeInt(3);
        data.writeInt(matcher.low);
        data.writeInt(matcher.high);
      } else if (matcher is MatcherSet) {
        data.writeInt(4);
        data.writeStr(matcher.toString());
      } else {
        throw Exception('Unknown matcher: $matcher');
      }
    }
  }

  /// Creates a serializer to represent the state.
  Serializer _serialize() {
    final Serializer data = Serializer();
    data.writeInt(this._trans.length);
    for (final Transition trans in this._trans) {
      data.writeStr(trans._target?._name ?? '');
      data.writeBool(trans.consume);
      this._serializeGroup(data, trans);
    }
    final bool hasTokenState = this._token != null;
    data.writeBool(hasTokenState);
    if (hasTokenState) data.writeStr(this._token?._name ?? '');
    return data;
  }

  /// Gets the name of the state.
  String get name => this._name;

  /// Gets the acceptance token for this state if this state
  /// accepts the input at this point.
  /// If this isn't an accepting state this will return null.
  TokenState? get token => this._token;

  /// Sets the acceptance token for this state to the token with
  /// the given [tokenName]. If no token by that name exists it
  /// will be created. The new token is returned.
  TokenState setToken(String tokenName) => this._token = this._tokenizer.token(tokenName);

  /// Joins this state to another state by the given [endStateName]
  /// with a new transition. If a transition already exists between
  /// these two states that transition is returned,
  /// otherwise the new transition is returned.
  Transition join(String endStateName) {
    for (final Transition trans in this._trans) {
      if (trans.target?.name == endStateName) return trans;
    }
    final target = this._tokenizer.state(endStateName);
    final trans = Transition._(target);
    this._trans.add(trans);
    return trans;
  }

  /// Finds the matching transition given a character.
  /// If no transition matches null is returned.
  Transition? findTansition(final int c) {
    for (final trans in this._trans) {
      if (trans.match(c)) return trans;
    }
    return null;
  }

  /// Gets the name for this state.
  @override
  String toString() => this._name;

  /// Gets the human readable debug string.
  String _toDebugString() {
    final buf = StringBuffer();
    buf.write('(${this._name})');
    if (this._token != null) {
      buf.write(' => [${this._token?._name}]');
      if (this._tokenizer._consume.contains(this._token?._name)) buf.write(' (consume)');
      for (final text in this._token?._replace.keys ?? <String>[]) {
        buf.writeln();
        final target = this._token?._replace[text] ?? '';
        buf.write('  -- ${text} => [$target]');
        if (this._tokenizer._consume.contains(target)) buf.write(' (consume)');
      }
    }
    for (final trans in this._trans) {
      buf.writeln();
      buf.write('  -- ${trans.toString()}');
    }
    return buf.toString();
  }
}

/// A token contains the text and information from a tokenizer.
class Token {
  /// The name of the token type.
  final String name;

  /// The text for this token.
  final String text;

  /// The index offset from the start of the input string.
  final int index;

  /// Creates a new token.
  Token(
      final this.name,
      final this.text,
      final this.index,
      );

  /// Gets the string for this token.
  @override
  String toString() => '$name:$index:"' + this.text.replaceAll('\n', '\\n').replaceAll('\t', '\\t') + '"';
}

/// A token state is added to a state to indicate that
/// the state is acceptance for a token.
class TokenState {
  final Tokenizer _tokenizer;
  final String _name;
  Map<String, String> _replace = {};

  /// Creates a new token state for the given tokenizer.
  TokenState._(
      final this._tokenizer,
      final this._name,
      );

  /// Gets the name of this token.
  String get name => this._name;

  /// Adds a replacement which replaces this token's name with the given
  /// [tokenName] when the accepted text is the same as any of the given [text].
  void replace(
      final String tokenName,
      final Iterable<String> text,
      ) {
    for (final t in text) {
      this._replace[t] = tokenName;
    }
  }

  /// Indicates that tokens with this name should not be emitted
  /// but quietly consumed.
  void consume() => this._tokenizer.consume([
    this._name,
  ]);

  /// Creates a token for this token state and the given [text].
  /// If the text matches a replacement's text the
  /// replacement token is used instead.
  Token getToken(
      final String text,
      final int index,
      ) =>
      Token(
        this._replace[text] ?? this._name,
        text,
        index,
      );

  /// Gets the name for this token.
  @override
  String toString() => this._name;
}

/// A transition is a matcher group which connects two states together.
/// When at one state this transition should be taken to the next if
/// the next character in the input is a match.
class Transition extends Group {
  final State? _target;

  /// Indicates if the character should be consumed (true)
  /// or appended (false) to the resulting string.
  bool consume = false;

  /// Creates a new transition.
  Transition._(
      final this._target,
      ) : super();

  /// Gets the state to goto if a character matches this transition.
  State? get target => this._target;

  /// Gets the string for this transition.
  @override
  String toString() => '${this._target?.name}: ' + super.toString();
}
// endregion

// region parse tree
/// The handler signature for a method to call for a specific trigger.
typedef TriggerHandle = void Function(TriggerArgs args);

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
abstract class TreeNode {
  /// Processes this tree node with the given handles for the triggers to call.
  void process(
      final Map<String, TriggerHandle> handles,
      );
}

/// The argument passed into the trigger handler when it is being called.
class TriggerArgs {
  /// The list of recent tokens while processing a tree node.
  List<Token> tokens = [];

  /// Creates a new trigger argument.
  TriggerArgs();

  /// Gets the recent token offset from most recent by the given index.
  Token? recent(
      final int index,
      ) {
    if ((index > 0) && (index <= tokens.length)) {
      return this.tokens[this.tokens.length - index];
    } else {
      return null;
    }
  }
}

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
class RuleNode implements TreeNode {
  static const String _charStart = '─';
  static const String _charBar = '  │';
  static const String _charBranch = '  ├─';
  static const String _charSpace = '   ';
  static const String _charLeaf = '  └─';

  /// The grammar rule for this node.
  final Rule rule;

  /// The list of items for this rule.
  /// The items are `TreeNodes` and `Tokenizer.Token`s.
  final List<TreeNode> items;

  /// Creates a new tree node.
  const RuleNode(
      final this.rule,
      final this.items,
      );

  /// Helps construct the debugging output of the tree.
  void _toTree(StringBuffer buf, String indent, String first) {
    buf.write(first + '<' + (this.rule.term?.name ?? '') + '>');
    if (items.isNotEmpty) {
      for (int i = 0; i < items.length - 1; i++) {
        final item = items[i];
        if (item is RuleNode) {
          item._toTree(buf, indent + _charBar, '\n' + indent + _charBranch);
        } else {
          buf.write('\n' + indent + _charBranch + item.toString());
        }
      }
      final item = items[items.length - 1];
      if (item is RuleNode) {
        item._toTree(buf, indent + _charSpace, '\n' + indent + _charLeaf);
      } else {
        buf.write('\n' + indent + _charLeaf + item.toString());
      }
    }
  }

  /// Processes this tree node with the given handles for the triggers to call.
  @override
  void process(Map<String, TriggerHandle> handles) {
    final List<TreeNode> stack = [];
    stack.add(this);
    final TriggerArgs args = TriggerArgs();
    while (stack.isNotEmpty) {
      final TreeNode node = stack.removeLast();
      if (node is RuleNode) {
        stack.addAll(node.items.reversed);
      } else if (node is TokenNode) {
        args.tokens.add(node.token);
      } else if (node is TriggerNode) {
        if (!handles.containsKey(node.trigger)) {
          throw Exception('Failed to find the handle for the trigger, ${node.trigger}');
        }
        handles[node.trigger]?.call(args);
      }
    }
  }

  /// Gets a string for the tree node.
  @override
  String toString() {
    final buf = StringBuffer();
    this._toTree(buf, '', _charStart);
    return buf.toString();
  }
}

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
class TokenNode implements TreeNode {
  /// The token found at this point in the parse tree.
  final Token token;

  /// Creates a new token parse tree node.
  const TokenNode(
      final this.token,
      );

  /// Processes this tree node with the given handles for the triggers to call.
  @override
  void process(
      final Map<String, TriggerHandle> handles,
      ) {
    // Do Nothing, no trigger so there is no effect.
  }

  /// Gets a string for this tree node.
  @override
  String toString() => '[${this.token.toString()}]';
}

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
class TriggerNode implements TreeNode {
  /// The token found at this point in the parse tree.
  final String trigger;

  /// Creates a new token parse tree node.
  const TriggerNode(
      final this.trigger,
      );

  /// Processes this tree node with the given handles for the triggers to call.
  @override
  void process(
      final Map<String, TriggerHandle> handles,
      ) {
    if (!handles.containsKey(this.trigger)) {
      throw Exception('Failed to find the handle for the trigger, ${this.trigger}');
    } else {
      handles[this.trigger]?.call(TriggerArgs());
    }
  }

  /// Gets a string for this tree node.
  @override
  String toString() => '{${this.trigger}}';
}
// endregion

// region matcher
/// A matcher which matches a set of characters.
class MatcherSet implements Matcher {
  List<int> _set = [];

  /// Creates a set matcher for all the characters in the given string.
  /// The set must contain at least one character.
  factory MatcherSet(String charSet) {
    return MatcherSet.fromCodeUnits(charSet.codeUnits);
  }

  /// Creates a set matcher with a given list of code units.
  /// The set must contain at least one character.
  MatcherSet.fromCodeUnits(Iterable<int> charSet) {
    if (charSet.isEmpty) throw Exception('May not create a Set with zero characters.');
    final map = <int, bool>{};
    for (final char in charSet) {
      map[char] = true;
    }
    final reducedSet = List<int>.from(map.keys);
    reducedSet.sort();
    this._set = reducedSet;
  }

  /// Determines if this matcher matches the given character, [c].
  /// Returns true if the given character is in the set, false otherwise.
  @override
  bool match(int c) => this._set.contains(c);

  /// Returns the string for this matcher.
  @override
  String toString() => String.fromCharCodes(this._set);
}

/// Creates a range matcher.
class Range implements Matcher {
  /// The lowest character value included in this range.
  final int low;

  /// The highest character value included in this range.
  final int high;

  /// Creates a new range matcher for the given inclusive range.
  /// The given strings may only contain one character.
  factory Range(String lowChar, String highChar) {
    if ((lowChar.length != 1) || (highChar.length != 1)) {
      throw Exception(
          "The given low and high character strings for a Range must have one and only one characters.");
    }
    final low = lowChar.codeUnitAt(0);
    final high = highChar.codeUnitAt(0);
    return Range.fromCodeUnits(low, high);
  }

  /// Creates a new range matcher.
  Range._(this.low, this.high);

  /// Creates a new range matcher for the given inclusive range.
  /// The given values are the code units for the characters.
  factory Range.fromCodeUnits(int low, int high) {
    if (low > high) {
      final temp = low;
      low = high;
      high = temp;
    }
    return Range._(low, high);
  }

  /// Determines if this matcher matches the given character, [c].
  /// Returns true if the character is inclusively in the given range, false otherwise.
  @override
  bool match(int c) => (this.low <= c) && (this.high >= c);

  /// Returns the string for this matcher.
  @override
  String toString() {
    final low = String.fromCharCode(this.low);
    final high = String.fromCharCode(this.high);
    return "$low..$high";
  }
}

/// A group of matchers which returns the opposite of the contained group of matchers.
class Not extends Group {
  /// Creates a not matcher group.
  Not() : super();

  /// Determines if this matcher matches the given character, [c].
  /// Returns the opposite of the matches in the group.
  @override
  bool match(int c) => !super.match(c);

  /// Returns the string for this matcher.
  @override
  String toString() => "![${super.toString()}]";
}

/// A [Matcher] is the interface used by transitions to determine is
/// a character will transition the tokenizer from one state to another.
abstract class Matcher {
  /// Determines if this matcher matches the given character, [c].
  /// It returns true if it is a match and false otherwise.
  bool match(int c);
}

/// A group of matchers for matching complicated sets of characters.
class Group implements Matcher {
  final List<Matcher> _matchers = [];

  /// Creates a new matcher group.
  Group();

  /// Gets the list of matchers in this group.
  List<Matcher> get matchers => this._matchers;

  /// Determines if this matcher matches the given character, [c].
  /// If any matcher matches the given character true is returned.
  @override
  bool match(int c) {
    for (final matcher in this._matchers) {
      if (matcher.match(c)) return true;
    }
    return false;
  }

  /// Adds a matcher to this group.
  Matcher add(Matcher matcher) {
    this._matchers.add(matcher);
    return matcher;
  }

  /// Adds a character set matcher to this group.
  MatcherSet addSet(String charSet) => this.add(MatcherSet(charSet)) as MatcherSet;

  /// Adds a range of characters to match to this group.
  Range addRange(String lowChar, String highChar) => this.add(Range(lowChar, highChar)) as Range;

  /// Adds a matcher to match all characters.
  All addAll() => this.add(All()) as All;

  /// Adds a not matcher group.
  Not addNot() => this.add(Not()) as Not;

  /// Returns the string for this matcher.
  @override
  String toString() {
    String str = "";
    for (final matcher in this._matchers) {
      if (str.isNotEmpty) str += ", ";
      // ignore: use_string_buffers
      str += matcher.toString();
    }
    return str;
  }
}

/// A matcher which matches all characters.
/// Since transitions are called in the order they are added
/// this matcher can be used as an "else" matcher.
class All implements Matcher {
  /// Creates a new all character matcher.
  All();

  /// Determines if this matcher matches the given character, [c].
  /// In this case it always returns true.
  @override
  bool match(int c) => true;

  /// Returns the string for this matcher.
  @override
  String toString() => "all";
}
// endregion

// region grammar
/// A grammar is a definition of a language.
/// It is made up of a set of terms and the rules for how each term is used.
///
/// Formally a Grammar is defined as `G = (V, E, R, S)`:
/// - `V` is the set of `v` (non-terminal characters / variables).
///   These are referred to as the terms of the grammar in this implementation.
/// - `E` (normally shown as an epsilon) is the set of `t` (terminals / tokens).
///   These are referred to as the tokens of this grammar in this implementation.
///   `V` and `E` are disjoint, meaning no `v` exists in `E` and no `t` exists in `V`.
/// - `R` is the relationship of `V` to `(V union E)*`, where here the asterisk is
///   the Kleene star operation. Each `r` in `R` is a rule (rewrite rules / productions)
///   of the grammar as represented by `v → [v or t]*` where `[v or t]` is an item in
///   in the rule. Each term must be the start of one or more rules with, at least
///   one rule must contain a single item. Each term may include a rule with no items
///   (`v → ε`). There should be no duplicate rules for a term.
/// - `S` is the start term where `S` must exist in `V`.
///
/// For the LR1 parser, used by Petite Parser Dart, the grammar must be a Context-free
/// Language (CFL) where `L(G) = {w in E*: S => w}`, meaning that all non-terminals can be
/// reached (`=>` means reachable) from the start term following the rules of the grammar.
///
/// To be a _proper_ CFG there my be no unreachable terms (for all `N` in `V` there
/// exists an `a` and `b` in `(V union U)*` such that `S => a N b`), no unproductive
/// symbols (for all `N` in `V` there exists a `w` in `E*` such that `N => w`),
/// no ε-rules (there does not exist an `N` in `V` such that `N → ε` exist in `R`), and
/// there are no cycles (there does not exist an `N` in `V` such that `N => ... => N`).
///
/// For more information see https://en.wikipedia.org/wiki/Context-free_grammar
class Grammar {
  final Set<Term> _terms = {};
  final Set<TokenItem> _tokens = {};
  final Set<Trigger> _triggers = {};
  Term? _start;

  /// Creates a new empty grammar.
  Grammar();

  /// Deserializes the given serialized data into a grammar.
  factory Grammar.deserialize(
      final Deserializer data,
      ) {
    final version = data.readInt();
    if (version != 1) {
      throw Exception('Unknown version, $version, for grammar serialization.');
    }
    final grammar = Grammar();
    grammar.start(data.readStr());
    final termCount = data.readInt();
    for (int i = 0; i < termCount; i++) {
      final term = grammar.term(data.readStr());
      final ruleCount = data.readInt();
      for (int j = 0; j < ruleCount; j++) {
        final rule = term.newRule();
        final itemCount = data.readInt();
        for (int k = 0; k < itemCount; k++) {
          final itemType = data.readInt();
          final itemName = data.readStr();
          switch (itemType) {
            case 1:
              rule.addTerm(itemName);
              break;
            case 2:
              rule.addToken(itemName);
              break;
            case 3:
              rule.addTrigger(itemName);
              break;
          }
        }
      }
    }
    return grammar;
  }

  /// Creates a copy of this grammar.
  Grammar copy() {
    final grammar = Grammar();
    for (final term in this._terms) {
      grammar._add(term.name);
    }
    if (this._start != null) {
      grammar._start = grammar._findTerm(this._start?.name ?? '');
    }
    for (final term in this._terms) {
      final termCopy = grammar._findTerm(term.name);
      if (termCopy != null) {
        for (final rule in term.rules) {
          final ruleCopy = Rule._(grammar, termCopy);
          for (final item in rule.items) {
            Item itemCopy;
            if (item is Term) {
              itemCopy = grammar.term(item.name);
            } else if (item is TokenItem) {
              itemCopy = grammar.token(item.name);
            } else if (item is Trigger) {
              itemCopy = grammar.trigger(item.name);
            } else {
              throw Exception('Unknown item type: $item');
            }
            ruleCopy._items.add(itemCopy);
          }
          termCopy.rules.add(ruleCopy);
        }
      }
    }
    return grammar;
  }

  /// Serializes the grammar.
  Serializer serialize() {
    final data = Serializer();
    data.writeInt(1); // Version 1
    data.writeStr(this._start?.name ?? '');
    data.writeInt(this._terms.length);
    for (final term in this._terms) {
      data.writeStr(term.name);
      data.writeInt(term.rules.length);
      for (final rule in term.rules) {
        data.writeInt(rule.items.length);
        for (final item in rule.items) {
          final int itemType;
          if (item is Term) {
            itemType = 1;
          } else {
            if (item is TokenItem) {
              itemType = 2;
            } else {
              itemType = 3;
            }
          }
          data.writeInt(itemType);
          data.writeStr(item.name);
        }
      }
    }
    return data;
  }

  /// This will trim the term name and check if the name is empty.
  String _sanitizedTermName(String name) {
    // ignore: parameter_assignments
    name = name.trim();
    if (name.isEmpty) throw Exception('May not have an all whitespace or empty term name.');
    return name;
  }

  /// Creates or adds a term for a set of rules
  /// and sets it as the starting term for the grammar.
  Term start(String termName) => this._start = this.term(termName);

  /// Gets the start term for this grammar.
  Term? get startTerm => this._start;

  /// Gets the terms for this grammar.
  List<Term> get terms => this._terms.toList();

  /// Gets the tokens for this grammar.
  List<TokenItem> get tokens => this._tokens.toList();

  /// Gets the triggers for this grammar.
  List<Trigger> get triggers => this._triggers.toList();

  /// Finds a term in this grammar by the given name.
  /// Returns null if no term by that name if found.
  Term? _findTerm(String termName) {
    for (final term in this._terms) {
      if (term.name == termName) return term;
    }
    return null;
  }

  /// Adds a new term to this grammar.
  /// If the start term isn't set, it will be set to this term.
  Term _add(String termName) {
    final nt = Term._(this, termName);
    this._terms.add(nt);
    this._start ??= nt;
    return nt;
  }

  /// Find the existing token in this grammar
  /// or add it if not found.
  TokenItem token(String tokenName) {
    // ignore: parameter_assignments
    tokenName = tokenName.trim();
    if (tokenName.isEmpty) throw Exception('May not have an all whitespace or empty token name.');
    for (final token in this._tokens) {
      if (token.name == tokenName) return token;
    }
    final token = TokenItem(tokenName);
    this._tokens.add(token);
    return token;
  }

  /// Find the existing trigger in this grammar
  /// or add it if not found.
  Trigger trigger(String triggerName) {
    // ignore: parameter_assignments
    triggerName = triggerName.trim();
    if (triggerName.isEmpty) throw Exception('May not have an all whitespace or empty trigger name.');
    for (final trigger in this._triggers) {
      if (trigger.name == triggerName) return trigger;
    }
    final trigger = Trigger(triggerName);
    this._triggers.add(trigger);
    return trigger;
  }

  /// Gets or adds a term for a set of rules to this grammar.
  /// If the start term isn't set, it will be set to this term.
  Term term(String termName) {
    // ignore: parameter_assignments
    termName = this._sanitizedTermName(termName);
    Term? nt = this._findTerm(termName);
    return nt ??= this._add(termName);
  }

  /// Gets or adds a term for and starts a new rule for that term.
  /// If the start term isn't set, it will be set to this rule's term.
  /// The new rule is returned.
  Rule newRule(String termName) => this.term(termName).newRule();

  /// Gets a string showing the whole language.
  @override
  String toString() {
    final buf = StringBuffer();
    if (this._start != null) buf.writeln("> " + this._start.toString());
    for (final term in this._terms) {
      // ignore: prefer_foreach
      for (final rule in term.rules) {
        buf.writeln(rule);
      }
    }
    return buf.toString();
  }

  /// Validates the grammars configuration,
  /// on success (no errors) an empty string is returned,
  /// on failure a string containing each error line separated is returned.
  String validate() {
    final buf = StringBuffer();
    if (this._terms.isEmpty) buf.writeln('No terms are defined.');
    if (this._tokens.isEmpty) buf.writeln('No tokens are defined.');
    if (this._start == null) {
      buf.writeln('The start term is not set.');
    } else if (!this._terms.contains(this._start)) {
      buf.writeln('The start term, ${this._start}, was not found in the set of terms.');
    }
    final termList = this._terms.toList();
    for (int i = termList.length - 1; i >= 0; i--) {
      for (int j = i - 1; j >= 0; j--) {
        if (termList[i].name == termList[j].name) {
          buf.writeln('There exists two terms with the same name, ${termList[i].name}.');
        }
      }
    }
    for (final term in this._terms) {
      if (term.name.trim().isEmpty) buf.writeln('There exists a term which is all whitespace or empty.');
      if (term._rules.isEmpty) buf.writeln('The term, $term, has no rules defined for it.');
      for (int i = term._rules.length - 1; i >= 0; i--) {
        for (int j = i - 1; j >= 0; j--) {
          if (term._rules[i].equals(term._rules[j])) {
            buf.writeln('There exists two rules which are the same, ${term._rules[i].toString()}.');
          }
        }
      }
      for (final rule in term._rules) {
        if (rule.term == null) {
          buf.writeln('The rule for ${term.name} is rule.');
        } else if (rule.term != term) {
          buf.writeln('The rule for ${term.name} says it is for ${rule.term?.name ?? 'null'}.');
        }
        for (final item in rule._items) {
          if (item.name.trim().isEmpty) {
            buf.writeln('There exists an item in rule for ${term.name} which is all whitespace or empty.');
          }
          if (item is Term) {
            if (!this._terms.contains(item)) {
              buf.writeln("The term, $item, in a rule for ${term.name}, was not found in the set of terms.");
            }
          } else if (item is TokenItem) {
            if (!this._tokens.contains(item)) {
              buf.writeln(
                  'The token, $item, in a rule for ${term.name}, was not found in the set of tokens.');
            }
          } else if (item is Trigger) {
            if (!this._triggers.contains(item)) {
              buf.writeln(
                  'The trigger, $item, in a rule for ${term.name}, was not found in the set of triggers.');
            }
          } else {
            throw Exception('Unknown item type in ${term.name}.');
          }
        }
      }
    }
    final unreached = _grammarUnreached(buf, termList, this._tokens, this._triggers);
    unreached.touch(this._start);
    unreached.validate();
    return buf.toString();
  }
}

/// This is a tool to help grammar validate unreachable states.
class _grammarUnreached {
  final StringBuffer _buf;
  final Set<String> _terms = {};
  final Set<String> _tokens = {};
  final Set<String> _triggers = {};

  /// Creates and populates a new unreachable validation.
  _grammarUnreached(this._buf, List<Term> terms, Set<TokenItem> tokens, Set<Trigger> triggers) {
    this._terms.addAll(terms.map<String>((Term t) => t.name));
    this._tokens.addAll(tokens.map<String>((TokenItem t) => t.name));
    this._triggers.addAll(triggers.map<String>((Trigger t) => t.name));
  }

  /// Touches the item and all the rules and items that are reachable.
  /// Anything reached is removed to leave only the unreachables.
  void touch(Item? item) {
    if (item == null) return;
    if (item is Term) {
      if (this._terms.contains(item.name)) {
        this._terms.remove(item.name);
        for (final r in item._rules) {
          // ignore: prefer_foreach
          for (final item in r._items) {
            this.touch(item);
          }
        }
      }
    } else if (item is TokenItem) {
      this._tokens.remove(item.name);
    } else if (item is Trigger) {
      this._triggers.remove(item.name);
    } else {
      _buf.writeln('Unknown item type: $item');
    }
  }

  /// Validates the unreachable and writes errors to the buffer.
  void validate() {
    if (this._terms.isNotEmpty) {
      _buf.writeln('The following terms are unreachable: ${this._terms.join(', ')}');
    }
    if (this._tokens.isNotEmpty) {
      _buf.writeln('The following tokens are unreachable: ${this._tokens.join(', ')}');
    }
    if (this._triggers.isNotEmpty) {
      _buf.writeln('The following triggers are unreachable: ${this._triggers.join(', ')}');
    }
  }
}

/// A trigger is an optional item which can be added
/// to a parse that is carried through to the parse results.
/// The triggers can used when compiling or interpreting.
class Trigger extends Item {
  /// Creates a new trigger.
  const Trigger(
      final String name,
      ) : super._(
    name,
  );

  /// Gets the string for this trigger.
  @override
  String toString() => "{${this.name}}";
}

/// A token is an item to represent a group of text
/// to the parser so it can match tokens to determine the
/// different rules to take while parsing.
/// This mirrors the `Tokenizer.Token` result object.
class TokenItem extends Item {
  /// Creates a new token.
  const TokenItem(
      final String name,
      ) : super._(
    name,
  );

  /// Gets the string for this token.
  @override
  String toString() => "[${this.name}]";
}

/// A term is a group of rules and part of a rule
/// which defines part of the grammar language.
///
/// For example the term `<T>` with the rules `<T> => "(" <E> ")"`,
/// `<T> => <E> * <E>`, and `<T> => <E> + <E>`.
class Term extends Item {
  final Grammar _grammar;
  final List<Rule> _rules = [];

  /// Creates a new term with the given name for the given grammar.
  Term._(this._grammar, String name) : super._(name);

  /// Gets the list of rules starting with this term.
  List<Rule> get rules => this._rules;

  /// Adds a new rule to this term.
  Rule newRule() {
    final rule = Rule._(this._grammar, this);
    this._rules.add(rule);
    return rule;
  }

  /// Determines the first tokens that can be reached from
  /// the rules of this term.
  List<TokenItem> determineFirsts() {
    final tokens = <TokenItem>{};
    this._determineFirsts(tokens, <Term>{});
    return tokens.toList();
  }

  /// Determines the follow tokens that can be reached from the reduction of all the rules,
  /// i.e. the tokens which follow after the term and any first term in all the rules.
  List<TokenItem> determineFollows() {
    final tokens = <TokenItem>{};
    this._determineFollows(tokens, <Term>{});
    return tokens.toList();
  }

  /// This is the recursive part of the determination of the first token sets which
  /// allows for terms which have already been checked to not be checked again.
  void _determineFirsts(Set<TokenItem> tokens, Set<Term> checked) {
    if (checked.contains(this)) return;
    checked.add(this);
    bool needFollows = false;
    for (final rule in this._rules) {
      if (this._determineRuleFirsts(rule, tokens, checked)) needFollows = true;
    }
    if (needFollows) this._determineFollows(tokens, <Term>{});
  }

  /// This determines the firsts for the given rule.
  /// If the rule has no tokens or terms this will return true
  /// indicating that the rule needs follows to be added.
  bool _determineRuleFirsts(Rule rule, Set<TokenItem> tokens, Set<Term> checked) {
    for (final item in rule.items) {
      if (item is Term) {
        item._determineFirsts(tokens, checked);
        return false;
      } else if (item is TokenItem) {
        tokens.add(item);
        return false;
      }
      // else if Trigger continue.
    }
    return true;
  }

  /// This is the recursive part of the determination of the follow token sets which
  /// allows for terms which have already been checked to not be checked again.
  void _determineFollows(Set<TokenItem> tokens, Set<Term> checked) {
    if (checked.contains(this)) return;
    checked.add(this);
    for (final term in this._grammar.terms) {
      for (final rule in term.rules) {
        final items = rule.basicItems;
        final count = items.length;
        for (int i = 0; i < count - 1; i++) {
          if (items[i] == this) {
            final item = items[i + 1];
            if (item is Term) {
              item._determineFirsts(tokens, <Term>{});
            } else {
              tokens.add(item as TokenItem);
            }
          }
        }

        if ((items.isNotEmpty) && (items[count - 1] == this)) {
          term._determineFollows(tokens, checked);
        }
      }
    }
  }

  /// Gets the string for this term.
  @override
  String toString() => "<${this.name}>";
}

/// A rule is a single definition from a grammar.
///
/// For example `<T> → "(" <E> ")"`. The term for the rule is
/// the left hand side (`T`) while the items are the parts on the right hand size.
/// The items are made up of tokens (`(`, `)`) and the rule's term or other terms (`E`).
/// The order of the items defines how this rule in the grammar is to be used.
class Rule {
  final Grammar _grammar;
  final Term? _term;
  final List<Item> _items = [];

  /// Creates a new rule for the the given grammar and term.
  Rule._(this._grammar, Term this._term);

  /// Adds a term to this rule.
  /// This will get or create a new term to the grammar.
  /// Returns this rule so that rule creation can be chained.
  // ignore: avoid_returning_this
  Rule addTerm(String termName) {
    final term = this._grammar.term(termName);
    this._items.add(term);
    return this;
  }

  /// Adds a token to this rule.
  /// Returns this rule so that rule creation can be chained.
  // ignore: avoid_returning_this
  Rule addToken(String tokenName) {
    final token = this._grammar.token(tokenName);
    this._items.add(token);
    return this;
  }

  /// Adds a trigger to this rule.
  /// Returns this rule so that rule creation can be chained.
  // ignore: avoid_returning_this
  Rule addTrigger(String triggerName) {
    final trigger = this._grammar.trigger(triggerName);
    this._items.add(trigger);
    return this;
  }

  /// Gets the left hand side term to the rule.
  Term? get term => this._term;

  /// Gets all the terms, tokens, and triggers for this rule.
  /// The items are in the order defined by this rule.
  List<Item> get items => this._items;

  /// Gets the set of terms and tokens without the triggers.
  List<Item> get basicItems {
    final items = <Item>[];
    for (final item in this._items) {
      if (item is! Trigger) items.add(item);
    }
    return items;
  }

  /// Determines if the given rule is equal to this rule.
  /// This uses pointer comparison for item equivalency.
  bool equals(Rule? other) {
    if (other == null) return false;
    if (this._term != other._term) return false;
    if (this._items.length != other._items.length) return false;
    for (int i = this._items.length - 1; i >= 0; i--) {
      if (this._items[i] != other._items[i]) return false;
    }
    return true;
  }

  /// Gets the string for this rule.
  /// Has an optional step index for showing the different
  /// states of the parser generator.
  @override
  String toString([int stepIndex = -1]) {
    final parts = <String>[];
    int index = 0;
    for (final item in this._items) {
      if (index == stepIndex) {
        parts.add('•');
        // ignore: parameter_assignments
        stepIndex = -1;
      }
      parts.add(item.toString());
      if (item is! Trigger) index++;
    }
    if (index == stepIndex) parts.add('•');
    return this._term.toString() + ' → ' + parts.join(' ');
  }
}

/// An item is part of a term rule.
abstract class Item {
  /// The name of the item.
  final String name;

  /// Creates a new item.
  const Item._(
      final this.name,
      );

  /// Gets the string for this item.
  @override
  String toString() => this.name;
}
// endregion

// region diff
/// A continuous group of step types.
class Step {
  /// The type for this group.
  final StepType type;

  /// The number of the given type in the group.
  final int count;

  /// Creates a new step group.
  const Step(
      final this.type,
      final this.count,
      );

  /// Gets the string for this group.
  @override
  String toString() => '$type $count';
}

/// This is the steps of the Levenshtein path.
enum StepType {
  /// Indicates A and B entries are equal.
  Equal,

  /// Indicates A was added.
  Added,

  /// Indicates A was removed.
  Removed
}

/// Gets the difference path for the sources as defined by the given comparable.
Iterable<Step> diffPath(
    final Comparable comp,
    ) =>
    _Path(comp).iteratePath();

/// Gets the difference path for the two given string lists.
Iterable<Step> stringListPath(
    final List<String> aSource,
    final List<String> bSource,
    ) =>
    diffPath(
      _StringsComparable(
        aSource,
        bSource,
      ),
    );

/// Gets the difference path for the lines in the given strings.
Iterable<Step> linesPath(
    final String aSource,
    final String bSource,
    ) =>
    stringListPath(
      aSource.split('\n'),
      bSource.split('\n'),
    );

/// Gets the labelled difference between the two list of lines.
/// It formats the results by prepending a "+" to new lines in `bSource`,
/// a "-" for any to removed strings from `aSource`, and space if the strings are the same.
String plusMinusLines(
    final String aSource,
    final String bSource,
    ) =>
    plusMinusParts(
      aSource.split('\n'),
      bSource.split('\n'),
    ).join('\n');

/// Gets the labelled difference between the two list of lines.
/// It formats the results by prepending a "+" to new lines in `bSource`,
/// a "-" for any to removed strings from `aSource`, and space if the strings are the same.
List<String> plusMinusParts(
    final List<String> aSource,
    final List<String> bSource,
    ) {
  final result = <String>[];
  int aIndex = 0;
  int bIndex = 0;
  for (final step in stringListPath(aSource, bSource)) {
    switch (step.type) {
      case StepType.Equal:
        for (int i = step.count - 1; i >= 0; i--) {
          result.add(' ' + aSource[aIndex]);
          aIndex++;
          bIndex++;
        }
        break;
      case StepType.Added:
        for (int i = step.count - 1; i >= 0; i--) {
          result.add('+' + bSource[bIndex]);
          bIndex++;
        }
        break;
      case StepType.Removed:
        for (int i = step.count - 1; i >= 0; i--) {
          result.add('-' + aSource[aIndex]);
          aIndex++;
        }
        break;
    }
  }
  return result;
}

/// The Levenshtein/Hirschberg path builder used for diffing two comparable sources.
/// See https://en.wikipedia.org/wiki/Levenshtein_distance
/// And https://en.wikipedia.org/wiki/Hirschberg%27s_algorithm
class _Path {
  /// The source comparable to create the path for.
  final Comparable _baseComp;

  /// The score vector at the front of the score calculation.
  List<int> _scoreFront = [];

  /// The score vector at the back of the score calculation.
  List<int> _scoreBack = [];

  /// The score vector to store off a result vector to.
  List<int> _scoreOther = [];

  /// Creates a new path builder.
  _Path(
      final this._baseComp,
      ) {
    final len = this._baseComp.bLength + 1;
    this._scoreFront = List<int>.filled(len, 0, growable: false);
    this._scoreBack = List<int>.filled(len, 0, growable: false);
    this._scoreOther = List<int>.filled(len, 0, growable: false);
  }

  /// Swaps the front and back score vectors.
  void _swapScores() {
    final temp = this._scoreFront;
    this._scoreFront = this._scoreBack;
    this._scoreBack = temp;
  }

  /// Swaps the back and other score vectors.
  void _storeScore() {
    final temp = this._scoreBack;
    this._scoreBack = this._scoreOther;
    this._scoreOther = temp;
  }

  /// Gets the maximum value of the three given values.
  int _max(
      final int a,
      final int b,
      final int c,
      ) =>
      max(
        a,
        max(
          b,
          c,
        ),
      );

  /// Calculate the Needleman-Wunsch score.
  /// At the end of this calculation the score is in the back vector.
  void _calculateScore(
      final _Container comp,
      ) {
    final aLen = comp.aLength;
    final bLen = comp.bLength;
    this._scoreBack[0] = 0;
    for (int j = 1; j <= bLen; ++j) {
      this._scoreBack[j] = this._scoreBack[j - 1] + comp.addCost(j - 1);
    }
    for (int i = 1; i <= aLen; ++i) {
      this._scoreFront[0] = this._scoreBack[0] + comp.removeCost(i - 1);
      for (int j = 1; j <= bLen; ++j) {
        this._scoreFront[j] = this._max(this._scoreBack[j - 1] + comp.substitutionCost(i - 1, j - 1),
            this._scoreBack[j] + comp.removeCost(i - 1), this._scoreFront[j - 1] + comp.addCost(j - 1));
      }

      this._swapScores();
    }
  }

  /// Finds the pivot between the other score and the reverse of the back score.
  /// The pivot is the index of the maximum sum of each element in the two scores.
  int _findPivot(
      final int bLength,
      ) {
    int index = 0;
    int max = this._scoreOther[0] + this._scoreBack[bLength];
    for (int j = 1; j <= bLength; ++j) {
      final int value = this._scoreOther[j] + this._scoreBack[bLength - j];
      if (value > max) {
        max = value;
        index = j;
      }
    }
    return index;
  }

  /// Handles when at the edge of the A source subset in the given container.
  Iterable<Step> _aEdge(
      final _Container comp,
      ) sync* {
    final aLen = comp.aLength;
    final bLen = comp.bLength;
    if (aLen <= 0) {
      if (bLen > 0) {
        yield Step(
          StepType.Added,
          bLen,
        );
      }
      return;
    }
    int split = -1;
    for (int j = 0; j < bLen; j++) {
      if (comp.equals(0, j)) {
        split = j;
        break;
      }
    }
    if (split < 0) {
      yield const Step(StepType.Removed, 1);
      yield Step(StepType.Added, bLen);
    } else {
      if (split > 0) yield Step(StepType.Added, split);
      yield const Step(StepType.Equal, 1);
      if (split < bLen - 1) yield Step(StepType.Added, bLen - split - 1);
    }
  }

  /// Handles when at the edge of the B source subset in the given container.
  Iterable<Step> _bEdge(
      final _Container comp,
      ) sync* {
    final aLen = comp.aLength;
    final bLen = comp.bLength;
    if (bLen <= 0) {
      if (aLen > 0) {
        yield Step(StepType.Removed, aLen);
      }
      return;
    }
    int split = -1;
    for (int i = 0; i < aLen; i++) {
      if (comp.equals(i, 0)) {
        split = i;
        break;
      }
    }
    if (split < 0) {
      yield Step(StepType.Removed, aLen);
      yield const Step(StepType.Added, 1);
    } else {
      if (split > 0) {
        yield Step(StepType.Removed, split);
      }
      yield const Step(StepType.Equal, 1);
      if (split < aLen - 1) {
        yield Step(StepType.Removed, aLen - split - 1);
      }
    }
  }

  /// This performs the Hirschberg divide and conquer and returns the path.
  Iterable<Step> _breakupPath(
      final _Container comp,
      ) sync* {
    final aLen = comp.aLength;
    final bLen = comp.bLength;
    if (aLen <= 1) {
      yield* this._aEdge(comp);
      return;
    }
    if (bLen <= 1) {
      yield* this._bEdge(comp);
      return;
    }
    final aMid = aLen ~/ 2;
    this._calculateScore(comp.sub(0, aMid, 0, bLen));
    this._storeScore();
    this._calculateScore(comp.sub(aMid, aLen, 0, bLen, reverse: true));
    final bMid = this._findPivot(bLen);
    yield* this._breakupPath(comp.sub(0, aMid, 0, bMid));
    yield* this._breakupPath(comp.sub(aMid, aLen, bMid, bLen));
  }

  /// Iterates through the diff path for the comparer this path was setup for.
  /// This will combine and sort the steps to create runs where removed is before the added.
  Iterable<Step> iteratePath() sync* {
    int removedCount = 0;
    int addedCount = 0;
    int equalCount = 0;
    final cont = _Container.Full(this._baseComp);
    for (final step in this._breakupPath(cont)) {
      switch (step.type) {
        case StepType.Added:
          if (equalCount > 0) {
            yield Step(StepType.Equal, equalCount);
            equalCount = 0;
          }
          addedCount += step.count;
          break;

        case StepType.Removed:
          if (equalCount > 0) {
            yield Step(StepType.Equal, equalCount);
            equalCount = 0;
          }
          removedCount += step.count;
          break;

        case StepType.Equal:
          if (removedCount > 0) {
            yield Step(StepType.Removed, removedCount);
            removedCount = 0;
          }
          if (addedCount > 0) {
            yield Step(StepType.Added, addedCount);
            addedCount = 0;
          }
          equalCount += step.count;
          break;
      }
    }

    if (removedCount > 0) {
      yield Step(StepType.Removed, removedCount);
    }
    if (addedCount > 0) {
      yield Step(StepType.Added, addedCount);
    }
    if (equalCount > 0) {
      yield Step(StepType.Equal, equalCount);
    }
  }
}

/// A container for the comparable used to determine subset and
/// revered reading of the data in the comparable.
class _Container {
  final Comparable _comp;
  final int _aOffset;
  final int _aLength;
  final int _bOffset;
  final int _bLength;
  final bool _reverse;

  /// Creates a new comparable container with the given subset and reverse settings.
  const _Container(
      final this._comp,
      final this._aOffset,
      final this._aLength,
      final this._bOffset,
      final this._bLength,
      final this._reverse,
      );

  /// Creates a new comparable for a full container.
  factory _Container.Full(
      final Comparable comp,
      ) =>
      _Container(
        comp,
        0,
        comp.aLength,
        0,
        comp.bLength,
        false,
      );

  /// Creates a new comparable container for a subset and reverse relative to this container's settings.
  _Container sub(
      final int aLow,
      final int aHigh,
      final int bLow,
      final int bHigh, {
        final bool reverse = false,
      }) {
    final aOffset = this._aAdjust(this._reverse ? aHigh : aLow);
    final bOffset = this._bAdjust(this._reverse ? bHigh : bLow);
    return _Container(
      this._comp,
      aOffset,
      aHigh - aLow,
      bOffset,
      bHigh - bLow,
      this._reverse != reverse,
    );
  }

  /// The length of the first list being compared.
  int get aLength => this._aLength;

  /// The length of the section list being compared.
  int get bLength => this._bLength;

  /// Gets the A index adjusted by the container's condition.
  int _aAdjust(
      final int aIndex,
      ) =>
      (this._reverse) ? (this._aLength - 1 - aIndex + this._aOffset) : (aIndex + this._aOffset);

  /// Gets the B index adjusted by the container's condition.
  int _bAdjust(
      final int bIndex,
      ) =>
      (this._reverse) ? (this._bLength - 1 - bIndex + this._bOffset) : (bIndex + this._bOffset);

  /// Determines if the entries in the two given indices are equal.
  bool equals(
      final int aIndex,
      final int bIndex,
      ) =>
      this._comp.equals(this._aAdjust(aIndex), this._bAdjust(bIndex));

  /// Gives the cost to remove A at the given index.
  int removeCost(
      final int aIndex,
      ) =>
      this._comp.removeCost(this._aAdjust(aIndex));

  /// Gives the cost to add B at the given index.
  int addCost(
      final int bIndex,
      ) =>
      this._comp.addCost(this._bAdjust(bIndex));

  /// Gives the substitution cost for replacing A with B at the given indices.
  int substitutionCost(
      final int aIndex,
      final int bIndex,
      ) =>
      this._comp.substitionCost(this._aAdjust(aIndex), this._bAdjust(bIndex));

  /// Gets the debug string for this container.
  @override
  String toString() {
    String aValues = '', bValues = '';
    if (this._comp is _StringsComparable) {
      final cmp = this._comp as _StringsComparable;
      final aParts = <String>[];
      for (int i = 0; i < this._aLength; ++i) {
        aParts.add(cmp._aSource[this._aAdjust(i)]);
      }
      aValues = ' [${aParts.join("|")}]';
      final bParts = <String>[];
      for (int j = 0; j < this._bLength; ++j) {
        bParts.add(cmp._bSource[this._bAdjust(j)]);
      }
      bValues = ' [${bParts.join("|")}]';
    }

    return '([$_aOffset..${_aOffset + _aLength}) $_aLength$aValues' +
        ', [$_bOffset..${_bOffset + _bLength}) $_bLength$bValues' +
        ', $_reverse)';
  }
}

/// A simple interface for generic difference determination.
abstract class Comparable {
  /// The length of the first list being compared.
  int get aLength;

  /// The length of the second list being compared.
  int get bLength;

  /// Determines if the entries in the two given indices are equal.
  bool equals(
      final int aIndex,
      final int bIndex,
      );

  /// Gives the cost to remove A at the given index.
  /// By default this will always return -1.
  int removeCost(
      final int aIndex,
      ) =>
      -1;

  /// Gives the cost to add B at the given index.
  /// By default this will always return -1.
  int addCost(
      final int bIndex,
      ) =>
      -1;

  /// Gives the substition cost for replacing A with B at the given indices.
  /// By default this will always return 0 if equal, -2 if not equal.
  int substitionCost(
      final int aIndex,
      final int bIndex,
      ) {
    if (this.equals(aIndex, bIndex)) {
      return 0;
    } else {
      return -2;
    }
  }

  /// Gets a generic debug string for this comparable.
  @override
  String toString() => 'Comparable($aLength, $bLength)';
}

/// A string list comparable to find the difference between them.
class _StringsComparable extends Comparable {
  final List<String> _aSource;
  final List<String> _bSource;

  /// Creates a new diff comparable for the two given strings.
  _StringsComparable(
      final this._aSource,
      final this._bSource,
      );

  /// The length of the first list being compared.
  @override
  int get aLength => this._aSource.length;

  /// The length of the section list being compared.
  @override
  int get bLength => this._bSource.length;

  /// Determines if the entries in the two given indices are equal.
  @override
  bool equals(
      final int aIndex,
      final int bIndex,
      ) =>
      this._aSource[aIndex] == this._bSource[bIndex];

  /// Gets a generic debug string for this comparable.
  @override
  String toString() => '(${_aSource.join('|')}, ${_bSource.join('|')})';
}
// endregion

// region calculator
// Example calculator.
void main() {
  final calc = Calculator();
  print('Enter in an equation and press enter to calculate the result.');
  print('Type "exit" to exit. See documentation for more information.');
  for (;;) {
    stdout.write("> ");
    final input = stdin.readLineSync() ?? '';
    if (input.toLowerCase() == 'exit') {
      break;
    } else {
      calc.clear();
      calc.calculate(input);
      print(calc.stackToString);
    }
  }
}

// # Petite Parser Calculator
//
// The calculator uses the petite parser to create a simple mathematical language.
//
// - [Examples](#examples)
// - [Literals](#literals)
//   - [Implicit Conversions](#implicit-conversions)
// - [Constants](#constants)
// - [Functions](#functions)
//   - [Explicit Casts](#explicit-casts)
//   - [Formatting](#formatting)
//   - [Trigonometry](#trigonometry)
//   - [Logarithms](#logarithms)
//   - [Basic Math](#basic-math)
// - [Operators](#operators)
//   - [Unary Operators](#unary-operators)
//   - [Binary Operators](#binary-operators)
//   - [Comparing Operators](#comparing-operators)
//   - [Order of Operators](#order-of-operators)
//
// ## Examples
//
// | Input                          | Result                    |
// |--------------------------------|---------------------------|
// | `10 * 4 + 6`                   | `46`                      |
// | `10 * (-4 + 6)**2.0`           | `40.0`                    |
// | `cos(1.5*pi)`                  | `-1.8369701987210297e-16` |
// | `min(4, 8, 15, 16, 23, 42)`    | `4`                       |
// | `0x00FF & 0xAAAA`              | `170`                     |
// | `hex(0x00FF & 0xAAAA)`         | `0xAA`                    |
// | `int(string(12) + string(34))` | `1234`                    |
// | `x := 4; y := x + 2; x*y`      | `24`                      |
// | `1 + 1; 2 + 2; 3 + 3;`         | `2, 4, 6`                 |
// | `upper(sub("Hello", 1, 3))`    | `EL`                      |
//
// ## Literals
//
// - **Binary** numbers are made up of `0` and `1`'s followed by a `b`. For example `1011b`.
// - **Octal** numbers are made up of `0` to `7`'s followed by a `o`. For example `137o`.
// - **Decimal** numbers are made up of `0` to `9`'s, optionally followed by a `d`. For example `42`.
// - **Hexadecimal** numbers are made up of `0` to `9` and `a` to `f`'s preceded by a `0x`. For example `0x00FF`.
// - **Boolean** is either `true` and `false`.
// - **Real** numbers are decimals numbers with either a decimal point or exponent in it.
//   For example `0.01`, `12e-3`, and `1.1e2`.
// - **String** literals are quoted letters. It can have escaped characters for quotations (`\"`), newlines (`\n`), tabs (`\t`), ascii (`\x0A`) with two hex digits, and Unicode (`\u000A`) with four hex digits. For example `""`, `"abc"`, `"\n"`, and `"\x0A"`.
//
// ### Implicit Conversions
//
// - Booleans can be implicitly converted to and integer or real as 0 and 1.
// - Integers can be implicitly converted into reals.
//
// ## Constants
//
// These are the built-in constants. Additional constants may be added as needed.
//
// - `pi`: This is a real with the value for pi.
// - `e`: This is a real with the value for e.
// - `true`: This is a Boolean for true.
// - `false`: This is a Boolean for false.
//
// ## Functions
//
// These are the built-in functions. Additional functions may be added as needed.
//
// ### Explicit Casts
//
// - `bool`: Converts the value to Boolean, e.g `bool(1)`.
// - `int`: Converts the value to integer, e.g `int(123)`.
// - `real`: Converts the value to real, e.g `real(123)`.
// - `string`: Converts the value to string, e.g. `string(123)`.
//   If the value is an integer or real, the result is as decimal number string.
//
// ### Formatting
//
// - `bin`: Formats an integer as a binary number string.
// - `oct`: Formats an integer as an octal number string.
// - `hex`: Formats an integer as a hexadecimal number string.
// - `sub`: Gets the substring of a string given an integer start and stop, e.g. `sub("hello", 2, 4)`.
// - `upper`: Gets the upper case of a string.
// - `lower`: Gets the lower case of a string.
// - `len`: Returns the length of a string.
// - `padLeft`: Pads the string on the left side with an optional string
//           until the string's length is equal to a specified length,
//           e.g. `padLeft("hello", 3)` and `padLeft("hello", 3, "-")`.
//           If not specified, the string will be padded with spaces.
// - `padRight`: Pads the string on the right side with an optional string
//           until the string's length is equal to a specified length,
//           e.g. `padRight("hello", 3)` and `padRight("hello", 3, "-")`.
//           If not specified, the string will be padded with spaces.
// - `trim`: Trims all whitespace from the left and right of a string.
// - `trimLeft`: Trims all whitespace from the left of a string.
// - `trimRight`: Trims all whitespace from the right of a string.
//
// ### Trigonometry
//
// - `sin`: Works on one number to get the sine.
// - `cos`: Works on one number to get the cosine.
// - `tan`: Works on one number to get the tangent.
// - `acos`: Works on one number to get the arc cosine.
// - `asin`: Works on one number to get the arc sine.
// - `atan`: Works on one number to get the arc tangent.
// - `atan2`: Works on two numbers to get the arc tangent given `y` and `x` as `atan(y/x)`.
//
// ### Logarithms
//
// - `log`: Works on two numbers to get the log given `a` and `b` as `log(a)/log(b)`.
// - `log2`: Works on one number to get the log base 2.
// - `log10`: Works on one number to get the log base 10.
// - `ln`: Works on one number to get the natural log.
//
// ### Basic Math
//
// - `abs`: Works on one number to get the absolute value, e.g. `abs(5)`.
// - `ceil`: Works on one real to get the ceiling (rounded up) value. Returns integers unchanged.
// - `floor`: Works on one real to get the floor (rounded down) value. Returns integers unchanged.
// - `round`: Works on one real to round the value. Returns integers unchanged.
// - `sqrt`: Works on one number to get the square root.
// - `rand`: Takes no arguments and will return a random real number between 0 and 1.
// - `avg`: Works on one or more numbers to get the average of all the numbers.
//     If all the numbers are integers then the result will be an integer, e.g. `avg(4.5, 3.3, 12.0)`.
// - `max`: Works on one or more numbers to get the maximum of all the numbers.
//     If all the numbers are integers then the result will be an integer, e.g. `max(4.5, 3.3, 12.0)`.
// - `min`: Works on one or more numbers to get the minimum of all the numbers.
//     If all the numbers are integers then the result will be an integer, e.g. `max(4.5, 3.3, 12.0)`.
// - `sum`: Works on one or more numbers to get the summation of all the numbers.
//     If all the numbers are integers then the result will be an integer, e.g. `sum(4.5, 3.3, 12.0)`.
//
// ## Operators
//
// These are the operators to use for mathematics. Mathematical expressions can be separated by `;`,
// e.g. `5*2; 1+2`
// Parentheses, `(` and `)`, can be used to perform part of the equation first, e.g. `4 * (2 + 3)`.
//
// ### Unary Operators
//
// - `+`: As an unary it has no effect on a number because it simply visually asserts the sign, e.g. `+4`.
// - `-`: As an unary for a number it will negate the number, e.g. `-4`.
// - `~`: This gets bitwise NOT the value of an integer, e.g. `~10`.
// - `!`: This gets the NOT the a Boolean value.
//
// ### Binary Operators
//
// - `+`: This will add them together two numbers, e.g. `2+4`. If both numbers are integers then an integer is returned.
//     This can also be used between two strings to concatenate them, e.g. `"ab" + "cd"`.
//     If used between two Booleans it will OR them.
// - `-`: This will subtract the number right from the number left, e.g. `45-11`. If both numbers are integers then an integer
//     is returned. If used between two Booleans it will imply (`!a|b`) them.
// - `*`: This will multiplying two numbers together. If both numbers are integers then an integer is returned.
// - `**`: This gets the power of the left raised to the right. If both numbers are integers then an integer is returned.
// - `/`: This divides the left number from the right number. If both numbers are integers then a truncated integer is returned.
// - `&`: This performs a bitwise ANDing of two integers or two Booleans.
// - `|`: This performs a bitwise ORing of two integers or two Booleans.
// - `^`: This performs a bitwise XORing of two integers or two Booleans.
// - `:=`: This assigns a value to a variable, e.g. `x := 5; y := x + 2`.
//   When a variable is assigned it is removed from the stack so will not be outputted.
//
// ### Comparing Operators
//
// - `==`: This checks the equality of two values and returns a Boolean with the result.
//     The values are compared if they are the same kind or can be implicitly cast to the same kind, otherwise false is returned.
// - `!=`: This checks the inequality of two values and returns a Boolean with the result.
//     The values are compared if they are the same kind or can be implicitly cast to the same kind, otherwise true is returned.
// - `>`: This checks if the left number is greater than the right number.
// - `>=`: This checks if the left number is greater than or equal to the right number.
// - `<`: This checks if the left number is less than the right number.
// - `<=`: This checks if the left number is less than or equal to the right number.
//
// ### Order of Operators
//
// This is the order of operations so that `2 * 3 + 4` and `4 + 3 * 2` will be multiplied first
// then added resulting in `10` for both and not `14` unless parentheses are used, e.g. `2 * (3 + 4)`.
// These are in order of highest to lowest priority. When values have the same priority they will
// be executed right to left.
//
// - `:=`
// - `|`
// - `&`
// - `==`, `!=`, `<`, `<=`, `>`, `>=`
// - `+` (binary), `-` (binary)
// - `*`, `\`
// - `()`, `^`, `**`, `-` (unary), `+` (unary), `!`, `~`
/// This is the signature for functions which can be called by the calculator.
///
/// DO NOT implement functions which my give access to gain control over a website or application.
typedef CalcFunc = Object? Function(List<Object?> args);

/// An implementation of a simple calculator language.
///
/// This is useful for allowing a text field with higher mathematic control
/// without exposing exploits via a full language input.
///
/// This is also an example of how to use petite parser to construct
/// a simple interpreted language.
class Calculator {
  static Parser? _parser;

  /// Loads the parser used by the calculator.
  ///
  /// This is done in a static method since to load the language
  /// from a file it has to be done asynchronously.
  static void loadParser() => _parser ??= Parser.fromDefinition(language);

  final Map<String, TriggerHandle> _handles = {};
  final List<Object?> _stack = [];
  final Map<String, Object?> _consts = {};
  final Map<String, Object?> _vars = {};
  final _CalcFuncs _funcs = _CalcFuncs();

  // Creates a new calculator instance.
  Calculator() {
    _handles.addAll({
      'Add': this._handleAdd,
      'And': this._handleAnd,
      'Assign': this._handleAssign,
      'Binary': this._handleBinary,
      'Call': this._handleCall,
      'Decimal': this._handleDecimal,
      'Divide': this._handleDivide,
      'Equal': this._handleEqual,
      'GreaterEqual': this._handleGreaterEqual,
      'GreaterThan': this._handleGreaterThan,
      'Hexadecimal': this._handleHexadecimal,
      'Id': this._handleId,
      'Invert': this._handleInvert,
      'LessEqual': this._handleLessEqual,
      'LessThan': this._handleLessThan,
      'Multiply': this._handleMultiply,
      'Negate': this._handleNegate,
      'Not': this._handleNot,
      'NotEqual': this._handleNotEqual,
      'Octal': this._handleOctal,
      'Or': this._handleOr,
      'Power': this._handlePower,
      'PushVar': this._handlePushVar,
      'Real': this._handleReal,
      'StartCall': this._handleStartCall,
      'String': this._handleString,
      'Subtract': this._handleSubtract,
      'Xor': this._handleXor
    });
    this._consts.addAll({"pi": pi, "e": e, "true": true, "false": false});
  }

  /// This parses the given calculation input and
  /// returns the results so that the input can be run multiple
  /// times without having to reparse the program.
  Result? parse(String input) {
    if (input.isEmpty) return null;
    loadParser();

    try {
      return _parser?.parse(input);
    } on Object catch (err) {
      return Result(['Errors in calculator input:\n' + err.toString()], null);
    }
  }

  /// This uses the pre-parsed input to calculate the result.
  /// This is useful when wanting to rerun the same code multiple
  /// times without having to reparse the program.
  void calculateNode(
      final TreeNode? tree,
      ) {
    try {
      if (tree != null) tree.process(this._handles);
    } on Object catch (err) {
      this._stack.clear();
      this.push('Errors in calculator input:\n' + err.toString());
    }
  }

  /// This parses the given calculation input and
  /// puts the result on the top of the stack.
  void calculate(
      final String input,
      ) {
    final result = this.parse(input);
    if (result != null) {
      if (result.errors.isNotEmpty) {
        this._stack.clear();
        this.push('Errors in calculator input:\n  ' + result.errors.join('\n  '));
        return;
      }
      this.calculateNode(result.tree);
    }
  }

  /// Get a string showing all the values in the stack.
  String get stackToString {
    if (this._stack.isEmpty) {
      return 'no result';
    } else {
      final parts = <String>[];
      for (final val in this._stack) {
        parts.add('${val}');
      }
      return parts.join(', ');
    }
  }

  /// Adds a new function that can be called by the language.
  /// Set to null to remove a function.
  void addFunc(
      final String name,
      final CalcFunc hndl,
      ) =>
      this._funcs.addFunc(name, hndl);

  /// Adds a new constant value into the language.
  /// Set to null to remove the constant.
  void addConstant(
      final String name,
      final Object? value,
      ) {
    if (value == null) {
      _consts.remove(name);
    } else {
      _consts[name] = value;
    }
  }

  /// Sets the value of a variable.
  /// Set to null to remove the variable.
  void setVar(
      final String name,
      final Object? value,
      ) {
    if (value == null) {
      _vars.remove(name);
    } else {
      _vars[name] = value;
    }
  }

  /// Indicates if the stack is empty or not.
  bool get stackEmpty => this._stack.isEmpty;

  /// Clears all the values from the stack.
  void clear() => this._stack.clear();

  /// Removes the top value from the stack.
  Object? pop() => this._stack.removeLast();

  /// Pushes a value onto the stack.
  void push(
      final Object? value,
      ) =>
      this._stack.add(value);

  /// Handles calculating the sum of the top two items off of the stack.
  void _handleAdd(
      final TriggerArgs args,
      ) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt + right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal + right.asReal);
    } else if (left.implicitStr && right.implicitStr) {
      this.push(left.asStr + right.asStr);
    } else {
      throw Exception('Can not Add $left to $right.');
    }
  }

  /// Handles ANDing the top two items off the stack.
  void _handleAnd(
      final TriggerArgs args,
      ) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool && right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt & right.asInt);
    } else {
      throw Exception('Can not And $left with $right.');
    }
  }

  /// Handles assigning an variable to the top value off of the stack.
  void _handleAssign(
      final TriggerArgs args,
      ) {
    final right = this.pop();
    final left = Variant(this.pop());
    if (left.value is! String) {
      throw Exception('Can not Assign $right to $left.');
    } else {
      final text = left.asStr;
      if (this._consts.containsKey(text)) {
        throw Exception('Can not Assign $right to the constant $left.');
      }
      this._vars[text] = right;
    }
  }

  /// Handles adding a binary integer value from the input tokens.
  void _handleBinary(
      final TriggerArgs args,
      ) {
    String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    text = text.substring(0, text.length - 1); // remove 'b'
    this.push(int.parse(text, radix: 2));
  }

  /// Handles calling a function, taking it's parameters off the stack.
  void _handleCall(TriggerArgs args) {
    final methodArgs = <Object?>[];
    Object? val = this.pop();
    while (val is! CalcFunc) {
      methodArgs.insert(0, val);
      val = this.pop();
    }
    this.push(val.call(methodArgs));
  }

  /// Handles adding a decimal integer value from the input tokens.
  void _handleDecimal(
      final TriggerArgs args,
      ) {
    String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    if (text.endsWith('d')) text = text.substring(0, text.length - 1);
    this.push(int.parse(text, radix: 10));
  }

  /// Handles dividing the top two items on the stack.
  void _handleDivide(
      final TriggerArgs args,
      ) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt ~/ right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal / right.asReal);
    } else {
      throw Exception('Can not Divide $left with $right.');
    }
  }

  /// Handles checking if the two top items on the stack are equal.
  void _handleEqual(
      final TriggerArgs args,
      ) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool == right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt == right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal == right.asReal);
    } else if (left.implicitStr && right.implicitStr) {
      this.push(left.asStr == right.asStr);
    } else {
      this.push(false);
    }
  }

  /// Handles checking if the two top items on the stack are greater than or equal.
  void _handleGreaterEqual(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt >= right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal >= right.asReal);
    } else {
      throw Exception('Can not Greater Than or Equals $left and $right.');
    }
  }

  /// Handles checking if the two top items on the stack are greater than.
  void _handleGreaterThan(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt > right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal > right.asReal);
    } else {
      throw Exception('Can not Greater Than $left and $right.');
    }
  }

  /// Handles looking up a constant or variable value.
  void _handleId(TriggerArgs args) {
    final text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    if (this._consts.containsKey(text)) {
      this._stack.add(this._consts[text]);
      return;
    }
    if (this._vars.containsKey(text)) {
      this._stack.add(this._vars[text]);
      return;
    }
    throw Exception('No constant called $text found.');
  }

  /// Handles inverting the top value on the stack.
  void _handleInvert(TriggerArgs args) {
    final top = Variant(this.pop());
    if (top.isInt) {
      this.push(~top.asInt);
    } else {
      throw Exception('Can not Invert $top.');
    }
  }

  /// Handles checking if the two top items on the stack are less than or equal.
  void _handleLessEqual(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt <= right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal <= right.asReal);
    } else {
      throw Exception('Can not Less Than or Equals $left and $right.');
    }
  }

  /// Handles checking if the two top items on the stack are less than.
  void _handleLessThan(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt < right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal < right.asReal);
    } else {
      throw Exception('Can not Less Than $left and $right.');
    }
  }

  /// Handles adding a hexadecimal integer value from the input tokens.
  void _handleHexadecimal(TriggerArgs args) {
    String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    text = text.substring(2); // remove '0x'
    this.push(int.parse(text, radix: 16));
  }

  /// Handles calculating the multiplies of the top two items off of the stack.
  void _handleMultiply(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt * right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal * right.asReal);
    } else {
      throw Exception('Can not Multiply $left to $right.');
    }
  }

  /// Handles negating the an integer or real value.
  void _handleNegate(TriggerArgs args) {
    final top = Variant(this.pop());
    if (top.isInt) {
      this.push(-top.asInt);
    } else if (top.isReal) {
      this.push(-top.asReal);
    } else {
      throw Exception('Can not Negate $top.');
    }
  }

  /// Handles NOTing the Boolean values at the top of the the stack.
  void _handleNot(TriggerArgs args) {
    final top = Variant(this.pop());
    if (top.isBool) {
      this.push(!top.asBool);
    } else {
      throw Exception('Can not Not $top.');
    }
  }

  /// Handles checking if the two top items on the stack are not equal.
  void _handleNotEqual(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool != right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt != right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal != right.asReal);
    } else if (left.implicitStr && right.implicitStr) {
      this.push(left.asStr != right.asStr);
    } else {
      this.push(true);
    }
  }

  /// Handles adding a octal integer value from the input tokens.
  void _handleOctal(TriggerArgs args) {
    String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    text = text.substring(0, text.length - 1); // remove 'o'
    this.push(int.parse(text, radix: 8));
  }

  /// Handles ORing the Boolean values at the top of the the stack.
  void _handleOr(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool || right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt | right.asInt);
    } else {
      throw Exception('Can not Or $left to $right.');
    }
  }

  /// Handles calculating the power of the top two values on the stack.
  void _handlePower(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(pow(left.asInt, right.asInt).toInt());
    } else if (left.implicitReal && right.implicitReal) {
      this.push(pow(left.asReal, right.asReal));
    } else {
      throw Exception('Can not Power $left and $right.');
    }
  }

  /// Handles push an ID value from the input tokens
  /// which will be used later as a variable name.
  void _handlePushVar(TriggerArgs args) {
    final text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    this.push(text);
  }

  /// Handles adding a real value from the input tokens.
  void _handleReal(TriggerArgs args) {
    final text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    this.push(double.parse(text));
  }

  /// Handles starting a function call.
  void _handleStartCall(TriggerArgs args) {
    final text = args.recent(1)?.text.toLowerCase() ?? '';
    args.tokens.clear();
    final func = this._funcs.findFunc(text);
    if (func == null) throw Exception('No function called $text found.');
    this.push(func);
  }

  /// Handles adding a string value from the input tokens.
  void _handleString(TriggerArgs args) {
    final text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    this.push(Loader.unescapeString(text));
  }

  /// Handles calculating the difference of the top two items off of the stack.
  void _handleSubtract(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt - right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal - right.asReal);
    } else {
      throw Exception('Can not Subtract $left to $right.');
    }
  }

  /// Handles XORing the Boolean values at the top of the the stack.
  void _handleXor(TriggerArgs args) {
    final right = Variant(this.pop());
    final left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool ^ right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt ^ right.asInt);
    } else {
      throw Exception('Can not Multiply $left to $right.');
    }
  }
}

/// Variant is a wrapper of values off the stack with helper methods
/// for casting and testing the implicit casting of a value.
class Variant {
  /// This is the wrapped value.
  final Object? value;

  /// Wraps the given value into a new Variant.
  Variant(
      final this.value,
      );

  /// Gets the string for this value.
  @override
  String toString() => value.runtimeType.toString() + '(' + value.toString() + ')';

  /// TODO inline all these is checks and check a local value to make type promotion work.
  /// Indicates if this value is a Boolean value.
  bool get isBool => value is bool;

  /// Indicates if this value is an integer value.
  bool get isInt => value is int;

  /// Indicates if this value is a real value.
  bool get isReal => value is double;

  /// Indicates if the given value can be implicitly cast to a Boolean value.
  bool get implicitBool => isBool;

  /// Indicates if the given value can be implicitly cast to an integer value.
  bool get implicitInt => isBool || isInt;

  /// Indicates if the given value can be implicitly cast to a real value.
  bool get implicitReal => isBool || isInt || isReal;

  /// Indicates if the given value can be implicitly cast to a string value.
  bool get implicitStr => value is String;

  /// Casts this value to a Boolean.
  bool get asBool {
    final _val = value;
    if (_val is String) {
      final val = _val.toLowerCase();
      return (val.isNotEmpty) && (val != '0') && (val != 'false');
    }
    // ignore: cast_nullable_to_non_nullable
    if (isInt) return (value as int) != 0;
    // ignore: cast_nullable_to_non_nullable
    if (isReal) return (value as double) != 0;
    // ignore: cast_nullable_to_non_nullable
    if (isBool) return value as bool;
    throw Exception('May not cast ${value} to Boolean.');
  }

  /// Casts this value to an integer.
  int get asInt {
    // ignore: cast_nullable_to_non_nullable
    if (value is String) return int.parse(value as String);
    // ignore: cast_nullable_to_non_nullable
    if (isInt) return value as int;
    // ignore: cast_nullable_to_non_nullable
    if (isReal) return (value as double).toInt();
    // ignore: cast_nullable_to_non_nullable
    if (isBool) return (value as bool) ? 1 : 0;
    throw Exception('May not cast ${value} to int.');
  }

  /// Casts this value to a real.
  double get asReal {
    // ignore: cast_nullable_to_non_nullable
    if (value is String) return double.parse(value as String);
    // ignore: cast_nullable_to_non_nullable
    if (isInt) return (value as int).toDouble();
    // ignore: cast_nullable_to_non_nullable
    if (isReal) return value as double;
    // ignore: cast_nullable_to_non_nullable
    if (isBool) return (value as bool) ? 1.0 : 0.0;
    throw Exception('May not cast ${value} to real.');
  }

  /// Casts this value to a string.
  String get asStr {
    // ignore: cast_nullable_to_non_nullable
    if (value is String) return value as String;
    // ignore: cast_nullable_to_non_nullable
    if (isInt) return (value as int).toString();
    // ignore: cast_nullable_to_non_nullable
    if (isReal) return (value as double).toString();
    // ignore: cast_nullable_to_non_nullable
    if (isBool) return (value as bool).toString();
    throw Exception('May not cast ${value} to string.');
  }
}

const String language = '''

# Petite Parser Example
# Calculator Language Definition

> (Start);

(Start):    '0'      => (Int.Zero);
(Int.Zero): '0'..'1' => (Int.Bin);
(Int.Zero): '2'..'7' => (Int.Oct);
(Int.Zero): '8'..'7' => (Int.Dec);
(Int.Zero): 'x'      => (Int.Hex.Start);
(Int.Zero): '.'      => (Real.Start);
(Int.Zero): 'e'      => (Exp.Start);
(Int.Zero): 'b' => [Binary];
(Int.Zero): 'o' => [Octal];
(Int.Zero): 'd' => [Decimal];
(Int.Zero) => [Decimal];

(Start):   '1'      => (Int.Bin);
(Int.Bin): '0'..'1' => (Int.Bin);
(Int.Bin): '2'..'7' => (Int.Oct);
(Int.Bin): '8'..'9' => (Int.Dec);
(Int.Bin): '.' => (Real.Start);
(Int.Bin): 'e' => (Exp.Start);
(Int.Bin): 'b' => [Binary];
(Int.Bin): 'o' => [Octal];
(Int.Bin): 'd' => [Decimal];
(Int.Bin) => [Decimal];

(Start):   '2'..'7' => (Int.Oct);
(Int.Oct): '0'..'7' => (Int.Oct);
(Int.Oct): '8'..'9' => (Int.Dec);
(Int.Oct): '.' => (Real.Start);
(Int.Oct): 'e' => (Exp.Start);
(Int.Oct): 'o' => [Octal];
(Int.Oct): 'd' => [Decimal];
(Int.Oct) => [Decimal];

(Start):   '8'..'9' => (Int.Dec);
(Int.Dec): '0'..'9' => (Int.Dec);
(Int.Dec): '.' => (Real.Start);
(Int.Dec): 'e' => (Exp.Start);
(Int.Dec): 'd' => [Decimal];
(Int.Dec) => [Decimal];

(Int.Hex.Start): '0'..'9', 'a'..'f', 'A'..'F' => (Int.Hex);
(Int.Hex): '0'..'9', 'a'..'f', 'A'..'F' => (Int.Hex);
(Int.Hex) => [Hexadecimal];

(Real.Start): '0'..'9' => (Real);
(Real): '0'..'9' => (Real);
(Real): 'e' => (Exp.Start);
(Real) => [Real];

(Exp.Start): '0'..'9' => (Exp);
(Exp.Start): '-', '+' => (Exp.Sign);
(Exp.Sign):  '0'..'9' => (Exp);
(Exp):       '0'..'9' => (Exp);
(Exp) => [Real];

(Start): 'a'..'z', 'A'..'Z', '_' => (Id);
(Id):    'a'..'z', 'A'..'Z', '0'..'9', '_' => [Id];

(Start): '*' => [Mul];
(Mul):   '*' => [Power];
(Start): '/' => [Div];
(Start): '+' => [Pos];
(Start): '-' => [Negate];
(Start): '^' => [Xor];
(Start): '~' => [Invert];
(Start): '&' => [And];
(Start): '|' => [Or];
(Start): '!' => [Not];
(Not):   '=' => [NotEqual];
(Start):       '>' => [GreaterThan];
(GreaterThan): '=' => [GreaterEqual];
(Start):       '<' => [LessThan];
(LessThan):    '=' => [LessEqual];
(Start): '=' => (Equal.Start): '=' => [Equal];
(Start): '(' => [Open];
(Start): ')' => [Close];
(Start): ',' => [Comma];
(Start): ';' => [Separator];
(Start): ':' => (Colon): '=' => [Assign];
(Start): ' ' => (Whitespace): ' ' => ^[Whitespace];

(Start): ^'"' => (Str.Body);
(Str.Body): ^'"' => [String];
(Str.Body): '\\\\' => (Str.Escape);
(Str.Escape): '\\\\"nrt' => (Str.Body);
(Str.Escape): 'x' => (Str.Hex1): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Hex2): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Body);
(Str.Escape): 'u' => (Str.Uni1): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Uni2): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Uni3);
(Str.Uni3): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Uni4): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Body);
(Str.Body): * => (Str.Body);

> <Program>;

<Program> := <Blocks>
    | <Blocks> [Separator];

<Blocks> := <Block>
    | <Blocks> [Separator] <Block>;

<Block> := <Expression.Or>
    | [Id] {PushVar} [Assign] <Expression.Or> {Assign};

<Expression.Or> := <Expression.And>
    | <Expression.Or> [Or]  <Expression.And> {Or};

<Expression.And> := <Expression.Comp>
    | <Expression.And> [And] <Expression.Comp> {And};

<Expression.Comp> := <Expression>
    | <Expression.Comp> [NotEqual]     <Expression> {NotEqual}
    | <Expression.Comp> [GreaterThan]  <Expression> {GreaterThan}
    | <Expression.Comp> [GreaterEqual] <Expression> {GreaterEqual}
    | <Expression.Comp> [LessThan]     <Expression> {LessThan}
    | <Expression.Comp> [LessEqual]    <Expression> {LessEqual}
    | <Expression.Comp> [Equal]        <Expression> {Equal};

<Expression> := <Term>
    | <Expression> [Pos] <Term> {Add}
    | <Expression> [Negate] <Term> {Subtract};

<Term> := <Factor>
    | <Term> [Mul] <Factor> {Multiply}
    | <Term> [Div] <Factor> {Divide};

<Factor> := <Value>
    | [Open] <Expression.Or> [Close]
    | <Factor> [Xor] <Value> {Xor}
    | <Factor> [Power] <Value> {Power}
    | [Negate] <Value> {Negate}
    | [Not] <Value> {Not}
    | [Pos] <Value>
    | [Invert] <Value> {Invert}
    | [Id] {StartCall} [Open] <Args> [Close] {Call};

<Value> := [Id] {Id}
    | [Binary] {Binary}
    | [Octal] {Octal}
    | [Decimal] {Decimal}
    | [Hexadecimal] {Hexadecimal}
    | [Real] {Real}
    | [String] {String};

<Args> := _
    | <Expression.Or>
    | <Args> [Comma] <Expression.Or>;

''';

/// This is a collection of functions for the calculator.
class _CalcFuncs {
  final Map<String, CalcFunc> _funcs = {};
  final Random _rand = Random(0);

  /// Creates a new collection of calculator function.
  _CalcFuncs() {
    this._funcs.addAll({
      'abs': this._funcAbs,
      'acos': this._funcAcos,
      'asin': this._funcAsin,
      'atan': this._funcAtan,
      'atan2': this._funcAtan2,
      'avg': this._funcAvg,
      'bin': this._funcBin,
      'bool': this._funcBool,
      'ceil': this._funcCeil,
      'cos': this._funcCos,
      'floor': this._funcFloor,
      'hex': this._funcHex,
      'int': this._funcInt,
      'len': this._funcLen,
      'log': this._funcLog,
      'log2': this._funcLog2,
      'log10': this._funcLog10,
      'lower': this._funcLower,
      'ln': this._funcLn,
      'max': this._funcMax,
      'min': this._funcMin,
      'oct': this._funcOct,
      'padleft': this._funcPadLeft,
      'padright': this._funcPadRight,
      'rand': this._funcRand,
      'real': this._funcReal,
      'round': this._funcRound,
      'sin': this._funcSin,
      'sqrt': this._funcSqrt,
      'string': this._funcString,
      'sub': this._funcSub,
      'sum': this._funcSum,
      'tan': this._funcTan,
      'trim': this._funcTrim,
      'trimleft': this._funcTrimLeft,
      'trimright': this._funcTrimRight,
      'upper': this._funcUpper
    });
  }

  /// Adds a new function that can be called by the language.
  /// Set to null to remove a function.
  void addFunc(String name, CalcFunc? hndl) {
    if (hndl == null) {
      this._funcs.remove(name);
    } else {
      this._funcs[name] = hndl;
    }
  }

  /// Finds the function with the given name.
  CalcFunc? findFunc(String name) => this._funcs[name];

  /// This checks that the specified number of arguments has been given.
  void _argCount(String name, List<Object?> args, int count) {
    if (args.length != count) {
      throw Exception('The function $name requires $count arguments but got ${args.length}.');
    }
  }

  /// This function gets the absolute value of the given integer or real.
  Object _funcAbs(List<Object?> args) {
    this._argCount('abs', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.abs();
    if (arg.implicitReal) return arg.asReal.abs();
    throw Exception('Can not use $arg in either abs(int) or abs(real).');
  }

  /// This function gets the arccosine of the given real.
  Object _funcAcos(List<Object?> args) {
    this._argCount('acos', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return acos(arg.asReal);
    throw Exception('Can not use $arg in acos(real).');
  }

  /// This function gets the arcsine of the given real.
  Object _funcAsin(List<Object?> args) {
    this._argCount('asin', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return asin(arg.asReal);
    throw Exception('Can not use $arg in asin(real).');
  }

  /// This function gets the arctangent of the given real.
  Object _funcAtan(List<Object?> args) {
    this._argCount('atan', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return atan(arg.asReal);
    throw Exception('Can not use $arg in atan(real).');
  }

  /// This function gets the arctangent of the two given reals.
  Object _funcAtan2(List<Object?> args) {
    this._argCount('atan2', args, 2);
    final left = Variant(args[0]);
    final right = Variant(args[1]);
    if (left.implicitReal && right.implicitReal) return atan2(left.asReal, right.asReal);
    throw Exception('Can not use $left and $right in atan2(real, real).');
  }

  /// This function gets the average of one or more reals.
  Object _funcAvg(List<Object?> args) {
    if (args.isEmpty) throw Exception('The function avg requires at least one argument.');
    double sum = 0.0;
    for (final arg in args) {
      final value = Variant(arg);
      if (value.implicitReal) {
        sum += value.asReal;
      } else {
        throw Exception('Can not use $arg in avg(real, real, ...).');
      }
    }
    return sum / args.length;
  }

  /// This function gets the binary formatted integer as a string.
  Object _funcBin(List<Object?> args) {
    this._argCount('bin', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(2) + "b";
    throw Exception('Can not use $arg to bin(int).');
  }

  /// This function casts the given value into a Boolean value.
  Object _funcBool(List<Object?> args) {
    this._argCount('bool', args, 1);
    final arg = Variant(args[0]);
    return arg.asBool;
  }

  /// This function gets the ceiling of the given real.
  Object _funcCeil(List<Object?> args) {
    this._argCount('ceil', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.ceil();
    throw Exception('Can not use $arg to ceil(real) or already an int.');
  }

  /// This function gets the cosine of the given real.
  Object _funcCos(List<Object?> args) {
    this._argCount('cos', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return cos(arg.asReal);
    throw Exception('Can not use $arg in cos(real).');
  }

  /// This function gets the floor of the given real.
  Object _funcFloor(List<Object?> args) {
    this._argCount('floor', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.floor();
    throw Exception('Can not use $arg to floor(real) or already an int.');
  }

  /// This function gets the hexadecimal formatted integer as a string.
  Object _funcHex(List<Object?> args) {
    this._argCount('hex', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitInt) return "0x" + arg.asInt.toRadixString(16).toUpperCase();
    throw Exception('Can not use $arg to hex(int).');
  }

  /// This function casts the given value into an integer value.
  Object _funcInt(List<Object?> args) {
    this._argCount('int', args, 1);
    final arg = Variant(args[0]);
    return arg.asInt;
  }

  /// This function gets the length of a string.
  Object _funcLen(List<Object?> args) {
    this._argCount('len', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitStr) return arg.asStr.length;
    throw Exception('Can not use $arg to len(string).');
  }

  /// This function gets the log of the given real with the base of another real.
  Object _funcLog(List<Object?> args) {
    this._argCount('log', args, 2);
    final left = Variant(args[0]);
    final right = Variant(args[1]);
    if (left.implicitReal && right.implicitReal) return log(left.asReal) / log(right.asReal);
    throw Exception('Can not use $left and $right in log(real, real).');
  }

  /// This function gets the log base 2 of the given real.
  Object _funcLog2(List<Object?> args) {
    this._argCount('log2', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return log(arg.asReal) / ln2;
    throw Exception('Can not use $arg in log2(real).');
  }

  /// This function gets the log base 10 of the given real.
  Object _funcLog10(List<Object?> args) {
    this._argCount('log10', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return log(arg.asReal) / ln10;
    throw Exception('Can not use $arg in log10(real).');
  }

  /// This function gets the lower case of the given string.
  Object _funcLower(List<Object?> args) {
    this._argCount('lower', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitStr) return arg.asStr.toLowerCase();
    throw Exception('Can not use $arg in lower(string).');
  }

  /// This function gets the natural log of the given real.
  Object _funcLn(List<Object?> args) {
    this._argCount('ln', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return log(arg.asReal);
    throw Exception('Can not use $arg in ln(real).');
  }

  /// This function gets the maximum value of one or more integers or reals.
  Object _funcMax(List<Object?> args) {
    if (args.isEmpty) throw Exception('The function max requires at least one argument.');
    bool allInt = true;
    for (final arg in args) {
      final value = Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw Exception('Can not use $arg in max(real, real, ...) or max(int, int, ...).');
    }

    if (allInt) {
      int value = Variant(args[0]).asInt;
      for (final arg in args) {
        value = max(value, Variant(arg).asInt);
      }
      return value;
    } else {
      double value = Variant(args[0]).asReal;
      for (final arg in args) {
        value = max(value, Variant(arg).asReal);
      }
      return value;
    }
  }

  /// This function gets the minimum value of one or more integers or reals.
  Object _funcMin(List<Object?> args) {
    if (args.isEmpty) throw Exception('The function min requires at least one argument.');
    bool allInt = true;
    for (final arg in args) {
      final value = Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw Exception('Can not use $arg in min(real, real, ...) or min(int, int, ...).');
    }

    if (allInt) {
      int value = Variant(args[0]).asInt;
      for (final arg in args) {
        value = min(value, Variant(arg).asInt);
      }
      return value;
    } else {
      double value = Variant(args[0]).asReal;
      for (final arg in args) {
        value = min(value, Variant(arg).asReal);
      }
      return value;
    }
  }

  /// This function gets the octal formatted integer as a string.
  Object _funcOct(List<Object?> args) {
    this._argCount('oct', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(8) + "o";
    throw Exception('Can not use $arg to oct(int).');
  }

  /// This function pads the string on the left side with an optional character
  /// until the string's length is equal to a specified length.
  Object _funcPadLeft(List<Object?> args) {
    if (args.length < 2 || args.length > 3) {
      throw Exception('The function padLeft requires 2 or 3 arguments but got ${args.length}.');
    }
    final arg0 = Variant(args[0]);
    final arg1 = Variant(args[1]);
    final arg2 = Variant((args.length == 3) ? args[2] : " ");
    if (arg0.implicitStr && arg1.implicitInt && arg2.implicitStr) return arg0.asStr.padLeft(arg1.asInt, arg2.asStr);
    throw Exception('Can not use $arg0, $arg1, and $arg2 in padLeft(string, int, [string]).');
  }

  /// This function pads the string on the right side with an optional character
  /// until the string's length is equal to a specified length.
  Object _funcPadRight(List<Object?> args) {
    if (args.length < 2 || args.length > 3) {
      throw Exception('The function padRight requires 2 or 3 arguments but got ${args.length}.');
    }
    final arg0 = Variant(args[0]);
    final arg1 = Variant(args[1]);
    final arg2 = Variant((args.length == 3) ? args[2] : " ");
    if (arg0.implicitStr && arg1.implicitInt && arg2.implicitStr) return arg0.asStr.padRight(arg1.asInt, arg2.asStr);
    throw Exception('Can not use $arg0, $arg1, and $arg2 in padRight(string, int, [string]).');
  }

  /// This function puts a random number onto the stack.
  Object _funcRand(List<Object?> args) {
    this._argCount('rand', args, 0);
    return this._rand.nextDouble();
  }

  /// This function casts the given value into a real value.
  Object _funcReal(List<Object?> args) {
    this._argCount('real', args, 1);
    final arg = Variant(args[0]);
    return arg.asReal;
  }

  /// This function gets the round of the given real.
  Object _funcRound(List<Object?> args) {
    this._argCount('round', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.round();
    throw Exception('Can not use $arg in round(real).');
  }

  /// This function gets the sine of the given real.
  Object _funcSin(List<Object?> args) {
    this._argCount('sin', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return sin(arg.asReal);
    throw Exception('Can not use $arg in sin(real).');
  }

  /// This function gets the square root of the given real.
  Object _funcSqrt(List<Object?> args) {
    this._argCount('sqrt', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) return sqrt(arg.asReal);
    throw Exception('Can not use $arg in sqrt(real).');
  }

  /// This function casts the given value into a string value.
  Object _funcString(List<Object?> args) {
    this._argCount('string', args, 1);
    final arg = Variant(args[0]);
    return arg.asStr;
  }

  /// This function gets a substring for a given string with a start and stop integer.
  Object _funcSub(List<Object?> args) {
    this._argCount('sub', args, 3);
    final arg0 = Variant(args[0]);
    final arg1 = Variant(args[1]);
    final arg2 = Variant(args[2]);
    if (arg0.implicitStr && arg1.implicitInt && arg2.implicitInt) return arg0.asStr.substring(arg1.asInt, arg2.asInt);
    throw Exception('Can not use $arg0, $arg1, and $arg2 in sub(string, int, int).');
  }

  /// This function gets the sum of zero or more integers or reals.
  Object _funcSum(List<Object?> args) {
    bool allInt = true;
    for (final arg in args) {
      final value = Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw Exception('Can not use $arg in sum(real, real, ...) or sum(int, int, ...).');
    }
    if (allInt) {
      int value = 0;
      for (final arg in args) {
        value += Variant(arg).asInt;
      }
      return value;
    } else {
      double value = 0.0;
      for (final arg in args) {
        value += Variant(arg).asReal;
      }
      return value;
    }
  }

  /// This function gets the tangent of the given real.
  Object _funcTan(
      final List<Object?> args,
      ) {
    this._argCount('tan', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitReal) {
      return tan(arg.asReal);
    } else {
      throw Exception('Can not use $arg in tan(real).');
    }
  }

  /// This function trims the left and right of a string.
  Object _funcTrim(
      final List<Object?> args,
      ) {
    this._argCount('trim', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitStr) {
      return arg.asStr.trim();
    } else {
      throw Exception('Can not use $arg in trim(string).');
    }
  }

  /// This function trims the left of a string.
  Object _funcTrimLeft(
      final List<Object?> args,
      ) {
    this._argCount('trimLeft', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitStr) {
      return arg.asStr.trimLeft();
    } else {
      throw Exception('Can not use $arg in trimLeft(string).');
    }
  }

  /// This function trims the right of a string.
  Object _funcTrimRight(
      final List<Object?> args,
      ) {
    this._argCount('trimRight', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitStr) {
      return arg.asStr.trimRight();
    } else {
      throw Exception('Can not use $arg in trimRight(string).');
    }
  }

  /// This function gets the upper case of the given string.
  Object _funcUpper(
      final List<Object?> args,
      ) {
    this._argCount('upper', args, 1);
    final arg = Variant(args[0]);
    if (arg.implicitStr) {
      return arg.asStr.toUpperCase();
    } else {
      throw Exception('Can not use $arg in upper(string).');
    }
  }
}
// endregion
