import 'dart:async';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

/// Servet stands for Server Widget.
class ServetBuilder implements AlfredMiddleware {
  final FutureOr<AlfredMiddleware> Function(ServeContext c) builder;

  const ServetBuilder({
    required final this.builder,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final built = await builder(c);
    await built.process(c);
  }
}
