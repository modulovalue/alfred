import 'dart:io';

import '../../../base/mime.dart';
import '../../interface/alfred.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

abstract class ServeFile implements AlfredMiddleware {}

class ServeFileIoFileImpl implements ServeFile {
  final File file;

  const ServeFileIoFileImpl({
    required final this.file,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) =>
      _serveFile(file, c);
}

class ServeFileStringPathImpl implements ServeFile {
  final String path;

  const ServeFileStringPathImpl({
    required final this.path,
  });

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
    final contentType = fileContentType(
      filePath: file.path,
    );
    final c_ = c.res.mimeType;
    if (c_ == null || c_ == 'text/plain') {
      c.res.setContentType(contentType);
    }
    await c.res.writeByteStream(file.openRead());
    return c.res.close();
  } else {
    throw AlfredFileNotFoundExceptionImpl(
      c: c,
      file: file,
    );
  }
}

class AlfredFileNotFoundExceptionImpl implements AlfredNotFoundException {
  final File file;
  final ServeContext c;

  const AlfredFileNotFoundExceptionImpl({
    required final this.c,
    required final this.file,
  });

  @override
  String toString() => 'AlfredFileNotFoundExceptionImpl{file: ' + file.toString() + '}';

  @override
  Z match<Z>({
    required final Z Function(AlfredNotFoundException p1) notFound,
  }) =>
      notFound(this);
}
