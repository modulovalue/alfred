import '../../../map/plotter.dart';
import '../../../map/quadtree/node/edge/interface.dart';
import '../../../map/quadtree/point/qt_point.dart';
import '../../../map/quadtree/quadtree/quadtree.dart';
import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/lines.dart';
import '../mouse_handle.dart';

/// A mouse handler for removing lines.
class LineRemover implements PlotterMouseHandle {
  final PlotterMouseButtonState _state;
  final QuadTreePlotter _plot;
  final QuadTreeGroup _plotItem;
  final QuadTree _tree;
  bool enabled;
  bool _mouseDown;
  final bool _trimTree;
  final Lines _tempLine;

  /// Creates a new mouse handler for removing lines.
  LineRemover(
    final this._tree,
    final this._plot,
    final this._plotItem,
    final this._state,
    final this._trimTree,
  )   : enabled = true,
        _mouseDown = false,
        _tempLine = _plot.plotter.addLines([])
          ..addPointSize(5.0)
          ..addDirected(true)
          ..addColor(1.0, 0.0, 0.0);

  /// Finds the nearest edge for a point under the mouse.
  QTEdgeNode? _findEdge(
    final PlotterMouseEvent e,
  ) {
    final trans = e.projection.mul(_plot.plotter.windowToViewTransformer);
    final x = trans.untransformX(e.x).round();
    final y = trans.untransformY(e.window.ymax - e.y).round();
    return _tree.findNearestEdge(QTPointImpl(x, y));
  }

  /// handles mouse down.
  @override
  void mouseDown(
    final PlotterMouseEvent e,
  ) {
    if (enabled && e.state.equals(_state)) {
      _mouseDown = true;
      final edge = _findEdge(e);
      if (edge != null) {
        _tempLine.add(
            [edge.start.x.toDouble(), edge.start.y.toDouble(), edge.end.x.toDouble(), edge.end.y.toDouble()]);
      }
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  @override
  void mouseMove(
    final PlotterMouseEvent e,
  ) {
    if (_mouseDown) {
      _tempLine.clear();
      final edge = _findEdge(e);
      if (edge != null) {
        _tempLine.add(
            [edge.start.x.toDouble(), edge.start.y.toDouble(), edge.end.x.toDouble(), edge.end.y.toDouble()]);
      }
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(
    final PlotterMouseEvent e,
  ) {
    if (_mouseDown) {
      final edge = _findEdge(e);
      if (edge != null) _tree.removeEdge(edge, _trimTree);
      _mouseDown = false;
      _tempLine.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}
