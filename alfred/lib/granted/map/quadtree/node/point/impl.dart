import '../../boundary/interface.dart';
import '../../edge/impl.dart';
import '../../edge/interface.dart';
import '../../first_left_edge_args/interface.dart';
import '../../handler_edge/interface.dart';
import '../../handler_node/interface.dart';
import '../../handler_point/interface.dart';
import '../../point/impl.dart';
import '../../point/interface.dart';
import '../../point/ops/cross.dart';
import '../../point/ops/equals.dart';
import '../../point/ops/intersect.dart';
import '../../point/ops/side.dart';
import '../boundary/impl_pass.dart';
import '../boundary/mixin.dart';
import '../branch/impl.dart';
import '../branch/interface.dart';
import '../edge/interface.dart';
import '../node/impl_empty.dart';
import '../node/interface.dart';
import 'interface.dart';

/// The point node represents a point in the quad-tree. It can have edges
/// starting or ending on it as well as edges which pass through it.
class PointNodeImpl with QTNodeBoundaryMixin implements PointNode {
  /// The first component (X) of the point.
  final int _x;

  /// The second component (Y) of the point.
  final int _y;

  /// The set of edges which start at this point.
  final Set<QTEdgeNode> _startEdges;

  /// The set of edges which end at this point.
  final Set<QTEdgeNode> _endEdges;

  /// The set of edges which pass through this node.
  final Set<QTEdgeNode> _passEdges;

  /// Any additional data that this point should contain.
  @override
  Object? data;

  /// Creates a new point node.
  PointNodeImpl(
    final this._x,
    final this._y,
  )   : _startEdges = <QTEdgeNode>{},
        _endEdges = <QTEdgeNode>{},
        _passEdges = <QTEdgeNode>{},
        data = null;

  /// Gets the first integer coordinate component.
  @override
  int get x => _x;

  /// Gets the second integer coordinate component.
  @override
  int get y => _y;

  /// Gets the point for this node.
  @override
  QTPointImpl get point => QTPointImpl(_x, _y);

  /// Gets the set of edges which start at this point.
  @override
  Set<QTEdgeNode> get startEdges => _startEdges;

  /// Gets the set of edges which end at this point.
  @override
  Set<QTEdgeNode> get endEdges => _endEdges;

  /// Gets the set of edges which pass through this node.
  @override
  Set<QTEdgeNode> get passEdges => _passEdges;

  /// Determines if this point is an orphan, meaning it's point isn't used by any edge.
  @override
  bool get orphan => _startEdges.isEmpty && _endEdges.isEmpty;

  /// Finds an edge that starts at this point and ends at the given point.
  @override
  QTEdgeNode? findEdgeTo(QTPoint end) {
    for (final edge in _startEdges) {
      if (pointEquals(edge.endNode, end)) return edge;
    }
    return null;
  }

  /// Finds an edge that ends at this point and starts at the given point.
  @override
  QTEdgeNode? findEdgeFrom(QTPoint start) {
    for (final edge in _endEdges) {
      if (pointEquals(edge.startNode, start)) {
        return edge;
      }
    }
    return null;
  }

  /// Finds an edge that starts or ends at this point and connects to the given point.
  @override
  QTEdgeNode? findEdgeBetween(
    final QTPoint other,
  ) =>
      findEdgeTo(other) ?? findEdgeFrom(other);

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode insertEdge(
    final QTEdgeNode edge,
  ) {
    if (edge.startNode == this) {
      _startEdges.add(edge);
    } else if (edge.endNode == this) {
      _endEdges.add(edge);
    } else if (overlapsEdge(edge)) {
      _passEdges.add(edge);
    }
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode insertPoint(
    final PointNode point,
  ) {
    final branch = BranchNodeImpl();
    branch.setLocation(xmin, ymin, width);
    final halfSize = width ~/ 2;
    // Make a copy of this node and set is as a child of the new branch.
    final childQuad = branch.childQuad(this);
    setLocation(branch.childX(childQuad), branch.childY(childQuad), halfSize);
    branch.setChild(childQuad, this);
    // Copy lines to new siblings, keep any non-empty sibling.
    for (final quad in Quadrant.values) {
      if (quad != childQuad) {
        final sibling = PassNode();
        sibling.setLocation(branch.childX(quad), branch.childY(quad), halfSize);
        _appendPassingEdges(sibling, _startEdges);
        _appendPassingEdges(sibling, _endEdges);
        _appendPassingEdges(sibling, _passEdges);
        if (sibling.passEdges.isNotEmpty) branch.setChild(quad, sibling);
      }
    }
    // Remove any edges which no longer pass through this point.
    final it = _passEdges.iterator;
    final remove = <QTEdge>{};
    while (it.moveNext()) {
      final edge = it.current;
      if (!overlapsEdge(edge)) remove.add(edge);
    }
    _passEdges.removeAll(remove);
    // Add the point to the new branch node, return new node.
    // This allows the branch to grow as needed.
    return branch.insertPoint(point);
  }

  /// This adds all the edges from the given set which pass through the given
  /// pass node to that node.
  void _appendPassingEdges(
    final PassNode node,
    final Set<QTEdgeNode> edges,
  ) {
    for (final edge in edges) {
      if (node.overlapsEdge(edge)) {
        node.passEdges.add(edge);
      }
    }
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode removeEdge(
    final QTEdgeNode edge,
    final bool trimTree,
  ) {
    final result = this;
    if (edge.startNode == this) {
      _startEdges.remove(edge);
    } else if (edge.endNode == this) {
      _endEdges.remove(edge);
    } else {
      _passEdges.remove(edge);
    }
    return result;
  }

  /// This handles the first found intersecting edge.
  @override
  IntersectionResult? findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler? hndl,
  ) {
    if (overlapsEdge(edge)) {
      IntersectionResult? result;
      result = findFirstIntersection2(_startEdges, edge, hndl);
      if (result != null) return result;
      result = findFirstIntersection2(_endEdges, edge, hndl);
      if (result != null) return result;
      result = findFirstIntersection2(_passEdges, edge, hndl);
      if (result != null) return result;
    }
    return null;
  }

  /// This handles all the intersections.
  @override
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler? hndl,
    final IntersectionSet intersections,
  ) {
    bool result = false;
    if (overlapsEdge(edge)) {
      if (findAllIntersections2(_startEdges, edge, hndl, intersections)) result = true;
      if (findAllIntersections2(_endEdges, edge, hndl, intersections)) result = true;
      if (findAllIntersections2(_passEdges, edge, hndl, intersections)) result = true;
    }
    return result;
  }

  /// Handles each point node reachable from this node in the boundary.
  @override
  bool foreachPoint(
    final QTPointHandler handle, [
    final QTBoundary? bounds,
  ]) {
    if ((bounds == null) || bounds.containsPoint(this)) {
      return handle.handle(this);
    } else {
      return true;
    }
  }

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  @override
  bool foreachEdge(
    final QTEdgeHandler handle, [
    final QTBoundary? bounds,
    final bool exclusive = false,
  ]) {
    if (bounds == null) {
      for (final edge in _startEdges) {
        if (!handle.handle(edge)) {
          return false;
        }
      }
    } else if (overlapsBoundary(bounds)) {
      if (exclusive) {
        // Check all edges which start at this node to see if they end in the bounds.
        // No need to check passEdges nor endEdges because for all exclusive edges
        // all startEdges lists will be checked at some point.
        for (final edge in _startEdges) {
          if (bounds.containsPoint(edge.end)) {
            if (!handle.handle(edge)) {
              return false;
            }
          }
        }
      } else {
        for (final edge in _startEdges) {
          if (!handle.handle(edge)) {
            return false;
          }
        }
        for (final edge in _endEdges) {
          if (!handle.handle(edge)) {
            return false;
          }
        }
        for (final edge in _passEdges) {
          if (!handle.handle(edge)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  @override
  bool foreachNode(
    final QTNodeHandler handle, [
    final QTBoundary? bounds,
  ]) =>
      ((bounds == null) || overlapsBoundary(bounds)) && handle.handle(this);

  /// Determines if the node has any point nodes inside it.
  /// Since this is a point node then it will always return true.
  @override
  bool get hasPoints => true;

  /// Determines if the node has any edge nodes inside it.
  @override
  bool get hasEdges => !(_passEdges.isEmpty || _endEdges.isEmpty || _startEdges.isEmpty);

  /// Gets the first edge to the left of the given point.
  @override
  void firstLeftEdge(
    final FirstLeftEdgeArgs args,
  ) {
    firstLineLeft(_startEdges, args);
    firstLineLeft(_endEdges, args);
    firstLineLeft(_passEdges, args);
  }

  /// Handles all the edges to the left of the given point.
  @override
  bool foreachLeftEdge(
    final QTPoint point,
    final QTEdgeHandler handle,
  ) {
    if (!foreachLeftEdge2(_startEdges, point, handle)) {
      return false;
    } else if (!foreachLeftEdge2(_endEdges, point, handle)) {
      return false;
    } else if (!foreachLeftEdge2(_passEdges, point, handle)) {
      return false;
    } else {
      return true;
    }
  }

  /// This finds the next point in the tree.
  @override
  PointNode? nextPoint(
    final QTPointHandler handle, [
    final QTBoundary? boundary,
  ]) {
    final _parent = parent;
    if (_parent == null) {
      return null;
    } else {
      return _parent.findNextPoint(this, boundary, handle);
    }
  }

  /// This finds the previous point in the tree.
  @override
  PointNode? previousPoint(
    final QTPointHandler handle, [
    final QTBoundary? boundary,
  ]) {
    final _parent = parent;
    if (_parent == null) {
      return null;
    } else {
      return _parent.findPreviousPoint(
        this,
        boundary,
        handle,
      );
    }
  }

  /// This finds the nearest edge to the given point.
  /// When determining which edge should be considered the closest edge when the
  /// point for this node is the nearest point to the query point. This doesn't
  /// check passing edges, only beginning and ending edges because the nearest
  /// edge starts or ends at this node.
  @override
  QTEdgeNode? nearEndEdge(
    final QTPoint queryPoint,
  ) {
    final queryEdge = QTEdgeImpl(
      queryPoint,
      this,
      null,
    );
    QTEdgeNode? rightMost;
    QTEdgeNode? leftMost;
    QTEdgeNode? center;
    // Check all edges which start at this node.
    for (final edge in startEdges) {
      final pnt = edge.endNode;
      final _side = side(queryEdge, pnt);
      if (_side == Side.Right) {
        if ((rightMost == null) || (side(rightMost, pnt) == Side.Right)) {
          rightMost = edge;
        }
      } else if (_side == Side.Left) {
        if ((leftMost == null) || (side(leftMost, pnt) == Side.Left)) {
          leftMost = edge;
        }
      } else {
        // (side == Side.Inside)
        center = edge;
      }
    }
    // Check all edges which end at this node.
    for (final edge in endEdges) {
      final pnt = edge.startNode;
      final _side = side(queryEdge, pnt);
      if (_side == Side.Right) {
        if ((rightMost == null) || (side(rightMost, pnt) == Side.Right)) {
          rightMost = edge;
        }
      } else if (_side == Side.Left) {
        if ((leftMost == null) || (side(leftMost, pnt) == Side.Left)) {
          leftMost = edge;
        }
      } else {
        // (side == Side.Inside)
        center = edge;
      }
    }
    // Determine the closest side of the found sides.
    if (rightMost != null) {
      if (leftMost != null) {
        final rightCross = pointCross(
          QTPointImpl(rightMost.x2 - x, rightMost.y2 - y),
          QTPointImpl(queryPoint.x - x, queryPoint.y - y),
        );
        final leftCross = pointCross(
          QTPointImpl(queryPoint.x - x, queryPoint.y - y),
          QTPointImpl(leftMost.x2 - x, leftMost.y2 - y),
        );
        if (rightCross <= leftCross) {
          return rightMost;
        } else {
          return leftMost;
        }
      } else {
        return rightMost;
      }
    } else if (leftMost != null) {
      return leftMost;
    } else {
      return center;
    }
  }

  /// Determines the replacement node when a point is removed.
  @override
  QTNode get replacement {
    parent = null;
    // If there are no passing edges return an empty node.
    if (_passEdges.isEmpty) {
      return QTNodeEmptyImpl.instance;
    } else {
      // Otherwise return a passing node with these passing edges.
      final pass = PassNode();
      pass.setLocation(xmin, ymin, width);
      pass.passEdges.addAll(_passEdges);
      _passEdges.clear();
      return pass;
    }
  }

  /// Validates this node.
  @override
  bool validate(
    final StringBuffer sout,
    final bool recursive,
  ) {
    bool result = true;
    if (!containsPoint(this)) {
      sout.write("Error in ");
      sout.write(": The point is not contained by the node's region.\n");
      result = false;
    }
    for (final edge in _startEdges) {
      if (edge.startNode != this) {
        sout.write("Error in ");
        sout.write(": A line in the starting list, ");
        sout.write(", doesn't start with this node.\n");
        result = false;
      }
      if (edge.endNode == this) {
        sout.write("Error in ");
        sout.write(": A line in the starting list, ");
        sout.write(", also ends on this node.\n");
        result = false;
      }
      if (recursive) {
        if (!edge.validate(sout)) {
          result = false;
        }
      }
    }
    for (final edge in _endEdges) {
      if (edge.endNode != this) {
        sout.write("Error in ");
        sout.write(": A line in the ending list, ");
        sout.write(", doesn't end with this node.\n");
        result = false;
      }
      if (edge.startNode == this) {
        sout.write("Error in ");
        sout.write(": A line in the ending list, ");
        sout.write(", also starts on this node.\n");
        result = false;
      }
    }
    for (final edge in _passEdges) {
      if (!overlapsEdge(edge)) {
        sout.write("Error in ");
        sout.write(": A line in the passing list, ");
        sout.write(", doesn't pass through this node.\n");
        result = false;
      }
      if (edge.startNode == this) {
        sout.write("Error in ");
        sout.write(": A line in the passing list, ");
        sout.write(", should be in the starting list.\n");
        result = false;
      }
      if (edge.endNode == this) {
        sout.write("Error in ");
        sout.write(": A line in the passing list, ");
        sout.write(", should be in the ending list.\n");
        result = false;
      }
    }
    return result;
  }

  /// Compares the given point with this point.
  /// Return 1 if this point is greater than the other point,
  /// -1 if this point is less than the other point,
  /// 0 if this point is the same as the other point.
  @override
  int compareTo(PointNode other) {
    if (_y < other.y) return -1;
    if (_y > other.y) return 1;
    if (_x < other.x) return -1;
    if (_x > other.x) return 1;
    return 0;
  }
}
