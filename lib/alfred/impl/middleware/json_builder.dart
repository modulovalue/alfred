import 'dart:convert';
import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

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
