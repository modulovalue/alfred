import 'dart:async';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/json.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';

Future<void> main() async {
  final app = AlfredImpl(
    onInternalError: (final dynamic e) => MiddlewareBuilder(
      (final c) {
        c.res.statusCode = 500;
        return const ServeJson.map({
          'message': 'error not handled',
        }).process(c);
      },
    ),
  );
  await app.build();
  app.get(
    '/throwserror',
    MiddlewareBuilder(
      (final _) => throw Exception('generic exception'),
    ),
  );
}
