import 'dart:async';
import 'dart:math';

// TODO remove this dependency, ...serialize.dart should be selfcontained.
import 'cachapa_crdt_serialize.dart';
import 'cachapa_hlc.dart';

// https://github.com/cachapa/crdt 4.0.2 @ 84b4b2880e889b40a2d0674d6eaca1d241fe3fa9

/// A CRDT backed by a in-memory map.
/// Useful for testing, or for applications which
/// only require temporary datasets.
class MapCrdt<K, V extends Object> extends CrdtBase<K, V> {
  final Map<K, Record<V>> _map = <K, Record<V>>{};
  final StreamController<MapEntry<K, V?>> _controller = StreamController<MapEntry<K, V?>>.broadcast();
  @override
  final String nodeId;

  MapCrdt(
    final this.nodeId, [
    final Map<K, Record<V>> seed = const {},
  ]) {
    _map.addAll(seed);
  }

  @override
  bool containsKey(
    final K key,
  ) =>
      _map.containsKey(key);

  @override
  Record<V>? getRecord(
    final K key,
  ) =>
      _map[key];

  @override
  void putRecord(
    final K key,
    final Record<V> value,
  ) {
    _map[key] = value;
    final _entry = MapEntry(key, value.value);
    _controller.add(_entry);
  }

  @override
  void putRecords(
    final Map<K, Record<V>> recordMap,
  ) {
    _map.addAll(recordMap);
    recordMap
        .map(
          (final key, final value) => MapEntry(key, value.value),
        )
        .entries
        .forEach(_controller.add);
  }

  @override
  Map<K, Record<V>> recordMap({
    final Hlc? modifiedSince,
  }) =>
      Map<K, Record<V>>.from(_map)
        ..removeWhere(
          (final _, final record) => record.modified.logicalTime < (modifiedSince?.logicalTime ?? 0),
        );

  @override
  Stream<MapEntry<K, V?>> watch({
    final K? key,
  }) =>
      _controller.stream.where(
        (final event) => key == null || key == event.key,
      );

  @override
  void purge() => _map.clear();
}

abstract class CrdtBase<K, V extends Object> implements Crdt<K, V> {
  late Hlc _canonicalTime;

  @override
  Hlc get canonicalTime => _canonicalTime;

  @override
  String get nodeId;

  @override
  bool get isEmpty => map.isEmpty;

  @override
  int get length => map.length;

  @override
  Map<K, V> get map {
    final map = recordMap();
    map.removeWhere(
      (final _, final record) => record.isDeleted,
    );
    return map.map(
      (final key, final record) => MapEntry(
        key,
        record.value!,
      ),
    );
  }

  CrdtBase() {
    _refreshCanonicalTime();
  }

  /// Iterates through the CRDT to find the highest
  /// HLC timestamp.
  /// Used to seed the Canonical Time.
  /// Should be overridden if the implementation
  /// can do it more efficiently.
  void _refreshCanonicalTime() {
    final map = recordMap();
    _canonicalTime = fromLogicalTimeHlc(
      () {
        if (map.isEmpty) {
          return 0;
        } else {
          return map.values.map((final record) => record.hlc.logicalTime).reduce(max);
        }
      }(),
      nodeId,
    );
  }

  @override
  V? get(
    final K key,
  ) =>
      getRecord(key)?.value;

  @override
  void put(
    final K key,
    final V? value,
  ) {
    _canonicalTime = sendHlc(_canonicalTime);
    final record = RecordImpl<V>(_canonicalTime, value, _canonicalTime);
    putRecord(key, record);
  }

  @override
  void putAll(
    final Map<K, V?> values,
  ) {
    // Avoid touching the canonical time if no data is inserted
    if (values.isNotEmpty) {
      _canonicalTime = sendHlc(_canonicalTime);
      final records = values.map<K, RecordImpl<V>>(
        (final key, final value) => MapEntry(
          key,
          RecordImpl(
            _canonicalTime,
            value,
            _canonicalTime,
          ),
        ),
      );
      putRecords(records);
    }
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
  bool? isDeleted(
    final K key,
  ) =>
      getRecord(key)?.isDeleted;

  @override
  void clear({
    final bool purge = false,
  }) {
    if (purge) {
      this.purge();
    } else {
      putAll(
        map.map(
          (final key, final _) => MapEntry(key, null),
        ),
      );
    }
  }

  @override
  void merge(
    final Map<K, Record<V>> remoteRecords,
  ) {
    final localRecords = recordMap();
    remoteRecords.removeWhere(
      (final key, final value) {
        _canonicalTime = receiveHlc(_canonicalTime, value.hlc);
        return localRecords[key] != null && localRecords[key]!.hlc >= value.hlc;
      },
    );
    final updatedRecords = remoteRecords.map(
      (final key, final value) => MapEntry(
        key,
        RecordImpl<V>(
          value.hlc,
          value.value,
          _canonicalTime,
        ),
      ),
    );
    // Store updated records.
    putRecords(updatedRecords);
    // Increment canonical time.
    _canonicalTime = sendHlc(_canonicalTime);
  }

  @override
  void mergeJson(
    final String json, {
    final K Function(String key)? keyDecoder,
    final V Function(String key, dynamic value)? valueDecoder,
  }) =>
      merge(
        crdtToJson<K, V>(
          json,
          _canonicalTime,
          keyDecoder: keyDecoder,
          valueDecoder: valueDecoder,
        ),
      );

  @override
  String toJson({
    final Hlc? modifiedSince,
    final String Function(K key)? keyEncoder,
    final dynamic Function(K key, V? value)? valueEncoder,
  }) =>
      crdtFromJson(
        recordMap(modifiedSince: modifiedSince),
        keyEncoder: keyEncoder,
        valueEncoder: valueEncoder,
      );

  @override
  String toString() => recordMap().toString();
}

class RecordImpl<V extends Object> implements Record<V> {
  @override
  final Hlc hlc;
  @override
  final V? value;
  @override
  final Hlc modified;

  const RecordImpl(
    final this.hlc,
    final this.value,
    final this.modified,
  );

  @override
  bool get isDeleted => value == null;

  @override
  // ignore: hash_and_equals
  bool operator ==(
    final Object other,
  ) =>
      other is Record<V> && hlc == other.hlc && value == other.value;

  @override
  String toString() => recordToJson(this, '').toString();
}

abstract class Crdt<K, V> {
  /// Represents the latest logical time seen in the stored data
  Hlc get canonicalTime;

  String get nodeId;

  /// Returns true if CRDT has any non-deleted records.
  bool get isEmpty;

  /// Get size of dataset excluding deleted records.
  int get length;

  /// Returns a simple key-value map without HLCs
  /// or deleted records.
  /// See [recordMap].
  Map<K, V> get map;

  V? get(
    final K key,
  );

  /// Inserts or updates a value in the CRDT and
  /// increments the canonical time.
  void put(
    final K key,
    final V? value,
  );

  /// Inserts or updates all values in the CRDT and
  /// increments the canonical time accordingly.
  void putAll(
    final Map<K, V?> values,
  );

  /// Marks the record as deleted.
  /// Note: this doesn't actually delete the record
  /// since the deletion needs to be propagated when
  /// merging with other CRDTs.
  void delete(
    final K key,
  );

  /// Checks if a record is marked as deleted
  /// Returns null if record does not exist
  bool? isDeleted(
    final K key,
  );

  /// Marks all records as deleted.
  /// Note: by default this doesn't actually delete
  /// the records since the deletion needs to be
  /// propagated when merging with other CRDTs.
  /// Set [purge] to true to clear the records. Useful
  /// for testing or to reset a store.
  void clear({
    final bool purge = false,
  });

  /// Merges two CRDTs and updates record and canonical clocks accordingly.
  /// See also [mergeJson()].
  void merge(
    final Map<K, Record<V>> remoteRecords,
  );

  /// Merges two CRDTs and updates record and
  /// canonical clocks accordingly.
  /// Use [keyDecoder] to convert non-string keys.
  /// Use [valueDecoder] to convert non-native value types.
  /// See also [merge()].
  void mergeJson(
    final String json, {
    final K Function(String key)? keyDecoder,
    final V Function(String key, dynamic value)? valueDecoder,
  });

  /// Outputs the contents of this CRDT in Json format.
  /// Use [modifiedSince] to encode only the most
  /// recently modified records.
  /// Use [keyEncoder] to convert non-string keys.
  /// Use [valueEncoder] to convert non-native value types.
  String toJson({
    final Hlc? modifiedSince,
    final String Function(K key)? keyEncoder,
    final dynamic Function(K key, V? value)? valueEncoder,
  });

  bool containsKey(
    final K key,
  );

  /// Gets record containing value and HLC.
  Record<V>? getRecord(
    final K key,
  );

  /// Stores record without updating the HLC.
  /// Meant for subclassing, clients should use
  /// [put()] instead.
  /// Make sure to call [refreshCanonicalTime()]
  /// if using this method directly.
  void putRecord(
    final K key,
    final Record<V> value,
  );

  /// Stores records without updating the HLC.
  /// Meant for subclassing, clients should use
  /// [putAll()] instead.
  /// Make sure to call [refreshCanonicalTime()]
  /// if using this method directly.
  void putRecords(
    final Map<K, Record<V>> recordMap,
  );

  /// Retrieves CRDT map including HLCs. Useful
  /// for merging with other CRDTs.
  /// Use [modifiedSince] to get only the most
  /// recently modified records.
  /// See also [toJson()].
  Map<K, Record<V>> recordMap({
    final Hlc? modifiedSince,
  });

  /// Watch for changes to this CRDT.
  /// Use [key] to monitor a specific key.
  Stream<MapEntry<K, V?>> watch({
    final K key,
  });

  /// Clear all records. Records will be removed
  /// rather than being marked as deleted.
  /// Useful for testing or to reset a store.
  /// See also [clear].
  void purge();
}

/// Stores a value associated with a given HLC.
abstract class Record<V> {
  Hlc get hlc;

  V? get value;

  Hlc get modified;

  bool get isDeleted;
}
