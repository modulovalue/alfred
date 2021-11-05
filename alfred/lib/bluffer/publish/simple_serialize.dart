import 'dart:io';

import '../html/html.dart';
import 'serialize.dart';

/// Writes the given element to the given path.
void serializeToDisk(
  final String path,
  final HtmlElement element,
) {
  final file = File(path);
  final serializedHtml = serializeHtmlElement(
    element: element,
  );
  file.writeAsStringSync(
    serializedHtml,
  );
}
