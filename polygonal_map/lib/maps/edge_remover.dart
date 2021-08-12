import '../quadtree/handler_edge/impl.dart';
import '../quadtree/handler_edge/interface.dart';
import '../quadtree/node/edge/interface.dart';
import '../quadtree/point/impl.dart';
import '../quadtree/point/ops/equals.dart';
import '../quadtree/point/ops/side.dart';
import '../quadtree/quadtree/impl.dart';

/// Collect all edges inside the polygon.
class EdgeRemover implements QTEdgeHandler {
  final QuadTree _region;
  final Set<QTEdgeNode> remove;

  EdgeRemover(
    final this._region,
  ) : remove = <QTEdgeNode>{};

  @override
  bool handle(
    final QTEdgeNode edge,
  ) {
    final center = QTPointImpl(
      edge.x1 + edge.dx ~/ 2,
      edge.y1 + edge.dy ~/ 2,
    );
    if (pointEquals(edge.start, center) || pointEquals(edge.end, center)) {
      // Determine if the edge is inside.
      // If both points are not on the region edge then it is outside
      // because all inside points have been removed.
      final start = _region.findPoint(edge.start);
      if (start == null) {
        return true;
      }
      final end = _region.findPoint(edge.end);
      if (end == null) {
        return true;
      }
      // If edge is one of the region edges ignore it for now.
      if (start.findEdgeBetween(end) != null) {
        return true;
      }
      // Find nearest edge on region.
      final border = QTEdgeHandlerBorderNeighborImpl.Points(
        end,
        start,
        false,
        null,
      );
      // ignore: prefer_foreach
      for (final neighbor in start.startEdges) {
        border.handle(neighbor);
      }
      // ignore: prefer_foreach
      for (final neighbor in start.endEdges) {
        border.handle(neighbor);
      }
      final regionEdge = border.result;
      if (regionEdge != null) {
        if (regionEdge.endNode != start) {
          remove.add(edge);
        }
      }
    } else {
      final first = _region.firstLeftEdge(center);
      if (first != null) {
        if (side(first, center) == Side.Left) {
          remove.add(edge);
        }
      }
    }
    return true;
  }
}
