import 'dart:math';

HlcImpl from_date_hlc(
  final DateTime date_time,
  final String node_id,
) {
  return HlcImpl(
    date_time.millisecondsSinceEpoch,
    0,
    node_id,
  );
}

HlcImpl from_logical_time_hlc(
  final int logical_time,
  final String node_id,
) {
  return HlcImpl(
    logical_time >> hlc_shift,
    logical_time & hlc_max_counter,
    node_id,
  );
}

HlcImpl now_hlc(
  final String node_id,
) {
  return from_date_hlc(DateTime.now(), node_id);
}

Hlc parse_hlc(
  final String timestamp, [
  final String Function(String nodeId)? id_decoder,
]) {
  final counter_dash = timestamp.indexOf('-', timestamp.lastIndexOf(':'));
  final node_id_dash = timestamp.indexOf('-', counter_dash + 1);
  final millis = DateTime.parse(timestamp.substring(0, counter_dash)).millisecondsSinceEpoch;
  final counter = int.parse(timestamp.substring(counter_dash + 1, node_id_dash), radix: 16);
  final node_id = timestamp.substring(node_id_dash + 1);
  return HlcImpl(
    millis,
    counter,
    () {
      if (id_decoder != null) {
        return id_decoder(node_id);
      } else {
        return node_id;
      }
    }(),
  );
}

/// Compares and validates a timestamp from a remote system with the local
/// canonical timestamp to preserve monotonicity.
/// Returns an updated canonical timestamp instance.
/// Local wall time will be used if [millis] isn't supplied.
Hlc receive_hlc(
  final Hlc canonical,
  final Hlc remote, {
  int? millis,
}) {
  // Retrieve the local wall time if millis is null
  // ignore: parameter_assignments
  millis = millis ?? DateTime.now().millisecondsSinceEpoch;
  // No need to do any more work if the remote logical time is lower
  if (canonical.logical_time >= remote.logical_time) {
    return canonical;
  } else if (canonical.node_id == remote.node_id) {
    // Assert the node id
    throw DuplicateNodeException(canonical.node_id);
  } else if (remote.millis - millis > hlc_max_drift) {
    // Assert the remote clock drift
    throw ClockDriftException(remote.millis - millis);
  } else {
    return from_logical_time_hlc(remote.logical_time, canonical.node_id);
  }
}

/// Generates a unique, monotonic timestamp suitable for transmission to
/// another system in string format. Local wall time will be used if
/// [millis] isn't supplied.
Hlc send_hlc(
  final Hlc canonical, {
  int? millis,
}) {
  // Retrieve the local wall time if millis is null
  // ignore: parameter_assignments
  millis = millis ?? DateTime.now().millisecondsSinceEpoch;
  // Unpack the canonical time and counter
  final millis_old = canonical.millis;
  final counter_old = canonical.counter;
  // Calculate the next time and counter
  // * ensure that the logical time never goes backward
  // * increment the counter if time does not advance
  final millis_new = max(millis_old, millis);
  final counter_new = () {
    if (millis_old == millis_new) {
      return counter_old + 1;
    } else {
      return 0;
    }
  }();
  // Check the result for drift and counter overflow
  if (millis_new - millis > hlc_max_drift) {
    throw ClockDriftException(millis_new - millis);
  } else if (counter_new > hlc_max_counter) {
    throw OverflowException(counter_new);
  } else {
    return HlcImpl(
      millis_new,
      counter_new,
      canonical.node_id,
    );
  }
}

HlcImpl zero_hlc(
  final String nodeId,
) {
  return HlcImpl(
    0,
    0,
    nodeId,
  );
}

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
  final String node_id;

  HlcImpl(
    final int millis,
    this.counter,
    this.node_id,
  )   : assert(
          counter <= hlc_max_counter,
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
  int get logical_time => (millis << hlc_shift) + counter;

  @override
  Hlc apply({
    final int? millis,
    final int? counter,
    final String? node_id,
  }) =>
      HlcImpl(
        millis ?? this.millis,
        counter ?? this.counter,
        node_id ?? this.node_id,
      );

  @override
  String to_json() => toString();

  @override
  String toString() =>
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toIso8601String() +
      '-' +
      counter.toRadixString(16).toUpperCase().padLeft(4, '0') +
      '-' +
      node_id;

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
      compareTo(other) > 0;

  @override
  bool operator >=(
    final Hlc other,
  ) =>
      this > other || this == other;

  @override
  int compareTo(
    final Hlc other,
  ) {
    final time = logical_time.compareTo(other.logical_time);
    if (time != 0) {
      return time;
    } else {
      return node_id.compareTo(other.node_id);
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

  String get node_id;

  int get logical_time;

  Hlc apply({
    final int? millis,
    final int? counter,
    final String? node_id,
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

  String to_json();

  @override
  int compareTo(
    final Hlc other,
  );
}

const int hlc_shift = 16;

const int hlc_max_counter = 0xFFFF;

const int hlc_max_drift = 60000; // 1 minute in ms

class ClockDriftException implements Exception {
  final int drift;

  const ClockDriftException(
    this.drift,
  );

  @override
  String toString() =>
      'Clock drift of ' + drift.toString() + ' ms exceeds maximum (' + hlc_max_drift.toString() + ')';
}

class OverflowException implements Exception {
  final int counter;

  const OverflowException(
    this.counter,
  );

  @override
  String toString() => 'Timestamp counter overflow: ' + counter.toString();
}

class DuplicateNodeException implements Exception {
  final String node_id;

  const DuplicateNodeException(
    this.node_id,
  );

  @override
  String toString() => 'Duplicate node: ' + node_id;
}
