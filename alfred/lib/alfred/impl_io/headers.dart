import 'dart:io';

import '../impl_io/content_type.dart';
import '../interface/serve_context.dart';

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
