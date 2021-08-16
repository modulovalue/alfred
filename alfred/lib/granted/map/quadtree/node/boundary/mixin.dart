import '../../boundary/impl.dart';
import '../../boundary/interface.dart';
import '../../boundary_region/interface.dart';
import '../../edge/interface.dart';
import '../../first_left_edge_args/interface.dart';
import '../../handler_edge/interface.dart';
import '../../point/interface.dart';
import '../../point/ops/intersect.dart';
import '../branch/interface.dart';
import '../edge/interface.dart';
import 'interface.dart';

/// This is the base node for all non-empty nodes.
mixin QTNodeBoundaryMixin implements QTNodeBoundary {
  /// The minimum X location of this node.
  int _xmin = 0;

  /// The minimum Y location of this node.
  int _ymin = 0;

  /// The width and height of this node.
  int _size = 1;

  /// The parent of this node.
  @override
  BranchNode? parent;

  @override
  int get depth {
    int depth = 0;
    QTNodeBoundary? _parent = this.parent;
    while (_parent != null) {
      _parent = _parent.parent;
      ++depth;
    }
    return depth;
  }

  @override
  QTNodeBoundary? get root {
    QTNodeBoundary? cur = this;
    for (;;) {
      final parent = cur?.parent;
      if (parent == null) {
        return cur;
      }
      cur = parent;
    }
  }

  @override
  QTNodeBoundary? commonAncestor(QTNodeBoundary other) {
    int depth1 = depth;
    int depth2 = other.depth;
    QTNodeBoundary? parent1 = parent;
    var parent2 = other.parent;
    // Get the parents to the same depth.
    while (depth1 > depth2) {
      if (parent1 == null) {
        return null;
      }
      parent1 = parent1.parent;
      --depth1;
    }
    // ignore: invariant_booleans
    while (depth2 > depth1) {
      if (parent2 == null) {
        return null;
      }
      parent2 = parent2.parent;
      --depth2;
    }
    // Keep going up tree until the parents are the same.
    while (parent1 != parent2) {
      if (parent1 == null) return null;
      if (parent2 == null) return null;
      parent1 = parent1.parent;
      parent2 = parent2.parent;
    }
    // Return the common ancestor.
    return parent1;
  }

  @override
  QTBoundaryImpl get boundary => QTBoundaryImpl.make(_xmin, _ymin, xmax, ymax);

  @override
  void setLocation(int xmin, int ymin, int size) {
    // ignore: prefer_asserts_with_message
    assert(size > 0);
    _xmin = xmin;
    _ymin = ymin;
    _size = size;
  }

  /// Gets the minimum X location of this node.
  @override
  int get xmin => _xmin;

  /// Gets the minimum Y location of this node.
  @override
  int get ymin => _ymin;

  /// Gets the maximum X location of this node.
  @override
  int get xmax => _xmin + _size - 1;

  /// Gets the maximum Y location of this node.
  @override
  int get ymax => _ymin + _size - 1;

  /// Gets the width of boundary.
  @override
  int get width => _size;

  /// Gets the height of boundary.
  @override
  int get height => _size;

  /// Gets the boundary region the given point was in.
  @override
  BoundaryRegion region(QTPoint point) => boundary.region(point);

  /// Checks if the given point is completely contained within this boundary.
  /// Returns true if the point is fully contained, false otherwise.
  @override
  bool containsPoint(QTPoint point) => boundary.containsPoint(point);

  /// Checks if the given edge is completely contained within this boundary.
  /// Returns true if the edge is fully contained, false otherwise.
  @override
  bool containsEdge(QTEdge edge) => boundary.containsEdge(edge);

  /// Checks if the given boundary is completely contains by this boundary.
  /// Returns true if the boundary is fully contained, false otherwise.
  @override
  bool containsBoundary(QTBoundary boundary) => boundary.containsBoundary(boundary);

  /// Checks if the given edge overlaps this boundary.
  /// Returns true if the edge is overlaps, false otherwise.
  @override
  bool overlapsEdge(QTEdge edge) => boundary.overlapsEdge(edge);

  /// Checks if the given boundary overlaps this boundary.
  /// Returns true if the given boundary overlaps this boundary,
  /// false otherwise.
  @override
  bool overlapsBoundary(QTBoundary boundary) => boundary.overlapsBoundary(boundary);

  /// Gets the distance squared from this boundary to the given point.
  /// Returns the distance squared from this boundary to the given point.
  @override
  double distance2(QTPoint point) => boundary.distance2(point);

  /// This gets the first edge to the left of the given point.
  /// The [args] are an argument class used to store all the arguments and
  /// results for running this methods.
  void firstLineLeft(Set<QTEdgeNode> edgeSet, FirstLeftEdgeArgs args) {
    // ignore: prefer_foreach
    for (final edge in edgeSet) {
      args.update(edge);
    }
  }

  /// This handles all the edges in the given set to the left of the given point.
  bool foreachLeftEdge2(Set<QTEdgeNode> edgeSet, QTPoint point, QTEdgeHandler handle) {
    for (final edge in edgeSet) {
      if (edge.y1 > point.y) {
        if (edge.y2 > point.y) {
          continue;
        }
      } else if (edge.y1 < point.y) {
        if (edge.y2 < point.y) {
          continue;
        }
      }
      if ((edge.x1 > point.x) && (edge.x2 > point.x)) {
        continue;
      }
      final x = (point.y - edge.y2) * edge.dx / edge.dy + edge.x2;
      if (x > point.x) {
        continue;
      }
      if (!handle.handle(edge)) {
        return false;
      }
    }
    return true;
  }

  /// This handles the first found intersecting edge in the given edge set.
  IntersectionResult? findFirstIntersection2(
    final Set<QTEdgeNode> edgeSet,
    final QTEdge edge,
    final QTEdgeHandler? hndl,
  ) {
    for (final other in edgeSet) {
      if ((hndl == null) || hndl.handle(other)) {
        final inter = intersect(edge, other);
        if (inter!.intersects) {
          return inter;
        }
      }
    }
    return null;
  }

  /// This handles all the intersections in the given edge set.
  bool findAllIntersections2(
    Set<QTEdgeNode> edgeSet,
    QTEdge edge,
    QTEdgeHandler? hndl,
    IntersectionSet intersections,
  ) {
    bool result = false;
    for (final other in edgeSet) {
      if ((hndl == null) || hndl.handle(other)) {
        if (!intersections.constainsB(other)) {
          final inter = intersect(edge, other);
          if (inter!.intersects) {
            intersections.add(inter);
            result = true;
          }
        }
      }
    }
    return result;
  }
}
