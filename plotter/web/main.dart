import 'package:plotter_dart/example/example.dart';
import 'package:plotter_dart/framework/plot/impl/html/svg.dart';

// TODO move this into a separate package.
void main() {
  makeExample(
    plotterPlotFactory: (final plot) => buildPlotHtmlSvg(
      targetDivId: "output",
      plot: plot,
    ),
  );
}
