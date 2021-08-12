import '../../boundary/interface.dart';
import '../../handler_point/interface.dart';
import '../../point/interface.dart';
import '../boundary/interface.dart';
import '../edge/interface.dart';
import '../node/interface.dart';

abstract class PointNode implements QTNodeBoundary, QTPoint {
  /// Gets the point for this node.
  QTPoint get point;

  /// Gets the set of edges which start at this point.
  Set<QTEdgeNode> get startEdges;

  /// Gets the set of edges which end at this point.
  Set<QTEdgeNode> get endEdges;

  /// Gets the set of edges which pass through this node.
  Set<QTEdgeNode> get passEdges;

  /// Determines if this point is an orphan, meaning it's point isn't used by any edge.
  bool get orphan;

  /// Finds an edge that starts at this point and ends at the given point.
  QTEdgeNode? findEdgeTo(
    final QTPoint end,
  );

  /// Finds an edge that ends at this point and starts at the given point.
  QTEdgeNode? findEdgeFrom(
    final QTPoint start,
  );

  /// Finds an edge that starts or ends at this point and connects to the given point.
  QTEdgeNode? findEdgeBetween(
    final QTPoint other,
  );

  /// This finds the next point in the tree.
  PointNode? nextPoint(
    final QTPointHandler handle, [
    final QTBoundary? boundary,
  ]);

  /// This finds the previous point in the tree.
  PointNode? previousPoint(
    final QTPointHandler handle, [
    final QTBoundary? boundary,
  ]);

  /// This finds the nearest edge to the given point.
  /// When determining which edge should be considered the closest edge when the
  /// point for this node is the nearest point to the query point. This doesn't
  /// check passing edges, only beginning and ending edges because the nearest
  /// edge starts or ends at this node.
  QTEdgeNode? nearEndEdge(
    final QTPoint queryPoint,
  );

  /// Determines the replacement node when a point is removed.
  QTNode get replacement;

  /// Compares the given point with this point.
  /// Return 1 if this point is greater than the other point,
  /// -1 if this point is less than the other point,
  /// 0 if this point is the same as the other point.
  int compareTo(
    final PointNode other,
  );
}
