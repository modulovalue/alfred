import 'dart:async';
import 'dart:io';

import '../interface/middleware.dart';

/// CORS Middleware.
///
/// Has some sensible defaults. You probably want to change the origin
class CorsMiddleware implements Middleware<void> {
  final int age;
  final String headers;
  final String methods;
  final String origin;

  const CorsMiddleware({
    this.age = 86400,
    this.headers = '*',
    this.methods = 'POST, GET, OPTIONS, PUT, PATCH',
    this.origin = '*',
  });

  @override
  FutureOr<void> process(HttpRequest req, HttpResponse res) {
    res.headers.set('Access-Control-Allow-Origin', origin);
    res.headers.set('Access-Control-Allow-Methods', methods);
    res.headers.set('Access-Control-Allow-Headers', headers);
    res.headers.set('Access-Control-Max-Age', age);
    if (req.method == 'OPTIONS') {
      res.close();
    }
  }
}
