import '../../hlc/impl/factory/parse.dart';
import '../../hlc/interface/hlc.dart';
import '../impl/record.dart';

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
