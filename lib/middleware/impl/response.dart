import 'dart:async';
import 'dart:io';

import '../interface/middleware.dart';

/// Middleware that depends on the response.
class ResponseMiddleware<T> implements Middleware<T> {
  final FutureOr<T> Function(HttpResponse req) process_;

  const ResponseMiddleware(this.process_);

  @override
  FutureOr<T> process(HttpRequest req, HttpResponse res) => process_(res);
}
