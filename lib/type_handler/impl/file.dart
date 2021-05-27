import 'dart:async';
import 'dart:io';

import '../../alfred/impl/alfred.dart';
import '../../alfred/impl/response.dart';
import 'mixin.dart';

class TypeHandlerFileImpl with TypeHandlerShouldHandleMixin<File> {
  const TypeHandlerFileImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    File file,
  ) async {
    if (file.existsSync()) {
      AlfredHttpResponseImpl(res).setContentTypeFromFile(file);
      await res.addStream(file.openRead());
      return res.close();
    } else {
      throw NotFoundError();
    }
  }
}
