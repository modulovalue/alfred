import 'dart:io';

import '../html/html.dart';
import '../html/pretty.dart';

/// Writes the given element to the given path.
void serializeToDisk(
  final String path,
  final HtmlElement element,
) {
  final file = File(path);
  final serializedHtml = htmlElementToString(
    element: element,
  );
  file.writeAsStringSync(
    serializedHtml,
  );
}
