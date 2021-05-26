import 'dart:async';
import 'dart:io';

import 'package:alfred/base.dart';

FutureOr<dynamic> exampleMiddlware(HttpRequest req, HttpResponse res) {
  // Do work.
  if (req.headers.value('Authorization') != 'apikey') {
    throw const AlfredException(401, {'message': 'authentication failed'});
  }
}

Future<void> main() async {
  final app = Alfred();
  app.all('/example/:id/:name', (req, res) {}, middleware: [exampleMiddlware]);
  await app.listen(); //Listening on port 3000
}
