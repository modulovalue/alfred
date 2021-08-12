import '../point/interface.dart';

/// The interface for geometry and quad-tree edges.
abstract class QTEdge<T extends Object?> {
  /// Gets the x component of the start point of the edge.
  int get x1;

  /// Gets the y component of the start point of the edge.
  int get y1;

  /// Gets the x component of the end point of the edge.
  int get x2;

  /// Gets the y component of the end point of the edge.
  int get y2;

  /// Gets any additional data that this edge should contain.
  abstract T data;

  /// Gets the start point for this edge.
  QTPoint get start;

  /// Gets the end point for this edge.
  QTPoint get end;

  /// Gets the change in the first component, delta X.
  int get dx;

  /// Gets the change in the second component, delta Y.
  int get dy;
}
