import '../../../map/maps/regions.dart';
import '../../../map/plotter.dart';
import '../../../map/quadtree/point/qt_point.dart';
import '../../attributes/impl/color.dart';
import '../../basic/color.dart';
import '../../basic/mouse_event.dart';
import '../../plotter_item/impl/lines.dart';
import '../../plotter_item/impl/points.dart';
import '../mouse_handle.dart';

/// A mouse handler for adding lines.
class RegionChecker implements PlotterMouseHandle {
  final QuadTreePlotter _plot;
  final Regions _regions;
  bool _enabled;
  final Lines _lines;
  final ColorAttr _pointColor;
  final Points _points;

  /// Creates a new mouse handler for adding lines.
  RegionChecker(
    final this._regions,
    final this._plot,
  )   : _enabled = true,
        _lines = _plot.plotter.addLines([])..addColor(1.0, 0.5, 0.5),
        _pointColor = ColorAttrImpl.rgb(0.0, 0.0, 0.0),
        _points = _plot.plotter.addPoints([]) {
    _points
      ..addPointSize(5.0)
      ..addAttr(_pointColor);
  }

  /// Indicates of the point adder tool is enabled or not.
  bool get enabled => _enabled;

  set enabled(
    final bool value,
  ) {
    _enabled = value;
    _points.clear();
    _lines.clear();
  }

  /// Translates the mouse location into the tree space based on the view.
  List<double> _transMouse(
    final PlotterMouseEvent e,
  ) {
    final trans = e.projection.mul(_plot.plotter.windowToViewTransformer);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  @override
  void mouseDown(
    final PlotterMouseEvent e,
  ) {
    if (_enabled) {
      final loc = _transMouse(e);
      final x = loc[0].round();
      final y = loc[1].round();
      final pnt = QTPointImpl(x, y);
      final region = _regions.quadTreeGetRegion(
        pnt: pnt,
      );
      print("[$x, $y] -> $region");
    }
  }

  @override
  void mouseMove(
    final PlotterMouseEvent e,
  ) {
    if (_enabled) {
      final loc = _transMouse(e);
      final x = loc[0].round();
      final y = loc[1].round();
      final pnt = QTPointImpl(x, y);
      _points.clear();
      final region = _regions.quadTreeGetRegion(
        pnt: pnt,
      );
      _pointColor.color = _regionColors[region];
      _points.add([x.toDouble(), y.toDouble()]);
      _lines.clear();
      final edge = _regions.tree.firstLeftEdge(pnt);
      if (edge != null) {
        _lines.add(
            [edge.start.x.toDouble(), edge.start.y.toDouble(), edge.end.x.toDouble(), edge.end.y.toDouble()]);
        final x = (pnt.y - edge.start.y) * edge.dx / edge.dy + edge.start.x;
        _lines.add([pnt.x.toDouble(), pnt.y.toDouble(), x, pnt.y.toDouble()]);
      }
      e.redraw = true;
    }
  }

  @override
  void mouseUp(
    final PlotterMouseEvent e,
  ) {}
}

/// The colors to draw for different regions
final _regionColors = [
  ColorImpl(0.0, 0.0, 0.0),
  ColorImpl(0.0, 0.0, 1.0),
  ColorImpl(0.0, 1.0, 1.0),
  ColorImpl(0.0, 1.0, 0.0),
  ColorImpl(1.0, 1.0, 0.0),
  ColorImpl(1.0, 0.0, 0.0),
  ColorImpl(1.0, 0.0, 1.0),
];
