import 'dart:async';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

/// Responds with a generic 5000 internal error.
class InternalError500Middleware implements Middleware {
  static InternalError500Middleware make(
    final dynamic error,
  ) =>
      InternalError500Middleware(error);

  final dynamic error;

  const InternalError500Middleware(
    final this.error,
  );

  @override
  Future<void> process(ServeContext c) async {
    try {
      c.res.statusCode = 500;
      c.res.write(error.toString());
      await c.res.close();
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {}
  }
}

class NotFound404Middleware implements Middleware {
  const NotFound404Middleware();

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.statusCode = 404;
    c.res.write('404 not found');
    await c.res.close();
  }
}
