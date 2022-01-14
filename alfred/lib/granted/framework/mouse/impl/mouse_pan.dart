import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../basic/transformer.dart';
import '../mouse_handle.dart';

PlotterMousePan makeMousePan(
  final Transformer plotTransformerView,
  final void Function(double, double) setViewOffset,
  final PlotterMouseButtonState _state,
) =>
    PlotterMousePan(
      plotTransformerView,
      setViewOffset,
      true,
      _state,
      0.0,
      0.0,
      0.0,
      0.0,
      false,
    );

/// A mouse handler for translating the viewport.
class PlotterMousePan implements PlotterMouseHandle {
  /// The plotter this mouse handle is changing.
  final Transformer _plotTransformerView;
  final void Function(double, double) setViewOffset;

  /// Indicates if mouse panning is enabled or not.
  bool enabled;

  /// The mouse button pressed.
  final PlotterMouseButtonState _state;

  /// The initial mouse x location on a mouse pressed.
  double _msx;

  /// The initial mouse y location on a mouse pressed.
  double _msy;

  /// The initial view x offset on a mouse pressed.
  double _viewx;

  /// The initial view y offset on a mouse pressed.
  double _viewy;

  /// True indicates a mouse move has been started.
  bool _moveStarted;

  PlotterMousePan(
    this._plotTransformerView,
    this.setViewOffset,
    this.enabled,
    this._state,
    this._msx,
    this._msy,
    this._viewx,
    this._viewy,
    this._moveStarted,
  );

  /// handles mouse down.
  @override
  void mouseDown(
    final PlotterMouseEvent e,
  ) {
    if (enabled && e.state.equals(_state)) {
      _viewx = _plotTransformerView.dx;
      _viewy = _plotTransformerView.dy;
      _msx = e.x;
      _msy = e.y;
      _moveStarted = true;
    }
  }

  /// Gets the change in the view x location.
  double _viewDX(
    final PlotterMouseEvent e,
  ) =>
      _viewx + (e.x - _msx) / e.projection.xScalar;

  /// Gets the change in the view y location.
  double _viewDY(
    final PlotterMouseEvent e,
  ) =>
      _viewy - (e.y - _msy) / e.projection.yScalar;

  /// handles mouse moved.
  @override
  void mouseMove(
    final PlotterMouseEvent e,
  ) {
    if (_moveStarted) {
      setViewOffset(_viewDX(e), _viewDY(e));
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(
    final PlotterMouseEvent e,
  ) {
    if (_moveStarted) {
      setViewOffset(_viewDX(e), _viewDY(e));
      _moveStarted = false;
      e.redraw = true;
    }
  }
}
