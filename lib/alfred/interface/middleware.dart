import 'dart:async';

import 'serve_context.dart';

abstract class Middleware {
  Future<void> process(ServeContext c);
}
