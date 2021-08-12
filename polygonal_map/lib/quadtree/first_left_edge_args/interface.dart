import '../edge/interface.dart';
import '../node/edge/interface.dart';
import '../point/interface.dart';

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
