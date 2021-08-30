import '../../interface/spec.dart';
import '../hlc.dart';

HlcImpl fromLogicalTimeHlc(
  final int logicalTime,
  final String nodeId,
) =>
    HlcImpl(
      logicalTime >> hlcShift,
      logicalTime & hlcMaxCounter,
      nodeId,
    );
