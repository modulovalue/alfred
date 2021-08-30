import 'dart:math';

import '../../hlc/impl/factory/logical_time.dart';
import '../../hlc/impl/factory/receive.dart';
import '../../hlc/impl/factory/send.dart';
import '../../hlc/interface/hlc.dart';
import '../impl/record.dart';
import '../interface/crdt.dart';
import '../interface/record.dart';
import '../serialization/decode_crdt.dart';
import '../serialization/encode_crdt.dart';
import 'record.dart';

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
        decodeCrdtJson<K, V>(
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
      encodeCrdtJson(
        recordMap(modifiedSince: modifiedSince),
        keyEncoder: keyEncoder,
        valueEncoder: valueEncoder,
      );

  @override
  String toString() => recordMap().toString();
}
