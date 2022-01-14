import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A list rectangles which all have the different width and height.
/// Creating the list will require the list of left and top points
/// and each width and height. The rectangles are effected by [color](#color),
/// [fill color](#fill-color), and [transformer](#transformer) attributes.
///
/// A plotter item for drawing rectangles.
class Rectangles with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a new rectangle plotter item.
  Rectangles();

  @override
  int get coordCount => 4;

  List<double> get _lefts => coords[0];

  List<double> get _tops => coords[1];

  List<double> get _widths => coords[2];

  List<double> get _heights => coords[3];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.actions.drawRects(
        _lefts,
        _tops,
        _widths,
        _heights,
      );

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      final x = _lefts[i];
      final y = _tops[i];
      b.expand(x, y);
      b.expand(x + _widths[i], y + _heights[i]);
    }
    return trans.transform(b);
  }
}
