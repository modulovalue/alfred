// TODO inline this dependency.
import 'package:mime_type/mime_type.dart' as _m;

import '../alfred/impl/content_type.dart';
import '../alfred/interface/parse_http_body.dart';

/// Get the contentType header from the given file.
AlfredContentType? fileContentType({
  required final String filePath,
}) {
  // Get the mimeType as a string from the name of the given file.
  final mimeType = _m.mime(filePath);
  if (mimeType != null) {
    final split = mimeType.split('/');
    return AlfredContentTypeImpl(
      primaryType: split[0],
      subType: split[1],
    );
  } else {
    return null;
  }
}

String? mimeFromExtension({
  required final String extension,
}) =>
    _m.mimeFromExtension(extension);
