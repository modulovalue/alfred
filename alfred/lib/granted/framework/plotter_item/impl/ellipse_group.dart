import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A ellipse group is a collection of ellipses which all have the same x and y radii.
/// Creating the group will require the x and y radii to use and the list of
/// x and y center points. The ellipse group is effected by [color](#color),
/// [fill color](#fill-color), and [transformer](#transformer) attributes.
///
/// A plotter item for drawing ellipses.{
/// The points are the top-left corner of the ellipses.
class EllipseGroup with PlotterItemMixin, BasicCoordsMixin {
  /// The x radius of all the ellipses.
  double xRadii;

  /// The y radius of all the ellipses.
  double yRadii;

  /// Creates a new ellipse plotter item.
  EllipseGroup(
    final this.xRadii,
    final this.yRadii,
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
      r.actions.drawEllipseSet(
        _centerXs,
        _centerYs,
        xRadii,
        yRadii,
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
      b.expand(b.xmin - xRadii, b.ymin - yRadii);
      b.expand(b.xmax + xRadii, b.ymax + yRadii);
    }
    return trans.transform(b);
  }
}
