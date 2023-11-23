import '../../basic/color.dart';
import '../../render/interface.dart';
import '../plotter_attribute.dart';

/// The fill color attribute sets the fill color of an item which can be filled.
/// This effects [Circle Group](#circle-group), [Circles](#circles), [Ellipse Group](#ellipse-group),
/// [Ellipses](#ellipses), [Polygon](#polygon), [Rectangle Group](#rectangle-group),
/// [Rectangles](#rectangles), and [Text](#text).
///
/// An attribute for setting the fill color.
class FillColorAttrImpl implements FillColorAttr {
  /// The color to set, or null for no fill.
  @override
  Color? color;

  /// The last color in the renderer.
  Color? _last;

  /// Creates a fill color attribute.
  FillColorAttrImpl([
    this.color,
  ]);

  /// Creates a fill color attribute.
  static FillColorAttrImpl rgb(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]) =>
      FillColorAttrImpl(
        ColorImpl(
          red,
          green,
          blue,
          alpha,
        ),
      );

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = r.state.fillColor;
    r.state.fillColor = color;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    r.state.fillColor = _last;
    _last = null;
  }
}

/// An attribute for setting the fill color.
abstract class FillColorAttr implements PlotterAttribute {
  /// The color to set, or null for no fill.
  abstract Color? color;
}
