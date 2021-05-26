import 'dart:async';
import 'dart:io';

abstract class Middleware<T> {
  FutureOr<T> process(HttpRequest req, HttpResponse res);
}
