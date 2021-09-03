// TODO centralize this dependency
import 'dart:io';

import '../interface/alfred.dart';
import '../interface/http_route_factory.dart';
import '../interface/parse_http_body.dart';
import '../interface/serve_context.dart';
import 'parse_http_body.dart';

class ServeContextImpl implements ServeContext {
  @override
  final Alfred alfred;
  @override
  final AlfredRequestImpl req;
  @override
  final AlfredResponseImpl res;
  @override
  late HttpRoute route;

  ServeContextImpl({
    required final this.alfred,
    required final this.req,
    required final this.res,
  });

  @override
  Future<Object?> get body async => (await processRequest(req, res)).httpBody.body;

  @override
  Map<String, String>? get arguments => getParams(
        route: route.path,
        input: req.req.uri.path,
      );
}

class AlfredRequestImpl implements AlfredRequest {
  final HttpRequest req;
  @override
  final AlfredResponse response;

  const AlfredRequestImpl({
    required final this.req,
    required final this.response,
  });

  @override
  HttpHeaders get headers => req.headers;

  @override
  String get method => req.method;

  @override
  Stream<List<int>> get stream => req;

  @override
  Uri get uri => req.uri;

  @override
  Future<WebSocket> upgradeToWebsocket() => WebSocketTransformer.upgrade(req);

  @override
  String? get mimeType => headers.contentType?.mimeType;
}

class AlfredResponseImpl implements AlfredResponse {
  final HttpResponse res;

  const AlfredResponseImpl({
    required final this.res,
  });

  @override
  Future<void> close() => res.close();

  @override
  void setHeaderInteger(
    final String key,
    final int value,
  ) =>
      res.headers.add(key, value);

  @override
  void setHeaderString(
    final String key,
    final String value,
  ) =>
      res.headers.add(key, value);

  @override
  void setStatusCode(
    final int statusCode,
  ) =>
      res.statusCode = statusCode;

  @override
  void setContentType(
    final AlfredContentType? type,
  ) {
    if (type == null) {
      res.headers.contentType = null;
    } else {
      res.headers.contentType = ContentType(
        type.primaryType,
        type.subType,
      );
    }
  }

  @override
  void writeString(
    final String s,
  ) =>
      res.write(s);

  @override
  void writeBytes(
    final List<int> bytes,
  ) =>
      res.add(bytes);

  @override
  Future<void> writeByteStream(
    final Stream<List<int>> stream,
  ) =>
      res.addStream(stream);

  @override
  Future<void> redirect(
    final Uri uri,
  ) =>
      res.redirect(uri);

  @override
  void setContentTypeBinary() => res.headers.contentType = ContentType.binary;

  @override
  void setContentTypeHtml() => res.headers.contentType = ContentType.html;

  @override
  void setContentTypeJson() => res.headers.contentType = ContentType.json;

  @override
  String? get mimeType => res.headers.contentType?.mimeType;
}

Map<String, String>? getParams({
  required final String route,
  required final String input,
}) {
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
