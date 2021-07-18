import 'dart:convert';
import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServeJson implements Middleware {
  final dynamic value;

  const ServeJson.map(
    final Map<String, Object?> this.value,
  );

  const ServeJson.list(
    final List<dynamic> this.value,
  );

  @override
  Future<dynamic> process(
    final ServeContext c,
  ) {
    c.res.headers.contentType = ContentType.json;
    c.res.write(jsonEncode(value));
    return c.res.close();
  }
}

class ServeJsonBuilder implements Middleware {
  final Future<dynamic> Function(ServeContext c) value;

  const ServeJsonBuilder.map(
    final Future<Map<String, Object?>> Function(ServeContext c) this.value,
  );

  const ServeJsonBuilder.list(
    final Future<List<dynamic>> Function(ServeContext c) this.value,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.headers.contentType = ContentType.json;
    c.res.write(jsonEncode(await value(c)));
    return c.res.close();
  }
}
