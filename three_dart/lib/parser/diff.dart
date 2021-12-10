import 'dart:math' as math;

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
      math.max(
        a,
        math.max(
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
  _Container(
    this._comp,
    this._aOffset,
    this._aLength,
    this._bOffset,
    this._bLength,
    this._reverse,
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
