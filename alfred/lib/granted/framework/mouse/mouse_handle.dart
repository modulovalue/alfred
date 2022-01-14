import '../basic/mouse_event.dart';

/// A mouse handler for managing user input.
abstract class PlotterMouseHandle {
  /// handles mouse down.
  void mouseDown(
    final PlotterMouseEvent e,
  );

  /// handles mouse moved.
  void mouseMove(
    final PlotterMouseEvent e,
  );

  /// handles mouse up.
  void mouseUp(
    final PlotterMouseEvent e,
  );
}
