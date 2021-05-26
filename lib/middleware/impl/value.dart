import 'dart:io';

import '../interface/middleware.dart';

/// Middleware that doesn't depend on requests and
/// responses and just returns a value.
class ValueMiddleware<T> implements Middleware<T> {
  final T value;

  const ValueMiddleware(this.value);

  @override
  T process(HttpRequest req, HttpResponse res) => value;
}
