import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'cachapa_hlc.dart';

// https://github.com/cachapa/crdt 4.0.2 @ 84b4b2880e889b40a2d0674d6eaca1d241fe3fa9

// region ds
/// A CRDT backed by a in-memory map.
/// Useful for testing, or for applications which
/// only require temporary datasets.
class MapCrdt<K, V extends Object> extends CrdtBase<K, V> {
  final Map<K, Record<V>> _map = <K, Record<V>>{};
  final StreamController<MapEntry<K, V?>> _controller = StreamController<MapEntry<K, V?>>.broadcast();
  @override
  final String node_id;

  MapCrdt(
    final this.node_id, [
    final Map<K, Record<V>> seed = const {},
  ]) {
    _map.addAll(seed);
  }

  @override
  bool contains_key(
    final K key,
  ) =>
      _map.containsKey(key);

  @override
  Record<V>? get_record(
    final K key,
  ) =>
      _map[key];

  @override
  void put_record(
    final K key,
    final Record<V> value,
  ) {
    _map[key] = value;
    final _entry = MapEntry(key, value.value);
    _controller.add(_entry);
  }

  @override
  void put_records(
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
  Map<K, Record<V>> record_map({
    final Hlc? modified_since,
  }) =>
      Map<K, Record<V>>.from(_map)
        ..removeWhere(
          (final _, final record) => record.modified.logical_time < (modified_since?.logical_time ?? 0),
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
  late Hlc _canonical_time;

  @override
  Hlc get canonical_time => _canonical_time;

  @override
  String get node_id;

  @override
  bool get is_empty => map.isEmpty;

  @override
  int get length => map.length;

  @override
  Map<K, V> get map {
    final map = record_map();
    map.removeWhere(
      (final _, final record) => record.is_deleted,
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
    final map = record_map();
    _canonical_time = from_logical_time_hlc(
      () {
        if (map.isEmpty) {
          return 0;
        } else {
          return map.values.map((final record) => record.hlc.logical_time).reduce(max);
        }
      }(),
      node_id,
    );
  }

  @override
  V? get(
    final K key,
  ) =>
      get_record(key)?.value;

  @override
  void put(
    final K key,
    final V? value,
  ) {
    _canonical_time = send_hlc(_canonical_time);
    final record = RecordImpl<V>(_canonical_time, value, _canonical_time);
    put_record(key, record);
  }

  @override
  void put_all(
    final Map<K, V?> values,
  ) {
    // Avoid touching the canonical time if no data is inserted
    if (values.isNotEmpty) {
      _canonical_time = send_hlc(_canonical_time);
      final records = values.map<K, RecordImpl<V>>(
        (final key, final value) => MapEntry(
          key,
          RecordImpl(
            _canonical_time,
            value,
            _canonical_time,
          ),
        ),
      );
      put_records(records);
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
  bool? is_deleted(
    final K key,
  ) =>
      get_record(key)?.is_deleted;

  @override
  void clear({
    final bool purge = false,
  }) {
    if (purge) {
      this.purge();
    } else {
      put_all(
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
    final localRecords = record_map();
    remoteRecords.removeWhere(
      (final key, final value) {
        _canonical_time = receive_hlc(_canonical_time, value.hlc);
        return localRecords[key] != null && localRecords[key]!.hlc >= value.hlc;
      },
    );
    final updatedRecords = remoteRecords.map(
      (final key, final value) => MapEntry(
        key,
        RecordImpl<V>(
          value.hlc,
          value.value,
          _canonical_time,
        ),
      ),
    );
    // Store updated records.
    put_records(updatedRecords);
    // Increment canonical time.
    _canonical_time = send_hlc(_canonical_time);
  }

  @override
  void merge_json(
    final String json, {
    final K Function(String key)? key_decoder,
    final V Function(String key, dynamic value)? value_decoder,
  }) =>
      merge(
        crdt_to_json<K, V>(
          json,
          _canonical_time,
          key_decoder: key_decoder,
          value_decoder: value_decoder,
        ),
      );

  @override
  String to_json({
    final Hlc? modified_since,
    final String Function(K key)? key_encoder,
    final dynamic Function(K key, V? value)? value_encoder,
  }) =>
      crdt_from_json(
        record_map(modified_since: modified_since),
        key_encoder: key_encoder,
        value_encoder: value_encoder,
      );

  @override
  String toString() => record_map().toString();
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
  bool get is_deleted => value == null;

  @override
  // ignore: hash_and_equals
  bool operator ==(
    final Object other,
  ) =>
      other is Record<V> && hlc == other.hlc && value == other.value;

  @override
  String toString() => record_to_json(this, '').toString();
}

abstract class Crdt<K, V> {
  /// Represents the latest logical time seen in the stored data
  Hlc get canonical_time;

  String get node_id;

  /// Returns true if CRDT has any non-deleted records.
  bool get is_empty;

  /// Get size of dataset excluding deleted records.
  int get length;

  /// Returns a simple key-value map without HLCs
  /// or deleted records.
  /// See [record_map].
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
  void put_all(
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
  bool? is_deleted(
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
    final Map<K, Record<V>> remote_records,
  );

  /// Merges two CRDTs and updates record and
  /// canonical clocks accordingly.
  /// Use [key_decoder] to convert non-string keys.
  /// Use [value_decoder] to convert non-native value types.
  /// See also [merge()].
  void merge_json(
    final String json, {
    final K Function(String key)? key_decoder,
    final V Function(String key, dynamic value)? value_decoder,
  });

  /// Outputs the contents of this CRDT in Json format.
  /// Use [modified_since] to encode only the most
  /// recently modified records.
  /// Use [key_encoder] to convert non-string keys.
  /// Use [value_encoder] to convert non-native value types.
  String to_json({
    final Hlc? modified_since,
    final String Function(K key)? key_encoder,
    final dynamic Function(K key, V? value)? value_encoder,
  });

  bool contains_key(
    final K key,
  );

  /// Gets record containing value and HLC.
  Record<V>? get_record(
    final K key,
  );

  /// Stores record without updating the HLC.
  /// Meant for subclassing, clients should use
  /// [put()] instead.
  /// Make sure to call [refreshCanonicalTime()]
  /// if using this method directly.
  void put_record(
    final K key,
    final Record<V> value,
  );

  /// Stores records without updating the HLC.
  /// Meant for subclassing, clients should use
  /// [putAll()] instead.
  /// Make sure to call [refreshCanonicalTime()]
  /// if using this method directly.
  void put_records(
    final Map<K, Record<V>> record_map,
  );

  /// Retrieves CRDT map including HLCs. Useful
  /// for merging with other CRDTs.
  /// Use [modified_since] to get only the most
  /// recently modified records.
  /// See also [toJson()].
  Map<K, Record<V>> record_map({
    final Hlc? modified_since,
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

  bool get is_deleted;
}
// endregion

// region serialize
String crdt_from_json<K, V extends Object>(
    final Map<K, Record<V>> map, {
      final String Function(K key)? key_encoder,
      final dynamic Function(K key, V? value)? value_encoder,
    }) {
  return jsonEncode(
    map.map(
          (final key, final value) => MapEntry(
        key_encoder == null ? key.toString() : key_encoder(key),
        record_to_json(
          value,
          key,
          value_encoder: value_encoder,
        ),
      ),
    ),
  );
}

Map<K, Record<V>> crdt_to_json<K, V extends Object>(
    final String json,
    final Hlc canonical_time, {
      final K Function(String key)? key_decoder,
      final V Function(String key, dynamic value)? value_decoder,
      final String Function(String)? node_id_decoder,
    }) {
  final now = now_hlc(canonical_time.node_id);
  final modified = canonical_time >= now ? canonical_time : now;
  return (jsonDecode(json) as Map<String, dynamic>).map(
        (final key, dynamic value) => MapEntry(
          () {
        if (key_decoder == null) {
          return key as K;
        } else {
          return key_decoder(key);
        }
      }(),
      record_from_json<V>(
        key,
        value as Map<String, dynamic>,
        modified,
        value_decoder: value_decoder,
        node_id_decoder: node_id_decoder,
      ),
    ),
  );
}

RecordImpl<V> record_from_json<V extends Object>(
    final dynamic key,
    final Map<String, dynamic> map,
    final Hlc modified, {
      final V Function(String key, dynamic value)? value_decoder,
      final String Function(String nodeId)? node_id_decoder,
    }) {
  return RecordImpl<V>(
    parse_hlc(map['hlc'] as String, node_id_decoder),
        () {
      if (value_decoder == null || map['value'] == null) {
        return map['value'] as V;
      } else {
        return value_decoder(key as String, map['value']);
      }
    }(),
    modified,
  );
}

@override
Map<String, dynamic> record_to_json<V extends Object, O>(
    final Record<V> record,
    final O key, {
      final dynamic Function(O key, V? value)? value_encoder,
    }) {
  return <String, dynamic>{
    'hlc': record.hlc.to_json(),
    'value': () {
      if (value_encoder == null) {
        return record.value;
      } else {
        return value_encoder(
          key,
          record.value,
        );
      }
    }(),
  };
}
// endregion
