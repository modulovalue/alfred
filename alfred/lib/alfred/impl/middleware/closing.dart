import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ClosingMiddleware implements Middleware {
  const ClosingMiddleware();

  @override
  Future<void> process(
    final ServeContext c,
  ) async =>
      c.res.close();
}
