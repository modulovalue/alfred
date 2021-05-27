import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/logging/impl/generalizing/log_type.dart';
import 'package:alfred/logging/impl/generalizing/print.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  final app = AlfredImpl(log: const AlfredLoggingDelegatePrintImpl(LogType.debug));
  app.get('/static/*', ValueMiddleware(Directory('path/to/files')));
  await app.listen();
}
