import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

/// Middleware that doesn't depend on requests and
/// responses and just returns a value.
class ServeString implements AlfredMiddleware {
  final String string;

  const ServeString({
    required final this.string,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.writeString(string);
    await c.res.close();
  }
}
