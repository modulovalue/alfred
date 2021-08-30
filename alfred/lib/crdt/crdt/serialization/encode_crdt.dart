import 'dart:convert';

import '../interface/record.dart';
import 'encode_record.dart';

String encodeCrdtJson<K, V extends Object>(
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
