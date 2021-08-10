import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

/// Middleware that doesn't depend on requests and
/// responses and just returns a value.
class ServeString implements Middleware {
  final String value;

  const ServeString(
    final this.value,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.write(value);
    await c.res.close();
  }
}
