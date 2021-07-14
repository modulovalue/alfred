import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../../../base/mime.dart';
import '../../interface/alfred.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServeDownload implements Middleware {
  final String filename;
  final ServeFile child;

  const ServeDownload({
    required final this.filename,
    required final this.child,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    // TODO extract and centralise header.
    c.res.headers.add('Content-Disposition', 'attachment; filename=$filename');
    await child.process(c);
  }
}

class ServeFile implements Middleware {
  final File file;

  const ServeFile(
    final this.file,
  );

  ServeFile.at(
    final String path,
  ) : file = File(path);

  @override
  Future<void> process(
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
      throw FileNotFoundException(c, file);
    }
  }
}

class FileNotFoundException implements NotFoundException {
  final File file;
  final ServeContext c;

  const FileNotFoundException(
    final this.c,
    final this.file,
  );

  @override
  String toString() => 'FileNotFoundException{file: $file}';
}

class ServeDirectory implements Middleware {
  final Directory directory;

  const ServeDirectory(
    final this.directory,
  );

  ServeDirectory.at(
    final String path,
  ) : directory = Directory(path);

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final usedRoute = c.route.route;
    assert(
      usedRoute.contains('*'),
      'TypeHandler of type Directory needs a route declaration that contains a wildcard (*). Found: $usedRoute',
    );
    final virtualPath = c.req.uri.path.substring(min(c.req.uri.path.length, usedRoute.indexOf('*')));
    final filePath = '${directory.path}/$virtualPath';
    // TODO separate logger.
    c.alfred.log.logTypeHandler(() => 'Resolve virtual path: $virtualPath');
    final fileCandidates = <File>[
      File(filePath),
      File('$filePath/index.html'),
      File('$filePath/index.htm'),
    ];
    try {
      final match = fileCandidates.firstWhere((file) => file.existsSync());
      // TODO separate logger.
      c.alfred.log.logTypeHandler(() => 'Respond with file: ${match.path}');
      final c_ = c.res.headers.contentType;
      if (c_ == null || c_.mimeType == 'text/plain') {
        c.res.headers.contentType = fileContentType(match);
      }
      await c.res.addStream(match.openRead());
      await c.res.close();
      // ignore: avoid_catching_errors
    } on StateError {
      // TODO separate logger.
      c.alfred.log.logTypeHandler(() => 'Could not match with any file. Expected file at: $filePath');
    }
  }
}
