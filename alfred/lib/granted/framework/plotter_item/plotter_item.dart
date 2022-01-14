import '../attributes/impl/color.dart';
import '../attributes/impl/directed_line.dart';
import '../attributes/impl/fill_color.dart';
import '../attributes/impl/font.dart';
import '../attributes/impl/point_size.dart';
import '../attributes/impl/trans.dart';
import '../attributes/plotter_attribute.dart';
import '../basic/bounds.dart';
import '../basic/transformer.dart';
import '../render/interface.dart';

/// The items are different types of data to draw.
/// All the items extends a [`PlotterItem`](./lib/src/plotter/plotter_item.dart).
/// Items can have zero or more [attributes](#attributes) applied to it which
/// set the color, size, etc. Each item also provides methods to easily
/// add attributes. An item can be enabled or disabled for easily showing or hiding
/// the item.
///
/// The abstract for all plotter items.
abstract class PlotterItem {
  /// The set of attributes for this item.
  List<PlotterAttribute> get attributes;

  /// Indicates if this item should be plotted or not.
  abstract bool enabled;

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
