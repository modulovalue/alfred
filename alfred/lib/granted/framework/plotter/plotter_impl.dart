import 'dart:math';

import '../events/events.dart';
import '../events/events_impl.dart';
import '../mouse/mouse_handle.dart';
import '../mouse/mouse_handle_impl.dart';
import '../plotter_item/plotter_item.dart';
import '../plotter_item/plotter_item_impl.dart';
import '../primitives/primitives.dart';
import '../primitives/primitives_impl.dart';
import '../render/interface.dart';

/// TODO move all below into plotter_item and split them apart.
/// TODO move readme doc into items.
Plotter makePlotter([
  final String label = "",
]) {
  final bounds = BoundsImpl.empty();
  final view = TransformerImpl.identity();
  final mouseHandles = <PlotterMouseHandle>[];
  final plotter = Plotter(
    bounds,
    view,
    mouseHandles,
    label,
  );
  final mousePan = makeMousePan(
    view,
    plotter.setViewOffset,
    const PlotterMouseButtonStateImpl(button: 0),
  );
  mouseHandles.add(mousePan);
  final grid = Grid();
  final dataBounds = DataBounds();
  plotter.addItems([grid, dataBounds]);
  plotter.addColor(0.0, 0.0, 0.0);
  return plotter;
}

/// The plotter to quickly draw 2D plots.
/// Great for reviewing data and debugging 2D algorithms.
///
/// Example:
///   Plotter plot = new Plotter();
///   plot.addLines([12.1, 10.1, 10.9, 10.1,
///                  10.9, 11.1,  6.9, 10.9,
///                  10.9, 10.9, 10.1, 13.9,
///                  10.1,  4.9, 10.1, 10.1]);
///   plot.addPoints([12.1, 10.1,   10.9, 10.1,
///                   10.9, 11.1,    6.9, 10.9,
///                   10.9, 10.9,   10.1, 13.9,
///                   10.1,  4.9,   10.1, 10.1])
///                 ..addPointSize(4.0);
///   plot.updateBounds();
///   plot.focusOnData();
class Plotter extends Group {
  /// minimum plotter zoom value.
  static const double _minZoom = 1.0e-4;

  /// maximum plotter zoom value.
  static const double _maxZoom = 1.0e+4;

  /// The data bounds for the item's data.
  Bounds _bounds;

  /// The transformer from the window to the view.
  final Transformer view;

  /// The set of mouse handles.
  final List<PlotterMouseHandle> _mouseHandles;

  Plotter(
    this._bounds,
    this.view,
    this._mouseHandles,
    final String label,
  ) : super(label);

  /// Focuses on the data.
  /// Note: May need to call updateBounds before this if the data has changed.
  void focusOnData() => focusOnBounds(_bounds);

  /// Focuses the view to the given bounds.
  void focusOnBounds(
    final Bounds bounds, [
    final double scalar = 0.95,
  ]) {
    view.reset();
    if (!bounds.isEmpty) {
      final scale = scalar / max(bounds.width, bounds.height);
      view.setScale(scale, scale);
      view.setOffset(-0.5 * (bounds.xmin + bounds.xmax) * scale, -0.5 * (bounds.ymin + bounds.ymax) * scale);
    }
  }

  /// Updates the bounds of the data.
  /// This should be called whenever the data has changed.
  void updateBounds() => _bounds = onGetBounds(view);

  /// Renders the plot with the given renderer.
  void render(
    final PlotterRenderer r,
  ) {
    r.dataSetBounds = _bounds;
    final trans = r.transform!.mul(view);
    r.transform = trans;
    draw(r);
  }

  /// Gets the list of mouse handles,
  List<PlotterMouseHandle> get mouseHandles => _mouseHandles;

  /// Sets the offset of the view transformation.
  void setViewOffset(
    final double x,
    final double y,
  ) =>
      view.setOffset(x, y);

  /// Sets the view transformation zoom.
  /// Note: This is 10 to the power of the given value, such that 0 is x1.0 zoom.
  void setViewZoom(
    final double pow_,
  ) {
    final scale = pow(10.0, pow_).toDouble();
    view.setScale(scale, scale);
  }

  /// Handles mouse down events.
  void onMouseDown(
    final PlotterMouseEvent e,
  ) {
    for (final hndl in _mouseHandles) {
      hndl.mouseDown(e);
    }
  }

  /// Handles mouse move events.
  void onMouseMove(
    final PlotterMouseEvent e,
  ) {
    for (final hndl in _mouseHandles) {
      hndl.mouseMove(e);
    }
  }

  /// Handles mouse up events.
  void onMouseUp(
    final PlotterMouseEvent e,
  ) {
    for (final hndl in _mouseHandles) {
      hndl.mouseUp(e);
    }
  }

  /// Handles mouse wheel move events.
  void onMouseWheel(
    final PlotterMouseEvent e,
    final double dw,
  ) {
    final prev = max(view.xScalar, view.yScalar);
    double scale = pow(10.0, log(prev) / ln10 - dw) as double;
    if (scale < _minZoom) {
      scale = _minZoom;
    } else if (scale > _maxZoom) scale = _maxZoom;
    final x = e.px;
    final y = e.py;
    final dx = (view.dx - x) * (scale / prev) + x;
    final dy = (view.dy - y) * (scale / prev) + y;
    view.setOffset(dx, dy);
    view.setScale(scale, scale);
    e.redraw = true;
  }
}

/// A plotter item for drawing circles.
/// The points are the x and y center points.
class CircleGroup with PlotterItemMixin, BasicCoordsMixin {
  /// The radius of all the circles.
  double radius;

  /// Creates a new circle plotter item.
  CircleGroup(
    final this.radius,
  );

  @override
  int get coordCount => 2;

  List<double> get _centerXs => coords[0];

  List<double> get _centerYs => coords[1];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.drawCircSet(_centerXs, _centerYs, radius);

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_centerXs[i], _centerYs[i]);
    }
    if (!b.isEmpty) {
      b.expand(b.xmin - radius, b.ymin - radius);
      b.expand(b.xmax + radius, b.ymax + radius);
    }
    return trans.transform(b);
  }
}

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
      r.drawCircs(_centerXs, _centerYs, _radii);

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

/// A plotter item for drawing ellipses.{
/// The points are the top-left corner of the ellipses.
class EllipseGroup with PlotterItemMixin, BasicCoordsMixin {
  /// The x radius of all the ellipses.
  double xRadii;

  /// The y radius of all the ellipses.
  double yRadii;

  /// Creates a new ellipse plotter item.
  EllipseGroup(
    final this.xRadii,
    final this.yRadii,
  );

  @override
  int get coordCount => 2;

  List<double> get _centerXs => coords[0];

  List<double> get _centerYs => coords[1];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.drawEllipseSet(
        _centerXs,
        _centerYs,
        xRadii,
        yRadii,
      );

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_centerXs[i], _centerYs[i]);
    }
    if (!b.isEmpty) {
      b.expand(b.xmin - xRadii, b.ymin - yRadii);
      b.expand(b.xmax + xRadii, b.ymax + yRadii);
    }
    return trans.transform(b);
  }
}

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
      r.drawEllipse(
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

/// A plotter item for drawing a line strip.
class LineStrip with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a line strip plotter item.
  LineStrip();

  @override
  int get coordCount => 2;

  List<double> get _x => coords[0];

  List<double> get _y => coords[1];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.drawStrip(_x, _y);

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_x[i], _y[i]);
    }
    return trans.transform(b);
  }
}

/// A plotter item for drawing lines.
class Lines with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a new line plotter item.
  Lines();

  @override
  int get coordCount => 4;

  List<double> get _x1 => coords[0];

  List<double> get _y1 => coords[1];

  List<double> get _x2 => coords[2];

  List<double> get _y2 => coords[3];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.drawLines(_x1, _y1, _x2, _y2);

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_x1[i], _y1[i]);
      b.expand(_x2[i], _y2[i]);
    }
    return trans.transform(b);
  }
}

/// The plotter item for plotting a polygon.
class Polygon with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a polygon plotter item.
  Polygon();

  @override
  int get coordCount => 2;

  List<double> get _x => coords[0];

  List<double> get _y => coords[1];

  /// Called when the polygon is to be draw.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.drawPoly(_x, _y);

  /// Gets the bounds for the polygon.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_x[i], _y[i]);
    }
    return trans.transform(b);
  }
}

/// A plotter item for points.
class Points with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a points plotter item.
  Points();

  @override
  int get coordCount => 2;

  List<double> get _x => coords[0];

  List<double> get _y => coords[1];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.drawPoints(_x, _y);

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_x[i], _y[i]);
    }
    return trans.transform(b);
  }
}

/// A plotter item for drawing rectangles.
class RectangleGroup with PlotterItemMixin, BasicCoordsMixin {
  /// The width of all the rectangles.
  double width;

  /// The height of all the rectangles.
  double height;

  /// Creates a new rectangle plotter item.
  RectangleGroup(
    final this.width,
    final this.height,
  );

  @override
  int get coordCount => 2;

  List<double> get _x => coords[0];

  List<double> get _y => coords[1];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.drawRectSet(_x, _y, width, height);

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      b.expand(_x[i], _y[i]);
    }
    if (!b.isEmpty) b.expand(b.xmax + width, b.ymax + height);
    return trans.transform(b);
  }
}

/// A plotter item for drawing rectangles.
class Rectangles with PlotterItemMixin, BasicCoordsMixin {
  /// Creates a new rectangle plotter item.
  Rectangles();

  @override
  int get coordCount => 4;

  List<double> get _lefts => coords[0];

  List<double> get _tops => coords[1];

  List<double> get _widths => coords[2];

  List<double> get _heights => coords[3];

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) =>
      r.drawRects(_lefts, _tops, _widths, _heights);

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    for (int i = count - 1; i >= 0; --i) {
      final x = _lefts[i];
      final y = _tops[i];
      b.expand(x, y);
      b.expand(x + _widths[i], y + _heights[i]);
    }
    return trans.transform(b);
  }
}

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
    final bound = r.dataSetBounds;
    r.drawRect(bound.xmin, bound.ymin, bound.xmax, bound.ymax);
  }

  /// Get the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) =>
      BoundsImpl.empty();
}

/// A plotter item to draw a grid.
class Grid with PlotterItemMixin {
  /// The closest grid color to the background color.
  final Color _backClr;

  /// The heaviest grid color.
  final Color _foreClr;

  /// The axis grid color.
  final Color _axisClr;

  /// Creates a grid item.
  Grid()
      : _backClr = ColorImpl(0.9, 0.9, 1.0),
        _foreClr = ColorImpl(0.5, 0.5, 1.0),
        _axisClr = ColorImpl(1.0, 0.7, 0.7) {
    addColor(0.0, 0.0, 0.0);
  }

  /// Gets the smallest power of 10 which is greater than the given value.
  int _getMaxPow(
    final double value,
  ) =>
      (log(value) / ln10).ceil();

  /// Gets the number above the given value in multiples of the given power value.
  double _getUpper(
    final double value,
    final double pow,
  ) =>
      (value / pow).ceilToDouble() * pow;

  /// Gets the number below the given value in multiples of the given power value.
  double _getLower(
    final double value,
    final double pow,
  ) =>
      (value / pow).floorToDouble() * pow;

  /// Adds a horizontal line at the given offset to the given group.
  void _addHorz(
    final List<double> group,
    final double offset,
    final Bounds window,
    final Bounds view,
  ) {
    final y = (offset - view.ymin) * window.height / view.height;
    if ((y > 0.0) && (y < window.height)) group.add(y);
  }

  /// The recursive method used to get a horizontal grid line and children grid lines.
  /// [groups] is the group of horizontal line groups.
  /// [window] is the window being drawn into.
  /// [view] is the viewport of the render space.
  /// [pow] is the minimum power to draw at.
  /// [minOffset] is the minimum offset into the view.
  /// [maxOffset] is the maximum offset into the view.
  /// [rmdPow] is the current offset of the power to get the lines for.
  void _getHorzs(
    final List<List<double>> groups,
    final Bounds window,
    final Bounds view,
    final double pow,
    final double minOffset,
    final double maxOffset,
    final int rmdPow,
  ) {
    if (rmdPow > 0) {
      final lowPow = pow / 10.0;
      double offset = minOffset;
      _getHorzs(groups, window, view, lowPow, offset, offset + pow, rmdPow - 1);
      if (offset + pow != offset) {
        final group = groups[rmdPow - 1];
        for (offset += pow; offset < maxOffset; offset += pow) {
          _addHorz(group, offset, window, view);
          _getHorzs(groups, window, view, lowPow, offset, offset + pow, rmdPow - 1);
        }
      }
    }
  }

  /// Adds a vertical line at the given offset to the given group.
  void _addVert(
    final List<double> group,
    final double offset,
    final Bounds window,
    final Bounds view,
  ) {
    final x = (offset - view.xmin) * window.width / view.width;
    if ((x > 0.0) && (x < window.width)) group.add(x);
  }

  /// The recursive method used to get a vertical grid line and children grid lines.
  /// [groups] is the group of vertical line groups.
  /// [window] is the window being drawn into.
  /// [view] is the viewport of the render space.
  /// [pow] is the minimum power to draw at.
  /// [minOffset] is the minimum offset into the view.
  /// [maxOffset] is the maximum offset into the view.
  /// [rmdPow] is the current offset of the power to get the lines for.
  void _getVerts(
    final List<List<double>> groups,
    final Bounds window,
    final Bounds view,
    final double pow,
    final double minOffset,
    final double maxOffset,
    final int rmdPow,
  ) {
    if (rmdPow <= 0) return;
    final lowPow = pow / 10.0;
    double offset = minOffset;
    final group = groups[rmdPow - 1];
    _getVerts(groups, window, view, lowPow, offset, offset + pow, rmdPow - 1);
    for (offset += pow; offset < maxOffset; offset += pow) {
      _addVert(group, offset, window, view);
      _getVerts(groups, window, view, lowPow, offset, offset + pow, rmdPow - 1);
    }
  }

  /// Sets the linearly interpolated color used for the grid lines to the renderer.
  void _setColor(
    final PlotterRenderer r,
    final int rmdPow,
    final int diff,
  ) {
    final fraction = rmdPow / diff;
    final red = _backClr.red + fraction * (_foreClr.red - _backClr.red);
    final green = _backClr.green + fraction * (_foreClr.green - _backClr.green);
    final blue = _backClr.blue + fraction * (_foreClr.blue - _backClr.blue);
    r.color = ColorImpl(red, green, blue);
  }

  /// Draws the grid lines.
  void _drawGrid(
    final PlotterRenderer r,
    final Bounds window,
    final Bounds view,
  ) {
    const minSpacing = 5.0;
    int maxPow = max(
      _getMaxPow(view.width),
      _getMaxPow(view.height),
    );
    int minPow = min(
      _getMaxPow(view.width * minSpacing / window.width),
      _getMaxPow(
        view.height * minSpacing / window.height,
      ),
    );
    int diff = maxPow - minPow;
    if (diff <= 0) {
      diff = 1;
      maxPow = 1;
      minPow = 0;
    }
    final _pow = pow(10, maxPow - 1).toDouble();
    final maxXOffset = _getUpper(view.xmax, _pow);
    final minXOffset = _getLower(view.xmin, _pow);
    final maxYOffset = _getUpper(view.ymax, _pow);
    final minYOffset = _getLower(view.ymin, _pow);
    final horzs = <List<double>>[];
    final verts = <List<double>>[];
    for (int i = 0; i < diff; ++i) {
      horzs.add(<double>[]);
      verts.add(<double>[]);
    }
    _getHorzs(horzs, window, view, _pow, minYOffset, maxYOffset, diff);
    _getVerts(verts, window, view, _pow, minXOffset, maxXOffset, diff);
    for (int i = 0; i < diff; ++i) {
      _setColor(r, i, diff);
      for (final y in horzs[i]) {
        r.drawLine(window.xmin, y, window.xmax, y);
      }
      for (final x in verts[i]) {
        r.drawLine(x, window.ymin, x, window.ymax);
      }
    }
  }

  /// Draws the axis grid lines.
  void _drawAxis(
    final PlotterRenderer r,
    final Bounds window,
    final Bounds view,
  ) {
    if ((view.xmin <= 0.0) && (view.xmax >= 0.0)) {
      final group = <double>[];
      _addVert(group, 0.0, window, view);
      if (group.length == 1) {
        r.color = _axisClr;
        final x = group[0];
        r.drawLine(x, window.ymin, x, window.ymax);
      }
    }
    if ((view.ymin <= 0.0) && (view.ymax >= 0.0)) {
      final group = <double>[];
      _addHorz(group, 0.0, window, view);
      if (group.length == 1) {
        r.color = _axisClr;
        final y = group[0];
        r.drawLine(window.xmin, y, window.xmax, y);
      }
    }
  }

  /// Draws the grid item.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) {
    final window = r.drawPanelBounds;
    final view = r.viewportIntoWindow;
    if (view.width > 0.0) {
      if (view.height > 0.0) {
        final last = r.transform;
        r.transform = TransformerImpl.identity();
        _drawGrid(r, window!, view);
        _drawAxis(r, window, view);
        r.transform = last;
      }
    }
  }

  /// Get the bounds for the grid.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) =>
      BoundsImpl.empty();
}

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
      r.drawText(x, y, size, text, scale);
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

/// A group for plotter items.
class Group with PlotterItemMixin {
  /// The label for the group.
  String label;

  /// Indicates if the item is enabled or disabled.
  @override
  // ignore: overridden_fields
  bool enabled;

  /// The plotter items in this group.
  final List<PlotterItem> _items;

  /// Creates a new plotter item group.
  Group([
    final this.label = "",
    final this.enabled = true,
  ]) : _items = <PlotterItem>[];

  /// The number of items in the group.
  int get count => _items.length;

  /// The list of items in the group.
  List<PlotterItem> get items => _items;

  /// Adds plotter items to the group.
  void addItems(
    final List<PlotterItem> items,
  ) {
    // ignore: prefer_foreach
    for (final item in items) {
      _items.add(item);
    }
  }

  /// Adds a text plotter item with the given data.
  Text addText(
    final double x,
    final double y,
    final double size,
    final String text, [
    final bool scale = false,
  ]) {
    final item = Text(x, y, size, text, scale);
    addItems([item]);
    return item;
  }

  /// Adds a points plotter item with the given data.
  Points addPoints(
    final List<double> val,
  ) {
    final item = Points()..add(val);
    addItems([item]);
    return item;
  }

  /// Adds a lines plotter item with the given data.
  Lines addLines(
    final List<double> val,
  ) {
    final item = Lines()..add(val);
    addItems([item]);
    return item;
  }

  /// Adds a line strip plotter item with the given data.
  LineStrip addLineStrip(
    final List<double> val,
  ) {
    final item = LineStrip()..add(val);
    addItems([item]);
    return item;
  }

  /// Adds a polygon plotter item with the given data.
  Polygon addPolygon(
    final List<double> val,
  ) {
    final item = Polygon()..add(val);
    addItems([item]);
    return item;
  }

  /// Adds a rectangles plotter item with the given data.
  Rectangles addRects(
    final List<double> items,
  ) {
    final item = Rectangles()..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a circles plotter item with the given data.
  Circles addCircles(
    final List<double> items,
  ) {
    final item = Circles()..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a ellipses plotter item with the given data.
  Ellipses addEllipses(
    final List<double> items,
  ) {
    final item = Ellipses()..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a rectangle group plotter item with the given data.
  RectangleGroup addRectGroup(
    final double width,
    final double height,
    final List<double> items,
  ) {
    final item = RectangleGroup(width, height)..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a circle group plotter item with the given data.
  CircleGroup addCircleGroup(double radius, List<double> items) {
    final item = CircleGroup(radius)..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a ellipse group plotter item with the given data.
  EllipseGroup addEllipseGroup(
    final double width,
    final double height,
    final List<double> items,
  ) {
    final item = EllipseGroup(width, height)..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a child group item with the given items.
  Group addGroup([
    final String label = "",
    final List<PlotterItem>? items,
    final bool enabled = true,
  ]) {
    final item = Group()
      ..label = label
      ..enabled = enabled;
    if (items != null) {
      item.addItems(items);
    }
    addItems([item]);
    return item;
  }

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) {
    if (enabled) {
      for (final item in _items) {
        item.draw(r);
      }
    }
  }

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    if (enabled) {
      for (final item in _items) {
        b.union(item.getBounds(trans));
      }
    }
    return b;
  }
}
