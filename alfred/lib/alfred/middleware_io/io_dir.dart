import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../alfred.dart';
import '../interface.dart';

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
  ) async {
    return _serve_directory(
      directory: directory,
      log: (final a) => log.log_type_handler(msgFn: a),
      c: c,
    );
  }
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
  ) {
    return _serve_directory(
      directory: Directory(path),
      log: (final a) => log.log_type_handler(msgFn: a),
      c: c,
    );
  }
}

Future<void> _serve_directory({
  required final Directory directory,
  required final void Function(String Function()) log,
  required final ServeContext c,
}) async {
  final used_route = c.route.path;
  final wildcard_index = used_route.indexOf('*');
  if (wildcard_index < 0) {
    // TODO is there a way to remove this?
    throw Exception(
      'TypeHandler of type Directory needs a route declaration that contains a wildcard (*). Found: ' +
          used_route,
    );
  } else {
    final _path = c.req.uri.path;
    final offset = min(_path.length, wildcard_index);
    final virtual_path = _path.substring(offset);
    final file_path = directory.path + '/' + virtual_path;
    log(
      () => 'Resolve virtual path: ' + virtual_path,
    );
    final file_candidates = <File>[
      File(file_path),
      File(file_path + '/index.html'),
      File(file_path + '/index.htm'),
    ];
    try {
      final match = file_candidates.firstWhere(
        (final file) => file.existsSync(),
      );
      log(
        () => 'Respond with file: ' + match.path,
      );
      final content_type = fileContentType(
        filePath: match.path,
      );
      final c_ = c.res.mime_type;
      if (c_ == null || c_ == 'text/plain') {
        c.res.set_content_type(content_type);
      }
      await c.res.write_byte_stream(match.openRead());
      await c.res.close();
      // ignore: avoid_catching_errors
    } on StateError {
      log(
        () => 'Could not match with any file. Expected file at: ' + file_path,
      );
    }
  }
}
