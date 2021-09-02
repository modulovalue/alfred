import '../framework/mouse/mouse_handle_impl.dart';
import '../framework/plotter/plotter_impl.dart';
import 'quadtree/boundary/impl.dart';
import 'quadtree/boundary/interface.dart';
import 'quadtree/edge/interface.dart';
import 'quadtree/handler_edge/interface.dart';
import 'quadtree/handler_node/interface.dart';
import 'quadtree/handler_point/interface.dart';
import 'quadtree/node/boundary/impl_pass.dart';
import 'quadtree/node/branch/interface.dart';
import 'quadtree/node/node/impl_empty.dart';
import 'quadtree/node/node/interface.dart';
import 'quadtree/node/point/interface.dart';
import 'quadtree/point/interface.dart';
import 'quadtree/quadtree/impl.dart';

/// A plotter customized to work with quad-trees.
class QuadTreePlotter {
  final Plotter plotter;

  QuadTreePlotter() : plotter = makePlotter() {
    plotter.mouseHandles.add(makeMouseCoords(plotter));
  }

  /// Adds a quad-tree plotter item with the given tree.
  QuadTreeGroup addTree(
    final QuadTree tree, [
    final String label = "Tree",
  ]) {
    final item = makeQuadTreeGroup(tree, label);
    plotter.addItems([item.group]);
    return item;
  }

  /// Adds a point to the given point list.
  Points addPoint(
    final Points points,
    final QTPoint point,
  ) {
    points.add(
      [
        point.x.toDouble(),
        point.y.toDouble(),
      ],
    );
    return points;
  }

  /// Adds a set of points to the given point list.
  Points addPointSet(
    final Points points,
    final Set<PointNode> pointSet,
  ) {
    for (final point in pointSet) {
      points.add([point.x.toDouble(), point.y.toDouble()]);
    }
    return points;
  }

  /// Adds an edge to the given line list.
  Lines addLine(
    final Lines lines,
    final QTEdge edge,
  ) {
    lines.add(
      [
        edge.x1.toDouble(),
        edge.y1.toDouble(),
        edge.x2.toDouble(),
        edge.y2.toDouble(),
      ],
    );
    return lines;
  }

  /// Adds a boundary to the given rectangle list.
  Rectangles addBound(
    final Rectangles rects,
    final QTBoundaryImpl bound,
    final double inset,
  ) {
    final inset2 = 1.0 - inset * 2.0;
    rects.add([
      bound.xmin.toDouble() - inset,
      bound.ymin.toDouble() - inset,
      bound.width.toDouble() - inset2,
      bound.height.toDouble() - inset2
    ]);
    return rects;
  }
}

QuadTreeGroup makeQuadTreeGroup(
  final QuadTree tree, [
  final String label = "Tree",
  final bool enabled = true,
]) {
  final passRects = Rectangles()
    ..addColor(0.0, 0.0, 0.6)
    ..addFillColor(0.0, 0.0, 0.6, 0.3);
  final pointRects = Rectangles()
    ..addColor(0.0, 0.6, 0.2)
    ..addFillColor(0.0, 0.6, 0.2, 0.3);
  final emptyRects = Rectangles()
    ..addColor(0.8, 0.8, 0.0)
    ..addFillColor(0.8, 0.8, 0.0, 0.3);
  final branchRects = Rectangles()
    ..addColor(0.0, 0.8, 0.0)
    ..addFillColor(0.0, 0.4, 0.8, 0.3);
  final edges = Lines()
    ..addColor(0.0, 0.0, 0.0)
    ..addDirected(true);
  final points = Points()
    ..addPointSize(3.0)
    ..addColor(0.0, 0.0, 0.0);
  final boundaryRect = Rectangles()
    ..addNoFillColor()
    ..addColor(1.0, 0.0, 0.0);
  final rootBoundaryRect = Rectangles()
    ..addNoFillColor()
    ..addColor(0.8, 0.8, 0.0);
  final group = Group(label, enabled);
  final item = QuadTreeGroup._(
    group: group,
    tree: tree,
    rootBoundaryRect: rootBoundaryRect,
    rootBoundaryGroup: group.addGroup("Boundary", [rootBoundaryRect]),
    passRects: passRects,
    pointRectsGroup: group.addGroup("Pass Nodes", [passRects]),
    pointRects: pointRects,
    passRectsGroup: group.addGroup("Point Nodes", [pointRects]),
    boundaryRect: boundaryRect,
    boundaryGroup: group.addGroup("Boundary", [boundaryRect]),
    emptyRects: emptyRects,
    emptyRectsGroup: group.addGroup("Empty Nodes", [emptyRects])..enabled = false,
    branchRects: branchRects,
    branchRectsGroup: group.addGroup("Branch Nodes", [branchRects])..enabled = false,
    edges: edges,
    edgesGroup: group.addGroup("Lines", [edges]),
    points: points,
    pointsGroup: group.addGroup("Points", [points]),
  );
  item.updateTree();
  return item;
}

/// The quad-tree plotter group for rendering a quad-tree parts
class QuadTreeGroup {
  final Group group;
  final QuadTree tree;
  final Rectangles passRects;
  final Group passRectsGroup;
  final Rectangles pointRects;
  final Group pointRectsGroup;
  final Rectangles emptyRects;
  final Group emptyRectsGroup;
  final Rectangles branchRects;
  final Group branchRectsGroup;
  final Lines edges;
  final Group edgesGroup;
  final Points points;
  final Group pointsGroup;
  final Rectangles boundaryRect;
  final Group boundaryGroup;
  final Rectangles rootBoundaryRect;
  final Group rootBoundaryGroup;

  const QuadTreeGroup._({
    required final this.tree,
    required final this.passRects,
    required final this.passRectsGroup,
    required final this.pointRects,
    required final this.pointRectsGroup,
    required final this.emptyRects,
    required final this.emptyRectsGroup,
    required final this.branchRects,
    required final this.branchRectsGroup,
    required final this.edges,
    required final this.edgesGroup,
    required final this.points,
    required final this.pointsGroup,
    required final this.boundaryRect,
    required final this.boundaryGroup,
    required final this.rootBoundaryRect,
    required final this.rootBoundaryGroup,
    required final this.group,
  });

  /// Indicates if pass nodes should be shown or not.
  set showPassNodes(
    final bool value,
  ) =>
      passRectsGroup.enabled = value;

  bool get showPassNodes => passRectsGroup.enabled;

  /// Indicates if point nodes should be shown or not.
  set showPointNodes(
    final bool value,
  ) =>
      pointRectsGroup.enabled = value;

  bool get showPointNodes => pointRectsGroup.enabled;

  /// Indicates if empty nodes should be shown or not.
  set showEmptyNodes(
    final bool value,
  ) =>
      emptyRectsGroup.enabled = value;

  bool get showEmptyNodes => emptyRectsGroup.enabled;

  /// Indicates if branch nodes should be shown or not.
  set showBranchNodes(
    final bool value,
  ) =>
      branchRectsGroup.enabled = value;

  bool get showBranchNodes => branchRectsGroup.enabled;

  /// Indicates if edges should be shown or not.
  set showEdges(
    final bool value,
  ) =>
      edgesGroup.enabled = value;

  bool get showEdges => edgesGroup.enabled;

  /// Indicates if points should be shown or not.
  set showPoints(
    final bool value,
  ) =>
      pointsGroup.enabled = value;

  bool get showPoints => pointsGroup.enabled;

  /// Indicates if the data boundaries should be shown or not.
  set showBoundary(
    final bool value,
  ) =>
      boundaryGroup.enabled = value;

  bool get showBoundary => boundaryGroup.enabled;

  /// Indicates if the root boundaries should be shown or not.
  set showRootBoundary(
    final bool value,
  ) =>
      rootBoundaryGroup.enabled = value;

  bool get showRootBoundary => rootBoundaryGroup.enabled;

  /// Adds a point to the given point list.
  Points addPoint(
    final Points points,
    final QTPoint point,
  ) {
    points.add([point.x.toDouble(), point.y.toDouble()]);
    return points;
  }

  /// Adds a set of points to the given point list.
  Points addPointSet(
    final Points points,
    final Set<PointNode> pointSet,
  ) {
    for (final point in pointSet) {
      points.add([point.x.toDouble(), point.y.toDouble()]);
    }
    return points;
  }

  /// Adds an edge to the given line list.
  Lines addLine(
    final Lines lines,
    final QTEdge edge,
  ) {
    lines.add([
      edge.x1.toDouble(),
      edge.y1.toDouble(),
      edge.x2.toDouble(),
      edge.y2.toDouble(),
    ]);
    return lines;
  }

  /// Adds a boundary to the given rectangle list.
  Rectangles addBound(
    final Rectangles rects,
    final QTBoundary bound,
    final double inset,
  ) {
    final inset2 = 1.0 - inset * 2.0;
    rects.add([
      bound.xmin.toDouble() - inset,
      bound.ymin.toDouble() - inset,
      bound.width.toDouble() - inset2,
      bound.height.toDouble() - inset2
    ]);
    return rects;
  }

  /// Updates a quad-tree to this plotter.
  void updateTree() {
    passRects.clear();
    pointRects.clear();
    emptyRects.clear();
    branchRects.clear();
    edges.clear();
    points.clear();
    boundaryRect.clear();
    rootBoundaryRect.clear();
    tree.foreachNode(
      _QuadTreePlotterNodeHandler(
        this,
        passRects,
        pointRects,
        emptyRects,
        branchRects,
      ),
    );
    tree.foreachEdge(
      _QuadTreePlotterEdgeHandler(
        this,
        edges,
      ),
    );
    tree.foreachPoint(
      _QuadTreePlotterPointHandler(
        this,
        points,
      ),
    );
    addBound(boundaryRect, tree.boundary, 0.0);
    addBound(rootBoundaryRect, tree.rootBoundary, 0.0);
  }
}

/// Handler for collecting all the nodes from the quadtree for plotting.
class _QuadTreePlotterNodeHandler extends QTNodeHandler {
  final double _pad;
  final QuadTreeGroup _plot;
  final Rectangles _passRects;
  final Rectangles _pointRects;
  final Rectangles _emptyRects;
  final Rectangles _branchRects;

  /// Creates a new quadtree plotter handler.
  _QuadTreePlotterNodeHandler(
    final this._plot,
    final this._passRects,
    final this._pointRects,
    final this._emptyRects,
    final this._branchRects, [
    final this._pad = 0.45,
  ]);

  /// Handles adding a new node into the plot.
  @override
  bool handle(
    final QTNode node,
  ) {
    // TODO have a matcher.
    if (node is PassNode) {
      _plot.addBound(_passRects, node.boundary, _pad);
    } else if (node is PointNode) {
      _plot.addBound(_pointRects, node.boundary, _pad);
    } else if (node is BranchNode) {
      for (final quad in Quadrant.values) {
        final child = node.child(quad);
        if (child is QTNodeEmptyImpl) {
          final x = node.childX(quad).toDouble();
          final y = node.childY(quad).toDouble();
          final width = node.width / 2 - 1.0 + _pad * 2.0;
          _emptyRects.add([x - _pad, y - _pad, width, width]);
        }
      }
      _plot.addBound(_branchRects, node.boundary, _pad);
    }
    return true;
  }
}

/// Handler for collecting all the edges from the quadtree for plotting.
class _QuadTreePlotterEdgeHandler extends QTEdgeHandler<Object?> {
  final QuadTreeGroup _plot;
  final Lines _edges;

  /// Creates a new quadtree plotter handler.
  _QuadTreePlotterEdgeHandler(
    final this._plot,
    final this._edges,
  );

  /// Handles adding a new edge into the plot.
  @override
  bool handle(
    final QTEdge edge,
  ) {
    _plot.addLine(_edges, edge);
    return true;
  }
}

/// Handler for collecting all the points from the quadtree for plotting.
class _QuadTreePlotterPointHandler extends QTPointHandler {
  final QuadTreeGroup _plot;
  final Points _points;

  /// Creates a new quadtree plotter handler.
  _QuadTreePlotterPointHandler(
    final this._plot,
    final this._points,
  );

  /// Handles adding a new point into the plot.
  @override
  bool handle(
    final PointNode point,
  ) {
    _plot.addPoint(_points, point);
    return true;
  }
}
