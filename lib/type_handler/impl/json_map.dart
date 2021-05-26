import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'mixin.dart';

class TypeHandlerJsonMapImpl with TypeHandlerShouldHandleMixin<Map<String, dynamic>> {
  const TypeHandlerJsonMapImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    Map<String, dynamic> value,
  ) {
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(value));
    return res.close();
  }
}
