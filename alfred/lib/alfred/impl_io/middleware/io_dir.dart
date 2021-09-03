import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../../../base/mime.dart';
import '../../impl/logging/print.dart';
import '../../interface/logging_delegate.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServeDirectoryIoDirectoryImpl implements AlfredMiddleware {
  final Directory directory;

  // TODO too capable
  final AlfredLoggingDelegate log;

  const ServeDirectoryIoDirectoryImpl({
    required final this.directory,
    final this.log = const AlfredLoggingDelegatePrintImpl(),
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async =>
      _serveDirectory(
        directory: directory,
        log: (final a) => log.logTypeHandler(msgFn: a),
        c: c,
      );
}

class ServeDirectoryStringPathImpl implements AlfredMiddleware {
  final String path;

  // TODO too capable.
  final AlfredLoggingDelegate log;

  const ServeDirectoryStringPathImpl({
    required final this.path,
    final this.log = const AlfredLoggingDelegatePrintImpl(),
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) =>
      _serveDirectory(
        directory: Directory(path),
        log: (final a) => log.logTypeHandler(msgFn: a),
        c: c,
      );
}

Future<void> _serveDirectory({
  required final Directory directory,
  required final void Function(String Function()) log,
  required final ServeContext c,
}) async {
  final usedRoute = c.route.path;
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
    log(
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
      log(
        () => 'Respond with file: ' + match.path,
      );
      final contentType = fileContentType(
        filePath: match.path,
      );
      final c_ = c.res.mimeType;
      if (c_ == null || c_ == 'text/plain') {
        c.res.setContentType(contentType);
      }
      await c.res.writeByteStream(match.openRead());
      await c.res.close();
      // ignore: avoid_catching_errors
    } on StateError {
      log(
        () => 'Could not match with any file. Expected file at: ' + filePath,
      );
    }
  }
}
