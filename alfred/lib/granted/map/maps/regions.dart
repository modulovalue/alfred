import '../quadtree/edge/impl.dart';
import '../quadtree/edge/interface.dart';
import '../quadtree/handler_edge/impl.dart';
import '../quadtree/handler_point/impl.dart';
import '../quadtree/node/edge/interface.dart';
import '../quadtree/node/point/interface.dart';
import '../quadtree/point/impl.dart';
import '../quadtree/point/interface.dart';
import '../quadtree/point/ops/side.dart';
import '../quadtree/quadtree/impl.dart';
import 'polygon_clipper.dart';

/// A map of regions.
/// Useful for defining country, state, and zone maps,
/// topographical  maps, or other distinct bounded area maps.
class Regions {
  /// The tree storing the regions.
  final QuadTree tree;

  /// Creates a new region map.
  Regions() : tree = QuadTree();

  /// Determines the region that the point is inside of.
  int getRegion(
    final QTPoint pnt,
  ) {
    final node = tree.firstLeftEdge(pnt);
    if (node == null) {
      return 0;
    } else {
      final sideData = (node.data as EdgeSide?)!;
      if (side(node, pnt) == Side.Left) {
        return sideData.left;
      } else {
        return sideData.right;
      }
    }
  }

  /// Adds a region into the map.
  /// Note: The region will overwrite any region contained in it.
  /// The given [pntCoords] are the x and y pairs for the points of the
  /// simple polygon for the region.
  void addRegionWithCoords(
    final int regionId,
    final List<int> pntCoords,
  ) {
    final count = pntCoords.length ~/ 2;
    addRegion(
      regionId,
      List.generate(
        count,
        (final i) => QTPointImpl(pntCoords[i * 2], pntCoords[i * 2 + 1]),
      ),
    );
  }

  /// Adds a region into the map.
  /// Note: The region will overwrite any region contained in it.
  void addRegion(
    final int regionId,
    final List<QTPoint> pnts,
  ) {
    final polys = polygonClip(pnts);
    for (final poly in polys) {
      _addRegion(regionId, poly);
    }
  }

  /// Adds a clipped region into the map.
  void _addRegion(
    final int regionId,
    final List<QTPoint> pnts,
  ) {
    int count = pnts.length;
    // Insert all the end points into the tree.
    final nodes = PointNodeVector();
    for (int i = 0; i < count; ++i) {
      final point = _insertPoint(pnts[i]);
      nodes.nodes.add(point);
    }
    // Find all near points to the new edges.
    for (int i = 0; i < count; ++i) {
      final edge = nodes.edge(i);
      final point = tree.findClosePoint(edge, QTPointHandlerEdgePointIgnorerImpl(edge));
      if (point != null) {
        nodes.nodes.insert(i + 1, point);
        ++count;
        --i;
      }
    }
    // Find all edge intersections.
    for (int i = 0; i < count; ++i) {
      final edge = nodes.edge(i);
      final result = tree.findFirstIntersection(edge, QTEdgeHandlerNeighborIgnorerImpl(edge));
      if (result != null) {
        final point = _insertPoint(result.point!);
        nodes.nodes.insert(i + 1, point);
        ++count;
        --i;
      }
    }
    // Remove any contained data.
    // Create a tree which contains the input so it can be queried.
    final newRegion = QuadTree();
    for (int i = 0; i < count; ++i) {
      newRegion.insertEdge(nodes.edge(i), null);
    }
    _removeContainedPoints(newRegion);
    _removeContainedEdges(newRegion);
    // Insert the edges of the boundary while checking the outside boundary region value.
    final removeEdge = <QTEdgeNode>[];
    for (int i = 0; i < count; ++i) {
      final edge = nodes.edge(i);
      final start = edge.start as PointNode;
      final end = edge.end as PointNode;
      var last = start.findEdgeTo(end);
      if (last != null) {
        final sideData = (last.data as EdgeSide?)!;
        sideData.left = regionId;
        if (sideData.right == regionId) {
          removeEdge.add(last);
        }
      } else {
        last = end.findEdgeTo(start);
        if (last != null) {
          final sideData = (last.data as EdgeSide?)!;
          sideData.right = regionId;
          if (sideData.left == regionId) {
            removeEdge.add(last);
          }
        } else {
          final outterRangeId = _getSide(start, end);
          if (outterRangeId != regionId) {
            final e = tree.insertEdge(edge, null);
            e!.data = EdgeSide(regionId, outterRangeId);
          }
        }
      }
    }
    // Remove any edge which ends up with the same data on both sides.
    for (final edge in removeEdge) {
      tree.removeEdge(edge, false);
    }
    // Find any remaining points which have been orphaned.
    for (int i = 0; i < count; ++i) {
      final point = tree.findPoint(nodes.nodes[i]);
      if ((point != null) && point.orphan) {
        tree.removePoint(point);
      }
    }
  }

  /// Removes the points (and edges connected to those points)
  /// contained within the given region.
  void _removeContainedPoints(
    final QuadTree newRegion,
  ) {
    final pntRemover = QTPointHandlerPointRemoverImpl(newRegion);
    tree.foreachPoint(pntRemover, newRegion.boundary);
    // Remove all the inner edges and points.
    // ignore: prefer_foreach
    for (final node in pntRemover.remove) {
      tree.removePoint(node);
    }
  }

  /// Removes all edges contained in the region.
  void _removeContainedEdges(
    final QuadTree newRegion,
  ) {
    final edgeRemover = QTEdgeHandlerEdgeRemoverImpl(newRegion);
    tree.foreachEdge(edgeRemover, newRegion.boundary, true);
    // Remove all the inner edges and points.
    for (final node in edgeRemover.remove) {
      tree.removeEdge(node, true);
    }
  }

  /// Gets the right side value for the given edge.
  /// The given [start] is the start point of the edge to get the side for.
  /// The given [end] is the end point of the edge to get the side for.
  int _getSide(
    final PointNode start,
    final PointNode end,
  ) {
    QTEdgeHandlerBorderNeighborImpl border = QTEdgeHandlerBorderNeighborImpl.Points(start, end, true);
    // ignore: prefer_foreach
    for (final neighbor in end.startEdges) {
      border.handle(neighbor);
    }
    // ignore: prefer_foreach
    for (final neighbor in end.endEdges) {
      border.handle(neighbor);
    }
    final next = border.result;
    if (next != null) {
      final sideData = (next.data as EdgeSide?)!;
      if (next.startNode == end) {
        return sideData.right;
      } else {
        return sideData.left;
      }
    }
    border = QTEdgeHandlerBorderNeighborImpl.Points(end, start, false);
    // ignore: prefer_foreach
    for (final neighbor in start.startEdges) {
      border.handle(neighbor);
    }
    // ignore: prefer_foreach
    for (final neighbor in start.endEdges) {
      border.handle(neighbor);
    }
    final previous = border.result;
    if (previous != null) {
      final sideData = (previous.data as EdgeSide?)!;
      if (previous.endNode == start) {
        return sideData.right;
      } else {
        return sideData.left;
      }
    }
    var edge = tree.firstLeftEdge(start);
    while (edge != null) {
      final sideData = (edge.data as EdgeSide?)!;
      final _side = side(edge, start);
      if (_side == Side.Right) {
        return sideData.right;
      }
      if (_side == Side.Left) {
        return sideData.left;
      }
      edge = edge.nextBorder();
    }
    return 0;
  }

  /// Inserts a point into the tree and collapses all near lines towards it.
  PointNode _insertPoint(
    final QTPoint pnt,
  ) {
    final result = tree.tryInsertPoint(pnt);
    if (result.existed) {
      return result.point;
    } else {
      // The point is new, check if any edges pass near it.
      final nearEdges = <QTEdgeNode>{};
      tree.forCloseEdges(QTEdgeHandlerEdgeCollectorImpl(edgeSet: nearEdges), pnt);
      // Remove near edges, store the replacement edges.
      final liftedEdges = <QTEdgeImpl>{};
      for (final edge in nearEdges) {
        liftedEdges.add(QTEdgeImpl(edge.startNode, result.point, edge.data));
        liftedEdges.add(QTEdgeImpl(result.point, edge.endNode, edge.data));
        tree.removeEdge(edge, false);
      }
      // Adjust all the near lines.
      final pushEdges = <QTEdgeImpl>{};
      while (liftedEdges.isNotEmpty) {
        final edge = liftedEdges.last;
        liftedEdges.remove(edge);
        final point = tree.findClosePoint(edge, QTPointHandlerEdgePointIgnorerImpl(edge));
        if (point == null) {
          pushEdges.add(edge);
        } else {
          liftedEdges.add(QTEdgeImpl(edge.start, point, edge.data));
          liftedEdges.add(QTEdgeImpl(point, edge.end, edge.data));
        }
      }
      // Reduce all edges which are coincident.
      final finalEdges = <QTEdgeImpl>{};
      while (pushEdges.isNotEmpty) {
        final edge = pushEdges.last;
        pushEdges.remove(edge);
        _reduceEdge(pushEdges, finalEdges, edge);
      }
      // Push the adjusted lines to the tree.
      for (final edge in finalEdges) {
        final node = tree.insertEdge(edge, null)!;
        node.data = copyEdgeSide(
          (edge.data as EdgeSide?)!,
        );
      }
      return result.point;
    }
  }

  /// Reduces a set of edges to the minimum required edges.
  /// The [pushEdges] are the edges to reduce.
  /// The [finalEdges] are the minimum required edges.
  /// The [edge] is the edge to reduce towards.
  void _reduceEdge(
    final Set<QTEdge> pushEdges,
    final Set<QTEdge> finalEdges,
    final QTEdge edge,
  ) {
    final lefts = <int>[];
    final rights = <int>[];
    var sideData = (edge.data as EdgeSide?)!;
    lefts.add(sideData.left);
    rights.add(sideData.right);
    // Check the tree for an existing line.
    final start = edge.start as PointNode;
    QTEdge? treeEdge = start.findEdgeTo(edge.end);
    if (treeEdge != null) {
      sideData = (treeEdge.data as EdgeSide?)!;
      lefts.add(sideData.left);
      rights.add(sideData.right);
    } else {
      treeEdge = start.findEdgeFrom(edge.end);
      if (treeEdge != null) {
        sideData = (treeEdge.data as EdgeSide?)!;
        lefts.add(sideData.right);
        rights.add(sideData.left);
      }
    }
    // Check for all other coincident edges.
    final it = pushEdges.iterator;
    final removeEdge = <QTEdge>[];
    while (it.moveNext()) {
      final edge2 = it.current;
      sideData = (edge2.data as EdgeSide?)!;
      if (qtEdgeEquals(edge, edge2, false)) {
        lefts.add(sideData.left);
        rights.add(sideData.right);
        removeEdge.add(edge2);
      } else if (qtEdgeOpposites(edge, edge2)) {
        lefts.add(sideData.right);
        rights.add(sideData.left);
        removeEdge.add(edge2);
      }
    }
    pushEdges.removeAll(removeEdge);
    // Reduce all edges side values.
    for (int i = lefts.length - 1; i >= 0; --i) {
      for (int j = rights.length - 1; j >= 0; --j) {
        if (lefts[i] == rights[j]) {
          lefts.removeAt(i);
          rights.removeAt(j);
          break;
        }
      }
    }
    // Create final edge.
    if (!(lefts.isEmpty || rights.isEmpty)) {
      edge.data = EdgeSide(lefts[0], rights[0]);
      finalEdges.add(edge);
    }
  }
}

/// Creates a copy of the [other] edge side data.
EdgeSide copyEdgeSide(
  final EdgeSide other,
) =>
    EdgeSide(
      other.left,
      other.right,
    );

/// The data for the edges in the region map.
/// The data defining identifier for the regions to the left and right of the edge
/// looking from the start point of the edge down to the end point.
class EdgeSide {
  /// The identifier of the region data to the left of the edge.
  int left;

  /// The identifier of the region data to the right of the edge.
  int right;

  /// Creates an edge side data.
  /// This specifies the identifiers of the region data to the [left] and [right] of the edge.
  EdgeSide(
    final this.left,
    final this.right,
  );

  /// A simple string displaying the data.
  @override
  String toString() => "[" + left.toString() + "|" + right.toString() + "]";
}
