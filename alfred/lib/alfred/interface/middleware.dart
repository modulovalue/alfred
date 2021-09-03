import 'dart:async';

import 'serve_context.dart';

abstract class AlfredMiddleware {
  Future<void> process(
    final ServeContext c,
  );
}
