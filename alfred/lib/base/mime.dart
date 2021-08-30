// TODO inline this dependency.
import 'package:mime_type/mime_type.dart' as _m;

/// Get the contentType header from the given file.
AlfredContentType? fileContentType({
  required final String filePath,
}) {
  // Get the mimeType as a string from the name of the given file.
  final mimeType = _m.mime(filePath);
  if (mimeType != null) {
    final split = mimeType.split('/');
    return AlfredContentType(split[0], split[1]);
  } else {
    return null;
  }
}

class AlfredContentType {
  final String primaryType;
  final String subType;

  const AlfredContentType(
    final this.primaryType,
    final this.subType,
  );
}

String? mimeFromExtension({
  required final String extension,
}) =>
    _m.mimeFromExtension(extension);
