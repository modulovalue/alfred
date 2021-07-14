import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServeHtmlBuilder implements Middleware {
  final String Function(ServeContext context) builder;

  const ServeHtmlBuilder(
    final this.builder,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.headers.contentType = ContentType.html;
    c.res.write(builder(c));
    await c.res.close();
  }
}
