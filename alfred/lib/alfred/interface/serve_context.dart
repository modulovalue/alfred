import 'dart:io';

import 'alfred.dart';
import 'http_route_factory.dart';
import 'parse_http_body.dart';

abstract class ServeContext {
  AlfredRequest get req;

  AlfredResponse get res;

  Alfred get alfred;

  /// Parse the body automatically and return the result.
  Future<Object?> get body;

  /// Get arguments.
  Map<String, String>? get arguments;

  /// Will not be available in 404 responses.
  HttpRoute get route;
}

abstract class AlfredRequest {
  // TODO don't depend on io, have an alfred websocket wrapper.
  Future<WebSocket> upgradeToWebsocket();

  Stream<List<int>> get stream;

  AlfredResponse get response;

  Uri get uri;

  String get method;

  // TODO io independent wrapper.
  HttpHeaders get headers;

  String? get mimeType;
}

abstract class AlfredResponse {
  void setStatusCode(
    final int statusCode,
  );

  void setHeaderString(
    final String key,
    final String value,
  );

  void setHeaderInteger(
    final String key,
    final int value,
  );

  Future<void> close();

  String? get mimeType;

  void writeString(
    final String s,
  );

  void writeBytes(
    final List<int> bytes,
  );

  Future<void> writeByteStream(
    final Stream<List<int>> stream,
  );

  Future<void> redirect(
    final Uri uri,
  );

  void setContentType(
    final AlfredContentType? detectedContentType,
  );

  void setContentTypeBinary();

  void setContentTypeJson();

  void setContentTypeHtml();
}
