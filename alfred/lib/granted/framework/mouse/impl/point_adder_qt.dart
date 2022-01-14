import '../../../map/plotter.dart';
import '../../../map/quadtree/point/qt_point.dart';
import '../../../map/quadtree/quadtree/quadtree.dart';
import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/points.dart';
import '../mouse_handle.dart';

/// A mouse handler for adding points.
class PointAdder implements PlotterMouseHandle {
  final PlotterMouseButtonState _state;
  final QuadTreePlotter _plot;
  final QuadTreeGroup _plotItem;
  final QuadTree _tree;
  bool enabled;
  bool _mouseDown;
  final Points _tempPoint;

  /// Creates a new mouse handler for adding points.
  PointAdder(
    final this._tree,
    final this._plot,
    final this._plotItem,
    final this._state,
  )   : enabled = true,
        _mouseDown = false,
        _tempPoint = _plot.plotter.addPoints([])
          ..addPointSize(5.0)
          ..addColor(1.0, 0.0, 0.0);

  /// Translates the mouse location into the tree space based on the view.
  List<double> _transMouse(
    final PlotterMouseEvent e,
  ) {
    final trans = e.projection.mul(_plot.plotter.windowToViewTransformer);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  @override
  void mouseDown(
    final PlotterMouseEvent e,
  ) {
    if (enabled && e.state.equals(_state)) {
      _mouseDown = true;
      final loc = _transMouse(e);
      _tempPoint.add([loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  @override
  void mouseMove(
    final PlotterMouseEvent e,
  ) {
    if (_mouseDown) {
      final loc = _transMouse(e);
      _tempPoint.set(0, [loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(
    final PlotterMouseEvent e,
  ) {
    if (_mouseDown) {
      final loc = _transMouse(e);
      final msx = loc[0].round();
      final msy = loc[1].round();
      _tree.insertPoint(QTPointImpl(msx, msy));
      _mouseDown = false;
      _tempPoint.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}
