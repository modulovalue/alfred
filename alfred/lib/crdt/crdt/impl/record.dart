import '../../hlc/interface/hlc.dart';
import '../interface/record.dart';
import '../serialization/encode_record.dart';

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
