import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/html.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';
import 'package:alfred/alfred/impl/middleware/json.dart';
import 'package:alfred/alfred/impl/middleware/string.dart';

Future<void> main() async {
  final app = AlfredImpl()
    ..get('/text', const ServeString('Text response'))
    ..get('/json', const ServeJson.map({'json_response': true}))
    ..get('/jsonExpressStyle', const ServeJson.map({'type': 'traditional_json_response'}))
    ..get('/file', ServeFile.at('test/files/image.jpg'))
    ..get('/html', const ServeHtml('<html><body><h1>Test HTML</h1></body></html>'));
  await app.build(port: 6565); // Listening on port 6565.
}
