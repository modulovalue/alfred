import '../../boundary/interface.dart';
import '../../edge/interface.dart';
import '../../first_left_edge_args/interface.dart';
import '../../handler_edge/interface.dart';
import '../../handler_node/interface.dart';
import '../../handler_point/interface.dart';
import '../../point/interface.dart';
import '../../point/ops/intersect.dart';
import '../edge/interface.dart';
import '../node/impl_empty.dart';
import '../node/interface.dart';
import '../point/interface.dart';
import 'mixin.dart';

/// The pass node is a leaf node which has
/// at least one line passing over the node.
class PassNode with QTNodeBoundaryMixin {
  /// The set of edges which pass through this node.
  final Set<QTEdgeNode> _passEdges;

  /// Creates the pass node.
  PassNode() : _passEdges = <QTEdgeNode>{};

  /// Gets the set of edges which pass through this node.
  Set<QTEdgeNode> get passEdges => _passEdges;

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  @override
  QTNode insertEdge(
    final QTEdgeNode edge,
  ) {
    if (overlapsEdge(edge)) {
      _passEdges.add(edge);
    }
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree
  @override
  QTNode insertPoint(
    final PointNode point,
  ) {
    point.setLocation(xmin, ymin, width);
    point.passEdges.addAll(_passEdges);
    return point;
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Return the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode removeEdge(
    final QTEdgeNode edge,
    final bool trimTree,
  ) {
    if (_passEdges.remove(edge)) {
      // If this node no longer has any edges replace this node with an
      // empty node.
      if (_passEdges.isEmpty) {
        return QTNodeEmptyImpl.instance;
      }
    }
    return this;
  }

  /// This handles the first found intersecting edge.
  @override
  IntersectionResult? findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
  ) {
    if (overlapsEdge(edge)) {
      return findFirstIntersection2(_passEdges, edge, hndl);
    } else {
      return null;
    }
  }

  /// This handles all the intersections.
  @override
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
    final IntersectionSet intersections,
  ) {
    if (overlapsEdge(edge)) {
      return findAllIntersections2(_passEdges, edge, hndl, intersections);
    } else {
      return false;
    }
  }

  /// Handles each point node reachable from this node in the boundary.
  @override
  bool foreachPoint(
    final QTPointHandler handle, [
    final QTBoundary? bounds,
  ]) =>
      true;

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  @override
  bool foreachEdge(
    final QTEdgeHandler<Object?> handle, [
    final QTBoundary? bounds,
    final bool exclusive = false,
  ]) {
    if (!exclusive) {
      if ((bounds == null) || overlapsBoundary(bounds)) {
        for (final edge in _passEdges) {
          if (!handle.handle(edge)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  @override
  bool foreachNode(
    final QTNodeHandler handle, [
    final QTBoundary? bounds,
  ]) {
    if (bounds != null) {
      return overlapsBoundary(bounds) && handle.handle(this);
    } else {
      return handle.handle(this);
    }
  }

  /// Determines if the node has any point nodes inside it. This node will
  /// never contain a point and will always return false.
  @override
  bool get hasPoints => false;

  /// Determines if the node has any edge nodes inside it. Since a pass node
  /// must have at least one edge in it this will always return true.
  @override
  bool get hasEdges => true;

  /// Gets the first edge to the left of the given point.
  @override
  void firstLeftEdge(
    final FirstLeftEdgeArgs args,
  ) =>
      firstLineLeft(_passEdges, args);

  /// Handles all the edges to the left of the given point.
  @override
  bool foreachLeftEdge(
    final QTPoint point,
    final QTEdgeHandler<Object?> handle,
  ) =>
      foreachLeftEdge2(_passEdges, point, handle);

  /// Validates this node.
  /// Set [recursive] to true to validate all children nodes too, false otherwise.
  @override
  bool validate(
    final StringBuffer sout,
    final bool recursive,
  ) {
    bool result = true;
    for (final edge in _passEdges) {
      if (!overlapsEdge(edge)) {
        sout.write("Error in ");
        sout.write(": An edge in the passing list, ");
        // edge.toBuffer(sout, format: format);
        sout.write(", doesn't pass through this node.\n");
        result = false;
      }
    }
    return result;
  }
}
