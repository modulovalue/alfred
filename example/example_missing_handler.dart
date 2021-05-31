import 'dart:async';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/impl.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';

Future<void> main() async {
  final app = AlfredImpl(onNotFound: MiddlewareBuilder((c) {
    c.res.statusCode = 404;
    return const ServeJson.map({'message': 'not found'}).process(c);
  }));
  await app.build();
}
