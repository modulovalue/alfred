import '../../edge/edge.dart';
import '../point.dart';
import '../point_impl.dart';

/// Gets the side of the edge the given point is on.
Side side(QTEdge edge, QTPoint point) {
  final double value =
      QTPointImpl.cross(QTPointImpl(edge.dx, edge.dy), QTPointImpl(point.x - edge.x1, point.y - edge.y1));
  const double epsilon = 1.0e-12;
  if (value.abs() <= epsilon) {
    return Side.Inside;
  } else if (value < 0.0) {
    return Side.Right;
  } else {
    return Side.Left;
  } // value > 0.0
}

/// The side of the edge that a point can be.
/// The side is determined by looking down the edge
/// from the start point towards the end point.
enum Side {
  /// The point is to the left of the edge.
  Left,

  /// The point is to the right of the edge.
  Right,

  /// The point is on the edge.
  Inside
}
