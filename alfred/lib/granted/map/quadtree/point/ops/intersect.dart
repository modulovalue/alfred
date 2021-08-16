import '../../edge/impl.dart';
import '../../edge/interface.dart';
import '../impl.dart';
import '../interface.dart';
import 'equals.dart';
import 'point_on_edge.dart';

/// Determines the way the two given edges intersect.
IntersectionResult? intersect(
  final QTEdge? edgeA,
  final QTEdge? edgeB,
) {
  if ((edgeA == null) || qtEdgeDegenerate(edgeA)) {
    return null;
  } else if ((edgeB == null) || qtEdgeDegenerate(edgeB)) {
    return null;
  } else {
    final startBOnEdgeA = pointOnEdge(edgeA, edgeB.start);
    final endBOnEdgeA = pointOnEdge(edgeA, edgeB.end);
    final startAOnEdgeB = pointOnEdge(edgeB, edgeA.start);
    final endAOnEdgeB = pointOnEdge(edgeB, edgeA.end);
    bool intersects;
    IntersectionType intType;
    QTPoint? intPnt;
    IntersectionLocation locA;
    IntersectionLocation locB;
    final dAx = edgeA.dx;
    final dAy = edgeA.dy;
    final dBx = edgeB.dx;
    final dBy = edgeB.dy;
    final denom = (dAx * dBy) - (dAy * dBx);
    if (startBOnEdgeA.onEdge) {
      if (endBOnEdgeA.onEdge) {
        if (startAOnEdgeB.onEdge) {
          if (endAOnEdgeB.onEdge) {
// OnEdge: startBOnEdgeA, endBOnEdgeA, startAOnEdgeB, and endAOnEdgeB
// The only way that all four points could be on the edges
// is if the edges are the same or opposite.
            intersects = true;
            locA = IntersectionLocation.None;
            locB = IntersectionLocation.None;
            intPnt = null;
            if (startBOnEdgeA.location == IntersectionLocation.AtStart) {
              intType = IntersectionType.Same;
// ignore: prefer_asserts_with_message
              assert(pointEquals(edgeA.start, edgeB.start));
// ignore: prefer_asserts_with_message
              assert(pointEquals(edgeA.end, edgeB.end));
            } else {
              intType = IntersectionType.Opposite;
// ignore: prefer_asserts_with_message
              assert(pointEquals(edgeA.start, edgeB.end));
// ignore: prefer_asserts_with_message
              assert(pointEquals(edgeA.end, edgeB.start));
            }
          } else {
// OnEdge: startBOnEdgeA, endBOnEdgeA, and startAOnEdgeB
// If there are three points on an edge, then the edges coincide.
            intersects = true;
            locA = IntersectionLocation.None;
            locB = IntersectionLocation.None;
            intPnt = null;
            intType = IntersectionType.Coincide;
          }
        } else if (endAOnEdgeB.onEdge) {
// OnEdge: startBOnEdgeA, endBOnEdgeA, and endAOnEdgeB
// If there are three points on an edge, then the edges coincide.
          intersects = true;
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
// OnEdge: startBOnEdgeA, and endBOnEdgeA
// Since both points on the same edge are on the other one edge is contained by the other.
          intersects = true;
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        }
      } else if (startAOnEdgeB.onEdge) {
        if (endAOnEdgeB.onEdge) {
// OnEdge: startBOnEdgeA, startAOnEdgeB, and endAOnEdgeB
// If there are three points on an edge, then the edges coincide.
          intersects = true;
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
// OnEdge: startBOnEdgeA, and startAOnEdgeB
// Since only two points overlap the edges are either partially
// coincident or they touch at the start point.
          intersects = true;
          if ((startBOnEdgeA.location == IntersectionLocation.InMiddle) ||
              (startAOnEdgeB.location == IntersectionLocation.InMiddle)) {
            locA = IntersectionLocation.None;
            locB = IntersectionLocation.None;
            intPnt = null;
            intType = IntersectionType.Coincide;
          } else {
            locA = IntersectionLocation.AtStart;
            locB = IntersectionLocation.AtStart;
            intPnt = edgeA.start;
            intType = () {
              if (denom == 0) {
                return IntersectionType.Collinear;
              } else {
                return IntersectionType.Point;
              }
            }();
// ignore: prefer_asserts_with_message
            assert(pointEquals(edgeA.start, edgeB.start));
          }
        }
      } else if (endAOnEdgeB.onEdge) {
// OnEdge: startBOnEdgeA, and endAOnEdgeB
// Since only two points overlap the edges are either partially
// coincident or they touch at the start point.
        intersects = true;
        if ((startBOnEdgeA.location == IntersectionLocation.InMiddle) ||
            (endAOnEdgeB.location == IntersectionLocation.InMiddle)) {
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
          locA = IntersectionLocation.AtEnd;
          locB = IntersectionLocation.AtStart;
          intPnt = edgeB.start;
          intType = () {
            if (denom == 0) {
              return IntersectionType.Collinear;
            } else {
              return IntersectionType.Point;
            }
          }();
// ignore: prefer_asserts_with_message
          assert(pointEquals(edgeB.start, edgeA.end));
        }
      } else {
// OnEdge: startBOnEdgeA
// Since only one point is on an edge that point must be the
// intersection in the middle of the edge.
        intersects = true;
        locA = IntersectionLocation.InMiddle;
        locB = IntersectionLocation.AtStart;
        intPnt = edgeB.start;
        intType = IntersectionType.Point;
// ignore: prefer_asserts_with_message
        assert(startBOnEdgeA.location == IntersectionLocation.InMiddle);
      }
    } else if (endBOnEdgeA.onEdge) {
      if (startAOnEdgeB.onEdge) {
        if (endAOnEdgeB.onEdge) {
// OnEdge: endBOnEdgeA, startAOnEdgeB, and endAOnEdgeB
// If there are three points on an edge, then the edges coincide.
          intersects = true;
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
// OnEdge: endBOnEdgeA, and startAOnEdgeB
// Since only two points overlap the edges are either partially
// coincident or they touch at the start point.
          intersects = true;
          if ((endBOnEdgeA.location == IntersectionLocation.InMiddle) ||
              (startAOnEdgeB.location == IntersectionLocation.InMiddle)) {
            locA = IntersectionLocation.None;
            locB = IntersectionLocation.None;
            intPnt = null;
            intType = IntersectionType.Coincide;
          } else {
            locA = IntersectionLocation.AtStart;
            locB = IntersectionLocation.AtEnd;
            intPnt = edgeA.start;
            intType = () {
              if (denom == 0) {
                return IntersectionType.Collinear;
              } else {
                return IntersectionType.Point;
              }
            }();
// ignore: prefer_asserts_with_message
            assert(pointEquals(edgeA.start, edgeB.end));
          }
        }
      } else if (endAOnEdgeB.onEdge) {
// OnEdge: endBOnEdgeA, and endAOnEdgeB
// Since only two points overlap the edges are either partially
// coincident or they touch at the start point.
        intersects = true;
        if ((endBOnEdgeA.location == IntersectionLocation.InMiddle) ||
            (endAOnEdgeB.location == IntersectionLocation.InMiddle)) {
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
          locA = IntersectionLocation.AtEnd;
          locB = IntersectionLocation.AtEnd;
          intPnt = edgeA.end;
          intType = () {
            if (denom == 0) {
              return IntersectionType.Collinear;
            } else {
              return IntersectionType.Point;
            }
          }();
// ignore: prefer_asserts_with_message
          assert(pointEquals(edgeA.end, edgeB.end));
        }
      } else {
// OnEdge: endBOnEdgeA
// Since only one point is on an edge that point must be the
// intersection in the middle of the edge.
        intersects = true;
        locA = IntersectionLocation.InMiddle;
        locB = IntersectionLocation.AtEnd;
        intPnt = edgeB.end;
        intType = IntersectionType.Point;
// ignore: prefer_asserts_with_message
        assert(endBOnEdgeA.location == IntersectionLocation.InMiddle);
      }
    } else if (startAOnEdgeB.onEdge) {
      if (endAOnEdgeB.onEdge) {
// OnEdge: startAOnEdgeB, and endAOnEdgeB
// Since both points on the same edge are on the other one edge is contained by the other.
        intersects = true;
        locA = IntersectionLocation.None;
        locB = IntersectionLocation.None;
        intPnt = null;
        intType = IntersectionType.Coincide;
      } else {
// OnEdge: startAOnEdgeB
// Since only one point is on an edge that point must be the
// intersection in the middle of the edge.
        intersects = true;
        locA = IntersectionLocation.AtStart;
        locB = IntersectionLocation.InMiddle;
        intPnt = edgeA.start;
        intType = IntersectionType.Point;
// ignore: prefer_asserts_with_message
        assert(startAOnEdgeB.location == IntersectionLocation.InMiddle);
      }
    } else if (endAOnEdgeB.onEdge) {
// OnEdge: endAOnEdgeB
// Since only one point is on an edge that point must be the
// intersection in the middle of the edge.
      intersects = true;
      locA = IntersectionLocation.AtEnd;
      locB = IntersectionLocation.InMiddle;
      intPnt = edgeA.end;
      intType = IntersectionType.Point;
// ignore: prefer_asserts_with_message
      assert(endAOnEdgeB.location == IntersectionLocation.InMiddle);
    } else if (denom == 0) {
// If there are no points on edge but the lines are parallel.
      intersects = false;
      locA = IntersectionLocation.None;
      locB = IntersectionLocation.None;
      intPnt = null;
      if (startBOnEdgeA.onLine) {
        intType = IntersectionType.Collinear;
      } else {
        intType = IntersectionType.Parallel;
      }
    } else {
// Lines intersect at a point.
      final dABx = edgeA.x1 - edgeB.x1;
      final dABy = edgeA.y1 - edgeB.y1;
      final numA = (dABy * dBx) - (dABx * dBy);
      final rA = numA / denom;
// Calculate the point of intersection.
      intPnt = QTPointImpl((edgeA.x1 + rA * dAx).round(), (edgeA.y1 + rA * dAy).round());
      final numB = (dABy * dAx) - (dABx * dAy);
      final rB = numB / denom;
// Find location of intersection location on edgeA.
      if (pointEquals(intPnt, edgeA.start)) {
        locA = IntersectionLocation.AtStart;
        intersects = true;
      } else if (pointEquals(intPnt, edgeA.end)) {
        locA = IntersectionLocation.AtEnd;
        intersects = true;
      } else if (rA <= 0.0) {
        locA = IntersectionLocation.BeforeStart;
        intersects = false;
      } else if (rA >= 1.0) {
        locA = IntersectionLocation.PastEnd;
        intersects = false;
      } else {
        locA = IntersectionLocation.InMiddle;
        intersects = true;
      }
      // Find location of intersection location on edgeB.
      if (pointEquals(intPnt, edgeB.start)) {
        locB = IntersectionLocation.AtStart;
      } else if (pointEquals(intPnt, edgeB.end)) {
        locB = IntersectionLocation.AtEnd;
      } else if (rB <= 0.0) {
        locB = IntersectionLocation.BeforeStart;
        intersects = false;
      } else if (rB >= 1.0) {
        locB = IntersectionLocation.PastEnd;
        intersects = false;
      } else {
        locB = IntersectionLocation.InMiddle;
      }
      if (intersects) {
        intType = IntersectionType.Point;
      } else {
        intType = IntersectionType.None;
      }
    }
    return IntersectionResultImpl(
      edgeA,
      edgeB,
      intersects,
      intType,
      intPnt,
      locA,
      locB,
      startBOnEdgeA,
      endBOnEdgeA,
      startAOnEdgeB,
      endAOnEdgeB,
    );
  }
}

/// The result information for a two edge intersection.
abstract class IntersectionResult {
  /// The first edge in the intersection.
  QTEdge get edgeA;

  /// The second edge in the intersection.
  QTEdge get edgeB;

  /// True if the edges intersect within the edges,
  /// false if not even if infinite lines intersect.
  bool get intersects;

  /// The type of intersection.
  IntersectionType get type;

  /// The intersection point or null if no intersection.
  QTPoint? get point;

  /// The location on the first edge that the second edge intersects it.
  IntersectionLocation get locA;

  /// The location on the second edge that the first edge intersects it.
  IntersectionLocation get locB;

  /// The location the second edge's start point is on the first edge.
  PointOnEdgeResult get startBOnEdgeA;

  /// The location the second edge's end point is on the first edge.
  PointOnEdgeResult get endBOnEdgeA;

  /// The location the first edge's start point is on the second edge.
  PointOnEdgeResult get startAOnEdgeB;

  /// The location the first edge's end point is on the second edge.
  PointOnEdgeResult get endAOnEdgeB;

  /// Compares this intersection with the other intersection.
  /// Returns 1 if this intersection's edges are larger,
  /// -1 if the other intersection is larger,
  /// 0 if they have the same edges.
  int compareTo(
    final IntersectionResult o,
  );

  /// Checks if this intersection is the same as the other intersection.
  /// Returns true if the two intersection results are the same, false otherwise.
  bool equals(
    final Object? o,
  );

  /// Gets the string of for this intersection result.
  @override
  String toString([
    final String separator = ", ",
  ]);
}

/// The types of intersections between two lines.
enum IntersectionType {
  /// The intersect between two the two edges could not be determined.
  None,

  /// The two edges are the same.
  Same,

  /// The two edges are the opposite.
  Opposite,

  /// The two lines defined with the given edges are parallel.
  Parallel,

  /// The two lines defined with the given edges share multiple points.
  Coincide,

  /// The two lines coincide but the edges don't touch.
  Collinear,

  /// The two lines defined with the given edges share a single a point.
  Point
}

class IntersectionResultImpl implements IntersectionResult {
  /// Checks if the two results are the same.
  static bool equalResults(
    final IntersectionResult? a,
    final IntersectionResult? b,
  ) {
    if (a == null) {
      return b == null;
    } else {
      return a.equals(b);
    }
  }

  /// The first edge in the intersection.
  @override
  final QTEdge edgeA;

  /// The second edge in the intersection.
  @override
  final QTEdge edgeB;

  /// True if the edges intersect within the edges,
  /// false if not even if infinite lines intersect.
  @override
  final bool intersects;

  /// The type of intersection.
  @override
  final IntersectionType type;

  /// The intersection point or null if no intersection.
  @override
  final QTPoint? point;

  /// The location on the first edge that the second edge intersects it.
  @override
  final IntersectionLocation locA;

  /// The location on the second edge that the first edge intersects it.
  @override
  final IntersectionLocation locB;

  /// The location the second edge's start point is on the first edge.
  @override
  final PointOnEdgeResult startBOnEdgeA;

  /// The location the second edge's end point is on the first edge.
  @override
  final PointOnEdgeResult endBOnEdgeA;

  /// The location the first edge's start point is on the second edge.
  @override
  final PointOnEdgeResult startAOnEdgeB;

  /// The location the first edge's end point is on the second edge.
  @override
  final PointOnEdgeResult endAOnEdgeB;

  /// Creates a new intersection result.
  IntersectionResultImpl(
    final this.edgeA,
    final this.edgeB,
    final this.intersects,
    final this.type,
    final this.point,
    final this.locA,
    final this.locB,
    final this.startBOnEdgeA,
    final this.endBOnEdgeA,
    final this.startAOnEdgeB,
    final this.endAOnEdgeB,
  );

  /// Compares this intersection with the other intersection.
  /// Returns 1 if this intersection's edges are larger,
  /// -1 if the other intersection is larger,
  /// 0 if they have the same edges.
  @override
  int compareTo(
    final IntersectionResult o,
  ) {
    final cmp = qtEdgeCompare(edgeA, o.edgeA);
    if (cmp != 0) {
      return cmp;
    } else {
      return qtEdgeCompare(edgeB, o.edgeB);
    }
  }

  /// Checks if this intersection is the same as the other intersection.
  /// Returns true if the two intersection results are the same, false otherwise.
  @override
  bool equals(
    final Object? o,
  ) {
    if (o == null) return false;
    if (o is IntersectionResult) return false;
    final other = o as IntersectionResult;
    if (!qtEdgeEquals(edgeA, other.edgeA, false)) return false;
    if (!qtEdgeEquals(edgeB, other.edgeB, false)) return false;
    if (intersects != other.intersects) return false;
    if (type != other.type) return false;
    if (locA != other.locA) return false;
    if (locB != other.locB) return false;
    if (!pointEquals(point, other.point)) return false;
    if (!PointOnEdgeResultImpl.equalResults(startBOnEdgeA, other.startBOnEdgeA)) return false;
    if (!PointOnEdgeResultImpl.equalResults(endBOnEdgeA, other.endBOnEdgeA)) return false;
    if (!PointOnEdgeResultImpl.equalResults(startAOnEdgeB, other.startAOnEdgeB)) return false;
    if (!PointOnEdgeResultImpl.equalResults(endAOnEdgeB, other.endAOnEdgeB)) return false;
    return true;
  }

  /// Gets the string of for this intersection result.
  @override
  String toString([
    final String separator = ", ",
  ]) {
    return "(edgeA:$edgeA, edgeB$edgeB, " +
        (() {
          if (intersects) {
            return "intersects";
          } else {
            return "misses";
          }
        }()) +
        ", $type, point:$point, $locA, $locB" +
        "${separator}startBOnEdgeA:$startBOnEdgeA" +
        "${separator}endBOnEdgeA:$endBOnEdgeA" +
        "${separator}startAOnEdgeB:$startAOnEdgeB" +
        "${separator}endAOnEdgeB:$endAOnEdgeB)";
  }
}

/// A set of edge nodes.
abstract class IntersectionSet {
  /// Contains an edge in the first, "A", intersection edge.
  bool constainsA(
    final QTEdge edge,
  );

  /// Contains an edge in the second, "B", intersection edge.
  bool constainsB(
    final QTEdge edge,
  );

  /// Formats the intersections into a string.
  void toBuffer(
    final StringBuffer sout,
    final String indent,
  );

  void add(
    final IntersectionResult result,
  );
}

class IntersectionSetImpl implements IntersectionSet {
  /// The internal set of results.
  final Set<IntersectionResult> _set;

  /// Create a set of edge nodes.
  IntersectionSetImpl() : _set = <IntersectionResult>{};

  /// Gets the internal set of results.
  Set<IntersectionResult> get results => _set;

  /// Contains an edge in the first, "A", intersection edge.
  @override
  bool constainsA(
    final QTEdge edge,
  ) {
    for (final inter in _set) {
      if (qtEdgeEquals(inter.edgeA, edge, false)) {
        return true;
      }
    }
    return false;
  }

  @override
  void add(
    final IntersectionResult result,
  ) =>
      results.add(result);

  /// Contains an edge in the second, "B", intersection edge.
  @override
  bool constainsB(
    final QTEdge edge,
  ) {
    for (final inter in _set) {
      if (qtEdgeEquals(inter.edgeB, edge, false)) {
        return true;
      }
    }
    return false;
  }

  /// Formats the intersections into a string.
  @override
  void toBuffer(
    final StringBuffer sout,
    final String indent,
  ) {
    bool first = true;
    for (final inter in _set) {
      if (first) {
        first = false;
      } else {
        sout.write("\n" + indent);
      }
      sout.write(inter.toString("\n" + indent + "   "));
    }
  }

  /// Formats the set into a string.
  @override
  String toString() {
    final sout = StringBuffer();
    toBuffer(sout, "");
    return sout.toString();
  }
}
