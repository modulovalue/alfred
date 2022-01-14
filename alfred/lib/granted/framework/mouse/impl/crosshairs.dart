import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/lines.dart';
import '../../plotter_item/impl/plotter.dart';
import '../mouse_handle.dart';

PlotterMouseLocationCrosshairs makeMouseCrosshairs(
  final Plotter plotter,
) {
  final _lines = plotter.addLines([])..addColor(1.0, 0.0, 0.0);
  return PlotterMouseLocationCrosshairs(
    plotter,
    _lines,
  );
}

class PlotterMouseLocationCrosshairs implements PlotterMouseHandle {
  final Plotter mouseHandlesPlotter;
  final Lines crossHairLines;

  const PlotterMouseLocationCrosshairs(
    final this.mouseHandlesPlotter,
    final this.crossHairLines,
  );

  /// Handles mouse movement to update the crosshairs.
  @override
  void mouseMove(
    final PlotterMouseEvent e,
  ) {
    final trans = e.projection.mul(mouseHandlesPlotter.windowToViewTransformer);
    final x = trans.untransformX(e.x);
    final y = trans.untransformY(e.window.ymax - e.y);
    final d = x - trans.untransformX(e.x + 10.0);
    crossHairLines.clear();
    crossHairLines.add([x - d, y, x + d, y, x, y - d, x, y + d]);
    e.redraw = true;
  }

  @override
  void mouseDown(
    final PlotterMouseEvent e,
  ) {}

  @override
  void mouseUp(
    final PlotterMouseEvent e,
  ) {}
}
