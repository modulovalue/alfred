import 'dart:html';
import 'dart:math';

import '../../basic/bounds.dart';
import '../../basic/color.dart';
import '../../basic/transformer.dart';
import '../interface.dart';

/// A renderer for drawing canvas plots.
class HtmlCanvasRenderer implements PlotterRenderer, PlotterDrawActions, PlotterDrawState {
  @override
  PlotterDrawActions get actions => this;

  @override
  PlotterDrawState get state => this;

  /// The context to render with.
  final CanvasRenderingContext2D _context;

  /// The bounds of the panel.
  Bounds? _window;

  /// The bounds of the data.
  @override
  Bounds dataSetBounds;

  /// The current transformer for the plot.
  @override
  Transformer? transform;

  /// The current point size.
  @override
  double currentPointSize;

  /// The current background color.
  @override
  Color currentBackgroundColor;

  /// The current line color.
  Color? _lineClr;

  /// The current line color string.
  String? _lineClrStr;

  /// The current fill color or null for no fill.
  Color? _fillClr;

  /// The current fill color string or empty for no fill.
  String? _fillClrStr;

  /// The current font to draw text with.
  @override
  String? currentFont;

  /// Indicates if the lines should be drawn directed (with arrows), or not.
  @override
  bool currentShouldDrawDirectedLines;

  /// Creates a new renderer.
  HtmlCanvasRenderer(
    final this._context,
  )   : dataSetBounds = BoundsImpl.empty(),
        currentPointSize = 0.0,
        currentBackgroundColor = ColorImpl(1.0, 1.0, 1.0),
        currentFont = "Verdana",
        currentShouldDrawDirectedLines = false {
    color = ColorImpl(0.0, 0.0, 0.0);
    fillColor = null;
  }

  /// Reset the renderer and clears the panel to white.
  void reset(
    final Bounds window,
    final Transformer trans,
  ) {
    _window = window;
    transform = trans;
    _context.fillStyle = _getColorString(currentBackgroundColor);
    _context.fillRect(0, 0, window.width, window.height);
  }

  /// Gets the bounds of the panel being drawn on.
  @override
  Bounds get drawPanelBounds => _window!;

  /// Gets the viewport into the window with the given transformation.
  @override
  Bounds get viewportIntoWindow => transform!.untransform(_window!);

  /// The color to draw lines with.
  @override
  Color? get color => _lineClr;

  @override
  set color(
    final Color? color,
  ) {
    _lineClr = color;
    _lineClrStr = _getColorString(color);
  }

  /// The color to fill shapes with.
  @override
  Color? get fillColor => _fillClr;

  @override
  set fillColor(
    final Color? color,
  ) {
    _fillClr = color;
    _fillClrStr = _getColorString(color);
  }

  /// Draws text to the viewport.
  @override
  void drawText(
    double x,
    double y,
    double size,
    final String text,
    final bool scale,
  ) {
    _context.beginPath();
    _context.strokeStyle = _lineClrStr;
    _context.fillStyle = _fillClrStr;
    if (scale) {
      final x2 = _transX(x + size);
      // ignore: parameter_assignments
      x = _transX(x);
      // ignore: parameter_assignments
      y = _transY(y);
      // ignore: parameter_assignments
      size = (x2 - x).abs();
    }
    _context.font = size.toString() + "px " + currentFont!;
    if (_fillClr != null) {
      _context.fillText(text, x, y);
    }
    _context.strokeText(text, x, y);
  }

  /// Draws a point to the viewport.
  @override
  void drawPoint(
    final double _x,
    final double _y,
  ) {
    final x = _transX(_x);
    final y = _transY(_y);
    final r = () {
      if (currentPointSize <= 1.0) {
        return 1.0;
      } else {
        return currentPointSize;
      }
    }();
    _writePoint(x, y, r);
  }

  /// Draws a set of points to the viewport.
  @override
  void drawPoints(
    final List<double> xCoords,
    final List<double> yCoords,
  ) {
    assert(xCoords.length == yCoords.length, "Both coordinate arrays must have the same size.");
    for (int i = xCoords.length - 1; i >= 0; --i) {
      drawPoint(xCoords[i], yCoords[i]);
    }
  }

  /// Draws a line to the viewport.
  @override
  void drawLine(
    final double x1,
    final double y1,
    final double x2,
    final double y2,
  ) {
    final tx1 = _transX(x1);
    final ty1 = _transY(y1);
    final tx2 = _transX(x2);
    final ty2 = _transY(y2);
    _drawTransLine(x1, y1, x2, y2, tx1, ty1, tx2, ty2);
    if (currentPointSize > 1.0) {
      drawPoint(x1, y1);
      drawPoint(x2, y2);
    }
  }

  /// Draws a line to the viewport with pre-translated coordinates.
  void _drawTransLine(
    final double x1,
    final double y1,
    final double x2,
    final double y2,
    final double tx1,
    final double ty1,
    final double tx2,
    final double ty2,
  ) {
    _context.strokeStyle = _lineClrStr;
    _context.fillStyle = "";
    _context.beginPath();
    _context.moveTo(tx1, ty1);
    _context.lineTo(tx2, ty2);
    if (currentShouldDrawDirectedLines) {
      double dx = x2 - x1;
      double dy = y2 - y1;
      final length = sqrt((dx * dx) + (dy * dy));
      if (length > 1.0e-12) {
        dx /= length;
        dy /= length;
        const width = 6.0;
        const height = 4.0;
        final tx3 = tx2 - dx * width;
        final dx3 = dy * height;
        final ty3 = ty2 + dy * width;
        final dy3 = dx * height;
        _context.moveTo(tx3 + dx3, ty3 + dy3);
        _context.lineTo(tx2, ty2);
        _context.lineTo(tx3 - dx3, ty3 - dy3);
      }
    }
    _context.stroke();
  }

  /// Draws a set of lines to the viewport.
  @override
  void drawLines(
    final List<double> x1Coords,
    final List<double> y1Coords,
    final List<double> x2Coords,
    final List<double> y2Coords,
  ) {
    assert(x1Coords.length == y1Coords.length, "All coordinate arrays must have the same size.");
    assert(x1Coords.length == x2Coords.length, "All coordinate arrays must have the same size.");
    assert(x1Coords.length == y2Coords.length, "All coordinate arrays must have the same size.");
    for (int i = x1Coords.length - 1; i >= 0; --i) {
      drawLine(x1Coords[i], y1Coords[i], x2Coords[i], y2Coords[i]);
    }
  }

  /// Draws a rectangle to the viewport.
  @override
  void drawRect(
    final double x1_,
    final double y1_,
    final double x2_,
    final double y2_,
  ) {
    final x1 = _transX(x1_);
    final y1 = _transY(y1_);
    final x2 = _transX(x2_);
    final y2 = _transY(y2_);
    final width = x2 - x1;
    final height = y1 - y2;
    _writeRect(x1, y2, width, height);
  }

  /// Draws a set of rectangles to the viewport.
  @override
  void drawRects(
    final List<double> xCoords,
    final List<double> yCoords,
    final List<double> widths,
    final List<double> heights,
  ) {
    assert(xCoords.length == yCoords.length, "All coordinate arrays must have the same size.");
    assert(xCoords.length == widths.length, "All coordinate arrays must have the same size.");
    assert(xCoords.length == heights.length, "All coordinate arrays must have the same size.");
    for (int i = xCoords.length - 1; i >= 0; --i) {
      final x = xCoords[i];
      final y = yCoords[i];
      drawRect(x, y, x + widths[i], y + heights[i]);
    }
  }

  /// Draws a set of rectangles to the viewport.
  @override
  void drawRectSet(
    final List<double> xCoords,
    final List<double> yCoords,
    final double width,
    final double height,
  ) {
    assert(xCoords.length == yCoords.length, "All coordinate arrays must have the same size.");
    for (int i = xCoords.length - 1; i >= 0; --i) {
      final x = xCoords[i];
      final y = yCoords[i];
      drawRect(x, y, x + width, y + height);
    }
  }

  /// Draws an ellipse to the viewport.
  void _drawEllipse(
    double x1_,
    double y1_,
    double x2_,
    double y2_,
  ) {
    double x1 = _transX(x1_);
    double y1 = _transY(y1_);
    double x2 = _transX(x2_);
    double y2 = _transY(y2_);
    if (x1 > x2) {
      final temp = x1;
      x1 = x2;
      x2 = temp;
    }
    if (y1 > y2) {
      final temp = y1;
      y1 = y2;
      y2 = temp;
    }
    final rx = (x2 - x1).abs() * 0.5;
    final ry = (y2 - y1).abs() * 0.5;
    final cx = x1 + rx;
    final cy = y1 + ry;
    _writeEllipse(cx, cy, rx, ry);
  }

  /// Draws a set of ellipses to the viewport.
  @override
  void drawEllipse(
    final List<double> xCoords,
    final List<double> yCoords,
    final List<double> xRadii,
    final List<double> yRadii,
  ) {
    assert(xCoords.length == yCoords.length, "All arrays must have the same size.");
    assert(xCoords.length == xRadii.length, "All arrays must have the same size.");
    assert(xCoords.length == yRadii.length, "All arrays must have the same size.");
    for (int i = xCoords.length - 1; i >= 0; --i) {
      final xr = xRadii[i];
      final yr = yRadii[i];
      final x = xCoords[i];
      final y = yCoords[i];
      _drawEllipse(x - xr, y - yr, x + xr, y + yr);
    }
  }

  /// Draws a set of ellipses to the viewport.
  @override
  void drawEllipseSet(
    final List<double> xCoords,
    final List<double> yCoords,
    final double xRadius,
    final double yRadius,
  ) {
    assert(xCoords.length == yCoords.length, "All coordinates must have the same size.");
    for (int i = xCoords.length - 1; i >= 0; --i) {
      final x = xCoords[i];
      final y = yCoords[i];
      _drawEllipse(x - xRadius, y - yRadius, x + xRadius, y + yRadius);
    }
  }

  /// Draws a set of circles to the viewport.
  @override
  void drawCircs(
    final List<double> xCoords,
    final List<double> yCoords,
    final List<double> radii,
  ) {
    assert(xCoords.length == yCoords.length, "All arrays must have the same size.");
    assert(xCoords.length == radii.length, "All arrays must have the same size.");
    for (int i = xCoords.length - 1; i >= 0; --i) {
      final r = radii[i];
      double cx = xCoords[i];
      double cy = yCoords[i];
      final x2 = _transX(cx + r);
      final y2 = _transY(cy + r);
      cx = _transX(cx);
      cy = _transY(cy);
      final rx = (x2 - cx).abs();
      final ry = (y2 - cy).abs();
      _writeEllipse(cx, cy, rx, ry);
    }
  }

  /// Draws a set of circles to the viewport.
  @override
  void drawCircSet(
    final List<double> xCoords,
    final List<double> yCoords,
    final double radius,
  ) {
    assert(xCoords.length == yCoords.length, "All coordinate arrays must have the same size.");
    for (int i = xCoords.length - 1; i >= 0; --i) {
      double cx = xCoords[i];
      double cy = yCoords[i];
      final x2 = _transX(cx + radius);
      final y2 = _transY(cy + radius);
      cx = _transX(cx);
      cy = _transY(cy);
      final rx = (x2 - cx).abs();
      final ry = (y2 - cy).abs();
      _writeEllipse(cx, cy, rx, ry);
    }
  }

  /// Draws a polygon to the viewport.
  @override
  void drawPoly(
    final List<double> xCoords,
    final List<double> yCoords,
  ) {
    assert(xCoords.length == yCoords.length, "All coordinate arrays must have the same size.");
    final count = xCoords.length;
    if (count >= 3) {
      _context.strokeStyle = _lineClrStr;
      _context.fillStyle = _fillClrStr;
      _context.beginPath();
      double x = _transX(xCoords[0]);
      double y = _transY(yCoords[0]);
      _context.moveTo(x, y);
      for (int i = 1; i < count; ++i) {
        x = _transX(xCoords[i]);
        y = _transY(yCoords[i]);
        _context.lineTo(x, y);
      }
      if (_fillClr != null) {
        _context.fill();
      }
      _context.stroke();
      if (currentShouldDrawDirectedLines) {
        double x1 = xCoords[count - 1];
        double y1 = yCoords[count - 1];
        double tx1 = _transX(x1);
        double ty1 = _transY(y1);
        for (int i = 0; i < count; ++i) {
          final x2 = xCoords[i];
          final y2 = yCoords[i];
          final tx2 = _transX(x2);
          final ty2 = _transY(y2);
          _drawTransLine(x1, y1, x2, y2, tx1, ty1, tx2, ty2);
          x1 = x2;
          y1 = y2;
          tx1 = tx2;
          ty1 = ty2;
        }
      }
    }
    if (currentPointSize > 1.0) {
      drawPoints(xCoords, yCoords);
    }
  }

  /// Draws a line strip to the viewport.
  @override
  void drawStrip(
    final List<double> xCoords,
    final List<double> yCoords,
  ) {
    assert(xCoords.length == yCoords.length, "All coordinate arrays must have the same size.");
    final count = xCoords.length;
    if (count >= 2) {
      _context.strokeStyle = _lineClrStr;
      _context.fillStyle = "";
      _context.beginPath();
      double x = _transX(xCoords[0]);
      double y = _transY(yCoords[0]);
      _context.moveTo(x, y);
      for (int i = 1; i < count; ++i) {
        x = _transX(xCoords[i]);
        y = _transY(yCoords[i]);
        _context.lineTo(x, y);
      }
      _context.stroke();
      if (currentShouldDrawDirectedLines) {
        double x1 = xCoords[0];
        double y1 = yCoords[0];
        double tx1 = _transX(x1);
        double ty1 = _transY(y1);
        for (int i = 1; i < count; ++i) {
          final x2 = xCoords[i];
          final y2 = yCoords[i];
          final tx2 = _transX(x2);
          final ty2 = _transY(y2);
          _drawTransLine(x1, y1, x2, y2, tx1, ty1, tx2, ty2);
          x1 = x2;
          y1 = y2;
          tx1 = tx2;
          ty1 = ty2;
        }
      }
    }
    if (currentPointSize > 1.0) {
      drawPoints(xCoords, yCoords);
    }
  }

  /// Translates the given x value by the current transformer.
  double _transX(
    final double x,
  ) =>
      transform!.transformX(x);

  /// Translates the given y value by the current transformer.
  double _transY(
    final double y,
  ) =>
      _window!.ymax - transform!.transformY(y);

  /// Gets the SVG color string for the given color.
  String _getColorString(
    final Color? color,
  ) {
    if (color == null) {
      return "";
    } else {
      final r = (color.red * 255.0).floor();
      final g = (color.green * 255.0).floor();
      final b = (color.blue * 255.0).floor();
      return "rgba($r, $g, $b, ${color.alpha})";
    }
  }

  /// Writes a point SVG to the buffer.
  void _writePoint(
    final double x,
    final double y,
    final double r,
  ) {
    _context.strokeStyle = "";
    _context.fillStyle = _lineClrStr;
    _context.beginPath();
    _context.arc(x, y, r, 0.0, _tau);
    _context.fill();
  }

  /// Writes a rectangle SVG to the buffer.
  void _writeRect(
    final double x,
    final double y,
    final double width,
    final double height,
  ) {
    _context.strokeStyle = _lineClrStr;
    _context.fillStyle = _fillClrStr;
    _context.beginPath();
    _context.rect(x, y, width, height);
    if (_fillClr != null) {
      _context.fill();
    }
    _context.stroke();
  }

  /// Writes an ellipse SVG to the buffer.
  void _writeEllipse(
    final double cx,
    final double cy,
    final double rx,
    final double ry,
  ) {
    _context.strokeStyle = _lineClrStr;
    _context.fillStyle = _fillClrStr;
    _context.beginPath();
    _context.ellipse(cx, cy, rx, ry, 0.0, 0.0, _tau, true);
    if (_fillClr != null) {
      _context.fill();
    }
    _context.stroke();
  }
}

const double _tau = 2.0 * pi;
