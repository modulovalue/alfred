import '../../interface/hlc.dart';
import '../../interface/spec.dart';
import 'exceptions.dart';
import 'logical_time.dart';

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
    throw ClockDriftException(remote.millis, millis);
  } else {
    return fromLogicalTimeHlc(remote.logicalTime, canonical.nodeId);
  }
}
