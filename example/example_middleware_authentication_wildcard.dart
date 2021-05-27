import 'dart:async';
import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/middleware/impl/empty.dart';
import 'package:alfred/middleware/impl/response.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.all('/resource*', ResponseMiddleware((HttpResponse res) async {
    res.statusCode = 401;
    await res.close();
  }));
  app.get('/resource', const EmptyMiddleware()); //Will not be hit
  app.post('/resource', const EmptyMiddleware()); //Will not be hit
  app.post('/resource/1', const EmptyMiddleware()); //Will not be hit
  await app.listen();
}
