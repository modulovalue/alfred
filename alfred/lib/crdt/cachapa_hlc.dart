import 'dart:math';

HlcImpl fromDateHlc(
  final DateTime dateTime,
  final String nodeId,
) =>
    HlcImpl(
      dateTime.millisecondsSinceEpoch,
      0,
      nodeId,
    );

HlcImpl fromLogicalTimeHlc(
  final int logicalTime,
  final String nodeId,
) =>
    HlcImpl(
      logicalTime >> hlcShift,
      logicalTime & hlcMaxCounter,
      nodeId,
    );

HlcImpl nowHlc(
  final String nodeId,
) =>
    fromDateHlc(DateTime.now(), nodeId);

Hlc parseHlc(
  final String timestamp, [
  final String Function(String nodeId)? idDecoder,
]) {
  final counterDash = timestamp.indexOf('-', timestamp.lastIndexOf(':'));
  final nodeIdDash = timestamp.indexOf('-', counterDash + 1);
  final millis = DateTime.parse(timestamp.substring(0, counterDash)).millisecondsSinceEpoch;
  final counter = int.parse(timestamp.substring(counterDash + 1, nodeIdDash), radix: 16);
  final nodeId = timestamp.substring(nodeIdDash + 1);
  return HlcImpl(
    millis,
    counter,
    () {
      if (idDecoder != null) {
        return idDecoder(nodeId);
      } else {
        return nodeId;
      }
    }(),
  );
}

/// Compares and validates a timestamp from a remote system with the local
/// canonical timestamp to preserve monotonicity.
/// Returns an updated canonical timestamp instance.
/// Local wall time will be used if [millis] isn't supplied.
Hlc receiveHlc(
  final Hlc canonical,
  final Hlc remote, {
  int? millis,
}) {
  // Retrieve the local wall time if millis is null
  // ignore: parameter_assignments
  millis = millis ?? DateTime.now().millisecondsSinceEpoch;
  // No need to do any more work if the remote logical time is lower
  if (canonical.logicalTime >= remote.logicalTime) {
    return canonical;
  } else if (canonical.nodeId == remote.nodeId) {
    // Assert the node id
    throw DuplicateNodeException(canonical.nodeId.toString());
  } else if (remote.millis - millis > hlcMaxDrift) {
    // Assert the remote clock drift
    throw ClockDriftException(remote.millis - millis);
  } else {
    return fromLogicalTimeHlc(remote.logicalTime, canonical.nodeId);
  }
}

/// Generates a unique, monotonic timestamp suitable for transmission to
/// another system in string format. Local wall time will be used if
/// [millis] isn't supplied.
Hlc sendHlc(
  final Hlc canonical, {
  int? millis,
}) {
  // Retrieve the local wall time if millis is null
  // ignore: parameter_assignments
  millis = millis ?? DateTime.now().millisecondsSinceEpoch;
  // Unpack the canonical time and counter
  final millisOld = canonical.millis;
  final counterOld = canonical.counter;
  // Calculate the next time and counter
  // * ensure that the logical time never goes backward
  // * increment the counter if time does not advance
  final millisNew = max(millisOld, millis);
  final counterNew = () {
    if (millisOld == millisNew) {
      return counterOld + 1;
    } else {
      return 0;
    }
  }();
  // Check the result for drift and counter overflow
  if (millisNew - millis > hlcMaxDrift) {
    throw ClockDriftException(millisNew - millis);
  } else if (counterNew > hlcMaxCounter) {
    throw OverflowException(counterNew);
  } else {
    return HlcImpl(millisNew, counterNew, canonical.nodeId);
  }
}

HlcImpl zeroHlc(
  final String nodeId,
) =>
    HlcImpl(
      0,
      0,
      nodeId,
    );

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
  )   : assert(
          counter <= hlcMaxCounter,
          "Counter can't go beyond max counter.",
        ),
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
    final Hlc other,
  ) {
    final time = logicalTime.compareTo(other.logicalTime);
    if (time != 0) {
      return time;
    } else {
      return nodeId.compareTo(other.nodeId);
    }
  }
}

/// A Hybrid Logical Clock implementation.
/// This class trades time precision for a guaranteed monotonically increasing
/// clock in distributed systems.
/// Inspiration: https://cse.buffalo.edu/tech-reports/2014-04.pdf
abstract class Hlc implements Comparable<Hlc> {
  int get millis;

  int get counter;

  String get nodeId;

  int get logicalTime;

  Hlc apply({
    final int? millis,
    final int? counter,
    final String? nodeId,
  });

  bool operator <(
    final Hlc other,
  );

  bool operator <=(
    final Hlc other,
  );

  bool operator >(
    final Hlc other,
  );

  bool operator >=(
    final Hlc other,
  );

  @override
  int compareTo(
    final Hlc other,
  );

  String toJson();
}

const int hlcShift = 16;

const int hlcMaxCounter = 0xFFFF;

const int hlcMaxDrift = 60000; // 1 minute in ms

class ClockDriftException implements Exception {
  final int drift;

  const ClockDriftException(
    final this.drift,
  );

  @override
  String toString() => 'Clock drift of ' + drift.toString() + ' ms exceeds maximum (' + hlcMaxDrift.toString() + ')';
}

class OverflowException implements Exception {
  final int counter;

  const OverflowException(
    final this.counter,
  );

  @override
  String toString() => 'Timestamp counter overflow: ' + counter.toString();
}

class DuplicateNodeException implements Exception {
  final String nodeId;

  const DuplicateNodeException(
    final this.nodeId,
  );

  @override
  String toString() => 'Duplicate node: ' + nodeId;
}
