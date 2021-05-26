import 'dart:async';
import 'dart:io';

import '../interface/middleware.dart';

/// Middleware that depends on the request.
class RequestMiddleware<T> implements Middleware<T> {
  final FutureOr<T> Function(HttpRequest req) process_;

  const RequestMiddleware(this.process_);

  @override
  FutureOr<T> process(HttpRequest req, HttpResponse res) => process_(req);
}
