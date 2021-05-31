import 'dart:isolate';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';
import 'package:alfred/base/unawaited.dart';

Future<void> main() async {
  // Fire up 5 isolates
  for (var i = 0; i < 5; i++) {
    unawaited(Isolate.spawn(startInstance, ''));
  }
  // Start listening on this isolate also
  unawaited(startInstance(null));
}

/// The start function needs to be top level or static. You probably want to
/// run your entire app in an isolate so you don't run into trouble sharing DB
/// connections etc. However you can engineer this however you like.
Future<void> startInstance(dynamic message) async {
  final app = AlfredImpl();
  app.all('/example', const ServeString('Hello world'));
  await app.build();
}
