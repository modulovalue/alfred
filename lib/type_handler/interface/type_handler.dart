import 'dart:async';
import 'dart:io';

abstract class TypeHandler<T> {
  FutureOr<dynamic> handler(HttpRequest req, HttpResponse res, T value);

  bool shouldHandle(dynamic item);
}
