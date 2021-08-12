import '../boundary_region/interface.dart';
import '../edge/interface.dart';
import '../point/interface.dart';

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
