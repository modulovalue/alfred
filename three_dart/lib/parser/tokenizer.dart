import 'matcher.dart';
import 'simple.dart';

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
