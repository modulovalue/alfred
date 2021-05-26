import 'dart:async';
import 'dart:io';

import '../interface/middleware.dart';

class MiddlewareImpl<T> implements Middleware<T> {
  final FutureOr<T> Function(HttpRequest req, HttpResponse res) process_;

  const MiddlewareImpl(this.process_);

  @override
  FutureOr<T> process(HttpRequest req, HttpResponse res) => process_(req, res);
}
