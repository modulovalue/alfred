import 'dart:io';

import '../interface/alfred.dart';
import '../interface/http_route_factory.dart';
import '../interface/serve_context.dart';
import 'parse_http_body.dart';

class ServeContextImpl with ServeContextMixin implements ServeContext {
  @override
  final Alfred alfred;
  @override
  final HttpRequest req;
  @override
  final HttpResponse res;
  @override
  late HttpRoute route;

  ServeContextImpl({
    required this.alfred,
    required this.req,
    required this.res,
  });
}

mixin ServeContextMixin implements ServeContext {
  @override
  Alfred get alfred;

  @override
  HttpRequest get req;

  @override
  HttpResponse get res;

  @override
  Future<Object?> get body async => (await HttpBodyHandlerImpl.processRequest(req)).body;

  @override
  Map<String, String>? get params => getParams(route.route, req.uri.path);
}

Map<String, String>? getParams(String route, String input) {
  final routeParts = route.split('/')..remove('');
  final inputParts = input.split('/')..remove('');
  if (inputParts.length != routeParts.length) {
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
