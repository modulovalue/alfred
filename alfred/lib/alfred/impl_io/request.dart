import 'dart:async';
import 'dart:io';

import '../interface/serve_context.dart';
import 'headers.dart';
import 'web_socket.dart';

class AlfredRequestImpl implements AlfredRequest {
  final HttpRequest req;
  @override
  final AlfredResponse response;

  const AlfredRequestImpl({
    required final this.req,
    required final this.response,
  });

  @override
  AlfredHttpHeaders get headers => AlfredHttpHeadersImpl(
        headers: req.headers,
      );

  @override
  String get method => req.method;

  @override
  Stream<List<int>> get stream => req;

  @override
  Uri get uri => req.uri;

  @override
  Future<AlfredWebSocket> upgradeToWebsocket() async => AlfredWebSocketImpl(
        socket: await WebSocketTransformer.upgrade(req),
      );

  @override
  String? get mimeType => headers.contentTypeMimeType;
}
