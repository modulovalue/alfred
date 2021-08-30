import 'dart:async';

import 'serve_context.dart';

// TODO find a better name for middleware?
abstract class Middleware {
  Future<void> process(
    final ServeContext c,
  );
}
