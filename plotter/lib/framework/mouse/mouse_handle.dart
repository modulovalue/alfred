import '../events/events.dart';

/// A mouse handler for managing user input.
abstract class PlotterMouseHandle {
  /// handles mouse down.
  void mouseDown(
    final MouseEvent e,
  );

  /// handles mouse moved.
  void mouseMove(
    final MouseEvent e,
  );

  /// handles mouse up.
  void mouseUp(
    final MouseEvent e,
  );
}
