import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

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
