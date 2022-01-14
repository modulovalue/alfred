class PlotterMouseButtonStateImpl implements PlotterMouseButtonState {
  @override
  final int button;
  @override
  final bool shiftKey;
  @override
  final bool ctrlKey;
  @override
  final bool altKey;

  const PlotterMouseButtonStateImpl({
    required final this.button,
    final this.shiftKey = false,
    final this.ctrlKey = false,
    final this.altKey = false,
  });

  @override
  bool equals(
    final PlotterMouseButtonState other,
  ) =>
      (button == other.button) &&
      (shiftKey == other.shiftKey) &&
      (ctrlKey == other.ctrlKey) &&
      (altKey == other.altKey);
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
