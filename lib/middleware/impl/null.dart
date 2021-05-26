import 'dart:io';

import '../interface/middleware.dart';

/// Middleware that returns null.
class NullMiddleware implements Middleware<Null> {
  const NullMiddleware();

  @override
  Null process(HttpRequest req, HttpResponse res) => null;
}
