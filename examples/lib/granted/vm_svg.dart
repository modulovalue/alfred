import 'dart:io';

import 'package:alfred/granted/example/example.dart';
import 'package:alfred/granted/framework/plot/impl/file/svg.dart';

void main() {
  final plot = makeExamplePlotter();
  // TODO plot htmlsvg/htmlcanvas over static generator possible?
  PlotFileSvg(
    plotter: plot,
    onNewSvg: (final svg) {
      final saveAtFile = File("plot.svg");
      return saveAtFile.writeAsStringSync(svg);
    },
  );
}
