import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/plotter.dart';
import '../../plotter_item/impl/text.dart';
import '../mouse_handle.dart';

PlotterMouseCoords makeMouseCoords(
  final Plotter plotter,
) {
  final _text = plotter.addText(0.0, 0.0, 12.0, "");
  return PlotterMouseCoords(
    plotter,
    _text,
  );
}

/// A mouse handler for outputting coordinates of the mouse, typically to be displayed.
class PlotterMouseCoords implements PlotterMouseHandle {
  final Plotter _plot;
  final Text _text;

  const PlotterMouseCoords(
    this._plot,
    this._text,
  );

  /// handles mouse down.
  @override
  void mouseDown(
    final PlotterMouseEvent e,
  ) {}

  /// handles mouse moved.
  @override
  void mouseMove(
    final PlotterMouseEvent e,
  ) {
    final x = _plot.windowToViewTransformer.untransformX(e.px).toStringAsPrecision(3);
    final y = _plot.windowToViewTransformer.untransformY(e.py).toStringAsPrecision(3);
    _text
      ..x = (e.x + 3)
      ..y = (e.y - 3)
      ..text = x + ", " + y;
    e.redraw = true;
  }

  /// handles mouse up.
  @override
  void mouseUp(
    final PlotterMouseEvent e,
  ) {}
}
