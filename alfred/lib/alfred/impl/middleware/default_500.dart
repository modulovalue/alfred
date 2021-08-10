import 'dart:async';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

/// Responds with a generic 5000 internal error.
class InternalError500Middleware implements Middleware {
  static InternalError500Middleware make(
    final Object error,
  ) =>
      InternalError500Middleware(error);

  final Object error;

  const InternalError500Middleware(
    final this.error,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    try {
      c.res.statusCode = 500;
      c.res.write(error.toString());
      await c.res.close();
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {}
  }
}
