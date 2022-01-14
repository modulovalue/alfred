import '../basic/bounds.dart';
import '../basic/color.dart';
import '../basic/transformer.dart';

/// A renderer for drawing plots.
abstract class PlotterRenderer {
  PlotterDrawActions get actions;

  PlotterDrawState get state;
}

abstract class PlotterDrawState {
  /// The bounds of the panel being drawn on.
  Bounds? get drawPanelBounds;

  /// The viewport into the window with the given transformation.
  Bounds get viewportIntoWindow;

  /// The bounds of the data to set.
  abstract Bounds dataSetBounds;

  /// The transformer for the current data.
  abstract Transformer? transform;

  /// The point size to draw points with.
  abstract double currentPointSize;

  /// The background color to clear to.
  abstract Color currentBackgroundColor;

  /// The color to draw lines with.
  abstract Color? color;

  /// The color to fill shapes with.
  abstract Color? fillColor;

  /// The font toy draw text with.
  abstract String? currentFont;

  /// Indicates if the lines should be drawn directed (with arrows), or not.
  abstract bool currentShouldDrawDirectedLines;
}

abstract class PlotterDrawActions {
  /// Draws text to the viewport.
  void drawText(
    final double x,
    final double y,
    final double size,
    final String text,
    final bool scale,
  );

  /// Draws a point to the viewport.
  void drawPoint(
    final double x,
    final double y,
  );

  /// Draws a set of points to the viewport.
  void drawPoints(
    final List<double> xCoords,
    final List<double> yCoords,
  );

  /// Draws a line to the viewport.
  void drawLine(
    final double x1,
    final double y1,
    final double x2,
    final double y2,
  );

  /// Draws a set of lines to the viewport.
  void drawLines(
    final List<double> x1Coords,
    final List<double> y1Coords,
    final List<double> x2Coords,
    final List<double> y2Coords,
  );

  /// Draws a rectangle to the viewport.
  void drawRect(
    final double x1,
    final double y1,
    final double x2,
    final double y2,
  );

  /// Draws a set of rectangles to the viewport.
  void drawRects(
    final List<double> xCoords,
    final List<double> yCoords,
    final List<double> widths,
    final List<double> heights,
  );

  /// Draws a set of rectangles to the viewport.
  void drawRectSet(
    final List<double> xCoords,
    final List<double> yCoords,
    final double width,
    final double height,
  );

  /// Draws a set of ellipse to the viewport.
  void drawEllipse(
    final List<double> xCoords,
    final List<double> yCoords,
    final List<double> xRadii,
    final List<double> yRadii,
  );

  /// Draws a set of ellipse to the viewport.
  void drawEllipseSet(
    final List<double> xCoords,
    final List<double> yCoords,
    final double xRadius,
    final double yRadius,
  );

  /// Draws a set of circles to the viewport.
  void drawCircs(
    final List<double> xCoords,
    final List<double> yCoords,
    final List<double> radii,
  );

  /// Draws a set of circles to the viewport.
  void drawCircSet(
    final List<double> xCoords,
    final List<double> yCoords,
    final double radius,
  );

  /// Draws a polygon to the viewport.
  void drawPoly(
    final List<double> xCoords,
    final List<double> yCoords,
  );

  /// Draws a line strip to the viewport.
  void drawStrip(
    final List<double> xCoords,
    final List<double> yCoords,
  );
}
