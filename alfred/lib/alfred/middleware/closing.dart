import '../interface.dart';

class ClosingMiddleware implements AlfredMiddleware {
  const ClosingMiddleware();

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    return c.res.close();
  }
}
