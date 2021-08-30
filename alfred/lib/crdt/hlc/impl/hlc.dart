import '../interface/hlc.dart';
import '../interface/spec.dart';

/// A Hybrid Logical Clock implementation.
/// This class trades time precision for a guaranteed monotonically increasing
/// clock in distributed systems.
/// Inspiration: https://cse.buffalo.edu/tech-reports/2014-04.pdf
class HlcImpl implements Hlc {
  @override
  final int millis;
  @override
  final int counter;
  @override
  final String nodeId;

  HlcImpl(
    final int millis,
    final this.counter,
    final this.nodeId,
  )   : assert(counter <= hlcMaxCounter, "Counter can't go beyond max counter."),
        // Detect microseconds and convert to millis
        millis = (() {
          // TODO fix this and just accept ms.
          if (millis < 0x0001000000000000) {
            return millis;
          } else {
            return millis ~/ 1000;
          }
        }());

  @override
  int get logicalTime => (millis << hlcShift) + counter;

  @override
  Hlc apply({
    final int? millis,
    final int? counter,
    final String? nodeId,
  }) =>
      HlcImpl(
        millis ?? this.millis,
        counter ?? this.counter,
        nodeId ?? this.nodeId,
      );

  @override
  String toJson() => toString();

  @override
  String toString() =>
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toIso8601String() +
      '-' +
      counter.toRadixString(16).toUpperCase().padLeft(4, '0') +
      '-' +
      nodeId.toString();

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(
    final Object other,
  ) =>
      other is Hlc && compareTo(other) == 0;

  @override
  bool operator <(
    final Hlc other,
  ) =>
      compareTo(other) < 0;

  @override
  bool operator <=(
    final Hlc other,
  ) =>
      this < other || this == other;

  @override
  bool operator >(
    final Hlc other,
  ) =>
      other is Hlc && compareTo(other) > 0;

  @override
  bool operator >=(
    final Hlc other,
  ) =>
      this > other || this == other;

  @override
  int compareTo(
    Hlc other,
  ) {
    final time = logicalTime.compareTo(other.logicalTime);
    if (time != 0) {
      return time;
    } else {
      return nodeId.compareTo(other.nodeId);
    }
  }
}
