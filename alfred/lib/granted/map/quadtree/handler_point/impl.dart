import '../boundary/impl.dart';
import '../edge/interface.dart';
import '../handler_point/interface.dart';
import '../node/point/interface.dart';
import '../point/ops/equals.dart';
import '../point/ops/side.dart';
import '../quadtree/impl.dart';
import 'interface.dart';

/// Validation handler is an assistant method to the validate method.
class QTPointHandlerValidateHandlerImpl implements QTPointHandler {
  QTBoundaryImpl? bounds;
  int pointCount = 0;
  int edgeCount = 0;

  QTPointHandlerValidateHandlerImpl();

  @override
  bool handle(
    final PointNode point,
  ) {
    bounds = boundaryExpand(bounds, point);
    pointCount++;
    edgeCount += point.startEdges.length;
    return true;
  }
}

/// This is a point handler which collects the points into a set.
class QTPointHandlerCollectorImpl implements QTPointHandler {
  /// The set to add new points into.
  final Set<PointNode> _set;

  /// The matcher to filter the collected points with.
  final QTPointHandler? filter;

  /// Create a new point collector.
  QTPointHandlerCollectorImpl({
    final Set<PointNode>? nodes,
    final this.filter,
  }) : _set = (() {
          if (nodes == null) {
            return <PointNode>{};
          } else {
            return nodes;
          }
        }());

  /// The set to add new points into.
  Set<PointNode> get collection => _set;

  /// Handles a new point.
  @override
  bool handle(
    final PointNode point,
  ) {
    final _filter = filter;
    if (_filter != null) {
      if (!_filter.handle(point)) {
        return true;
      }
    }
    _set.add(point);
    return true;
  }
}

/// Handler for calling a given function pointer for each node.
class QTPointHandlerAnonymousImpl implements QTPointHandler {
  /// The handle to call for each node.
  final bool Function(PointNode point) _hndl;

  /// Creates a new node handler.
  const QTPointHandlerAnonymousImpl(
    final this._hndl,
  );

  /// Handles the given node.
  @override
  bool handle(
    final PointNode node,
  ) =>
      _hndl(node);
}

/// A point handler for ignoring the start and end point of an edge.
class QTPointHandlerEdgePointIgnorerImpl implements QTPointHandler {
  /// The edge to ignore the points of.
  final QTEdge _edge;

  /// Create a new edge point ignorer.
  /// The given [edge] is the edge to ignore the points of.
  QTPointHandlerEdgePointIgnorerImpl(
    final this._edge,
  );

  /// Gets the edge to ignore the points of.
  QTEdge get edge => _edge;

  /// Handles the point to check to ignore.
  /// Returns true to allow, false to ignore.
  @override
  bool handle(
    final PointNode point,
  ) =>
      !(pointEquals(point, _edge.start) || pointEquals(point, _edge.end));
}

/// Collect all points inside the polygon.
class QTPointHandlerPointRemoverImpl implements QTPointHandler {
  final QuadTree _region;
  final Set<PointNode> remove;

  QTPointHandlerPointRemoverImpl(
    final this._region,
  ) : remove = <PointNode>{};

  @override
  bool handle(
    final PointNode point,
  ) {
    final edge = _region.firstLeftEdge(point);
    if (edge != null) {
      if (side(edge, point) == Side.Left) {
        remove.add(point);
      }
    }
    return true;
  }
}
