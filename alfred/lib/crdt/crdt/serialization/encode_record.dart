import '../interface/record.dart';

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
