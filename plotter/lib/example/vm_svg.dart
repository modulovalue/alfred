import '../framework/plot/impl/file/svg.dart';
import 'example.dart';

void main() {
  makeExample(
    plotterPlotFactory: (final plot) => buildPlotFileSvg(
      plot: plot,
    ),
  );
}
