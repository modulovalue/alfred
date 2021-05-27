import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  final app = AlfredImpl();

  /// Note the wildcard (*) this is very important!!
  app.get('/public/*', ValueMiddleware(Directory('test/files')));
  await app.listen();
}
