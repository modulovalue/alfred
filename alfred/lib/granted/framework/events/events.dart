import '../primitives/primitives.dart';

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

/// Mouse button state.
abstract class PlotterMouseButtonState {
  /// The mouse button pressed.
  int get button;

  /// Indicates if the shift key is pressed.
  bool get shiftKey;

  /// Indicates if the control key is pressed.
  bool get ctrlKey;

  /// Indicates if the alt key is pressed.
  bool get altKey;

  /// Determines if the given state is the same as this state.
  bool equals(
    final PlotterMouseButtonState other,
  );
}
