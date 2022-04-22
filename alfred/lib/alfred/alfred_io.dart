import 'dart:async';
import 'dart:io';

import 'alfred.dart';
import 'interface.dart';

class ServeContextIOImpl implements ServeContext {
  @override
  final Alfred alfred;
  @override
  final AlfredRequestImpl req;
  @override
  final AlfredResponseImpl res;
  @override
  late AlfredHttpRoute route;

  ServeContextIOImpl({
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

class AlfredHttpHeadersImpl implements AlfredHttpHeaders {
  final HttpHeaders headers;

  const AlfredHttpHeadersImpl({
    required final this.headers,
  });

  @override
  String? get contentTypeMimeType => headers.contentType?.mimeType;

  @override
  AlfredContentType? get contentType {
    final contentType = headers.contentType;
    if (contentType == null) {
      return null;
    } else {
      return AlfredContentTypeFromContentTypeImpl(
        contentType: contentType,
      );
    }
  }

  @override
  String? getValue(
    final String key,
  ) =>
      headers.value(key);

  @override
  String? get host => headers.host;
}

class AlfredContentTypeFromContentTypeImpl implements AlfredContentType {
  final ContentType contentType;

  const AlfredContentTypeFromContentTypeImpl({
    required final this.contentType,
  });

  @override
  String get primaryType => contentType.primaryType;

  @override
  String get subType => contentType.subType;

  @override
  String? get charset => contentType.charset;

  @override
  String? getParameter(
    final String key,
  ) =>
      contentType.parameters[key];

  @override
  String get mimeType => contentType.mimeType;
}

// TODO inline mime type dependency.
class AlfredContentTypeSvg extends AlfredContentTypeFromContentTypeImpl {
  AlfredContentTypeSvg()
      : super(
          contentType: ContentType.parse(
            "image/svg+xml",
          ),
        );
}

class AlfredContentTypePng extends AlfredContentTypeFromContentTypeImpl {
  AlfredContentTypePng()
      : super(
          contentType: ContentType.parse(
            "image/png",
          ),
        );
}

class AlfredWebSocketImpl implements AlfredWebSocket {
  final WebSocket socket;

  const AlfredWebSocketImpl({
    required final this.socket,
  });

  @override
  void addString(
    final String string,
  ) =>
      socket.add(string);

  @override
  void addBytes(
    final List<int> bytes,
  ) =>
      socket.add(bytes);

  @override
  Future<void> close({
    required int? code,
    required String? reason,
  }) =>
      socket.close(code, reason);

  @override
  StreamSubscription<dynamic> listen({
    required final void Function(dynamic event)? onData,
    required final Function? onError,
    required final void Function()? onDone,
    required final bool? cancelOnError,
  }) =>
      socket.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
