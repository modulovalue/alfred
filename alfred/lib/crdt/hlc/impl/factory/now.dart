import '../hlc.dart';
import 'date.dart';

HlcImpl nowHlc(
  final String nodeId,
) =>
    fromDateHlc(DateTime.now(), nodeId);
