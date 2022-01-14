import '../../../map/plotter.dart';
import '../../../map/quadtree/basic/qt_edge.dart';
import '../../../map/quadtree/point/qt_point.dart';
import '../../../map/quadtree/quadtree/quadtree.dart';
import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/lines.dart';
import '../mouse_handle.dart';

/// A mouse handler for adding lines.
class LineAdder implements PlotterMouseHandle {
  final PlotterMouseButtonState _state;
  final QuadTreePlotter _plot;
  final QuadTreeGroup _plotItem;
  final QuadTree _tree;
  bool enabled;
  bool _mouseDown;
  late double _startX;
  late double _startY;
  final Lines _tempLine;

  /// Creates a new mouse handler for adding lines.
  LineAdder(
    final this._tree,
    final this._plot,
    final this._plotItem,
    final this._state,
  )   : enabled = true,
        _mouseDown = false,
        _tempLine = _plot.plotter.addLines([])
          ..addPointSize(5.0)
          ..addDirected(true)
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
      _startX = loc[0].roundToDouble();
      _startY = loc[1].roundToDouble();
      _tempLine.add([_startX, _startY, _startX, _startY]);
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
      _tempLine.set(
        0,
        [
          _startX,
          _startY,
          loc[0].roundToDouble(),
          loc[1].roundToDouble(),
        ],
      );
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
      final pnt1 = QTPointImpl(
        _startX.round(),
        _startY.round(),
      );
      final pnt2 = QTPointImpl(
        loc[0].round(),
        loc[1].round(),
      );
      _tree.insertEdge(
        QTEdgeImpl(pnt1, pnt2, null),
        null,
      );
      _mouseDown = false;
      _tempLine.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}
