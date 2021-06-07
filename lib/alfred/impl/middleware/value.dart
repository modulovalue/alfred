import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

/// Middleware that doesn't depend on requests and
/// responses and just returns a value.
class ServeString implements Middleware {
  final String value;

  const ServeString(this.value);

  @override
  Future<void> process(ServeContext c) async {
    c.res.write(value);
    await c.res.close();
  }
}

class ServeJson implements Middleware {
  final dynamic value;

  const ServeJson.map(Map<String, Object?> this.value);

  const ServeJson.list(List<dynamic> this.value);

  @override
  Future<dynamic> process(ServeContext c) {
    c.res.headers.contentType = ContentType.json;
    c.res.write(jsonEncode(value));
    return c.res.close();
  }
}

class ServeJsonBuilder implements Middleware {
  final Future<dynamic> Function(ServeContext c) value;

  const ServeJsonBuilder.map(Future<Map<String, Object?>> Function(ServeContext c) this.value);

  const ServeJsonBuilder.list(Future<List<dynamic>> Function(ServeContext c) this.value);

  @override
  Future<void> process(ServeContext c) async {
    c.res.headers.contentType = ContentType.json;
    c.res.write(jsonEncode(await value(c)));
    return c.res.close();
  }
}

class ServeHtml implements Middleware {
  final String html;

  const ServeHtml(this.html);

  @override
  Future<void> process(ServeContext c) async {
    c.res.headers.contentType = ContentType.html;
    c.res.write(html);
    await c.res.close();
  }
}

class ServeHtmlBuilder implements Middleware {
  final String Function(ServeContext context) builder;

  const ServeHtmlBuilder(this.builder);

  @override
  Future<void> process(ServeContext c) async {
    c.res.headers.contentType = ContentType.html;
    c.res.write(builder(c));
    await c.res.close();
  }
}

class ClosingMiddleware implements Middleware {
  const ClosingMiddleware();

  @override
  Future<void> process(ServeContext c) async => c.res.close();
}

class StreamOfBytesMiddleware implements Middleware {
  final Stream<List<int>> bytes;

  const StreamOfBytesMiddleware(this.bytes);

  @override
  Future<void> process(ServeContext c) async {
    if (c.res.headers.contentType == null || c.res.headers.contentType!.value == 'text/plain') {
      c.res.headers.contentType = ContentType.binary;
    }
    await c.res.addStream(bytes);
    await c.res.close();
  }
}

class BytesMiddleware implements Middleware {
  final List<int> bytes;

  const BytesMiddleware(this.bytes);

  @override
  Future<void> process(ServeContext c) async {
    if (c.res.headers.contentType == null || c.res.headers.contentType!.value == 'text/plain') {
      c.res.headers.contentType = ContentType.binary;
    }
    c.res.add(bytes);
    await c.res.close();
  }
}
