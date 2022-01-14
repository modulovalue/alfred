import '../basic/first_left_edge_args.dart';
import '../basic/qt_edge.dart';
import '../basic/qt_edge_handler.dart';
import '../basic/qt_node_handler.dart';
import '../basic/qt_point_handler.dart';
import '../boundary.dart';
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
import '../point/ops/distance2.dart';
import '../point/ops/equals.dart';
import '../point/ops/intersect.dart';
import '../point/ops/point_on_edge.dart';
import '../point/qt_point.dart';
import 'insert_point_result.dart';
import 'nearest_edge_args.dart';
import 'stack.dart';

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
  QTNode get rootNode => _root;

  @override
  QTBoundaryImpl get tightBoundingBodyOfAllData => _boundary;

  @override
  int get numberofPointsInTheTree => _pointCount;

  @override
  int get numberOfEdgesInTheTree => _edgeCount;

  @override
  void clearPointsEdgeNodesButAdditionalData() {
    _root = QTNodeEmptyImpl.instance;
    _boundary = QTBoundaryImpl.make(0, 0, 0, 0);
    _pointCount = 0;
    _edgeCount = 0;
  }

  @override
  QTBoundaryImpl get boundaryContainingAllNodes {
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
    if (!boundaryContainingAllNodes.containsPoint(point)) {
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
    if (!boundaryContainingAllNodes.containsPoint(point)) {
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
      final node = stack.popTop;
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
          stack.pushChildrenOnTop(
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
      final node = stack.popTop;
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
          stack.pushChildrenOnTop(
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
        final node = stack.popTop;
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
            stack.pushChildrenOnTop(
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
    return args.searchResult();
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
      final node = stack.popTop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          return node;
        }
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) {
          stack.pushChildrenOnTop(
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
      final node = stack.popTop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          return node;
        }
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) {
          stack.pushReverseChildrenOnTop(
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
      final node = stack.popTop;
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
          stack.pushChildrenOnTop(
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
      final node = stack.popTop;
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
          stack.pushChildrenOnTop(
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
      final node = stack.popTop;
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
          stack.pushChildrenOnTop(
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
    stack.pushOnTop(_root);
    while (!stack.isEmpty) {
      final node = stack.popTop;
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
          stack.pushChildrenOnTop(
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
    stack.pushOnTop(_root);
    while (!stack.isEmpty) {
      final node = stack.popTop;
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
          stack.pushChildrenOnTop(
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
      startNode = pair.insertedPoint;
      startNew = pair.pointExistedElsePointNew;
    }
    if ((edge.end is PointNode) && ((edge.end as PointNodeImpl).root == _root)) {
      endNode = edge.end as PointNode;
      endNew = false;
    } else {
      final pair = tryInsertPoint(edge.end);
      endNode = pair.insertedPoint;
      endNew = pair.pointExistedElsePointNew;
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
      tryInsertPoint(point).insertedPoint;

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
      final node = stack.popTop;
      if (node is PointNode) {
        // ignore: parameter_assignments
        if (value < node.y) {
          // ignore: parameter_assignments
          value = node.y;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.ymax) stack.pushAllOnTop([node.sw, node.se, node.nw, node.ne]);
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
      final node = stack.popTop;
      if (node is PointNode) {
        if (value < node.x) {
          // ignore: parameter_assignments
          value = node.x;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.xmax) stack.pushAllOnTop([node.sw, node.nw, node.se, node.ne]);
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
      final node = stack.popTop;
      if (node is PointNode) {
        if (value > node.y) {
          // ignore: parameter_assignments
          value = node.y;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.ymin) stack.pushAllOnTop([node.nw, node.ne, node.sw, node.se]);
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
      final node = stack.popTop;
      if (node is PointNode) {
        if (value > node.x) {
          // ignore: parameter_assignments
          value = node.x;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.xmin) {
          stack.pushAllOnTop([node.se, node.ne, node.sw, node.nw]);
        }
      }
    }
    return value;
  }
}

/// A polygon mapping quad-tree for storing edges and
/// points in a two dimensional logarithmic data structure.
abstract class QuadTree {
  QTNode get rootNode;

  QTBoundaryImpl get tightBoundingBodyOfAllData;

  int get numberofPointsInTheTree;

  int get numberOfEdgesInTheTree;

  void clearPointsEdgeNodesButAdditionalData();

  QTBoundaryImpl get boundaryContainingAllNodes;

  PointNode? findPoint(
    final QTPoint point,
  );

  /// This will locate the smallest non-empty node containing the given point.
  /// Returns this is the smallest non-empty node containing the given point.
  /// If no non-empty node could be found from this node then null is returned.
  QTNodeBoundary? nodeContaining(
    final QTPoint point,
  );

  /// Finds an edge node from this node for the given edge.
  /// Set [undirected] to true if the opposite edge may also be returned, false if not.
  QTEdge? findEdge(
    final QTEdge edge,
    final bool undirected,
  );

  /// Finds the nearest point to the given point.
  /// [queryPoint] is the query point to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode? findNearestPointToPoint(
    final QTPoint queryPoint, {
    final QTPointHandler? handle,
    final double cutoffDist2 = double.maxFinite,
  });

  /// Finds the nearest point to the given edge.
  /// [queryEdge] is the query edge to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode? findNearestPointToEdge(
    final QTEdge queryEdge, {
    final QTPointHandler? handle,
    final double cutoffDist2 = double.maxFinite,
  });

  /// Finds the point close to the given edge.
  /// [queryEdge] is the query edge to find a close point to.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode? findClosePoint(
    final QTEdge queryEdge,
    final QTPointHandler handle,
  );

  /// Returns the edge nearest to the given query point, which has been matched
  /// by the given matcher, and is within the given cutoff distance.
  /// [point] is the point to find the nearest edge to.
  /// [cutoffDist2] is the maximum distance squared edges may be
  /// away from the given point to be an eligible result.
  /// [handler] is the matcher to filter eligible edges, if null all edges are accepted.
  QTEdgeNode? findNearestEdge(
    final QTPoint point, {
    final double cutoffDist2 = double.maxFinite,
    final QTEdgeHandler<Object?>? handler,
  });

  /// Returns the first left edge to the given query point.
  /// [point] is the point to find the first left edge from.
  /// [handle] is the matcher to filter eligible edges. If null all edges are accepted.
  QTEdgeNode? firstLeftEdge(
    final QTPoint point, {
    final QTEdgeHandler<Object?>? handle,
  });

  /// Handle all the edges to the left of the given point.
  /// [point] is the point to find the left edges from.
  /// [handle] is the handle to process all the edges with.
  bool foreachLeftEdge(
    final QTPoint point,
    final QTEdgeHandler<Object?> handle,
  );

  /// Gets the first point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode? firstPoint(
    final QTBoundary? boundary,
    final QTPointHandler handle,
  );

  /// Gets the last point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode? lastPoint(
    final QTBoundary? boundary,
    final QTPointHandler handle,
  );

  /// Handles each point node in the boundary.
  bool foreachPoint(
    final QTPointHandler handle, [
    final QTBoundary? bounds,
  ]);

  /// Handles each edge node in the boundary.
  /// [handle] is the handler to run on each edge in the boundary.
  /// [bounds] is the boundary containing the edges to handle.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  bool foreachEdge(
    final QTEdgeHandler<Object?> handle, [
    final QTBoundary? bounds,
    final bool exclusive = false,
  ]);

  /// Handles each node in the boundary.
  /// [handle] is the handler to run on each node in the boundary.
  /// [bounds] is the boundary containing the nodes to handle.
  /// Returns true if all nodes in the boundary were run, false if stopped.
  bool foreachNode(
    final QTNodeHandler handle, [
    final QTBoundary? bounds,
  ]);

  /// Calls given handle for the all the near points to the given point.
  /// [handle] is the handle to handle all near points with.
  /// [queryPoint] is the query point to find the points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled, false if the handled returned false and stopped early.
  bool forNearPointPoints(
    final QTPointHandler handle,
    final QTPoint queryPoint,
    final double cutoffDist2,
  );

  /// Finds the near points to the given edge.
  /// [handle] is the callback to handle the near points.
  /// [queryEdge] is the query edge to find all points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forNearEdgePoints(
    final QTPointHandler handle,
    final QTEdge queryEdge,
    final double cutoffDist2,
  );

  /// Finds the close points to the given edge.
  /// [handle] is the callback to handle the close points.
  /// [queryEdge] is the query edge to find all points close to.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forClosePoints(
    final QTPointHandler handle,
    final QTEdge queryEdge,
  );

  /// Calls given handle for all the edges near to the given query point.
  /// [handler] is the handle to handle all near edges with.
  /// [queryPoint] is the point to find the near edges to.
  /// [cutoffDist2] is the maximum distance for near edges.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forNearEdges(
    final QTEdgeHandler<Object?> handler,
    final QTPoint queryPoint,
    final double cutoffDist2,
  );

  /// Calls given handle for all the edges close to the given query point.
  /// [handler] is the handle to handle all close edges with.
  /// [queryPoint] is the point to find the close edges to.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forCloseEdges(
    final QTEdgeHandler<Object?> handler,
    final QTPoint queryPoint,
  );

  /// Finds the first intersection between the given line and lines in the tree which
  /// match the given handler. When multiple intersections exist, which intersection
  /// is discovered is not specific.
  /// [edge] is the edge to find intersections with.
  /// [hndl] is the edge handle to filter possible intersecting edges.
  /// Returns the first found intersection.
  IntersectionResult? findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
  );

  /// This handles all the intersections.
  /// [edge] is the edge to look for intersections with.
  /// [hndl] is the handler to match valid edges with.
  /// [intersections] is the set of intersections to add to.
  /// Returns true if a new intersection was found.
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
    final IntersectionSet intersections,
  );

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns the edge in the tree.
  QTEdge<T>? insertEdge<T>(
    final QTEdge<T> edge,
    final T data,
  );

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns a pair containing the edge in the tree, and true if the edge is
  /// new or false if the edge already existed in the tree.
  QTEdge<T>? tryInsertEdge<T>(
    final QTEdge<T> edge,
    final T initData,
  );

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns the point node for the point inserted into the tree, or
  /// the point node which already existed.
  PointNode insertPoint(
    final QTPoint point,
  );

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns a pair containing the point node in the tree, and true if the
  /// point is new or false if the point already existed in the tree.
  InsertPointResult tryInsertPoint(
    final QTPoint point,
  );

  /// This removes an edge from the tree.
  /// [edge] is the edge to remove from the tree.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edge begins or ends at that point.
  void removeEdge(
    final QTEdgeNode edge,
    final bool trimTree,
  );

  /// This removes a point from the tree.
  /// [point] is the point to removed from the tree.
  void removePoint(
    final PointNode point,
  );

  /// Validates this quad-tree.
  /// [sout] is the output to write errors to.
  /// Returns true if valid, false if invalid.
  bool validate([
    StringBuffer? sout,
  ]);
}
