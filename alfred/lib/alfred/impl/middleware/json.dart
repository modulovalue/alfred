import 'dart:convert';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServeJson implements AlfredMiddleware {
  final dynamic value;

  const ServeJson.map({
    required final Map<String, Object?> map,
  }) : value = map;

  const ServeJson.list({
    required final List<dynamic> list,
  }) : value = list;

  @override
  Future<dynamic> process(
    final ServeContext c,
  ) {
    c.res.setContentTypeJson();
    c.res.writeString(jsonEncode(value));
    return c.res.close();
  }
}

class ServeJsonBuilder implements AlfredMiddleware {
  final Future<dynamic> Function(ServeContext c) value;

  const ServeJsonBuilder.map({
    required final Future<Map<String, Object?>> Function(ServeContext c) map,
  }) : value = map;

  const ServeJsonBuilder.list({
    required final Future<List<dynamic>> Function(ServeContext c) list,
  }) : value = list;

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    c.res.setContentTypeJson();
    c.res.writeString(jsonEncode(await value(c)));
    return c.res.close();
  }
}
