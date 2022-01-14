import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../coords_mixin.dart';

/// A list circles which all have the different radii.
/// Creating the list will require the list of x and y center points
/// and each radii. The circles are effected by [color](#color),
/// [fill color](#fill-color), and [transformer](#transformer) attributes.
///
/// A plotter item for drawing ellipses.
/// The coordinates are the x and y center points and radii.
class Circles with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a new ellipse plotter item.
  Circles();

  @override
  int get coordCount => 3;

  List<double> get _centerXs => coords[0];

  List<double> get _centerYs => coords[1];

  List<double> get _radii => coords[2];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.actions.drawCircs(
        _centerXs,
        _centerYs,
        _radii,
      );

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      final r = _radii[i];
      final x = _centerXs[i];
      final y = _centerYs[i];
      b.expand(x - r, y - r);
      b.expand(x + r, y + r);
    }
    return trans.transform(b);
  }
}
