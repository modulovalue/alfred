import '../../basic/first_left_edge_args.dart';
import '../../basic/qt_edge.dart';
import '../../basic/qt_edge_handler.dart';
import '../../basic/qt_node_handler.dart';
import '../../basic/qt_point_handler.dart';
import '../../boundary.dart';
import '../../point/ops/intersect.dart';
import '../../point/qt_point.dart';

/// The interface for all nodes in a quad-tree.
abstract class QTNode {
  /// Handles each point node reachable from this node.
  /// Returns true if all points were run, false if stopped.
  bool foreachPoint(
    final QTPointHandler handle, [
    final QTBoundary? bounds,
  ]);

  /// Handles each edge node reachable from this node.
  /// Returns true if all edges were run, false if stopped.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  bool foreachEdge(
    final QTEdgeHandler<Object?> handle, [
    final QTBoundary? bounds,
    final bool exclusive = false,
  ]);

  /// Handles each node reachable from this node.
  /// Returns true if all nodes were run, false if stopped.
  bool foreachNode(
    final QTNodeHandler handle, [
    final QTBoundary? bounds,
  ]);

  /// Determines if the node has any point nodes inside it.
  bool get hasPoints;

  /// Determines if the node has any edge nodes inside it.
  bool get hasEdges;

  /// Gets the first edge to the left of the given point.
  /// The [args] is used to store all the input arguments and
  /// results for running this methods.
  void firstLeftEdge(
    final FirstLeftEdgeArgs args,
  );

  /// Handles all the edges to the left of the given point.
  /// The [query] is the point to find the left edges from.
  /// Returns true if all the edges were processed, false if the handle stopped early.
  bool foreachLeftEdge(
    final QTPoint query,
    final QTEdgeHandler<Object?> hndl,
  );

  /// This handles the first found intersecting edge.
  /// The [edge] to look for intersections with.
  /// The [hndl] is the handler to match valid edges with.
  /// Returns the first found intersection.
  IntersectionResult? findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
  );

  /// This handles all the intersections.
  /// The [edge] to look for intersections with.
  /// The [hndl] is the handler to match valid edges with.
  /// The set of [intersections] to add to.
  /// Returns true if a new intersection was found.
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
    final IntersectionSet intersections,
  );

  /// Validates this node.
  /// Set [recursive] true to validate all children nodes too, false otherwise.
  /// Returns true if valid, false if invalid.
  bool validate(
    final StringBuffer sout,
    final bool recursive,
  );
}
