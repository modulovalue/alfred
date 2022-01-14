import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A line strip is a collection of x and y coordinates which draw lines
/// connecting all the coordinates to the coordinate prior to it.
/// The line strip is effected by [color](#color), [transformer](#transformer),
/// [point size](#point-size), and [directed line](#directed-line) attributes.
/// A point size above 1.0 will draw a point at each coordinate. If directed line
/// is set to true then each line will have an arrow head at the end.
///
/// A plotter item for drawing a line strip.
class LineStrip with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a line strip plotter item.
  LineStrip();

  @override
  int get coordCount => 2;

  List<double> get _x => coords[0];

  List<double> get _y => coords[1];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.actions.drawStrip(
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
