import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/response.dart';
import 'package:alfred/middleware/impl/response.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.get('/image/download', ResponseMiddleware((res) {
    AlfredHttpResponseImpl(res).setDownload(filename: 'image.jpg');
    return File('test/files/image.jpg');
  }));
  await app.listen(); //Listening on port 3000
}
