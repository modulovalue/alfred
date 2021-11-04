import '../boundary.dart';
import '../edge/interface.dart';
import '../handler_edge/interface.dart';
import '../handler_node/interface.dart';
import '../handler_point/interface.dart';
import '../node/boundary/interface.dart';
import '../node/branch/interface.dart';
import '../node/edge/interface.dart';
import '../node/node/interface.dart';
import '../node/point/interface.dart';
import '../point/interface.dart';
import '../point/ops/intersect.dart';

/// A polygon mapping quad-tree for storing edges and
/// points in a two dimensional logarithmic data structure.
abstract class QuadTree {
  /// The root node of the quad-tree.
  QTNode get root;

  /// Gets the tight bounding box of all the data.
  QTBoundaryImpl get boundary;

  /// Gets the number of points in the tree.
  int get pointCount;

  /// Gets the number of edges in the tree.
  int get edgeCount;

  /// Clears all the points, edges, and nodes from the quad-tree.
  /// Does not clear the additional data.
  void clear();

  /// Gets the boundary containing all nodes.
  QTBoundaryImpl get rootBoundary;

  /// Finds a point node from this node for the given point.
  PointNode? findPoint(
    final QTPoint point,
  );

  /// This will locate the smallest non-empty node containing the given point.
  /// Returns this is the smallest non-empty node containing the given point.
  /// If no non-empty node could be found from this node then null is returned.
  QTNodeBoundary? nodeContaining(
    final QTPoint point,
  );

  /// Finds an edge node from this node for the given edge.
  /// Set [undirected] to true if the opposite edge may also be returned, false if not.
  QTEdge? findEdge(
    final QTEdge edge,
    final bool undirected,
  );

  /// Finds the nearest point to the given point.
  /// [queryPoint] is the query point to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode? findNearestPointToPoint(
    final QTPoint queryPoint, {
    final QTPointHandler? handle,
    double cutoffDist2 = double.maxFinite,
  });

  /// Finds the nearest point to the given edge.
  /// [queryEdge] is the query edge to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode? findNearestPointToEdge(
    final QTEdge queryEdge, {
    final QTPointHandler? handle,
    double cutoffDist2 = double.maxFinite,
  });

  /// Finds the point close to the given edge.
  /// [queryEdge] is the query edge to find a close point to.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode? findClosePoint(
    final QTEdge queryEdge,
    final QTPointHandler handle,
  );

  /// Returns the edge nearest to the given query point, which has been matched
  /// by the given matcher, and is within the given cutoff distance.
  /// [point] is the point to find the nearest edge to.
  /// [cutoffDist2] is the maximum distance squared edges may be
  /// away from the given point to be an eligible result.
  /// [handler] is the matcher to filter eligible edges, if null all edges are accepted.
  QTEdgeNode? findNearestEdge(
    final QTPoint point, {
    final double cutoffDist2 = double.maxFinite,
    final QTEdgeHandler<Object?>? handler,
  });

  /// Returns the first left edge to the given query point.
  /// [point] is the point to find the first left edge from.
  /// [handle] is the matcher to filter eligible edges. If null all edges are accepted.
  QTEdgeNode? firstLeftEdge(
    final QTPoint point, {
    final QTEdgeHandler<Object?>? handle,
  });

  /// Handle all the edges to the left of the given point.
  /// [point] is the point to find the left edges from.
  /// [handle] is the handle to process all the edges with.
  bool foreachLeftEdge(
    final QTPoint point,
    final QTEdgeHandler<Object?> handle,
  );

  /// Gets the first point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode? firstPoint(
    final QTBoundary? boundary,
    final QTPointHandler handle,
  );

  /// Gets the last point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode? lastPoint(
    final QTBoundary? boundary,
    final QTPointHandler handle,
  );

  /// Handles each point node in the boundary.
  bool foreachPoint(
    final QTPointHandler handle, [
    final QTBoundary? bounds,
  ]);

  /// Handles each edge node in the boundary.
  /// [handle] is the handler to run on each edge in the boundary.
  /// [bounds] is the boundary containing the edges to handle.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  bool foreachEdge(
    final QTEdgeHandler<Object?> handle, [
    final QTBoundary? bounds,
    final bool exclusive = false,
  ]);

  /// Handles each node in the boundary.
  /// [handle] is the handler to run on each node in the boundary.
  /// [bounds] is the boundary containing the nodes to handle.
  /// Returns true if all nodes in the boundary were run, false if stopped.
  bool foreachNode(
    final QTNodeHandler handle, [
    final QTBoundary? bounds,
  ]);

  /// Calls given handle for the all the near points to the given point.
  /// [handle] is the handle to handle all near points with.
  /// [queryPoint] is the query point to find the points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled, false if the handled returned false and stopped early.
  bool forNearPointPoints(
    final QTPointHandler handle,
    final QTPoint queryPoint,
    final double cutoffDist2,
  );

  /// Finds the near points to the given edge.
  /// [handle] is the callback to handle the near points.
  /// [queryEdge] is the query edge to find all points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forNearEdgePoints(
    final QTPointHandler handle,
    final QTEdge queryEdge,
    final double cutoffDist2,
  );

  /// Finds the close points to the given edge.
  /// [handle] is the callback to handle the close points.
  /// [queryEdge] is the query edge to find all points close to.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forClosePoints(
    final QTPointHandler handle,
    final QTEdge queryEdge,
  );

  /// Calls given handle for all the edges near to the given query point.
  /// [handler] is the handle to handle all near edges with.
  /// [queryPoint] is the point to find the near edges to.
  /// [cutoffDist2] is the maximum distance for near edges.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forNearEdges(
    final QTEdgeHandler<Object?> handler,
    final QTPoint queryPoint,
    final double cutoffDist2,
  );

  /// Calls given handle for all the edges close to the given query point.
  /// [handler] is the handle to handle all close edges with.
  /// [queryPoint] is the point to find the close edges to.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forCloseEdges(
    final QTEdgeHandler<Object?> handler,
    final QTPoint queryPoint,
  );

  /// Finds the first intersection between the given line and lines in the tree which
  /// match the given handler. When multiple intersections exist, which intersection
  /// is discovered is not specific.
  /// [edge] is the edge to find intersections with.
  /// [hndl] is the edge handle to filter possible intersecting edges.
  /// Returns the first found intersection.
  IntersectionResult? findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
  );

  /// This handles all the intersections.
  /// [edge] is the edge to look for intersections with.
  /// [hndl] is the handler to match valid edges with.
  /// [intersections] is the set of intersections to add to.
  /// Returns true if a new intersection was found.
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
    final IntersectionSet intersections,
  );

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns the edge in the tree.
  QTEdge<T>? insertEdge<T>(
    final QTEdge<T> edge,
    final T data,
  );

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns a pair containing the edge in the tree, and true if the edge is
  /// new or false if the edge already existed in the tree.
  QTEdge<T>? tryInsertEdge<T>(
    final QTEdge<T> edge,
    final T initData,
  );

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns the point node for the point inserted into the tree, or
  /// the point node which already existed.
  PointNode insertPoint(
    final QTPoint point,
  );

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns a pair containing the point node in the tree, and true if the
  /// point is new or false if the point already existed in the tree.
  InsertPointResult tryInsertPoint(
    final QTPoint point,
  );

  /// This removes an edge from the tree.
  /// [edge] is the edge to remove from the tree.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edge begins or ends at that point.
  void removeEdge(
    final QTEdgeNode edge,
    final bool trimTree,
  );

  /// This removes a point from the tree.
  /// [point] is the point to removed from the tree.
  void removePoint(
    final PointNode point,
  );

  /// Validates this quad-tree.
  /// [sout] is the output to write errors to.
  /// Returns true if valid, false if invalid.
  bool validate([
    StringBuffer? sout,
  ]);
}

/// The result from a point insertion into the tree.
abstract class InsertPointResult {
  /// The inserted point.
  PointNode get point;

  /// True if the point existed, false if the point is new.
  bool get existed;
}

/// The nearest edge arguments to handle multiple returns
/// objects for determining the nearest edge to a point.
abstract class NearestEdgeArgs {
  /// Runs this node and all children nodes through this search.
  void run(
    final QTNode rootNode,
  );

  /// Gets the result from this search.
  QTEdgeNode? result();
}

/// A stack of nodes.
abstract class NodeStack {
  /// Indicates if the task is empty.
  bool get isEmpty;

  /// Pops the the top node off the stack.
  QTNode get pop;

  /// Pushes the given node onto the top of the stack.
  void push(
    final QTNode node,
  );

  /// Pushes a set of nodes onto the stack.
  void pushAll(
    final List<QTNode> nodes,
  );

  /// Pushes the children of the given branch onto this stack.
  void pushChildren(
    final BranchNode node,
  );

  /// Pushes the children of the given branch onto this stack in reverse order.
  void pushReverseChildren(
    final BranchNode node,
  );
}
