import '../events/events.dart';
import '../plotter/plotter_impl.dart';
import '../primitives/primitives.dart';
import 'mouse_handle.dart';

MouseCoords makeMouseCoords(
  final Plotter plotter,
) {
  final _text = plotter.addText(0.0, 0.0, 12.0, "");
  return MouseCoords(
    plotter,
    _text,
  );
}

/// A mouse handler for outputting coordinates of the mouse, typically to be displayed.
class MouseCoords implements PlotterMouseHandle {
  /// The plotter this mouse handle is changing.
  final Plotter _plot;

  /// The lines for the crosshairs.
  final Text _text;

  const MouseCoords(
    final this._plot,
    final this._text,
  );

  /// handles mouse down.
  @override
  void mouseDown(
    final MouseEvent e,
  ) {}

  /// handles mouse moved.
  @override
  void mouseMove(
    final MouseEvent e,
  ) {
    final x = _plot.view.untransformX(e.px).toStringAsPrecision(3);
    final y = _plot.view.untransformY(e.py).toStringAsPrecision(3);
    _text
      ..x = (e.x + 3)
      ..y = (e.y - 3)
      ..text = x.toString() + ", " + y.toString();
    e.redraw = true;
  }

  /// handles mouse up.
  @override
  void mouseUp(
    final MouseEvent e,
  ) {}
}

MouseCrosshairs makeMouseCrosshairs(
  final Plotter plotter,
) {
  final _lines = plotter.addLines([])..addColor(1.0, 0.0, 0.0);
  return MouseCrosshairs(
    plotter,
    _lines,
  );
}

/// Adds crosshairs at the mouse location.
class MouseCrosshairs implements PlotterMouseHandle {
  /// The plotter this mouse handle is changing.
  final Plotter _plot;

  /// The lines for the crosshairs.
  final Lines _lines;

  /// Creates a new mouse crosshairs.
  const MouseCrosshairs(
    final this._plot,
    final this._lines,
  );

  /// Implements interface but has no effect.
  @override
  void mouseDown(
    final MouseEvent e,
  ) {}

  /// Handles mouse movement to update the crosshairs.
  @override
  void mouseMove(
    final MouseEvent e,
  ) {
    final trans = e.projection.mul(_plot.view);
    final x = trans.untransformX(e.x);
    final y = trans.untransformY(e.window.ymax - e.y);
    final d = x - trans.untransformX(e.x + 10.0);
    _lines.clear();
    _lines.add([x - d, y, x + d, y, x, y - d, x, y + d]);
    e.redraw = true;
  }

  /// Implements interface but has no effect.
  @override
  void mouseUp(
    final MouseEvent e,
  ) {}
}

MousePan makeMousePan(
  final Transformer plotTransformerView,
  final void Function(double, double) setViewOffset,
  final MouseButtonState _state,
) =>
    MousePan(
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
class MousePan implements PlotterMouseHandle {
  /// The plotter this mouse handle is changing.
  final Transformer _plotTransformerView;
  final void Function(double, double) setViewOffset;

  /// Indicates if mouse panning is enabled or not.
  bool enabled;

  /// The mouse button pressed.
  final MouseButtonState _state;

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

  MousePan(
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
    final MouseEvent e,
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
    final MouseEvent e,
  ) =>
      _viewx + (e.x - _msx) / e.projection.xScalar;

  /// Gets the change in the view y location.
  double _viewDY(
    final MouseEvent e,
  ) =>
      _viewy - (e.y - _msy) / e.projection.yScalar;

  /// handles mouse moved.
  @override
  void mouseMove(
    final MouseEvent e,
  ) {
    if (_moveStarted) {
      setViewOffset(_viewDX(e), _viewDY(e));
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(
    final MouseEvent e,
  ) {
    if (_moveStarted) {
      setViewOffset(_viewDX(e), _viewDY(e));
      _moveStarted = false;
      e.redraw = true;
    }
  }
}
