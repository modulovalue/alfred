import 'dart:async';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/impl.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.all('/resource*', MiddlewareBuilder((c) async {
    c.res.statusCode = 401;
    await c.res.close();
  }));
  app.get('/resource', const ClosingMiddleware()); //Will not be hit
  app.post('/resource', const ClosingMiddleware()); //Will not be hit
  app.post('/resource/1', const ClosingMiddleware()); //Will not be hit
  await app.build();
}
