import '../edge/edge.dart';
import '../point/point.dart';
import '../point/point_impl.dart';
import 'boundary.dart';

/// The geometric boundary in a quad-tree.
class QTBoundaryImpl implements QTBoundary {
  /// Determines if the given boundaries are equal.
  static bool equals(QTBoundary? a, QTBoundary? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    return (a.xmin == b.xmin) && (a.ymin == b.ymin) && (a.xmax == b.xmax) && (a.ymax == b.ymax);
  }

  /// Returns the given boundary expanded with the new point.
  static QTBoundaryImpl expand(QTBoundary? boundary, QTPoint point) {
    if (boundary == null) {
      return QTBoundaryImpl(point.x, point.y, point.x, point.y);
    } else {
      int xmin = boundary.xmin, xmax = boundary.xmax;
      if (point.x < xmin) {
        xmin = point.x;
      } else if (point.x > xmax) xmax = point.x;
      int ymin = boundary.ymin, ymax = boundary.ymax;
      if (point.y < ymin) {
        ymin = point.y;
      } else if (point.y > ymax) ymax = point.y;
      return QTBoundaryImpl(xmin, ymin, xmax, ymax);
    }
  }

  /// The minimum x component, inclusive.
  final int _xmin;

  /// The minimum y component, inclusive.
  final int _ymin;

  /// The maximum x component, inclusive.
  final int _xmax;

  /// The maximum y component, inclusive.
  final int _ymax;

  /// Creates a new boundary.
  factory QTBoundaryImpl(int x1, int y1, int x2, int y2) {
    if (x2 < x1) {
      final int temp = x1;
      x1 = x2;
      x2 = temp;
    }
    if (y2 < y1) {
      final int temp = y1;
      y1 = y2;
      y2 = temp;
    }
    return QTBoundaryImpl._(x1, y1, x2, y2);
  }

  /// Creates a new boundary.
  factory QTBoundaryImpl.Corners(QTPoint pnt1, QTPoint pnt2) {
    return QTBoundaryImpl(pnt1.x, pnt1.y, pnt2.x, pnt2.y);
  }

  /// Creates a new boundary.
  QTBoundaryImpl._(this._xmin, this._ymin, this._xmax, this._ymax);

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
  BoundaryRegion region(QTPoint point) {
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
  bool containsBoundary(QTBoundary boundary) =>
      _contains(boundary.xmin, boundary.ymin) && _contains(boundary.xmax, boundary.ymax);

  /// Checks if the given edge overlaps this boundary.
  /// Returns true if the edge is overlaps, false otherwise.
  @override
  bool overlapsEdge(QTEdge edge) {
    final BoundaryRegion region1 = region(edge.start);
    if (region1 == BoundaryRegionImpl.Inside) return true;
    final BoundaryRegion region2 = region(edge.end);
    if (region2 == BoundaryRegionImpl.Inside) return true;
    // If the edge is directly above and below or to the left and right,
    // then it will result in a contained segment.
    final BoundaryRegion orRegion = region1 | region2;
    if ((orRegion == BoundaryRegionImpl.Horizontal) || (orRegion == BoundaryRegionImpl.Vertical)) return true;
    // Check if both points are on the same side so the edge cannot be contained.
    final BoundaryRegion andRegion = region1 & region2;
    if (andRegion.has(BoundaryRegionImpl.West) ||
        andRegion.has(BoundaryRegionImpl.East) ||
        andRegion.has(BoundaryRegionImpl.North) ||
        andRegion.has(BoundaryRegionImpl.South)) return false;
    // Check for edge intersection point.
    if (orRegion.has(BoundaryRegionImpl.West)) {
      final int y = ((_xmin - edge.x1) * (edge.dy / edge.dx) + edge.y1).round();
      if ((y >= _ymin) && (y <= _ymax)) return true;
    }
    if (orRegion.has(BoundaryRegionImpl.East)) {
      final int y = ((_xmax - edge.x1 + 1) * (edge.dy / edge.dx) + edge.y1).round();
      if ((y >= _ymin) && (y <= _ymax)) return true;
    }
    if (orRegion.has(BoundaryRegionImpl.North)) {
      final int x = ((_ymin - edge.y1 + 1) * (edge.dx / edge.dy) + edge.x1).round();
      if ((x >= _xmin) && (x <= _xmax)) return true;
    }
    if (orRegion.has(BoundaryRegionImpl.South)) {
      final int x = ((_ymax - edge.y1) * (edge.dx / edge.dy) + edge.x1).round();
      if ((x >= _xmin) && (x <= _xmax)) return true;
    }
    return false;
  }

  /// Checks if the given boundary overlaps this boundary.
  /// Returns true if the given boundary overlaps this boundary, false otherwise.
  @override
  bool overlapsBoundary(QTBoundary boundary) =>
      !((_xmax < boundary.xmin) || (_ymax < boundary.ymin) || (_xmin > boundary.xmax) || (_ymin > boundary.ymax));

  /// Gets the distance squared from this boundary to the given point.
  @override
  double distance2(QTPoint point) {
    if (_xmin > point.x) {
      if (_ymin > point.y) {
        return QTPointImpl.distance2(QTPointImpl(_xmin, _ymin), point);
      } else if (_ymax >= point.y) {
        final double dx = _xmin.toDouble() - point.x.toDouble();
        return dx * dx;
      } else {
        return QTPointImpl.distance2(QTPointImpl(_xmin, _ymax), point);
      }
    } else if (_xmax >= point.x) {
      if (_ymin > point.y) {
        final double dy = _ymin.toDouble() - point.y.toDouble();
        return dy * dy;
      } else if (_ymax >= point.y) {
        return 0.0;
      } else {
        final double dy = point.y.toDouble() - _ymax.toDouble();
        return dy * dy;
      }
    } else {
      if (_ymin > point.y) {
        return QTPointImpl.distance2(QTPointImpl(_xmax, _ymin), point);
      } else if (_ymax >= point.y) {
        final double dx = point.x.toDouble() - _xmax.toDouble();
        return dx * dx;
      } else {
        return QTPointImpl.distance2(QTPointImpl(_xmax, _ymax), point);
      }
    }
  }

  /// Gets the string for this boundary.
  @override
  String toString() => "[$_xmin, $_ymin, $_xmax, $_ymax]";
}

/// The boundary regions are a set of values that can be used to
class BoundaryRegionImpl implements BoundaryRegion {
  /// Indicates that the point is inside of the boundary.
  static final BoundaryRegion Inside = BoundaryRegionImpl._(0x00);

  /// Indicates that the point is south (-Y) of the boundary.
  static final BoundaryRegion South = BoundaryRegionImpl._(0x01);

  /// Indicates that the point is south (+Y) of the boundary.
  static final BoundaryRegion North = BoundaryRegionImpl._(0x02);

  /// Indicates that the point is either north, south, or inside the boundary.
  /// This is a combination of North and South.
  static final BoundaryRegion Vertical = BoundaryRegionImpl._(0x03);

  /// Indicates that the point is west (-X) of the boundary.
  static final BoundaryRegion West = BoundaryRegionImpl._(0x04);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of South and West.
  static final BoundaryRegion SouthWest = BoundaryRegionImpl._(0x05);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of North and West.
  static final BoundaryRegion NorthWest = BoundaryRegionImpl._(0x06);

  /// Indicates that the point is east (+X) of the boundary.
  static final BoundaryRegion East = BoundaryRegionImpl._(0x08);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of South and East.
  static final BoundaryRegion SouthEast = BoundaryRegionImpl._(0x09);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of North and East.
  static final BoundaryRegion NorthEast = BoundaryRegionImpl._(0x0A);

  /// Indicates that the point is either east, west, or inside the boundary.
  /// This is a combination of East and West.
  static final BoundaryRegion Horizontal = BoundaryRegionImpl._(0x0C);

  /// The value of the boundary region.
  @override
  int value;

  /// Creates a new boundary region.
  BoundaryRegionImpl._(this.value);

  /// Determines if the given [other] BoundaryRegion is partially contained in this BoundaryRegion.
  /// Typically used with North, South, East, and West. Will always return true for Inside.
  @override
  bool has(BoundaryRegion other) => (value & other.value) == other.value;

  /// Checks if this BoundaryRegion is equal to the given [other] BoundaryRegion.
  @override
  bool operator ==(Object other) {
    return other is BoundaryRegion && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  /// Gets the OR of the two boundary regions.
  @override
  BoundaryRegion operator |(BoundaryRegion other) => BoundaryRegionImpl._(value | other.value);

  /// Gets the AND of the two boundary regions.
  @override
  BoundaryRegion operator &(BoundaryRegion other) => BoundaryRegionImpl._(value & other.value);

  /// Gets the string for the given boundary region.
  @override
  String toString() {
    switch (value) {
      case 0x00:
        return "Inside";
      case 0x01:
        return "South";
      case 0x02:
        return "North";
      case 0x03:
        return "Vertical";
      case 0x04:
        return "West";
      case 0x05:
        return "SouthWest";
      case 0x06:
        return "NorthWest";
      case 0x08:
        return "East";
      case 0x09:
        return "SouthEast";
      case 0x0A:
        return "NorthEast";
      case 0x0C:
        return "Horizontal";
      default:
        return "Unknown($value)";
    }
  }
}
