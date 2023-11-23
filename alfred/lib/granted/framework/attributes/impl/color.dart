import '../../basic/color.dart';
import '../../render/interface.dart';
import '../plotter_attribute.dart';

/// The color attribute sets the stroke or outline color of the items.
/// It is an red, green, blue, with an optional alpha color between 0.0 and 1.0.
/// This has an effect on all items.
///
/// An attribute for setting the line color.
class ColorAttrImpl implements ColorAttr {
  @override
  Color color;

  /// The last color in the renderer.
  Color? _last;

  /// Creates a line color attribute.
  ColorAttrImpl(
    this.color,
  );

  /// Creates a line color attribute.
  static ColorAttrImpl rgb(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]) =>
      ColorAttrImpl(
        ColorImpl(red, green, blue, alpha),
      );

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = r.state.color;
    r.state.color = color;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    r.state.color = _last!;
    _last = null;
  }
}

/// An attribute for setting the line color.
abstract class ColorAttr implements PlotterAttribute {
  /// The color to apply for this attribute.
  abstract Color color;
}
