import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../../../base/mime.dart';
import '../../interface/logging_delegate.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';
import '../logging/print.dart';

class ServeDirectoryIoDirectoryImpl implements Middleware {
  final Directory directory;

  // TODO too capable
  final AlfredLoggingDelegate log;

  const ServeDirectoryIoDirectoryImpl(
    final this.directory, [
    final this.log = const AlfredLoggingDelegatePrintImpl(),
  ]);

  @override
  Future<void> process(
    final ServeContext c,
  ) async =>
      _serveDirectory(
        directory: directory,
        log: log,
        c: c,
      );
}

class ServeDirectoryStringPathImpl implements Middleware {
  final String directoryPath;

  // TODO too capable
  final AlfredLoggingDelegate log;

  const ServeDirectoryStringPathImpl(
    final this.directoryPath, [
    final this.log = const AlfredLoggingDelegatePrintImpl(),
  ]);

  @override
  Future<void> process(
    final ServeContext c,
  ) =>
      _serveDirectory(
        directory: Directory(directoryPath),
        log: log,
        c: c,
      );
}

Future<void> _serveDirectory({
  required final Directory directory,
  required final AlfredLoggingDelegate log,
  required final ServeContext c,
}) async {
  final usedRoute = c.route.route;
  final wildcardIndex = usedRoute.indexOf('*');
  if (wildcardIndex < 0) {
    // TODO is there a way to remove this?
    throw Exception(
      'TypeHandler of type Directory needs a route declaration that contains a wildcard (*). Found: ' + usedRoute,
    );
  } else {
    final _path = c.req.uri.path;
    final offset = min(_path.length, wildcardIndex);
    final virtualPath = _path.substring(offset);
    final filePath = directory.path + '/' + virtualPath;
    log.logTypeHandler(
      () => 'Resolve virtual path: ' + virtualPath,
    );
    final fileCandidates = <File>[
      File(filePath),
      File(filePath + '/index.html'),
      File(filePath + '/index.htm'),
    ];
    try {
      final match = fileCandidates.firstWhere(
        (final file) => file.existsSync(),
      );
      log.logTypeHandler(() => 'Respond with file: ' + match.path);
      final c_ = c.res.headers.contentType;
      if (c_ == null || c_.mimeType == 'text/plain') {
        c.res.headers.contentType = fileContentType(match);
      }
      await c.res.addStream(match.openRead());
      await c.res.close();
      // ignore: avoid_catching_errors
    } on StateError {
      log.logTypeHandler(
        () => 'Could not match with any file. Expected file at: ' + filePath,
      );
    }
  }
}
