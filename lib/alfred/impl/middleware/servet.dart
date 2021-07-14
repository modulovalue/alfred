import 'dart:async';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServetBuilder implements Middleware {
  final FutureOr<Middleware> Function(ServeContext c) process_;

  const ServetBuilder(
    final this.process_,
  );

  @override
  Future<void> process(ServeContext c) async => (await process_(c)).process(c);
}
