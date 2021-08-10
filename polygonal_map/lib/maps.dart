// @dart = 2.9
import 'quadtree/edge/edge.dart';
import 'quadtree/edge/edge_impl.dart';
import 'quadtree/point/ops/intersect.dart';
import 'quadtree/point/ops/side.dart';
import 'quadtree/point/point.dart';
import 'quadtree/point/point_impl.dart';
import 'quadtree/quadtree.dart';
import 'quadtree/quadtree_impl.dart';

/// The data for the edges in the region map.
/// The data defining identifier for the regions to the left and right of the edge
/// looking from the start point of the edge down to the end point.
class EdgeSide extends Object {
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

  /// Creates a copy of the [other] edge side data.
  factory EdgeSide.copy(
    final EdgeSide other,
  ) =>
      EdgeSide(
        other.left,
        other.right,
      );

  /// A simple string displaying the data.
  @override
  String toString() => "[$left|$right]";
}

/// A tool for clipping polygons into simpler set of polygons.
class PolygonClipper {
  /// Cuts a complicated polygon wrapped in any order into
  /// CCW wrapped simpler set of polygons.
  static List<List<QTPoint>> Clip(List<QTPoint> pnts) {
    final PolygonClipper clipper = PolygonClipper._();
    clipper._setPolygon(pnts);
    clipper._getPolygons();
    return clipper._result;
  }

  final QuadTree _tree;
  final List<List<QTPoint>> _result;

  /// Create a polygon clipper.
  PolygonClipper._()
      : _tree = QuadTree(),
        _result = <List<QTPoint>>[];

  /// Sets the polygon to clip.
  void _setPolygon(List<QTPoint> pnts) {
    final int count = pnts.length;
    if (count < 3) return;
    // Insert all the end points into the tree.
    final PointNodeVector nodes = PointNodeVector();
    for (int i = count - 1; i >= 0; --i) {
      final PointNode point = _insertPoint(pnts[i]);
      point.data = false;
      // ignore: prefer_asserts_with_message
      assert(point != null);
      nodes.nodes.add(point);
    }
    // Insert edges ignoring any degenerate ones.
    for (int i = pnts.length - 1; i >= 0; --i) {
      _insertEdge(nodes.edge(i));
    }
  }

  /// Gets all the polygons out of the quad-tree.
  void _getPolygons() {
    _tree.foreachEdge(QTEdgeHandlerAnonymousImpl(_tracePolygon));
  }

  /// Trace out a polygon starting from the given edge.
  bool _tracePolygon(QTEdge e) {
    QTEdgeNodeImpl edge = e as QTEdgeNodeImpl;
    // If the data is true then this edge has already been handled so skip it.
    if (edge.data as bool) return true;
    // Trace polygon and mark edges as handled,
    // continue until the point has been reached before.
    final PointNodeVector pnts = PointNodeVector();
    final List<QTEdgeNodeImpl> edges = <QTEdgeNodeImpl>[];
    while (edge != null) {
      edge.data = true;
      final PointNode startPnt = edge.startNode;
      startPnt.data = true;
      pnts.nodes.add(startPnt);
      edges.add(edge);
      final PointNode endPnt = edge.endNode;
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

  /// Removed the found polygon loop from the point stack.
  void _popoffPolygon(PointNodeVector pnts, List<QTEdgeNodeImpl> edges, PointNode stopPnt) {
    // Read back to that point.
    for (int i = pnts.nodes.length - 1; i >= 0; --i) {
      final PointNode pnt = pnts.nodes[i];
      if (stopPnt == pnt) {
        // Cut off sub-polygon.
        final PointNodeVector subpnts = PointNodeVector();
        subpnts.nodes.addAll(pnts.nodes.sublist(i));
        pnts.nodes.removeRange(i, pnts.nodes.length);
        edges.removeRange(i, edges.length);
        // Make sure the polygon has at least 3 points,
        // it is counter-clockwise, and has more than a very tiny area.
        if (subpnts.nodes.length >= 3) {
          final QTEdgeHandlerAreaAccumulatorImpl area = subpnts.area;
          const double epsilon = 1.0e-12;
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
  bool _ignoreMarkedEdges(QTEdge edge) => !(edge.data as bool);

  /// Inserts an edge into the tree and splits it for all instersections.
  void _insertEdge(QTEdge edge) {
    if (QTEdgeImpl.degenerate(edge)) return;
    // Split edge for all near close points.
    final PointNode point = _tree.findClosePoint(edge, QTPointHandlerEdgePointIgnorerImpl(edge));
    if (point != null) {
      _insertEdge(QTEdgeImpl(edge.start, point));
      _insertEdge(QTEdgeImpl(point, edge.end));
      return;
    }
    // Split edges which intersect.
    final IntersectionResult result = _tree.findFirstIntersection(edge, QTEdgeHandlerNeighborIgnorerImpl(edge));
    if (result != null) {
      final PointNode point = _insertPoint(result.point);
      _insertEdge(QTEdgeImpl(edge.start, point));
      _insertEdge(QTEdgeImpl(point, edge.end));
      return;
    }
    // Insert the edge.
    final QTEdgeNodeImpl node = _tree.insertEdge(edge);
    node.data = false;
  }

  /// Inserts a point into the tree and collapses all near lines towards it.
  PointNode _insertPoint(QTPoint pnt) {
    final InsertPointResult result = _tree.tryInsertPoint(pnt);
    if (result.existed) return result.point;
    // The point is new, check if any edges pass near it.
    final Set<QTEdgeNodeImpl> nearEdges = <QTEdgeNodeImpl>{};
    _tree.forCloseEdges(QTEdgeHandlerEdgeCollectorImpl(edgeSet: nearEdges), pnt);
    // Remove near edges, store the replacement edges.
    final Set<QTEdgeImpl> liftedEdges = <QTEdgeImpl>{};
    for (final QTEdgeNodeImpl edge in nearEdges) {
      liftedEdges.add(QTEdgeImpl(edge.startNode, result.point, edge.data));
      liftedEdges.add(QTEdgeImpl(result.point, edge.endNode, edge.data));
      _tree.removeEdge(edge, false);
    }
    // Adjust all the near lines.
    final Set<QTEdgeImpl> finalEdges = <QTEdgeImpl>{};
    while (liftedEdges.isNotEmpty) {
      final QTEdge edge = liftedEdges.last;
      liftedEdges.remove(edge);
      final PointNode point = _tree.findClosePoint(edge, QTPointHandlerEdgePointIgnorerImpl(edge));
      if (point == null) {
        finalEdges.add(edge);
      } else {
        liftedEdges.add(QTEdgeImpl(edge.start, point, edge.data));
        liftedEdges.add(QTEdgeImpl(point, edge.end, edge.data));
      }
    }
    // Push the adjusted lines to the tree.
    for (final QTEdge edge in finalEdges) {
      final QTEdgeNodeImpl node = _tree.insertEdge(edge);
      node.data = edge.data;
      // ignore: prefer_asserts_with_message
      assert(node != null);
    }
    return result.point;
  }
}

/// A map of regions.
/// Useful for defining country, state, and zone maps,
/// topographical  maps, or other distinct bounded area maps.
class Regions {
  /// The tree storing the regions.
  QuadTree _tree;

  /// Creates a new region map.
  Regions() {
    _tree = QuadTree();
  }

  /// Gets the tree storing the regions.
  QuadTree get tree => _tree;

  /// Determines the region that the point is inside of.
  int getRegion(QTPoint pnt) {
    final QTEdgeNodeImpl node = _tree.firstLeftEdge(pnt);
    if (node == null) return 0;
    final EdgeSide sideData = node.data as EdgeSide;
    return (side(node, pnt) == Side.Left) ? sideData.left : sideData.right;
  }

  /// Adds a region into the map.
  /// Note: The region will overwrite any region contained in it.
  /// The given [pntCoords] are the x and y pairs for the points of the
  /// simple polygon for the region.
  void addRegionWithCoords(int regionId, List<int> pntCoords) {
    final int count = pntCoords.length ~/ 2;
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
  void addRegion(int regionId, List<QTPoint> pnts) {
    final List<List<QTPoint>> polys = PolygonClipper.Clip(pnts);
    for (final List<QTPoint> poly in polys) {
      _addRegion(regionId, poly);
    }
  }

  /// Adds a clipped region into the map.
  void _addRegion(int regionId, List<QTPoint> pnts) {
    int count = pnts.length;
    // Insert all the end points into the tree.
    final PointNodeVector nodes = PointNodeVector();
    for (int i = 0; i < count; ++i) {
      final PointNode point = _insertPoint(pnts[i]);
      // ignore: prefer_asserts_with_message
      assert(point != null);
      nodes.nodes.add(point);
    }
    // Find all near points to the new edges.
    for (int i = 0; i < count; ++i) {
      final QTEdgeImpl edge = nodes.edge(i);
      final PointNode point = _tree.findClosePoint(edge, QTPointHandlerEdgePointIgnorerImpl(edge));
      if (point != null) {
        nodes.nodes.insert(i + 1, point);
        ++count;
        --i;
      }
    }
    // Find all edge intersections.
    for (int i = 0; i < count; ++i) {
      final QTEdgeImpl edge = nodes.edge(i);
      final IntersectionResult result = _tree.findFirstIntersection(edge, QTEdgeHandlerNeighborIgnorerImpl(edge));
      if (result != null) {
        final PointNode point = _insertPoint(result.point);
        nodes.nodes.insert(i + 1, point);
        ++count;
        --i;
      }
    }
    // Remove any contained data.
    // Create a tree which contains the input so it can be queried.
    final QuadTree newRegion = QuadTree();
    for (int i = 0; i < count; ++i) {
      newRegion.insertEdge(nodes.edge(i));
    }
    _removeContainedPoints(newRegion);
    _removeContainedEdges(newRegion);
    // Insert the edges of the boundary while checking the outside boundary region value.
    final List<QTEdgeNodeImpl> removeEdge = <QTEdgeNodeImpl>[];
    for (int i = 0; i < count; ++i) {
      final QTEdgeImpl edge = nodes.edge(i);
      final PointNode start = edge.start;
      final PointNode end = edge.end;
      QTEdgeNodeImpl last = start.findEdgeTo(end);
      if (last != null) {
        final EdgeSide sideData = last.data as EdgeSide;
        // ignore: prefer_asserts_with_message
        assert(sideData != null);
        sideData.left = regionId;
        if (sideData.right == regionId) removeEdge.add(last);
      } else {
        last = end.findEdgeTo(start);
        if (last != null) {
          final EdgeSide sideData = last.data as EdgeSide;
          // ignore: prefer_asserts_with_message
          assert(sideData != null);
          sideData.right = regionId;
          if (sideData.left == regionId) removeEdge.add(last);
        } else {
          final int outterRangeId = _getSide(start, end);
          if (outterRangeId != regionId) {
            final QTEdgeNodeImpl e = _tree.insertEdge(edge);
            // ignore: prefer_asserts_with_message
            assert(e != null);
            e.data = EdgeSide(regionId, outterRangeId);
          }
        }
      }
    }
    // Remove any edge which ends up with the same data on both sides.
    for (final QTEdgeNodeImpl edge in removeEdge) {
      _tree.removeEdge(edge, false);
    }
    // Find any remaining points which have been orphaned.
    for (int i = 0; i < count; ++i) {
      final PointNode point = _tree.findPoint(nodes.nodes[i]);
      if ((point != null) && point.orphan) {
        _tree.removePoint(point);
      }
    }
  }

  /// Removes the points (and edges connected to those points)
  /// contained within the given region.
  void _removeContainedPoints(QuadTree newRegion) {
    final _PointRemover pntRemover = _PointRemover(newRegion);
    _tree.foreachPoint(pntRemover, newRegion.boundary);
    // Remove all the inner edges and points.
    // ignore: prefer_foreach
    for (final PointNode node in pntRemover.remove) {
      _tree.removePoint(node);
    }
  }

  /// Removes all edges contained in the region.
  void _removeContainedEdges(QuadTree newRegion) {
    final _EdgeRemover edgeRemover = _EdgeRemover(newRegion);
    _tree.foreachEdge(edgeRemover, newRegion.boundary, true);
    // Remove all the inner edges and points.
    for (final QTEdgeNodeImpl node in edgeRemover.remove) {
      _tree.removeEdge(node, true);
    }
  }

  /// Gets the right side value for the given edge.
  /// The given [start] is the start point of the edge to get the side for.
  /// The given [end] is the end point of the edge to get the side for.
  int _getSide(PointNode start, PointNode end) {
    QTEdgeHandlerBorderNeighborImpl border = QTEdgeHandlerBorderNeighborImpl.Points(start, end, true);
    // ignore: prefer_foreach
    for (final QTEdgeNodeImpl neighbor in end.startEdges) {
      border.handle(neighbor);
    }
    // ignore: prefer_foreach
    for (final QTEdgeNodeImpl neighbor in end.endEdges) {
      border.handle(neighbor);
    }
    final QTEdgeNodeImpl next = border.result;
    if (next != null) {
      final EdgeSide sideData = next.data as EdgeSide;
      return next.startNode == end ? sideData.right : sideData.left;
    }
    border = QTEdgeHandlerBorderNeighborImpl.Points(end, start, false);
    // ignore: prefer_foreach
    for (final QTEdgeNodeImpl neighbor in start.startEdges) {
      border.handle(neighbor);
    }
    // ignore: prefer_foreach
    for (final QTEdgeNodeImpl neighbor in start.endEdges) {
      border.handle(neighbor);
    }
    final QTEdgeNodeImpl previous = border.result;
    if (previous != null) {
      final EdgeSide sideData = previous.data as EdgeSide;
      return previous.endNode == start ? sideData.right : sideData.left;
    }
    QTEdgeNodeImpl edge = _tree.firstLeftEdge(start);
    while (edge != null) {
      final EdgeSide sideData = edge.data as EdgeSide;
      final Side _side = side(edge, start);
      if (_side == Side.Right) return sideData.right;
      if (_side == Side.Left) return sideData.left;
      edge = edge.nextBorder() as QTEdgeNodeImpl;
    }
    return 0;
  }

  /// Inserts a point into the tree and collapses all near lines towards it.
  PointNode _insertPoint(QTPoint pnt) {
    final InsertPointResult result = _tree.tryInsertPoint(pnt);
    if (result.existed) return result.point;
    // The point is new, check if any edges pass near it.
    final Set<QTEdgeNodeImpl> nearEdges = <QTEdgeNodeImpl>{};
    _tree.forCloseEdges(QTEdgeHandlerEdgeCollectorImpl(edgeSet: nearEdges), pnt);
    // Remove near edges, store the replacement edges.
    final Set<QTEdgeImpl> liftedEdges = <QTEdgeImpl>{};
    for (final QTEdgeNodeImpl edge in nearEdges) {
      liftedEdges.add(QTEdgeImpl(edge.startNode, result.point, edge.data));
      liftedEdges.add(QTEdgeImpl(result.point, edge.endNode, edge.data));
      _tree.removeEdge(edge, false);
    }
    // Adjust all the near lines.
    final Set<QTEdgeImpl> pushEdges = <QTEdgeImpl>{};
    while (liftedEdges.isNotEmpty) {
      final QTEdge edge = liftedEdges.last;
      liftedEdges.remove(edge);
      final PointNode point = _tree.findClosePoint(edge, QTPointHandlerEdgePointIgnorerImpl(edge));
      if (point == null) {
        pushEdges.add(edge);
      } else {
        liftedEdges.add(QTEdgeImpl(edge.start, point, edge.data));
        liftedEdges.add(QTEdgeImpl(point, edge.end, edge.data));
      }
    }
    // Reduce all edges which are coincident.
    final Set<QTEdgeImpl> finalEdges = <QTEdgeImpl>{};
    while (pushEdges.isNotEmpty) {
      final QTEdge edge = pushEdges.last;
      pushEdges.remove(edge);
      _reduceEdge(pushEdges, finalEdges, edge);
    }
    // Push the adjusted lines to the tree.
    for (final QTEdge edge in finalEdges) {
      final QTEdgeNodeImpl node = _tree.insertEdge(edge);
      node.data = EdgeSide.copy(edge.data);
    }
    return result.point;
  }

  /// Reduces a set of edges to the minimum required edges.
  /// The [pushEdges] are the edges to reduce.
  /// The [finalEdges] are the minimum required edges.
  /// The [edge] is the edge to reduce towards.
  void _reduceEdge(Set<QTEdgeImpl> pushEdges, Set<QTEdgeImpl> finalEdges, QTEdge edge) {
    final List<int> lefts = <int>[];
    final List<int> rights = <int>[];
    EdgeSide sideData = edge.data;
    lefts.add(sideData.left);
    rights.add(sideData.right);
    // Check the tree for an existing line.
    final PointNode start = edge.start;
    QTEdgeNodeImpl treeEdge = start.findEdgeTo(edge.end);
    if (treeEdge != null) {
      sideData = treeEdge.data;
      lefts.add(sideData.left);
      rights.add(sideData.right);
    } else {
      treeEdge = start.findEdgeFrom(edge.end);
      if (treeEdge != null) {
        sideData = treeEdge.data;
        lefts.add(sideData.right);
        rights.add(sideData.left);
      }
    }
    // Check for all other coincident edges.
    final Iterator<QTEdge> it = pushEdges.iterator;
    final List<QTEdge> removeEdge = <QTEdge>[];
    while (it.moveNext()) {
      final QTEdge edge2 = it.current;
      sideData = edge2.data;
      if (QTEdgeImpl.equals(edge, edge2, false)) {
        lefts.add(sideData.left);
        rights.add(sideData.right);
        removeEdge.add(edge2);
      } else if (QTEdgeImpl.opposites(edge, edge2)) {
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

/// Collect all points inside the polygon.
class _PointRemover implements QTPointHandler {
  final QuadTree _region;
  Set<PointNode> _remove;

  _PointRemover(this._region) {
    _remove = <PointNode>{};
  }

  Set<PointNode> get remove => _remove;

  @override
  bool handle(PointNode point) {
    final QTEdgeNodeImpl edge = _region.firstLeftEdge(point);
    if (edge != null) {
      if (side(edge, point) == Side.Left) {
        _remove.add(point);
      }
    }
    return true;
  }
}

/// Collect all edges inside the polygon.
class _EdgeRemover implements QTEdgeHandler {
  final QuadTree _region;
  Set<QTEdgeNodeImpl> _remove;

  _EdgeRemover(this._region) {
    _remove = <QTEdgeNodeImpl>{};
  }

  Set<QTEdgeNodeImpl> get remove => _remove;

  @override
  bool handle(QTEdge edge) {
    final QTPointImpl center = QTPointImpl(edge.x1 + edge.dx ~/ 2, edge.y1 + edge.dy ~/ 2);
    if (QTPointImpl.equals(edge.start, center) || QTPointImpl.equals(edge.end, center)) {
      // Determine if the edge is inside.
      // If both points are not on the region edge then it is outside
      // because all inside points have been removed.
      final PointNode start = _region.findPoint(edge.start);
      if (start == null) return true;
      final PointNode end = _region.findPoint(edge.end);
      if (end == null) return true;
      // If edge is one of the region edges ignore it for now.
      if (start.findEdgeBetween(end) != null) return true;
      // Find nearest edge on region.
      final QTEdgeHandlerBorderNeighborImpl border = QTEdgeHandlerBorderNeighborImpl.Points(end, start, false, null);
      // ignore: prefer_foreach
      for (final QTEdgeNodeImpl neighbor in start.startEdges) {
        border.handle(neighbor);
      }
      // ignore: prefer_foreach
      for (final QTEdgeNodeImpl neighbor in start.endEdges) {
        border.handle(neighbor);
      }
      final QTEdgeNodeImpl regionEdge = border.result;
      if (regionEdge != null) {
        if (regionEdge.endNode != start) {
          _remove.add(edge);
        }
      }
    } else {
      final QTEdgeNodeImpl first = _region.firstLeftEdge(center);
      if (first != null) {
        if (side(first, center) == Side.Left) {
          _remove.add(edge);
        }
      }
    }
    return true;
  }
}
