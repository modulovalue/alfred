import 'dart:async';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class MiddlewareBuilder implements Middleware {
  final Future<void> Function(ServeContext c) process_;

  const MiddlewareBuilder(this.process_);

  @override
  Future<void> process(ServeContext c) async {
    await process_(c);
  }
}

class ServetBuilder implements Middleware {
  final Future<Middleware> Function(ServeContext c) process_;

  const ServetBuilder(this.process_);

  @override
  Future<void> process(ServeContext c) async {
    return (await process_(c)).process(c);
  }
}
