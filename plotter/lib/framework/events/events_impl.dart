import '../primitives/primitives.dart';
import 'events.dart';

class MouseButtonStateImpl implements MouseButtonState {
  @override
  final int button;
  @override
  final bool shiftKey;
  @override
  final bool ctrlKey;
  @override
  final bool altKey;

  const MouseButtonStateImpl({
    required final this.button,
    final this.shiftKey = false,
    final this.ctrlKey = false,
    final this.altKey = false,
  });

  @override
  bool equals(
    final MouseButtonState other,
  ) =>
      (button == other.button) &&
      (shiftKey == other.shiftKey) &&
      (ctrlKey == other.ctrlKey) &&
      (altKey == other.altKey);
}

class MouseEventImpl implements MouseEvent {
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
  final MouseButtonState state;
  @override
  bool redraw;

  MouseEventImpl(
    final this.window,
    final this.projection,
    final this.viewProj,
    final this.x,
    final this.y,
    final this.state,
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
