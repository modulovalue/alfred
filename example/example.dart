import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/response.dart';
import 'package:alfred/middleware/impl/response.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.get('/text', const ValueMiddleware('Text response'));
  app.get('/json', const ValueMiddleware({'json_response': true}));
  app.get('/jsonExpressStyle', ResponseMiddleware((res) => AlfredHttpResponseImpl(res).json({'type': 'traditional_json_response'})));
  app.get('/file', ValueMiddleware(File('test/files/image.jpg')));
  app.get('/html', ResponseMiddleware((res) {
    res.headers.contentType = ContentType.html;
    return '<html><body><h1>Test HTML</h1></body></html>';
  }));
  await app.listen(6565); // Listening on port 6565.
}
