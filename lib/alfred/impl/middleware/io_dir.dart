import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../../../base/mime.dart';
import '../../interface/logging_delegate.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';
import '../logging/print.dart';

abstract class ServeDirectory implements Middleware {
  const factory ServeDirectory(
    final Directory directory, [
    final AlfredLoggingDelegate log,
  ]) = _ServeDirectory_IoDirectory;

  const factory ServeDirectory.at(
    final String path, [
    final AlfredLoggingDelegate log,
  ]) = _ServeDirectory_StringPath;
}

class _ServeDirectory_IoDirectory implements ServeDirectory {
  final Directory directory;

  // TODO too capable
  final AlfredLoggingDelegate log;

  const _ServeDirectory_IoDirectory(
    final this.directory, [
    final this.log = const AlfredLoggingDelegatePrintImpl(),
  ]);

  @override
  Future<void> process(
    final ServeContext c,
  ) async =>
      _serveDirectory(directory, log, c);
}

class _ServeDirectory_StringPath implements ServeDirectory {
  final String directoryPath;

  // TODO too capable
  final AlfredLoggingDelegate log;

  const _ServeDirectory_StringPath(
    final this.directoryPath, [
    final this.log = const AlfredLoggingDelegatePrintImpl(),
  ]);

  @override
  Future<void> process(
    final ServeContext c,
  ) async =>
      _serveDirectory(Directory(directoryPath), log, c);
}

Future<void> _serveDirectory(
  final Directory directory,
  final AlfredLoggingDelegate log,
  final ServeContext c,
) async {
  final usedRoute = c.route.route;
  final wildcardIndex = usedRoute.indexOf('*');
  if (wildcardIndex < 0) {
    throw Exception('TypeHandler of type Directory needs a route declaration that contains a wildcard (*). Found: ' + usedRoute);
  } else {
    final _path = c.req.uri.path;
    final offset = min(_path.length, wildcardIndex);
    final virtualPath = _path.substring(offset);
    final filePath = directory.path + '/' + virtualPath;
    log.logTypeHandler(() => 'Resolve virtual path: ' + virtualPath);
    final fileCandidates = <File>[
      File(filePath),
      File(filePath + '/index.html'),
      File(filePath + '/index.htm'),
    ];
    try {
      final match = fileCandidates.firstWhere((file) => file.existsSync());
      log.logTypeHandler(() => 'Respond with file: ' + match.path);
      final c_ = c.res.headers.contentType;
      if (c_ == null || c_.mimeType == 'text/plain') {
        c.res.headers.contentType = fileContentType(match);
      }
      await c.res.addStream(match.openRead());
      await c.res.close();
      // ignore: avoid_catching_errors
    } on StateError {
      log.logTypeHandler(() => 'Could not match with any file. Expected file at: ' + filePath);
    }
  }
}
