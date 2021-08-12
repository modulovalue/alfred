import '../quadtree/edge/impl.dart';
import '../quadtree/edge/interface.dart';
import '../quadtree/handler_edge/impl.dart';
import '../quadtree/handler_point/impl.dart';
import '../quadtree/node/edge/interface.dart';
import '../quadtree/node/point/interface.dart';
import '../quadtree/point/interface.dart';
import '../quadtree/quadtree/impl.dart';
import 'point_node_vector.dart';

/// Cuts a complicated polygon wrapped in any order into
/// CCW wrapped simpler set of polygons.
List<List<QTPoint>> polygonClip(
  final List<QTPoint> pnts,
) {
  final clipper = PolygonClipper._();
  clipper._setPolygon(pnts);
  clipper._getPolygons();
  return clipper._result;
}

/// A tool for clipping polygons into simpler set of polygons.
class PolygonClipper {
  final QuadTree _tree;
  final List<List<QTPoint>> _result;

  /// Create a polygon clipper.
  PolygonClipper._()
      : _tree = QuadTree(),
        _result = <List<QTPoint>>[];

  /// Sets the polygon to clip.
  void _setPolygon(
    final List<QTPoint> pnts,
  ) {
    final count = pnts.length;
    if (count >= 3) {
      // Insert all the end points into the tree.
      final nodes = PointNodeVector();
      for (int i = count - 1; i >= 0; --i) {
        final point = _insertPoint(pnts[i]);
        point.data = false;
        nodes.nodes.add(point);
      }
      // Insert edges ignoring any degenerate ones.
      for (int i = pnts.length - 1; i >= 0; --i) {
        _insertEdge(nodes.edge(i));
      }
    }
  }

  /// Gets all the polygons out of the quad-tree.
  void _getPolygons() => _tree.foreachEdge(QTEdgeHandlerAnonymousImpl(_tracePolygon));

  /// Trace out a polygon starting from the given edge.
  bool _tracePolygon(
    final QTEdgeNode _edge,
  ) {
    // If the data is true then this edge has already been handled so skip it.
    if ((_edge.data as bool?)!) {
      return true;
    } else {
      QTEdgeNode? edge = _edge;
      // Trace polygon and mark edges as handled,
      // continue until the point has been reached before.
      final pnts = PointNodeVector();
      final edges = <QTEdgeNode>[];
      while (edge != null) {
        edge.data = true;
        final startPnt = edge.startNode;
        startPnt.data = true;
        pnts.nodes.add(startPnt);
        edges.add(edge);
        final endPnt = edge.endNode;
        if (endPnt.data is bool) {
          _popoffPolygon(pnts, edges, endPnt);
          if (pnts.nodes.isEmpty) {
            return true;
          }
          edge = edges.last;
        }
        edge = edge.nextBorder(QTEdgeHandlerAnonymousImpl(_ignoreMarkedEdges));
      }
      return true;
    }
  }

  /// Removed the found polygon loop from the point stack.
  void _popoffPolygon(
    final PointNodeVector pnts,
    final List<QTEdgeNode> edges,
    final PointNode stopPnt,
  ) {
    // Read back to that point.
    for (int i = pnts.nodes.length - 1; i >= 0; --i) {
      final pnt = pnts.nodes[i];
      if (stopPnt == pnt) {
        // Cut off sub-polygon.
        final subpnts = PointNodeVector();
        subpnts.nodes.addAll(pnts.nodes.sublist(i));
        pnts.nodes.removeRange(i, pnts.nodes.length);
        edges.removeRange(i, edges.length);
        // Make sure the polygon has at least 3 points,
        // it is counter-clockwise, and has more than a very tiny area.
        if (subpnts.nodes.length >= 3) {
          final area = subpnts.area;
          const epsilon = 1.0e-12;
          if (area.area > epsilon) {
            if (!area.ccw) subpnts.reverse();
            _result.add(subpnts.nodes);
          }
        }
        return;
      }
      pnt.data = false;
    }
  }

  /// Ignores any edges which have been marked.
  bool _ignoreMarkedEdges(
    final QTEdge edge,
  ) =>
      !(edge.data as bool?)!;

  /// Inserts an edge into the tree and splits it for all instersections.
  void _insertEdge(
    final QTEdge edge,
  ) {
    if (!qtEdgeDegenerate(edge)) {
      // Split edge for all near close points.
      final point = _tree.findClosePoint(edge, QTPointHandlerEdgePointIgnorerImpl(edge));
      if (point != null) {
        _insertEdge(QTEdgeImpl(edge.start, point, null));
        _insertEdge(QTEdgeImpl(point, edge.end, null));
      } else {
        // Split edges which intersect.
        final result = _tree.findFirstIntersection(edge, QTEdgeHandlerNeighborIgnorerImpl(edge));
        if (result != null) {
          final point = _insertPoint(result.point!);
          _insertEdge(QTEdgeImpl(edge.start, point, null));
          _insertEdge(QTEdgeImpl(point, edge.end, null));
        } else {
          // Insert the edge.
          final node = _tree.insertEdge(edge);
          node!.data = false;
        }
      }
    }
  }

  /// Inserts a point into the tree and collapses all near lines towards it.
  PointNode _insertPoint(
    final QTPoint pnt,
  ) {
    final result = _tree.tryInsertPoint(pnt);
    if (result.existed) {
      return result.point;
    } else {
      // The point is new, check if any edges pass near it.
      final nearEdges = <QTEdgeNode>{};
      _tree.forCloseEdges(QTEdgeHandlerEdgeCollectorImpl(edgeSet: nearEdges), pnt);
      // Remove near edges, store the replacement edges.
      final liftedEdges = <QTEdgeImpl>{};
      for (final edge in nearEdges) {
        liftedEdges.add(QTEdgeImpl(edge.startNode, result.point, edge.data));
        liftedEdges.add(QTEdgeImpl(result.point, edge.endNode, edge.data));
        _tree.removeEdge(edge, false);
      }
      // Adjust all the near lines.
      final finalEdges = <QTEdgeImpl>{};
      while (liftedEdges.isNotEmpty) {
        final edge = liftedEdges.last;
        liftedEdges.remove(edge);
        final point = _tree.findClosePoint(edge, QTPointHandlerEdgePointIgnorerImpl(edge));
        if (point == null) {
          finalEdges.add(edge);
        } else {
          liftedEdges.add(QTEdgeImpl(edge.start, point, edge.data));
          liftedEdges.add(QTEdgeImpl(point, edge.end, edge.data));
        }
      }
      // Push the adjusted lines to the tree.
      for (final edge in finalEdges) {
        final node = _tree.insertEdge(edge)!;
        node.data = edge.data;
      }
      return result.point;
    }
  }
}
