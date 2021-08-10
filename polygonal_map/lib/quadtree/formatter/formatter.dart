import '../boundary/boundary.dart';
import '../edge/edge.dart';
import '../point/point.dart';

/// The interface for the formatting used for outputting data as strings.
abstract class QTFormatter {
  /// Converts a x value to a string.
  String toXString(
    final int x,
  );

  /// Converts a y value to a string.
  String toYString(
    final int y,
  );

  /// Converts a width value to a string.
  String toWidthString(
    final int width,
  );

  /// Converts a height value to a string.
  String toHeightString(
    final int height,
  );

  /// Converts a point to a string.
  String toPointString(
    final QTPoint point,
  );

  /// Converts an edge to a string.
  String toEdgeString(
    final QTEdge edge,
  );

  /// Converts a boundary to a string.
  String toBoundaryString(
    final QTBoundary boundary,
  );
}
