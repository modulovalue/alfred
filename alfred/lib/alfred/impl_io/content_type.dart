import 'dart:io';

import '../interface/serve_context.dart';

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
