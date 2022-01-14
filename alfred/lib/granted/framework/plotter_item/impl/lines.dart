import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A set of lines is a collection of x and y coordinates which draw lines
/// connecting every other line to the coordinates to the coordinate prior to it.
/// This means each group of four `double`s defines a single line.
/// The lines are effected by [color](#color), [transformer](#transformer),
/// [point size](#point-size), and [directed line](#directed-line) attributes.
/// A point size above 1.0 will draw a point at each coordinate. If directed line
/// is set to true then each line will have an arrow head at the end.
///
/// A plotter item for drawing lines.
class Lines with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a new line plotter item.
  Lines();

  @override
  int get coordCount => 4;

  List<double> get _x1 => coords[0];

  List<double> get _y1 => coords[1];

  List<double> get _x2 => coords[2];

  List<double> get _y2 => coords[3];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.actions.drawLines(
        _x1,
        _y1,
        _x2,
        _y2,
      );

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_x1[i], _y1[i]);
      b.expand(_x2[i], _y2[i]);
    }
    return trans.transform(b);
  }
}
