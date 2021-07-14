import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServeHtml implements Middleware {
  final String html;

  const ServeHtml(
    final this.html,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.headers.contentType = ContentType.html;
    c.res.write(html);
    await c.res.close();
  }
}
