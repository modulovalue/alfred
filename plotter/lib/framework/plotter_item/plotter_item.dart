import '../primitives/primitives.dart';
import '../render/interface.dart';

/// TODO these are not items, these are attributes.
/// The interface for all attributes.
abstract class PlotterAttribute {
  /// Pushes the attribute to the renderer.
  void pushAttr(
    final PlotterRenderer r,
  );

  /// Pops the attribute from the renderer.
  void popAttr(
    final PlotterRenderer r,
  );
}

/// A translation attribute for setting a special translation on some data.
abstract class TransAttr implements PlotterAttribute {
  /// The transformation to set.
  Transformer? get transform;

  /// True indicates the transformation should be multiplied with
  /// the current transformation at that time, false to just set
  /// the transformation overriding the current one at that time.
  ///
  /// The multiplier indicator.
  /// True indicates the transformation should be multiplied with
  /// the current transformation at that time, false to just set
  /// the transformation overriding the current one at that time.
  bool get multiply;

  /// Applies this transformation attribute, similar to pushing but while calculating the data bounds.
  Transformer apply(
    final Transformer trans,
  );

  /// Un-applies this transformation attribute, similar as popping but while calculating the data bounds.
  Transformer unapply(
    Transformer trans,
  );
}

/// An attribute for setting the line color.
abstract class ColorAttr implements PlotterAttribute {
  /// The color to apply for this attribute.
  Color get color;

  set color(
    final Color color,
  );
}

/// An attribute for setting the fill color.
abstract class FillColorAttr implements PlotterAttribute {
  /// The color to set, or null for no fill.
  Color? get color;

  set color(
    final Color? color,
  );
}

/// An attribute for setting the point size.
abstract class PointSizeAttr implements PlotterAttribute {
  /// The size of the point to set.
  double get size;

  set size(
    final double size,
  );
}

/// An attribute for setting if the line is directed or not.
abstract class DirectedLineAttr implements PlotterAttribute {
  /// Gets the directed line flag to apply for this attribute.
  bool get directed;

  set directed(
    final bool directed,
  );
}

/// An attribute for setting the font.
abstract class FontAttr implements PlotterAttribute {
  /// The font to set.
  String get font;

  set font(
    final String font,
  );
}

/// The abstract for all plotter items.
abstract class PlotterItem {
  /// The set of attributes for this item.
  List<PlotterAttribute> get attributes;

  /// Indicates if this item should be plotted or not.
  bool get enabled;

  set enabled(
    final bool enabled,
  );

  /// Adds an attribute to this item.
  void addAttr(
    final PlotterAttribute attr,
  );

  /// Adds a transformation to this item.
  TransAttr addTrans(
    final double xScalar,
    final double yScalar,
    final double dx,
    final double dy,
  );

  /// Adds an offset to this item.
  TransAttr addOffset(
    final double dx,
    final double dy,
  );

  /// Adds a scalar to this item.
  TransAttr addScalar(
    final double xScalar,
    final double yScalar,
  );

  /// Adds a color attribute to this item.
  ColorAttr addColor(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]);

  /// Adds a point size attribute to this item.
  PointSizeAttr addPointSize(
    final double size,
  );

  /// Adds a filled attribute to this item.
  FillColorAttr addFillColor(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]);

  /// Adds a filled attribute indicating no fill color to this item.
  FillColorAttr addNoFillColor();

  /// Adds a font attribute to this item.
  FontAttr addFont(
    final String font,
  );

  /// Adds a directed line attribute to this item.
  DirectedLineAttr addDirected(
    final bool directed,
  );

  /// Draws the item to the panel.
  void draw(
    final PlotterRenderer r,
  );

  /// Gets the bounds for this item.
  Bounds getBounds(
    final Transformer trans,
  );
}
