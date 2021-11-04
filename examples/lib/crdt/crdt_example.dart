
import 'package:alfred/crdt/cachapa_crdt.dart';

void main() {
  const firstKey = "firstKey";
  const secondKey = "secondKey";
  final clientCrdt = MapCrdt<String, String>('C');
  final remoteCrdt = MapCrdt<String, String>('R');
  String sendToRemoteAndReceiveUpdatedBack({
    required final String json,
  }) {
    final merged = remoteCrdt..mergeJson(json);
    merged.put(firstKey, "Remote Update First");
    merged.put(secondKey, "Remote Update Second");
    return merged.toJson();
  }

  clientCrdt.put(firstKey, "First");
  final remoteJson = sendToRemoteAndReceiveUpdatedBack(
    json: clientCrdt.toJson(),
  );
  clientCrdt.put(secondKey, "Second");
  clientCrdt.mergeJson(remoteJson);
  print('Record after merging: ' + clientCrdt.toJson());
}
