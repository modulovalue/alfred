import 'dart:isolate';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/html.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';
import 'package:alfred/alfred/impl/middleware/string.dart';
import 'package:alfred/base/unawaited.dart';

Future<void> main() async {
  for (var i = 0; i < 5; i++) {
    unawaited(Isolate.spawn(runIsolate, ''));
  }
  unawaited(runIsolate(null));
}

Future<void> runIsolate(
  dynamic message,
) async {
  const log = AlfredLoggingDelegatePrintImpl();
  final app = AlfredImpl()
    ..all(
      '/example',
      const ServeString('Hello world'),
    )
    ..get(
      '/html',
      const ServeHtml('<html><body><h1>Title!</h1></body></html>'),
    )
    ..get(
      '/image',
      ServeFile.at('test/files/image.jpg'),
    )
    ..get(
      '/image/download',
      ServeDownload(
        filename: 'model10.jpg',
        child: ServeFile.at('test/files/image.jpg'),
      ),
    )
    ..get(
      '/redirect',
      MiddlewareBuilder(
        (final c) => c.res.redirect(Uri.parse('https://www.google.com')),
      ),
    )
    ..get(
      '/files',
      ServeDirectory.at('test/files', log),
    );
  final server = await app.build(log: log);
  print('Listening on ' + server.server.port.toStringAsFixed(0));
}
