import '../framework/events/events.dart';
import '../framework/events/events_impl.dart';
import '../framework/mouse/mouse_handle.dart';
import '../framework/mouse/mouse_handle_impl.dart';
import '../framework/plot/interface.dart';
import '../framework/plotter/plotter_impl.dart';

void makeExample({
  required final PlotterPlot Function(Plotter) plotterPlotFactory,
}) {
  final plot = makePlotter();
  {
    final group = _createBox(plot, 0.0, 0.0, "Circle Group");
    group.addCircleGroup(1.5, [10, 20, 20, 40, 30, 60]);
    group.addCircleGroup(3.5, [30, 20, 40, 40, 50, 60])
      ..addColor(1.0, 1.0, 1.0)
      ..addFillColor(0.0, 0.0, 1.0);
  }
  {
    final group = _createBox(plot, 100.0, 0.0, "Circles");
    group.addCircles([10, 20, 1.0, 20, 40, 3.0, 30, 60, 5.0]);
    group.addCircles([30, 20, 2.5, 40, 40, 4.5, 50, 60, 6.5])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 200.0, 0.0, "Ellipse Group");
    group.addEllipseGroup(4.0, 2.0, [10, 20, 20, 40, 30, 60]);
    group.addEllipseGroup(4.0, 8.0, [30, 20, 40, 40, 50, 60])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 300.0, 0.0, "Ellipses");
    group.addEllipses([10, 20, 4.0, 2.0, 20, 40, 3.0, 3.0, 30, 60, 2.0, 4.0]);
    group.addEllipses([30, 20, 4.0, 8.0, 40, 40, 6.0, 6.0, 50, 60, 8.0, 4.0])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 0.0, -100.0, "Line Strip");
    group.addLineStrip([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]);
  }
  {
    final group = _createBox(plot, 100.0, -100.0, "Lines");
    group.addLines([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]);
  }
  {
    final group = _createBox(plot, 200.0, -100.0, "Directed Lines");
    group.addLines([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addDirected(true);
  }
  {
    final group = _createBox(plot, 300.0, -100.0, "Pointed Lines");
    group.addLines([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addPointSize(3.0);
  }
  {
    final group = _createBox(plot, 0.0, -200.0, "Points");
    group.addPoints([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addPointSize(3.0);
  }
  {
    final group = _createBox(plot, 0.0, -200.0, "Points");
    group.addPoints([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addPointSize(3.0);
  }
  {
    final group = _createBox(plot, 100.0, -200.0, "Polygon");
    group.addPolygon([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addFillColor(
        0.0, 0.0, 1.0, 0.5);
  }
  {
    final group = _createBox(plot, 200.0, -200.0, "Rectangle Group");
    group.addRectGroup(8.0, 4.0, [10, 20, 20, 40, 30, 60]);
    group.addRectGroup(8.0, 16.0, [30, 20, 40, 40, 50, 60])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 300.0, -200.0, "Rectangles");
    group.addRects([10, 20, 8.0, 4.0, 20, 40, 6.0, 6.0, 30, 60, 4.0, 8.0]);
    group.addRects([30, 20, 8.0, 16.0, 40, 40, 12.0, 12.0, 50, 60, 16.0, 8.0])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 0.0, -300.0, "Text");
    group.addText(10.0, 70.0, 4.0, "Small", true);
    group.addText(10.0, 60.0, 6.0, "Courier", true).addFont("Courier");
    group.addText(10.0, 50.0, 6.0, "Colored", true)
      ..addColor(1.0, 0.0, 0.0)
      ..addFillColor(0.0, 0.0, 1.0);
    group.addText(10.0, 30.0, 16.0, "Large", true)
      ..addColor(0.0, 0.0, 0.0)
      ..addFillColor(1.0, 1.0, 1.0, 0.5);
  }
  {
    final group = _createBox(plot, 100.0, -300.0, "Mouse Examples");
    group.addText(10.0, 70.0, 6.0, "Hold shift while clicking", true).addFillColor(0.0, 0.0, 0.0);
    group.addText(20.0, 60.0, 6.0, "to add red points.", true).addFillColor(0.0, 0.0, 0.0);
    group.addText(10.0, 40.0, 6.0, "Hold ctrl while clicking", true).addFillColor(0.0, 0.0, 0.0);
    group.addText(20.0, 30.0, 6.0, "to add red arrows.", true).addFillColor(0.0, 0.0, 0.0);
  }
  plot.updateBounds();
  plot.focusOnData();
  plot.mouseHandles.add(makePointAdder(plot));
  plot.mouseHandles.add(makeArrowAdder(plot));
  plot.mouseHandles.add(makeMouseCoords(plot));
  plot.mouseHandles.add(makeMouseCrosshairs(plot));
  plotterPlotFactory(plot);
}

Group _createBox(
  final Plotter plot,
  final double x,
  final double y,
  final String title,
) =>
    plot.addGroup()
      ..addOffset(x, y)
      ..addRects([0, 10, 90, 80])
      ..addRects([0, 90, 90, 10]).addFillColor(0.0, 0.0, 0.0, 0.75)
      ..addText(5, 92, 8, title, true)
      ..addColor(0.7, 0.7, 0.7)
      ..addFillColor(1.0, 1.0, 1.0);

// TODO fix arrow adder.
_ArrowAdder makeArrowAdder(
  final Plotter _plot,
) =>
    _ArrowAdder._(
      _plot.addLines([])
        ..addDirected(true)
        ..addColor(1.0, 0.0, 0.0),
    );

class _ArrowAdder implements PlotterMouseHandle {
  static const PlotterMouseButtonState _state = PlotterMouseButtonStateImpl(
    button: 0,
    altKey: true,
  );
  bool _mouseDown = false;
  final Lines _arrows;

  _ArrowAdder._(
    final this._arrows,
  );

  @override
  void mouseDown(
    final PlotterMouseEvent e,
  ) {
    if (e.state.equals(_state)) {
      _mouseDown = true;
      _arrows.add([e.vpx, e.vpy, e.vpx, e.vpy]);
      e.redraw = true;
    }
  }

  @override
  void mouseMove(
    final PlotterMouseEvent e,
  ) {
    if (_mouseDown) {
      final points = _arrows.get(_arrows.count - 1, 1);
      points[2] = e.vpx;
      points[3] = e.vpy;
      _arrows.set(_arrows.count - 1, points);
      e.redraw = true;
    }
  }

  @override
  void mouseUp(
    final PlotterMouseEvent e,
  ) {
    if (_mouseDown) {
      final points = _arrows.get(_arrows.count - 1, 1);
      points[2] = e.vpx;
      points[3] = e.vpy;
      _arrows.set(_arrows.count - 1, points);
      e.redraw = true;
      _mouseDown = false;
    }
  }
}

_PointAdder makePointAdder(
  final Plotter _plot,
) =>
    _PointAdder._(
      _plot.addPoints([])
        ..addPointSize(4.0)
        ..addColor(1.0, 0.0, 0.0),
    );

class _PointAdder implements PlotterMouseHandle {
  final Points _adderPoints;
  bool _mouseDown = false;

  static const PlotterMouseButtonStateImpl _state = PlotterMouseButtonStateImpl(
    button: 0,
    shiftKey: true,
  );

  _PointAdder._(
    final this._adderPoints,
  );

  @override
  void mouseDown(
    final PlotterMouseEvent e,
  ) {
    if (e.state.equals(_state)) {
      _mouseDown = true;
      _adderPoints.add([e.vpx, e.vpy]);
      e.redraw = true;
    }
  }

  @override
  void mouseMove(
    final PlotterMouseEvent e,
  ) {}

  @override
  void mouseUp(
    final PlotterMouseEvent e,
  ) {
    if (_mouseDown) {
      _mouseDown = false;
    }
  }
}
