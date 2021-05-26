import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../../extensions.dart';
import 'mixin.dart';

class TypeHandlerDirectoryImpl with TypeHandlerShouldHandleMixin<Directory> {
  static void _log(HttpRequest req, String Function() msgFn) => req.alfred.LOG.logTypeHandler(msgFn);

  const TypeHandlerDirectoryImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    Directory directory,
  ) async {
    final usedRoute = req.route;
    assert(
      usedRoute.contains('*'),
      'TypeHandler of type Directory needs a route declaration that contains a wildcard (*). Found: $usedRoute',
    );
    final virtualPath = req.uri.path.substring(min(req.uri.path.length, usedRoute.indexOf('*')));
    final filePath = '${directory.path}/$virtualPath';
    _log(req, () => 'Resolve virtual path: $virtualPath');
    final fileCandidates = <File>[
      File(filePath),
      File('$filePath/index.html'),
      File('$filePath/index.htm'),
    ];
    try {
      final match = fileCandidates.firstWhere((file) => file.existsSync());
      _log(req, () => 'Respond with file: ${match.path}');
      res.setContentTypeFromFile(match);
      await res.addStream(match.openRead());
      await res.close();
      // ignore: avoid_catching_errors
    } on StateError {
      _log(req, () => 'Could not match with any file. Expected file at: $filePath');
    }
  }
}
