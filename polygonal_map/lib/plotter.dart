// @dart = 2.9
import 'dart:html' as html;

import 'package:plotter_dart/framework/mouse/mouse_handle_impl.dart';
import 'package:plotter_dart/framework/plotter/plotter_impl.dart';
import 'package:plotter_dart/impl/html_svg.dart';

import 'quadtree/boundary/boundary_impl.dart';
import 'quadtree/edge/edge.dart';
import 'quadtree/point/point.dart';
import 'quadtree/quadtree.dart' as qt;
import 'quadtree/quadtree_impl.dart' as qt;

/// A plotter customized to work with quad-trees.
class QuadTreePlotter {
  final Plotter plotter;

  QuadTreePlotter() : plotter = makePlotter() {
    plotter.mouseHandles.add(makeMouseCoords(plotter));
  }

  /// Shows a quad-tree in a plot panel.
  static PlotSvg Show(
    final qt.QuadTree tree,
    final html.DivElement div, {
    final bool showPassNodes = true,
    final bool showPointNodes = true,
    final bool showEmptyNodes = false,
    final bool showBranchNodes = false,
    final bool showEdges = true,
    final bool showPoints = true,
    final bool showBoundary = true,
    final bool showRootBoundary = true,
  }) {
    final plot = QuadTreePlotter();
    plot.addTree(tree)
      ..showPassNodes = showPassNodes
      ..showPointNodes = showPointNodes
      ..showEmptyNodes = showEmptyNodes
      ..showBranchNodes = showBranchNodes
      ..showEdges = showEdges
      ..showPoints = showPoints
      ..showBoundary = showBoundary
      ..showRootBoundary = showRootBoundary;
    plot.plotter.updateBounds();
    plot.plotter.focusOnData();
    return PlotSvg.fromElem(div, plot.plotter);
  }

  /// Adds a quad-tree plotter item with the given tree.
  QuadTree addTree(qt.QuadTree tree, [String label = "Tree"]) {
    final QuadTree item = QuadTree(tree, label);
    plotter.addItems([item]);
    return item;
  }

  /// Adds a point to the given point list.
  Points addPoint(Points points, QTPoint point) {
    if (points != null) {
      points.add([point.x.toDouble(), point.y.toDouble()]);
    }
    return points;
  }

  /// Adds a set of points to the given point list.
  Points addPointSet(Points points, Set<qt.PointNode> pointSet) {
    if (points != null) {
      for (final qt.PointNode point in pointSet) {
        points.add([point.x.toDouble(), point.y.toDouble()]);
      }
    }
    return points;
  }

  /// Adds an edge to the given line list.
  Lines addLine(Lines lines, QTEdge edge) {
    if (lines != null) {
      lines.add([edge.x1.toDouble(), edge.y1.toDouble(), edge.x2.toDouble(), edge.y2.toDouble()]);
    }
    return lines;
  }

  /// Adds a boundary to the given rectangle list.
  Rectangles addBound(
    final Rectangles rects,
    final QTBoundaryImpl bound,
    final double inset,
  ) {
    final double inset2 = 1.0 - inset * 2.0;
    rects.add([
      bound.xmin.toDouble() - inset,
      bound.ymin.toDouble() - inset,
      bound.width.toDouble() - inset2,
      bound.height.toDouble() - inset2
    ]);
    return rects;
  }
}

/// The quad-tree plotter group for rendering a quad-tree parts
class QuadTree extends Group {
  final qt.QuadTree _tree;
  Rectangles _passRects;
  Group _passRectsGroup;
  Rectangles _pointRects;
  Group _pointRectsGroup;
  Rectangles _emptyRects;
  Group _emptyRectsGroup;
  Rectangles _branchRects;
  Group _branchRectsGroup;
  Lines _edges;
  Group _edgesGroup;
  Points _points;
  Group _pointsGroup;
  Rectangles _boundaryRect;
  Group _boundaryGroup;
  Rectangles _rootBoundaryRect;
  Group _rootBoundaryGroup;

  /// Creates a new quad-tree plotter group.
  QuadTree(
    this._tree, [
    String label = "Tree",
    bool enabled = true,
  ]) : super(
          label,
          enabled,
        ) {
    _passRects = Rectangles();
    _passRects.addColor(0.0, 0.0, 0.6);
    _passRects.addFillColor(0.0, 0.0, 0.6, 0.3);
    _passRectsGroup = addGroup("Pass Nodes", [_passRects]);
    _pointRects = Rectangles();
    _pointRects.addColor(0.0, 0.6, 0.2);
    _pointRects.addFillColor(0.0, 0.6, 0.2, 0.3);
    _pointRectsGroup = addGroup("Point Nodes", [_pointRects]);
    _emptyRects = Rectangles();
    _emptyRects.addColor(0.8, 0.8, 0.0);
    _emptyRects.addFillColor(0.8, 0.8, 0.0, 0.3);
    _emptyRectsGroup = addGroup("Empty Nodes", [_emptyRects])..enabled = false;
    _branchRects = Rectangles();
    _branchRects.addColor(0.0, 0.8, 0.0);
    _branchRects.addFillColor(0.0, 0.4, 0.8, 0.3);
    _branchRectsGroup = addGroup("Branch Nodes", [_branchRects])..enabled = false;
    _edges = Lines();
    _edges.addColor(0.0, 0.0, 0.0);
    _edges.addDirected(true);
    _edgesGroup = addGroup("Lines", [_edges]);
    _points = Points();
    _points.addPointSize(3.0);
    _points.addColor(0.0, 0.0, 0.0);
    _pointsGroup = addGroup("Points", [_points]);
    _boundaryRect = Rectangles();
    _boundaryRect.addNoFillColor();
    _boundaryRect.addColor(1.0, 0.0, 0.0);
    _boundaryGroup = addGroup("Boundary", [_boundaryRect]);
    _rootBoundaryRect = Rectangles();
    _rootBoundaryRect.addNoFillColor();
    _rootBoundaryRect.addColor(0.8, 0.8, 0.0);
    _rootBoundaryGroup = addGroup("Boundary", [_rootBoundaryRect]);
    updateTree();
  }

  /// Indicates if pass nodes should be shown or not.
  set showPassNodes(bool value) => _passRectsGroup.enabled = value;

  bool get showPassNodes => _passRectsGroup.enabled;

  /// Indicates if point nodes should be shown or not.
  set showPointNodes(bool value) => _pointRectsGroup.enabled = value;

  bool get showPointNodes => _pointRectsGroup.enabled;

  /// Indicates if empty nodes should be shown or not.
  set showEmptyNodes(bool value) => _emptyRectsGroup.enabled = value;

  bool get showEmptyNodes => _emptyRectsGroup.enabled;

  /// Indicates if branch nodes should be shown or not.
  set showBranchNodes(bool value) => _branchRectsGroup.enabled = value;

  bool get showBranchNodes => _branchRectsGroup.enabled;

  /// Indicates if edges should be shown or not.
  set showEdges(bool value) => _edgesGroup.enabled = value;

  bool get showEdges => _edgesGroup.enabled;

  /// Indicates if points should be shown or not.
  set showPoints(bool value) => _pointsGroup.enabled = value;

  bool get showPoints => _pointsGroup.enabled;

  /// Indicates if the data boundaries should be shown or not.
  set showBoundary(bool value) => _boundaryGroup.enabled = value;

  bool get showBoundary => _boundaryGroup.enabled;

  /// Indicates if the root boundaries should be shown or not.
  set showRootBoundary(bool value) => _rootBoundaryGroup.enabled = value;

  bool get showRootBoundary => _rootBoundaryGroup.enabled;

  /// Adds a point to the given point list.
  Points addPoint(Points points, QTPoint point) {
    if (points != null) {
      points.add([point.x.toDouble(), point.y.toDouble()]);
    }
    return points;
  }

  /// Adds a set of points to the given point list.
  Points addPointSet(Points points, Set<qt.PointNode> pointSet) {
    if (points != null) {
      for (final qt.PointNode point in pointSet) {
        points.add([point.x.toDouble(), point.y.toDouble()]);
      }
    }
    return points;
  }

  /// Adds an edge to the given line list.
  Lines addLine(Lines lines, QTEdge edge) {
    if (lines != null) {
      lines.add([edge.x1.toDouble(), edge.y1.toDouble(), edge.x2.toDouble(), edge.y2.toDouble()]);
    }
    return lines;
  }

  /// Adds a boundary to the given rectangle list.
  Rectangles addBound(Rectangles rects, QTBoundaryImpl bound, double inset) {
    final double inset2 = 1.0 - inset * 2.0;
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
    _passRects.clear();
    _pointRects.clear();
    _emptyRects.clear();
    _branchRects.clear();
    _edges.clear();
    _points.clear();
    _boundaryRect.clear();
    _rootBoundaryRect.clear();
    if (_tree != null) {
      _tree.foreachNode(_quadTreePlotterNodeHandler(this, _passRects, _pointRects, _emptyRects, _branchRects));
      if (_edges != null) _tree.foreachEdge(_quadTreePlotterEdgeHandler(this, _edges));
      if (_points != null) _tree.foreachPoint(_quadTreePlotterPointHandler(this, _points));
    }
    addBound(_boundaryRect, _tree.boundary, 0.0);
    addBound(_rootBoundaryRect, _tree.rootBoundary, 0.0);
  }
}

/// Handler for collecting all the nodes from the quadtree for plotting.
class _quadTreePlotterNodeHandler extends qt.QTNodeHandler {
  final double _pad;
  final QuadTree _plot;
  final Rectangles _passRects;
  final Rectangles _pointRects;
  final Rectangles _emptyRects;
  final Rectangles _branchRects;

  /// Creates a new quadtree plotter handler.
  _quadTreePlotterNodeHandler(
    this._plot,
    this._passRects,
    this._pointRects,
    this._emptyRects,
    this._branchRects, [
    this._pad = 0.45,
  ]);

  /// Handles adding a new node into the plot.
  @override
  bool handle(qt.QTNode node) {
    if (node is qt.PassNode) {
      _plot.addBound(_passRects, node.boundary, _pad);
    } else if (node is qt.PointNodeImpl) {
      _plot.addBound(_pointRects, node.boundary, _pad);
    } else if (node is qt.BranchNode) {
      if (_emptyRects != null) {
        for (final qt.Quadrant quad in qt.Quadrant.All) {
          final qt.QTNode child = node.child(quad);
          if (child is qt.QTNodeEmptyImpl) {
            final double x = node.childX(quad).toDouble();
            final double y = node.childY(quad).toDouble();
            final double width = node.width / 2 - 1.0 + _pad * 2.0;
            _emptyRects.add([x - _pad, y - _pad, width, width]);
          }
        }
      }
      _plot.addBound(_branchRects, node.boundary, _pad);
    }
    return true;
  }
}

/// Handler for collecting all the edges from the quadtree for plotting.
class _quadTreePlotterEdgeHandler extends qt.QTEdgeHandler {
  final QuadTree _plot;
  final Lines _edges;

  /// Creates a new quadtree plotter handler.
  _quadTreePlotterEdgeHandler(this._plot, this._edges);

  /// Handles adding a new edge into the plot.
  @override
  bool handle(QTEdge edge) {
    _plot.addLine(_edges, edge);
    return true;
  }
}

/// Handler for collecting all the points from the quadtree for plotting.
class _quadTreePlotterPointHandler extends qt.QTPointHandler {
  final QuadTree _plot;
  final Points _points;

  /// Creates a new quadtree plotter handler.
  _quadTreePlotterPointHandler(this._plot, this._points);

  /// Handles adding a new point into the plot.
  @override
  bool handle(qt.PointNode point) {
    _plot.addPoint(_points, point);
    return true;
  }
}
