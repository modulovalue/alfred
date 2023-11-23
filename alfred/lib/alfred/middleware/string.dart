import '../interface.dart';

/// Middleware that doesn't depend on requests and
/// responses and just returns a value.
class ServeString implements AlfredMiddleware {
  final String string;

  const ServeString({
    required this.string,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.write_string(string);
    await c.res.close();
  }
}
