import 'dart:math';

import '../../basic/bounds.dart';
import '../../basic/color.dart';
import '../../basic/transformer.dart';
import '../interface.dart';

// TODO collect objects that are serialized to a string on finalize.
/// A renderer for drawing SVG plots.
class SvgRenderer implements PlotterRenderer, PlotterDrawActions, PlotterDrawState {
  final void Function(Bounds window, String backgroundColorString) renderReset;
  final StringBuffer outputBuffer;
  @override
  Bounds? drawPanelBounds;
  @override
  Bounds dataSetBounds;
  @override
  Transformer? transform;
  @override
  double currentPointSize;

  // TODO I should probably have an svg color that maintains the string itself?
  @override
  Color currentBackgroundColor;
  Color? currentLineClr;
  String? currentLineClrStr;
  String? currentPointClrStr;
  Color? currentFillClr;
  String? _currentFillClrStr;
  @override
  String? currentFont;
  @override
  bool currentShouldDrawDirectedLines;

  SvgRenderer({
    required final this.renderReset,
  })  : outputBuffer = StringBuffer(),
        dataSetBounds = BoundsImpl.empty(),
        currentPointSize = 0.0,
        currentBackgroundColor = ColorImpl(1.0, 1.0, 1.0),
        currentFont = "Verdana",
        currentShouldDrawDirectedLines = false {
    color = ColorImpl(0.0, 0.0, 0.0);
    fillColor = null;
  }

  @override
  PlotterDrawActions get actions => this;

  @override
  PlotterDrawState get state => this;

  /// Reset the renderer and clears the panel to white.
  void reset(
    final Bounds window,
    final Transformer trans,
  ) {
    drawPanelBounds = window;
    transform = trans;
    final _backgroundColorString = _color_to_svg_string(
      currentBackgroundColor,
    );
    renderReset(window, _backgroundColorString);
    outputBuffer.clear();
  }

  @override
  Bounds get viewportIntoWindow => transform!.untransform(drawPanelBounds!);

  @override
  Color? get color => currentLineClr;

  @override
  set color(
    final Color? color,
  ) {
    currentLineClr = color;
    final drawClr = _color_to_svg_string(color!);
    currentLineClrStr = "stroke=\"" + drawClr + "\" stroke-opacity=\"" + color.alpha.toString() + "\" ";
    currentPointClrStr = "fill=\"" + drawClr + "\" fill-opacity=\"" + color.alpha.toString() + "\" ";
  }

  @override
  Color? get fillColor => currentFillClr;

  @override
  set fillColor(
    final Color? color,
  ) {
    currentFillClr = color;
    if (color != null) {
      _currentFillClrStr =
          "fill=\"" + _color_to_svg_string(color) + "\" fill-opacity=\"" + color.alpha.toString() + "\" ";
    } else {
      _currentFillClrStr = "fill=\"none\" ";
    }
  }

  @override
  void drawText(
    double x,
    double y,
    double size,
    final String text,
    final bool scale,
  ) {
    if (scale) {
      final x2 = transX(x + size);
      // ignore: parameter_assignments
      x = transX(x);
      // ignore: parameter_assignments
      y = transY(y);
      // ignore: parameter_assignments
      size = (x2 - x).abs();
    }
    outputBuffer.write(
      "<text x=\"" +
          x.toString() +
          "\" y=\"" +
          y.toString() +
          "\" style=\"font-family: " +
          currentFont.toString() +
          "; font-size: " +
          size.toString() +
          "px;\" ",
    );
    outputBuffer.writeln(
      currentLineClrStr.toString() + _currentFillClrStr.toString() + ">" + text + "</text>",
    );
  }

  @override
  void drawPoint(
    double x,
    double y,
  ) {
    // ignore: parameter_assignments
    x = transX(x);
    // ignore: parameter_assignments
    y = transY(y);
    final r = () {
      if (currentPointSize <= 1.0) {
        return 1.0;
      } else {
        return currentPointSize;
      }
    }();
    outputBuffer.writeln(
      "<circle cx=\"" +
          x.toString() +
          "\" cy=\"" +
          y.toString() +
          "\" r=\"" +
          r.toString() +
          "\" " +
          currentPointClrStr! +
          " />",
    );
  }

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

  @override
  void drawLine(
    final double x1,
    final double y1,
    final double x2,
    final double y2,
  ) {
    final tx1 = transX(x1);
    final ty1 = transY(y1);
    final tx2 = transX(x2);
    final ty2 = transY(y2);
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
    _writeLine(tx1, ty1, tx2, ty2);
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
        _writeLine(tx2, ty2, tx3 + dx3, ty3 + dy3);
        _writeLine(tx2, ty2, tx3 - dx3, ty3 - dy3);
      }
    }
  }

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

  @override
  void drawRect(
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    // ignore: parameter_assignments
    x1 = transX(x1);
    // ignore: parameter_assignments
    y1 = transY(y1);
    // ignore: parameter_assignments
    x2 = transX(x2);
    // ignore: parameter_assignments
    y2 = transY(y2);
    final width = x2 - x1;
    final height = y1 - y2;
    outputBuffer.writeln(
      "<rect x=\"" +
          x1.toString() +
          "\" y=\"" +
          y2.toString() +
          "\" width=\"" +
          width.toString() +
          "\" height=\"" +
          height.toString() +
          "\" " +
          _currentFillClrStr! +
          currentLineClrStr! +
          "/>",
    );
  }

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

  void _drawEllipse(
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    // ignore: parameter_assignments
    x1 = transX(x1);
    // ignore: parameter_assignments
    y1 = transY(y1);
    // ignore: parameter_assignments
    x2 = transX(x2);
    // ignore: parameter_assignments
    y2 = transY(y2);
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
      final x2 = transX(cx + r);
      final y2 = transY(cy + r);
      cx = transX(cx);
      cy = transY(cy);
      final rx = (x2 - cx).abs();
      final ry = (y2 - cy).abs();
      _writeEllipse(cx, cy, rx, ry);
    }
  }

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
      final x2 = transX(cx + radius);
      final y2 = transY(cy + radius);
      cx = transX(cx);
      cy = transY(cy);
      final rx = (x2 - cx).abs();
      final ry = (y2 - cy).abs();
      _writeEllipse(cx, cy, rx, ry);
    }
  }

  @override
  void drawPoly(
    final List<double> xCoords,
    final List<double> yCoords,
  ) {
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
    final int count = xCoords.length;
    if (count >= 3) {
      double x = transX(xCoords[0]);
      double y = transY(yCoords[0]);
      outputBuffer.write("<polygon points=\"$x,$y");
      for (int i = 1; i < count; ++i) {
        x = transX(xCoords[i]);
        y = transY(yCoords[i]);
        outputBuffer.write(" $x,$y");
      }
      outputBuffer.writeln("\" $_currentFillClrStr$currentLineClrStr/>");
      if (currentShouldDrawDirectedLines) {
        double x1 = xCoords[count - 1];
        double y1 = yCoords[count - 1];
        double tx1 = transX(x1);
        double ty1 = transY(y1);
        for (int i = 0; i < count; ++i) {
          final x2 = xCoords[i];
          final y2 = yCoords[i];
          final tx2 = transX(x2);
          final ty2 = transY(y2);
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

  @override
  void drawStrip(
    final List<double> xCoords,
    final List<double> yCoords,
  ) {
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
    final count = xCoords.length;
    if (count >= 2) {
      double x = transX(xCoords[0]);
      double y = transY(yCoords[0]);
      outputBuffer.write("<polyline points=\"" + x.toString() + "," + y.toString());
      for (int i = 1; i < count; ++i) {
        x = transX(xCoords[i]);
        y = transY(yCoords[i]);
        outputBuffer.write(" $x,$y");
      }
      outputBuffer.writeln("\" fill=\"none\" " + currentLineClrStr! + "/>");
      if (currentShouldDrawDirectedLines) {
        double x1 = xCoords[0];
        double y1 = yCoords[0];
        double tx1 = transX(x1);
        double ty1 = transY(y1);
        for (int i = 1; i < count; ++i) {
          final x2 = xCoords[i];
          final y2 = yCoords[i];
          final tx2 = transX(x2);
          final ty2 = transY(y2);
          _drawTransLine(x1, y1, x2, y2, tx1, ty1, tx2, ty2);
          x1 = x2;
          y1 = y2;
          tx1 = tx2;
          ty1 = ty2;
        }
      }
    }
    if (currentPointSize > 1.0) {
      drawPoints(
        xCoords,
        yCoords,
      );
    }
  }

  /// Finishes the render and applies the SVG.
  String finalize() => outputBuffer.toString();

  /// Translates the given x value by the current transformer.
  double transX(
    final double x,
  ) =>
      transform!.transformX(x);

  /// Translates the given y value by the current transformer.
  double transY(
    final double y,
  ) =>
      drawPanelBounds!.ymax - transform!.transformY(y);

  /// Writes a line SVG to the buffer.
  void _writeLine(
    final double x1,
    final double y1,
    final double x2,
    final double y2,
  ) =>
      outputBuffer.writeln(
        "<line x1=\"" +
            x1.toString() +
            "\" y1=\"" +
            y1.toString() +
            "\" x2=\"" +
            x2.toString() +
            "\" y2=\"" +
            y2.toString() +
            "\" " +
            currentLineClrStr! +
            "/>",
      );

  /// Writes an ellipse SVG to the buffer.
  void _writeEllipse(
    final double cx,
    final double cy,
    final double rx,
    final double ry,
  ) =>
      outputBuffer.writeln(
        "<ellipse cx=\"" +
            cx.toString() +
            "\" cy=\"" +
            cy.toString() +
            "\" rx=\"" +
            rx.toString() +
            "\" ry=\"" +
            ry.toString() +
            "\" " +
            _currentFillClrStr! +
            currentLineClrStr! +
            "/>",
      );
}

/// Gets the SVG color string for the given color.
String _color_to_svg_string(
  final Color color,
) {
  final r = (color.red * 255.0).floor();
  final g = (color.green * 255.0).floor();
  final b = (color.blue * 255.0).floor();
  return "rgb(" + r.toString() + ", " + g.toString() + ", " + b.toString() + ")";
}
