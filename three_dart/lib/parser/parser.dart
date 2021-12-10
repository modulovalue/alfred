import 'dart:math' as math;

import 'grammar.dart' as __grammar;
import 'matcher.dart' as matcher;
import 'parse_tree.dart' as _parsetree;
import 'simple.dart' as simple;
import 'tokenizer.dart' as __tokenizer;

const String _startTerm = 'startTerm';
const String _eofTokenName = 'eofToken';

/// This is a parser for running tokens against a grammar to see
/// if the tokens are part of that grammar.
class Parser {
  _Table _table;
  __grammar.Grammar _grammar;
  __tokenizer.Tokenizer _tokenizer;

  static String getDebugStateString(__grammar.Grammar grammar) {
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
  factory Parser.fromGrammar(__grammar.Grammar grammar, __tokenizer.Tokenizer tokenizer) {
    final String errors = grammar.validate();
    if (errors.isNotEmpty) throw Exception('Error: Parser can not use invalid grammar:\n' + errors);

    grammar = grammar.copy();
    final _Builder builder = _Builder(grammar);
    builder.determineStates();
    builder.fillTable();
    final String errs = builder.buildErrors;
    if (errs.isNotEmpty) throw Exception('Errors while building parser:\n' + builder.toString(showTable: false));
    return Parser._(builder.table, grammar, tokenizer);
  }

  /// Creates a parser from the given JSON serialization.
  factory Parser.deserialize(simple.Deserializer data) {
    final int version = data.readInt();
    if (version != 1) {
      throw Exception('Unknown version, $version, for parser serialization.');
    }
    final __grammar.Grammar grammar = __grammar.Grammar.deserialize(data.readSer());
    final _Table table = _Table.deserialize(data.readSer(), grammar);
    final __tokenizer.Tokenizer tokenizer = __tokenizer.Tokenizer.deserialize(data.readSer());
    return Parser._(table, grammar, tokenizer);
  }

  /// Creates a parser from a parser definition file.
  factory Parser.fromDefinition(String input) => (Loader()..load(input)).parser;

  /// Creates a parser from a parser definition string.
  factory Parser.fromDefinitionChar(Iterator<int> input) => (Loader()..loadChars(input)).parser;

  /// Serializes the parser into a JSON serialization.
  simple.Serializer serialize() => simple.Serializer()
    ..writeInt(1) // Version 1
    ..writeSer(this._grammar.serialize())
    ..writeSer(this._table.serialize())
    ..writeSer(this._tokenizer.serialize());

  /// Gets the grammar for this parser.
  /// This should be treated as a constant, modifying it could cause the parser to fail.
  __grammar.Grammar get grammar => this._grammar;

  /// Gets the tokenizer for this parser.
  /// This should be treated as a constant, modifying it could cause the parser to fail.
  __tokenizer.Tokenizer get tokenizer => this._tokenizer;

  /// This parses the given string and returns the results.
  Result parse(String input) => this.parseTokens(this._tokenizer.tokenize(input));

  /// This parses the given characters and returns the results.
  Result parseChars(Iterator<int> iterator) => this.parseTokens(this._tokenizer.tokenizeChars(iterator));

  /// This parses the given tokens and returns the results.
  Result parseTokens(Iterable<__tokenizer.Token> tokens, [int errorCap = 0]) {
    final _Runner runner = _Runner(this._table, errorCap);
    for (final __tokenizer.Token token in tokens) {
      if (!runner.add(token)) return runner.result;
    }
    runner.add(__tokenizer.Token(_eofTokenName, _eofTokenName, -1));
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
  final __grammar.Rule rule;

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
  final __grammar.Grammar _grammar;
  final List<_State> _states = [];
  final Set<__grammar.Item> _items = {};
  final _Table _table = _Table();
  final StringBuffer _errors = StringBuffer();

  /// Constructs of a new parser builder.
  _Builder(this._grammar) {
    final __grammar.Term? oldStart = this._grammar.startTerm;
    this._grammar.start(_startTerm);
    this._grammar.newRule(_startTerm).addTerm(oldStart?.name ?? '').addToken(_eofTokenName);

    for (final __grammar.Term term in this._grammar.terms) {
      this._items.add(term);
      for (final __grammar.Rule rule in term.rules) {
        for (final __grammar.Item item in rule.items) {
          if (item is! __grammar.Trigger) this._items.add(item);
        }
      }
    }
  }

  /// Finds a state with the given offset index for the given rule.
  _State? find(int index, __grammar.Rule rule) {
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
    for (final __grammar.Rule rule in this._grammar.startTerm?.rules ?? []) {
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
      final __grammar.Rule rule = state.rules[i];
      final List<__grammar.Item> items = rule.basicItems;
      if (index < items.length) {
        final __grammar.Item item = items[index];

        if ((item is __grammar.TokenItem) && (item.name == _eofTokenName)) {
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
        final __grammar.Rule rule = state.rules[i];
        final int index = state.indices[i];
        final List<__grammar.Item> items = rule.basicItems;
        if (items.length <= index) {
          final List<__grammar.TokenItem> follows = rule.term?.determineFollows() ?? [];
          if (follows.isNotEmpty) {
            // Add the reduce action to all the follow items.
            final _Reduce reduce = _Reduce(rule);
            for (final __grammar.TokenItem follow in follows) {
              this._table.writeShift(state.number, follow.name, reduce);
            }
          }
        }
      }

      for (int i = 0; i < state.gotos.length; i++) {
        final __grammar.Item onItem = state.onItems[i];
        final int goto = state.gotos[i].number;
        if (onItem is __grammar.Term) {
          this._table.writeGoto(state.number, onItem.name, _Goto(goto));
        } else {
          this._table.writeShift(state.number, onItem.name, _Shift(goto));
        }
      }
    }

    // Check for goto loops.
    for (final __grammar.Term term in this._grammar.terms) {
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
  static __tokenizer.Tokenizer getTokenizer() {
    final __tokenizer.Tokenizer tok = __tokenizer.Tokenizer();
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
    final matcher.Group hexMatcher = matcher.Group()
      ..addRange('0', '9')
      ..addRange('A', 'F')
      ..addRange('a', 'f');
    final matcher.Group idLetter = matcher.Group()
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
  static __grammar.Grammar getGrammar() {
    final __grammar.Grammar gram = __grammar.Grammar();
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
    gram.newRule("stateID").addToken("openParen").addToken("id").addToken("closeParen").addTrigger("new.state");
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
    gram.newRule("triggerID").addToken("openCurly").addToken("id").addToken("closeCurly").addTrigger("new.trigger");

    gram.newRule("matcher.start").addToken("any").addTrigger("match.any");
    gram.newRule("matcher.start").addTerm("matcher");
    gram.newRule("matcher.start").addToken("consume").addTerm("matcher").addTrigger("match.consume");

    gram.newRule("matcher").addTerm("charSetRange");
    gram.newRule("matcher").addTerm("matcher").addToken("comma").addTerm("charSetRange");

    gram.newRule("charSetRange").addToken("string").addTrigger("match.set");
    gram.newRule("charSetRange").addToken("not").addToken("string").addTrigger("match.set.not");
    gram.newRule("charSetRange").addToken("string").addToken("range").addToken("string").addTrigger("match.range");
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
  static Parser getParser() => Parser.fromGrammar(Loader.getGrammar(), Loader.getTokenizer());

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
          final String hex = value.substring(stop + 2, stop + 4);
          final int charCode = int.parse(hex, radix: 16);
          buf.writeCharCode(charCode);
          stop += 2;
          break;
        case 'u':
          final String hex = value.substring(stop + 2, stop + 6);
          final int charCode = int.parse(hex, radix: 16);
          buf.writeCharCode(charCode);
          stop += 4;
          break;
      }
      start = stop + 2;
    }
    return buf.toString();
  }

  final Map<String, _parsetree.TriggerHandle> _handles = {};
  final __grammar.Grammar _grammar = __grammar.Grammar();
  final __tokenizer.Tokenizer _tokenizer = __tokenizer.Tokenizer();

  final List<__tokenizer.State> _states = [];
  final List<__tokenizer.TokenState> _tokenStates = [];
  final List<__grammar.Term> _terms = [];
  final List<__grammar.TokenItem> _tokenItems = [];
  final List<__grammar.Trigger> _triggers = [];
  final List<matcher.Group> _curTransGroups = [];
  bool _curTransConsume = false;
  final List<String> _replaceText = [];
  __grammar.Rule? _curRule;

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
  __grammar.Grammar get grammar => this._grammar;

  /// Gets the tokenizer which is being loaded.
  __tokenizer.Tokenizer get tokenizer => this._tokenizer;

  /// Creates a parser with the loaded tokenizer and grammar.
  Parser get parser => Parser.fromGrammar(this._grammar, this._tokenizer);

  /// A trigger handle for starting a new definition block.
  void _newDef(_parsetree.TriggerArgs args) {
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
  void _startState(_parsetree.TriggerArgs args) => this._tokenizer.start(this._states.last.name);

  /// A trigger handle for joining two states with the defined matcher.
  void _joinState(_parsetree.TriggerArgs args) {
    final __tokenizer.State start = this._states[this._states.length - 2];
    final __tokenizer.State end = this._states.last;
    final __tokenizer.Transition trans = start.join(end.name);
    trans.matchers.addAll(this._curTransGroups[0].matchers);
    trans.consume = this._curTransConsume;
    this._curTransGroups.clear();
    this._curTransConsume = false;
  }

  /// A trigger handle for joining a state to a token with the defined matcher.
  void _joinToken(_parsetree.TriggerArgs args) {
    final __tokenizer.State start = this._states.last;
    final __tokenizer.TokenState end = this._tokenStates.last;
    final __tokenizer.Transition trans = start.join(end.name);
    trans.matchers.addAll(this._curTransGroups[0].matchers);
    trans.consume = this._curTransConsume;
    this._tokenizer.state(end.name).setToken(end.name);
    this._curTransGroups.clear();
    this._curTransConsume = false;
  }

  /// A trigger handle for assigning a token to a state.
  void _assignToken(_parsetree.TriggerArgs args) {
    final __tokenizer.State start = this._states.last;
    final __tokenizer.TokenState end = this._tokenStates.last;
    start.setToken(end.name);
  }

  /// A trigger handle for adding a new state to the tokenizer.
  void _newState(_parsetree.TriggerArgs args) {
    final String name = args.recent(2)?.text ?? '';
    final __tokenizer.State state = this._tokenizer.state(name);
    this._states.add(state);
  }

  /// A trigger handle for adding a new token to the tokenizer.
  void _newTokenState(_parsetree.TriggerArgs args) {
    final String name = args.recent(2)?.text ?? '';
    final __tokenizer.TokenState token = this._tokenizer.token(name);
    this._tokenStates.add(token);
  }

  /// A trigger handle for adding a new token to the tokenizer
  /// and setting it to consume that token.
  void _newTokenConsume(_parsetree.TriggerArgs args) {
    final String name = args.recent(2)?.text ?? '';
    final __tokenizer.TokenState token = this._tokenizer.token(name);
    token.consume();
    this._tokenStates.add(token);
  }

  /// A trigger handle for adding a new term to the grammar.
  void _newTerm(_parsetree.TriggerArgs args) {
    final String name = args.recent(2)?.text ?? '';
    final __grammar.Term term = this._grammar.term(name);
    this._terms.add(term);
  }

  /// A trigger handle for adding a new token to the grammar.
  void _newTokenItem(_parsetree.TriggerArgs args) {
    final String name = args.recent(2)?.text ?? '';
    final __grammar.TokenItem token = this._grammar.token(name);
    this._tokenItems.add(token);
  }

  /// A trigger handle for adding a new trigger to the grammar.
  void _newTrigger(_parsetree.TriggerArgs args) {
    final String name = args.recent(2)?.text ?? '';
    final __grammar.Trigger trigger = this._grammar.trigger(name);
    this._triggers.add(trigger);
  }

  /// A trigger handle for setting the currently building matcher to match any.
  void _matchAny(_parsetree.TriggerArgs args) {
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(matcher.Group());
    this._curTransGroups.last.addAll();
  }

  /// A trigger handle for setting the currently building matcher to be consumed.
  void _matchConsume(_parsetree.TriggerArgs args) => this._curTransConsume = true;

  /// A trigger handle for setting the currently building matcher to match to a character set.
  void _matchSet(_parsetree.TriggerArgs args) {
    final __tokenizer.Token? token = args.recent(1);
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(matcher.Group());
    this._curTransGroups.last.addSet(unescapeString(token?.text ?? ''));
  }

  /// A trigger handle for setting the currently building matcher to not match to a character set.
  void _matchSetNot(_parsetree.TriggerArgs args) {
    this._notGroupStart(args);
    this._matchSet(args);
    this._notGroupEnd(args);
  }

  /// A trigger handle for setting the currently building matcher to match to a character range.
  void _matchRange(_parsetree.TriggerArgs args) {
    final __tokenizer.Token? lowChar = args.recent(3);
    final __tokenizer.Token? highChar = args.recent(1);
    final String lowText = unescapeString(lowChar?.text ?? '');
    final String highText = unescapeString(highChar?.text ?? '');
    if (lowText.length != 1) {
      throw Exception('May only have one character for the low char of a range. $lowChar does not.');
    }
    if (highText.length != 1) {
      throw Exception('May only have one character for the high char of a range. $highChar does not.');
    }
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(matcher.Group());
    this._curTransGroups.last.addRange(lowText, highText);
  }

  /// A trigger handle for setting the currently building matcher to not match to a character range.
  void _matchRangeNot(_parsetree.TriggerArgs args) {
    this._notGroupStart(args);
    this._matchRange(args);
    this._notGroupEnd(args);
  }

  /// A trigger handle for starting a not group of matchers.
  void _notGroupStart(_parsetree.TriggerArgs args) {
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(matcher.Group());
    this._curTransGroups.add(this._curTransGroups.last.addNot());
  }

  /// A trigger handle for ending a not group of matchers.
  void _notGroupEnd(_parsetree.TriggerArgs args) => this._curTransGroups.removeLast();

  /// A trigger handle for adding a new replacement string to the loader.
  void _addReplaceText(_parsetree.TriggerArgs args) =>
      this._replaceText.add(unescapeString(args.recent(1)?.text ?? ''));

  /// A trigger handle for setting a set of replacements between two
  /// tokens with a previously set replacement string set.
  void _replaceToken(_parsetree.TriggerArgs args) {
    final __tokenizer.TokenState start = this._tokenStates[this._tokenStates.length - 2];
    final __tokenizer.TokenState end = this._tokenStates.last;
    start.replace(end.name, this._replaceText);
    this._replaceText.clear();
  }

  /// A trigger handle for starting a grammar definition of a term.
  void _startTerm(_parsetree.TriggerArgs args) => this._grammar.start(this._terms.last.name);

  /// A trigger handle for starting defining a rule for the current term.
  void _startRule(_parsetree.TriggerArgs args) => this._curRule = this._terms.last.newRule();

  /// A trigger handle for adding a token to the current rule being built.
  void _itemToken(_parsetree.TriggerArgs args) => this._curRule?.addToken(this._tokenItems.removeLast().name);

  /// A trigger handle for adding a term to the current rule being built.
  void _itemTerm(_parsetree.TriggerArgs args) => this._curRule?.addTerm(this._terms.removeLast().name);

  /// A trigger handle for adding a trigger to the current rule being built.
  void _itemTrigger(_parsetree.TriggerArgs args) => this._curRule?.addTrigger(this._triggers.removeLast().name);
}

/// This is the result from a parse of a stream of tokens.
class Result {
  /// Any errors which occurred during the parse.
  final List<String> errors;

  /// The tree of the parsed tokens into grammar rules.
  /// This will be null if there are any errors.
  final _parsetree.TreeNode? tree;

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
  final List<_parsetree.TreeNode> _itemStack = [];
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
  bool _nullAction(int curState, __tokenizer.Token token, String indent) {
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
  bool _shiftAction(_Shift action, __tokenizer.Token token, String indent) {
    if (this._verbose) print('${indent}shift ${action.state} on $token');
    this._itemStack.add(_parsetree.TokenNode(token));
    this._stateStack.add(action.state);
    return true;
  }

  /// Handles when a reduce action has been reached.
  bool _reduceAction(_Reduce action, __tokenizer.Token token, String indent) {
    // Pop the items off the stack for this action.
    // Also check that the items match the expected rule.
    final int count = action.rule.items.length;
    final List<_parsetree.TreeNode> items = [];
    for (int i = count - 1; i >= 0; i--) {
      final __grammar.Item ruleItem = action.rule.items[i];
      if (ruleItem is __grammar.Trigger) {
        items.insert(0, _parsetree.TriggerNode(ruleItem.name));
      } else {
        this._stateStack.removeLast();
        final _parsetree.TreeNode item = this._itemStack.removeLast();
        items.insert(0, item);

        if (ruleItem is __grammar.Term) {
          if (item is _parsetree.RuleNode) {
            if (ruleItem.name != item.rule.term?.name) {
              throw Exception('The action, $action, could not reduce item $i, $item: the term names did not match.');
            }
          } else {
            throw Exception('The action, $action, could not reduce item $i, $item: the item is not a rule node.');
          }
        } else {
          // if (ruleItem is Grammar.TokenItem) {
          if (item is _parsetree.TokenNode) {
            if (ruleItem.name != item.token.name) {
              throw Exception('The action, $action, could not reduce item $i, $item: the token names did not match.');
            }
          } else {
            throw Exception('The action, $action, could not reduce item $i, $item: the item is not a token node.');
          }
        }
      }
    }

    // Create a new item with the items for this rule in it
    // and put it onto the stack.
    final _parsetree.RuleNode node = _parsetree.RuleNode(action.rule, items);
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
  bool add(__tokenizer.Token token) {
    if (this._accepted) {
      this._errors.add('unexpected token after end: $token');
      return false;
    }
    return this._addToken(token, '');
  }

  /// Inserts the next look ahead token into the parser.
  /// This is the internal method for `add` which can be called recursively.
  bool _addToken(__tokenizer.Token token, String indent) {
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
    final int max = math.max(this._itemStack.length, this._stateStack.length);
    for (int i = 0; i < max; ++i) {
      if (i != 0) buf.write(', ');
      bool hasState = false;
      if (i < this._stateStack.length) {
        buf.write('${this._stateStack[i]}');
        hasState = true;
      }
      if (i < this._itemStack.length) {
        if (hasState) buf.write(':');
        final _parsetree.TreeNode item = this._itemStack[i];
        if (item is _parsetree.RuleNode) {
          buf.write('<${item.rule.term?.name ?? ''}>');
        } else if (item is _parsetree.TokenNode) {
          buf.write('[${item.token.name}]');
        } else if (item is _parsetree.TriggerNode) {
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
  final List<__grammar.Rule> _rules = [];
  final List<__grammar.Item> _onItems = [];
  final List<_State> _gotos = [];
  bool _accept = false;

  /// This is the index of the state in the builder.
  final int number;

  /// Creates a new state for the parser builder.
  _State(this.number);

  /// The indices which indicated the offset into the matching rule.
  List<int> get indices => this._indices;

  /// The rules for this state which match up with the indices.
  List<__grammar.Rule> get rules => this._rules;

  /// This is the items which connect two states together.
  /// This matches with the goto values to create a connection.
  List<__grammar.Item> get onItems => this._onItems;

  /// This is the goto which indicates which state to go to for the matched items.
  /// This matches with the `onItems` to create a connection.
  List<_State> get gotos => this._gotos;

  /// Indicates if this state can acceptance for this grammar.
  bool get hasAccept => this._accept;

  /// Sets this state as an accept state for the grammar.
  void setAccept() => this._accept = true;

  /// Checks if the given index and rule exist in this state.
  bool hasRule(int index, __grammar.Rule rule) {
    for (int i = this._indices.length - 1; i >= 0; i--) {
      if ((this._indices[i] == index) && (this._rules[i] == rule)) return true;
    }
    return false;
  }

  /// Adds the given index and rule to this state.
  /// Returns false if it already exists, true if added.
  bool addRule(int index, __grammar.Rule rule) {
    if (this.hasRule(index, rule)) return false;
    this._indices.add(index);
    this._rules.add(rule);

    final List<__grammar.Item> items = rule.basicItems;
    if (index < items.length) {
      final __grammar.Item item = items[index];
      if (item is __grammar.Term) {
        for (final __grammar.Rule rule in item.rules) {
          this.addRule(0, rule);
        }
      }
    }
    return true;
  }

  /// Finds the go to state from the given item,
  /// null is returned if none is found.
  _State? findGoto(__grammar.Item item) {
    for (int i = this._onItems.length - 1; i >= 0; i--) {
      if (this._onItems[i] == item) return this._gotos[i];
    }
    return null;
  }

  /// Adds a goto connection on the given item to the given state.
  bool addGoto(__grammar.Item item, _State state) {
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
  factory _Table.deserialize(simple.Deserializer data, __grammar.Grammar grammar) {
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
  _Action? _deserializeAction(simple.Deserializer data, __grammar.Grammar grammar) {
    switch (data.readInt()) {
      case 1:
        return _Shift(data.readInt());
      case 2:
        return _Goto(data.readInt());
      case 3:
        final __grammar.Term term = grammar.term(data.readStr());
        final __grammar.Rule rule = term.rules[data.readInt()];
        return _Reduce(rule);
      case 4:
        return _Accept();
      case 5:
        return _Error(data.readStr());
    }
    return null;
  }

  /// Serializes the table.
  simple.Serializer serialize() {
    final simple.Serializer data = simple.Serializer();
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
  void _serializeAction(simple.Serializer data, _Action? action) {
    if (action is _Shift) {
      data.writeInt(1);
      data.writeInt(action.state);
    } else if (action is _Goto) {
      data.writeInt(2);
      data.writeInt(action.state);
    } else if (action is _Reduce) {
      data.writeInt(3);
      final __grammar.Term? term = action.rule.term;
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
    final int maxRowCount = math.max(this._shiftTable.length, this._gotoTable.length);
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
        maxWidth = math.max(maxWidth, grid[i][j].length);
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
