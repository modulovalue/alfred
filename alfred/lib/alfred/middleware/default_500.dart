import 'dart:async';

import '../../../base/http_status_code.dart';
import '../interface.dart';

/// Responds with a generic 5000 internal error.
class InternalError500Middleware implements AlfredMiddleware {
  final Object error;

  const InternalError500Middleware({
    required this.error,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    try {
      c.res.set_status_code(httpStatusInternalServerError500);
      c.res.write_string(error.toString());
      await c.res.close();
    } on Object catch (_) {}
  }
}
