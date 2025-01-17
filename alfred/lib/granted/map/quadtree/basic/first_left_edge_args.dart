import '../node/edge/interface.dart';
import '../node/point/interface.dart';
import '../point/qt_point.dart';
import 'qt_edge.dart';
import 'qt_edge_handler.dart';

/// The first left edge arguments to handle multiple returns objects for
/// determining the first left edge to a point.
class FirstLeftEdgeArgsImpl implements FirstLeftEdgeArgs {
  /// The query point to find the first edge left of.
  final QTPoint _queryPoint;

  /// The edge matcher to filter edges with.
  final QTEdgeHandler<Object?>? _handle;

  /// The current right most value.
  double _rightValue;

  /// The currently found closest edge.
  /// Null if a point has been found closer.
  QTEdgeNode? _resultEdge;

  /// The node if the nearest part of the edge is the point.
  /// Null if an edge has been found closer.
  PointNode? _resultPoint;

  /// Creates a new first left edge argument for finding the first edge that is
  /// left of the given query point.
  /// [queryPoint] is the point to find the first edge left of.
  FirstLeftEdgeArgsImpl(
    this._queryPoint,
    this._handle,
  )   : _rightValue = -double.maxFinite,
        _resultEdge = null,
        _resultPoint = null;

  /// Gets the query point, the point to find the first edge left of.
  @override
  QTPoint get queryPoint => _queryPoint;

  /// Gets the x value of the location the left horizontal edge crosses the
  /// current result. This will be the right most value found.
  @override
  double get rightValue => _rightValue;

  /// Indicates that a result has been found. This doesn't mean the correct
  /// solution has been found. Only that a value has been found.
  @override
  bool get found => (_resultEdge != null) || (_resultPoint != null);

  /// Gets the resulting first edge left of the query point.
  /// Returns the first left edge in the tree which was found.
  /// If no edges were found null is returned.
  @override
  QTEdgeNode? get result {
    final __resultPoint = _resultPoint;
    if (__resultPoint == null) {
      return _resultEdge;
    } else {
      return __resultPoint.nearEndEdge(_queryPoint);
    }
  }

  /// This updates with the given edges.
  @override
  void update(
    final QTEdgeNode? edge,
  ) {
    if (edge != null) {
      if (edge != _resultEdge) {
        final __handle = _handle;
        if (__handle != null) {
          if (!__handle.handle(edge)) {
            return;
          }
        }
        // Determine how the edge crosses the horizontal edge from the point and left.
        if (edge.y1 == _queryPoint.y) {
          if (edge.y2 == _queryPoint.y) {
            if (edge.x1 > _queryPoint.x) {
              if (edge.x2 > _queryPoint.x) {
                // The edge to the right of the point, do nothing.
              } else {
                // The edge is collinear with and contains the query point.
                _updateWithEdge(edge, _queryPoint.x.toDouble());
              }
            } else if (edge.x2 > _queryPoint.x) {
              // The edge is collinear with and contains the query point.
              _updateWithEdge(edge, _queryPoint.x.toDouble());
            } else if (edge.x1 > edge.x2) {
              // The edge is collinear with the point and the start is more right.
              _updateWithPoint(edge.startNode);
            } else {
              // The edge is collinear with the point and the start is more left.
              _updateWithPoint(edge.endNode);
            }
          } else if (edge.x1 < _queryPoint.x) {
            // The start point is on the horizontal and to the left.
            _updateWithPoint(edge.startNode);
          } else {
            // The start point is on the horizontal but on or to the right, do nothing.
          }
        } else if (edge.y1 > _queryPoint.y) {
          if (edge.y2 == _queryPoint.y) {
            if (edge.x2 <= _queryPoint.x) {
              // The end point is on the horizontal and on or to the left.
              _updateWithPoint(edge.endNode);
            } else {
              // The end point is on the horizontal but to the right, do nothing.
            }
          } else if (edge.y2 > _queryPoint.y) {
            // The edge is above the horizontal, do nothing.
          } else {
            // (edge.y2 < this._queryPoint.y)
            if ((edge.x1 > _queryPoint.x) && (edge.x2 > _queryPoint.x)) {
              // The edge is to the right of the point, do nothing.
            } else {
              final x = (edge.x1 - edge.x2) * (_queryPoint.y - edge.y2) / (edge.y1 - edge.y2) + edge.x2;
              if (x > _queryPoint.x) {
                // The horizontal crossing is to the right of the point, do nothing.
              } else {
                // The edge crosses to the left of the point.
                _updateWithEdge(edge, x);
              }
            }
          }
        } else {
          // (edge.y1 < this._queryPoint.y)
          if (edge.y2 == _queryPoint.y) {
            if (edge.x2 <= _queryPoint.x) {
              // The end point is on the horizontal and on or to the left.
              _updateWithPoint(edge.endNode);
            } else {
              // The end point is on the horizontal but to the right, do nothing.
            }
          } else if (edge.y2 < _queryPoint.y) {
            // The edge is below the horizontal, do nothing.
          } else {
            // (edge.y2 > this._queryPoint.y)
            if ((edge.x1 > _queryPoint.x) && (edge.x2 > _queryPoint.x)) {
              // The edge is to the right of the point, do nothing.
            } else {
              final x = (edge.x1 - edge.x2) * (_queryPoint.y - edge.y2) / (edge.y1 - edge.y2) + edge.x2;
              if (x > _queryPoint.x) {
                // The horizontal crossing is to the right of the point, do nothing.
              } else {
                // The edge crosses to the left of the point.
                _updateWithEdge(edge, x);
              }
            }
          }
        }
      }
    }
  }

  /// The edge to update with has the point on the horizontal edge inside it.
  void _updateWithEdge(
    final QTEdgeNode edge,
    final double loc,
  ) {
    if (loc > _rightValue) {
      _resultEdge = edge;
      _resultPoint = null;
      _rightValue = loc;
    }
  }

  /// The edge to update with has the point on the horizontal edge at one of the end points.
  /// This is called to update with that point instead of point inside the edge.
  void _updateWithPoint(
    final PointNode point,
  ) {
    if (point.x > _rightValue) {
      // Do not set _resultEdge here, leave it as the previous value.
      _resultPoint = point;
      _rightValue = point.x.toDouble();
    }
  }
}

/// The first left edge arguments to handle multiple returns objects for
/// determining the first left edge to a point.
abstract class FirstLeftEdgeArgs {
  /// Gets the query point, the point to find the first edge left of.
  QTPoint get queryPoint;

  /// Gets the x value of the location the left horizontal edge crosses the
  /// current result. This will be the right most value found.
  double get rightValue;

  /// Indicates that a result has been found. This doesn't mean the correct
  /// solution has been found. Only that a value has been found.
  bool get found;

  /// Gets the resulting first edge left of the query point.
  /// Returns the first left edge in the tree which was found.
  /// If no edges were found null is returned.
  QTEdge? get result;

  /// This updates with the given edges.
  void update(
    final QTEdgeNode? edge,
  );
}
