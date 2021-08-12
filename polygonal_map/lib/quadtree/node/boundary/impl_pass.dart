import '../../boundary/interface.dart';
import '../../edge/interface.dart';
import '../../first_left_edge_args/interface.dart';
import '../../formatter/interface.dart';
import '../../formatter/string_parts.dart';
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
    if (overlapsEdge(edge)) _passEdges.add(edge);
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree
  @override
  QTNode insertPoint(PointNode point) {
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
  QTNode removeEdge(QTEdgeNode edge, bool trimTree) {
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
    final QTEdgeHandler? hndl,
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
    final QTEdgeHandler? hndl,
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
  bool foreachPoint(QTPointHandler handle, [QTBoundary? bounds]) => true;

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  @override
  bool foreachEdge(QTEdgeHandler handle, [QTBoundary? bounds, bool exclusive = false]) {
    if (!exclusive) {
      if ((bounds == null) || overlapsBoundary(bounds)) {
        for (final edge in _passEdges) {
          if (!handle.handle(edge)) return false;
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  @override
  bool foreachNode(QTNodeHandler handle, [QTBoundary? bounds]) {
    if (bounds != null) return overlapsBoundary(bounds) && handle.handle(this);
    return handle.handle(this);
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
  void firstLeftEdge(FirstLeftEdgeArgs args) => firstLineLeft(_passEdges, args);

  /// Handles all the edges to the left of the given point.
  @override
  bool foreachLeftEdge(QTPoint point, QTEdgeHandler handle) => foreachLeftEdge2(_passEdges, point, handle);

  /// Validates this node.
  /// Set [recursive] to true to validate all children nodes too, false otherwise.
  @override
  bool validate(StringBuffer sout, QTFormatter? format, bool recursive) {
    bool result = true;
    for (final edge in _passEdges) {
      if (!overlapsEdge(edge)) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": An edge in the passing list, ");
        // edge.toBuffer(sout, format: format);
        sout.write(", doesn't pass through this node.\n");
        result = false;
      }
    }
    return result;
  }

  /// Formats the nodes into a string.
  /// [children] indicates any child should also be stringified.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  @override
  void toBuffer(
    StringBuffer sout, {
    String indent = "",
    bool children = false,
    bool contained = false,
    bool last = true,
    QTFormatter? format,
  }) {
    if (contained) {
      if (last) {
        sout.write(StringParts.Last);
      } else {
        sout.write(StringParts.Child);
      }
    }
    sout.write("PassNode: ");
    if (format == null) {
      sout.write(boundary.toString());
    } else {
      sout.write(format.toBoundaryString(boundary));
    }
    if (children) {
      if (_passEdges.isNotEmpty) {
        sout.write(StringParts.Sep);
        sout.write(indent);
      }
      String childIndent;
      if (contained && !last) {
        childIndent = indent + StringParts.Bar;
      } else {
        childIndent = indent + StringParts.Space;
      }
      edgeNodesToBuffer(_passEdges, sout, indent: childIndent, contained: true, last: true, format: format);
    }
  }
}

/// Formats the edges into a string.
/// [contained] indicates this output is part of another part.
/// [last] indicate this is the last set in a list of parents.
void edgeNodesToBuffer(
  final Set<QTEdge> nodes,
  final StringBuffer sout, {
  final String indent = "",
  final bool contained = false,
  final bool last = true,
  final QTFormatter? format,
}) {
  // final int count = nodes.length;
  // int index = 0;
  // for (final edge in nodes) {
  //   if (index > 0) {
  //     sout.write(StringParts.Sep);
  //     sout.write(indent);
  //   }
  //   index++;
  //   /// TODO fix
  //   // edge.toBuffer(sout, indent: indent, contained: contained, last: last && (index >= count), format: format);
  // }
}
