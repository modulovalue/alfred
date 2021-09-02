import '../../edge/impl.dart';
import '../../edge/interface.dart';
import '../../handler_edge/interface.dart';
import '../../point/interface.dart';
import '../point/interface.dart';

/// The edge node is a connection in the quad-tree
/// between two point nodes. It represents a two
/// dimensional directed line segment.
// TODO remove bound.
abstract class QTEdgeNode<T extends Object?> implements QTEdge<T> {
  /// Gets the start point node for the edge.
  PointNode get startNode;

  /// Gets the end point node for the edge.
  PointNode get endNode;

  /// Gets the edge for this edge node.
  QTEdgeImpl get edge;

  /// Gets the point for the given node.
  /// Set [start] t0 true to return the start point,
  /// false to return the end point.
  QTPoint point(
    final bool start,
  );

  /// Gets the point node for the given point.
  /// Set [start] to true to return the start node,
  /// false to return the end node.
  PointNode node(
    final bool start,
  );

  /// Determines if this edge is connected to the given node.
  /// [point] is the node to determine if it is either the start
  /// or end node of this edge.
  /// Returns true if the given node was either the start
  /// or end node of this edge, false if not or the node was null.
  bool connectsToPoint(
    final PointNode point,
  );

  /// Determines if this edge is connected to the given edge. To be connected
  /// either the start node or end node of this edge must be the same node as
  /// either the start node or end node of the given edge.
  /// [edge] is the edge to determine if it shares a node with this edge.
  /// Returns true if the given edge shared a node with this edge,
  /// false if not or the edge was null.
  bool connectsToEdge(
    final QTEdgeNode? edge,
  );

  /// This gets the edge set of neighbor edges to this edge.
  // Set [next] to true to return the start edges from the end node,
  /// false to return the end edges from the start node..
  /// Returns the edge set of neighbors to this edge.
  Set<QTEdge> neighborEdges(
    final bool next,
  );

  /// This will attempt to find an edge which ends where this one starts and
  /// starts where this one ends, coincident and opposite.
  QTEdge? findOpposite();

  /// Determines the next neighbor edge on a properly wound polygon.
  QTEdgeNode? nextBorder([
    final QTEdgeHandler<Object?>? matcher,
  ]);

  /// Determines the previous neighbor edge on a properly wound polygon.
  QTEdge? previousBorder([
    final QTEdgeHandler<Object?>? matcher,
  ]);

  /// Validates this node and all children nodes.
  bool validate(
    final StringBuffer sout,
  );

  /// Compares the given line with this line.
  /// Returns 1 if this line is greater than the other line,
  /// -1 if this line is less than the other line,
  /// 0 if this line is the same as the other line.
  int compareTo(
    final QTEdgeNode other,
  );
}
