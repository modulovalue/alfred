import 'dart:async';

import 'alfred.dart';
import 'http_route_factory.dart';

abstract class ServeContext {
  AlfredRequest get req;

  AlfredResponse get res;

  Alfred get alfred;

  /// Parse the body automatically and return the result.
  Future<Object?> get body;

  /// Get arguments.
  Map<String, String>? get arguments;

  /// Will not be available in 404 responses.
  AlfredHttpRoute get route;
}

abstract class AlfredRequest {
  Future<AlfredWebSocket> upgradeToWebsocket();

  Stream<List<int>> get stream;

  AlfredResponse get response;

  Uri get uri;

  String get method;

  AlfredHttpHeaders get headers;

  String? get mimeType;
}

abstract class AlfredHttpHeaders {
  String? get contentTypeMimeType;

  AlfredContentType? get contentType;

  String? get host;

  String? getValue(
    final String key,
  );
}

abstract class AlfredContentType {
  String get primaryType;

  String get subType;

  String? get charset;

  String get mimeType;

  String? getParameter(
    final String key,
  );
}

abstract class AlfredWebSocket {
  StreamSubscription<dynamic> listen({
    required final void Function(dynamic event)? onData,
    required final Function? onError,
    required void Function()? onDone,
    required final bool? cancelOnError,
  });

  void addString(
    final String string,
  );

  void addBytes(
    final List<int> bytes,
  );

  Future<void> close({
    required final int? code,
    required final String? reason,
  });
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
