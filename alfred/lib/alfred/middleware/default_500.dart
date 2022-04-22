import 'dart:async';

import '../../../base/http_status_code.dart';
import '../interface.dart';

/// Responds with a generic 5000 internal error.
class InternalError500Middleware implements AlfredMiddleware {
  final Object error;

  const InternalError500Middleware({
    required final this.error,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    try {
      c.res.setStatusCode(httpStatusInternalServerError500);
      c.res.writeString(error.toString());
      await c.res.close();
    } on Object catch (_) {}
  }
}
