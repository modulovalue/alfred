import '../point/point.dart';
import '../point/point_impl.dart';
import 'edge.dart';

/// An edge represents a directed line segment between two integer points.
class QTEdgeImpl implements QTEdge, Comparable<QTEdgeImpl> {
  /// Gets the squared length of this edge.
  static double length2(QTEdge edge) => QTPointImpl.distance2(edge.start, edge.end);

  /// Determines if the start and end points are the same.
  /// Returns true if the edge has no length, false otherwise.
  static bool degenerate(QTEdge edge) => (edge.x1 == edge.x2) && (edge.y1 == edge.y2);

  /// Compares the two given lines.
  /// Returns 1 if the first line is greater than the the second line,
  /// -1 if the first line is less than the the second line,
  /// 0 if the first line is the same as the the second line.
  static int compare(QTEdge a, QTEdge b) {
    if (a.x1 > b.x1) {
      return 1;
    } else if (a.x1 < b.x1) {
      return -1;
    } else if (a.y1 > b.y1) {
      return 1;
    } else if (a.y1 < b.y1) {
      return -1;
    } else if (a.x2 > b.x2) {
      return 1;
    } else if (a.x2 < b.x2) {
      return -1;
    } else if (a.y2 > b.y2) {
      return 1;
    } else if (a.y2 < b.y2) {
      return -1;
    } else {
      return 0;
    }
  }

  /// Checks the equality of the two given edges.
  /// [undirected] indicates if true to compare the edges undirected, false to compare directed.
  static bool equals(QTEdge? a, QTEdge? b, bool undirected) {
    if (a == null) {
      return b == null;
    } else if (b == null) {
      return false;
    } else {
      if ((a.x1 == b.x1) && (a.y1 == b.y1) && (a.x2 == b.x2) && (a.y2 == b.y2)) {
        return true;
      } else if (undirected) {
        return (a.x1 == b.x2) && (a.y1 == b.y2) && (a.x2 == b.x1) && (a.y2 == b.y1);
      } else {
        return false;
      }
    }
  }

  /// Checks if one edge is the opposite of the other edge.
  static bool opposites(QTEdge? a, QTEdge? b) {
    if (a == null) {
      return b == null;
    } else if (b == null) {
      return false;
    } else {
      return (a.x1 == b.x2) && (a.y1 == b.y2) && (a.x2 == b.x1) && (a.y2 == b.y1);
    }
  }

  /// Gets the minimum squared distance between the point and the edge.
  static double distance2(QTEdge edge, QTPoint point) {
    double dx, dy;
    final double leng2 = QTEdgeImpl.length2(edge);
    if (leng2 <= 0.0) {
      dx = (edge.x1 - point.x).toDouble();
      dy = (edge.y1 - point.y).toDouble();
    } else {
      final double r = ((point.x - edge.x1) * edge.dx + (point.y - edge.y1) * edge.dy) / leng2;
      if (r <= 0.0) {
        dx = (edge.x1 - point.x).toDouble();
        dy = (edge.y1 - point.y).toDouble();
      } else if (r >= 1.0) {
        dx = (edge.x2 - point.x).toDouble();
        dy = (edge.y2 - point.y).toDouble();
      } else {
        dx = edge.x1 + r * edge.dx - point.x;
        dy = edge.y1 + r * edge.dy - point.y;
      }
    }
    return dx * dx + dy * dy;
  }

  /// Finds the start point based cross product for the given edges.
  /// Returs the z component of the cross product vector for the two given edges.
  static double cross(QTEdge edge1, QTEdge edge2) =>
      QTPointImpl.cross(QTPointImpl(edge1.dx, edge1.dy), QTPointImpl(edge2.dx, edge2.dy));

  /// Finds the start point based dot product for the given edges.
  /// Returns the dot product vector for the two given edges.
  static double dot(QTEdge edge1, QTEdge edge2) =>
      QTPointImpl.dot(QTPointImpl(edge1.dx, edge1.dy), QTPointImpl(edge2.dx, edge2.dy));

  /// Determines if the two edges are acute or not.
  /// Returns true if the two edges are acute (<90), false if not.
  static bool acute(QTEdge edge1, QTEdge edge2) => dot(edge1, edge2) > 0.0;

  /// Determines if the two edges are obtuse or not.
  /// Returns true if the two edges are obtuse (>90), false if not.
  static bool obtuse(QTEdge edge1, QTEdge edge2) => dot(edge1, edge2) < 0.0;

  /// The start point of the edge.
  final QTPoint _start;

  /// The end point of the edge.
  final QTPoint _end;

  /// Any additional data that this edge should contain.
  @override
  Object? data;

  /// Creates a new edge.
  QTEdgeImpl(this._start, this._end, [this.data]);

  /// Gets the first component of the start point of the edge.
  @override
  int get x1 => _start.x;

  /// Gets the second component of the start point of the edge.
  @override
  int get y1 => _start.y;

  /// Gets the first component of the end point of the edge.
  @override
  int get x2 => _end.x;

  /// Gets the second component of the end point of the edge.
  @override
  int get y2 => _end.y;

  /// Gets the start point for this edge.
  @override
  QTPoint get start => _start;

  /// Gets the end point for this edge.
  @override
  QTPoint get end => _end;

  /// Gets the change in the first component, delta X.
  @override
  int get dx => x2 - x1;

  /// Gets the change in the second component, delta Y.
  @override
  int get dy => y2 - y1;

  /// Gets the opposite direction edge.
  QTEdgeImpl get opposite => QTEdgeImpl(_end, _start);

  /// Compares the given line with this line.
  /// Returns 1 if this line is greater than the other line,
  /// -1 if this line is less than the other line,
  /// 0 if this line is the same as the other line.
  @override
  int compareTo(QTEdgeImpl other) => compare(this, other);

  /// Gets the string for this edge.
  @override
  String toString() => "[$x1, $y1, $x2, $y2]";
}
