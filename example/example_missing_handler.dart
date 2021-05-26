import 'dart:async';
import 'dart:io';

import 'package:alfred/base.dart';

Future<void> main() async {
  final app = Alfred(onNotFound: missingHandler);
  await app.listen();
}

FutureOr<dynamic> missingHandler(HttpRequest req, HttpResponse res) {
  res.statusCode = 404;
  return {'message': 'not found'};
}
