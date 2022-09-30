import 'dart:async';

import '../interface.dart';

class MiddlewareBuilder implements AlfredMiddleware {
  final Future<void> Function(ServeContext c) process_;

  const MiddlewareBuilder({
    required final Future<void> Function(ServeContext c) process,
  }) : process_ = process;

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    return process_(c);
  }
}
