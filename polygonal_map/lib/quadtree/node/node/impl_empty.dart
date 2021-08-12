import '../../boundary/impl.dart';
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
import '../boundary/impl_pass.dart';
import '../edge/interface.dart';
import '../point/interface.dart';
import 'interface.dart';

/// The empty node represents a node which has no data, no points nor edges.
/// It is a leaf in all locations that have no information in the tree.
class QTNodeEmptyImpl implements QTNode {
  /// The singleton instance of the empty node.
  static QTNodeEmptyImpl? _singleton;

  /// This gets the single instance of the empty node.
  static QTNodeEmptyImpl get instance => _singleton ??= QTNodeEmptyImpl._();

  /// Creates a new empty node.
  QTNodeEmptyImpl._();

  /// Adds a point to this location in the tree.
  QTNode addPoint(int xmin, int ymin, int size, PointNode point) {
    point.setLocation(xmin, ymin, size);
    return point;
  }

  /// Adds an edge to this location in the tree.
  QTNode addEdge(
    final int xmin,
    final int ymin,
    final int size,
    final QTEdgeNode edge,
  ) {
    final boundary = QTBoundaryImpl(
      xmin,
      ymin,
      xmin + size - 1,
      ymin + size - 1,
    );
    if (boundary.overlapsEdge(edge)) {
      final node = PassNode();
      node.setLocation(xmin, ymin, size);
      node.passEdges.add(edge);
      return node;
    } else {
      return this;
    }
  }

  /// Handles each point node reachable from this node.
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
    final QTEdgeHandler handle, [
    final QTBoundary? bounds,
    final bool exclusive = false,
  ]) =>
      true;

  /// Handles each node reachable from this node.
  @override
  bool foreachNode(
    final QTNodeHandler handle, [
    final QTBoundary? bounds,
  ]) =>
      true;

  /// Determines if the node has any point nodes inside it.
  @override
  bool get hasPoints => false;

  /// Determines if the node has any edge nodes inside it.
  @override
  bool get hasEdges => false;

  /// Gets the first edge to the left of the given point.
  @override
  void firstLeftEdge(
    final FirstLeftEdgeArgs args,
  ) {}

  /// Handles all the edges to the left of the given point.
  @override
  bool foreachLeftEdge(
    final QTPoint pnt,
    final QTEdgeHandler hndl,
  ) =>
      true;

  /// This handles the first found intersecting edge.
  @override
  Null findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler? hndl,
  ) =>
      null;

  /// This handles all the intersections.
  @override
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler? hndl,
    final IntersectionSet intersections,
  ) =>
      false;

  /// Validates this node.
  @override
  bool validate(
    final StringBuffer sout,
    final QTFormatter? format,
    final bool recursive,
  ) =>
      true;

  /// Formats the nodes into a string.
  /// [children] indicates any child should also be stringified.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  @override
  void toBuffer(
    final StringBuffer sout, {
    final String indent = "",
    final bool children = false,
    final bool contained = false,
    final bool last = true,
    final QTFormatter? format,
  }) {
    if (contained) {
      if (last) {
        sout.write(StringParts.Last);
      } else {
        sout.write(StringParts.Child);
      }
    }
    sout.write("EmptyNode");
  }

  /// Gets the string for this node.
  @override
  String toString() {
    final sout = StringBuffer();
    toBuffer(sout);
    return sout.toString();
  }
}
