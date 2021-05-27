import 'dart:io';
import 'dart:isolate';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/response.dart';
import 'package:alfred/base/mime.dart';
import 'package:alfred/base/unawaited.dart';
import 'package:alfred/middleware/impl/response.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  for (var i = 0; i < 5; i++) {
    unawaited(Isolate.spawn(runIsolate, ''));
  }
  unawaited(runIsolate(null));
}

Future<void> runIsolate(dynamic message) async {
  final app = AlfredImpl();
  app.all('/example', const ValueMiddleware('Hello world'));
  app.get('/html', ResponseMiddleware((res) {
    res.headers.contentType = ContentType.html;
    return '<html><body><h1>Title!</h1></body></html>';
  }));
  app.get('/image', ValueMiddleware(File('test/files/image.jpg')));
  app.get(
    '/image/download',
    ResponseMiddleware((res) {
      AlfredHttpResponseImpl(res).setDownload(filename: 'model10.jpg');
      final file = File('test/files/image.jpg');
      res.headers.contentType = fileContentType(file);
      return file.openRead();
    }),
    middleware: [
      const ValueMiddleware({'test': true})
    ],
  );
  app.get('/redirect', ResponseMiddleware((res) => res.redirect(Uri.parse('https://www.google.com'))));
  app.get('/files', ValueMiddleware(Directory('test/files')));
  final server = await app.listen();
  print('Listening on ${server.port}');
}
