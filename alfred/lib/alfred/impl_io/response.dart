import 'dart:io';

import '../interface/serve_context.dart';

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
