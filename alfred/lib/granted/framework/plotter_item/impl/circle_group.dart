import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A circle group is a collection of circles which all have the same radii.
/// Creating the group will require the radii to use and the list of
/// x and y center points. The circle group is effected by [color](#color),
/// [fill color](#fill-color), and [transformer](#transformer) attributes.
///
/// A plotter item for drawing circles.
/// The points are the x and y center points.
class CircleGroup with PlotterItemMixin, BasicCoordsMixin {
  /// The radius of all the circles.
  double radius;

  /// Creates a new circle plotter item.
  CircleGroup(
    this.radius,
  );

  @override
  int get coordCount => 2;

  List<double> get _centerXs => coords[0];

  List<double> get _centerYs => coords[1];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.actions.drawCircSet(
        _centerXs,
        _centerYs,
        radius,
      );

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_centerXs[i], _centerYs[i]);
    }
    if (!b.isEmpty) {
      b.expand(b.xmin - radius, b.ymin - radius);
      b.expand(b.xmax + radius, b.ymax + radius);
    }
    return trans.transform(b);
  }
}
