import '../basic/qt_edge_handler.dart';
import '../node/boundary/impl_pass.dart';
import '../node/branch/interface.dart';
import '../node/edge/interface.dart';
import '../node/node/interface.dart';
import '../node/point/interface.dart';
import '../point/ops/distance2.dart';
import '../point/ops/point_on_edge.dart';
import '../point/qt_point.dart';
import 'stack.dart';

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
    stack.pushOnTop(rootNode);
    while (!stack.isEmpty) {
      final node = stack.popTop;
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
          stack.pushChildrenOnTop(node);
        }
      }
      // else, empty nodes have no edges.
    }
  }

  @override
  QTEdgeNode? searchResult() {
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

/// The nearest edge arguments to handle multiple returns
/// objects for determining the nearest edge to a point.
abstract class NearestEdgeArgs {
  /// Runs this node and all children nodes through this search.
  void run(
    final QTNode rootNode,
  );

  QTEdgeNode? searchResult();
}
