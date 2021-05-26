import 'dart:io';

import 'package:alfred/alfred.dart';

Future<void> main() async {
  final app = Alfred(logLevel: LogType.debug);

  app.get('/static/*', (req, res) => Directory('path/to/files'));

  await app.listen();
}
