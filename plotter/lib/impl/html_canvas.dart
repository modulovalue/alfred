import 'dart:html' as html;
import 'dart:math' as math;

import '../framework/events/events.dart';
import '../framework/events/events_impl.dart';
import '../framework/plotter/plotter.dart';
import '../framework/plotter/plotter_impl.dart';
import '../framework/primitives/primitives.dart';
import '../framework/primitives/primitives_impl.dart';

PlotCanvas buildPlotCanvas({
  required final String targetDivId,
  required final Plotter plot,
}) =>
    PlotCanvas.fromElem(
      html.querySelector('#' + targetDivId)!,
      plot,
    );

/// Plotter renderer which outputs to a canvas.
class PlotCanvas implements PlotterPlot {
  /// The target html div to write to.
  final html.Element _targetDiv;

  /// The canvas element.
  final html.CanvasElement _canvas;

  /// The plotter to render.
  final Plotter plotter;

  /// The renderer used to plot with.
  late _Renderer _renderer;

  /// Indicates that a refresh is pending.
  bool _pendingRender;

  /// Creates a plotter that outputs SVG.
  PlotCanvas.fromElem(
    final this._targetDiv,
    final this.plotter,
  )   : _canvas = html.CanvasElement(),
        _pendingRender = false {
    _canvas.style
      ..margin = "0px"
      ..padding = "0px"
      ..width = "100%"
      ..height = "100%";
    _canvas
      ..onResize.listen(_resize)
      ..onMouseDown.listen(_mouseDown)
      ..onMouseMove.listen(_mouseMove)
      ..onMouseUp.listen(_mouseUp)
      ..onMouseWheel.listen(_mouseWheelMoved);
    _renderer = _Renderer._((_canvas.getContext("2d") as html.CanvasRenderingContext2D?)!);
    html.window.onResize.listen(_resize);
    _targetDiv.append(_canvas);
    refresh();
  }

  /// Refreshes the canvas drawing.
  @override
  void refresh() {
    if (!_pendingRender) {
      _pendingRender = true;
      html.window.requestAnimationFrame(
        (t) {
          if (_pendingRender) {
            _pendingRender = false;
            _draw();
          }
        },
      );
    }
  }

  /// Draws to the target with SVG.
  void _draw() {
    _canvas.width = _width.floor();
    _canvas.height = _height.floor();
    _renderer.reset(_window, _projection);
    plotter.render(_renderer);
  }

  /// The width of the div that is being plotted to.
  double get _width {
    final box = _canvas.getBoundingClientRect();
    return (box.right - box.left).toDouble();
  }

  /// The height of the div that is being plotted to.
  double get _height {
    final box = _canvas.getBoundingClientRect();
    return (box.bottom - box.top).toDouble();
  }

  /// Gets the transformer for the plot target div.
  /// This is the projection from the view coordinates to the window coordinates.
  Transformer get _projection {
    final width = _width;
    final height = _height;
    double size = math.min(width, height);
    if (size <= 0.0) {
      size = 1.0;
    }
    return TransformerImpl(
      size,
      size,
      0.5 * width,
      0.5 * height,
    );
  }

  /// Gets the window size for the plot.
  Bounds get _window => BoundsImpl(
        0.0,
        0.0,
        _width,
        _height,
      );

  /// Called when the svg is resized.
  void _resize(
    final html.Event _,
  ) =>
      refresh();

  /// Creates a mouse event for a dart mouse event.
  MouseEvent _mouseLoc(
    final html.MouseEvent e,
  ) {
    final rect = _canvas.getBoundingClientRect();
    final local = html.Point(e.client.x - rect.left, e.client.y - rect.top);
    final viewProj = _projection.mul(plotter.view);
    return MouseEventImpl(
      _window,
      _projection,
      viewProj,
      local.x as double,
      local.y as double,
      MouseButtonStateImpl(
        button: e.button,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        altKey: e.altKey,
      ),
    );
  }

  /// Called when the mouse button is pressed on the panel.
  void _mouseDown(
    final html.MouseEvent e,
  ) {
    e.stopPropagation();
    e.preventDefault();
    final me = _mouseLoc(e);
    plotter.onMouseDown(me);
    if (me.redraw) {
      refresh();
    }
  }

  /// Called when the mouse is moved with the button down.
  void _mouseMove(
    final html.MouseEvent e,
  ) {
    e.stopPropagation();
    e.preventDefault();
    final me = _mouseLoc(e);
    plotter.onMouseMove(me);
    if (me.redraw) {
      refresh();
    }
  }

  /// Called when the mouse button is released.
  void _mouseUp(
    final html.MouseEvent e,
  ) {
    e.stopPropagation();
    e.preventDefault();
    final me = _mouseLoc(e);
    plotter.onMouseUp(me);
    if (me.redraw) {
      refresh();
    }
  }

  /// Called when the mouse wheel is moved.
  void _mouseWheelMoved(
    final html.WheelEvent e,
  ) {
    e.stopPropagation();
    e.preventDefault();
    final me = _mouseLoc(e);
    final dw = e.deltaY.toDouble() / 1000.0;
    plotter.onMouseWheel(me, dw);
    plotter.onMouseMove(me);
    if (me.redraw) {
      refresh();
    }
  }
}

/// A renderer for drawing canvas plots.
class _Renderer extends PlotterRenderer {
  /// The context to render with.
  final html.CanvasRenderingContext2D _context;

  /// The bounds of the panel.
  Bounds? _window;

  /// The bounds of the data.
  @override
  Bounds dataBounds;

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

  /// The current line color string.
  String? _lineClrStr;

  /// The current fill color or null for no fill.
  Color? _fillClr;

  /// The current fill color string or empty for no fill.
  String? _fillClrStr;

  /// The current font to draw text with.
  @override
  String? font;

  /// Indicates if the lines should be drawn directed (with arrows), or not.
  @override
  bool directedLines;

  /// Creates a new renderer.
  _Renderer._(
    final this._context,
  )   : dataBounds = BoundsImpl.empty(),
        pointSize = 0.0,
        backgroundColor = ColorImpl(1.0, 1.0, 1.0),
        font = "Verdana",
        directedLines = false {
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
    _context.fillStyle = _getColorString(backgroundColor);
    _context.fillRect(0, 0, window.width, window.height);
  }

  /// Gets the bounds of the panel being drawn on.
  @override
  Bounds get window => _window!;

  /// Gets the viewport into the window with the given transformation.
  @override
  Bounds get viewport => transform!.untransform(_window!);

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
    if (scale) {
      final x2 = _transX(x + size);
      // ignore: parameter_assignments
      x = _transX(x);
      // ignore: parameter_assignments
      y = _transY(y);
      // ignore: parameter_assignments
      size = (x2 - x).abs();
    }
    _context.beginPath();
    _context.strokeStyle = _lineClrStr;
    _context.fillStyle = _fillClrStr;
    _context.font = "${size}px " + font!;
    if (_fillClr != null) _context.fillText(text, x, y);
    _context.strokeText(text, x, y);
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
    final r = () {
      if (pointSize <= 1.0) {
        return 1.0;
      } else {
        return pointSize;
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
    _drawTransLine(x1, y1, x2, y2, tx1, ty1, tx2, ty2);
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
    _context.strokeStyle = _lineClrStr;
    _context.fillStyle = "";
    _context.beginPath();
    _context.moveTo(tx1, ty1);
    _context.lineTo(tx2, ty2);
    if (directedLines) {
      double dx = x2 - x1;
      double dy = y2 - y1;
      final length = math.sqrt((dx * dx) + (dy * dy));
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
    if (pointSize > 1.0) drawPoints(xCoords, yCoords);
  }

  /// Draws a line strip to the viewport.
  @override
  void drawStrip(
    final List<double> xCoords,
    final List<double> yCoords,
  ) {
    // ignore: prefer_asserts_with_message
    assert(xCoords.length == yCoords.length);
    final int count = xCoords.length;
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

const double _tau = 2.0 * math.pi;
