import 'dart:async';
import 'dart:io';

import 'mixin.dart';

class TypeHandlerListOfIntegersImpl with TypeHandlerShouldHandleMixin<List<int>> {
  const TypeHandlerListOfIntegersImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    List<int> value,
  ) async {
    if (res.headers.contentType == null || res.headers.contentType!.value == 'text/plain') {
      res.headers.contentType = ContentType.binary;
    }
    res.add(value);
    await res.close();
  }
}
