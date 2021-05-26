import 'dart:async';

import 'package:alfred/alfred.dart';

Future<void> main() async {
  final app = Alfred(onInternalError: errorHandler);
  await app.listen();
  app.get('/throwserror', (req, res) => throw Exception('generic exception'));
}

FutureOr<dynamic> errorHandler(HttpRequest req, HttpResponse res) {
  res.statusCode = 500;
  return {'message': 'error not handled'};
}
