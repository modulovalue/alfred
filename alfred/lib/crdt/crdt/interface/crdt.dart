import '../../hlc/interface/hlc.dart';
import 'record.dart';

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
