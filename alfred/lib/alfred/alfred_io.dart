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
  void set_header_integer(
    final String key,
    final int value,
  ) =>
      res.headers.add(key, value);

  @override
  void set_header_string(
    final String key,
    final String value,
  ) =>
      res.headers.add(key, value);

  @override
  void set_status_code(
    final int statusCode,
  ) =>
      res.statusCode = statusCode;

  @override
  void set_content_type(
    final AlfredContentType? type,
  ) {
    if (type == null) {
      res.headers.contentType = null;
    } else {
      res.headers.contentType = ContentType(
        type.primary_type,
        type.sub_type,
      );
    }
  }

  @override
  void write_string(
    final String s,
  ) =>
      res.write(s);

  @override
  void write_bytes(
    final List<int> bytes,
  ) =>
      res.add(bytes);

  @override
  Future<void> write_byte_stream(
    final Stream<List<int>> stream,
  ) =>
      res.addStream(stream);

  @override
  Future<void> redirect(
    final Uri uri,
  ) =>
      res.redirect(uri);

  @override
  void set_content_type_binary() => res.headers.contentType = ContentType.binary;

  @override
  void set_content_type_html() => res.headers.contentType = ContentType.html;

  @override
  void set_content_type_json() => res.headers.contentType = ContentType.json;

  @override
  String? get mime_type => res.headers.contentType?.mimeType;
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
  Future<AlfredWebSocket> upgrade_to_websocket() async => AlfredWebSocketImpl(
        socket: await WebSocketTransformer.upgrade(req),
      );

  @override
  String? get mime_type => headers.content_type_mime_type;
}

class AlfredHttpHeadersImpl implements AlfredHttpHeaders {
  final HttpHeaders headers;

  const AlfredHttpHeadersImpl({
    required final this.headers,
  });

  @override
  String? get content_type_mime_type => headers.contentType?.mimeType;

  @override
  AlfredContentType? get content_type {
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
  String? get_value(
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
  String get primary_type => contentType.primaryType;

  @override
  String get sub_type => contentType.subType;

  @override
  String? get charset => contentType.charset;

  @override
  String? get_parameter(
    final String key,
  ) =>
      contentType.parameters[key];

  @override
  String get mime_type => contentType.mimeType;
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
  void add_string(
    final String string,
  ) =>
      socket.add(string);

  @override
  void add_bytes(
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
    required final void Function(dynamic event)? on_data,
    required final Function? on_error,
    required final void Function()? on_done,
    required final bool? cancel_on_error,
  }) =>
      socket.listen(
        on_data,
        onError: on_error,
        onDone: on_done,
        cancelOnError: cancel_on_error,
      );
}
