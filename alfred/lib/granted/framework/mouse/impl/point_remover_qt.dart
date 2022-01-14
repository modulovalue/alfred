import '../../../map/plotter.dart';
import '../../../map/quadtree/node/node/interface.dart';
import '../../../map/quadtree/node/point/interface.dart';
import '../../../map/quadtree/point/qt_point.dart';
import '../../../map/quadtree/quadtree/quadtree.dart';
import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/points.dart';
import '../mouse_handle.dart';

/// A mouse handler for removing points.
class PointRemover implements PlotterMouseHandle {
  final PlotterMouseButtonState _state;
  final QuadTreePlotter _plot;
  final QuadTreeGroup _plotItem;
  final QuadTree _tree;
  bool enabled;
  bool _mouseDown;
  final Points _tempPoint;

  /// Creates a new mouse handler for removing points.
  PointRemover(
    final this._tree,
    final this._plot,
    final this._plotItem,
    final this._state,
  )   : enabled = true,
        _mouseDown = false,
        _tempPoint = _plot.plotter.addPoints([])
          ..addPointSize(5.0)
          ..addColor(1.0, 0.0, 0.0);

  /// Finds the point which has its node under the mouse.
  QTNode? _findNearPoint(
    final PlotterMouseEvent e,
  ) {
    final trans = e.projection.mul(_plot.plotter.windowToViewTransformer);
    final msx = trans.untransformX(e.x).round();
    final msy = trans.untransformY(e.window.ymax - e.y).round();
    final node = _tree.nodeContaining(QTPointImpl(msx, msy));
    if (node is QTNode) {
      return node;
    } else {
      return null;
    }
  }

  /// handles mouse down.
  @override
  void mouseDown(
    final PlotterMouseEvent e,
  ) {
    if (enabled && e.state.equals(_state)) {
      _mouseDown = true;
      final node = _findNearPoint(e);
      final _node = node;
      if (_node != null) {
        _node as PointNode;
        _tempPoint.add([_node.point.x.toDouble(), _node.point.y.toDouble()]);
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
      _tempPoint.clear();
      final node = _findNearPoint(e);
      final _node = node;
      if (_node != null) {
        _node as PointNode;
        _tempPoint.add([_node.point.x.toDouble(), _node.point.y.toDouble()]);
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
      final node = _findNearPoint(e);
      final _node = node;
      if (_node != null) {
        _node as PointNode;
        _tree.removePoint(_node);
      }
      _mouseDown = false;
      _tempPoint.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}
