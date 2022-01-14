import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A rectangle group is a collection of rectangles which all have the same width and height.
/// Creating the group will require the width and height to use and the list of
/// left and top points. The rectangle group is effected by [color](#color),
/// [fill color](#fill-color), and [transformer](#transformer) attributes.
///
/// A plotter item for drawing rectangles.
class RectangleGroup with PlotterItemMixin, BasicCoordsMixin {
  /// The width of all the rectangles.
  double width;

  /// The height of all the rectangles.
  double height;

  /// Creates a new rectangle plotter item.
  RectangleGroup(
    final this.width,
    final this.height,
  );

  @override
  int get coordCount => 2;

  List<double> get _x => coords[0];

  List<double> get _y => coords[1];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.actions.drawRectSet(
        _x,
        _y,
        width,
        height,
      );

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_x[i], _y[i]);
    }
    if (!b.isEmpty) {
      b.expand(b.xmax + width, b.ymax + height);
    }
    return trans.transform(b);
  }
}
