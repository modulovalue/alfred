import 'dart:async';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';
import 'package:alfred/alfred/interface/alfred.dart';
import 'package:alfred/alfred/interface/middleware.dart';
import 'package:alfred/alfred/interface/serve_context.dart';

class ExampleMiddleware implements Middleware {
  const ExampleMiddleware();

  @override
  Future<dynamic> process(ServeContext context) async {
    // Do work.
    if (context.req.headers.value('Authorization') != 'apikey') {
      throw const _AlfredExceptionImpl(401, {'message': 'authentication failed'});
    }
  }
}

Future<void> main() async {
  final app = AlfredImpl();
  app.all('/example/:id/:name', const ClosingMiddleware());
  await app.build(); //Listening on port 3000
}

/// Throw these exceptions to bubble up an error from sub functions and have them
/// handled automatically for the client
class _AlfredExceptionImpl implements AlfredException {
  /// The response to send to the client
  @override
  final Object? response;

  /// The statusCode to send to the client
  @override
  final int statusCode;

  const _AlfredExceptionImpl(this.statusCode, this.response);
}
