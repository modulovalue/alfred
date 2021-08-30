import 'dart:convert';

import '../../hlc/impl/factory/now.dart';
import '../../hlc/interface/hlc.dart';
import '../interface/record.dart';
import 'decode_record.dart';

Map<K, Record<V>> decodeCrdtJson<K, V extends Object>(
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
