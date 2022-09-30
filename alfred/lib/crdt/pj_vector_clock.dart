import 'dart:math' show max;

import 'package:collection/collection.dart' show ListEquality, UnmodifiableListView;

class DistributedClock implements Comparable<DistributedClock> {
  final VectorClock _vector_clock;
  final int _timestamp;
  final String _node;

  DistributedClock(
    final VectorClock clock,
    final this._timestamp,
    final this._node,
  ) : _vector_clock = VectorClock.from(clock);

  DistributedClock.from(
    final DistributedClock other,
  ) : this(
          VectorClock.from(other._vector_clock),
          other._timestamp,
          other._node,
        );

  DistributedClock.now(
    final VectorClock clock,
    final String node,
  ) : this(
          clock,
          DateTime.now().millisecondsSinceEpoch,
          node,
        );

  VectorClock get vectorClock => _vector_clock;

  int get timestamp => _timestamp;

  String get node => _node;

  @override
  String toString() => '$_vector_clock:$_timestamp:$_node';

  // TODO inline hash
  @override
  int get hashCode => const ListEquality<dynamic>().hash(
        <dynamic>[
          _vector_clock,
          _timestamp,
          _node,
        ],
      );

  @override
  bool operator ==(
    final Object other,
  ) {
    if (!(other is DistributedClock)) {
      return false;
    } else {
      return other._vector_clock == _vector_clock && other._timestamp == _timestamp && other._node == _node;
    }
  }

  @override
  int compareTo(
    final DistributedClock other,
  ) {
    final vectorClockCmp = _vector_clock.partialCompareTo(other._vector_clock);
    if (vectorClockCmp != null && vectorClockCmp != 0) {
      return vectorClockCmp;
    }
    final timestampCmp = _timestamp.compareTo(other._timestamp);
    if (timestampCmp != 0) {
      return timestampCmp;
    } else {
      return _node.compareTo(other._node);
    }
  }

  bool operator <(
    final DistributedClock other,
  ) =>
      compareTo(other) < 0;

  bool operator <=(
    final DistributedClock other,
  ) {
    final cmp = compareTo(other);
    return cmp == 0 || cmp == -1;
  }

  bool operator >(
    final DistributedClock other,
  ) =>
      compareTo(other) > 0;

  bool operator >=(
    final DistributedClock other,
  ) {
    final cmp = compareTo(other);
    return cmp == 0 || cmp == 1;
  }

  factory DistributedClock.fromJson(
    final Map<String, dynamic> json,
  ) {
    return DistributedClock(
      VectorClock.fromList(
        (json['clock'] as List).map((dynamic e) => e as int).toList(),
      ),
      json['timestamp'] as int,
      json['node'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clock': List<int>.from(_vector_clock.value),
        'timestamp': _timestamp,
        'node': _node,
      };
}

// TODO https://ferd.ca/interval-tree-clocks.html
class VectorClock {
  final List<int> _value;

  VectorClock(
    final int num_nodes,
  ) : _value = List.filled(
          num_nodes,
          0,
          growable: true,
        );

  VectorClock.fromList(
    final List<int> value,
  ) : _value = List.from(value);

  VectorClock.from(
    final VectorClock other,
  ) : this.fromList(other._value);

  int get num_nodes => _value.length;

  UnmodifiableListView<int> get value => UnmodifiableListView(_value);

  void increment(
    final int index,
  ) {
    if (index < 0 || index >= _value.length) {
      throw RangeError.range(
        index,
        0,
        _value.length - 1,
      );
    } else {
      _value[index]++;
    }
  }

  void insertClockValue(
    final int index, [
    final int value = 0,
  ]) {
    if (index < 0 || index > _value.length) {
      throw RangeError.range(
        index,
        0,
        _value.length,
      );
    } else {
      _value.insert(index, value);
    }
  }

  void merge(
    final VectorClock other,
  ) {
    if (num_nodes != other.num_nodes) {
      throw ArgumentError.value(
        other,
        'Cannot merge clock with different numbers of nodes (this != other): $num_nodes != ${other.num_nodes}',
      );
    }
    for (var i = 0; i < _value.length; i++) {
      _value[i] = max(_value[i], other._value[i]);
    }
  }

  /// like compareTo but returns null if the vector clocks are not comparable
  int? partialCompareTo(
    final VectorClock other,
  ) {
    if (other.num_nodes != num_nodes) {
      return null;
    } else {
      var vectorCmp = 0;
      for (var i = 0; i < _value.length; i++) {
        final nodeCmp = _value[i].compareTo(other._value[i]);
        if (vectorCmp == 0) {
          vectorCmp = nodeCmp;
        } else if (nodeCmp != 0 && vectorCmp != nodeCmp) {
          return null;
        }
      }
      return vectorCmp;
    }
  }

  @override
  String toString() => '[${_value.join(', ')}]';

  @override
  int get hashCode => const ListEquality<dynamic>().hash(_value);

  @override
  bool operator ==(
    final Object other,
  ) {
    if (other is VectorClock) {
      return const ListEquality<int>().equals(other._value, _value);
    } else {
      return false;
    }
  }
}
