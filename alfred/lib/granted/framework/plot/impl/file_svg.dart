import 'dart:math';

import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../plotter_item/impl/plotter.dart';
import '../../render/impl/svg.dart';
import '../interface.dart';

/// Plotter renderer which outputs SVG.
class PlotFileSvg implements PlotterPlot {
  final Plotter plotter;
  late final SvgRenderer _renderer;
  final void Function(String) onNewSvg;
  late Bounds __window;
  late String _bgColor;

  PlotFileSvg({
    required this.plotter,
    required this.onNewSvg,
  }) {
    _renderer = SvgRenderer(
      renderReset: (final window, final backgroundColorString) {
        __window = window;
        _bgColor = backgroundColorString;
      },
    );
    _onSvgResize();
  }

  @override
  void refresh() => _onSvgResize();

  void _onSvgResize() {
    _renderer.reset(_window, _projection);
    plotter.renderPlotWithRenderer(_renderer);
    final svgBody = _renderer.finalize();
    final svg = '<svg viewBox="0 0 ' +
        __window.width.toString() +
        ' ' +
        __window.height.toString() +
        '" height="' +
        __window.height.toString() +
        '" width="' +
        __window.width.toString() +
        '" xmlns="http://www.w3.org/2000/svg">' +
        '<rect width="100%" height="100%" fill="' +
        _bgColor +
        '"/>' +
        svgBody +
        '</svg>';
    onNewSvg(svg);
  }

  /// Gets the transformer for the plot target div.
  /// This is the projection from the view
  /// coordinates to the window coordinates.
  Transformer get _projection {
    final width = _width;
    final height = _height;
    final size = () {
      final _size = min(width, height);
      if (_size <= 0.0) {
        return 1.0;
      } else {
        return _size;
      }
    }();
    return TransformerImpl(
      size,
      size,
      0.5 * width,
      0.5 * height,
    );
  }

  // TODO to get a 1:1 scaling, this would need to be the bounds of the content. No trivial way to do that without dart:svg
  /// The width of the div that is being plotted to.
  double get _width => 2000;

  /// The height of the div that is being plotted to.
  double get _height => 2000;

  /// Gets the window size for the plot.
  Bounds get _window => BoundsImpl(
        0.0,
        0.0,
        _width,
        _height,
      );
}
