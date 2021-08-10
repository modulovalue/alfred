import '../edge/edge.dart';
import '../point/point.dart';

/// The interface for boundary types.
abstract class QTBoundary {
  /// Gets the minimum x component.
  int get xmin;

  /// Gets the minimum y component.
  int get ymin;

  /// Gets the maximum x component.
  int get xmax;

  /// Gets the maximum y component.
  int get ymax;

  /// Gets the width of boundary.
  int get width;

  /// Gets the height of boundary.
  int get height;

  /// Gets the boundary region the given point was in.
  BoundaryRegion region(
    final QTPoint point,
  );

  /// Checks if the given point is completely contained within this boundary.
  bool containsPoint(
    final QTPoint point,
  );

  /// Checks if the given edge is completely contained within this boundary.
  bool containsEdge(
    final QTEdge edge,
  );

  /// Checks if the given boundary is completely contains by this boundary.
  bool containsBoundary(
    final QTBoundary boundary,
  );

  /// Checks if the given edge overlaps this boundary.
  bool overlapsEdge(
    final QTEdge edge,
  );

  /// Checks if the given boundary overlaps this boundary.
  bool overlapsBoundary(
    final QTBoundary boundary,
  );

  /// Gets the distance squared from this boundary to the given point.
  double distance2(
    final QTPoint point,
  );
}

/// The boundary regions are a set of values that can be used to
abstract class BoundaryRegion {
  int get value;

  /// Determines if the given [other] BoundaryRegion is partially contained in this BoundaryRegion.
  /// Typically used with North, South, East, and West. Will always return true for Inside.
  bool has(
    final BoundaryRegion other,
  );

  /// Gets the OR of the two boundary regions.
  BoundaryRegion operator |(
    final BoundaryRegion other,
  );

  /// Gets the AND of the two boundary regions.
  BoundaryRegion operator &(
    final BoundaryRegion other,
  );
}
