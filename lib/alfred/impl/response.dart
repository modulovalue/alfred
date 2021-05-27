import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../base/mime.dart';
import '../interface/response.dart';

class AlfredHttpResponseImpl implements AlfredHttpResponse {
  @override
  final HttpResponse rawResponse;

  const AlfredHttpResponseImpl(this.rawResponse);

  @override
  void setDownload({
    required String filename,
  }) =>
      rawResponse.headers.add('Content-Disposition', 'attachment; filename=$filename');

  @override
  void setContentTypeFromExtension(String extension) {
    final mime = mimeFromExtension(extension);
    if (mime != null) {
      final split = mime.split('/');
      rawResponse.headers.contentType = ContentType(split[0], split[1]);
    }
  }

  @override
  void setContentTypeFromFile(File file) {
    final c = rawResponse.headers.contentType;
    if (c == null || c.mimeType == 'text/plain') {
      rawResponse.headers.contentType = fileContentType(file);
    }
  }

  @override
  Future<dynamic> json(Object? json) {
    rawResponse.headers.contentType = ContentType.json;
    rawResponse.write(jsonEncode(json));
    return rawResponse.close();
  }

  @override
  Future<dynamic> send(Object? data) {
    rawResponse.write(data);
    return rawResponse.close();
  }
}
