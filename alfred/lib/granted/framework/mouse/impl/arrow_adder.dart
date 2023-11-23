import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/lines.dart';
import '../../plotter_item/impl/plotter.dart';
import '../mouse_handle.dart';

// TODO fix arrow adder.
ArrowAdder makeArrowAdder(
  final Plotter _plot,
) =>
    ArrowAdder._(
      _plot.addLines([])
        ..addDirected(true)
        ..addColor(1.0, 0.0, 0.0),
    );

class ArrowAdder implements PlotterMouseHandle {
  static const PlotterMouseButtonState _state = PlotterMouseButtonStateImpl(
    button: 0,
    altKey: true,
  );
  bool _mouseDown = false;
  final Lines _arrows;

  ArrowAdder._(
    this._arrows,
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
