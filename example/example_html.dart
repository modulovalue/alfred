import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/response.dart';

Future<void> main() async {
  final app = Alfred();
  app.get('/html', ResponseMiddleware((res) {
    res.headers.contentType = ContentType.html;
    return '<html><body><h1>Title!</h1></body></html>';
  }));
  await app.listen(); //Listening on port 3000
}
