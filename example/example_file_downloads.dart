import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/extensions.dart';
import 'package:alfred/middleware/impl/response.dart';

Future<void> main() async {
  final app = Alfred();
  app.get('/image/download', ResponseMiddleware((res) {
    res.setDownload(filename: 'image.jpg');
    return File('test/files/image.jpg');
  }));
  await app.listen(); //Listening on port 3000
}
