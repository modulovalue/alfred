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
import 'plotter_item.dart';

/// The abstract for all plotter items.
mixin PlotterItemMixin implements PlotterItem {
  /// The set of attributes for this item.
  @override
  final List<PlotterAttribute> attributes = [];

  /// Indicates if this item should be plotted or not.
  @override
  bool enabled = true;

  /// Adds an attribute to this item.
  @override
  void addAttr(
    final PlotterAttribute attr,
  ) =>
      attributes.add(attr);

  /// Adds a transformation to this item.
  @override
  TransAttr addTrans(
    final double xScalar,
    final double yScalar,
    final double dx,
    final double dy,
  ) {
    final attr = TransAttrImpl(
      TransformerImpl(
        xScalar,
        yScalar,
        dx,
        dy,
      ),
    );
    addAttr(attr);
    return attr;
  }

  /// Adds an offset to this item.
  @override
  TransAttr addOffset(
    final double dx,
    final double dy,
  ) =>
      addTrans(
        1.0,
        1.0,
        dx,
        dy,
      );

  /// Adds a scalar to this item.
  @override
  TransAttr addScalar(
    final double xScalar,
    final double yScalar,
  ) =>
      addTrans(
        xScalar,
        yScalar,
        0.0,
        0.0,
      );

  /// Adds a color attribute to this item.
  @override
  ColorAttr addColor(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]) {
    final attr = ColorAttrImpl.rgb(red, green, blue, alpha);
    addAttr(attr);
    return attr;
  }

  /// Adds a point size attribute to this item.
  @override
  PointSizeAttr addPointSize(
    final double size,
  ) {
    final attr = PointSizeAttrImpl(size);
    addAttr(attr);
    return attr;
  }

  /// Adds a filled attribute to this item.
  @override
  FillColorAttr addFillColor(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]) {
    final attr = FillColorAttrImpl.rgb(red, green, blue, alpha);
    addAttr(attr);
    return attr;
  }

  /// Adds a filled attribute indicating no fill color to this item.
  @override
  FillColorAttr addNoFillColor() {
    final attr = FillColorAttrImpl(null);
    addAttr(attr);
    return attr;
  }

  /// Adds a font attribute to this item.
  @override
  FontAttr addFont(
    final String font,
  ) {
    final attr = FontAttrImpl(font);
    addAttr(attr);
    return attr;
  }

  /// Adds a directed line attribute to this item.
  @override
  DirectedLineAttr addDirected(
    final bool directed,
  ) {
    final attr = DirectedLineAttrImpl(directed);
    addAttr(attr);
    return attr;
  }

  /// Draws the item to the panel.
  @override
  void draw(
    final PlotterRenderer r,
  ) {
    if (enabled) {
      final count = attributes.length;
      for (int i = 0; i < count; i++) {
        attributes[i].pushAttr(r);
      }
      onDraw(r);
      for (int i = count - 1; i >= 0; i--) {
        attributes[i].popAttr(r);
      }
    } else {
      return;
    }
  }

  /// Gets the bounds for this item.
  @override
  Bounds getBounds(
    Transformer trans,
  ) {
    if (enabled) {
      final count = attributes.length;
      for (int i = 0; i < count; i++) {
        final attr = attributes[i];
        if (attr is TransAttr) {
          // ignore: parameter_assignments
          trans = attr.apply(trans);
        }
      }
      final b = onGetBounds(trans);
      for (int i = count - 1; i >= 0; i--) {
        final attr = attributes[i];
        if (attr is TransAttr) {
          // ignore: parameter_assignments
          trans = attr.unapply(trans);
        }
      }
      return b;
    } else {
      return BoundsImpl.empty();
    }
  }

  /// The abstract method to draw to the panel.
  void onDraw(
    final PlotterRenderer r,
  );

  /// The abstract method for getting the bounds for the item.
  Bounds onGetBounds(
    final Transformer trans,
  );
}
