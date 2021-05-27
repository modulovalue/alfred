import 'dart:async';
import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/base/interface/exception.dart';
import 'package:alfred/middleware/impl/empty.dart';
import 'package:alfred/middleware/interface/middleware.dart';

class ExampleMiddleware implements Middleware<dynamic> {
  const ExampleMiddleware();

  @override
  FutureOr<dynamic> process(HttpRequest req, HttpResponse res) {
    // Do work.
    if (req.headers.value('Authorization') != 'apikey') {
      throw const _AlfredExceptionImpl(401, {'message': 'authentication failed'});
    }
  }
}

FutureOr<dynamic> exampleMiddlware(HttpRequest req, HttpResponse res) {}

Future<void> main() async {
  final app = AlfredImpl();
  app.all('/example/:id/:name', const EmptyMiddleware(), middleware: const [ExampleMiddleware()]);
  await app.listen(); //Listening on port 3000
}

/// Throw these exceptions to bubble up an error from sub functions and have them
/// handled automatically for the client
/// TODO have an adt for all errors any given method can throw. no catch all exception-types.
class _AlfredExceptionImpl implements AlfredException {
  /// The response to send to the client
  @override
  final Object? response;

  /// The statusCode to send to the client
  @override
  final int statusCode;

  const _AlfredExceptionImpl(this.statusCode, this.response);
}
