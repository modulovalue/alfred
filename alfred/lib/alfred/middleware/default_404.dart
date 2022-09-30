import '../../../base/http_status_code.dart';
import '../interface.dart';

class NotFound404Middleware implements AlfredMiddleware {
  const NotFound404Middleware();

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.set_status_code(httpStatusNotFound404);
    c.res.write_string('404 not found');
    await c.res.close();
  }
}
