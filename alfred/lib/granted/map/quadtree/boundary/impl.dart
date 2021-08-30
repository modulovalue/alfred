import '../boundary_region/impl.dart';
import '../boundary_region/interface.dart';
import '../edge/interface.dart';
import '../point/impl.dart';
import '../point/interface.dart';
import '../point/ops/distance2.dart';
import 'interface.dart';

/// Determines if the given boundaries are equal.
bool boundaryEquals(
  final QTBoundary? a,
  final QTBoundary? b,
) {
  if (a == null) {
    return b == null;
  } else if (b == null) {
    return false;
  } else {
    return (a.xmin == b.xmin) && (a.ymin == b.ymin) && (a.xmax == b.xmax) && (a.ymax == b.ymax);
  }
}

/// Returns the given boundary expanded with the new point.
QTBoundaryImpl boundaryExpand(
  final QTBoundary? boundary,
  final QTPoint point,
) {
  if (boundary == null) {
    return QTBoundaryImpl.make(point.x, point.y, point.x, point.y);
  } else {
    int xmin = boundary.xmin, xmax = boundary.xmax;
    if (point.x < xmin) {
      xmin = point.x;
    } else if (point.x > xmax) {
      xmax = point.x;
    }
    int ymin = boundary.ymin, ymax = boundary.ymax;
    if (point.y < ymin) {
      ymin = point.y;
    } else if (point.y > ymax) {
      ymax = point.y;
    }
    return QTBoundaryImpl.make(
      xmin,
      ymin,
      xmax,
      ymax,
    );
  }
}

/// The geometric boundary in a quad-tree.
class QTBoundaryImpl implements QTBoundary {
  /// The minimum x component, inclusive.
  final int _xmin;

  /// The minimum y component, inclusive.
  final int _ymin;

  /// The maximum x component, inclusive.
  final int _xmax;

  /// The maximum y component, inclusive.
  final int _ymax;

  /// Creates a new boundary.
  static QTBoundaryImpl make(
    int x1,
    int y1,
    int x2,
    int y2,
  ) {
    if (x2 < x1) {
      final temp = x1;
      // ignore: parameter_assignments
      x1 = x2;
      // ignore: parameter_assignments
      x2 = temp;
    }
    if (y2 < y1) {
      final temp = y1;
      // ignore: parameter_assignments
      y1 = y2;
      // ignore: parameter_assignments
      y2 = temp;
    }
    return QTBoundaryImpl._(x1, y1, x2, y2);
  }

  /// Creates a new boundary.
  static QTBoundaryImpl Corners(
    final QTPoint pnt1,
    final QTPoint pnt2,
  ) =>
      QTBoundaryImpl.make(pnt1.x, pnt1.y, pnt2.x, pnt2.y);

  /// Creates a new boundary.
  const QTBoundaryImpl._(
    final this._xmin,
    final this._ymin,
    final this._xmax,
    final this._ymax,
  );

  /// Gets the minimum x component.
  @override
  int get xmin => _xmin;

  /// Gets the minimum y component.
  @override
  int get ymin => _ymin;

  /// Gets the maximum x component.
  @override
  int get xmax => _xmax;

  /// Gets the maximum y component.
  @override
  int get ymax => _ymax;

  /// Gets the width of boundary.
  @override
  int get width => _xmax - _xmin + 1;

  /// Gets the height of boundary.
  @override
  int get height => _ymax - _ymin + 1;

  /// Indicates if there is no with nor height.
  bool get empty => (width <= 0) || (height <= 0);

  /// Gets the boundary region the given point was in.
  @override
  BoundaryRegion region(
    final QTPoint point,
  ) {
    if (_xmin > point.x) {
      if (_ymin > point.y) {
        return BoundaryRegionImpl.SouthWest;
      } else if (_ymax >= point.y) {
        return BoundaryRegionImpl.West;
      } else {
        return BoundaryRegionImpl.NorthWest;
      }
    } else if (_xmax >= point.x) {
      if (_ymin > point.y) {
        return BoundaryRegionImpl.South;
      } else if (_ymax >= point.y) {
        return BoundaryRegionImpl.Inside;
      } else {
        return BoundaryRegionImpl.North;
      }
    } else {
      if (_ymin > point.y) {
        return BoundaryRegionImpl.SouthEast;
      } else if (_ymax >= point.y) {
        return BoundaryRegionImpl.East;
      } else {
        return BoundaryRegionImpl.NorthEast;
      }
    }
  }

  /// Checks if the given point is completely contained within this boundary.
  bool _contains(int x, int y) => !((_xmin > x) || (_xmax < x) || (_ymin > y) || (_ymax < y));

  /// Checks if the given point is completely contained within this boundary.
  /// Returns true if the point is fully contained, false otherwise.
  @override
  bool containsPoint(QTPoint point) => _contains(point.x, point.y);

  /// Checks if the given edge is completely contained within this boundary.
  /// Returns true if the edge is fully contained, false otherwise.
  @override
  bool containsEdge(QTEdge edge) => _contains(edge.x1, edge.y1) && _contains(edge.x2, edge.y2);

  /// Checks if the given boundary is completely contains by this boundary.
  /// @Returns true if the boundary is fully contained, false otherwise.
  @override
  bool containsBoundary(
    final QTBoundary boundary,
  ) =>
      _contains(boundary.xmin, boundary.ymin) && _contains(boundary.xmax, boundary.ymax);

  /// Checks if the given edge overlaps this boundary.
  /// Returns true if the edge is overlaps, false otherwise.
  @override
  bool overlapsEdge(
    final QTEdge edge,
  ) {
    final region1 = region(edge.start);
    if (region1 == BoundaryRegionImpl.Inside) {
      return true;
    }
    final region2 = region(edge.end);
    if (region2 == BoundaryRegionImpl.Inside) {
      return true;
    }
    // If the edge is directly above and below or to the left and right,
    // then it will result in a contained segment.
    final orRegion = region1 | region2;
    if ((orRegion == BoundaryRegionImpl.Horizontal) || (orRegion == BoundaryRegionImpl.Vertical)) {
      return true;
    }
    // Check if both points are on the same side so the edge cannot be contained.
    final andRegion = region1 & region2;
    if (andRegion.has(BoundaryRegionImpl.West) ||
        andRegion.has(BoundaryRegionImpl.East) ||
        andRegion.has(BoundaryRegionImpl.North) ||
        andRegion.has(BoundaryRegionImpl.South)) {
      return false;
    }
    // Check for edge intersection point.
    if (orRegion.has(BoundaryRegionImpl.West)) {
      final y = ((_xmin - edge.x1) * (edge.dy / edge.dx) + edge.y1).round();
      if ((y >= _ymin) && (y <= _ymax)) {
        return true;
      }
    }
    if (orRegion.has(BoundaryRegionImpl.East)) {
      final y = ((_xmax - edge.x1 + 1) * (edge.dy / edge.dx) + edge.y1).round();
      if ((y >= _ymin) && (y <= _ymax)) {
        return true;
      }
    }
    if (orRegion.has(BoundaryRegionImpl.North)) {
      final x = ((_ymin - edge.y1 + 1) * (edge.dx / edge.dy) + edge.x1).round();
      if ((x >= _xmin) && (x <= _xmax)) {
        return true;
      }
    }
    if (orRegion.has(BoundaryRegionImpl.South)) {
      final x = ((_ymax - edge.y1) * (edge.dx / edge.dy) + edge.x1).round();
      if ((x >= _xmin) && (x <= _xmax)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the given boundary overlaps this boundary.
  /// Returns true if the given boundary overlaps this boundary, false otherwise.
  @override
  bool overlapsBoundary(
    final QTBoundary boundary,
  ) =>
      !((_xmax < boundary.xmin) || (_ymax < boundary.ymin) || (_xmin > boundary.xmax) || (_ymin > boundary.ymax));

  /// Gets the distance squared from this boundary to the given point.
  @override
  double distance2(
    final QTPoint point,
  ) {
    if (_xmin > point.x) {
      if (_ymin > point.y) {
        return pointDistance2(QTPointImpl(_xmin, _ymin), point);
      } else if (_ymax >= point.y) {
        final dx = _xmin.toDouble() - point.x.toDouble();
        return dx * dx;
      } else {
        return pointDistance2(QTPointImpl(_xmin, _ymax), point);
      }
    } else if (_xmax >= point.x) {
      if (_ymin > point.y) {
        final dy = _ymin.toDouble() - point.y.toDouble();
        return dy * dy;
      } else if (_ymax >= point.y) {
        return 0.0;
      } else {
        final dy = point.y.toDouble() - _ymax.toDouble();
        return dy * dy;
      }
    } else {
      if (_ymin > point.y) {
        return pointDistance2(QTPointImpl(_xmax, _ymin), point);
      } else if (_ymax >= point.y) {
        final dx = point.x.toDouble() - _xmax.toDouble();
        return dx * dx;
      } else {
        return pointDistance2(QTPointImpl(_xmax, _ymax), point);
      }
    }
  }

  /// Gets the string for this boundary.
  @override
  String toString() => "[$_xmin, $_ymin, $_xmax, $_ymax]";
}
