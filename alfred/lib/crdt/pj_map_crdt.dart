import 'dart:collection';

// TODO remove this.
import 'package:collection/collection.dart';

import 'pj_vector_clock.dart';

abstract class _MapCrdtBase<K, V> implements MapCrdt<K, V> {
  final Map<K, Record<V>> _records;

  _MapCrdtBase(this._records);

  _MapCrdtBase.from(
    _MapCrdtBase<K, V> other, {
    K Function(K)? cloneKey,
    V Function(V)? cloneValue,
  }) : _records = Map<K, Record<V>>.from(other._records).map((key, value) => MapEntry(
              cloneKey != null ? cloneKey(key) : key,
              Record<V>.from(value, cloneValue: cloneValue),
            ));

  @override
  Map<K, Record<V>> get records => _records;

  @override
  Map<K, V> get map => (Map<K, Record<V>>.from(_records)..removeWhere((key, value) => value.isDeleted))
      .map((key, value) => MapEntry(key, value.value!));

  @override
  Iterable<V> get values =>
      (List<Record<V>>.from(_records.values)..removeWhere((record) => record.isDeleted)).map((record) => record.value!);

  @override
  Record<V>? getRecord(K key) => _records[key];

  @override
  V? get(K key) => getRecord(key)?.value;

  @override
  void updateRecords(Record<V> Function(K, Record<V>) updateRecord) {
    _records.updateAll((key, record) => updateRecord(key, record));
  }

  @override
  void updateRecord(K key, Record<V> Function(Record<V>) updateRecord) {
    _records.update(key, updateRecord);
  }

  @override
  void updateValues(V Function(K, V) updateValue) {
    _records.updateAll(
        (k, record) => record.isDeleted ? record : Record(clock: record.clock, value: updateValue(k, record.value!)));
  }

  @override
  void updateValue(K key, V Function(V) updateRecord) {
    _records.update(
      key,
      (record) => record.isDeleted ? record : Record(clock: record.clock, value: updateRecord(record.value!)),
    );
  }

  @override
  Map<String, dynamic> recordsToJson({
    final String Function(K)? keyEncode,
    final dynamic Function(V)? valueEncode,
  }) =>
      _records.map<String, dynamic>(
        (final key, final value) => MapEntry<String, dynamic>(
          keyEncode != null ? keyEncode(key) : key as String,
          value.toJson(valueEncode: valueEncode),
        ),
      );

  static Map<K, Record<V>> recordsFromJson<K, V>(
    final Map<dynamic, dynamic> json, {
    final K Function(dynamic)? keyDecode,
    final V Function(dynamic)? valueDecode,
  }) =>
      json.map<K, Record<V>>(
        (final dynamic key, final dynamic value) => MapEntry(
          keyDecode != null ? keyDecode(key) : key as K,
          Record<V>.fromJson(
            value as Map<String, dynamic>,
            valueDecode: valueDecode,
          ),
        ),
      );

  /// Merge records with other records and updates [vectorClock].
  /// Assumes all records have been updated to contain nodes this and [other].
  /// Important: Records of [other] will be changed. Use MapCrdt.from(other, cloneKey: ..., cloneValue: ...) to keep them intact.
  void _mergeRecords(
    final MapCrdt<K, V> other,
    final VectorClock vectorClock,
    final MapCrdtRoot<dynamic, dynamic> root,
  ) {
    final updatedRecords = other.records
      ..removeWhere(
        (final key, final record) {
          final localRecord = _records[key];
          if (localRecord == null) {
            return false;
          }
          final value = record.value;
          final localValue = localRecord.value;
          if (localValue is MapCrdt && value.runtimeType == localValue.runtimeType) {
            localValue.merge((value as MapCrdt?)!);
            return true;
          } else if (localValue == null && value is MapCrdt) {
            return _forEveryRecordRecursive(
              value,
              (final record) => localRecord.clock >= record.clock,
            );
          } else {
            return localRecord.clock >= record.clock;
          }
        },
      )
      ..map(
        (final key, final value) => MapEntry(
          key,
          _updateNodeParentIfNecessary(value, root),
        ),
      );
    _records.addAll(updatedRecords);
  }

  Record<V> _updateNodeParentIfNecessary(
    final Record<V> record,
    final MapCrdtRoot<dynamic, dynamic> root,
  ) {
    if (record.isDeleted) return record;
    final value = record.value;
    if (value is MapCrdtNode) value._root = root;

    return record;
  }

  bool _forEveryRecordRecursive(
    final MapCrdt<dynamic, dynamic> crdt,
    final bool Function(Record<dynamic>) test,
  ) {
    return crdt.records.values.every((record) {
      if (!test(record)) return false;
      final dynamic value = record.value;
      if (value is _MapCrdtBase) {
        if (!value._forEveryRecordRecursive(value, test)) {
          return false;
        }
      }

      return true;
    });
  }

  void _validateRecord(
    final Record<dynamic> record,
    final MapCrdtRoot<dynamic, dynamic> root,
  ) {
    if (!containsNode(record.clock.node)) {
      throw ArgumentError(
        'node list doesn\'t contain the node of the record',
      );
    } else if (record.clock.vectorClock.numNodes != vectorClock.numNodes) {
      throw ArgumentError(
        'record vector clock does not have the same number of nodes as this crdt',
      );
    } else if (!record.isDeleted) {
      final dynamic subRecord = record.value!;
      if (subRecord is MapCrdt<dynamic, dynamic>) {
        if (subRecord.root != root) {
          throw ArgumentError('a node has an invalid root node');
        }
        subRecord.records.values.forEach(
          (final record) => subRecord.validateRecord(record),
        );
      }
    }
  }

  @override
  void insertClockValue(
    final int pos, [
    final int initialClockValue = 0,
  ]) {
    _records.values.forEach((record) {
      record.clock.vectorClock.insertClockValue(pos, initialClockValue);
      final value = record.value;
      if (value is MapCrdt) value.insertClockValue(pos, initialClockValue);
    });
  }
}

class MapCrdtRoot<K, V> extends _MapCrdtBase<K, V> {
  final List<String> _nodes;
  final VectorClock _vectorClock;
  late String _node;
  late int _nodeClockIndex;

  MapCrdtRoot(
    final this._node, {
    final Set<String>? nodes,
    final VectorClock? vectorClock,
    final Map<K, Record<V>>? records,
    final bool validateRecords = true,
  })  : _nodes = (() {
          if (nodes != null) {
            return List<String>.from(nodes);
          } else {
            return [_node];
          }
        }()),
        _vectorClock = (() {
          if (vectorClock == null) {
            return VectorClock(nodes == null ? 1 : nodes.length);
          } else {
            return VectorClock.from(vectorClock);
          }
        }()),
        super(records ?? {}) {
    if (_vectorClock.numNodes != _nodes.length) {
      throw ArgumentError('vector clock has invalid number of nodes');
    } else {
      _nodes.sort();
      _updateNodeClockIndex();
      if (validateRecords) _validateRecords(_records);
    }
  }

  /// Create a copy of [other].
  ///
  /// Use [cloneKey] to provide a function to clone the key.
  /// Use [cloneValue] to provide a function to clone the value.
  ///
  /// To clone deep clone values that require the parent CRDT (e.g. MapCrdtNode),
  /// don't provide [cloneValue] and call [updateValues] or [updateRecords] later.
  MapCrdtRoot.from(
    final MapCrdtRoot<K, V> other, {
    final K Function(K)? cloneKey,
    final V Function(V)? cloneValue,
  })  : _node = other._node,
        _nodes = List.from(other._nodes),
        _vectorClock = VectorClock.from(other._vectorClock),
        _nodeClockIndex = other._nodeClockIndex,
        super.from(other, cloneKey: cloneKey, cloneValue: cloneValue);

  @override
  MapCrdtRoot<K, V> get root => this;

  @override
  List<String> get nodes => UnmodifiableListView(_nodes);

  @override
  bool containsNode(
    final String node,
  ) =>
      binarySearch(_nodes, node) != -1;

  @override
  String get node => _node;

  @override
  VectorClock get vectorClock => _vectorClock;

  @override
  int get vectorClockIndex => _nodeClockIndex;

  @override
  void putRecord(
    K key,
    Record<V> record, {
    bool validateRecord = true,
  }) {
    if (validateRecord) this.validateRecord(record);
    _records[key] = record;
  }

  @override
  void validateRecord(
    final Record<dynamic> record,
  ) =>
      _validateRecord(
        record,
        this,
      );

  @override
  void put(
    final K key,
    final V? value,
  ) {
    putRecord(key, _makeRecord(value), validateRecord: false);
  }

  @override
  void putAll(
    final Map<K, V?> values,
  ) {
    final clock = _makeDistributedClock();
    values.forEach((key, value) {
      _records[key] = Record(clock: clock, value: value);
    });
  }

  @override
  void delete(
    final K key,
  ) =>
      put(
        key,
        null,
      );

  @override
  void addNode(
    final String node,
  ) {
    final insertPos = lowerBound(_nodes, node);
    if (insertPos < _nodes.length && _nodes[insertPos] == node) {
      return;
    } else {
      _nodes.insert(insertPos, node);
      _vectorClock.insertClockValue(insertPos);
      insertClockValue(insertPos);
      _updateNodeClockIndex();
    }
  }

  @override
  void mergeNodes(
    final MapCrdt<dynamic, dynamic> other,
  ) {
    other.nodes.forEach((node) => addNode(node));
    nodes.forEach((node) => other.addNode(node));
  }

  @override
  void merge(
    final MapCrdt<K, V> other,
  ) {
    mergeNodes(other);
    _vectorClock.merge(other.vectorClock);
    _mergeRecords(other, _vectorClock, this);
    _vectorClock.increment(_nodeClockIndex);
  }

  /// Changes the internal node name
  ///
  /// The old node name will still be kept in the list of nodes.
  void changeNode(String node) {
    addNode(node);
    _node = node;
    _updateNodeClockIndex();
  }

  bool canContainChangesFor(MapCrdtRoot<dynamic, dynamic> other) {
    final tmp = MapCrdtRoot<String, dynamic>(
      node,
      nodes: nodes.toSet(),
      vectorClock: vectorClock,
    );
    other.nodes.forEach(tmp.addNode);
    if (!const ListEquality<dynamic>().equals(other.nodes, tmp.nodes)) return true;
    final clockCmp = tmp.vectorClock.partialCompareTo(other.vectorClock);

    return clockCmp == null || clockCmp > 0;
  }

  void _validateRecords<S>(Map<S, Record<dynamic>> records) => _records.values.forEach(validateRecord);

  Record<S> _makeRecord<S>(S? value) {
    return Record(
      clock: _makeDistributedClock(),
      value: value,
    );
  }

  DistributedClock _makeDistributedClock() => DistributedClock.now(
        _vectorClock..increment(_nodeClockIndex),
        _node,
      );

  void _updateNodeClockIndex() {
    _nodeClockIndex = binarySearch(_nodes, _node);
    if (!containsNode(node)) {
      throw ArgumentError('could not find own node in list of nodes');
    }
  }

  Map<String, dynamic> toJson({
    String Function(K)? keyEncode,
    dynamic Function(V)? valueEncode,
  }) {
    return <String, dynamic>{
      'node': _node,
      'nodes': _nodes,
      'vectorClock': List<int>.from(_vectorClock.value),
      'records': recordsToJson(keyEncode: keyEncode, valueEncode: valueEncode),
    };
  }

  factory MapCrdtRoot.fromJson(
    Map<String, dynamic> json, {
    K Function(dynamic)? keyDecode,
    V Function(dynamic)? valueDecode,
    V Function(MapCrdtRoot<K, V>, dynamic)? lateValueDecode,
  }) {
    final crdt = MapCrdtRoot(
      json['node'] as String,
      nodes: (json['nodes'] as List).map((dynamic e) => e as String).toSet(),
      vectorClock: VectorClock.fromList(
        (json['vectorClock'] as List).map((dynamic e) => e as int).toList(),
      ),
      records: lateValueDecode == null
          ? _MapCrdtBase.recordsFromJson(
              json['records'] as Map<dynamic, dynamic>,
              keyDecode: keyDecode,
              valueDecode: valueDecode,
            )
          : null,
    );
    if (lateValueDecode != null) {
      _MapCrdtBase.recordsFromJson(
        json['records'] as Map<dynamic, dynamic>,
        keyDecode: keyDecode,
        valueDecode: (final dynamic v) => lateValueDecode(crdt, v),
      ).forEach(
        (final key, final value) => crdt.putRecord(
          key,
          value,
          validateRecord: false,
        ),
      );
    }

    return crdt;
  }
}

class MapCrdtNode<K, V> extends _MapCrdtBase<K, V> {
  MapCrdtRoot<dynamic, dynamic> _root;

  MapCrdtNode(
    this._root, {
    Map<K, Record<V>>? records,
    bool validateRecord = true,
  }) : super(records ?? {}) {
    if (validateRecord) _root._validateRecords(_records);
  }

  /// Warning: Doesn't clone the parent. Specify [parent] to use a new parent.
  MapCrdtNode.from(
    MapCrdtNode<K, V> other, {
    MapCrdtRoot<dynamic, MapCrdtNode<K, V>>? parent,
    K Function(K)? cloneKey,
    V Function(V)? cloneValue,
  })  : _root = parent ?? other._root,
        super.from(other, cloneKey: cloneKey, cloneValue: cloneValue);

  @override
  MapCrdtRoot<dynamic, dynamic> get root => _root;

  @override
  List<String> get nodes => _root.nodes;

  @override
  bool containsNode(String node) => _root.containsNode(node);

  @override
  String get node => _root.node;

  @override
  VectorClock get vectorClock => _root.vectorClock;

  @override
  int get vectorClockIndex => _root.vectorClockIndex;

  @override
  void merge(MapCrdt<K, V> other, {bool mergeParentNodes = true}) {
    if (mergeParentNodes) _root.mergeNodes(other);
    _mergeRecords(other, _root.vectorClock, root);
  }

  @override
  void putRecord(K key, Record<V> record, {bool validateRecord = true}) {
    if (validateRecord) this.validateRecord(record);
    _records[key] = record;
  }

  @override
  void validateRecord(Record<dynamic> record) {
    _validateRecord(record, root);
  }

  @override
  void put(K key, V? value) {
    putRecord(key, _root._makeRecord(value), validateRecord: false);
  }

  @override
  void putAll(Map<K, V?> values) {
    final clock = _root._makeDistributedClock();
    values.forEach((key, value) {
      _records[key] = Record(clock: clock, value: value);
    });
  }

  @override
  void delete(K key) => put(key, null);

  @override
  void addNode(String node) => _root.addNode(node);

  @override
  void mergeNodes(MapCrdt<dynamic, dynamic> other) => _root.mergeNodes(other);

  @override
  String toString() {
    return 'CrdtNode$records';
  }

  Map<String, dynamic> toJson({
    String Function(K)? keyEncode,
    dynamic Function(V)? valueEncode,
  }) =>
      recordsToJson(keyEncode: keyEncode, valueEncode: valueEncode);

  factory MapCrdtNode.fromJson(
    Map<String, dynamic> json, {
    required MapCrdtRoot<dynamic, MapCrdtNode<K, V>> parent,
    K Function(dynamic)? keyDecode,
    V Function(dynamic)? valueDecode,
    bool validateRecords = true,
  }) {
    return MapCrdtNode(
      parent,
      records: _MapCrdtBase.recordsFromJson(
        json,
        keyDecode: keyDecode,
        valueDecode: valueDecode,
      ),
      validateRecord: validateRecords,
    );
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(
    final Object other,
  ) {
    if (other is MapCrdtNode<K, V>) {
      return other._root == _root && const MapEquality<dynamic, dynamic>().equals(other._records, _records);
    } else {
      return false;
    }
  }
}

class Record<T> {
  DistributedClock clock;
  T? value;

  Record({
    required final this.clock,
    final this.value,
  });

  Record.from(Record<T> other, {T Function(T)? cloneValue})
      : clock = DistributedClock.from(other.clock),
        value = other.value == null ? null : (cloneValue != null ? cloneValue(other.value!) : other.value);

  bool get isDeleted => value == null;

  Map<String, dynamic> toJson({
    final dynamic Function(T)? valueEncode,
  }) {
    return <String, dynamic>{
      'clock': clock.toJson(),
      'value': () {
        if (value == null) {
          return null;
        } else {
          if (valueEncode != null) {
            return valueEncode(value!);
          } else {
            return value;
          }
        }
      }(),
    };
  }

  factory Record.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? valueDecode,
  }) {
    final dynamic jsonValue = () {
      if (json.containsKey('value')) {
        return json['value'];
      } else {
        return null;
      }
    }();
    return Record(
      clock: DistributedClock.fromJson(json['clock'] as Map<String, dynamic>),
      value: () {
        if (jsonValue == null) {
          return null;
        } else {
          if (valueDecode != null) {
            return valueDecode(jsonValue);
          } else {
            return jsonValue as T;
          }
        }
      }(),
    );
  }

  @override
  int get hashCode => const ListEquality<dynamic>().hash(
        <dynamic>[
          clock.hashCode,
          value?.hashCode,
        ],
      );

  @override
  bool operator ==(
    final Object other,
  ) {
    if (other is Record<T>) {
      return other.clock == clock && other.value == value;
    } else {
      return false;
    }
  }

  @override
  String toString() => '$value@$clock';
}

abstract class MapCrdt<K, V> {
  /// Get the root node of this crdt if it is part of a tree.
  /// Returns this if the node itself is the root.
  MapCrdt<dynamic, dynamic> get root;

  /// Get all recods
  Map<K, Record<V>> get records;

  /// Get all not deleted entries
  Map<K, V> get map;

  /// Get all not deleted values
  Iterable<V> get values;

  /// Get the record for [key]
  Record<V>? getRecord(K key);

  /// Get the entry for [key]
  V? get(K key);

  /// Get the list of nodes that this crdt knows
  List<String> get nodes;

  /// True if this crdt knows of node [node]
  bool containsNode(String node);

  /// The name of this node
  String get node;

  /// The current vector clock of this node
  VectorClock get vectorClock;

  /// Get the vector clock index of this crdt
  int get vectorClockIndex;

  /// Update all records using the [updateRecord] function
  ///
  /// This function can be used to deep clone MapCrdt with MapCrdtNode values.
  void updateRecords(Record<V> Function(K, Record<V>) updateRecord);

  /// Update a single record if it exists
  void updateRecord(K key, Record<V> Function(Record<V>) updateRecord);

  /// Update all values that are not deleted
  void updateValues(V Function(K, V) updateValue);

  /// Update a single value if it exists and is not deleted
  void updateValue(K key, V Function(V) updateRecord);

  /// Add or replace a record
  void putRecord(K key, Record<V> record, {bool validateRecord = true});

  /// Validate if [record] seems to be compatible with this crdt map.
  /// Throws an ArgumentError if it is not compatible.
  void validateRecord(Record<dynamic> record);

  /// Add or replace an entry for [key].
  /// If [value] is null, the record for [key] will be marked as deleted.
  void put(K key, V? value);

  /// Put all entries with the same clock value
  void putAll(Map<K, V?> values);

  // Mark the entry for [key] as deleted.
  void delete(K key);

  /// Add a node to the list of known nodes
  ///
  /// The node is added to the current internal vector clock and all vector clocks of existing records
  void addNode(String node);

  /// Add all nodes from [other] to this and all nodes of this to [other]
  void mergeNodes(MapCrdt<dynamic, dynamic> other);

  /// Merge all records of [other] into this
  ///
  /// Important: Records and nodes of [other] will be changed.
  /// Use the from(other, cloneKey: ..., cloneValue: ...) constructor to clone it before using this function if [other] is used after.
  void merge(MapCrdt<K, V> other);

  /// Insert a node into the internal vector clock.
  /// THIS METHOD IS ONLY INTENDED FOR INTERNAL USAGE.
  ///
  /// Using this method can irreversibly destroy the structure of internal vector clocks.
  ///
  /// Internal method used to recursively update the vector clock when new nodes are added and the correct insertion index is already known.
  void insertClockValue(int pos, [int initialClockValue = 0]);

  /// Encode all records to a JSON map
  ///
  /// Use [keyEncode] to specify custom key encoding.
  /// Use [valueEncode] to specify custom value encoding.
  Map<String, dynamic> recordsToJson({
    String Function(K)? keyEncode,
    dynamic Function(V)? valueEncode,
  });
}
