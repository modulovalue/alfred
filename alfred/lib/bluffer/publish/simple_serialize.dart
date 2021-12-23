import 'dart:io';

import '../html/html.dart';

/// Writes the given element to the given path.
void serializeToDisk(
  final String path,
  final HtmlEntityElement element,
) {
  final file = File(path);
  final serializedHtml = htmlElementToString(
    element: element.element,
  );
  file.writeAsStringSync(
    serializedHtml,
  );
}
