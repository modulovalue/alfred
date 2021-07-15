import 'dart:async';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

/// Servet stands for Server Widget.
class ServetBuilder implements Middleware {
  final FutureOr<Middleware> Function(ServeContext c) builder;

  const ServetBuilder(
    final this.builder,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) async => (await builder(c)).process(c);
}
