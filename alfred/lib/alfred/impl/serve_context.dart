import 'dart:io';

import '../interface/alfred.dart';
import '../interface/http_route_factory.dart';
import '../interface/serve_context.dart';
import 'parse_http_body.dart';

class ServeContextImpl implements ServeContext {
  @override
  final Alfred alfred;
  @override
  final HttpRequest req;
  @override
  final HttpResponse res;
  @override
  late HttpRoute route;

  ServeContextImpl({
    required final this.alfred,
    required final this.req,
    required final this.res,
  });

  @override
  Future<Object?> get body async => (await HttpBodyHandlerImpl.processRequest(req)).body;

  @override
  Map<String, String>? get arguments => getParams(route.route, req.uri.path);
}

Map<String, String>? getParams(
  final String route,
  final String input,
) {
  final routeParts = route.split('/')..remove('');
  final inputParts = input.split('/')..remove('');
  if (inputParts.length != routeParts.length) {
    // TODO expose the reason for the empty map.
    return null;
  } else {
    final output = <String, String>{};
    for (var i = 0; i < routeParts.length; i++) {
      final routePart = routeParts[i];
      final inputPart = inputParts[i];
      if (routePart.contains(':')) {
        final routeParams = routePart.split(':')..remove('');
        for (final item in routeParams) {
          output[item] = Uri.decodeComponent(inputPart);
        }
      }
    }
    return output;
  }
}
