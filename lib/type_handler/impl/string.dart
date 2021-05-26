import 'dart:async';
import 'dart:io';

import 'mixin.dart';

class TypeHandlerStringImpl with TypeHandlerShouldHandleMixin<String> {
  const TypeHandlerStringImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    String value,
  ) {
    res.write(value);
    return res.close();
  }
}
