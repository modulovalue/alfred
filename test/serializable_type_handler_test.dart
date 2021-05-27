import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/interface/alfred.dart';
import 'package:alfred/middleware/impl/value.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'common.dart';

void main() {
  late Alfred app;
  late int port;

  /// TODO replace with run tests
  setUp(() async {
    app = AlfredImpl();
    port = await app.listenForTest();
  });
  tearDown(() => app.close());
  test('it uses the serializable helper correctly', () async {
    app.get('/testSerializable1', ValueMiddleware(_SerializableObjType1()));
    app.get('/testSerializable2', ValueMiddleware(_SerializableObjType1()));
    app.get('/testNoSerialize', ValueMiddleware(_NonSerializableObj()));
    final response1 = await http.get(Uri.parse('http://localhost:$port/testSerializable1'));
    expect(response1.body, '{"test":true}');

    final response2 = await http.get(Uri.parse('http://localhost:$port/testSerializable2'));
    expect(response2.body, '{"test":true}');

    final response3 = await http.get(Uri.parse('http://localhost:$port/testNoSerialize'));
    expect(response3.statusCode, 500);
    expect(response3.body.contains('_NonSerializableObj'), true);
  });
}

class _SerializableObjType1 {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'test': true};
  }
}

class _NonSerializableObj {}
