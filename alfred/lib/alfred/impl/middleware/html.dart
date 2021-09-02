// TODO centralize this dependency
import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServeHtml implements Middleware {
  final String html;

  const ServeHtml({
    required final this.html,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.headers.contentType = ContentType.html;
    c.res.write(html);
    await c.res.close();
  }
}

class ServeHtmlBuilder implements Middleware {
  final String Function(ServeContext context) builder;

  const ServeHtmlBuilder({
    required final this.builder,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.headers.contentType = ContentType.html;
    c.res.write(builder(c));
    await c.res.close();
  }
}
