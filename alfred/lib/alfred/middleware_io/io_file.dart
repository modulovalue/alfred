import 'dart:io';

import '../alfred.dart';
import '../interface.dart';

abstract class ServeFile implements AlfredMiddleware {}

class ServeFileIoFileImpl implements ServeFile {
  final File file;

  const ServeFileIoFileImpl({
    required this.file,
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
    required this.path,
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
    final c_ = c.res.mime_type;
    if (c_ == null || c_ == 'text/plain') {
      c.res.set_content_type(contentType);
    }
    await c.res.write_byte_stream(file.openRead());
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
    required this.c,
    required this.file,
  });

  @override
  String toString() => 'AlfredFileNotFoundExceptionImpl{file: ' + file.toString() + '}';

  @override
  Z match<Z>({
    required final Z Function(AlfredNotFoundException p1) NotFound,
  }) =>
      NotFound(this);
}
