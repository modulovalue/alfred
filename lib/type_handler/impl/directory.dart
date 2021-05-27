import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../../alfred/impl/request.dart';
import '../../alfred/impl/response.dart';
import '../../alfred/interface/alfred.dart';
import 'mixin.dart';

class TypeHandlerDirectoryImpl with TypeHandlerShouldHandleMixin<Directory> {
  final Alfred alfred;

  const TypeHandlerDirectoryImpl(this.alfred);

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    Directory directory,
  ) async {
    final usedRoute = AlfredHttpRequestImpl(req, alfred).route;
    assert(
      usedRoute.contains('*'),
      'TypeHandler of type Directory needs a route declaration that contains a wildcard (*). Found: $usedRoute',
    );
    final virtualPath = req.uri.path.substring(min(req.uri.path.length, usedRoute.indexOf('*')));
    final filePath = '${directory.path}/$virtualPath';
    alfred.log.logTypeHandler(() => 'Resolve virtual path: $virtualPath');
    final fileCandidates = <File>[
      File(filePath),
      File('$filePath/index.html'),
      File('$filePath/index.htm'),
    ];
    try {
      final match = fileCandidates.firstWhere((file) => file.existsSync());
      alfred.log.logTypeHandler(() => 'Respond with file: ${match.path}');
      AlfredHttpResponseImpl(res).setContentTypeFromFile(match);
      await res.addStream(match.openRead());
      await res.close();
      // ignore: avoid_catching_errors
    } on StateError {
      alfred.log.logTypeHandler(() => 'Could not match with any file. Expected file at: $filePath');
    }
  }
}
