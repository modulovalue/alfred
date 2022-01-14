import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A polygon is a collection of x and y coordinates which draw a polygon which
/// may be filled. The polygon is effected by [color](#color),
/// [fill color](#fill-color), [transformer](#transformer),
/// [point size](#point-size), and [directed line](#directed-line) attributes.
/// A point size above 1.0 will draw a point at each coordinate. If directed line
/// is set to true then each line will have an arrow head at the end.
///
/// The plotter item for plotting a polygon.
class Polygon with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a polygon plotter item.
  Polygon();

  @override
  int get coordCount => 2;

  List<double> get _x => coords[0];

  List<double> get _y => coords[1];

  /// Called when the polygon is to be draw.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.actions.drawPoly(
        _x,
        _y,
      );

  /// Gets the bounds for the polygon.
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
