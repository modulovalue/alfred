import '../../boundary/interface.dart';
import '../../node/branch/interface.dart';
import '../../node/node/interface.dart';
import '../../node/point/interface.dart';
import '../edge/interface.dart';

abstract class QTNodeBoundary implements QTNode, QTBoundary {
  /// The parent of this node.
  abstract BranchNode? parent;

  /// Determines the root of this tree.
  QTNodeBoundary? get root;

  /// Determines the depth of this node in the tree.
  /// Returns the depth of this node in the tree,
  /// if it has no parents then the depth is zero.
  int get depth;

  /// Determines the common ancestor node between this node and the other node.
  /// Returns the common ancestor or null if none exists.
  QTNodeBoundary? commonAncestor(
    final QTNodeBoundary other,
  );

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  QTNode insertEdge(
    final QTEdgeNode edge,
  );

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  QTNode insertPoint(
    final PointNode point,
  );

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  QTNode removeEdge(
    final QTEdgeNode edge,
    final bool trimTree,
  );

  /// Gets creates a boundary for this node.
  QTBoundary get boundary;

  /// Sets the location of this node.
  void setLocation(
    final int xmin,
    final int ymin,
    final int size,
  );
}
