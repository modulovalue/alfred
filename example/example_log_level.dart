import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  final app = Alfred(logLevel: LogType.debug);
  app.get('/static/*', ValueMiddleware(Directory('path/to/files')));
  await app.listen();
}
