import '../hlc.dart';

HlcImpl fromDateHlc(
  final DateTime dateTime,
  final String nodeId,
) =>
    HlcImpl(
      dateTime.millisecondsSinceEpoch,
      0,
      nodeId,
    );
