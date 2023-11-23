import 'bounds.dart';
import 'mouse_button_state.dart';
import 'transformer.dart';

class PlotterMouseEventImpl implements PlotterMouseEvent {
  @override
  final Bounds window;
  @override
  final Transformer projection;
  @override
  final Transformer viewProj;
  @override
  final double x;
  @override
  final double y;
  @override
  final PlotterMouseButtonState state;
  @override
  bool redraw;

  PlotterMouseEventImpl(
    this.window,
    this.projection,
    this.viewProj,
    this.x,
    this.y,
    this.state,
  ) : redraw = false;

  @override
  double get px => projection.untransformX(x);

  @override
  double get py => projection.untransformY(window.ymax - y);

  @override
  double get vpx => viewProj.untransformX(x);

  @override
  double get vpy => viewProj.untransformY(window.ymax - y);
}

/// Mouse event arguments
abstract class PlotterMouseEvent {
  /// The bounds for the client viewport.
  Bounds get window;

  /// Transformer for converting from graphics view coordinate system to screen coordinate system.
  Transformer get projection;

  /// Transformer for converting from graphics base coordinate system to screen coordinate system.
  Transformer get viewProj;

  /// X location of the mouse.
  double get x;

  /// Y location of the mouse.
  double get y;

  /// The state of the mouse button.
  PlotterMouseButtonState get state;

  // TODO it would be great if this could be immutable or at least taken out of this and wrapped in a redraw mouse event.
  /// Indicates the plotter needs to be redrawn.
  abstract bool redraw;

  /// Gets the graphic coordinate system mouse x location.
  double get px;

  /// Gets the graphic coordinate system mouse y location.
  double get py;

  /// Gets the base coordinate system mouse x location.
  double get vpx;

  /// Gets the base coordinate system mouse y location.
  double get vpy;
}
