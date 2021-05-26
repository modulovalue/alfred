import 'dart:async';
import 'dart:io';

import 'mixin.dart';

class TypeHandlerStreamOfListOfIntegersImpl with TypeHandlerShouldHandleMixin<Stream<List<int>>> {
  const TypeHandlerStreamOfListOfIntegersImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    Stream<List<int>> val,
  ) async {
    if (res.headers.contentType == null || res.headers.contentType!.value == 'text/plain') {
      res.headers.contentType = ContentType.binary;
    }
    await res.addStream(val);
    await res.close();
  }
}
