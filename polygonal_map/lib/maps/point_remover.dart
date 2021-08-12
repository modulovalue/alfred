import '../quadtree/handler_point/interface.dart';
import '../quadtree/node/point/interface.dart';
import '../quadtree/point/ops/side.dart';
import '../quadtree/quadtree/impl.dart';

/// Collect all points inside the polygon.
class PointRemover implements QTPointHandler {
  final QuadTree _region;
  final Set<PointNode> remove;

  PointRemover(
    final this._region,
  ) : remove = <PointNode>{};

  @override
  bool handle(
    final PointNode point,
  ) {
    final edge = _region.firstLeftEdge(point);
    if (edge != null) {
      if (side(edge, point) == Side.Left) {
        remove.add(point);
      }
    }
    return true;
  }
}
