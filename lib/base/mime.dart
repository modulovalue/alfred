import 'dart:io';

import 'package:mime_type/mime_type.dart' as _m;

/// Get the contentType header from the given file.
ContentType? fileContentType(File file) {
  // Get the mimeType as a string from the name of the given file.
  final mimeType = _m.mime(file.path);
  if (mimeType != null) {
    final split = mimeType.split('/');
    return ContentType(split[0], split[1]);
  } else {
    return null;
  }
}

String? mimeFromExtension(String extension) => _m.mimeFromExtension(extension);
