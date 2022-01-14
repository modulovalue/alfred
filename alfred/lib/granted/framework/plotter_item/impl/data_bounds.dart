import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';

/// A plotter item to draw the data bounds.
class DataBounds with PlotterItemMixin {
  /// Creates a new data bound plotter item.
  /// Adds a default color attribute.
  DataBounds() {
    addColor(1.0, 0.75, 0.75);
  }

  /// Called to draw to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) {
    final bound = r.state.dataSetBounds;
    r.actions.drawRect(
      bound.xmin,
      bound.ymin,
      bound.xmax,
      bound.ymax,
    );
  }

  /// Get the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) =>
      BoundsImpl.empty();
}
