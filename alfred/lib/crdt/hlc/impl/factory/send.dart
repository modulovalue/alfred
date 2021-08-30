import 'dart:math';

import '../../interface/hlc.dart';
import '../../interface/spec.dart';
import '../hlc.dart';
import 'exceptions.dart';

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
  final counterNew = millisOld == millisNew ? counterOld + 1 : 0;
  // Check the result for drift and counter overflow
  if (millisNew - millis > hlcMaxDrift) {
    throw ClockDriftException(millisNew, millis);
  } else if (counterNew > hlcMaxCounter) {
    throw OverflowException(counterNew);
  } else {
    return HlcImpl(millisNew, counterNew, canonical.nodeId);
  }
}
