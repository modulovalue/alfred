import '../boundary.dart';
import '../edge/impl.dart';
import '../edge/interface.dart';
import '../first_left_edge_args/impl.dart';
import '../handler_edge/interface.dart';
import '../handler_node/interface.dart';
import '../handler_point/impl.dart';
import '../handler_point/interface.dart';
import '../node/boundary/impl_pass.dart';
import '../node/boundary/interface.dart';
import '../node/boundary/mixin.dart';
import '../node/branch/impl.dart';
import '../node/branch/interface.dart';
import '../node/edge/impl.dart';
import '../node/edge/interface.dart';
import '../node/node/impl_empty.dart';
import '../node/node/interface.dart';
import '../node/point/impl.dart';
import '../node/point/interface.dart';
import '../point/impl.dart';
import '../point/interface.dart';
import '../point/ops/distance2.dart';
import '../point/ops/equals.dart';
import '../point/ops/intersect.dart';
import '../point/ops/point_on_edge.dart';
import 'interface.dart';

/// A polygon mapping quad-tree for storing edges and
/// points in a two dimensional logarithmic data structure.
class QuadTreeImpl implements QuadTree {
  /// Roughly the distance to the corner of an unit square.
  static const double _distToCorner = 1.415;

  /// The root node of the quad-tree.
  QTNode _root;

  /// The tight bounding box of all the data.
  QTBoundaryImpl _boundary;

  /// The number of points in the tree.
  int _pointCount;

  /// The number of edges in the tree.
  int _edgeCount;

  /// Creates a new quad-tree.
  QuadTreeImpl()
      : _root = QTNodeEmptyImpl.instance,
        _boundary = QTBoundaryImpl.make(0, 0, 0, 0),
        _pointCount = 0,
        _edgeCount = 0;

  @override
  QTNode get root => _root;

  @override
  QTBoundaryImpl get boundary => _boundary;

  @override
  int get pointCount => _pointCount;

  @override
  int get edgeCount => _edgeCount;

  @override
  void clear() {
    _root = QTNodeEmptyImpl.instance;
    _boundary = QTBoundaryImpl.make(0, 0, 0, 0);
    _pointCount = 0;
    _edgeCount = 0;
  }

  @override
  QTBoundaryImpl get rootBoundary {
    if (_root is QTNodeBoundaryMixin) {
      return (_root as QTNodeBoundaryMixin).boundary;
    } else {
      return QTBoundaryImpl.make(0, 0, 0, 0);
    }
  }

  @override
  PointNode? findPoint(
    final QTPoint point,
  ) {
    if (!rootBoundary.containsPoint(point)) {
      return null;
    }
    QTNode node = _root;
    for (;;) {
      if (node is PointNode) {
        if (pointEquals(node, point)) {
          return node;
        } else {
          return null;
        }
      } else if (node is BranchNode) {
        final branch = node;
        final quad = branch.childQuad(point);
        node = branch.child(quad);
      } else {
        return null;
      } // Pass nodes and empty nodes have no points.
    }
  }

  @override
  QTNodeBoundary? nodeContaining(
    final QTPoint point,
  ) {
    if (!rootBoundary.containsPoint(point)) {
      return null;
    }
    QTNode node = _root;
    for (;;) {
      if (node is BranchNode) {
        final branch = node;
        final quad = branch.childQuad(point);
        node = branch.child(quad);
        if (node is QTNodeEmptyImpl) {
          return branch;
        }
      } else if (node is QTNodeEmptyImpl) {
        return null;
      } else {
        return node as QTNodeBoundary;
      } // The pass or point node.
    }
  }

  @override
  QTEdge? findEdge(
    final QTEdge edge,
    final bool undirected,
  ) {
    final node = findPoint(edge.start);
    if (node == null) {
      return null;
    }
    var result = node.findEdgeTo(edge.end);
    if ((result == null) && undirected) {
      result = node.findEdgeFrom(edge.end);
    }
    return result;
  }

  @override
  PointNode? findNearestPointToPoint(
    final QTPoint queryPoint, {
    final QTPointHandler? handle,
    double cutoffDist2 = double.maxFinite,
  }) {
    PointNode? result;
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        final point = node;
        final dist2 = pointDistance2(queryPoint, point);
        if (dist2 < cutoffDist2) {
          if ((handle == null) || handle.handle(point)) {
            result = point;
            // ignore: parameter_assignments
            cutoffDist2 = dist2;
          }
        }
      } else if (node is BranchNode) {
        final branch = node;
        final dist2 = branch.distance2(queryPoint);
        if (dist2 <= cutoffDist2) {
          stack.pushChildren(
            branch,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  @override
  PointNode? findNearestPointToEdge(
    final QTEdge queryEdge, {
    final QTPointHandler? handle,
    double cutoffDist2 = double.maxFinite,
  }) {
    PointNode? result;
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        final dist2 = qtEdgeDistance2(queryEdge, node);
        if (dist2 < cutoffDist2) {
          if ((handle == null) || handle.handle(node)) {
            result = node;
            // ignore: parameter_assignments
            cutoffDist2 = dist2;
          }
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = qtEdgeDistance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) {
          stack.pushChildren(
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  @override
  PointNode? findClosePoint(
    final QTEdge queryEdge,
    final QTPointHandler handle,
  ) {
    if (qtEdgeDegenerate(queryEdge)) {
      return null;
    } else {
      final stack = NodeStackImpl(
        nodes: [_root],
      );
      while (!stack.isEmpty) {
        final node = stack.pop;
        if (node is PointNode) {
          final pnt = pointOnEdge(queryEdge, node);
          if (pnt.onEdge) {
            // ignore: unnecessary_null_comparison
            if ((handle == null) || handle.handle(node)) {
              return node;
            }
          }
        } else if (node is BranchNode) {
          final width = node.width;
          final x = node.xmin + width ~/ 2;
          final y = node.ymin + width ~/ 2;
          final diagDist2 = 2.0 * width * width;
          final dist2 = qtEdgeDistance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
          if (dist2 <= _distToCorner) {
            stack.pushChildren(
              node,
            );
          }
        }
        // else, Pass nodes and empty nodes have no points.
      }
      return null;
    }
  }

  @override
  QTEdgeNode? findNearestEdge(
    final QTPoint point, {
    final double cutoffDist2 = double.maxFinite,
    final QTEdgeHandler<Object?>? handler,
  }) {
    final args = NearestEdgeArgsImpl(
      queryPoint: point,
      cutoffDist2: cutoffDist2,
      handle: handler,
    );
    args.run(_root);
    return args.result();
  }

  @override
  QTEdgeNode? firstLeftEdge(
    final QTPoint point, {
    final QTEdgeHandler<Object?>? handle,
  }) {
    final args = FirstLeftEdgeArgsImpl(point, handle);
    _root.firstLeftEdge(args);
    return args.result;
  }

  @override
  bool foreachLeftEdge(
    final QTPoint point,
    final QTEdgeHandler<Object?> handle,
  ) =>
      _root.foreachLeftEdge(point, handle);

  @override
  PointNode? firstPoint(
    final QTBoundary? boundary,
    final QTPointHandler handle,
  ) {
    PointNode? result;
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          return node;
        }
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) {
          stack.pushChildren(
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  @override
  PointNode? lastPoint(
    final QTBoundary? boundary,
    final QTPointHandler handle,
  ) {
    PointNode? result;
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          return node;
        }
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) {
          stack.pushReverseChildren(
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  @override
  bool foreachPoint(
    final QTPointHandler handle, [
    final QTBoundary? bounds,
  ]) =>
      _root.foreachPoint(handle, bounds);

  @override
  bool foreachEdge(
    final QTEdgeHandler<Object?> handle, [
    final QTBoundary? bounds,
    final bool exclusive = false,
  ]) =>
      _root.foreachEdge(
        handle,
        bounds,
        exclusive,
      );

  @override
  bool foreachNode(
    final QTNodeHandler handle, [
    final QTBoundary? bounds,
  ]) =>
      _root.foreachNode(handle, bounds);

  @override
  bool forNearPointPoints(
    final QTPointHandler handle,
    final QTPoint queryPoint,
    final double cutoffDist2,
  ) {
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        final dist2 = pointDistance2(queryPoint, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) {
            return false;
          }
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = pointDistance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) {
          stack.pushChildren(
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  @override
  bool forNearEdgePoints(
    final QTPointHandler handle,
    final QTEdge queryEdge,
    final double cutoffDist2,
  ) {
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        final dist2 = qtEdgeDistance2(queryEdge, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) {
            return false;
          }
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = qtEdgeDistance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) {
          stack.pushChildren(
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  @override
  bool forClosePoints(
    final QTPointHandler handle,
    final QTEdge queryEdge,
  ) {
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        final pnt = pointOnEdge(queryEdge, node);
        if (pnt.onEdge) {
          if (!handle.handle(node)) {
            return false;
          }
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = qtEdgeDistance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) {
          stack.pushChildren(
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  @override
  bool forNearEdges(
    final QTEdgeHandler<Object?> handler,
    final QTPoint queryPoint,
    final double cutoffDist2,
  ) {
    final stack = NodeStackImpl(
      nodes: null,
    );
    stack.push(_root);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        for (final edge in node.startEdges) {
          if (qtEdgeDistance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) {
              return false;
            }
          }
        }
        for (final edge in node.endEdges) {
          if (qtEdgeDistance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) {
              return false;
            }
          }
        }
        for (final edge in node.passEdges) {
          if (qtEdgeDistance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) {
              return false;
            }
          }
        }
      } else if (node is PassNode) {
        for (final edge in node.passEdges) {
          if (qtEdgeDistance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) {
              return false;
            }
          }
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = pointDistance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) {
          stack.pushChildren(
            node,
          );
        }
      }
      // else, empty nodes have no edges.
    }
    return true;
  }

  @override
  bool forCloseEdges(
    final QTEdgeHandler<Object?> handler,
    final QTPoint queryPoint,
  ) {
    final stack = NodeStackImpl(
      nodes: null,
    );
    stack.push(_root);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        for (final edge in node.startEdges) {
          final pnt = pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) {
              return false;
            }
          }
        }
        for (final edge in node.endEdges) {
          final pnt = pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) {
              return false;
            }
          }
        }
        for (final edge in node.passEdges) {
          final pnt = pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) {
              return false;
            }
          }
        }
      } else if (node is PassNode) {
        for (final edge in node.passEdges) {
          final pnt = pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) {
              return false;
            }
          }
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = pointDistance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) {
          stack.pushChildren(
            node,
          );
        }
      }
      // else, empty nodes have no edges.
    }
    return true;
  }

  @override
  IntersectionResult? findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
  ) =>
      _root.findFirstIntersection(edge, hndl);

  @override
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
    final IntersectionSet intersections,
  ) {
    if (_edgeCount <= 0) {
      return false;
    } else {
      return (_root as QTNodeBoundaryMixin).findAllIntersections(
        edge,
        hndl,
        intersections,
      );
    }
  }

  @override
  QTEdge<T>? insertEdge<T>(
    final QTEdge<T> edge,
    final T data,
  ) =>
      tryInsertEdge<T>(
        edge,
        data,
      );

  @override
  QTEdge<T>? tryInsertEdge<T>(
    final QTEdge<T> edge,
    final T initData,
  ) {
    PointNode? startNode;
    PointNode? endNode;
    bool startNew;
    bool endNew;
    if ((edge.start is PointNode) && ((edge.start as PointNodeImpl).root == _root)) {
      startNode = edge.start as PointNode;
      startNew = false;
    } else {
      final pair = tryInsertPoint(edge.start);
      startNode = pair.point;
      startNew = pair.existed;
    }
    if ((edge.end is PointNode) && ((edge.end as PointNodeImpl).root == _root)) {
      endNode = edge.end as PointNode;
      endNew = false;
    } else {
      final pair = tryInsertPoint(edge.end);
      endNode = pair.point;
      endNew = pair.existed;
    }
    // Check for degenerate edges.
    if (startNode == endNode) {
      return null;
    }
    // If both points already existed check if edge exists.
    if (!(startNew || endNew)) {
      final edge = startNode.findEdgeTo(endNode);
      if (edge != null) {
        return edge as QTEdgeNode<T>;
      }
    }
    // Insert new edge.
    final ancestor = startNode.commonAncestor(endNode);
    if (ancestor == null) {
      // ignore: prefer_asserts_with_message
      assert(validate());
      // ignore: prefer_asserts_with_message
      assert(startNode.root == _root);
      // ignore: prefer_asserts_with_message
      assert(endNode.root == _root);
      // ignore: prefer_asserts_with_message
      assert(ancestor != null);
      return null;
    }
    final newEdge = QTEdgeNodeImpl<T>(
      startNode,
      endNode,
      initData,
    );
    final replacement = ancestor.insertEdge(newEdge);
    _reduceBranch(ancestor, replacement);
    _edgeCount++;
    return newEdge;
  }

  @override
  PointNode insertPoint(
    final QTPoint point,
  ) =>
      tryInsertPoint(point).point;

  @override
  InsertPointResult tryInsertPoint(
    final QTPoint point,
  ) {
    final pntNode = PointNodeImpl(
      point.x,
      point.y,
    );
    // Attempt to find the point first.
    final node = nodeContaining(pntNode);
    final _node = node;
    if (_node != null) {
      // A node containing the point has been found.
      if (_node is PointNodeImpl) {
        if (pointEquals(_node, pntNode)) {
          return InsertPointResultImpl(
            _node,
            true,
          );
        }
      }
      final parent = _node.parent;
      if (parent != null) {
        final quad = parent.childNodeQuad(_node);
        QTNode replacement = _node.insertPoint(pntNode);
        parent.setChild(quad, replacement);
        replacement = parent.reduce();
        _reduceBranch(parent, replacement);
      } else {
        final replacement = _node.insertPoint(pntNode);
        _setRoot(replacement);
      }
    } else if (_root is QTNodeEmptyImpl) {
      // Tree is empty so create a new tree.
      const initialTreeWidth = 256;
      int centerX = (pntNode.x ~/ initialTreeWidth) * initialTreeWidth;
      int centerY = (pntNode.y ~/ initialTreeWidth) * initialTreeWidth;
      if (pntNode.x < 0) centerX -= initialTreeWidth - 1;
      if (pntNode.y < 0) centerY -= initialTreeWidth - 1;
      _setRoot(
        (_root as QTNodeEmptyImpl).addPoint(
          centerX,
          centerY,
          initialTreeWidth,
          pntNode,
        ),
      );
    } else {
      // Point outside of tree, expand the tree.
      final root = _expandFootprint(_root as QTNodeBoundaryMixin, pntNode);
      _setRoot(root.insertPoint(pntNode));
    }
    // ignore: prefer_asserts_with_message
    assert(_root is! QTNodeEmptyImpl);
    _pointCount++;
    _expandBoundingBox(pntNode);
    _reduceFootprint();
    return InsertPointResultImpl(
      pntNode,
      false,
    );
  }

  @override
  void removeEdge(
    final QTEdgeNode edge,
    final bool trimTree,
  ) {
    final ancestor = edge.startNode.commonAncestor(edge.endNode);
    // ignore: prefer_asserts_with_message
    assert(ancestor != null);
    final replacement = ancestor!.removeEdge(edge, trimTree);
    _reduceBranch(ancestor, replacement);
    --_edgeCount;
    // If trimming the tree, see if the black nodes need to be deleted.
    if (trimTree) {
      if (edge.startNode.orphan) {
        removePoint(edge.startNode);
      }
      if (edge.endNode.orphan) {
        removePoint(edge.endNode);
      }
    }
  }

  @override
  void removePoint(
    final PointNode point,
  ) {
    // Remove any edges on the point.
    final startEdges = point.startEdges.toList();
    for (final edge in startEdges) {
      removeEdge(edge, false);
    }
    final endEdges = point.endEdges.toList();
    for (final edge in endEdges) {
      removeEdge(edge, false);
    }
    // The point node must not have any edges beginning
    // nor ending on by the time is is removed.
    // ignore: prefer_asserts_with_message
    assert(point.orphan);
    // Remove the point from the tree.
    if (_root == point) {
      // If the only thing in the tree is the point, simply replace it
      // with an empty node.
      _root = QTNodeEmptyImpl.instance;
    } else {
      final parent = point.parent!;
      QTNode replacement = point.replacement;
      final quad = parent.childNodeQuad(point);
      parent.setChild(quad, replacement);
      replacement = parent.reduce();
      _reduceBranch(parent, replacement);
      _reduceFootprint();
    }
    --_pointCount;
    _collapseBoundingBox(point);
  }

  @override
  bool validate([
    StringBuffer? sout,
  ]) {
    bool result = true;
    bool toConsole = false;
    if (sout == null) {
      // ignore: parameter_assignments
      sout = StringBuffer();
      toConsole = true;
    }
    final vHndl = QTPointHandlerValidateHandlerImpl();
    foreachPoint(vHndl);
    if (_pointCount != vHndl.pointCount) {
      sout.write("Error: The point count should have been ");
      sout.write(vHndl.pointCount);
      sout.write(" but it was ");
      sout.write(_pointCount);
      sout.write(".\n");
      result = false;
    }
    if (_edgeCount != vHndl.edgeCount) {
      sout.write("Error: The edge count should have been ");
      sout.write(vHndl.edgeCount);
      sout.write(" but it was ");
      sout.write(_edgeCount);
      sout.write(".\n");
      result = false;
    }
    vHndl.bounds ??= QTBoundaryImpl.make(0, 0, 0, 0);
    if (!boundaryEquals(_boundary, vHndl.bounds)) {
      sout.write("Error: The data boundary should have been ");
      sout.write(vHndl.bounds.toString());
      sout.write(" but it was ");
      sout.write(_boundary.toString());
      sout.write(".\n");
      result = false;
    }
    if (_root is! QTNodeEmptyImpl) {
      final root = _root as QTNodeBoundaryMixin;
      if (root.parent != null) {
        sout.write("Error: The root node's parent should be null but it is ");
        sout.write(".\n");
        result = false;
      }
    }
    if (!_root.validate(sout, true)) {
      result = false;
    }
    if (toConsole && sout.isNotEmpty) {
      print(sout.toString());
    }
    return result;
  }

  /// This reduces the root to the smallest branch needed.
  /// [node] is the original node to reduce.
  /// [replacement] is the node to replace the original node with.
  void _reduceBranch(
    QTNodeBoundary node,
    QTNode replacement,
  ) {
    while (replacement != node) {
      final parent = node.parent;
      if (parent == null) {
        _setRoot(replacement);
        break;
      }
      final quad = parent.childNodeQuad(node);
      parent.setChild(quad, replacement);
      // ignore: parameter_assignments
      node = parent;
      // ignore: parameter_assignments
      replacement = parent.reduce();
    }
  }

  /// This sets the root node of this tree.
  /// [node] is the node to set as the root.
  /// Returns true if root changed, false if no change.
  bool _setRoot(
    final QTNode? node,
  ) {
    // ignore: prefer_asserts_with_message
    assert(node != null);
    if (_root == node!) return false;
    _root = node;
    if (_root is! QTNodeEmptyImpl) {
      (_root as QTNodeBoundaryMixin).parent = null;
    }
    return true;
  }

  /// This expands the foot print of the tree to include the given point.
  /// [root] is the original root to expand.
  /// Returns the new expanded root.
  QTNodeBoundaryMixin _expandFootprint(
    QTNodeBoundaryMixin root,
    final QTPoint point,
  ) {
    while (!root.containsPoint(point)) {
      final xmin = root.xmin;
      final ymin = root.ymin;
      final width = root.width;
      final half = width ~/ 2;
      final oldCenterX = xmin + half;
      final oldCenterY = ymin + half;
      int newXMin = xmin;
      int newYMin = ymin;
      Quadrant quad;
      if (point.y > oldCenterY) {
        if (point.x > oldCenterX) {
          // New node is in the 'NorthEast'.
          quad = Quadrant.SouthWest;
        } else {
          // New node is in the 'NorthWest'.
          newXMin = xmin - width;
          quad = Quadrant.SouthEast;
        }
      } else {
        if (point.x > oldCenterX) {
          // New node is in the 'SouthEast'.
          newYMin = ymin - width;
          quad = Quadrant.NorthWest;
        } else {
          // New node is in the 'SouthWest'.
          newXMin = xmin - width;
          newYMin = ymin - width;
          quad = Quadrant.NorthEast;
        }
      }
      final newRoot = BranchNodeImpl();
      newRoot.setLocation(newXMin, newYMin, width * 2);
      newRoot.setChild(quad, root);
      final replacement = newRoot.reduce();
      // ignore: prefer_asserts_with_message
      assert(replacement is! QTNodeEmptyImpl);
      // ignore: parameter_assignments
      root = replacement as QTNodeBoundaryMixin;
    }
    return root;
  }

  /// Expands the tree's boundary to include the given point.
  void _expandBoundingBox(
    final QTPoint point,
  ) {
    if (_pointCount <= 1) {
      _boundary = QTBoundaryImpl.make(point.x, point.y, point.x, point.y);
    } else {
      _boundary = boundaryExpand(_boundary, point);
    }
  }

  /// This reduces the footprint to the smallest root needed.
  void _reduceFootprint() {
    // ignore: unnecessary_null_comparison
    while ((_root != null) && (_root is BranchNode)) {
      final broot = _root as BranchNode;
      int emptyCount = 0;
      QTNode? onlyChild;
      for (final quad in Quadrant.values) {
        final child = broot.child(quad);
        if (child is QTNodeEmptyImpl) {
          emptyCount++;
        } else {
          onlyChild = child;
        }
      }
      if (emptyCount == 3) {
        _setRoot(onlyChild);
      } else {
        break;
      }
    }
  }

  /// This collapses the boundary with the given point which was just removed.
  /// [point] is the point which was removed.
  void _collapseBoundingBox(
    final QTPoint point,
  ) {
    if (_pointCount <= 0) {
      _boundary = QTBoundaryImpl.make(0, 0, 0, 0);
    } else {
      if (_boundary.xmax <= point.x) {
        _boundary = QTBoundaryImpl.make(
          _boundary.xmin,
          _boundary.ymin,
          _determineEastSide(_boundary.xmin),
          _boundary.ymax,
        );
      }
      if (_boundary.xmin >= point.x) {
        _boundary = QTBoundaryImpl.make(
          _determineWestSide(_boundary.xmax),
          _boundary.ymin,
          _boundary.xmax,
          _boundary.ymax,
        );
      }
      if (_boundary.ymax <= point.y) {
        _boundary = QTBoundaryImpl.make(
          _boundary.xmin,
          _boundary.ymin,
          _boundary.xmax,
          _determineNorthSide(_boundary.ymin),
        );
      }
      if (_boundary.ymin >= point.y) {
        _boundary = QTBoundaryImpl.make(
          _boundary.xmax,
          _boundary.ymax,
          _boundary.xmin,
          _determineSouthSide(_boundary.ymax),
        );
      }
    }
  }

  /// This finds the north side in the tree.
  /// Return is the value of the north side for the given direction.
  int _determineNorthSide(
    int value,
  ) {
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        // ignore: parameter_assignments
        if (value < node.y) {
          // ignore: parameter_assignments
          value = node.y;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.ymax) stack.pushAll([node.sw, node.se, node.nw, node.ne]);
      }
    }
    return value;
  }

  /// This finds the east side in the tree.
  /// Returns the value of the east side for the given direction.
  int _determineEastSide(
    int value,
  ) {
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        if (value < node.x) {
          // ignore: parameter_assignments
          value = node.x;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.xmax) stack.pushAll([node.sw, node.nw, node.se, node.ne]);
      }
    }
    return value;
  }

  /// This finds the south side in the tree.
  /// Returns the value of the south side for the given direction.
  int _determineSouthSide(
    int value,
  ) {
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        if (value > node.y) {
          // ignore: parameter_assignments
          value = node.y;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.ymin) stack.pushAll([node.nw, node.ne, node.sw, node.se]);
      }
    }
    return value;
  }

  /// This finds the west side in the tree.
  /// Returns the value of the west side for the given direction.
  int _determineWestSide(
    int value,
  ) {
    final stack = NodeStackImpl(
      nodes: [_root],
    );
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        if (value > node.x) {
          // ignore: parameter_assignments
          value = node.x;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.xmin) {
          stack.pushAll([node.se, node.ne, node.sw, node.nw]);
        }
      }
    }
    return value;
  }
}

/// A stack of nodes.
class NodeStackImpl implements NodeStack {
  /// The internal stack of nodes.
  final List<QTNode> _stack;

  /// Creates a new stack.
  /// The initial sets of [nodes] is pushed in order.
  NodeStackImpl({
    required final List<QTNode>? nodes,
  }) : _stack = <QTNode>[] {
    if (nodes != null) {
      // ignore: prefer_foreach
      for (final node in nodes) {
        push(node);
      }
    }
  }

  @override
  bool get isEmpty => _stack.isEmpty;

  @override
  QTNode get pop => _stack.removeLast();

  @override
  void push(
    final QTNode node,
  ) =>
      _stack.add(node);

  @override
  void pushAll(
    final List<QTNode> nodes,
  ) {
    // ignore: prefer_foreach
    for (final node in nodes) {
      push(node);
    }
  }

  @override
  void pushChildren(
    final BranchNode node,
  ) {
    // Push in reverse order from typical searches so that they
    // are processed in the order: NE, NW, SE, then SW.
    push(node.sw);
    push(node.se);
    push(node.nw);
    push(node.ne);
  }

  @override
  void pushReverseChildren(
    final BranchNode node,
  ) {
    // Push in normal order from typical searches so that they
    // are processed in the order: SW, SE, NW, then NE.
    push(node.ne);
    push(node.nw);
    push(node.se);
    push(node.sw);
  }
}

/// The nearest edge arguments to handle multiple returns
/// objects for determining the nearest edge to a point.
class NearestEdgeArgsImpl implements NearestEdgeArgs {
  /// The query point to find the nearest line to.
  final QTPoint queryPoint;

  /// The line matcher to filter lines with.
  final QTEdgeHandler<Object?>? handle;

  /// The maximum allowable distance squared to the result.
  double cutoffDist2;

  /// The currently found closest edge. Null if a point has been found closer.
  QTEdgeNode? _resultEdge;

  /// The node if the nearest part of the edge is the point.
  /// Null if an edge has been found closer.
  PointNode? _resultPoint;

  /// Creates a new nearest edge arguments.
  /// [queryPoint] is the query point to find an edge nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest edge.
  /// The [handle] is the filter acceptable edges with, or null to not filter.
  NearestEdgeArgsImpl({
    required final this.queryPoint,
    required final this.cutoffDist2,
    required final this.handle,
  })  : _resultEdge = null,
        _resultPoint = null;

  @override
  void run(
    final QTNode rootNode,
  ) {
    final stack = NodeStackImpl(
      nodes: null,
    );
    stack.push(rootNode);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        // ignore: prefer_foreach
        for (final edge in node.startEdges) {
          _checkEdge(edge);
        }
        // ignore: prefer_foreach
        for (final edge in node.endEdges) {
          _checkEdge(edge);
        }
        // ignore: prefer_foreach
        for (final edge in node.passEdges) {
          _checkEdge(edge);
        }
      } else if (node is PassNode) {
        // ignore: prefer_foreach
        for (final edge in node.passEdges) {
          _checkEdge(edge);
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        // ignore: avoid_dynamic_calls
        final dist2 = pointDistance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) {
          stack.pushChildren(node);
        }
      }
      // else, empty nodes have no edges.
    }
  }

  @override
  QTEdgeNode? result() {
    final __resultPoint = _resultPoint;
    if (__resultPoint == null) {
      return _resultEdge;
    } else {
      return __resultPoint.nearEndEdge(queryPoint);
    }
  }

  /// Checks if the given edge is closer that last found edge.
  void _checkEdge(
    final QTEdgeNode? edge,
  ) {
    if (edge == null) {
      return;
    }
    if (edge == _resultEdge) {
      return;
    }
    final __handle = handle;
    if (__handle != null) {
      if (!__handle.handle(edge)) {
        return;
      }
    }
    // Determine how the point is relative to the edge.
    final result = pointOnEdge(edge, queryPoint);
    switch (result.location) {
      case IntersectionLocation.InMiddle:
        _updateWithEdge(edge, result.closestOnEdge);
        break;
      case IntersectionLocation.BeforeStart:
        _updateWithPoint(edge.startNode);
        break;
      case IntersectionLocation.AtStart:
        _updateWithPoint(edge.startNode);
        break;
      case IntersectionLocation.PastEnd:
        _updateWithPoint(edge.endNode);
        break;
      case IntersectionLocation.AtEnd:
        _updateWithPoint(edge.endNode);
        break;
      case IntersectionLocation.None:
        break;
    }
  }

  /// Update with the edge with the middle of the edge the closest.
  void _updateWithEdge(
    final QTEdgeNode edge,
    final QTPoint closePoint,
  ) {
    final dist2 = pointDistance2(queryPoint, closePoint);
    if (dist2 <= cutoffDist2) {
      _resultEdge = edge;
      _resultPoint = null;
      cutoffDist2 = dist2;
    }
  }

  /// Update with the point at the end of the edge.
  void _updateWithPoint(
    final PointNode point,
  ) {
    final dist2 = pointDistance2(queryPoint, point);
    if (dist2 <= cutoffDist2) {
      // Do not set _resultEdge here, leave it as the previous value.
      _resultPoint = point;
      cutoffDist2 = dist2;
    }
  }
}

class InsertPointResultImpl implements InsertPointResult {
  @override
  final PointNode point;

  @override
  final bool existed;

  const InsertPointResultImpl(
    final this.point,
    final this.existed,
  );
}
