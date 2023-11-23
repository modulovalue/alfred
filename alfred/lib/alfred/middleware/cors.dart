import 'dart:async';

import '../../base/method.dart';
import '../interface.dart';

/// CORS Middleware.
///
/// Has some sensible defaults. You probably
/// want to change the origin.
class CorsMiddleware implements AlfredMiddleware {
  static const String default_methods = MethodPost.postString +
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
    this.age = 86400,
    this.headers = '*',
    this.methods = default_methods,
    this.origin = '*',
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    // TODO extract and centralise header key.
    c.res.set_header_string('Access-Control-Allow-Origin', origin);
    // TODO extract and centralise header key.
    c.res.set_header_string('Access-Control-Allow-Methods', methods);
    // TODO extract and centralise header key.
    c.res.set_header_string('Access-Control-Allow-Headers', headers);
    // TODO extract and centralise header key.
    c.res.set_header_integer('Access-Control-Max-Age', age);
    if (Methods.options.isMethod(c.req.method)) {
      await c.res.close();
    }
  }
}
