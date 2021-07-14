import 'dart:async';

import '../../../base/method.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

/// CORS Middleware.
///
/// Has some sensible defaults. You probably want to change the origin
class CorsMiddleware implements Middleware {
  final int age;
  final String headers;
  final String methods;
  final String origin;

  const CorsMiddleware({
    this.age = 86400,
    this.headers = '*',
    this.methods = '${MethodPost.postString}, ${MethodGet.getString}, ${MethodOptions.optionsString}, ${MethodPut.putString}, ${MethodPatch.patchString}',
    this.origin = '*',
  });

  @override
  Future<void> process(ServeContext c) async {
    c.res.headers.set('Access-Control-Allow-Origin', origin);
    c.res.headers.set('Access-Control-Allow-Methods', methods);
    c.res.headers.set('Access-Control-Allow-Headers', headers);
    c.res.headers.set('Access-Control-Max-Age', age);
    if (c.req.method == MethodOptions.optionsString) {
      await c.res.close();
    }
  }
}
