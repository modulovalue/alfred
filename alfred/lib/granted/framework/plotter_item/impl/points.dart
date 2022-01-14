import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A set of points is a collection of x and y coordinates for each point.
/// The points are effected by [color](#color), [transformer](#transformer),
/// and [point size](#point-size) attributes.
///
/// A plotter item for points.
class Points with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a points plotter item.
  Points();

  @override
  int get coordCount => 2;

  List<double> get _x => coords[0];

  List<double> get _y => coords[1];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.actions.drawPoints(
        _x,
        _y,
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
    return trans.transform(b);
  }
}
