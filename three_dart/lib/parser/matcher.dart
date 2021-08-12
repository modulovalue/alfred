/// A matcher which matches a set of characters.
class Set implements Matcher {
  List<int> _set = [];

  /// Creates a set matcher for all the characters in the given string.
  /// The set must contain at least one character.
  factory Set(String charSet) {
    return Set.fromCodeUnits(charSet.codeUnits);
  }

  /// Creates a set matcher with a given list of code units.
  /// The set must contain at least one character.
  Set.fromCodeUnits(Iterable<int> charSet) {
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
  Set addSet(String charSet) => this.add(Set(charSet)) as Set;

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
