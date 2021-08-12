import '../boundary/impl.dart';
import '../boundary/interface.dart';
import '../edge/impl.dart';
import '../edge/interface.dart';
import '../first_left_edge_args/impl.dart';
import '../formatter/interface.dart';
import '../formatter/string_parts.dart';
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

/// A polygon mapping quad-tree for storing edges and
/// points in a two dimensional logarithmic data structure.
class QuadTree {
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
  QuadTree()
      : _root = QTNodeEmptyImpl.instance,
        _boundary = QTBoundaryImpl(0, 0, 0, 0),
        _pointCount = 0,
        _edgeCount = 0;

  /// The root node of the quad-tree.
  QTNode get root => _root;

  /// Gets the tight bounding box of all the data.
  QTBoundaryImpl get boundary => _boundary;

  /// Gets the number of points in the tree.
  int get pointCount => _pointCount;

  /// Gets the number of edges in the tree.
  int get edgeCount => _edgeCount;

  /// Clears all the points, edges, and nodes from the quad-tree.
  /// Does not clear the additional data.
  void clear() {
    _root = QTNodeEmptyImpl.instance;
    _boundary = QTBoundaryImpl(0, 0, 0, 0);
    _pointCount = 0;
    _edgeCount = 0;
  }

  /// Gets the boundary containing all nodes.
  QTBoundaryImpl get rootBoundary {
    if (_root is QTNodeBoundaryMixin) return (_root as QTNodeBoundaryMixin).boundary;
    return QTBoundaryImpl(0, 0, 0, 0);
  }

  /// Finds a point node from this node for the given point.
  PointNode? findPoint(QTPoint point) {
    if (!rootBoundary.containsPoint(point)) return null;
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

  /// This will locate the smallest non-empty node containing the given point.
  /// Returns this is the smallest non-empty node containing the given point.
  /// If no non-empty node could be found from this node then null is returned.
  QTNodeBoundary? nodeContaining(QTPoint point) {
    if (!rootBoundary.containsPoint(point)) return null;
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

  /// Finds an edge node from this node for the given edge.
  /// Set [undirected] to true if the opposite edge may also be returned, false if not.
  QTEdge? findEdge(QTEdge edge, bool undirected) {
    final node = findPoint(edge.start);
    if (node == null) return null;
    var result = node.findEdgeTo(edge.end);
    if ((result == null) && undirected) result = node.findEdgeFrom(edge.end);
    return result;
  }

  /// Finds the nearest point to the given point.
  /// [queryPoint] is the query point to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode? findNearestPointToPoint(
    QTPoint queryPoint, {
    double cutoffDist2 = double.maxFinite,
    QTPointHandler? handle,
  }) {
    PointNode? result;
    final stack = _NodeStack<QTNode>([_root]);
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
          _pushChildren(
            stack,
            branch,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Finds the nearest point to the given edge.
  /// [queryEdge] is the query edge to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode? findNearestPointToEdge(QTEdge queryEdge, {double cutoffDist2 = double.maxFinite, QTPointHandler? handle}) {
    PointNode? result;
    final stack = _NodeStack([_root]);
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
          _pushChildren(
            stack,
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Finds the point close to the given edge.
  /// [queryEdge] is the query edge to find a close point to.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode? findClosePoint(QTEdge queryEdge, QTPointHandler handle) {
    if (qtEdgeDegenerate(queryEdge)) {
      return null;
    }
    final stack = _NodeStack([_root]);
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
          _pushChildren(
            stack,
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return null;
  }

  /// Returns the edge nearest to the given query point, which has been matched
  /// by the given matcher, and is within the given cutoff distance.
  /// [point] is the point to find the nearest edge to.
  /// [cutoffDist2] is the maximum distance squared edges may be
  /// away from the given point to be an eligible result.
  /// [handler] is the matcher to filter eligible edges, if null all edges are accepted.
  QTEdgeNode? findNearestEdge(QTPoint point, {double cutoffDist2 = double.maxFinite, QTEdgeHandler? handler}) {
    final args = NearestEdgeArgs(point, cutoffDist2, handler);
    args.run(_root);
    return args.result();
  }

  /// Returns the first left edge to the given query point.
  /// [point] is the point to find the first left edge from.
  /// [handle] is the matcher to filter eligible edges. If null all edges are accepted.
  QTEdgeNode? firstLeftEdge(
    final QTPoint point, {
    final QTEdgeHandler? handle,
  }) {
    final args = FirstLeftEdgeArgsImpl(point, handle);
    _root.firstLeftEdge(args);
    return args.result;
  }

  /// Handle all the edges to the left of the given point.
  /// [point] is the point to find the left edges from.
  /// [handle] is the handle to process all the edges with.
  bool foreachLeftEdge(QTPoint point, QTEdgeHandler handle) => _root.foreachLeftEdge(point, handle);

  /// Gets the first point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode? firstPoint(QTBoundary? boundary, QTPointHandler handle) {
    PointNode? result;
    final stack = _NodeStack<QTNode>([_root]);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) return node;
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) {
          _pushChildren(
            stack,
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Gets the last point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode? lastPoint(QTBoundary? boundary, QTPointHandler handle) {
    PointNode? result;
    final stack = _NodeStack([_root]);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) return node;
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) {
          _pushReverseChildren(
            stack,
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Handles each point node in the boundary.
  bool foreachPoint(QTPointHandler handle, [QTBoundary? bounds]) => _root.foreachPoint(handle, bounds);

  /// Handles each edge node in the boundary.
  /// [handle] is the handler to run on each edge in the boundary.
  /// [bounds] is the boundary containing the edges to handle.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  bool foreachEdge(QTEdgeHandler handle, [QTBoundary? bounds, bool exclusive = false]) =>
      _root.foreachEdge(handle, bounds, exclusive);

  /// Handles each node in the boundary.
  /// [handle] is the handler to run on each node in the boundary.
  /// [bounds] is the boundary containing the nodes to handle.
  /// Returns true if all nodes in the boundary were run, false if stopped.
  bool foreachNode(QTNodeHandler handle, [QTBoundary? bounds]) => _root.foreachNode(handle, bounds);

  /// Calls given handle for the all the near points to the given point.
  /// [handle] is the handle to handle all near points with.
  /// [queryPoint] is the query point to find the points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled, false if the handled returned false and stopped early.
  bool forNearPointPoints(QTPointHandler handle, QTPoint queryPoint, double cutoffDist2) {
    final stack = _NodeStack<QTNode>([_root]);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        final dist2 = pointDistance2(queryPoint, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = pointDistance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) {
          _pushChildren(
            stack,
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  /// Finds the near points to the given edge.
  /// [handle] is the callback to handle the near points.
  /// [queryEdge] is the query edge to find all points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forNearEdgePoints(QTPointHandler handle, QTEdge queryEdge, double cutoffDist2) {
    final stack = _NodeStack<QTNode>([_root]);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        final dist2 = qtEdgeDistance2(queryEdge, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = qtEdgeDistance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) {
          _pushChildren(
            stack,
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  /// Finds the close points to the given edge.
  /// [handle] is the callback to handle the close points.
  /// [queryEdge] is the query edge to find all points close to.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forClosePoints(QTPointHandler handle, QTEdge queryEdge) {
    final stack = _NodeStack<QTNode>([_root]);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        final pnt = pointOnEdge(queryEdge, node);
        if (pnt.onEdge) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = qtEdgeDistance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) {
          _pushChildren(
            stack,
            node,
          );
        }
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  /// Calls given handle for all the edges near to the given query point.
  /// [handler] is the handle to handle all near edges with.
  /// [queryPoint] is the point to find the near edges to.
  /// [cutoffDist2] is the maximum distance for near edges.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forNearEdges(QTEdgeHandler handler, QTPoint queryPoint, double cutoffDist2) {
    final stack = _NodeStack<QTNode>();
    stack.push(_root);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        for (final edge in node.startEdges) {
          if (qtEdgeDistance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (final edge in node.endEdges) {
          if (qtEdgeDistance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (final edge in node.passEdges) {
          if (qtEdgeDistance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is PassNode) {
        for (final edge in node.passEdges) {
          if (qtEdgeDistance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = pointDistance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) {
          _pushChildren(
            stack,
            node,
          );
        }
      }
      // else, empty nodes have no edges.
    }
    return true;
  }

  /// Calls given handle for all the edges close to the given query point.
  /// [handler] is the handle to handle all close edges with.
  /// [queryPoint] is the point to find the close edges to.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forCloseEdges(QTEdgeHandler handler, QTPoint queryPoint) {
    final stack = _NodeStack<QTNode>();
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
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is BranchNode) {
        final width = node.width;
        final x = node.xmin + width ~/ 2;
        final y = node.ymin + width ~/ 2;
        final diagDist2 = 2.0 * width * width;
        final dist2 = pointDistance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) {
          _pushChildren(
            stack,
            node,
          );
        }
      }
      // else, empty nodes have no edges.
    }
    return true;
  }

  /// Finds the first intersection between the given line and lines in the tree which
  /// match the given handler. When multiple intersections exist, which intersection
  /// is discovered is not specific.
  /// [edge] is the edge to find intersections with.
  /// [hndl] is the edge handle to filter possible intersecting edges.
  /// Returns the first found intersection.
  IntersectionResult? findFirstIntersection(QTEdge edge, QTEdgeHandler? hndl) =>
      _root.findFirstIntersection(edge, hndl);

  /// This handles all the intersections.
  /// [edge] is the edge to look for intersections with.
  /// [hndl] is the handler to match valid edges with.
  /// [intersections] is the set of intersections to add to.
  /// Returns true if a new intersection was found.
  bool findAllIntersections(QTEdge edge, QTEdgeHandler? hndl, IntersectionSet intersections) {
    if (_edgeCount <= 0) {
      return false;
    } else {
      return (_root as QTNodeBoundaryMixin).findAllIntersections(edge, hndl, intersections);
    }
  }

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns the edge in the tree.
  QTEdge? insertEdge(QTEdge edge) => tryInsertEdge(edge)?.edge;

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns a pair containing the edge in the tree, and true if the edge is
  /// new or false if the edge already existed in the tree.
  InsertEdgeResult? tryInsertEdge(
    final QTEdge edge,
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
    if (startNode == endNode) return const InsertEdgeResult(null, false);
    // If both points already existed check if edge exists.
    if (!(startNew || endNew)) {
      final edge = startNode.findEdgeTo(endNode);
      if (edge != null) {
        return InsertEdgeResult(edge, false);
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
    final newEdge = QTEdgeNodeImpl(startNode, endNode, null);
    final replacement = ancestor.insertEdge(newEdge);
    _reduceBranch(ancestor, replacement);
    _edgeCount++;
    return InsertEdgeResult(
      newEdge,
      true,
    );
  }

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns the point node for the point inserted into the tree, or
  /// the point node which already existed.
  PointNode insertPoint(QTPoint point) => tryInsertPoint(point).point;

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns a pair containing the point node in the tree, and true if the
  /// point is new or false if the point already existed in the tree.
  InsertPointResult tryInsertPoint(QTPoint point) {
    final pntNode = PointNodeImpl(point.x, point.y);
    // Attempt to find the point first.
    final node = nodeContaining(pntNode);
    final _node = node;
    if (_node != null) {
      // A node containing the point has been found.
      if (_node is PointNodeImpl) {
        if (pointEquals(_node, pntNode)) {
          return InsertPointResult(_node, true);
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
      _setRoot((_root as QTNodeEmptyImpl).addPoint(centerX, centerY, initialTreeWidth, pntNode));
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
    return InsertPointResult(pntNode, false);
  }

  /// This removes an edge from the tree.
  /// [edge] is the edge to remove from the tree.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edge begins or ends at that point.
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

  /// This removes a point from the tree.
  /// [point] is the point to removed from the tree.
  void removePoint(PointNode point) {
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

  /// Validates this quad-tree.
  /// [sout] is the output to write errors to.
  /// [format] is the format used for printing, null to use default.
  /// Returns true if valid, false if invalid.
  bool validate([StringBuffer? sout, QTFormatter? format]) {
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
    vHndl.bounds ??= QTBoundaryImpl(0, 0, 0, 0);
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
        root.parent!.toBuffer(sout, format: format);
        sout.write(".\n");
        result = false;
      }
    }
    if (!_root.validate(sout, format, true)) {
      result = false;
    }
    if (toConsole && sout.isNotEmpty) {
      print(sout.toString());
    }
    return result;
  }

  /// Formats the quad-tree into a string.
  /// [sout] is the output to write the formatted string to.
  /// [indent] is the indent for this quad-tree.
  /// [contained] indicates this node is part of another output.
  /// [last] indicates this is the last output of the parent.
  /// [format] is the format used for printing, null to use default.
  void toBuffer(StringBuffer sout,
      {String indent = "", bool contained = false, bool last = true, QTFormatter? format}) {
    if (contained) {
      sout.write(
        () {
          if (last) {
            return StringParts.Last;
          } else {
            return StringParts.Child;
          }
        }(),
      );
    }
    sout.write("Tree:");
    final childIndent = indent +
        (() {
          if (contained && !last) {
            return StringParts.Bar;
          } else {
            return StringParts.Space;
          }
        }());
    sout.write(StringParts.Sep);
    sout.write(indent);
    sout.write(StringParts.Child);
    sout.write("Boundary: ");
    if (format == null) {
      sout.write(_boundary.toString());
    } else {
      sout.write(format.toBoundaryString(_boundary));
    }
    sout.write(StringParts.Sep);
    sout.write(indent);
    sout.write(StringParts.Child);
    sout.write("Points: ");
    sout.write(_pointCount);
    sout.write(StringParts.Sep);
    sout.write(indent);
    sout.write(StringParts.Child);
    sout.write("Edges: ");
    sout.write(_edgeCount);
    sout.write(StringParts.Sep);
    sout.write(indent);
    _root.toBuffer(sout, indent: childIndent, children: true, contained: true, format: format);
  }

  /// Gets the string for this quad-tree.
  @override
  String toString() {
    final sout = StringBuffer();
    toBuffer(sout);
    return sout.toString();
  }

  /// Gets the string for the points and edges of the quad-tree.
  String toBasicString() {
    final soutPoints = StringBuffer();
    soutPoints.write("Points:");
    soutPoints.write(StringParts.Sep);
    final soutEdges = StringBuffer();
    soutEdges.write("Edges:");
    soutEdges.write(StringParts.Sep);
    foreachPoint(QTPointHandlerBasicStringHandlerImpl(soutPoints, soutEdges));
    return soutPoints.toString() + soutEdges.toString();
  }

  /// This reduces the root to the smallest branch needed.
  /// [node] is the original node to reduce.
  /// [replacement] is the node to replace the original node with.
  void _reduceBranch(QTNodeBoundary node, QTNode replacement) {
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
  bool _setRoot(QTNode? node) {
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
  QTNodeBoundaryMixin _expandFootprint(QTNodeBoundaryMixin root, QTPoint point) {
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
  void _expandBoundingBox(QTPoint point) {
    if (_pointCount <= 1) {
      _boundary = QTBoundaryImpl(point.x, point.y, point.x, point.y);
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
  void _collapseBoundingBox(QTPoint point) {
    if (_pointCount <= 0) {
      _boundary = QTBoundaryImpl(0, 0, 0, 0);
    } else {
      if (_boundary.xmax <= point.x) {
        _boundary = QTBoundaryImpl(_boundary.xmin, _boundary.ymin, _determineEastSide(_boundary.xmin), _boundary.ymax);
      }
      if (_boundary.xmin >= point.x) {
        _boundary = QTBoundaryImpl(_determineWestSide(_boundary.xmax), _boundary.ymin, _boundary.xmax, _boundary.ymax);
      }
      if (_boundary.ymax <= point.y) {
        _boundary = QTBoundaryImpl(_boundary.xmin, _boundary.ymin, _boundary.xmax, _determineNorthSide(_boundary.ymin));
      }
      if (_boundary.ymin >= point.y) {
        _boundary = QTBoundaryImpl(_boundary.xmax, _boundary.ymax, _boundary.xmin, _determineSouthSide(_boundary.ymax));
      }
    }
  }

  /// This finds the north side in the tree.
  /// Return is the value of the north side for the given direction.
  int _determineNorthSide(int value) {
    final stack = _NodeStack<QTNode>([_root]);
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
  int _determineEastSide(int value) {
    final stack = _NodeStack<QTNode>([_root]);
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
  int _determineSouthSide(int value) {
    final stack = _NodeStack<QTNode>([_root]);
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
  int _determineWestSide(int value) {
    final stack = _NodeStack<QTNode>([_root]);
    while (!stack.isEmpty) {
      final node = stack.pop;
      if (node is PointNode) {
        if (value > node.x) {
          // ignore: parameter_assignments
          value = node.x;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.xmin) stack.pushAll([node.se, node.ne, node.sw, node.nw]);
      }
    }
    return value;
  }
}

/// The result from a edge insertion into the tree.
class InsertEdgeResult {
  /// The inserted edge.
  final QTEdge? edge;

  /// True if the edge existed, false if the edge is new.
  final bool existed;

  /// Creates a new insert edge result.
  const InsertEdgeResult(
    final this.edge,
    final this.existed,
  );
}

/// The result from a point insertion into the tree.
class InsertPointResult {
  /// The inserted point.
  final PointNode point;

  /// True if the point existed, false if the point is new.
  final bool existed;

  /// Creates a new insert point result.
  const InsertPointResult(
    final this.point,
    final this.existed,
  );
}

/// The nearest edge arguments to handle multiple returns
/// objects for determining the nearest edge to a point.
class NearestEdgeArgs {
  /// The query point to find the nearest line to.
  final QTPoint _queryPoint;

  /// The line matcher to filter lines with.
  final QTEdgeHandler? _handle;

  /// The maximum allowable distance squared to the result.
  double _cutoffDist2;

  /// The currently found closest edge. Null if a point has been found closer.
  QTEdgeNode? _resultEdge;

  /// The node if the nearest part of the edge is the point.
  /// Null if an edge has been found closer.
  PointNode? _resultPoint;

  /// Creates a new nearest edge arguments.
  /// [_queryPoint] is the query point to find an edge nearest to.
  /// [_cutoffDist2] is the maximum allowable distance squared to the nearest edge.
  /// The [_handle] is the filter acceptable edges with, or null to not filter.
  NearestEdgeArgs(this._queryPoint, this._cutoffDist2, this._handle)
      : _resultEdge = null,
        _resultPoint = null;

  /// Runs this node and all children nodes through this search.
  void run(QTNode rootNode) {
    final stack = _NodeStack<QTNode>();
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
        final dist2 = pointDistance2(_queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= _cutoffDist2) {
          _pushChildren(stack, node);
        }
      }
      // else, empty nodes have no edges.
    }
  }

  /// Gets the result from this search.
  QTEdgeNode? result() {
    final __resultPoint = _resultPoint;
    if (__resultPoint == null) {
      return _resultEdge;
    } else {
      return __resultPoint.nearEndEdge(_queryPoint);
    }
  }

  /// Checks if the given edge is closer that last found edge.
  void _checkEdge(
    final QTEdgeNode? edge,
  ) {
    if (edge == null) return;
    if (edge == _resultEdge) return;
    final __handle = _handle;
    if (__handle != null) {
      if (!__handle.handle(edge)) return;
    }
    // Determine how the point is relative to the edge.
    final result = pointOnEdge(edge, _queryPoint);
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
  void _updateWithEdge(QTEdgeNode edge, QTPoint closePoint) {
    final dist2 = pointDistance2(_queryPoint, closePoint);
    if (dist2 <= _cutoffDist2) {
      _resultEdge = edge;
      _resultPoint = null;
      _cutoffDist2 = dist2;
    }
  }

  /// Update with the point at the end of the edge.
  void _updateWithPoint(PointNode point) {
    final dist2 = pointDistance2(_queryPoint, point);
    if (dist2 <= _cutoffDist2) {
      // Do not set _resultEdge here, leave it as the previous value.
      _resultPoint = point;
      _cutoffDist2 = dist2;
    }
  }
}

/// Pushes the children of the given branch onto this stack.
void _pushChildren(
  final _NodeStack<QTNode> stack,
  final BranchNode node,
) {
  // Push in reverse order from typical searches so that they
  // are processed in the order: NE, NW, SE, then SW.
  stack.push(node.sw);
  stack.push(node.se);
  stack.push(node.nw);
  stack.push(node.ne);
}

/// Pushes the children of the given branch onto this stack in reverse order.
void _pushReverseChildren(
  final _NodeStack<QTNode> stack,
  final BranchNode node,
) {
  // Push in normal order from typical searches so that they
  // are processed in the order: SW, SE, NW, then NE.
  stack.push(node.ne);
  stack.push(node.nw);
  stack.push(node.se);
  stack.push(node.sw);
}

/// A stack of nodes.
class _NodeStack<T> {
  /// The internal stack of nodes.
  final List<T> _stack;

  /// Creates a new stack.
  /// The initial sets of [nodes] is pushed in order.
  _NodeStack([
    final List<T>? nodes,
  ]) : _stack = <T>[] {
    if (nodes != null) {
      // ignore: prefer_foreach
      for (final node in nodes) {
        push(node);
      }
    }
  }

  /// Indicates if the task is empty.
  bool get isEmpty => _stack.isEmpty;

  /// Pops the the top node off the stack.
  T get pop => _stack.removeLast();

  /// Pushes the given node onto the top of the stack.
  void push(
    final T node,
  ) =>
      _stack.add(node);

  /// Pushes a set of nodes onto the stack.
  void pushAll(
    final List<T> nodes,
  ) {
    // ignore: prefer_foreach
    for (final node in nodes) {
      push(node);
    }
  }
}
