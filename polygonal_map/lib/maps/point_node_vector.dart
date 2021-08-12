import '../quadtree/boundary/impl.dart';
import '../quadtree/edge/impl.dart';
import '../quadtree/handler_edge/impl.dart';
import '../quadtree/node/point/interface.dart';

/// A vector of point nodes which can represent
/// a polygon, poly-line, or point stack.
class PointNodeVector {
  /// The list of nodes in this vector.
  final List<PointNode> _list;

  /// Creates a new point node vector.
  PointNodeVector() : _list = <PointNode>[];

  /// Gets the internal list of nodes.
  List<PointNode> get nodes => _list;

  /// Gets the edge between the point at the given index and the next index.
  QTEdgeImpl edge(
    final int index,
  ) {
    final startNode = _list[index];
    final endNode = _list[(index + 1) % _list.length];
    return QTEdgeImpl(startNode, endNode, null);
  }

  /// Reverses the location of all the points in the vector.
  void reverse() {
    for (int i = 0, j = _list.length - 1; i < j; ++i, --j) {
      final temp = _list[i];
      _list[i] = _list[j];
      _list[j] = temp;
    }
  }

  /// Calculates the area of the polygon in the vector.
  QTEdgeHandlerAreaAccumulatorImpl get area {
    final area = QTEdgeHandlerAreaAccumulatorImpl();
    PointNode endNode = _list[0];
    for (int i = _list.length - 1; i >= 0; --i) {
      final startNode = _list[i];
      area.handle(
        QTEdgeImpl(
          startNode,
          endNode,
          null,
        ),
      );
      endNode = startNode;
    }
    return area;
  }

  /// Calculates the boundary of all the points in the vertex.
  QTBoundaryImpl? get bounds {
    QTBoundaryImpl? bounds;
    for (int i = _list.length - 1; i >= 0; --i) {
      bounds = boundaryExpand(bounds, _list[i]);
    }
    return bounds;
  }

  /// Converts the vertex into a set.
  Set<PointNode> toSet() {
    final newSet = <PointNode>{};
    for (int i = _list.length - 1; i >= 0; --i) {
      newSet.add(_list[i]);
    }
    return newSet;
  }
}
