// @dart = 2.9

import 'boundary/boundary.dart';
import 'boundary/boundary_impl.dart';
import 'edge/edge.dart';
import 'edge/edge_impl.dart';
import 'formatter/formatter.dart';
import 'point/ops/intersect.dart';
import 'point/ops/point_on_edge.dart';
import 'point/ops/side.dart';
import 'point/point.dart';
import 'point/point_impl.dart';
import 'quadtree.dart';

/// Validation handler is an assistant method to the validate method.
class _QTPointHandlerValidateHandlerImpl implements QTPointHandler {
  QTBoundaryImpl bounds;
  int pointCount = 0;
  int edgeCount = 0;

  _QTPointHandlerValidateHandlerImpl();

  @override
  bool handle(
    final PointNode point,
  ) {
    bounds = QTBoundaryImpl.expand(bounds, point);
    pointCount++;
    edgeCount += point.startEdges.length;
    return true;
  }
}

/// Basic string handler is an assistant method to the basic string method.
class _QTPointHandlerBasicStringHandlerImpl implements QTPointHandler {
  final StringBuffer _soutPoints;
  final StringBuffer _soutEdges;

  _QTPointHandlerBasicStringHandlerImpl(
    final this._soutPoints,
    final this._soutEdges,
  );

  @override
  bool handle(PointNode point) {
    _soutPoints.write(StringParts.Space);
    String dataStr = (point.data != null) ? ", ${point.data}" : "";
    _soutPoints.write("[${point.x}, ${point.y}]$dataStr");
    _soutPoints.write(StringParts.Sep);
    for (final QTEdgeNodeImpl edge in point.startEdges) {
      _soutEdges.write(StringParts.Space);
      dataStr = (edge.data != null) ? ", ${edge.data}" : "";
      _soutEdges.write("[${edge.x1}, ${edge.y1}, ${edge.x2}, ${edge.y2}]$dataStr");
      _soutEdges.write(StringParts.Sep);
    }
    return true;
  }
}

/// This is a point handler which collects the points into a set.
class QTPointHandlerCollectorImpl implements QTPointHandler {
  /// The set to add new points into.
  Set<PointNode> _set;

  /// The matcher to filter the collected points with.
  QTPointHandler _filter;

  /// Create a new point collector.
  QTPointHandlerCollectorImpl({
    final Set<PointNode> nodes,
    final QTPointHandler filter,
  }) {
    if (nodes == null) {
      _set = <PointNode>{};
    } else {
      _set = nodes;
    }
    _filter = filter;
  }

  /// The set to add new points into.
  Set<PointNode> get collection => _set;

  /// The matcher to filter the collected points with.
  QTPointHandler get filter => _filter;

  /// Handles a new point.
  @override
  bool handle(PointNode point) {
    if (_filter != null) {
      if (!_filter.handle(point)) return true;
    }
    _set.add(point);
    return true;
  }
}

/// An edge handler to ignore a neighboring edge to the given edge.
class QTEdgeHandlerNeighborIgnorerImpl implements QTEdgeHandler {
  /// The edge to ignore and ignore the neighbors of.
  final QTEdge _edge;

  /// Creates a new neighbor edge ignorer.
  /// The given [edge] is the edge to ignore and ignore the neighbors of.
  QTEdgeHandlerNeighborIgnorerImpl(this._edge);

  /// Gets the edge to ignore and ignore the neighbors of.
  QTEdge get edge => _edge;

  /// Handles an edge to check if it should be ignored.
  @override
  bool handle(QTEdge edge) => !(QTPointImpl.equals(edge.start, _edge.start) ||
      QTPointImpl.equals(edge.start, _edge.end) ||
      QTPointImpl.equals(edge.end, _edge.start) ||
      QTPointImpl.equals(edge.end, _edge.end));
}

/// Handler for calling a given function pointer for each node.
class QTPointHandlerAnonymousImpl implements QTPointHandler {
  /// The handle to call for each node.
  final bool Function(PointNode point) _hndl;

  /// Creates a new node handler.
  const QTPointHandlerAnonymousImpl(
    final this._hndl,
  );

  /// Handles the given node.
  @override
  bool handle(
    final QTNode node,
  ) =>
      _hndl(node);
}

/// Handler for calling a given function pointer for each edge.
class QTEdgeHandlerAnonymousImpl implements QTEdgeHandler {
  /// The handle to call for each edge.
  final bool Function(QTEdge value) _hndl;

  /// Creates a new edge handler.
  const QTEdgeHandlerAnonymousImpl(
    final this._hndl,
  );

  /// Handles the given edge.
  @override
  bool handle(
    final QTEdge edge,
  ) =>
      _hndl(edge);
}

/// The empty node represents a node which has no data, no points nor edges.
/// It is a leaf in all locations that have no information in the tree.
class QTNodeEmptyImpl implements QTNode {
  /// The singleton instance of the empty node.
  static QTNodeEmptyImpl _singleton;

  /// This gets the single instance of the empty node.
  static QTNodeEmptyImpl get instance => _singleton ??= QTNodeEmptyImpl._();

  /// Creates a new empty node.
  QTNodeEmptyImpl._();

  /// Adds a point to this location in the tree.
  QTNode addPoint(int xmin, int ymin, int size, PointNodeImpl point) {
    point.setLocation(xmin, ymin, size);
    return point;
  }

  /// Adds an edge to this location in the tree.
  QTNode addEdge(int xmin, int ymin, int size, QTEdgeNodeImpl edge) {
    final QTBoundaryImpl boundary = QTBoundaryImpl(xmin, ymin, xmin + size - 1, ymin + size - 1);
    if (boundary.overlapsEdge(edge)) {
      final PassNode node = PassNode();
      node.setLocation(xmin, ymin, size);
      node.passEdges.add(edge);
      return node;
    } else {
      return this;
    }
  }

  /// Handles each point node reachable from this node.
  @override
  bool foreachPoint(QTPointHandler handle, [QTBoundary bounds]) => true;

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  @override
  bool foreachEdge(QTEdgeHandler handle, [QTBoundary bounds, bool exclusive = false]) => true;

  /// Handles each node reachable from this node.
  @override
  bool foreachNode(QTNodeHandler handle, [QTBoundary bounds]) => true;

  /// Determines if the node has any point nodes inside it.
  @override
  bool get hasPoints => false;

  /// Determines if the node has any edge nodes inside it.
  @override
  bool get hasEdges => false;

  /// Gets the first edge to the left of the given point.
  @override
  void firstLeftEdge(FirstLeftEdgeArgs args) {}

  /// Handles all the edges to the left of the given point.
  @override
  bool foreachLeftEdge(QTPoint pnt, QTEdgeHandler hndl) => true;

  /// This handles the first found intersecting edge.
  @override
  IntersectionResult findFirstIntersection(QTEdge edge, QTEdgeHandler hndl) => null;

  /// This handles all the intersections.
  @override
  bool findAllIntersections(QTEdge edge, QTEdgeHandler hndl, IntersectionSet intersections) => false;

  /// Validates this node.
  @override
  bool validate(StringBuffer sout, QTFormatter format, bool recursive) => true;

  /// Formats the nodes into a string.
  /// [children] indicates any child should also be stringified.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  @override
  void toBuffer(StringBuffer sout,
      {String indent = "", bool children = false, bool contained = false, bool last = true, QTFormatter format}) {
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
    final StringBuffer sout = StringBuffer();
    toBuffer(sout);
    return sout.toString();
  }
}

/// A point handler for ignoring the start and end point of an edge.
class QTPointHandlerEdgePointIgnorerImpl implements QTPointHandler {
  /// The edge to ignore the points of.
  final QTEdge _edge;

  /// Create a new edge point ignorer.
  /// The given [edge] is the edge to ignore the points of.
  QTPointHandlerEdgePointIgnorerImpl(this._edge);

  /// Gets the edge to ignore the points of.
  QTEdge get edge => _edge;

  /// Handles the point to check to ignore.
  /// Returns true to allow, false to ignore.
  @override
  bool handle(PointNode point) {
    return !(QTPointImpl.equals(point, _edge.start) || QTPointImpl.equals(point, _edge.end));
  }
}

/// The edge node is a connection in the quad-tree between two point nodes. It
/// represents a two dimensional directed line segment.
class QTEdgeNodeImpl implements QTEdge, Comparable<QTEdgeNodeImpl> {
  /// The start point node for the edge.
  final PointNodeImpl _start;

  /// The end point node for the edge.
  final PointNodeImpl _end;

  /// Any additional data that this edge should contain.
  @override
  Object data;

  /// Creates a new edge node.
  QTEdgeNodeImpl._(this._start, this._end, [this.data]) {
    // May not initialize an edge node with a null start node.
    // ignore: prefer_asserts_with_message
    assert(start != null);
    // May not initialize an edge node with a null end node.
    // ignore: prefer_asserts_with_message
    assert(end != null);
    // May not initialize an edge node with the same node for both the start and end.
    // ignore: prefer_asserts_with_message
    assert(start != end);
  }

  /// Gets the start point node for the edge.
  PointNodeImpl get startNode => _start;

  /// Gets the end point node for the edge.
  PointNodeImpl get endNode => _end;

  /// Gets the edge for this edge node.
  QTEdgeImpl get edge => QTEdgeImpl(_start, _end);

  /// Gets the point for the given node.
  /// Set [start] t0 true to return the start point, false to return the end point.
  QTPointImpl point(bool start) => start ? _start.point : _end.point;

  /// Gets the point node for the given point.
  /// Set [start] to true to return the start node, false to return the end node.
  PointNode node(bool start) => start ? _start : _end;

  /// Determines if this edge is connected to the given node.
  /// [point] is the node to determine if it is either the start
  /// or end node of this edge.
  /// Returns true if the given node was either the start or end node of this edge,
  /// false if not or the node was null.
  bool connectsToPoint(PointNode point) => (_start == point) || (_end == point);

  /// Determines if this edge is connected to the given edge. To be connected
  /// either the start node or end node of this edge must be the same node as
  /// either the start node or end node of the given edge.
  /// [edge] is the edge to determine if it shares a node with this edge.
  /// Returns true if the given edge shared a node with this edge,
  /// false if not or the edge was null.
  bool connectsToEdge(QTEdgeNodeImpl edge) =>
      (edge != null) &&
      ((_start == edge._end) || (_end == edge._start) || (_start == edge._start) || (_end == edge._end));

  /// This gets the edge set of neighbor edges to this edge.
  // Set [next] to true to return the start edges from the end node,
  /// false to return the end edges from the start node..
  /// Returns the edge set of neighbors to this edge.
  Set<QTEdgeNodeImpl> neighborEdges(bool next) => next ? _end.startEdges : _start.endEdges;

  /// This will attempt to find an edge which ends where this one starts and
  /// starts where this one ends, coincident and opposite.
  QTEdgeNodeImpl findOpposite() => _end.findEdgeTo(_start);

  /// Gets the first component of the start point of the edge.
  @override
  int get x1 => _start.x;

  /// Gets the second component of the start point of the edge.
  @override
  int get y1 => _start.y;

  /// Gets the first component of the end point of the edge.
  @override
  int get x2 => _end.x;

  /// Gets the second component of the end point of the edge.
  @override
  int get y2 => _end.y;

  /// Gets the start point for this edge.
  @override
  QTPoint get start => _start;

  /// Gets the end point for this edge.
  @override
  QTPoint get end => _end;

  /// Gets the change in the first component, delta X.
  @override
  int get dx => _end.x - _start.x;

  /// Gets the change in the second component, delta Y.
  @override
  int get dy => _end.y - _start.y;

  /// Determines the next neighbor edge on a properly wound polygon.
  QTEdge nextBorder([QTEdgeHandler matcher]) {
    final QTEdgeHandlerBorderNeighborImpl border = QTEdgeHandlerBorderNeighborImpl(this, true, matcher);
    // ignore: prefer_foreach
    for (final QTEdgeNodeImpl neighbor in _end.startEdges) {
      border.handle(neighbor);
    }
    return border.result;
  }

  /// Determines the previous neighbor edge on a properly wound polygon.
  QTEdge previousBorder([QTEdgeHandler matcher]) {
    final QTEdgeHandlerBorderNeighborImpl border = QTEdgeHandlerBorderNeighborImpl.Points(_end, _start, false, matcher);
    // ignore: prefer_foreach
    for (final QTEdgeNodeImpl neighbor in _start.endEdges) {
      border.handle(neighbor);
    }
    return border.result;
  }

  /// Validates this node and all children nodes.
  bool validate(StringBuffer sout, QTFormatter format) {
    bool result = true;
    if (_start.commonAncestor(_end) == null) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(": The nodes don't have a common ancestor.\n");
      result = false;
    }
    if (!_start.startEdges.contains(this)) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(":  The start node, ");
      sout.write(_start);
      sout.write(", doesn't have this edge in it's starting list.\n");
      result = false;
    }
    if (!_end.endEdges.contains(this)) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(":  The end node, ");
      sout.write(_end);
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
  int compareTo(QTEdgeNodeImpl other) {
    final int cmp = _start.compareTo(other._start);
    if (cmp != 0) return cmp;
    return _end.compareTo(other._end);
  }

  /// Formats the nodes into a string.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  void toBuffer(StringBuffer sout, {String indent = "", bool contained = false, bool last = true, QTFormatter format}) {
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
    final StringBuffer sout = StringBuffer();
    toBuffer(sout);
    return sout.toString();
  }
}

/// This is an edge handler which collects the edges into a set.
class QTEdgeHandlerEdgeCollectorImpl implements QTEdgeHandler {
  /// The set to add new edges into.
  Set<QTEdgeNodeImpl> _set;

  /// The matcher to filter the collected edges with.
  QTEdgeHandler _filter;

  /// Create a new edge collector.
  QTEdgeHandlerEdgeCollectorImpl({Set<QTEdgeNodeImpl> edgeSet, QTEdgeHandler filter}) {
    if (edgeSet == null) {
      _set = <QTEdgeNodeImpl>{};
    } else {
      _set = edgeSet;
    }
    _filter = filter;
  }

  /// The set to add new edges into.
  Set<QTEdgeNodeImpl> get collection => _set;

  /// The matcher to filter the collected edges with.
  QTEdgeHandler get filter => _filter;

  /// Handles a new edge.
  @override
  bool handle(QTEdge edge) {
    if (_filter != null) {
      if (!_filter.handle(edge)) return true;
    }
    _set.add(edge);
    return true;
  }
}

/// The point node represents a point in the quad-tree. It can have edges
/// starting or ending on it as well as edges which pass through it.
// ignore: prefer_mixin
class PointNodeImpl with QTNodeBoundaryBase implements PointNode {
  /// The first component (X) of the point.
  final int _x;

  /// The second component (Y) of the point.
  final int _y;

  /// The set of edges which start at this point.
  final Set<QTEdgeNodeImpl> _startEdges;

  /// The set of edges which end at this point.
  final Set<QTEdgeNodeImpl> _endEdges;

  /// The set of edges which pass through this node.
  final Set<QTEdgeNodeImpl> _passEdges;

  /// Any additional data that this point should contain.
  @override
  Object data;

  /// Creates a new point node.
  PointNodeImpl(
    final this._x,
    final this._y,
  )   : _startEdges = <QTEdgeNodeImpl>{},
        _endEdges = <QTEdgeNodeImpl>{},
        _passEdges = <QTEdgeNodeImpl>{},
        data = null;

  /// Gets the first integer coordinate component.
  @override
  int get x => _x;

  /// Gets the second integer coordinate component.
  @override
  int get y => _y;

  /// Gets the point for this node.
  @override
  QTPointImpl get point => QTPointImpl(_x, _y);

  /// Gets the set of edges which start at this point.
  @override
  Set<QTEdgeNodeImpl> get startEdges => _startEdges;

  /// Gets the set of edges which end at this point.
  @override
  Set<QTEdgeNodeImpl> get endEdges => _endEdges;

  /// Gets the set of edges which pass through this node.
  @override
  Set<QTEdgeNodeImpl> get passEdges => _passEdges;

  /// Determines if this point is an orphan, meaning it's point isn't used by any edge.
  @override
  bool get orphan => _startEdges.isEmpty && _endEdges.isEmpty;

  /// Finds an edge that starts at this point and ends at the given point.
  @override
  QTEdgeNodeImpl findEdgeTo(QTPoint end) {
    for (final QTEdgeNodeImpl edge in _startEdges) {
      if (QTPointImpl.equals(edge.endNode, end)) return edge;
    }
    return null;
  }

  /// Finds an edge that ends at this point and starts at the given point.
  @override
  QTEdgeNodeImpl findEdgeFrom(QTPoint start) {
    for (final QTEdgeNodeImpl edge in _endEdges) {
      if (QTPointImpl.equals(edge.startNode, start)) return edge;
    }
    return null;
  }

  /// Finds an edge that starts or ends at this point and connects to the given point.
  @override
  QTEdgeNodeImpl findEdgeBetween(QTPoint other) => findEdgeTo(other) ?? findEdgeFrom(other);

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode insertEdge(covariant QTEdgeNodeImpl edge) {
    if (edge.startNode == this) {
      _startEdges.add(edge);
    } else if (edge.endNode == this) {
      _endEdges.add(edge);
    } else if (overlapsEdge(edge)) _passEdges.add(edge);
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode insertPoint(PointNode point) {
    final BranchNode branch = BranchNode();
    branch.setLocation(xmin, ymin, width);
    final int halfSize = width ~/ 2;
    // Make a copy of this node and set is as a child of the new branch.
    final Quadrant childQuad = branch.childQuad(this);
    setLocation(branch.childX(childQuad), branch.childY(childQuad), halfSize);
    branch.setChild(childQuad, this);
    // Copy lines to new siblings, keep any non-empty sibling.
    for (final Quadrant quad in Quadrant.All) {
      if (quad != childQuad) {
        final PassNode sibling = PassNode();
        sibling.setLocation(branch.childX(quad), branch.childY(quad), halfSize);
        _appendPassingEdges(sibling, _startEdges);
        _appendPassingEdges(sibling, _endEdges);
        _appendPassingEdges(sibling, _passEdges);
        if (sibling.passEdges.isNotEmpty) branch.setChild(quad, sibling);
      }
    }
    // Remove any edges which no longer pass through this point.
    final Iterator<QTEdgeNodeImpl> it = _passEdges.iterator;
    final Set<QTEdgeNodeImpl> remove = <QTEdgeNodeImpl>{};
    while (it.moveNext()) {
      final QTEdgeNodeImpl edge = it.current;
      if (!overlapsEdge(edge)) remove.add(edge);
    }
    _passEdges.removeAll(remove);
    // Add the point to the new branch node, return new node.
    // This allows the branch to grow as needed.
    return branch.insertPoint(point);
  }

  /// This adds all the edges from the given set which pass through the given
  /// pass node to that node.
  void _appendPassingEdges(PassNode node, Set<QTEdgeNodeImpl> edges) {
    for (final QTEdgeNodeImpl edge in edges) {
      if (node.overlapsEdge(edge)) node.passEdges.add(edge);
    }
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode removeEdge(covariant QTEdgeNodeImpl edge, bool trimTree) {
    final QTNode result = this;
    if (edge.startNode == this) {
      _startEdges.remove(edge);
    } else if (edge.endNode == this) {
      _endEdges.remove(edge);
    } else {
      _passEdges.remove(edge);
    }
    return result;
  }

  /// This handles the first found intersecting edge.
  @override
  IntersectionResult findFirstIntersection(QTEdge edge, QTEdgeHandler hndl) {
    if (overlapsEdge(edge)) {
      IntersectionResult result;
      result = _findFirstIntersection(_startEdges, edge, hndl);
      if (result != null) return result;
      result = _findFirstIntersection(_endEdges, edge, hndl);
      if (result != null) return result;
      result = _findFirstIntersection(_passEdges, edge, hndl);
      if (result != null) return result;
    }
    return null;
  }

  /// This handles all the intersections.
  @override
  bool findAllIntersections(QTEdge edge, QTEdgeHandler hndl, IntersectionSet intersections) {
    bool result = false;
    if (overlapsEdge(edge)) {
      if (_findAllIntersections(_startEdges, edge, hndl, intersections)) result = true;
      if (_findAllIntersections(_endEdges, edge, hndl, intersections)) result = true;
      if (_findAllIntersections(_passEdges, edge, hndl, intersections)) result = true;
    }
    return result;
  }

  /// Handles each point node reachable from this node in the boundary.
  @override
  bool foreachPoint(QTPointHandler handle, [QTBoundary bounds]) {
    if ((bounds == null) || bounds.containsPoint(this)) {
      return handle.handle(this);
    } else {
      return true;
    }
  }

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  @override
  bool foreachEdge(QTEdgeHandler handle, [QTBoundary bounds, bool exclusive = false]) {
    if (bounds == null) {
      for (final QTEdgeNodeImpl edge in _startEdges) {
        if (!handle.handle(edge)) return false;
      }
    } else if (overlapsBoundary(bounds)) {
      if (exclusive) {
        // Check all edges which start at this node to see if they end in the bounds.
        // No need to check passEdges nor endEdges because for all exclusive edges
        // all startEdges lists will be checked at some point.
        for (final QTEdgeNodeImpl edge in _startEdges) {
          if (bounds.containsPoint(edge.end)) {
            if (!handle.handle(edge)) return false;
          }
        }
      } else {
        for (final QTEdgeNodeImpl edge in _startEdges) {
          if (!handle.handle(edge)) return false;
        }
        for (final QTEdgeNodeImpl edge in _endEdges) {
          if (!handle.handle(edge)) return false;
        }
        for (final QTEdgeNodeImpl edge in _passEdges) {
          if (!handle.handle(edge)) return false;
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  @override
  bool foreachNode(QTNodeHandler handle, [QTBoundary bounds]) {
    return ((bounds == null) || overlapsBoundary(bounds)) && handle.handle(this);
  }

  /// Determines if the node has any point nodes inside it.
  /// Since this is a point node then it will always return true.
  @override
  bool get hasPoints => true;

  /// Determines if the node has any edge nodes inside it.
  @override
  bool get hasEdges => !(_passEdges.isEmpty || _endEdges.isEmpty || _startEdges.isEmpty);

  /// Gets the first edge to the left of the given point.
  @override
  void firstLeftEdge(FirstLeftEdgeArgs args) {
    _firstLineLeft(_startEdges, args);
    _firstLineLeft(_endEdges, args);
    _firstLineLeft(_passEdges, args);
  }

  /// Handles all the edges to the left of the given point.
  @override
  bool foreachLeftEdge(QTPoint point, QTEdgeHandler handle) {
    if (!_foreachLeftEdge(_startEdges, point, handle)) return false;
    if (!_foreachLeftEdge(_endEdges, point, handle)) return false;
    if (!_foreachLeftEdge(_passEdges, point, handle)) return false;
    return true;
  }

  /// This finds the next point in the tree.
  @override
  PointNode nextPoint(QTPointHandler handle, [QTBoundary boundary]) {
    if (parent == null) return null;
    return parent.findNextPoint(this, boundary, handle);
  }

  /// This finds the previous point in the tree.
  @override
  PointNode previousPoint(QTPointHandler handle, [QTBoundary boundary]) {
    if (parent == null) return null;
    return parent.findPreviousPoint(this, boundary, handle);
  }

  /// This finds the nearest edge to the given point.
  /// When determining which edge should be considered the closest edge when the
  /// point for this node is the nearest point to the query point. This doesn't
  /// check passing edges, only beginning and ending edges because the nearest
  /// edge starts or ends at this node.
  @override
  QTEdgeNodeImpl nearEndEdge(QTPoint queryPoint) {
    final QTEdgeImpl queryEdge = QTEdgeImpl(queryPoint, this);
    QTEdgeNodeImpl rightMost;
    QTEdgeNodeImpl leftMost;
    QTEdgeNodeImpl center;
    // Check all edges which start at this node.
    for (final QTEdgeNodeImpl edge in startEdges) {
      final QTPoint pnt = edge.endNode;
      final Side _side = side(queryEdge, pnt);
      if (_side == Side.Right) {
        if ((rightMost == null) || (side(rightMost, pnt) == Side.Right)) {
          rightMost = edge;
        }
      } else if (_side == Side.Left) {
        if ((leftMost == null) || (side(leftMost, pnt) == Side.Left)) {
          leftMost = edge;
        }
      } else {
        // (side == Side.Inside)
        center = edge;
      }
    }
    // Check all edges which end at this node.
    for (final QTEdgeNodeImpl edge in endEdges) {
      final QTPoint pnt = edge.startNode;
      final Side _side = side(queryEdge, pnt);
      if (_side == Side.Right) {
        if ((rightMost == null) || (side(rightMost, pnt) == Side.Right)) {
          rightMost = edge;
        }
      } else if (_side == Side.Left) {
        if ((leftMost == null) || (side(leftMost, pnt) == Side.Left)) {
          leftMost = edge;
        }
      } else {
        // (side == Side.Inside)
        center = edge;
      }
    }
    // Determine the closest side of the found sides.
    if (rightMost != null) {
      if (leftMost != null) {
        final double rightCross = QTPointImpl.cross(
            QTPointImpl(rightMost.x2 - x, rightMost.y2 - y), QTPointImpl(queryPoint.x - x, queryPoint.y - y));
        final double leftCross = QTPointImpl.cross(
            QTPointImpl(queryPoint.x - x, queryPoint.y - y), QTPointImpl(leftMost.x2 - x, leftMost.y2 - y));
        if (rightCross <= leftCross) {
          return rightMost;
        } else {
          return leftMost;
        }
      } else {
        return rightMost;
      }
    } else if (leftMost != null) {
      return leftMost;
    } else {
      return center;
    }
  }

  /// Determines the replacement node when a point is removed.
  @override
  QTNode get replacement {
    parent = null;
    // If there are no passing edges return an empty node.
    if (_passEdges.isEmpty) return QTNodeEmptyImpl.instance;
    // Otherwise return a passing node with these passing edges.
    final PassNode pass = PassNode();
    pass.setLocation(xmin, ymin, width);
    pass.passEdges.addAll(_passEdges);
    _passEdges.clear();
    return pass;
  }

  /// Validates this node.
  @override
  bool validate(
    final StringBuffer sout,
    final QTFormatter format,
    final bool recursive,
  ) {
    bool result = true;
    if (!containsPoint(this)) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(": The point is not contained by the node's region.\n");
      result = false;
    }
    for (final QTEdgeNodeImpl edge in _startEdges) {
      if (edge == null) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": A null line was in the starting list.\n");
        result = false;
      } else {
        if (edge.startNode != this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the starting list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", doesn't start with this node.\n");
          result = false;
        }
        if (edge.endNode == this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the starting list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", also ends on this node.\n");
          result = false;
        }
        if (recursive) {
          if (!edge.validate(sout, format)) result = false;
        }
      }
    }
    for (final QTEdgeNodeImpl edge in _endEdges) {
      if (edge == null) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": A null line was in the ending list.\n");
        result = false;
      } else {
        if (edge.endNode != this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the ending list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", doesn't end with this node.\n");
          result = false;
        }
        if (edge.startNode == this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the ending list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", also starts on this node.\n");
          result = false;
        }
      }
    }
    for (final QTEdgeNodeImpl edge in _passEdges) {
      if (edge == null) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": A null line was in the passing list.\n");
        result = false;
      } else {
        if (!overlapsEdge(edge)) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the passing list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", doesn't pass through this node.\n");
          result = false;
        }
        if (edge.startNode == this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the passing list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", should be in the starting list.\n");
          result = false;
        }
        if (edge.endNode == this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the passing list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", should be in the ending list.\n");
          result = false;
        }
      }
    }
    return result;
  }

  /// Compares the given point with this point.
  /// Return 1 if this point is greater than the other point,
  /// -1 if this point is less than the other point,
  /// 0 if this point is the same as the other point.
  @override
  int compareTo(PointNode other) {
    if (_y < other.y) return -1;
    if (_y > other.y) return 1;
    if (_x < other.x) return -1;
    if (_x > other.x) return 1;
    return 0;
  }

  /// Formats the nodes into a string.
  /// [children] indicates any child should also be concatenated.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  @override
  void toBuffer(
    final StringBuffer sout, {
    final String indent = "",
    final bool children = false,
    final bool contained = false,
    final bool last = true,
    final QTFormatter format,
  }) {
    if (contained) {
      if (last) {
        sout.write(StringParts.Last);
      } else {
        sout.write(StringParts.Child);
      }
    }
    sout.write("PointNode: ");
    if (format == null) {
      sout.write(point.toString());
    } else {
      sout.write(format.toPointString(point));
    }
    sout.write(", ");
    if (format == null) {
      sout.write(boundary.toString());
    } else {
      sout.write(format.toBoundaryString(boundary));
    }
    if (data != null) {
      sout.write(" ");
      sout.write(data.toString());
    }
    if (children) {
      String childIndent;
      if (contained && !last) {
        childIndent = indent + StringParts.Bar;
      } else {
        childIndent = indent + StringParts.Space;
      }
      final bool hasStart = _startEdges.isNotEmpty;
      final bool hasEnd = _endEdges.isNotEmpty;
      final bool hasPass = _passEdges.isNotEmpty;
      if (hasStart) {
        sout.write(StringParts.Sep);
        sout.write(indent);
        edgeNodesToBuffer(_startEdges, sout,
            indent: childIndent, contained: true, last: !(hasEnd || hasPass), format: format);
      }
      if (hasEnd) {
        sout.write(StringParts.Sep);
        sout.write(indent);
        edgeNodesToBuffer(_endEdges, sout, indent: childIndent, contained: true, last: !hasPass, format: format);
      }
      if (hasPass) {
        sout.write(StringParts.Sep);
        sout.write(indent);
        edgeNodesToBuffer(_passEdges, sout, indent: childIndent, contained: true, last: true, format: format);
      }
    }
  }
}

/// The pass node is a leaf node which has
/// at least one line passing over the node.
// ignore: prefer_mixin
class PassNode with QTNodeBoundaryBase {
  /// The set of edges which pass through this node.
  Set<QTEdgeNodeImpl> _passEdges;

  /// Creates the pass node.
  PassNode() {
    _passEdges = <QTEdgeNodeImpl>{};
  }

  /// Gets the set of edges which pass through this node.
  Set<QTEdgeNodeImpl> get passEdges => _passEdges;

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  @override
  QTNode insertEdge(QTEdgeNodeImpl edge) {
    if (overlapsEdge(edge)) _passEdges.add(edge);
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree
  @override
  QTNode insertPoint(covariant PointNodeImpl point) {
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
  QTNode removeEdge(QTEdgeNodeImpl edge, bool trimTree) {
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
  IntersectionResult findFirstIntersection(QTEdge edge, QTEdgeHandler hndl) {
    if (overlapsEdge(edge)) {
      return _findFirstIntersection(_passEdges, edge, hndl);
    }
    return null;
  }

  /// This handles all the intersections.
  @override
  bool findAllIntersections(QTEdge edge, QTEdgeHandler hndl, IntersectionSet intersections) {
    if (overlapsEdge(edge)) {
      return _findAllIntersections(_passEdges, edge, hndl, intersections);
    }
    return false;
  }

  /// Handles each point node reachable from this node in the boundary.
  @override
  bool foreachPoint(QTPointHandler handle, [QTBoundary bounds]) => true;

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  @override
  bool foreachEdge(QTEdgeHandler handle, [QTBoundary bounds, bool exclusive = false]) {
    if (!exclusive) {
      if ((bounds == null) || overlapsBoundary(bounds)) {
        for (final QTEdgeNodeImpl edge in _passEdges) {
          if (!handle.handle(edge)) return false;
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  @override
  bool foreachNode(QTNodeHandler handle, [QTBoundary bounds]) {
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
  void firstLeftEdge(FirstLeftEdgeArgs args) => _firstLineLeft(_passEdges, args);

  /// Handles all the edges to the left of the given point.
  @override
  bool foreachLeftEdge(QTPoint point, QTEdgeHandler handle) => _foreachLeftEdge(_passEdges, point, handle);

  /// Validates this node.
  /// Set [recursive] to true to validate all children nodes too, false otherwise.
  @override
  bool validate(StringBuffer sout, QTFormatter format, bool recursive) {
    bool result = true;
    for (final QTEdgeNodeImpl edge in _passEdges) {
      if (!overlapsEdge(edge)) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": An edge in the passing list, ");
        edge.toBuffer(sout, format: format);
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
  void toBuffer(StringBuffer sout,
      {String indent = "", bool children = false, bool contained = false, bool last = true, QTFormatter format}) {
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

/// The branch node is a quad-tree branching node with four children nodes.
// ignore: prefer_mixin
class BranchNode with QTNodeBoundaryBase {
  /// The north-east child node.
  QTNode _ne;

  /// The north-west child node.
  QTNode _nw;

  /// The south-east child node.
  QTNode _se;

  /// The south-west child node.
  QTNode _sw;

  /// Creates a new branch node.
  BranchNode() {
    _ne = QTNodeEmptyImpl.instance;
    _nw = QTNodeEmptyImpl.instance;
    _se = QTNodeEmptyImpl.instance;
    _sw = QTNodeEmptyImpl.instance;
  }

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode insertEdge(QTEdgeNodeImpl edge) {
    bool changed = false;
    if (overlapsEdge(edge)) {
      for (final Quadrant quad in Quadrant.All) {
        final QTNode node = child(quad);
        QTNode newChild;
        if (node is QTNodeEmptyImpl) {
          newChild = QTNodeEmptyImpl.instance.addEdge(childX(quad), childY(quad), width ~/ 2, edge);
        } else {
          newChild = (node as QTNodeBoundaryBase).insertEdge(edge);
        }
        if (setChild(quad, newChild)) {
          changed = true;
        }
      }
    }
    if (changed) {
      return reduce();
    } else {
      return this;
    }
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode insertPoint(PointNode point) {
    final Quadrant quad = childQuad(point);
    final QTNode node = child(quad);
    if (node is QTNodeEmptyImpl) {
      final QTNode child = QTNodeEmptyImpl.instance.addPoint(childX(quad), childY(quad), width ~/ 2, point);
      if (setChild(quad, child)) return reduce();
    } else {
      final QTNode child = (node as QTNodeBoundaryBase).insertPoint(point);
      if (setChild(quad, child)) return reduce();
    }
    return this;
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode removeEdge(QTEdgeNodeImpl edge, bool trimTree) {
    bool changed = false;
    if (overlapsEdge(edge)) {
      for (final Quadrant quad in Quadrant.All) {
        final QTNode node = child(quad);
        if (node is! QTNodeEmptyImpl) {
          if (setChild(quad, (node as QTNodeBoundaryBase).removeEdge(edge, trimTree))) {
            changed = true;
            // Even if child changes don't skip others.
          }
        }
      }
    }
    if (changed) {
      return reduce();
    } else {
      return this;
    }
  }

  /// This handles the first found intersecting edge.
  @override
  IntersectionResult findFirstIntersection(QTEdge edge, QTEdgeHandler hndl) {
    if (overlapsEdge(edge)) {
      IntersectionResult result;
      result = _ne.findFirstIntersection(edge, hndl);
      if (result != null) return result;
      result = _nw.findFirstIntersection(edge, hndl);
      if (result != null) return result;
      result = _se.findFirstIntersection(edge, hndl);
      if (result != null) return result;
      result = _sw.findFirstIntersection(edge, hndl);
      if (result != null) return result;
    }
    return null;
  }

  /// This handles all the intersections.
  @override
  bool findAllIntersections(QTEdge edge, QTEdgeHandler hndl, IntersectionSet intersections) {
    bool result = false;
    if (overlapsEdge(edge)) {
      if (_ne.findAllIntersections(edge, hndl, intersections)) result = true;
      if (_nw.findAllIntersections(edge, hndl, intersections)) result = true;
      if (_se.findAllIntersections(edge, hndl, intersections)) result = true;
      if (_sw.findAllIntersections(edge, hndl, intersections)) result = true;
    }
    return result;
  }

  /// Gets the north-east child node.
  QTNode get ne => _ne;

  /// Gets the north-west child node.
  QTNode get nw => _nw;

  /// Gets the south-east child node.
  QTNode get se => _se;

  /// Gets the south-west child node.
  QTNode get sw => _sw;

  /// Handles each point node reachable from this node in the boundary.
  /// Returns true if all points in the boundary were run, false if stopped.
  @override
  bool foreachPoint(QTPointHandler handle, [QTBoundary bounds]) {
    if ((bounds == null) || overlapsBoundary(bounds)) {
      return _ne.foreachPoint(handle, bounds) &&
          _nw.foreachPoint(handle, bounds) &&
          _se.foreachPoint(handle, bounds) &&
          _sw.foreachPoint(handle, bounds);
    }
    return true;
  }

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  @override
  bool foreachEdge(QTEdgeHandler handle, [QTBoundary bounds, bool exclusive = false]) {
    if ((bounds == null) || overlapsBoundary(bounds)) {
      return _ne.foreachEdge(handle, bounds, exclusive) &&
          _nw.foreachEdge(handle, bounds, exclusive) &&
          _se.foreachEdge(handle, bounds, exclusive) &&
          _sw.foreachEdge(handle, bounds, exclusive);
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  /// Returns true if all nodes in the boundary were run,
  /// false if stopped.
  @override
  bool foreachNode(QTNodeHandler handle, [QTBoundary bounds]) {
    if ((bounds == null) || overlapsBoundary(bounds)) {
      return handle.handle(this) &&
          _ne.foreachNode(handle, bounds) &&
          _nw.foreachNode(handle, bounds) &&
          _se.foreachNode(handle, bounds) &&
          _sw.foreachNode(handle, bounds);
    }
    return true;
  }

  /// Determines if the node has any point nodes inside it.
  /// Returns true if this node has any points in it, false otherwise.
  ///
  /// The only way this branch hasn't been reduced is
  /// because there is at least two points in it.
  @override
  bool get hasPoints => true;

  /// Determines if the node has any edge nodes inside it.
  /// Returns true if this edge has any edges in it, false otherwise.
  @override
  bool get hasEdges => _ne.hasEdges && _nw.hasEdges && _se.hasEdges && _sw.hasEdges;

  /// Gets the first edge to the left of the given point.
  @override
  void firstLeftEdge(FirstLeftEdgeArgs args) {
    if ((args.queryPoint.y <= ymax) && (args.queryPoint.y >= ymin)) {
      final Quadrant quad = childQuad(args.queryPoint);
      if (quad == Quadrant.NorthEast) {
        _ne.firstLeftEdge(args);
        // If no edges in the NW child could have a larger right value, skip.
        if ((!args.found) || (args.rightValue <= (xmin + width / 2))) _nw.firstLeftEdge(args);
      } else if (quad == Quadrant.NorthWest) {
        _nw.firstLeftEdge(args);
      } else if (quad == Quadrant.SouthEast) {
        _se.firstLeftEdge(args);
        // If no edges in the SW child could have a larger right value, skip.
        if ((!args.found) || (args.rightValue <= (xmin + width / 2))) _sw.firstLeftEdge(args);
      } else {
        // Quadrant.SouthWest
        _sw.firstLeftEdge(args);
      }
    }
  }

  /// Handles all the edges to the left of the given point.
  /// Returns true if all the edges were processed,
  /// false if the handle stopped early.
  @override
  bool foreachLeftEdge(QTPoint point, QTEdgeHandler hndl) {
    bool result = true;
    if ((point.y <= ymax) && (point.y >= ymin)) {
      final Quadrant quad = childQuad(point);
      if (quad == Quadrant.NorthEast) {
        result = _ne.foreachLeftEdge(point, hndl);
        if (result) result = _nw.foreachLeftEdge(point, hndl);
      } else if (quad == Quadrant.NorthWest) {
        result = _nw.foreachLeftEdge(point, hndl);
      } else if (quad == Quadrant.SouthEast) {
        result = _se.foreachLeftEdge(point, hndl);
        if (result) result = _sw.foreachLeftEdge(point, hndl);
      } else {
        // Quadrant.SouthWest
        result = _sw.foreachLeftEdge(point, hndl);
      }
    }
    return result;
  }

  /// Gets the quadrant of the child in the direction of the given point.
  /// This doesn't check that the point is actually contained by the child indicated,
  /// only the child in the direction of the point.
  Quadrant childQuad(QTPoint pnt) {
    final int half = width ~/ 2;
    final bool south = pnt.y < (ymin + half);
    final bool west = pnt.x < (xmin + half);
    if (south) {
      if (west) {
        return Quadrant.SouthWest;
      } else {
        return Quadrant.SouthEast;
      }
    } else {
      if (west) {
        return Quadrant.NorthWest;
      } else {
        return Quadrant.NorthEast;
      }
    }
  }

  /// Gets the quadrant of the given child node.
  Quadrant childNodeQuad(QTNode node) {
    if (_ne == node) {
      return Quadrant.NorthEast;
    } else if (_nw == node) {
      return Quadrant.NorthWest;
    } else if (_se == node) {
      return Quadrant.SouthEast;
    } else {
      return Quadrant.SouthWest;
    }
  }

  /// Gets the minimum x location of the child of the given quadrant.
  int childX(Quadrant quad) {
    if ((quad == Quadrant.NorthEast) || (quad == Quadrant.SouthEast)) return xmin + width ~/ 2;
    // (quad == Quadrant.NorthWest) || (quad == Quadrant.SouthWest)
    return xmin;
  }

  /// Gets the minimum y location of the child of the given quadrant.
  int childY(Quadrant quad) {
    if ((quad == Quadrant.NorthEast) || (quad == Quadrant.NorthWest)) return ymin + width ~/ 2;
    // (quad == Quadrant.SouthEast) || (quad == Quadrant.SouthWest)
    return ymin;
  }

  /// Gets the child at a given quadrant.
  QTNode child(Quadrant childQuad) {
    if (childQuad == Quadrant.NorthEast) return _ne;
    if (childQuad == Quadrant.NorthWest) return _nw;
    if (childQuad == Quadrant.SouthEast) return _se;
    // childQuad ==  Quadrant.SouthWest
    return _sw;
  }

  /// This sets the child at a given quadrant.
  /// Returns true if the child was changed, false if there was not change.
  bool setChild(Quadrant childQuad, QTNode node) {
    // ignore: prefer_asserts_with_message
    assert(node != this);
    if (childQuad == Quadrant.NorthEast) {
      if (_ne == node) return false;
      _ne = node;
    } else if (childQuad == Quadrant.NorthWest) {
      if (_nw == node) return false;
      _nw = node;
    } else if (childQuad == Quadrant.SouthEast) {
      if (_se == node) return false;
      _se = node;
    } else {
      // childQuad == Quadrant.SouthWest
      if (_sw == node) return false;
      _sw = node;
    }
    if (node is! QTNodeEmptyImpl) {
      (node as QTNodeBoundaryBase).parent = this;
    }
    return true;
  }

  /// Returns the first point within the given boundary in this node.
  /// The given [boundary] is the boundary to search within,
  /// or null for no boundary.
  /// Returns the first point node in the given boundary,
  /// or null if none was found.
  PointNode findFirstPoint(QTBoundary boundary, QTPointHandler handle) {
    if ((boundary == null) || overlapsBoundary(boundary)) {
      for (final Quadrant quad in Quadrant.All) {
        final QTNode node = child(quad);
        if (node is PointNode) {
          if ((boundary == null) || boundary.containsPoint(node)) {
            if ((handle != null) && (!handle.handle(node))) continue;
            return node;
          }
        } else if (node is BranchNode) {
          final PointNode result = node.findFirstPoint(boundary, handle);
          if (result != null) return result;
        }
      }
    }
    return null;
  }

  /// Returns the last point within the given boundary in this node.
  /// The given [boundary] is the boundary to search within,
  /// or null for no boundary.
  /// Returns the last point node in the given boundary,
  /// or null if none was found.
  PointNode findLastPoint(QTBoundary boundary, QTPointHandler handle) {
    if ((boundary == null) || overlapsBoundary(boundary)) {
      for (final Quadrant quad in Quadrant.All) {
        final QTNode node = child(quad);
        if (node is PointNode) {
          if ((boundary == null) || boundary.containsPoint(node)) {
            if ((handle != null) && (!handle.handle(node))) continue;
            return node;
          }
        } else if (node is BranchNode) {
          final PointNode result = node.findLastPoint(boundary, handle);
          if (result != null) return result;
        }
      }
    }
    return null;
  }

  /// Returns the next point in this node after the given child.
  /// The [curNode] is the child node to find the next from.
  /// Returns the next point node in the given region,
  /// or null if none was found.
  PointNode findNextPoint(QTNode curNode, QTBoundary boundary, QTPointHandler handle) {
    List<Quadrant> others;
    final Quadrant quad = childNodeQuad(curNode);
    if (quad == Quadrant.NorthWest) {
      others = [Quadrant.NorthEast, Quadrant.SouthWest, Quadrant.SouthEast];
    } else if (quad == Quadrant.NorthEast) {
      others = [Quadrant.SouthWest, Quadrant.SouthEast];
    } else if (quad == Quadrant.SouthWest) {
      others = [Quadrant.SouthEast];
    } else {
      others = [];
    }

    for (final Quadrant quad in others) {
      final QTNode node = child(quad);
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          if ((handle != null) && (!handle.handle(node))) {
            continue;
          } else {
            return node;
          }
        }
      } else if (node is BranchNode) {
        final PointNode result = node.findFirstPoint(boundary, handle);
        if (result != null) return result;
      }
    }
    if (parent == null) {
      return null;
    } else {
      return parent.findNextPoint(this, boundary, handle);
    }
  }

  /// Returns the previous point in this node after the given child.
  /// The [curNode] is the child node to find the next from.
  /// Returns the previous point node in the given region,
  /// or null if none was found.
  PointNode findPreviousPoint(QTNode curNode, QTBoundary boundary, QTPointHandler handle) {
    List<Quadrant> others;
    final Quadrant quad = childNodeQuad(curNode);
    if (quad == Quadrant.NorthWest) {
      others = [];
    } else if (quad == Quadrant.NorthEast) {
      others = [Quadrant.NorthWest];
    } else if (quad == Quadrant.SouthWest) {
      others = [Quadrant.NorthWest, Quadrant.NorthEast];
    } else {
      others = [Quadrant.NorthWest, Quadrant.NorthEast, Quadrant.SouthWest];
    }
    for (final Quadrant quad in others) {
      final QTNode node = child(quad);
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          if ((handle != null) && (!handle.handle(node))) {
            continue;
          } else {
            return node;
          }
        }
      } else if (node is BranchNode) {
        final PointNode result = node.findLastPoint(boundary, handle);
        if (result != null) return result;
      }
    }
    if (parent == null) {
      return null;
    } else {
      return parent.findPreviousPoint(this, boundary, handle);
    }
  }

  /// Determine if this node can be reduced.
  /// Returns this branch node if not reduced,
  /// or the reduced node to replace this node with.
  QTNode reduce() {
    // A branch node can be reduced any time the all of the children
    // contain no points or only one point.
    final int pointCount = _pointWeight(_ne) + _pointWeight(_nw) + _pointWeight(_se) + _pointWeight(_sw);
    if (pointCount == 0) {
      // Find an pass node and populate it with the other pass nodes' lines.
      PassNode pass;
      for (final Quadrant quad in Quadrant.All) {
        final QTNode node = child(quad);
        if (node is PassNode) {
          if (pass == null) {
            pass = node;
            pass.setLocation(xmin, ymin, width);
            pass.parent = null;
            setChild(quad, QTNodeEmptyImpl.instance);
          } else {
            // Copy all edges from this pass node into the already found pass node.
            pass.passEdges.addAll(node.passEdges);
          }
        }
      }
      // Return either the found pass node or the empty node.
      if (pass != null) {
        return pass;
      } else {
        return QTNodeEmptyImpl.instance;
      }
    } else if (pointCount == 1) {
      // Find the point node in the children.
      PointNodeImpl point;
      for (final Quadrant quad in Quadrant.All) {
        final QTNode node = child(quad);
        if (node is PointNode) {
          // Point node found, relocate and remove the node
          // from this parent node so that it isn't deleted later.
          point = node;
          point.setLocation(xmin, ymin, width);
          point.parent = null;
          setChild(quad, QTNodeEmptyImpl.instance);
          break;
        }
      }
      if (point == null) return QTNodeEmptyImpl.instance;
      // Find any pass nodes and copy all lines into the point node.
      for (final Quadrant quad in Quadrant.All) {
        final QTNode node = child(quad);
        if (node is PassNode) {
          // Add all passing lines to point node unless the line starts or ends
          // on the point node, since the line will already be in the start or end line lists.
          for (final QTEdgeNodeImpl edge in node.passEdges) {
            if ((edge.startNode != point) && (edge.endNode != point)) point.passEdges.add(edge);
          }
        }
      }
      // Return found point node.
      return point;
    } else {
      // Can't reduce so return this node.
      return this;
    }
  }

  /// Gets a weighting which indicates the minimum amount
  /// of points which can be in the node.
  int _pointWeight(QTNode node) {
    if (node is PointNode) {
      return 1;
    } else if (node is BranchNode) {
      return 2;
    } else if (node is PassNode) {
      return 0;
    } else {
      return 0;
    }
  }

  //// Validates this node.
  @override
  bool validate(StringBuffer sout, QTFormatter format, bool recursive) {
    bool result = true;
    if (!_validateChild(sout, format, recursive, _ne, "NE", true, true)) result = false;
    if (!_validateChild(sout, format, recursive, _nw, "NW", true, false)) result = false;
    if (!_validateChild(sout, format, recursive, _sw, "SW", false, false)) result = false;
    if (!_validateChild(sout, format, recursive, _se, "SE", false, true)) result = false;
    return result;
  }

  /// Validates the given child node.
  bool _validateChild(
      StringBuffer sout, QTFormatter format, bool recursive, QTNode child, String name, bool north, bool east) {
    if (child == null) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(": The ");
      sout.write(name);
      sout.write(" child was null.\n");
      return false;
    }
    bool result = true;
    if (child is! QTNodeEmptyImpl) {
      final QTNodeBoundaryBase bnode = child as QTNodeBoundaryBase;
      if (bnode.parent != this) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": The ");
        sout.write(name);
        sout.write(" child, ");
        child.toBuffer(sout, format: format);
        sout.write(", parent wasn't this node, it was ");
        (child as QTNodeBoundaryBase).parent.toBuffer(sout, format: format);
        sout.write(".\n");
        result = false;
      }
      if (width / 2 != bnode.width) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": The ");
        sout.write(name);
        sout.write(" child, ");
        child.toBuffer(sout, format: format);
        sout.write(", was ");
        sout.write(bnode.width);
        sout.write(" wide, but should have been ");
        sout.write(width / 2);
        sout.write(".\n");
        result = false;
      }
      final int left = east ? (xmin + bnode.width) : xmin;
      final int top = north ? (ymin + bnode.width) : ymin;
      if ((left != bnode.xmin) || (top != bnode.ymin)) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": The ");
        sout.write(name);
        sout.write(" child, ");
        child.toBuffer(sout, format: format);
        sout.write(", was at [");
        sout.write(bnode.xmin);
        sout.write(", ");
        sout.write(bnode.ymin);
        sout.write("], but should have been [");
        sout.write(left);
        sout.write(", ");
        sout.write(top);
        sout.write("].\n");
        result = false;
      }
    }
    if (recursive) {
      if (!child.validate(sout, format, recursive)) result = false;
    }
    return result;
  }

  /// Formats the node into a string.
  /// [children] indicates any child should also be string-ified.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  @override
  void toBuffer(StringBuffer sout,
      {String indent = "", bool children = false, bool contained = false, bool last = true, QTFormatter format}) {
    if (contained) {
      if (last) {
        sout.write(StringParts.Last);
      } else {
        sout.write(StringParts.Child);
      }
    }
    sout.write("BranchNode: ");
    if (format == null) {
      sout.write(boundary.toString());
    } else {
      sout.write(format.toBoundaryString(boundary));
    }
    if (children) {
      sout.write(StringParts.Sep);
      sout.write(indent);
      _ne.toBuffer(sout,
          indent: indent + StringParts.Bar, children: true, contained: true, last: false, format: format);
      sout.write(StringParts.Sep);
      sout.write(indent);
      _nw.toBuffer(sout,
          indent: indent + StringParts.Bar, children: true, contained: true, last: false, format: format);
      sout.write(StringParts.Sep);
      sout.write(indent);
      _se.toBuffer(sout,
          indent: indent + StringParts.Bar, children: true, contained: true, last: false, format: format);
      sout.write(StringParts.Sep);
      sout.write(indent);
      _sw.toBuffer(sout,
          indent: indent + StringParts.Space, children: true, contained: true, last: true, format: format);
    }
  }
}

/// This is the base node for all non-empty nodes.
abstract class QTNodeBoundaryBase implements QTNodeBoundary {
  /// The minimum X location of this node.
  int _xmin = 0;

  /// The minimum Y location of this node.
  int _ymin = 0;

  /// The width and height of this node.
  int _size = 1;

  /// The parent of this node.
  BranchNode _parent;

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  QTNode insertEdge(QTEdgeNodeImpl edge);

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  QTNode insertPoint(PointNode point);

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  QTNode removeEdge(QTEdgeNodeImpl edge, bool trimTree);

  /// The parent node to this node.
  // ignore: unnecessary_getters_setters
  BranchNode get parent => _parent;

  /// TODO use abstract once nnbd is on.
  // ignore: unnecessary_getters_setters
  set parent(BranchNode parent) => _parent = parent;

  /// Determines the depth of this node in the tree.
  /// Returns the depth of this node in the tree,
  /// if it has no parents then the depth is zero.
  int get depth {
    int depth = 0;
    BranchNode parent = _parent;
    while (parent != null) {
      parent = parent.parent;
      ++depth;
    }
    return depth;
  }

  /// Determines the root of this tree.
  QTNodeBoundaryBase get root {
    QTNodeBoundaryBase cur = this;
    for (;;) {
      final QTNodeBoundaryBase parent = cur.parent;
      if (parent == null) return cur;
      cur = parent;
    }
  }

  /// Determines the common ancestor node between this node and the other node.
  /// Returns the common ancestor or null if none exists.
  BranchNode commonAncestor(QTNodeBoundaryBase other) {
    int depth1 = depth;
    int depth2 = other.depth;
    BranchNode parent1 = _parent;
    BranchNode parent2 = other._parent;
    // Get the parents to the same depth.
    while (depth1 > depth2) {
      if (parent1 == null) return null;
      parent1 = parent1.parent;
      --depth1;
    }
    // ignore: invariant_booleans
    while (depth2 > depth1) {
      if (parent2 == null) return null;
      parent2 = parent2.parent;
      --depth2;
    }
    // Keep going up tree until the parents are the same.
    while (parent1 != parent2) {
      if (parent1 == null) return null;
      if (parent2 == null) return null;
      parent1 = parent1.parent;
      parent2 = parent2.parent;
    }
    // Return the common ancestor.
    return parent1;
  }

  /// Gets creates a boundary for this node.
  QTBoundaryImpl get boundary => QTBoundaryImpl(_xmin, _ymin, xmax, ymax);

  /// Sets the location of this node.
  void setLocation(int xmin, int ymin, int size) {
    // ignore: prefer_asserts_with_message
    assert(size > 0);
    _xmin = xmin;
    _ymin = ymin;
    _size = size;
  }

  /// Gets the minimum X location of this node.
  @override
  int get xmin => _xmin;

  /// Gets the minimum Y location of this node.
  @override
  int get ymin => _ymin;

  /// Gets the maximum X location of this node.
  @override
  int get xmax => _xmin + _size - 1;

  /// Gets the maximum Y location of this node.
  @override
  int get ymax => _ymin + _size - 1;

  /// Gets the width of boundary.
  @override
  int get width => _size;

  /// Gets the height of boundary.
  @override
  int get height => _size;

  /// Gets the boundary region the given point was in.
  @override
  BoundaryRegion region(QTPoint point) => boundary.region(point);

  /// Checks if the given point is completely contained within this boundary.
  /// Returns true if the point is fully contained, false otherwise.
  @override
  bool containsPoint(QTPoint point) => boundary.containsPoint(point);

  /// Checks if the given edge is completely contained within this boundary.
  /// Returns true if the edge is fully contained, false otherwise.
  @override
  bool containsEdge(QTEdge edge) => boundary.containsEdge(edge);

  /// Checks if the given boundary is completely contains by this boundary.
  /// Returns true if the boundary is fully contained, false otherwise.
  @override
  bool containsBoundary(QTBoundary boundary) => boundary.containsBoundary(boundary);

  /// Checks if the given edge overlaps this boundary.
  /// Returns true if the edge is overlaps, false otherwise.
  @override
  bool overlapsEdge(QTEdge edge) => boundary.overlapsEdge(edge);

  /// Checks if the given boundary overlaps this boundary.
  /// Returns true if the given boundary overlaps this boundary,
  /// false otherwise.
  @override
  bool overlapsBoundary(QTBoundary boundary) => boundary.overlapsBoundary(boundary);

  /// Gets the distance squared from this boundary to the given point.
  /// Returns the distance squared from this boundary to the given point.
  @override
  double distance2(QTPoint point) => boundary.distance2(point);

  /// This gets the first edge to the left of the given point.
  /// The [args] are an argument class used to store all the arguments and
  /// results for running this methods.
  void _firstLineLeft(Set<QTEdgeNodeImpl> edgeSet, FirstLeftEdgeArgs args) {
    // ignore: prefer_foreach
    for (final QTEdgeNodeImpl edge in edgeSet) {
      args.update(edge);
    }
  }

  /// This handles all the edges in the given set to the left of the given point.
  bool _foreachLeftEdge(Set<QTEdgeNodeImpl> edgeSet, QTPoint point, QTEdgeHandler handle) {
    for (final QTEdgeNodeImpl edge in edgeSet) {
      if (edge.y1 > point.y) {
        if (edge.y2 > point.y) continue;
      } else if (edge.y1 < point.y) {
        if (edge.y2 < point.y) continue;
      }
      if ((edge.x1 > point.x) && (edge.x2 > point.x)) continue;
      final double x = (point.y - edge.y2) * edge.dx / edge.dy + edge.x2;
      if (x > point.x) continue;
      if (!handle.handle(edge)) return false;
    }
    return true;
  }

  /// This handles the first found intersecting edge in the given edge set.
  IntersectionResult _findFirstIntersection(Set<QTEdgeNodeImpl> edgeSet, QTEdge edge, QTEdgeHandler hndl) {
    for (final QTEdgeNodeImpl other in edgeSet) {
      if ((hndl == null) || hndl.handle(other)) {
        final IntersectionResult inter = intersect(edge, other);
        if (inter.intersects) {
          return inter;
        }
      }
    }
    return null;
  }

  /// This handles all the intersections in the given edge set.
  bool _findAllIntersections(
      Set<QTEdgeNodeImpl> edgeSet, QTEdge edge, QTEdgeHandler hndl, IntersectionSet intersections) {
    bool result = false;
    for (final QTEdgeNodeImpl other in edgeSet) {
      if ((hndl == null) || hndl.handle(other)) {
        if (!intersections.constainsB(other)) {
          final IntersectionResult inter = intersect(edge, other);
          if (inter.intersects) {
            intersections.add(inter);
            result = true;
          }
        }
      }
    }
    return result;
  }

  /// Gets the string for this node.
  @override
  String toString() {
    final StringBuffer sout = StringBuffer();
    toBuffer(sout);
    return sout.toString();
  }
}

/// An edge handler for determining a border neighbor.
/// The border neighbor is the most clockwise (or counter-clockwise) line sharing a point
/// with an edge. This will flow a border if the shapes is wound properly.
class QTEdgeHandlerBorderNeighborImpl implements QTEdgeHandler {
  /// The query edge to get the neighbor of.
  final QTEdge _query;

  /// True to use a counter-clockwise border, false if clockwise.
  final bool _ccw;

  /// The matcher to filter possible neighbors.
  final QTEdgeHandler _matcher;

  /// The current result neighbor edge.
  QTEdge _result;

  /// The current result edge or opposite to point away from query edge.
  QTEdge _adjusted;

  /// Indicates that forward edges are still allowed,
  /// edges which head in the same direction as the query edge.
  bool _allowFore;

  /// Indicates that backward edges are still allowed,
  /// edges which head back towards the query point.
  bool _allowBack;

  /// Indicates that left or right edges are still allowed.
  bool _allowTurn;

  /// Indicates that a left edge has been found.
  bool _hasLeft;

  /// Indicates that a right edge has been found.
  bool _hasRight;

  /// Creates a new border neighbor finder.
  /// The given [_query] point is usually the other point on the border.
  /// Set [_ccw] to true to use a counter-clockwise border, false if clockwise.
  /// The given [_matcher] will filter possible neighbors.
  QTEdgeHandlerBorderNeighborImpl(this._query, [this._ccw = true, this._matcher]) {
    _result = null;
    _adjusted = null;
    _allowFore = true;
    _allowBack = true;
    _allowTurn = true;
    _hasLeft = false;
    _hasRight = false;
  }

  /// Creates a new border neighbor finder.
  /// The given [origin] point is the origin for neighbors.
  /// The given [query] point is usually the other point on the border.
  /// Set [ccw] to true to use a counter-clockwise border, false if clockwise.
  /// The given [matcher] will filter possible neighbors.
  QTEdgeHandlerBorderNeighborImpl.Points(QTPoint origin, QTPoint query, [bool ccw = true, QTEdgeHandler matcher])
      : this(QTEdgeImpl(origin, query), ccw, matcher);

  /// The currently found edge border neighbor or null.
  QTEdge get result => this._result;

  /// Updates the border neighbor with the given edge.
  /// Always returns true.
  @override
  bool handle(QTEdge edge) {
    if (_matcher != null) {
      if (edge is QTEdgeNodeImpl) {
        if (!_matcher.handle(edge)) return true;
      }
    }
    final QTEdge adjusted = _adjustedNeighbor(edge);
    if (adjusted == null) return true;
    if (_ccw) {
      _ccwNeighbor(edge, adjusted);
    } else {
      _cwNeighbor(edge, adjusted);
    }
    return true;
  }

  /// Gets the neighbor edge edge or opposite to point away from query edge.
  QTEdge _adjustedNeighbor(QTEdge edge) {
    if (QTPointImpl.equals(edge.start, _query.start) || QTPointImpl.equals(edge.start, _query.end)) return edge;
    if (QTPointImpl.equals(edge.end, _query.start) || QTPointImpl.equals(edge.end, _query.end)) {
      return QTEdgeImpl(edge.end, edge.start);
    }
    return null;
  }

  /// Updates the counter-clockwise border neighbor.
  void _ccwNeighbor(QTEdge edge, QTEdge adjusted) {
    // Get the far point in the other edge.
    final QTPoint point = adjusted.end;
    // Check if edge is opposite.
    if (QTPointImpl.equals(point, _query.end)) {
      if (_allowBack) {
        _result = edge;
        _adjusted = adjusted;
        _allowBack = false;
      }
      return;
    }
    // Determine the side of the query edge that the other edge is on.
    switch (side(_query, point)) {
      case Side.Inside:
        if (_allowFore || _allowBack) {
          // Bias toward edges heading the same way.
          if (QTEdgeImpl.acute(_query, edge)) {
            if (_allowFore) {
              _result = edge;
              _adjusted = adjusted;
              _allowFore = false;
              _allowBack = false;
              _allowTurn = false;
            }
          } else if (_allowBack) {
            _result = edge;
            _adjusted = adjusted;
            _allowBack = false;
          }
        }
        break;
      case Side.Left:
        if (_allowTurn) {
          if (!_hasLeft) {
            _result = edge;
            _adjusted = adjusted;
            _hasLeft = true;
            _allowBack = false;
          } else if (side(_adjusted, point) == Side.Right) {
            _result = edge;
            _adjusted = adjusted;
          }
        }
        break;
      case Side.Right:
        if (!_hasRight) {
          _result = edge;
          _adjusted = adjusted;
          _hasRight = true;
          _allowFore = false;
          _allowBack = false;
          _allowTurn = false;
        } else if (side(_adjusted, point) == Side.Right) {
          _result = edge;
          _adjusted = adjusted;
        }
        break;
    }
  }

  /// Updates the clockwise border neighbor.
  void _cwNeighbor(QTEdge edge, QTEdge adjusted) {
    // Get the far point in the other edge.
    final QTPoint point = adjusted.end;
    // Check if edge is opposite.
    if (QTPointImpl.equals(point, _query.end)) {
      if (_allowBack) {
        _result = edge;
        _adjusted = adjusted;
        _allowBack = false;
      }
      return;
    }
    // Determine the side of the query edge that the other edge is on.
    switch (side(_query, point)) {
      case Side.Inside:
        if (_allowFore || _allowBack) {
          // Bias toward edges heading the same way.
          if (QTEdgeImpl.acute(_query, edge)) {
            if (_allowFore) {
              _result = edge;
              _adjusted = adjusted;
              _allowFore = false;
              _allowBack = false;
              _allowTurn = false;
            }
          } else if (_allowBack) {
            _result = edge;
            _adjusted = adjusted;
            _allowBack = false;
          }
        }
        break;
      case Side.Left:
        if (!_hasLeft) {
          _result = edge;
          _adjusted = adjusted;
          _hasLeft = true;
          _allowFore = false;
          _allowBack = false;
          _allowTurn = false;
        } else if (side(_adjusted, point) == Side.Left) {
          _result = edge;
          _adjusted = adjusted;
        }
        break;
      case Side.Right:
        if (_allowTurn) {
          if (!_hasRight) {
            _result = edge;
            _adjusted = adjusted;
            _hasRight = true;
            _allowBack = false;
          } else if (side(_adjusted, point) == Side.Left) {
            _result = edge;
            _adjusted = adjusted;
          }
        }
        break;
    }
  }
}

/// An edge handler which can be used to accumulate a shapes area.
class QTEdgeHandlerAreaAccumulatorImpl implements QTEdgeHandler {
  /// The currently accumulated area.
  double _area;

  /// Create a new area accumulator.
  QTEdgeHandlerAreaAccumulatorImpl() {
    _area = 0.0;
  }

  /// This gets the signed area accumulated.
  /// A positive area generally wraps counter-clockwise,
  /// a negative area generally wraps clockwise.
  double get signedArea => _area;

  /// This returns the unsigned area accumulated.
  double get area => (_area < 0.0) ? -_area : _area;

  /// Indicates if the shape  if accumulated area is counter clockwise,
  /// Returns true if counter clockwise, false if clockwise.
  bool get ccw => _area > 0.0;

  /// Adds a new edge of the shape to the accumulated area.
  /// Always returns true.
  @override
  bool handle(QTEdge edge) {
    _area += (edge.x1.toDouble() * edge.y2.toDouble() - edge.x2.toDouble() * edge.y1.toDouble()) * 0.5;
    return true;
  }
}

/// The first left edge arguments to handle multiple returns objects for
/// determining the first left edge to a point.
class FirstLeftEdgeArgsImpl implements FirstLeftEdgeArgs {
  /// The query point to find the first edge left of.
  final QTPoint _queryPoint;

  /// The edge matcher to filter edges with.
  final QTEdgeHandler _handle;

  /// The current right most value.
  double _rightValue;

  /// The currently found closest edge.
  /// Null if a point has been found closer.
  QTEdgeNodeImpl _resultEdge;

  /// The node if the nearest part of the edge is the point.
  /// Null if an edge has been found closer.
  PointNode _resultPoint;

  /// Creates a new first left edge argument for finding the first edge that is
  /// left of the given query point.
  /// [queryPoint] is the point to find the first edge left of.
  FirstLeftEdgeArgsImpl(
    final this._queryPoint,
    final this._handle,
  )   : _rightValue = -double.maxFinite,
        _resultEdge = null,
        _resultPoint = null;

  /// Gets the query point, the point to find the first edge left of.
  @override
  QTPoint get queryPoint => _queryPoint;

  /// Gets the x value of the location the left horizontal edge crosses the
  /// current result. This will be the right most value found.
  @override
  double get rightValue => _rightValue;

  /// Indicates that a result has been found. This doesn't mean the correct
  /// solution has been found. Only that a value has been found.
  @override
  bool get found => (_resultEdge != null) || (_resultPoint != null);

  /// Gets the resulting first edge left of the query point.
  /// Returns the first left edge in the tree which was found.
  /// If no edges were found null is returned.
  @override
  QTEdgeNodeImpl get result {
    if (_resultPoint == null) return _resultEdge;
    return _resultPoint.nearEndEdge(_queryPoint);
  }

  /// This updates with the given edges.
  @override
  void update(covariant QTEdgeNodeImpl edge) {
    if (edge == null) return;
    if (edge == _resultEdge) return;
    if (_handle != null) {
      if (!_handle.handle(edge)) return;
    }
    // Determine how the edge crosses the horizontal edge from the point and left.
    if (edge.y1 == _queryPoint.y) {
      if (edge.y2 == _queryPoint.y) {
        if (edge.x1 > _queryPoint.x) {
          if (edge.x2 > _queryPoint.x) {
            // The edge to the right of the point, do nothing.
          } else {
            // The edge is collinear with and contains the query point.
            _updateWithEdge(edge, _queryPoint.x.toDouble());
          }
        } else if (edge.x2 > _queryPoint.x) {
          // The edge is collinear with and contains the query point.
          _updateWithEdge(edge, _queryPoint.x.toDouble());
        } else if (edge.x1 > edge.x2) {
          // The edge is collinear with the point and the start is more right.
          _updateWithPoint(edge.startNode);
        } else {
          // The edge is collinear with the point and the start is more left.
          _updateWithPoint(edge.endNode);
        }
      } else if (edge.x1 < _queryPoint.x) {
        // The start point is on the horizontal and to the left.
        _updateWithPoint(edge.startNode);
      } else {
        // The start point is on the horizontal but on or to the right, do nothing.
      }
    } else if (edge.y1 > _queryPoint.y) {
      if (edge.y2 == _queryPoint.y) {
        if (edge.x2 <= _queryPoint.x) {
          // The end point is on the horizontal and on or to the left.
          _updateWithPoint(edge.endNode);
        } else {
          // The end point is on the horizontal but to the right, do nothing.
        }
      } else if (edge.y2 > _queryPoint.y) {
        // The edge is above the horizontal, do nothing.
      } else {
        // (edge.y2 < this._queryPoint.y)
        if ((edge.x1 > _queryPoint.x) && (edge.x2 > _queryPoint.x)) {
          // The edge is to the right of the point, do nothing.
        } else {
          final double x = (edge.x1 - edge.x2) * (_queryPoint.y - edge.y2) / (edge.y1 - edge.y2) + edge.x2;
          if (x > _queryPoint.x) {
            // The horizontal crossing is to the right of the point, do nothing.
          } else {
            // The edge crosses to the left of the point.
            _updateWithEdge(edge, x);
          }
        }
      }
    } else {
      // (edge.y1 < this._queryPoint.y)
      if (edge.y2 == _queryPoint.y) {
        if (edge.x2 <= _queryPoint.x) {
          // The end point is on the horizontal and on or to the left.
          _updateWithPoint(edge.endNode);
        } else {
          // The end point is on the horizontal but to the right, do nothing.
        }
      } else if (edge.y2 < _queryPoint.y) {
        // The edge is below the horizontal, do nothing.
      } else {
        // (edge.y2 > this._queryPoint.y)
        if ((edge.x1 > _queryPoint.x) && (edge.x2 > _queryPoint.x)) {
          // The edge is to the right of the point, do nothing.
        } else {
          final double x = (edge.x1 - edge.x2) * (_queryPoint.y - edge.y2) / (edge.y1 - edge.y2) + edge.x2;
          if (x > _queryPoint.x) {
            // The horizontal crossing is to the right of the point, do nothing.
          } else {
            // The edge crosses to the left of the point.
            _updateWithEdge(edge, x);
          }
        }
      }
    }
  }

  /// The edge to update with has the point on the horizontal edge inside it.
  void _updateWithEdge(QTEdgeNodeImpl edge, double loc) {
    if (loc > _rightValue) {
      _resultEdge = edge;
      _resultPoint = null;
      _rightValue = loc;
    }
  }

  /// The edge to update with has the point on the horizontal edge at one of the end points.
  /// This is called to update with that point instead of point inside the edge.
  void _updateWithPoint(PointNode point) {
    if (point.x > _rightValue) {
      // Do not set _resultEdge here, leave it as the previous value.
      _resultPoint = point;
      _rightValue = point.x.toDouble();
    }
  }
}

/// A polygon mapping quad-tree for storing edges and
/// points in a two dimensional logarithmic data structure.
class QuadTree {
  /// The root node of the quad-tree.
  QTNode _root;

  /// The tight bounding box of all the data.
  QTBoundaryImpl _boundary;

  /// The number of points in the tree.
  int _pointCount;

  /// The number of edges in the tree.
  int _edgeCount;

  /// Creates a new quad-tree.
  QuadTree() {
    _root = QTNodeEmptyImpl.instance;
    _boundary = QTBoundaryImpl(0, 0, 0, 0);
    _pointCount = 0;
    _edgeCount = 0;
  }

  /// The root node of the quad-tree.
  QTNode get root => _root;

  /// Gets the tight bounding box of all the data.
  QTBoundaryImpl get boundary => _boundary;

  /// Gets the number of points in the tree.
  int get pointCount => _pointCount;

  /// Gets the number of edges in the tree.
  int get edgeCount => _edgeCount;

  /// Clears all the points, edges, and nodes from the quad-tree.
  /// Does not clear the additional data.
  void clear() {
    _root = QTNodeEmptyImpl.instance;
    _boundary = QTBoundaryImpl(0, 0, 0, 0);
    _pointCount = 0;
    _edgeCount = 0;
  }

  /// Gets the boundary containing all nodes.
  QTBoundaryImpl get rootBoundary {
    if (_root is QTNodeBoundaryBase) return (_root as QTNodeBoundaryBase).boundary;
    return QTBoundaryImpl(0, 0, 0, 0);
  }

  /// Finds a point node from this node for the given point.
  PointNode findPoint(QTPoint point) {
    if (!rootBoundary.containsPoint(point)) return null;
    QTNode node = _root;
    for (;;) {
      if (node is PointNode) {
        if (QTPointImpl.equals(node, point)) {
          return node;
        } else {
          return null;
        }
      } else if (node is BranchNode) {
        final BranchNode branch = node as BranchNode;
        final Quadrant quad = branch.childQuad(point);
        node = branch.child(quad);
      } else {
        return null;
      } // Pass nodes and empty nodes have no points.
    }
  }

  /// This will locate the smallest non-empty node containing the given point.
  /// Returns this is the smallest non-empty node containing the given point.
  /// If no non-empty node could be found from this node then null is returned.
  QTNodeBoundaryBase nodeContaining(QTPoint point) {
    if (!rootBoundary.containsPoint(point)) return null;
    QTNode node = _root;
    for (;;) {
      if (node is BranchNode) {
        final BranchNode branch = node as BranchNode;
        final Quadrant quad = branch.childQuad(point);
        node = branch.child(quad);
        if (node is QTNodeEmptyImpl) return branch;
      } else if (node is QTNodeEmptyImpl) {
        return null;
      } else {
        return node;
      } // The pass or point node.
    }
  }

  /// Finds an edge node from this node for the given edge.
  /// Set [undirected] to true if the opposite edge may also be returned, false if not.
  QTEdgeNodeImpl findEdge(QTEdge edge, bool undirected) {
    final PointNode node = findPoint(edge.start);
    if (node == null) return null;
    QTEdgeNodeImpl result = node.findEdgeTo(edge.end);
    if ((result == null) && undirected) result = node.findEdgeFrom(edge.end);
    return result;
  }

  /// Finds the nearest point to the given point.
  /// [queryPoint] is the query point to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode findNearestPointToPoint(
    QTPoint queryPoint, {
    double cutoffDist2 = double.maxFinite,
    QTPointHandler handle,
  }) {
    PointNode result;
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        final PointNode point = node;
        final double dist2 = QTPointImpl.distance2(queryPoint, point);
        if (dist2 < cutoffDist2) {
          if ((handle == null) || handle.handle(point)) {
            result = point;
            // ignore: parameter_assignments
            cutoffDist2 = dist2;
          }
        }
      } else if (node is BranchNode) {
        final BranchNode branch = node;
        final double dist2 = branch.distance2(queryPoint);
        if (dist2 <= cutoffDist2) stack.pushChildren(branch);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Finds the nearest point to the given edge.
  /// [queryEdge] is the query edge to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode findNearestPointToEdge(QTEdge queryEdge, {double cutoffDist2 = double.maxFinite, QTPointHandler handle}) {
    PointNode result;
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        final double dist2 = QTEdgeImpl.distance2(queryEdge, node);
        if (dist2 < cutoffDist2) {
          if ((handle == null) || handle.handle(node)) {
            result = node;
            // ignore: parameter_assignments
            cutoffDist2 = dist2;
          }
        }
      } else if (node is BranchNode) {
        final int width = node.width;
        final int x = node.xmin + width ~/ 2;
        final int y = node.ymin + width ~/ 2;
        final double diagDist2 = 2.0 * width * width;
        final double dist2 = QTEdgeImpl.distance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Finds the point close to the given edge.
  /// [queryEdge] is the query edge to find a close point to.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode findClosePoint(QTEdge queryEdge, QTPointHandler handle) {
    if (QTEdgeImpl.degenerate(queryEdge)) return null;
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        final PointOnEdgeResult pnt = pointOnEdge(queryEdge, node);
        if (pnt.onEdge) {
          if ((handle == null) || handle.handle(node)) {
            return node;
          }
        }
      } else if (node is BranchNode) {
        final int width = node.width;
        final int x = node.xmin + width ~/ 2;
        final int y = node.ymin + width ~/ 2;
        final double diagDist2 = 2.0 * width * width;
        final double dist2 = QTEdgeImpl.distance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return null;
  }

  /// Returns the edge nearest to the given query point, which has been matched
  /// by the given matcher, and is within the given cutoff distance.
  /// [point] is the point to find the nearest edge to.
  /// [cutoffDist2] is the maximum distance squared edges may be
  /// away from the given point to be an eligible result.
  /// [handler] is the matcher to filter eligible edges, if null all edges are accepted.
  QTEdgeNodeImpl findNearestEdge(QTPoint point, {double cutoffDist2 = double.maxFinite, QTEdgeHandler handler}) {
    final NearestEdgeArgs args = NearestEdgeArgs(point, cutoffDist2, handler);
    args.run(_root);
    return args.result();
  }

  /// Returns the first left edge to the given query point.
  /// [point] is the point to find the first left edge from.
  /// [handle] is the matcher to filter eligible edges. If null all edges are accepted.
  QTEdgeNodeImpl firstLeftEdge(QTPoint point, {QTEdgeHandler handle}) {
    final FirstLeftEdgeArgs args = FirstLeftEdgeArgsImpl(point, handle);
    _root.firstLeftEdge(args);
    return args.result;
  }

  /// Handle all the edges to the left of the given point.
  /// [point] is the point to find the left edges from.
  /// [handle] is the handle to process all the edges with.
  bool foreachLeftEdge(QTPoint point, QTEdgeHandler handle) => _root.foreachLeftEdge(point, handle);

  /// Gets the first point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode firstPoint(QTBoundary boundary, QTPointHandler handle) {
    PointNode result;
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) return node;
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Gets the last point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode lastPoint(QTBoundary boundary, QTPointHandler handle) {
    PointNode result;
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) return node;
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) stack.pushReverseChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Handles each point node in the boundary.
  bool foreachPoint(QTPointHandler handle, [QTBoundary bounds]) => _root.foreachPoint(handle, bounds);

  /// Handles each edge node in the boundary.
  /// [handle] is the handler to run on each edge in the boundary.
  /// [bounds] is the boundary containing the edges to handle.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  bool foreachEdge(QTEdgeHandler handle, [QTBoundary bounds, bool exclusive = false]) =>
      _root.foreachEdge(handle, bounds, exclusive);

  /// Handles each node in the boundary.
  /// [handle] is the handler to run on each node in the boundary.
  /// [bounds] is the boundary containing the nodes to handle.
  /// Returns true if all nodes in the boundary were run, false if stopped.
  bool foreachNode(QTNodeHandler handle, [QTBoundary bounds]) => _root.foreachNode(handle, bounds);

  /// Calls given handle for the all the near points to the given point.
  /// [handle] is the handle to handle all near points with.
  /// [queryPoint] is the query point to find the points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled, false if the handled returned false and stopped early.
  bool forNearPointPoints(QTPointHandler handle, QTPoint queryPoint, double cutoffDist2) {
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        final double dist2 = QTPointImpl.distance2(queryPoint, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        final int width = node.width;
        final int x = node.xmin + width ~/ 2;
        final int y = node.ymin + width ~/ 2;
        final double diagDist2 = 2.0 * width * width;
        final double dist2 = QTPointImpl.distance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  /// Finds the near points to the given edge.
  /// [handle] is the callback to handle the near points.
  /// [queryEdge] is the query edge to find all points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forNearEdgePoints(QTPointHandler handle, QTEdge queryEdge, double cutoffDist2) {
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        final double dist2 = QTEdgeImpl.distance2(queryEdge, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        final int width = node.width;
        final int x = node.xmin + width ~/ 2;
        final int y = node.ymin + width ~/ 2;
        final double diagDist2 = 2.0 * width * width;
        final double dist2 = QTEdgeImpl.distance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  /// Finds the close points to the given edge.
  /// [handle] is the callback to handle the close points.
  /// [queryEdge] is the query edge to find all points close to.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forClosePoints(QTPointHandler handle, QTEdge queryEdge) {
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        final PointOnEdgeResult pnt = pointOnEdge(queryEdge, node);
        if (pnt.onEdge) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        final int width = node.width;
        final int x = node.xmin + width ~/ 2;
        final int y = node.ymin + width ~/ 2;
        final double diagDist2 = 2.0 * width * width;
        final double dist2 = QTEdgeImpl.distance2(queryEdge, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  /// Calls given handle for all the edges near to the given query point.
  /// [handler] is the handle to handle all near edges with.
  /// [queryPoint] is the point to find the near edges to.
  /// [cutoffDist2] is the maximum distance for near edges.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forNearEdges(QTEdgeHandler handler, QTPoint queryPoint, double cutoffDist2) {
    final NodeStack stack = NodeStack();
    stack.push(_root);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        for (final QTEdgeNodeImpl edge in node.startEdges) {
          if (QTEdgeImpl.distance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (final QTEdgeNodeImpl edge in node.endEdges) {
          if (QTEdgeImpl.distance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (final QTEdgeNodeImpl edge in node.passEdges) {
          if (QTEdgeImpl.distance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is PassNode) {
        for (final QTEdgeNodeImpl edge in node.passEdges) {
          if (QTEdgeImpl.distance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is BranchNode) {
        final int width = node.width;
        final int x = node.xmin + width ~/ 2;
        final int y = node.ymin + width ~/ 2;
        final double diagDist2 = 2.0 * width * width;
        final double dist2 = QTPointImpl.distance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= cutoffDist2) stack.pushChildren(node);
      }
      // else, empty nodes have no edges.
    }
    return true;
  }

  /// Calls given handle for all the edges close to the given query point.
  /// [handler] is the handle to handle all close edges with.
  /// [queryPoint] is the point to find the close edges to.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forCloseEdges(QTEdgeHandler handler, QTPoint queryPoint) {
    final NodeStack stack = NodeStack();
    stack.push(_root);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        for (final QTEdgeNodeImpl edge in node.startEdges) {
          final PointOnEdgeResult pnt = pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (final QTEdgeNodeImpl edge in node.endEdges) {
          final PointOnEdgeResult pnt = pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (final QTEdgeNodeImpl edge in node.passEdges) {
          final PointOnEdgeResult pnt = pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is PassNode) {
        for (final QTEdgeNodeImpl edge in node.passEdges) {
          final PointOnEdgeResult pnt = pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is BranchNode) {
        final int width = node.width;
        final int x = node.xmin + width ~/ 2;
        final int y = node.ymin + width ~/ 2;
        final double diagDist2 = 2.0 * width * width;
        final double dist2 = QTPointImpl.distance2(queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) stack.pushChildren(node);
      }
      // else, empty nodes have no edges.
    }
    return true;
  }

  /// Finds the first intersection between the given line and lines in the tree which
  /// match the given handler. When multiple intersections exist, which intersection
  /// is discovered is not specific.
  /// [edge] is the edge to find intersections with.
  /// [hndl] is the edge handle to filter possible intersecting edges.
  /// Returns the first found intersection.
  IntersectionResult findFirstIntersection(QTEdge edge, QTEdgeHandler hndl) => _root.findFirstIntersection(edge, hndl);

  /// This handles all the intersections.
  /// [edge] is the edge to look for intersections with.
  /// [hndl] is the handler to match valid edges with.
  /// [intersections] is the set of intersections to add to.
  /// Returns true if a new intersection was found.
  bool findAllIntersections(QTEdge edge, QTEdgeHandler hndl, IntersectionSet intersections) {
    if (_edgeCount <= 0) return false;
    return (_root as QTNodeBoundaryBase).findAllIntersections(edge, hndl, intersections);
  }

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns the edge in the tree.
  QTEdgeNodeImpl insertEdge(QTEdge edge) => tryInsertEdge(edge).edge;

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns a pair containing the edge in the tree, and true if the edge is
  /// new or false if the edge already existed in the tree.
  InsertEdgeResult tryInsertEdge(QTEdge edge) {
    PointNodeImpl startNode;
    PointNodeImpl endNode;
    bool startNew;
    bool endNew;
    if ((edge.start is PointNode) && ((edge.start as PointNodeImpl).root == _root)) {
      startNode = edge.start;
      startNew = false;
    } else {
      final InsertPointResult pair = tryInsertPoint(edge.start);
      startNode = pair.point;
      startNew = pair.existed;
    }
    if ((edge.end is PointNode) && ((edge.end as PointNodeImpl).root == _root)) {
      endNode = edge.end;
      endNew = false;
    } else {
      final InsertPointResult pair = tryInsertPoint(edge.end);
      endNode = pair.point;
      endNew = pair.existed;
    }
    // Check for degenerate edges.
    if (startNode == endNode) return const InsertEdgeResult(null, false);
    // If both points already existed check if edge exists.
    if (!(startNew || endNew)) {
      final QTEdgeNodeImpl edge = startNode.findEdgeTo(endNode);
      if (edge != null) return InsertEdgeResult(edge, false);
    }
    // Insert new edge.
    final BranchNode ancestor = startNode.commonAncestor(endNode);
    if (ancestor == null) {
      // ignore: prefer_asserts_with_message
      assert(validate());
      // ignore: prefer_asserts_with_message
      assert(startNode.root == _root);
      // ignore: prefer_asserts_with_message
      assert(endNode.root == _root);
      // ignore: prefer_asserts_with_message
      assert(ancestor != null);
      return null;
    }
    final QTEdgeNodeImpl newEdge = QTEdgeNodeImpl._(startNode, endNode);
    final QTNode replacement = ancestor.insertEdge(newEdge);
    _reduceBranch(ancestor, replacement);
    _edgeCount++;
    return InsertEdgeResult(newEdge, true);
  }

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns the point node for the point inserted into the tree, or
  /// the point node which already existed.
  PointNode insertPoint(QTPoint point) => tryInsertPoint(point).point;

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns a pair containing the point node in the tree, and true if the
  /// point is new or false if the point already existed in the tree.
  InsertPointResult tryInsertPoint(QTPoint point) {
    final PointNode pntNode = PointNodeImpl(point.x, point.y);
    // Attempt to find the point first.
    final QTNodeBoundaryBase node = nodeContaining(pntNode);
    if (node != null) {
      // A node containing the point has been found.
      if (node is PointNodeImpl) {
        if (QTPointImpl.equals(node, pntNode)) {
          return InsertPointResult(node, true);
        }
      }
      final BranchNode parent = node.parent;
      if (parent != null) {
        final Quadrant quad = parent.childNodeQuad(node);
        QTNode replacement = node.insertPoint(pntNode);
        parent.setChild(quad, replacement);
        replacement = parent.reduce();
        _reduceBranch(parent, replacement);
      } else {
        final QTNode replacement = node.insertPoint(pntNode);
        _setRoot(replacement);
      }
    } else if (_root is QTNodeEmptyImpl) {
      // Tree is empty so create a new tree.
      const int initialTreeWidth = 256;
      int centerX = (pntNode.x ~/ initialTreeWidth) * initialTreeWidth;
      int centerY = (pntNode.y ~/ initialTreeWidth) * initialTreeWidth;
      if (pntNode.x < 0) centerX -= initialTreeWidth - 1;
      if (pntNode.y < 0) centerY -= initialTreeWidth - 1;
      _setRoot((_root as QTNodeEmptyImpl).addPoint(centerX, centerY, initialTreeWidth, pntNode));
    } else {
      // Point outside of tree, expand the tree.
      final QTNodeBoundaryBase root = _expandFootprint(_root as QTNodeBoundaryBase, pntNode);
      _setRoot(root.insertPoint(pntNode));
    }
    // ignore: prefer_asserts_with_message
    assert(_root is! QTNodeEmptyImpl);
    _pointCount++;
    _expandBoundingBox(pntNode);
    _reduceFootprint();
    return InsertPointResult(pntNode, false);
  }

  /// This removes an edge from the tree.
  /// [edge] is the edge to remove from the tree.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edge begins or ends at that point.
  void removeEdge(QTEdgeNodeImpl edge, bool trimTree) {
    final BranchNode ancestor = edge.startNode.commonAncestor(edge.endNode);
    // ignore: prefer_asserts_with_message
    assert(ancestor != null);
    final QTNode replacement = ancestor.removeEdge(edge, trimTree);
    _reduceBranch(ancestor, replacement);
    --_edgeCount;
    // If trimming the tree, see if the black nodes need to be deleted.
    if (trimTree) {
      if (edge.startNode.orphan) removePoint(edge.startNode);
      if (edge.endNode.orphan) removePoint(edge.endNode);
    }
  }

  /// This removes a point from the tree.
  /// [point] is the point to removed from the tree.
  void removePoint(PointNodeImpl point) {
    // Remove any edges on the point.
    final List<QTEdgeNodeImpl> startEdges = point.startEdges.toList();
    for (final QTEdgeNodeImpl edge in startEdges) {
      removeEdge(edge, false);
    }
    final List<QTEdgeNodeImpl> endEdges = point.endEdges.toList();
    for (final QTEdgeNodeImpl edge in endEdges) {
      removeEdge(edge, false);
    }
    // The point node must not have any edges beginning
    // nor ending on by the time is is removed.
    // ignore: prefer_asserts_with_message
    assert(point.orphan);
    // Remove the point from the tree.
    if (_root == point) {
      // If the only thing in the tree is the point, simply replace it
      // with an empty node.
      _root = QTNodeEmptyImpl.instance;
    } else {
      final BranchNode parent = point.parent;
      QTNode replacement = point.replacement;
      final Quadrant quad = parent.childNodeQuad(point);
      parent.setChild(quad, replacement);
      replacement = parent.reduce();
      _reduceBranch(parent, replacement);
      _reduceFootprint();
    }
    --_pointCount;
    _collapseBoundingBox(point);
  }

  /// Validates this quad-tree.
  /// [sout] is the output to write errors to.
  /// [format] is the format used for printing, null to use default.
  /// Returns true if valid, false if invalid.
  bool validate([StringBuffer sout, QTFormatter format]) {
    bool result = true;
    bool toConsole = false;
    if (sout == null) {
      // ignore: parameter_assignments
      sout = StringBuffer();
      toConsole = true;
    }
    final _QTPointHandlerValidateHandlerImpl vHndl = _QTPointHandlerValidateHandlerImpl();
    foreachPoint(vHndl);
    if (_pointCount != vHndl.pointCount) {
      sout.write("Error: The point count should have been ");
      sout.write(vHndl.pointCount);
      sout.write(" but it was ");
      sout.write(_pointCount);
      sout.write(".\n");
      result = false;
    }
    if (_edgeCount != vHndl.edgeCount) {
      sout.write("Error: The edge count should have been ");
      sout.write(vHndl.edgeCount);
      sout.write(" but it was ");
      sout.write(_edgeCount);
      sout.write(".\n");
      result = false;
    }
    vHndl.bounds ??= QTBoundaryImpl(0, 0, 0, 0);
    if (!QTBoundaryImpl.equals(_boundary, vHndl.bounds)) {
      sout.write("Error: The data boundary should have been ");
      sout.write(vHndl.bounds.toString());
      sout.write(" but it was ");
      sout.write(_boundary.toString());
      sout.write(".\n");
      result = false;
    }
    if (_root is! QTNodeEmptyImpl) {
      final QTNodeBoundaryBase root = _root as QTNodeBoundaryBase;
      if (root.parent != null) {
        sout.write("Error: The root node's parent should be null but it is ");
        root.parent.toBuffer(sout, format: format);
        sout.write(".\n");
        result = false;
      }
    }
    if (!_root.validate(sout, format, true)) result = false;
    if (toConsole && sout.isNotEmpty) {
      print(sout.toString());
    }
    return result;
  }

  /// Formats the quad-tree into a string.
  /// [sout] is the output to write the formatted string to.
  /// [indent] is the indent for this quad-tree.
  /// [contained] indicates this node is part of another output.
  /// [last] indicates this is the last output of the parent.
  /// [format] is the format used for printing, null to use default.
  void toBuffer(StringBuffer sout, {String indent = "", bool contained = false, bool last = true, QTFormatter format}) {
    if (contained) {
      sout.write(
        () {
          if (last) {
            return StringParts.Last;
          } else {
            return StringParts.Child;
          }
        }(),
      );
    }
    sout.write("Tree:");
    final String childIndent = indent +
        (() {
          if (contained && !last) {
            return StringParts.Bar;
          } else {
            return StringParts.Space;
          }
        }());
    sout.write(StringParts.Sep);
    sout.write(indent);
    sout.write(StringParts.Child);
    sout.write("Boundary: ");
    if (format == null) {
      sout.write(_boundary.toString());
    } else {
      sout.write(format.toBoundaryString(_boundary));
    }
    sout.write(StringParts.Sep);
    sout.write(indent);
    sout.write(StringParts.Child);
    sout.write("Points: ");
    sout.write(_pointCount);
    sout.write(StringParts.Sep);
    sout.write(indent);
    sout.write(StringParts.Child);
    sout.write("Edges: ");
    sout.write(_edgeCount);
    sout.write(StringParts.Sep);
    sout.write(indent);
    _root.toBuffer(sout, indent: childIndent, children: true, contained: true, format: format);
  }

  /// Gets the string for this quad-tree.
  @override
  String toString() {
    final StringBuffer sout = StringBuffer();
    toBuffer(sout);
    return sout.toString();
  }

  /// Gets the string for the points and edges of the quad-tree.
  String toBasicString() {
    final StringBuffer soutPoints = StringBuffer();
    soutPoints.write("Points:");
    soutPoints.write(StringParts.Sep);
    final StringBuffer soutEdges = StringBuffer();
    soutEdges.write("Edges:");
    soutEdges.write(StringParts.Sep);
    foreachPoint(_QTPointHandlerBasicStringHandlerImpl(soutPoints, soutEdges));
    return soutPoints.toString() + soutEdges.toString();
  }

  /// This reduces the root to the smallest branch needed.
  /// [node] is the original node to reduce.
  /// [replacement] is the node to replace the original node with.
  void _reduceBranch(QTNodeBoundaryBase node, QTNode replacement) {
    while (replacement != node) {
      final BranchNode parent = node.parent;
      if (parent == null) {
        _setRoot(replacement);
        break;
      }
      final Quadrant quad = parent.childNodeQuad(node);
      parent.setChild(quad, replacement);
      // ignore: parameter_assignments
      node = parent;
      // ignore: parameter_assignments
      replacement = parent.reduce();
    }
  }

  /// This sets the root node of this tree.
  /// [node] is the node to set as the root.
  /// Returns true if root changed, false if no change.
  bool _setRoot(QTNode node) {
    // ignore: prefer_asserts_with_message
    assert(node != null);
    if (_root == node) return false;
    _root = node;
    if (_root is! QTNodeEmptyImpl) {
      (_root as QTNodeBoundaryBase).parent = null;
    }
    return true;
  }

  /// This expands the foot print of the tree to include the given point.
  /// [root] is the original root to expand.
  /// Returns the new expanded root.
  QTNodeBoundaryBase _expandFootprint(QTNodeBoundaryBase root, QTPoint point) {
    while (!root.containsPoint(point)) {
      final int xmin = root.xmin;
      final int ymin = root.ymin;
      final int width = root.width;
      final int half = width ~/ 2;
      final int oldCenterX = xmin + half;
      final int oldCenterY = ymin + half;
      int newXMin = xmin;
      int newYMin = ymin;
      Quadrant quad;
      if (point.y > oldCenterY) {
        if (point.x > oldCenterX) {
          // New node is in the 'NorthEast'.
          quad = Quadrant.SouthWest;
        } else {
          // New node is in the 'NorthWest'.
          newXMin = xmin - width;
          quad = Quadrant.SouthEast;
        }
      } else {
        if (point.x > oldCenterX) {
          // New node is in the 'SouthEast'.
          newYMin = ymin - width;
          quad = Quadrant.NorthWest;
        } else {
          // New node is in the 'SouthWest'.
          newXMin = xmin - width;
          newYMin = ymin - width;
          quad = Quadrant.NorthEast;
        }
      }
      final BranchNode newRoot = BranchNode();
      newRoot.setLocation(newXMin, newYMin, width * 2);
      newRoot.setChild(quad, root);
      final QTNode replacement = newRoot.reduce();
      // ignore: prefer_asserts_with_message
      assert(replacement is! QTNodeEmptyImpl);
      // ignore: parameter_assignments
      root = replacement as QTNodeBoundaryBase;
    }
    return root;
  }

  /// Expands the tree's boundary to include the given point.
  void _expandBoundingBox(QTPoint point) {
    if (_pointCount <= 1) {
      _boundary = QTBoundaryImpl(point.x, point.y, point.x, point.y);
    } else {
      _boundary = QTBoundaryImpl.expand(_boundary, point);
    }
  }

  /// This reduces the footprint to the smallest root needed.
  void _reduceFootprint() {
    while ((_root != null) && (_root is BranchNode)) {
      final BranchNode broot = _root as BranchNode;
      int emptyCount = 0;
      QTNode onlyChild;
      for (final Quadrant quad in Quadrant.All) {
        final QTNode child = broot.child(quad);
        if (child is QTNodeEmptyImpl) {
          emptyCount++;
        } else {
          onlyChild = child;
        }
      }
      if (emptyCount == 3) {
        _setRoot(onlyChild);
      } else {
        break;
      }
    }
  }

  /// This collapses the boundary with the given point which was just removed.
  /// [point] is the point which was removed.
  void _collapseBoundingBox(QTPoint point) {
    if (_pointCount <= 0) {
      _boundary = QTBoundaryImpl(0, 0, 0, 0);
    } else {
      if (_boundary.xmax <= point.x) {
        _boundary = QTBoundaryImpl(_boundary.xmin, _boundary.ymin, _determineEastSide(_boundary.xmin), _boundary.ymax);
      }
      if (_boundary.xmin >= point.x) {
        _boundary = QTBoundaryImpl(_determineWestSide(_boundary.xmax), _boundary.ymin, _boundary.xmax, _boundary.ymax);
      }
      if (_boundary.ymax <= point.y) {
        _boundary = QTBoundaryImpl(_boundary.xmin, _boundary.ymin, _boundary.xmax, _determineNorthSide(_boundary.ymin));
      }
      if (_boundary.ymin >= point.y) {
        _boundary = QTBoundaryImpl(_boundary.xmax, _boundary.ymax, _boundary.xmin, _determineSouthSide(_boundary.ymax));
      }
    }
  }

  /// This finds the north side in the tree.
  /// Return is the value of the north side for the given direction.
  int _determineNorthSide(int value) {
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        // ignore: parameter_assignments
        if (value < node.y) {
          // ignore: parameter_assignments
          value = node.y;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.ymax) stack.pushAll([node.sw, node.se, node.nw, node.ne]);
      }
    }
    return value;
  }

  /// This finds the east side in the tree.
  /// Returns the value of the east side for the given direction.
  int _determineEastSide(int value) {
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        if (value < node.x) {
          // ignore: parameter_assignments
          value = node.x;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.xmax) stack.pushAll([node.sw, node.nw, node.se, node.ne]);
      }
    }
    return value;
  }

  /// This finds the south side in the tree.
  /// Returns the value of the south side for the given direction.
  int _determineSouthSide(int value) {
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        if (value > node.y) {
          // ignore: parameter_assignments
          value = node.y;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.ymin) stack.pushAll([node.nw, node.ne, node.sw, node.se]);
      }
    }
    return value;
  }

  /// This finds the west side in the tree.
  /// Returns the value of the west side for the given direction.
  int _determineWestSide(int value) {
    final NodeStack stack = NodeStack([_root]);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        if (value > node.x) {
          // ignore: parameter_assignments
          value = node.x;
        }
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.xmin) stack.pushAll([node.se, node.ne, node.sw, node.nw]);
      }
    }
    return value;
  }
}

/// The set of string parts used when formatting.
class StringParts {
  /// The separator between lines of the tree output.
  static const String Sep = "\n";

  /// The indent part of the last child.
  static const String Last = "'-";

  /// The indent part of a child which is not the last child.
  static const String Child = "|-";

  /// The space indent for a line in the tree output.
  static const String Space = "  ";

  /// The continuing indent for a line in the tree output.
  static const String Bar = "| ";

  /// Keep this class from being constructed.
  StringParts._();
}

/// The child quadrant.
class Quadrant {
  /// Indicates the minimum X and maximum Y child.
  static final Quadrant NorthWest = Quadrant._(0, "NorthWest");

  /// Indicates the maximum X and minimum Y child.
  static final Quadrant SouthWest = Quadrant._(1, "SouthWest");

  /// Indicates the minimum X and maximum Y child.
  static final Quadrant NorthEast = Quadrant._(2, "NorthEast");

  /// Indicates the maximum X and minimum Y child.
  static final Quadrant SouthEast = Quadrant._(3, "SouthEast");

  /// Gets a list of all quadrants.
  static List<Quadrant> get All => [NorthWest, SouthEast, NorthEast, SouthWest];

  /// The value of the quadrant.
  final int value;

  /// The name of the quadrant.
  final String _name;

  /// Creates a new quadrant.
  Quadrant._(
    final this.value,
    final this._name,
  );

  /// Checks if this Quadrant is equal to the given [other] Quadrant.
  @override
  bool operator ==(
    final Object other,
  ) =>
      other is Quadrant && value == other.value;

  @override
  int get hashCode => value.hashCode;

  /// Gets the name of the quadrant.
  @override
  String toString() => _name;
}

/// A vector of point nodes which can represent
/// a polygon, poly-line, or point stack.
class PointNodeVector {
  /// The list of nodes in this vector.
  List<PointNode> _list;

  /// Creates a new point node vector.
  PointNodeVector() {
    _list = <PointNode>[];
  }

  /// Gets the internal list of nodes.
  List<PointNode> get nodes => _list;

  /// Gets the edge between the point at the given index and the next index.
  QTEdgeImpl edge(int index) {
    final PointNode startNode = _list[index];
    final PointNode endNode = _list[(index + 1) % _list.length];
    return QTEdgeImpl(startNode, endNode);
  }

  /// Reverses the location of all the points in the vector.
  void reverse() {
    for (int i = 0, j = _list.length - 1; i < j; ++i, --j) {
      final PointNode temp = _list[i];
      _list[i] = _list[j];
      _list[j] = temp;
    }
  }

  /// Calculates the area of the polygon in the vector.
  QTEdgeHandlerAreaAccumulatorImpl get area {
    final QTEdgeHandlerAreaAccumulatorImpl area = QTEdgeHandlerAreaAccumulatorImpl();
    PointNode endNode = _list[0];
    for (int i = _list.length - 1; i >= 0; --i) {
      final PointNode startNode = _list[i];
      area.handle(QTEdgeImpl(startNode, endNode));
      endNode = startNode;
    }
    return area;
  }

  /// Calculates the boundary of all the points in the vertex.
  QTBoundaryImpl get bounds {
    QTBoundaryImpl bounds;
    for (int i = _list.length - 1; i >= 0; --i) {
      bounds = QTBoundaryImpl.expand(bounds, _list[i]);
    }
    return bounds;
  }

  /// Converts the vertex into a set.
  Set<PointNode> toSet() {
    final Set<PointNode> newSet = <PointNode>{};
    for (int i = _list.length - 1; i >= 0; --i) {
      newSet.add(_list[i]);
    }
    return newSet;
  }
}

/// A stack of nodes.
class NodeStack {
  /// The internal stack of nodes.
  List<QTNode> _stack;

  /// Creates a new stack.
  /// The initial sets of [nodes] is pushed in order.
  NodeStack([List<QTNode> nodes]) {
    _stack = <QTNode>[];
    if (nodes != null) {
      // ignore: prefer_foreach
      for (final QTNode node in nodes) {
        push(node);
      }
    }
  }

  /// Indicates if the stask is empty.
  bool get isEmpty => _stack.isEmpty;

  /// Pops the the top node off the stack.
  QTNode get pop => _stack.removeLast();

  /// Pushes the given node onto the top of the stack.
  void push(QTNode node) => _stack.add(node);

  /// Pushes a set of nodes onto the stack.
  void pushAll(List<QTNode> nodes) {
    // ignore: prefer_foreach
    for (final QTNode node in nodes) {
      push(node);
    }
  }

  /// Pushes the children of the given branch onto this stack.
  void pushChildren(BranchNode node) {
    // Push in reverse order from typical searches so that they
    // are processed in the order: NE, NW, SE, then SW.
    push(node.sw);
    push(node.se);
    push(node.nw);
    push(node.ne);
  }

  /// Pushes the children of the given branch onto this stack in reverse order.
  void pushReverseChildren(BranchNode node) {
    // Push in normal order from typical searches so that they
    // are processed in the order: SW, SE, NW, then NE.
    push(node.ne);
    push(node.nw);
    push(node.se);
    push(node.sw);
  }
}

/// The nearest edge arguments to handle multiple returns
/// objects for determining the nearest edge to a point.
class NearestEdgeArgs {
  /// The query point to find the nearest line to.
  final QTPoint _queryPoint;

  /// The line matcher to filter lines with.
  final QTEdgeHandler _handle;

  /// The maximum allowable distance squared to the result.
  double _cutoffDist2;

  /// The currently found closest edge. Null if a point has been found closer.
  QTEdgeNodeImpl _resultEdge;

  /// The node if the nearest part of the edge is the point.
  /// Null if an edge has been found closer.
  PointNode _resultPoint;

  /// Creates a new nearest edge arguments.
  /// [_queryPoint] is the query point to find an edge nearest to.
  /// [_cutoffDist2] is the maximum allowable distance squared to the nearest edge.
  /// The [_handle] is the filter acceptable edges with, or null to not filter.
  NearestEdgeArgs(this._queryPoint, this._cutoffDist2, this._handle) {
    _resultEdge = null;
    _resultPoint = null;
  }

  /// Runs this node and all children nodes through this search.
  void run(QTNode rootNode) {
    final NodeStack stack = NodeStack();
    stack.push(rootNode);
    while (!stack.isEmpty) {
      final QTNode node = stack.pop;
      if (node is PointNode) {
        // ignore: prefer_foreach
        for (final QTEdgeNodeImpl edge in node.startEdges) {
          _checkEdge(edge);
        }
        // ignore: prefer_foreach
        for (final QTEdgeNodeImpl edge in node.endEdges) {
          _checkEdge(edge);
        }
        // ignore: prefer_foreach
        for (final QTEdgeNodeImpl edge in node.passEdges) {
          _checkEdge(edge);
        }
      } else if (node is PassNode) {
        // ignore: prefer_foreach
        for (final QTEdgeNodeImpl edge in node.passEdges) {
          _checkEdge(edge);
        }
      } else if (node is BranchNode) {
        final int width = node.width;
        final int x = node.xmin + width ~/ 2;
        final int y = node.ymin + width ~/ 2;
        final double diagDist2 = 2.0 * width * width;
        final double dist2 = QTPointImpl.distance2(_queryPoint, QTPointImpl(x, y)) - diagDist2;
        if (dist2 <= _cutoffDist2) {
          stack.pushChildren(node);
        }
      }
      // else, empty nodes have no edges.
    }
  }

  /// Gets the result from this search.
  QTEdgeNodeImpl result() {
    if (_resultPoint == null) return _resultEdge;
    return _resultPoint.nearEndEdge(_queryPoint);
  }

  /// Checks if the given edge is closer that last found edge.
  void _checkEdge(QTEdgeNodeImpl edge) {
    if (edge == null) return;
    if (edge == _resultEdge) return;
    if (_handle != null) {
      if (!_handle.handle(edge)) return;
    }
    // Determine how the point is relative to the edge.
    final PointOnEdgeResult result = pointOnEdge(edge, _queryPoint);
    switch (result.location) {
      case IntersectionLocation.InMiddle:
        _updateWithEdge(edge, result.closestOnEdge);
        break;
      case IntersectionLocation.BeforeStart:
        _updateWithPoint(edge.startNode);
        break;
      case IntersectionLocation.AtStart:
        _updateWithPoint(edge.startNode);
        break;
      case IntersectionLocation.PastEnd:
        _updateWithPoint(edge.endNode);
        break;
      case IntersectionLocation.AtEnd:
        _updateWithPoint(edge.endNode);
        break;
      case IntersectionLocation.None:
        break;
    }
  }

  /// Update with the edge with the middle of the edge the closest.
  void _updateWithEdge(QTEdgeNodeImpl edge, QTPoint closePoint) {
    final double dist2 = QTPointImpl.distance2(_queryPoint, closePoint);
    if (dist2 <= _cutoffDist2) {
      _resultEdge = edge;
      _resultPoint = null;
      _cutoffDist2 = dist2;
    }
  }

  /// Update with the point at the end of the edge.
  void _updateWithPoint(PointNode point) {
    final double dist2 = QTPointImpl.distance2(_queryPoint, point);
    if (dist2 <= _cutoffDist2) {
      // Do not set _resultEdge here, leave it as the previous value.
      _resultPoint = point;
      _cutoffDist2 = dist2;
    }
  }
}

/// The result from a point insertion into the tree.
class InsertPointResult {
  /// The inserted point.
  final PointNode point;

  /// True if the point existed, false if the point is new.
  final bool existed;

  /// Creates a new insert point result.
  const InsertPointResult(
    final this.point,
    final this.existed,
  );
}

/// The result from a edge insertion into the tree.
class InsertEdgeResult {
  /// The inserted edge.
  final QTEdgeNodeImpl edge;

  /// True if the edge existed, false if the edge is new.
  final bool existed;

  /// Creates a new insert edge result.
  const InsertEdgeResult(
    final this.edge,
    final this.existed,
  );
}

/// Roughly the distance to the corner of an unit square.
const double _distToCorner = 1.415;

/// Formats the edges into a string.
/// [contained] indicates this output is part of another part.
/// [last] indicate this is the last set in a list of parents.
void edgeNodesToBuffer(Set<QTEdgeNodeImpl> nodes, StringBuffer sout,
    {String indent = "", bool contained = false, bool last = true, QTFormatter format}) {
  final int count = nodes.length;
  int index = 0;
  for (final QTEdgeNodeImpl edge in nodes) {
    if (index > 0) {
      sout.write(StringParts.Sep);
      sout.write(indent);
    }
    index++;
    edge.toBuffer(sout, indent: indent, contained: contained, last: last && (index >= count), format: format);
  }
}
