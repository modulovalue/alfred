import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  final app = Alfred();
  // Provide any static assets
  app.get('/frontend/*', ValueMiddleware(Directory('spa')));
  // Let any other routes handle by client SPA
  app.get('/frontend/*', ValueMiddleware(File('spa/index.html')));
  await app.listen();
}
