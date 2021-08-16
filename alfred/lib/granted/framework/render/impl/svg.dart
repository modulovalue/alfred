import 'dart:math';

import '../../primitives/primitives.dart';
import '../../primitives/primitives_impl.dart';
import '../interface.dart';

/// A renderer for drawing SVG plots.
class SvgRenderer implements PlotterRenderer {
  /// The buffer to temporarily store SVG while drawing.
  final StringBuffer _outputBuffer;

  /// The bounds of the panel being drawn on.
  @override
  Bounds? drawPanelBounds;

  /// The bounds of the data.
  @override
  Bounds dataSetBounds;

  /// The current transformer for the plot.
  @override
  Transformer? transform;

  /// The current point size.
  @override
  double pointSize;

  /// The current background color.
  @override
  Color backgroundColor;

  /// The current line color.
  Color? _lineClr;

  /// The CSS draw color currently set.
  String? _lineClrStr;

  /// The CSS draw color currently set.
  String? _pointClrStr;

  /// The current fill color or null for no fill.
  Color? _fillClr;

  /// The CSS fill color currently set.
  String? _fillClrStr;

  /// The current font to draw text with.
  @override
  String? font;

  /// Indicates if the lines should be drawn directed (with arrows), or not.
  @override
  bool directedLines;

  final void Function(Bounds window, String backgroundColorString) renderReset;

  /// Creates a new renderer.
  SvgRenderer(
    final this.renderReset,
  )   : _outputBuffer = StringBuffer(),
        dataSetBounds = BoundsImpl.empty(),
        pointSize = 0.0,
        backgroundColor = ColorImpl(1.0, 1.0, 1.0),
        font = "Verdana",
        directedLines = false {
    color = ColorImpl(0.0, 0.0, 0.0);
    fillColor = null;
  }

  /// Reset the renderer and clears the panel to white.
  void reset(
    final Bounds _window,
    final Transformer trans,
  ) {
    drawPanelBounds = _window;
    transform = trans;
    final _backgroundColorString = _getColorString(backgroundColor);
    renderReset(_window, _backgroundColorString);
    _outputBuffer.clear();
  }

  @override
  Bounds get viewportIntoWindow => transform!.untransform(drawPanelBounds!);

  @override
  Color? get color => _lineClr;

  @override
  set color(
    final Color? color,
  ) {
    _lineClr = color;
    final drawClr = _getColorString(color!);
    _lineClrStr = "stroke=\"" + drawClr + "\" stroke-opacity=\"" + color.alpha.toString() + "\" ";
    _pointClrStr = "fill=\"" + drawClr + "\" fill-opacity=\"" + color.alpha.toString() + "\" ";
  }

  @override
  Color? get fillColor => _fillClr;

  @override
  set fillColor(
    final Color? color,
  ) {
    _fillClr = color;
    if (color != null) {
      _fillClrStr = "fill=\"" + _getColorString(color) + "\" fill-opacity=\"" + color.alpha.toString() + "\" ";
    } else {
      _fillClrStr = "fill=\"none\" ";
    }
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
    if (scale) {
      final x2 = _transX(x + size);
      // ignore: parameter_assignments
      x = _transX(x);
      // ignore: parameter_assignments
      y = _transY(y);
      // ignore: parameter_assignments
      size = (x2 - x).abs();
    }
    _outputBuffer.write(
      "<text x=\"$x\" y=\"$y\" style=\"font-family: ${font}; font-size: ${size}px;\" ",
    );
    _outputBuffer.writeln(
      "${_lineClrStr}${_fillClrStr}>" + text + "</text>",
    );
  }

  /// Draws a point to the viewport.
  @override
  void drawPoint(
    double x,
    double y,
  ) {
    // ignore: parameter_assignments
    x = _transX(x);
    // ignore: parameter_assignments
    y = _transY(y);
    final r = (pointSize <= 1.0) ? 1.0 : pointSize;
    _writePoint(x, y, r);
  }

  /// Draws a set of points to the viewport.
  @override
  void drawPoints(
    final List<double> xCoords,
    final List<double> yCoords,
  ) {
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
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
    _drawTransLine(
      x1,
      y1,
      x2,
      y2,
      tx1,
      ty1,
      tx2,
      ty2,
    );
    if (pointSize > 1.0) {
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
    _writeLine(tx1, ty1, tx2, ty2);
    if (directedLines) {
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
        _writeLine(tx2, ty2, tx3 + dx3, ty3 + dy3);
        _writeLine(tx2, ty2, tx3 - dx3, ty3 - dy3);
      }
    }
  }

  /// Draws a set of lines to the viewport.
  @override
  void drawLines(
    final List<double> x1Coords,
    final List<double> y1Coords,
    final List<double> x2Coords,
    final List<double> y2Coords,
  ) {
    // ignore: prefer_asserts_with_message
    assert(x1Coords.length == y1Coords.length);
    // ignore: prefer_asserts_with_message
    assert(x1Coords.length == x2Coords.length);
    // ignore: prefer_asserts_with_message
    assert(x1Coords.length == y2Coords.length);
    for (int i = x1Coords.length - 1; i >= 0; --i) {
      drawLine(x1Coords[i], y1Coords[i], x2Coords[i], y2Coords[i]);
    }
  }

  /// Draws a rectangle to the viewport.
  @override
  void drawRect(
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    // ignore: parameter_assignments
    x1 = _transX(x1);
    // ignore: parameter_assignments
    y1 = _transY(y1);
    // ignore: parameter_assignments
    x2 = _transX(x2);
    // ignore: parameter_assignments
    y2 = _transY(y2);
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
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == widths.length);
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == heights.length);
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
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
    for (int i = xCoords.length - 1; i >= 0; --i) {
      final x = xCoords[i];
      final y = yCoords[i];
      drawRect(x, y, x + width, y + height);
    }
  }

  /// Draws an ellipse to the viewport.
  void _drawEllipse(
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    // ignore: parameter_assignments
    x1 = _transX(x1);
    // ignore: parameter_assignments
    y1 = _transY(y1);
    // ignore: parameter_assignments
    x2 = _transX(x2);
    // ignore: parameter_assignments
    y2 = _transY(y2);
    if (x1 > x2) {
      final temp = x1;
      // ignore: parameter_assignments
      x1 = x2;
      // ignore: parameter_assignments
      x2 = temp;
    }
    if (y1 > y2) {
      final temp = y1;
      // ignore: parameter_assignments
      y1 = y2;
      // ignore: parameter_assignments
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
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == xRadii.length);
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yRadii.length);
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
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
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
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == radii.length);
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
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
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
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
    final int count = xCoords.length;
    if (count >= 3) {
      double x = _transX(xCoords[0]);
      double y = _transY(yCoords[0]);
      _outputBuffer.write("<polygon points=\"$x,$y");
      for (int i = 1; i < count; ++i) {
        x = _transX(xCoords[i]);
        y = _transY(yCoords[i]);
        _outputBuffer.write(" $x,$y");
      }
      _outputBuffer.writeln("\" $_fillClrStr$_lineClrStr/>");
      if (directedLines) {
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
    if (pointSize > 1.0) {
      drawPoints(xCoords, yCoords);
    }
  }

  /// Draws a line strip to the viewport.
  @override
  void drawStrip(
    final List<double> xCoords,
    final List<double> yCoords,
  ) {
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
    final count = xCoords.length;
    if (count >= 2) {
      double x = _transX(xCoords[0]);
      double y = _transY(yCoords[0]);
      _outputBuffer.write("<polyline points=\"" + x.toString() + "," + y.toString());
      for (int i = 1; i < count; ++i) {
        x = _transX(xCoords[i]);
        y = _transY(yCoords[i]);
        _outputBuffer.write(" $x,$y");
      }
      _outputBuffer.writeln("\" fill=\"none\" " + _lineClrStr! + "/>");
      if (directedLines) {
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
    if (pointSize > 1.0) {
      drawPoints(
        xCoords,
        yCoords,
      );
    }
  }

  /// Finishes the render and applies the SVG.
  String finalize() => _outputBuffer.toString();

  /// Translates the given x value by the current transformer.
  double _transX(
    final double x,
  ) =>
      transform!.transformX(x);

  /// Translates the given y value by the current transformer.
  double _transY(
    final double y,
  ) =>
      drawPanelBounds!.ymax - transform!.transformY(y);

  /// Gets the SVG color string for the given color.
  String _getColorString(
    final Color color,
  ) {
    final r = (color.red * 255.0).floor();
    final g = (color.green * 255.0).floor();
    final b = (color.blue * 255.0).floor();
    return "rgb(" + r.toString() + ", " + g.toString() + ", " + b.toString() + ")";
  }

  /// Writes a point SVG to the buffer.
  void _writePoint(
    final double x,
    final double y,
    final double r,
  ) =>
      _outputBuffer.writeln(
        "<circle cx=\"" +
            x.toString() +
            "\" cy=\"" +
            y.toString() +
            "\" r=\"" +
            r.toString() +
            "\" " +
            _pointClrStr! +
            " />",
      );

  /// Writes a line SVG to the buffer.
  void _writeLine(
    final double x1,
    final double y1,
    final double x2,
    final double y2,
  ) =>
      _outputBuffer.writeln(
        "<line x1=\"" +
            x1.toString() +
            "\" y1=\"" +
            y1.toString() +
            "\" x2=\"" +
            x2.toString() +
            "\" y2=\"" +
            y2.toString() +
            "\" " +
            _lineClrStr! +
            "/>",
      );

  /// Writes a rectangle SVG to the buffer.
  void _writeRect(
    final double x,
    final double y,
    final double width,
    final double height,
  ) =>
      _outputBuffer.writeln(
        "<rect x=\"" +
            x.toString() +
            "\" y=\"" +
            y.toString() +
            "\" width=\"" +
            width.toString() +
            "\" height=\"" +
            height.toString() +
            "\" " +
            _fillClrStr! +
            _lineClrStr! +
            "/>",
      );

  /// Writes an ellipse SVG to the buffer.
  void _writeEllipse(
    final double cx,
    final double cy,
    final double rx,
    final double ry,
  ) =>
      _outputBuffer.writeln(
        "<ellipse cx=\"" +
            cx.toString() +
            "\" cy=\"" +
            cy.toString() +
            "\" rx=\"" +
            rx.toString() +
            "\" ry=\"" +
            ry.toString() +
            "\" " +
            _fillClrStr! +
            _lineClrStr! +
            "/>",
      );
}
