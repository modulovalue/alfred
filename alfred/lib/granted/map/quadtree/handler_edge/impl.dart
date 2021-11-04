import '../edge/impl.dart';
import '../edge/interface.dart';
import '../node/edge/interface.dart';
import '../point/impl.dart';
import '../point/interface.dart';
import '../point/ops/equals.dart';
import '../point/ops/side.dart';
import '../quadtree/interface.dart';
import 'interface.dart';

/// An edge handler to ignore a neighboring edge to the given edge.
class QTEdgeHandlerNeighborIgnorerImpl implements QTEdgeHandler<Object?> {
  /// The edge to ignore and ignore the neighbors of.
  final QTEdge _edge;

  /// Creates a new neighbor edge ignorer.
  /// The given [edge] is the edge to ignore and ignore the neighbors of.
  QTEdgeHandlerNeighborIgnorerImpl(
    final this._edge,
  );

  /// Gets the edge to ignore and ignore the neighbors of.
  QTEdge get edge => _edge;

  /// Handles an edge to check if it should be ignored.
  @override
  bool handle(
    final QTEdgeNode edge,
  ) =>
      !(pointEquals(edge.start, _edge.start) ||
          pointEquals(edge.start, _edge.end) ||
          pointEquals(edge.end, _edge.start) ||
          pointEquals(edge.end, _edge.end));
}

/// Handler for calling a given function pointer for each edge.
class QTEdgeHandlerAnonymousImpl<T> implements QTEdgeHandler<T> {
  /// The handle to call for each edge.
  final bool Function(QTEdgeNode<T> value) _hndl;

  /// Creates a new edge handler.
  const QTEdgeHandlerAnonymousImpl(
    final this._hndl,
  );

  /// Handles the given edge.
  @override
  bool handle(
    final QTEdgeNode<T> edge,
  ) =>
      _hndl(edge);
}

/// This is an edge handler which collects the edges into a set.
class QTEdgeHandlerEdgeCollectorImpl implements QTEdgeHandler<Object?> {
  /// The set to add new edges into.
  final Set<QTEdge> _set;

  /// The matcher to filter the collected edges with.
  final QTEdgeHandler<Object?>? filter;

  /// Create a new edge collector.
  QTEdgeHandlerEdgeCollectorImpl({
    final Set<QTEdgeNode>? edgeSet,
    final this.filter,
  }) : _set = (() {
          if (edgeSet == null) {
            return <QTEdgeNode>{};
          } else {
            return edgeSet;
          }
        }());

  /// The set to add new edges into.
  Set<QTEdge> get collection => _set;

  /// Handles a new edge.
  @override
  bool handle(
    final QTEdgeNode edge,
  ) {
    final _filter = filter;
    if (_filter != null) {
      if (!_filter.handle(edge)) {
        return true;
      }
    }
    _set.add(edge);
    return true;
  }
}

/// An edge handler for determining a border neighbor.
/// The border neighbor is the most clockwise (or counter-clockwise) line sharing a point
/// with an edge. This will flow a border if the shapes is wound properly.
class QTEdgeHandlerBorderNeighborImpl implements QTEdgeHandler<Object?> {
  /// The query edge to get the neighbor of.
  final QTEdge _query;

  /// True to use a counter-clockwise border, false if clockwise.
  final bool _ccw;

  /// The matcher to filter possible neighbors.
  final QTEdgeHandler<Object?>? _matcher;

  /// The current result neighbor edge.
  QTEdgeNode? _result;

  /// The current result edge or opposite to point away from query edge.
  QTEdge? _adjusted;

  /// Indicates that forward edges are still allowed,
  /// edges which head in the same direction as the query edge.
  bool _allowFore;

  /// Indicates that backward edges are still allowed,
  /// edges which head back towards the query point.
  bool _allowBack;

  /// Indicates that left or right edges are still allowed.
  bool _allowTurn;

  /// Indicates that a left edge has been found.
  bool _hasLeft;

  /// Indicates that a right edge has been found.
  bool _hasRight;

  /// Creates a new border neighbor finder.
  /// The given [_query] point is usually the other point on the border.
  /// Set [_ccw] to true to use a counter-clockwise border, false if clockwise.
  /// The given [_matcher] will filter possible neighbors.
  QTEdgeHandlerBorderNeighborImpl(
    final this._query, [
    final this._ccw = true,
    final this._matcher,
  ])  : _result = null,
        _adjusted = null,
        _allowFore = true,
        _allowBack = true,
        _allowTurn = true,
        _hasLeft = false,
        _hasRight = false;

  /// Creates a new border neighbor finder.
  /// The given [origin] point is the origin for neighbors.
  /// The given [query] point is usually the other point on the border.
  /// Set [ccw] to true to use a counter-clockwise border, false if clockwise.
  /// The given [matcher] will filter possible neighbors.
  QTEdgeHandlerBorderNeighborImpl.Points(
    final QTPoint origin,
    final QTPoint query, [
    final bool ccw = true,
    final QTEdgeHandler<Object?>? matcher,
  ]) : this(
          QTEdgeImpl(origin, query, null),
          ccw,
          matcher,
        );

  /// The currently found edge border neighbor or null.
  QTEdgeNode? get result => this._result;

  /// Updates the border neighbor with the given edge.
  /// Always returns true.
  @override
  bool handle(
    final QTEdgeNode edge,
  ) {
    if (_matcher != null) {
      if (edge is QTEdgeNode) {
        if (!_matcher!.handle(edge)) {
          return true;
        }
      }
    }
    final adjusted = _adjustedNeighbor(edge);
    if (adjusted == null) {
      return true;
    }
    if (_ccw) {
      _ccwNeighbor(edge, adjusted);
    } else {
      _cwNeighbor(edge, adjusted);
    }
    return true;
  }

  /// Gets the neighbor edge edge or opposite to point away from query edge.
  QTEdge? _adjustedNeighbor(
    final QTEdge edge,
  ) {
    if (pointEquals(edge.start, _query.start) || pointEquals(edge.start, _query.end)) {
      return edge;
    } else if (pointEquals(edge.end, _query.start) || pointEquals(edge.end, _query.end)) {
      return QTEdgeImpl(
        edge.end,
        edge.start,
        null,
      );
    } else {
      return null;
    }
  }

  /// Updates the counter-clockwise border neighbor.
  void _ccwNeighbor(
    final QTEdgeNode edge,
    final QTEdge adjusted,
  ) {
    // Get the far point in the other edge.
    final point = adjusted.end;
    // Check if edge is opposite.
    if (pointEquals(point, _query.end)) {
      if (_allowBack) {
        _result = edge;
        _adjusted = adjusted;
        _allowBack = false;
      }
      return;
    } else {
      // Determine the side of the query edge that the other edge is on.
      switch (side(_query, point)) {
        case Side.Inside:
          if (_allowFore || _allowBack) {
            // Bias toward edges heading the same way.
            if (qtEdgeAcute(_query, edge)) {
              if (_allowFore) {
                _result = edge;
                _adjusted = adjusted;
                _allowFore = false;
                _allowBack = false;
                _allowTurn = false;
              }
            } else if (_allowBack) {
              _result = edge;
              _adjusted = adjusted;
              _allowBack = false;
            }
          }
          break;
        case Side.Left:
          if (_allowTurn) {
            if (!_hasLeft) {
              _result = edge;
              _adjusted = adjusted;
              _hasLeft = true;
              _allowBack = false;
            } else if (side(_adjusted!, point) == Side.Right) {
              _result = edge;
              _adjusted = adjusted;
            }
          }
          break;
        case Side.Right:
          if (!_hasRight) {
            _result = edge;
            _adjusted = adjusted;
            _hasRight = true;
            _allowFore = false;
            _allowBack = false;
            _allowTurn = false;
          } else if (side(_adjusted!, point) == Side.Right) {
            _result = edge;
            _adjusted = adjusted;
          }
          break;
      }
    }
  }

  /// Updates the clockwise border neighbor.
  void _cwNeighbor(
    final QTEdgeNode edge,
    final QTEdge adjusted,
  ) {
    // Get the far point in the other edge.
    final point = adjusted.end;
    // Check if edge is opposite.
    if (pointEquals(point, _query.end)) {
      if (_allowBack) {
        _result = edge;
        _adjusted = adjusted;
        _allowBack = false;
      }
      return;
    }
    // Determine the side of the query edge that the other edge is on.
    switch (side(_query, point)) {
      case Side.Inside:
        if (_allowFore || _allowBack) {
          // Bias toward edges heading the same way.
          if (qtEdgeAcute(_query, edge)) {
            if (_allowFore) {
              _result = edge;
              _adjusted = adjusted;
              _allowFore = false;
              _allowBack = false;
              _allowTurn = false;
            }
          } else if (_allowBack) {
            _result = edge;
            _adjusted = adjusted;
            _allowBack = false;
          }
        }
        break;
      case Side.Left:
        if (!_hasLeft) {
          _result = edge;
          _adjusted = adjusted;
          _hasLeft = true;
          _allowFore = false;
          _allowBack = false;
          _allowTurn = false;
        } else if (side(_adjusted!, point) == Side.Left) {
          _result = edge;
          _adjusted = adjusted;
        }
        break;
      case Side.Right:
        if (_allowTurn) {
          if (!_hasRight) {
            _result = edge;
            _adjusted = adjusted;
            _hasRight = true;
            _allowBack = false;
          } else if (side(_adjusted!, point) == Side.Left) {
            _result = edge;
            _adjusted = adjusted;
          }
        }
        break;
    }
  }
}

/// An edge handler which can be used to accumulate a shapes area.
class QTEdgeHandlerAreaAccumulatorImpl implements QTEdgeHandler<Object?> {
  /// The currently accumulated area.
  double _area;

  /// Create a new area accumulator.
  QTEdgeHandlerAreaAccumulatorImpl() : _area = 0.0;

  /// This gets the signed area accumulated.
  /// A positive area generally wraps counter-clockwise,
  /// a negative area generally wraps clockwise.
  double get signedArea => _area;

  /// This returns the unsigned area accumulated.
  double get area {
    if (_area < 0.0) {
      return -_area;
    } else {
      return _area;
    }
  }

  /// Indicates if the shape  if accumulated area is counter clockwise,
  /// Returns true if counter clockwise, false if clockwise.
  bool get ccw => _area > 0.0;

  /// Adds a new edge of the shape to the accumulated area.
  /// Always returns true.
  @override
  bool handle(
    final QTEdge edge,
  ) {
    _area += (edge.x1.toDouble() * edge.y2.toDouble() - edge.x2.toDouble() * edge.y1.toDouble()) * 0.5;
    return true;
  }
}

/// Collect all edges inside the polygon.
class QTEdgeHandlerEdgeRemoverImpl implements QTEdgeHandler<Object?> {
  final QuadTree _region;
  final Set<QTEdgeNode> remove;

  QTEdgeHandlerEdgeRemoverImpl(
    final this._region,
  ) : remove = <QTEdgeNode>{};

  @override
  bool handle(
    final QTEdgeNode edge,
  ) {
    final center = QTPointImpl(
      edge.x1 + edge.dx ~/ 2,
      edge.y1 + edge.dy ~/ 2,
    );
    if (pointEquals(edge.start, center) || pointEquals(edge.end, center)) {
      // Determine if the edge is inside.
      // If both points are not on the region edge then it is outside
      // because all inside points have been removed.
      final start = _region.findPoint(edge.start);
      if (start == null) {
        return true;
      }
      final end = _region.findPoint(edge.end);
      if (end == null) {
        return true;
      }
      // If edge is one of the region edges ignore it for now.
      if (start.findEdgeBetween(end) != null) {
        return true;
      }
      // Find nearest edge on region.
      final border = QTEdgeHandlerBorderNeighborImpl.Points(
        end,
        start,
        false,
        null,
      );
      // ignore: prefer_foreach
      for (final neighbor in start.startEdges) {
        border.handle(neighbor);
      }
      // ignore: prefer_foreach
      for (final neighbor in start.endEdges) {
        border.handle(neighbor);
      }
      final regionEdge = border.result;
      if (regionEdge != null) {
        if (regionEdge.endNode != start) {
          remove.add(edge);
        }
      }
    } else {
      final first = _region.firstLeftEdge(center);
      if (first != null) {
        if (side(first, center) == Side.Left) {
          remove.add(edge);
        }
      }
    }
    return true;
  }
}
