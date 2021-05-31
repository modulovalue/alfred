import 'dart:async';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/impl.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';

Future<void> main() async {
  final app = AlfredImpl(
    onInternalError: (dynamic e) => MiddlewareBuilder(
      (c) {
        c.res.statusCode = 500;
        return const ServeJson.map({'message': 'error not handled'}).process(c);
      },
    ),
  );
  await app.build();
  app.get('/throwserror', MiddlewareBuilder((_) => throw Exception('generic exception')));
}
