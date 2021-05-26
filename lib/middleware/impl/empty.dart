import 'dart:async';
import 'dart:io';

import '../interface/middleware.dart';

/// Middleware that does nothing.
class EmptyMiddleware implements Middleware<void> {
  const EmptyMiddleware();

  @override
  FutureOr<void> process(HttpRequest req, HttpResponse res) {}
}
