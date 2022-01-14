import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/plotter.dart';
import '../../plotter_item/impl/points.dart';
import '../mouse_handle.dart';

PointAdder makePointAdder(
  final Plotter plot,
) =>
    PointAdder._(
      plot.addPoints([])
        ..addPointSize(4.0)
        ..addColor(1.0, 0.0, 0.0),
    );

class PointAdder implements PlotterMouseHandle {
  final Points _adderPoints;
  bool _mouseDown = false;

  static const PlotterMouseButtonStateImpl _state = PlotterMouseButtonStateImpl(
    button: 0,
    shiftKey: true,
  );

  PointAdder._(
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
