import '../../interface/spec.dart';

class ClockDriftException implements Exception {
  final int drift;

  const ClockDriftException(
    final int millisTs,
    final int millisWall,
  ) : drift = millisTs - millisWall;

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
