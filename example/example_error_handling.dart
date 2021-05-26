import 'dart:async';

import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/callback.dart';
import 'package:alfred/middleware/impl/response.dart';

Future<void> main() async {
  final app = Alfred(onInternalError: ResponseMiddleware((res) {
    res.statusCode = 500;
    return {'message': 'error not handled'};
  }));
  await app.listen();
  app.get('/throwserror', CallbackMiddleware(() => throw Exception('generic exception')));
}
