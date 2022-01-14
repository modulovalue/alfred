import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A list ellipses which all have the different x and y radii.
/// Creating the list will require the list of x and y center points
/// and each x and y radii. The ellipses are effected by [color](#color),
/// [fill color](#fill-color), and [transformer](#transformer) attributes.
///
/// A plotter item for drawing ellipses.
class Ellipses with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a new ellipse plotter item.
  Ellipses();

  @override
  int get coordCount => 4;

  List<double> get _centerXs => coords[0];

  List<double> get _centerYs => coords[1];

  List<double> get _xRadii => coords[2];

  List<double> get _yRadii => coords[3];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.actions.drawEllipse(
        _centerXs,
        _centerYs,
        _xRadii,
        _yRadii,
      );

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      final xr = _xRadii[i];
      final yr = _yRadii[i];
      final x = _centerXs[i];
      final y = _centerYs[i];
      b.expand(x - xr, y - yr);
      b.expand(x + xr, y + yr);
    }
    return trans.transform(b);
  }
}
