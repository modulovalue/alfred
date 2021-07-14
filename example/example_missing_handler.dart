import 'dart:async';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/json.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';

Future<void> main() async {
  final app = AlfredImpl(
    onNotFound: MiddlewareBuilder(
      (final c) {
        c.res.statusCode = 404;
        return const ServeJson.map({'message': 'not found'}).process(c);
      },
    ),
  );
  await app.build();
}
