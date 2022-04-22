import 'dart:async';

import '../../base/method.dart';
import '../interface.dart';

/// CORS Middleware.
///
/// Has some sensible defaults. You probably
/// want to change the origin.
class CorsMiddleware implements AlfredMiddleware {
  static const String defaultMethods = MethodPost.postString +
      ', ' +
      MethodGet.getString +
      ', ' +
      MethodOptions.optionsString +
      ', ' +
      MethodPut.putString +
      ', ' +
      MethodPatch.patchString;
  final int age;
  final String headers;
  final String methods;
  final String origin;

  const CorsMiddleware({
    final this.age = 86400,
    final this.headers = '*',
    final this.methods = defaultMethods,
    final this.origin = '*',
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    // TODO extract and centralise header key.
    c.res.setHeaderString('Access-Control-Allow-Origin', origin);
    // TODO extract and centralise header key.
    c.res.setHeaderString('Access-Control-Allow-Methods', methods);
    // TODO extract and centralise header key.
    c.res.setHeaderString('Access-Control-Allow-Headers', headers);
    // TODO extract and centralise header key.
    c.res.setHeaderInteger('Access-Control-Max-Age', age);
    if (Methods.options.isMethod(c.req.method)) {
      await c.res.close();
    }
  }
}
