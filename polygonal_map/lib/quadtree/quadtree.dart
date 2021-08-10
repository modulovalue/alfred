import 'boundary/boundary.dart';
import 'edge/edge.dart';
import 'formatter/formatter.dart';
import 'point/ops/intersect.dart';
import 'point/point.dart';

/// The node handler is used to process
/// or match points with custom handlers inside for each methods.
abstract class QTNodeHandler {
  /// Handles the given node.
  /// The [node] to handle.
  /// Returns true to continue or accept, false to stop or reject.
  bool handle(
    final QTNode node,
  );
}

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
    final QTEdgeHandler handle, [
    final QTBoundary? bounds,
    final bool? exclusive = false,
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
    final QTEdgeHandler hndl,
  );

  /// This handles the first found intersecting edge.
  /// The [edge] to look for intersections with.
  /// The [hndl] is the handler to match valid edges with.
  /// Returns the first found intersection.
  IntersectionResult findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler hndl,
  );

  /// This handles all the intersections.
  /// The [edge] to look for intersections with.
  /// The [hndl] is the handler to match valid edges with.
  /// The set of [intersections] to add to.
  /// Returns true if a new intersection was found.
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler hndl,
    final IntersectionSet intersections,
  );

  /// Validates this node.
  /// The [format] is used for printing, null to use default.
  /// Set [recursive] true to validate all children nodes too, false otherwise.
  /// Returns true if valid, false if invalid.
  bool validate(
    final StringBuffer sout,
    final QTFormatter format,
    final bool recursive,
  );

  /// Formats just this node into a string.
  /// The [format] is used for printing, null to use default.
  /// [children] indicates any child should also be stringified.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  void toBuffer(
    final StringBuffer sout, {
    final String indent = "",
    final bool children = false,
    final bool contained = false,
    final bool last = true,
    final QTFormatter? format,
  });
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
  QTEdge get result;

  /// This updates with the given edges.
  void update(
    final QTEdge edge,
  );
}

/// The edge node handler is used to process
/// or match edges with custom handlers inside for-each methods.
abstract class QTEdgeHandler {
  /// Handles the given edge node.
  /// Return true to continue, false to stop.
  bool handle(
    final QTEdge edge,
  );
}

/// The point handler is used to process
/// or match points with custom handlers inside for-each methods.
abstract class QTPointHandler {
  /// Handles the given point.
  /// Returns true to continue, false to stop.
  bool handle(
    final PointNode point,
  );
}

abstract class PointNode implements QTNode, QTBoundary, QTPoint, Comparable<PointNode> {
  /// Gets the point for this node.
  QTPoint get point;

  /// Gets the set of edges which start at this point.
  Set<QTEdge> get startEdges;

  /// Gets the set of edges which end at this point.
  Set<QTEdge> get endEdges;

  /// Gets the set of edges which pass through this node.
  Set<QTEdge> get passEdges;

  /// Determines if this point is an orphan, meaning it's point isn't used by any edge.
  bool get orphan;

  /// Finds an edge that starts at this point and ends at the given point.
  QTEdge findEdgeTo(
    final QTPoint end,
  );

  /// Finds an edge that ends at this point and starts at the given point.
  QTEdge findEdgeFrom(
    final QTPoint start,
  );

  /// Finds an edge that starts or ends at this point and connects to the given point.
  QTEdge findEdgeBetween(
    final QTPoint other,
  );

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  QTNode insertEdge(
    final QTEdge edge,
  );

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  QTNode insertPoint(
    final PointNode point,
  );

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  QTNode removeEdge(
    final QTEdge edge,
    final bool trimTree,
  );

  /// This finds the next point in the tree.
  PointNode nextPoint(
    final QTPointHandler handle, [
    final QTBoundary? boundary,
  ]);

  /// This finds the previous point in the tree.
  PointNode previousPoint(
    final QTPointHandler handle, [
    final QTBoundary? boundary,
  ]);

  /// This finds the nearest edge to the given point.
  /// When determining which edge should be considered the closest edge when the
  /// point for this node is the nearest point to the query point. This doesn't
  /// check passing edges, only beginning and ending edges because the nearest
  /// edge starts or ends at this node.
  QTEdge nearEndEdge(
    final QTPoint queryPoint,
  );

  /// Determines the replacement node when a point is removed.
  QTNode get replacement;

  /// Compares the given point with this point.
  /// Return 1 if this point is greater than the other point,
  /// -1 if this point is less than the other point,
  /// 0 if this point is the same as the other point.
  @override
  int compareTo(
    final PointNode other,
  );
}

abstract class QTNodeBoundary implements QTNode, QTBoundary {}
