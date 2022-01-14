import '../../../map/maps/regions.dart';
import '../../../map/plotter.dart';
import '../../../map/quadtree/point/qt_point.dart';
import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/lines.dart';
import '../mouse_handle.dart';

/// A mouse handler for adding lines.
class PolygonAdder implements PlotterMouseHandle {
  final PlotterMouseButtonState _addPointState;
  final PlotterMouseButtonState _finishRegionState;
  final QuadTreePlotter _plot;
  final QuadTreeGroup _plotItem;
  final Regions _regions;
  bool _enabled;
  int regionId;
  bool _mouseDown;
  final List<QTPoint> _points;
  final Lines _tempLines;

  /// Creates a new mouse handler for adding lines.
  PolygonAdder(this._regions, this._plot, this._plotItem, this._addPointState, this._finishRegionState)
      : _enabled = true,
        regionId = 1,
        _mouseDown = false,
        _points = <QTPointImpl>[],
        _tempLines = _plot.plotter.addLines([])
          ..addPointSize(5.0)
          ..addDirected(true)
          ..addColor(1.0, 0.0, 0.0);

  /// Indicates of the point adder tool is enabled or not.
  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    reset();
  }

  /// Prints the region in the buffer.
  void _printRegion() {
    String result = "";
    bool first = true;
    for (final pnt in _points) {
      if (first) {
        result += "{";
        first = false;
      } else {
        result += ", ";
      }
      // ignore: use_string_buffers
      result += "[${pnt.x}, ${pnt.y}]";
    }
    print(result + "}");
  }

  /// Resets the currently being created polygon.
  void reset() {
    _points.clear();
    _tempLines.clear();
  }

  /// Finished and inserts a region.
  void finishRegion() {
    if (_points.isNotEmpty) {
      _printRegion();
      _regions.quadTreeAddRegion(
        regionId: regionId,
        pnts: _points,
      );
    }
    _plotItem.updateTree();
    _points.clear();
    _tempLines.clear();
  }

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
    if (_enabled) {
      if (e.state.equals(_finishRegionState)) {
        finishRegion();
        e.redraw = true;
      } else if (e.state.equals(_addPointState)) {
        _mouseDown = true;
        final loc = _transMouse(e);
        final x = loc[0].roundToDouble();
        final y = loc[1].roundToDouble();
        if (_tempLines.count > 0) {
          final last = _tempLines.get(_tempLines.count - 1, 1);
          _tempLines.add([last[2], last[3], x, y]);
        } else {
          _tempLines.add([x, y, x, y]);
          _points.add(QTPointImpl(x.round(), y.round()));
        }
        e.redraw = true;
      }
    }
  }

  /// handles mouse moved.
  @override
  void mouseMove(PlotterMouseEvent e) {
    if (_mouseDown) {
      final loc = _transMouse(e);
      final last = _tempLines.get(_tempLines.count - 1, 1);
      _tempLines
          .set(_tempLines.count - 1, [last[0], last[1], loc[0].roundToDouble(), loc[1].roundToDouble()]);
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
      final last = _tempLines.get(_tempLines.count - 1, 1);
      _tempLines
          .set(_tempLines.count - 1, [last[0], last[1], loc[0].roundToDouble(), loc[1].roundToDouble()]);
      if (_points.isNotEmpty) {
        final lastPnt = _points[_points.length - 1];
        final x = loc[0].round();
        final y = loc[1].round();
        if ((lastPnt.x != x) || (lastPnt.y != y)) {
          _points.add(QTPointImpl(x, y));
        }
      } else {
        _points.add(QTPointImpl(loc[0].round(), loc[1].round()));
      }
      e.redraw = true;
      _mouseDown = false;
    }
  }
}
