import 'package:alfred/granted/example/example.dart';
import 'package:alfred/granted/framework/plot/impl/html/svg.dart';

void main() {
  buildPlotHtmlSvg(
    targetDivId: "output",
    plot: makeExamplePlotter(),
  );
}
