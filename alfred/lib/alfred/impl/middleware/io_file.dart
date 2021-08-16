import 'dart:io';

import '../../../base/mime.dart';
import '../../interface/alfred.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

abstract class ServeFile implements Middleware {}

class ServeFileIoFileImpl implements ServeFile {
  final File file;

  const ServeFileIoFileImpl(
    final this.file,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) =>
      _serveFile(file, c);
}

class ServeFileStringPathImpl implements ServeFile {
  final String path;

  const ServeFileStringPathImpl(
    final this.path,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) =>
      _serveFile(File(path), c);
}

Future<void> _serveFile(
  final File file,
  final ServeContext c,
) async {
  if (file.existsSync()) {
    c.res.headers.contentType = fileContentType(file);
    final c_ = c.res.headers.contentType;
    if (c_ == null || c_.mimeType == 'text/plain') {
      c.res.headers.contentType = fileContentType(file);
    }
    await c.res.addStream(file.openRead());
    return c.res.close();
  } else {
    throw AlfredFileNotFoundExceptionImpl(c, file);
  }
}

class AlfredFileNotFoundExceptionImpl implements AlfredNotFoundException {
  final File file;
  final ServeContext c;

  const AlfredFileNotFoundExceptionImpl(
    final this.c,
    final this.file,
  );

  @override
  String toString() => 'AlfredFileNotFoundExceptionImpl{file: $file}';

  @override
  Z match<Z>({
    required final Z Function(AlfredResponseException p1) response,
    required final Z Function(AlfredNotFoundException p1) notFound,
  }) =>
      notFound(this);
}
