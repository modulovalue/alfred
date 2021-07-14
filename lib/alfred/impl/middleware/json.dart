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
