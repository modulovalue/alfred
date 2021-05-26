import 'dart:io';

import 'package:alfred/base.dart';

Future<void> main() async {
  final app = Alfred();

  /// Note the wildcard (*) this is very important!!
  app.get('/public/*', (req, res) => Directory('test/files'));
  await app.listen();
}
