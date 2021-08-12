import '../../edge/impl.dart';
import '../../edge/interface.dart';
import '../../formatter/interface.dart';
import '../../formatter/string_parts.dart';
import '../../handler_edge/impl.dart';
import '../../handler_edge/interface.dart';
import '../../point/interface.dart';
import '../point/interface.dart';
import 'interface.dart';

/// The edge node is a connection in the quad-tree
/// between two point nodes. It represents a two
/// dimensional directed line segment.
class QTEdgeNodeImpl implements QTEdgeNode<Object?> {
  @override
  final PointNode startNode;

  @override
  final PointNode endNode;

  @override
  Object? data;

  /// Creates a new edge node.
  QTEdgeNodeImpl(
    final this.startNode,
    final this.endNode,
    final this.data,
  ) :
        // May not initialize an edge node with the
        // same node for both the start and end.
        // ignore: prefer_asserts_with_message
        assert(startNode != endNode);

  @override
  QTEdgeImpl get edge => QTEdgeImpl(startNode, endNode, null,);

  @override
  QTPoint point(
    final bool start,
  ) {
    if (start) {
      return startNode.point;
    } else {
      return endNode.point;
    }
  }

  @override
  PointNode node(
    final bool start,
  ) {
    if (start) {
      return startNode;
    } else {
      return endNode;
    }
  }

  @override
  bool connectsToPoint(
    final PointNode point,
  ) =>
      (startNode == point) || (endNode == point);

  @override
  bool connectsToEdge(
    final QTEdgeNode? edge,
  ) =>
      (edge != null) &&
      ((startNode == edge.end) || (endNode == edge.start) || (startNode == edge.start) || (endNode == edge.end));

  /// This gets the edge set of neighbor edges to this edge.
  // Set [next] to true to return the start edges from the end node,
  /// false to return the end edges from the start node..
  /// Returns the edge set of neighbors to this edge.
  @override
  Set<QTEdge> neighborEdges(
    final bool next,
  ) {
    if (next) {
      return endNode.startEdges;
    } else {
      return startNode.endEdges;
    }
  }

  /// This will attempt to find an edge which ends where this one starts and
  /// starts where this one ends, coincident and opposite.
  @override
  QTEdge? findOpposite() => endNode.findEdgeTo(startNode);

  /// Gets the first component of the start point of the edge.
  @override
  int get x1 => startNode.x;

  /// Gets the second component of the start point of the edge.
  @override
  int get y1 => startNode.y;

  /// Gets the first component of the end point of the edge.
  @override
  int get x2 => endNode.x;

  /// Gets the second component of the end point of the edge.
  @override
  int get y2 => endNode.y;

  /// Gets the start point for this edge.
  @override
  QTPoint get start => startNode;

  /// Gets the end point for this edge.
  @override
  QTPoint get end => endNode;

  /// Gets the change in the first component, delta X.
  @override
  int get dx => endNode.x - startNode.x;

  /// Gets the change in the second component, delta Y.
  @override
  int get dy => endNode.y - startNode.y;

  /// Determines the next neighbor edge on a properly wound polygon.
  @override
  QTEdgeNode? nextBorder([
    final QTEdgeHandler? matcher,
  ]) {
    final border = QTEdgeHandlerBorderNeighborImpl(
      this,
      true,
      matcher,
    );
    // ignore: prefer_foreach
    for (final neighbor in endNode.startEdges) {
      border.handle(neighbor);
    }
    return border.result;
  }

  /// Determines the previous neighbor edge on a properly wound polygon.
  @override
  QTEdge? previousBorder([
    final QTEdgeHandler? matcher,
  ]) {
    final border = QTEdgeHandlerBorderNeighborImpl.Points(
      endNode,
      startNode,
      false,
      matcher,
    );
    // ignore: prefer_foreach
    for (final neighbor in startNode.endEdges) {
      border.handle(neighbor);
    }
    return border.result;
  }

  /// Validates this node and all children nodes.
  @override
  bool validate(
    final StringBuffer sout,
    final QTFormatter? format,
  ) {
    bool result = true;
    if (startNode.commonAncestor(endNode) == null) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(": The nodes don't have a common ancestor.\n");
      result = false;
    }
    if (!startNode.startEdges.contains(this)) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(":  The start node, ");
      sout.write(startNode);
      sout.write(", doesn't have this edge in it's starting list.\n");
      result = false;
    }
    if (!endNode.endEdges.contains(this)) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(":  The end node, ");
      sout.write(endNode);
      sout.write(", doesn't have this edge in it's ending list.\n");
      result = false;
    }
    return result;
  }

  /// Compares the given line with this line.
  /// Returns 1 if this line is greater than the other line,
  /// -1 if this line is less than the other line,
  /// 0 if this line is the same as the other line.
  @override
  int compareTo(
    final QTEdgeNode other,
  ) {
    final cmp = startNode.compareTo(other.startNode);
    if (cmp != 0) return cmp;
    return endNode.compareTo(other.endNode);
  }

  /// Formats the nodes into a string.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  @override
  void toBuffer(
    final StringBuffer sout, {
    final String indent = "",
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
    sout.write("EdgeNode: ");
    if (format == null) {
      sout.write(edge.toString());
    } else {
      sout.write(format.toEdgeString(edge));
    }
    if (data != null) {
      sout.write(" ");
      sout.write(data.toString());
    }
  }

  /// Gets the string for this edge node.
  @override
  String toString() {
    final sout = StringBuffer();
    toBuffer(sout);
    return sout.toString();
  }
}
