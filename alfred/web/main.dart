import 'dart:html';

import 'package:alfred/granted/example/example.dart';
import 'package:alfred/granted/framework/plot/impl/html_svg.dart';

// /usr/local/opt/dart-beta/libexec/bin/dart pub global run webdev serve
void main() {
  makePlotHtmlSvg(
    targetDiv: querySelector(
      "#output",
    )!,
    plot: makeExamplePlotter(),
  );
}
