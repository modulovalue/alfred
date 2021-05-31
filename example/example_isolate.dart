import 'dart:isolate';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/impl.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';
import 'package:alfred/base/unawaited.dart';

Future<void> main() async {
  for (var i = 0; i < 5; i++) {
    unawaited(Isolate.spawn(runIsolate, ''));
  }
  unawaited(runIsolate(null));
}

Future<void> runIsolate(dynamic message) async {
  final app = AlfredImpl();
  app.all('/example', const ServeString('Hello world'));
  app.get('/html', const ServeHtml('<html><body><h1>Title!</h1></body></html>'));
  app.get('/image', ServeFile.at('test/files/image.jpg'));
  app.get(
    '/image/download',
    ServeDownload(
      filename: 'model10.jpg',
      child: ServeFile.at('test/files/image.jpg'),
    ),
  );
  app.get('/redirect', MiddlewareBuilder((c) {
    return c.res.redirect(Uri.parse('https://www.google.com'));
  }));
  app.get('/files', ServeDirectory.at('test/files'));
  final server = await app.build();
  print('Listening on ${server.server.port}');
}
