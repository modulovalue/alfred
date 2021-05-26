import 'dart:async';
import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/response.dart';

Future<void> main() async {
  final app = Alfred(onNotFound: ResponseMiddleware((HttpResponse res) {
    res.statusCode = 404;
    return {'message': 'not found'};
  }));
  await app.listen();
}
