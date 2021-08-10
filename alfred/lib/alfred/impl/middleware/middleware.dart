import 'dart:async';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class MiddlewareBuilder implements Middleware {
  final Future<void> Function(ServeContext c) process_;

  const MiddlewareBuilder(
    final this.process_,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) =>
      process_(c);
}
