import '../plotter/plotter.dart';
import '../primitives/primitives.dart';
import '../primitives/primitives_impl.dart';
import 'plotter_item.dart';

/// An attribute for setting if the line is directed or not.
class DirectedLineAttrImpl implements DirectedLineAttr {
  /// Gets the directed line flag to apply for this attribute.
  @override
  bool directed;

  /// The last directed line flag in the renderer.
  bool _last;

  /// Creates a directed line flag attribute.
  DirectedLineAttrImpl([
    final this.directed = true,
  ]) : _last = false;

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = r.directedLines;
    r.directedLines = directed;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    r.directedLines = _last;
    _last = false;
  }
}

/// An attribute for setting the line color.
class ColorAttrImpl implements ColorAttr {
  @override
  Color color;

  /// The last color in the renderer.
  Color? _last;

  /// Creates a line color attribute.
  ColorAttrImpl(
    final this.color,
  );

  /// Creates a line color attribute.
  factory ColorAttrImpl.rgb(
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
    _last = r.color;
    r.color = color;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    r.color = _last!;
    _last = null;
  }
}

/// An attribute for setting the fill color.
class FillColorAttrImpl implements FillColorAttr {
  /// The color to set, or null for no fill.
  @override
  Color? color;

  /// The last color in the renderer.
  Color? _last;

  /// Creates a fill color attribute.
  FillColorAttrImpl([
    final this.color,
  ]);

  /// Creates a fill color attribute.
  factory FillColorAttrImpl.rgb(
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
    _last = r.fillColor;
    r.fillColor = color;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    r.fillColor = _last;
    _last = null;
  }
}

/// An attribute for setting the font.
class FontAttrImpl implements FontAttr {
  /// The font to set.
  @override
  String font;

  /// The last font in the renderer.
  String? _last;

  /// Creates a line font attribute.
  FontAttrImpl(
    final this.font,
  );

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = r.font;
    r.font = font;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    r.font = _last;
    _last = null;
  }
}

/// An attribute for setting the point size.
class PointSizeAttrImpl implements PointSizeAttr {
  /// The size of the point to set.
  @override
  double size;

  /// The previous size of the point to store.
  double _last;

  /// Creates a new point size attribute.
  PointSizeAttrImpl(
    final this.size,
  ) : _last = 0.0;

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = r.pointSize;
    r.pointSize = size;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) =>
      r.pointSize = _last;
}

/// A translation attribute for setting a special translation on some data.
class TransAttrImpl implements TransAttr {
  /// The transformation to set.
  @override
  final Transformer? transform;

  /// True indicates the transformation should be multiplied with
  /// the current transformation at that time, false to just set
  /// the transformation overriding the current one at that time.
  ///
  /// The multiplier indicator.
  /// True indicates the transformation should be multiplied with
  /// the current transformation at that time, false to just set
  /// the transformation overriding the current one at that time.
  @override
  final bool multiply;

  /// The previous transformation.
  Transformer? _last;

  /// Creates a new transformation attribute.
  TransAttrImpl(
    final this.transform,
  )   : multiply = true,
        _last = null;

  /// Applies this transformation attribute, similar to pushing but while calculating the data bounds.
  @override
  Transformer apply(
    final Transformer trans,
  ) {
    _last = null;
    final _transform = transform;
    if (_transform != null) {
      _last = trans;
      if (multiply) {
        return trans.mul(_transform);
      } else {
        return _transform;
      }
    }
    return trans;
  }

  /// Un-applies this transformation attribute, similar as popping but while calculating the data bounds.
  @override
  Transformer unapply(
    Transformer trans,
  ) {
    final __last = _last;
    if (__last != null) {
      // ignore: parameter_assignments
      trans = __last;
      _last = null;
    }
    return trans;
  }

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = null;
    final _transform = transform;
    if (_transform != null) {
      final rTransform = r.transform;
      _last = rTransform;
      if (multiply) {
        r.transform = rTransform!.mul(_transform);
      } else {
        r.transform = _transform;
      }
    }
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    final __last = _last;
    if (__last != null) {
      r.transform = __last;
      _last = null;
    }
  }
}

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
      final int count = attributes.length;
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

/// A plotter item for coordinate based items.
/// TODO this is bad. be explicit about the size of coordinates.
mixin BasicCoordsMixin implements PlotterItem {
  /// The x coordinates for the points.
  List<List<double>>? __coords;

  List<List<double>> get coords => __coords ??= () {
        final _coords = <List<double>>[];
        for (int i = 0; i < coordCount; i++) {
          _coords.add(<double>[]);
        }
        return _coords;
      }();

  int get coordCount;

  // Clears all the items.
  void clear() {
    for (int i = 0; i < coords.length; i++) {
      coords[i].clear();
    }
  }

  /// Adds values to the item.
  void add(
    final List<double> val,
  ) {
    final count = val.length;
    for (int i = 0; i < count; i += coords.length) {
      for (int j = 0; j < coords.length; j++) {
        coords[j].add(val[i + j]);
      }
    }
  }

  /// Sets the value to the item.
  void set(
    final int index,
    final List<double> val,
  ) {
    final count = val.length;
    final localCoords = <List<double>>[];
    for (int i = 0; i < this.coords.length; i++) {
      localCoords.add(<double>[]);
    }
    for (int i = 0; i < count; i += this.coords.length) {
      for (int j = 0; j < this.coords.length; j++) {
        localCoords[j].add(val[i + j]);
      }
    }
    for (int i = 0; i < this.coords.length; i++) {
      this.coords[i].setAll(index, this.coords[i]);
    }
  }

  /// Gets values from the item.
  List<double> get(
    final int index,
    final int count,
  ) {
    final val = <double>[];
    for (int i = 0; i < count; i++) {
      for (int j = 0; j < coords.length; j++) {
        val.add(coords[j][index + i]);
      }
    }
    return val;
  }

  /// The number of coordinate.
  int get count => coords[0].length;
}
