import 'dart:convert';

import 'cachapa_crdt.dart';
import 'cachapa_hlc.dart';

String crdtFromJson<K, V extends Object>(
  final Map<K, Record<V>> map, {
  final String Function(K key)? keyEncoder,
  final dynamic Function(K key, V? value)? valueEncoder,
}) =>
    jsonEncode(
      map.map(
        (final key, final value) => MapEntry(
          keyEncoder == null ? key.toString() : keyEncoder(key),
          recordToJson(
            value,
            key,
            valueEncoder: valueEncoder,
          ),
        ),
      ),
    );

Map<K, Record<V>> crdtToJson<K, V extends Object>(
  final String json,
  final Hlc canonicalTime, {
  final K Function(String key)? keyDecoder,
  final V Function(String key, dynamic value)? valueDecoder,
  final String Function(String)? nodeIdDecoder,
}) {
  final now = nowHlc(canonicalTime.nodeId);
  final modified = canonicalTime >= now ? canonicalTime : now;
  return (jsonDecode(json) as Map<String, dynamic>).map(
    (final key, dynamic value) => MapEntry(
      () {
        if (keyDecoder == null) {
          return key as K;
        } else {
          return keyDecoder(key);
        }
      }(),
      recordFromJson<V>(
        key,
        value as Map<String, dynamic>,
        modified,
        valueDecoder: valueDecoder,
        nodeIdDecoder: nodeIdDecoder,
      ),
    ),
  );
}

RecordImpl<V> recordFromJson<V extends Object>(
  final dynamic key,
  final Map<String, dynamic> map,
  final Hlc modified, {
  final V Function(String key, dynamic value)? valueDecoder,
  final String Function(String nodeId)? nodeIdDecoder,
}) =>
    RecordImpl<V>(
      parseHlc(map['hlc'] as String, nodeIdDecoder),
      () {
        if (valueDecoder == null || map['value'] == null) {
          return map['value'] as V;
        } else {
          return valueDecoder(key as String, map['value']);
        }
      }(),
      modified,
    );

@override
Map<String, dynamic> recordToJson<V extends Object, O>(
  final Record<V> record,
  final O key, {
  final dynamic Function(O key, V? value)? valueEncoder,
}) =>
    <String, dynamic>{
      'hlc': record.hlc.toJson(),
      'value': () {
        if (valueEncoder == null) {
          return record.value;
        } else {
          return valueEncoder(
            key,
            record.value,
          );
        }
      }(),
    };
