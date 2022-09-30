
import 'package:alfred/crdt/cachapa_crdt.dart';

void main() {
  const firstKey = "firstKey";
  const secondKey = "secondKey";
  final clientCrdt = MapCrdt<String, String>('C');
  final remoteCrdt = MapCrdt<String, String>('R');
  String sendToRemoteAndReceiveUpdatedBack({
    required final String json,
  }) {
    final merged = remoteCrdt..merge_json(json);
    merged.put(firstKey, "Remote Update First");
    merged.put(secondKey, "Remote Update Second");
    return merged.to_json();
  }

  clientCrdt.put(firstKey, "First");
  final remoteJson = sendToRemoteAndReceiveUpdatedBack(
    json: clientCrdt.to_json(),
  );
  clientCrdt.put(secondKey, "Second");
  clientCrdt.merge_json(remoteJson);
  print('Record after merging: ' + clientCrdt.to_json());
}
