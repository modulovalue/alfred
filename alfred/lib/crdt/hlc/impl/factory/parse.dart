import '../../interface/hlc.dart';
import '../hlc.dart';

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
