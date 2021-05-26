import 'dart:async';
import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/empty.dart';
import 'package:alfred/middleware/interface/middleware.dart';

class ExampleMiddleware implements Middleware<dynamic> {
  const ExampleMiddleware();

  @override
  FutureOr<dynamic> process(HttpRequest req, HttpResponse res) {
    // Do work.
    if (req.headers.value('Authorization') != 'apikey') {
      throw const AlfredException(401, {'message': 'authentication failed'});
    }
  }
}

FutureOr<dynamic> exampleMiddlware(HttpRequest req, HttpResponse res) {}

Future<void> main() async {
  final app = Alfred();
  app.all('/example/:id/:name', const EmptyMiddleware(), middleware: const [ExampleMiddleware()]);
  await app.listen(); //Listening on port 3000
}
