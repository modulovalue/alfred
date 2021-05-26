import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'mixin.dart';

class TypeHandlerJsonListImpl with TypeHandlerShouldHandleMixin<List<dynamic>> {
  const TypeHandlerJsonListImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    List<dynamic> value,
  ) {
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(value));
    return res.close();
  }
}
