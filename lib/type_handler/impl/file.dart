import 'dart:async';
import 'dart:io';

import '../../base.dart';
import '../../extensions.dart';
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
      res.setContentTypeFromFile(file);
      await res.addStream(file.openRead());
      return res.close();
    } else {
      throw NotFoundError();
    }
  }
}
