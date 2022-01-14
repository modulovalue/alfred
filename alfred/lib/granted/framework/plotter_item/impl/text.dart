import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';

/// A text item is a single line of text. The text has an x and y location
/// where the x is the left edge and the y is the baseline of the text.
/// The text can be set to auto-scale with the plot or to stay fixed on
/// the string with the `scale` flag.
/// The text is effected by [font](#font), [color](#color),
/// [fill color](#fill-color), and [transformer](#transformer) attributes.
///
/// A plotter item for points.
class Text with PlotterItemMixin {
  // FUTURE: Add alignment (left, right, center)
  // FUTURE: Add an optional width for wrapping, alignment, and justification.

  /// The x location of the left of the text.
  double x;

  /// The y location of the bottom of the text.
  double y;

  /// The size of the text in pixels.
  double size;

  /// The text to draw.
  String text;

  /// Indicates if the text should scale and track the graph.
  bool scale;

  /// Creates a points plotter item.
  Text([
    final this.x = 0.0,
    final this.y = 0.0,
    final this.size = 10.0,
    final this.text = "",
    final this.scale = false,
  ]);

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) {
    if (text.isNotEmpty) {
      r.actions.drawText(
        x,
        y,
        size,
        text,
        scale,
      );
    }
  }

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    if (text.isNotEmpty) {
      b.expand(x, y);
    }
    return trans.transform(b);
  }
}
