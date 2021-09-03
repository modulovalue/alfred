import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServeHtml implements AlfredMiddleware {
  final String html;

  const ServeHtml({
    required final this.html,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.setContentTypeHtml();
    c.res.writeString(html);
    await c.res.close();
  }
}

class ServeHtmlBuilder implements AlfredMiddleware {
  final String Function(ServeContext context) builder;

  const ServeHtmlBuilder({
    required final this.builder,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.setContentTypeHtml();
    c.res.writeString(builder(c));
    await c.res.close();
  }
}
