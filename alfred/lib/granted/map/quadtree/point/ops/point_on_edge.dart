import '../../basic/qt_edge.dart';
import '../qt_point.dart';
import 'equals.dart';

/// Gets the intersection location of the given point on the edge.
PointOnEdgeResult pointOnEdge(final QTEdge edge, final QTPoint point) {
  if (qtEdgeDegenerate(edge)) {
    // TODO don't throw.
    return throw Exception("degenerate edge");
  } else if (pointEquals(point, edge.start)) {
    return PointOnEdgeResultImpl(edge, point, IntersectionLocation.AtStart, point, true, point, true);
  } else if (pointEquals(point, edge.end)) {
    return PointOnEdgeResultImpl(edge, point, IntersectionLocation.AtEnd, point, true, point, true);
  } else {
    // Calculate closest point on the edge's line.
    // The denominator can't be zero because the edge isn't degenerate.
    final dx = edge.dx.toDouble();
    final dy = edge.dy.toDouble();
    final numer = (point.x - edge.x1) * dx + (point.y - edge.y1) * dy;
    final denom = dx * dx + dy * dy;
    final t = numer / denom;
    final x = (edge.x1 + t * dx).round();
    final y = (edge.y1 + t * dy).round();
    QTPoint closestOnLine = QTPointImpl(x, y);
    bool onLine = false;
    if (pointEquals(closestOnLine, point)) {
      closestOnLine = point;
      onLine = true;
    }
    final closestOnEdge = closestOnLine;
    bool onEdge = onLine;
    IntersectionLocation location;
    if (pointEquals(closestOnLine, edge.start)) {
      location = IntersectionLocation.AtStart;
    } else if (pointEquals(closestOnLine, edge.end)) {
      location = IntersectionLocation.AtEnd;
    } else if (t <= 0.0) {
      location = IntersectionLocation.BeforeStart;
      closestOnLine = edge.start;
      onEdge = false;
    } else if (t >= 1.0) {
      location = IntersectionLocation.PastEnd;
      closestOnLine = edge.end;
      onEdge = false;
    } else {
      location = IntersectionLocation.InMiddle;
    }
    return PointOnEdgeResultImpl(edge, point, location, closestOnEdge, onEdge, closestOnLine, onLine);
  }
}

/// The multiple results from a point on the edge method call.
abstract class PointOnEdgeResult {
  /// The edge the point is close to.
  QTEdge get edge;

  /// The query point for the edge.
  QTPoint get point;

  /// The point intersection location relative to the edge.
  IntersectionLocation get location;

  /// The point on the edge that is the closest to the query point.
  QTPoint get closestOnEdge;

  /// Indicates if the query point is the same as the closest point, meaning
  /// the query point is on the edge.
  bool get onEdge;

  /// The point on the line that is the closest to the query point.
  QTPoint get closestOnLine;

  /// Indicates if the query point is the same as the closest point, meaning
  /// the query point is on the line.
  bool get onLine;

  /// Checks if the other point on edge results are the same as this one.
  bool equals(
    final Object? o,
  );
}

/// The multiple results from a point on the edge method call.
class PointOnEdgeResultImpl implements PointOnEdgeResult {
  /// This checks if the given point on edge results are the same.
  static bool equalResults(final PointOnEdgeResult? a, final PointOnEdgeResult? b) {
    if (a == null) {
      return b == null;
    }
    return a.equals(b);
  }

  /// The edge the point is close to.
  @override
  final QTEdge edge;

  /// The query point for the edge.
  @override
  final QTPoint point;

  /// The point intersection location relative to the edge.
  @override
  final IntersectionLocation location;

  /// The point on the edge that is the closest to the query point.
  @override
  final QTPoint closestOnEdge;

  /// Indicates if the query point is the same as the closest point, meaning
  /// the query point is on the edge.
  @override
  final bool onEdge;

  /// The point on the line that is the closest to the query point.
  @override
  final QTPoint closestOnLine;

  /// Indicates if the query point is the same as the closest point, meaning
  /// the query point is on the line.
  @override
  final bool onLine;

  /// Creates the result container.
  PointOnEdgeResultImpl(
    this.edge,
    this.point,
    this.location,
    this.closestOnEdge,
    this.onEdge,
    this.closestOnLine,
    this.onLine,
  );

  /// Checks if the other point on edge results are the same as this one.
  @override
  bool equals(
    final Object? o,
  ) {
    if (o == null) return false;
    if (o is PointOnEdgeResult) return false;
    final other = o as PointOnEdgeResult;
    if (!qtEdgeEquals(edge, other.edge, false)) return false;
    if (!pointEquals(point, other.point)) return false;
    if (location != other.location) return false;
    if (!pointEquals(closestOnEdge, other.closestOnEdge)) return false;
    if (onEdge != other.onEdge) return false;
    if (!pointEquals(closestOnLine, other.closestOnLine)) return false;
    if (onLine != other.onLine) return false;
    return true;
  }

  /// Gets the string for this point on edge result.
  @override
  String toString() =>
      "(edge:" +
      edge.toString() +
      ", point:" +
      point.toString() +
      ", " +
      location.toString() +
      ", onEdge(" +
      closestOnEdge.toString() +
      ", " +
      onEdge.toString() +
      "), onLine(" +
      closestOnLine.toString() +
      ", " +
      onLine.toString() +
      "))";
}

/// Indicates where an intersection occurs on an edge.
enum IntersectionLocation {
  /// Intersection type not set, not determined, or not determinable.
  None,

  /// Intersection occurs in edge's line before the edge's start point.
  BeforeStart,

  /// Intersection occurs within edge.
  InMiddle,

  /// Intersection occurs in edge's line past the edge's end point.
  PastEnd,

  /// Intersection occurs at the edge's start point.
  AtStart,

  /// Intersection occurs at the edge's end point.
  AtEnd
}
