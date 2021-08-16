import 'dart:io';

import 'package:alfred/granted/example/example.dart';
import 'package:alfred/granted/framework/plot/impl/file/svg.dart';

void main() {
  final plot = makeExamplePlotter();
  PlotFileSvg(
    plotter: plot,
    onNewSvg: (final svg) {
      final saveAtFile = File("/Users/valauskasmodestas/Desktop/plot.svg");
      return saveAtFile.writeAsStringSync(svg);
    },
  );
}
