import '../../basic/first_left_edge_args.dart';
import '../../basic/qt_edge.dart';
import '../../basic/qt_edge_handler.dart';
import '../../basic/qt_node_handler.dart';
import '../../basic/qt_point_handler.dart';
import '../../boundary.dart';
import '../../point/ops/intersect.dart';
import '../../point/qt_point.dart';
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
  QTNode addPoint(
    final int xmin,
    final int ymin,
    final int size,
    final PointNode point,
  ) {
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
    final boundary = QTBoundaryImpl.make(
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
    final QTEdgeHandler<Object?> handle, [
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
    final QTEdgeHandler<Object?> hndl,
  ) =>
      true;

  /// This handles the first found intersecting edge.
  @override
  Null findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
  ) =>
      null;

  /// This handles all the intersections.
  @override
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler<Object?>? hndl,
    final IntersectionSet intersections,
  ) =>
      false;

  /// Validates this node.
  @override
  bool validate(
    final StringBuffer sout,
    final bool recursive,
  ) =>
      true;
}
