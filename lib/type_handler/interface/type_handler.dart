import 'dart:async';
import 'dart:io';

/// TODO consider making Empty/Request/Result/RequestAndResult/each_async_and_not_async - an adt to be able to optimize if a middleware doesn't need any of them.
abstract class TypeHandler<T> {
  FutureOr<dynamic> handler(HttpRequest req, HttpResponse res, T value);

  bool shouldHandle(dynamic item);
}
