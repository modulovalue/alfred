import '../interface.dart';

class ServeHtml implements AlfredMiddleware {
  final String html;

  const ServeHtml({
    required final this.html,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.set_content_type_html();
    c.res.write_string(html);
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
    c.res.set_content_type_html();
    c.res.write_string(builder(c));
    await c.res.close();
  }
}
