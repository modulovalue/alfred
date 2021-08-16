import 'dart:html' as html;

import 'package:alfred/granted/framework/events/events.dart';
import 'package:alfred/granted/framework/events/events_impl.dart';
import 'package:alfred/granted/framework/mouse/mouse_handle.dart';
import 'package:alfred/granted/framework/mouse/mouse_handle_impl.dart';
import 'package:alfred/granted/framework/plot/impl/html/svg.dart';
import 'package:alfred/granted/framework/plotter/plotter_impl.dart';
import 'package:alfred/granted/framework/plotter_item/plotter_item.dart';
import 'package:alfred/granted/framework/plotter_item/plotter_item_impl.dart';
import 'package:alfred/granted/framework/primitives/primitives.dart';
import 'package:alfred/granted/framework/primitives/primitives_impl.dart';
import 'package:alfred/granted/map/maps/regions.dart';
import 'package:alfred/granted/map/plotter.dart' as qt_plot;
import 'package:alfred/granted/map/quadtree/point/impl.dart';

void main() {
  html.document.title = "Points & Lines";
  final body = html.document.body!;
  final menu = html.DivElement();
  menu.className = "menu";
  body.append(menu);
  final plotElem = html.DivElement();
  plotElem.className = "plot_target";
  body.append(plotElem);
  final plot = qt_plot.QuadTreePlotter();
  final svgPlot = PlotHtmlSvg(plotElem, plot.plotter);
  final dvr = Driver(svgPlot, plot);
  addMenuView(menu, dvr);
  addMenuTools(menu, dvr);
}

void addMenuView(html.DivElement menu, Driver dvr) {
  final dropDown = html.DivElement()..className = "dropdown";
  menu.append(dropDown);
  final text = html.DivElement()..text = "View";
  dropDown.append(text);
  final items = html.DivElement()..className = "dropdown-content";
  dropDown.append(items);
  addMenuItem(items, "Center View", dvr.centerView);
  addMenuItem(items, "Points", dvr.points);
  addMenuItem(items, "Lines", dvr.lines);
  addMenuItem(items, "Empty Nodes", dvr.emptyNodes);
  addMenuItem(items, "Branch Nodes", dvr.branchNodes);
  addMenuItem(items, "Pass Nodes", dvr.passNodes);
  addMenuItem(items, "Point Nodes", dvr.pointNodes);
  addMenuItem(items, "Boundary", dvr.boundary);
  addMenuItem(items, "Root Boundary", dvr.rootBoundary);
}

void addMenuTools(html.DivElement menu, Driver dvr) {
  final dropDown = html.DivElement()..className = "dropdown";
  menu.append(dropDown);
  final text = html.DivElement()..text = "Tools";
  dropDown.append(text);
  final items = html.DivElement()..className = "dropdown-content";
  dropDown.append(items);
  addMenuItem(items, "Pan View", dvr.panView);
  addMenuItem(items, "Add Polygon 1", dvr.addPolygon1);
  addMenuItem(items, "Add Polygon 2", dvr.addPolygon2);
  addMenuItem(items, "Add Polygon 3", dvr.addPolygon3);
  addMenuItem(items, "Add Polygon 4", dvr.addPolygon4);
  addMenuItem(items, "Add Polygon 5", dvr.addPolygon5);
  addMenuItem(items, "Check Region", dvr.checkRegion);
  addMenuItem(items, "Validate", dvr.validate);
  addMenuItem(items, "Print Tree", dvr.printTree);
  addMenuItem(items, "Clear All", dvr.clearAll);
}

void addMenuItem(html.DivElement dropDownItems, String text, BoolValue value) {
  final item = html.DivElement()
    ..text = text
    ..className = (() {
      if (value.value) {
        return "dropdown-item-active";
      } else {
        return "dropdown-item-inactive";
      }
    }())
    ..onClick.listen(
      (_) {
        value.onClick();
      },
    );
  value.onChange.add(
    (final value) => item.className = () {
      if (value) {
        return "dropdown-item-active";
      } else {
        return "dropdown-item-inactive";
      }
    }(),
  );
  dropDownItems.append(item);
}

/// The signature for handling changes to the boolean value.
typedef OnBoolValueChange = void Function(bool newValue);

/// Boolean value handler for keeping track of changes in the UI and driver.
/// Kind of like a mini-store variable.
class BoolValue {
  final bool _toggle;
  bool _value;
  final List<OnBoolValueChange> _changed;

  /// Creates a new boolean value.
  /// [toggle] indicates if the value will changed to true when value is false
  /// and false when the value is true or if the value should only be set to true on click.
  BoolValue(bool toggle, [bool value = false])
      : _toggle = toggle,
        _value = value,
        _changed = <OnBoolValueChange>[];

  /// Handles the value being clicked on.
  void onClick() {
    if (_toggle) {
      value = !_value;
    } else {
      value = true;
    }
  }

  /// Handles the value being set.
  set value(bool value) {
    if (_value != value) {
      _value = value;
      for (final hndl in _changed) {
        hndl(_value);
      }
    }
  }

  /// Gets the currently set value.
  bool get value => _value;

  /// Gets the list of listeners who are watching for changes to this value.
  List<OnBoolValueChange> get onChange => _changed;
}

enum Tool { None, PanView, AddPolygon, CheckRegion }

class Driver {
  final PlotHtmlSvg _svgPlot;
  final qt_plot.QuadTreePlotter _plot;
  late Regions _regions;
  late qt_plot.QuadTreeGroup _plotItem;

  late BoolValue _centerView;
  late BoolValue _points;
  late BoolValue _lines;
  late BoolValue _emptyNodes;
  late BoolValue _branchNodes;
  late BoolValue _passNodes;
  late BoolValue _pointNodes;
  late BoolValue _boundary;
  late BoolValue _rootBoundary;

  late BoolValue _panView;
  late BoolValue _addPolygon1;
  late BoolValue _addPolygon2;
  late BoolValue _addPolygon3;
  late BoolValue _addPolygon4;
  late BoolValue _addPolygon5;
  late BoolValue _checkRegion;
  late BoolValue _validate;
  late BoolValue _printTree;
  late BoolValue _clearAll;

  late Tool _selectedTool;
  late PlotterMousePan _shiftPanViewTool;
  late PlotterMousePan _panViewTool;
  late PolygonAdder _polygonAdderTool;
  late RegionChecker _regionCheckTool;

  Driver(this._svgPlot, this._plot) {
    _regions = Regions();
    _plotItem = _plot.addTree(_regions.tree);
    _selectedTool = Tool.None;
    _centerView = BoolValue(false)..onChange.add(_onCenterViewChange);
    _points = BoolValue(true, true)..onChange.add(_onPointsChange);
    _lines = BoolValue(true, true)..onChange.add(_onLinesChange);
    _emptyNodes = BoolValue(true)..onChange.add(_onEmptyNodesChange);
    _branchNodes = BoolValue(true)..onChange.add(_onBranchNodesChange);
    _passNodes = BoolValue(true, true)..onChange.add(_onPassNodesChange);
    _pointNodes = BoolValue(true, true)..onChange.add(_onPointNodesChange);
    _boundary = BoolValue(true, true)..onChange.add(_onBoundaryChange);
    _rootBoundary = BoolValue(true, true)..onChange.add(_onRootBoundaryChange);
    _panView = BoolValue(false)..onChange.add(_onPanViewChange);
    _addPolygon1 = BoolValue(false)..onChange.add(_onAddPolygon1Change);
    _addPolygon2 = BoolValue(false)..onChange.add(_onAddPolygon2Change);
    _addPolygon3 = BoolValue(false)..onChange.add(_onAddPolygon3Change);
    _addPolygon4 = BoolValue(false)..onChange.add(_onAddPolygon4Change);
    _addPolygon5 = BoolValue(false)..onChange.add(_onAddPolygon5Change);
    _checkRegion = BoolValue(false)..onChange.add(_onCheckRegion);
    _validate = BoolValue(false)..onChange.add(_onValidateChange);
    _printTree = BoolValue(false)..onChange.add(_onPrintTreeChange);
    _clearAll = BoolValue(false)..onChange.add(_onClearAllChange);
    _shiftPanViewTool = makeMousePan(
      _plot.plotter.view,
      _plot.plotter.setViewOffset,
      const PlotterMouseButtonStateImpl(
        button: 0,
        shiftKey: true,
      ),
    );
    _panViewTool = makeMousePan(
      _plot.plotter.view,
      _plot.plotter.setViewOffset,
      const PlotterMouseButtonStateImpl(button: 0),
    );
    _polygonAdderTool = PolygonAdder(
      _regions,
      _plot,
      _plotItem,
      const PlotterMouseButtonStateImpl(button: 0),
      const PlotterMouseButtonStateImpl(
        button: 0,
        ctrlKey: true,
      ),
    );
    _regionCheckTool = RegionChecker(_regions, _plot, _plotItem);
    _plot.plotter.mouseHandles
      ..clear()
      ..add(_shiftPanViewTool)
      ..add(_panViewTool)
      ..add(_polygonAdderTool)
      ..add(_regionCheckTool)
      ..add(makeMouseCoords(_plot.plotter));
    _plot.plotter.focusOnBounds(BoundsImpl(-100.0, -100.0, 100.0, 100.0));
    _setTool(Tool.AddPolygon, true, 1);
  }

  BoolValue get centerView => _centerView;

  BoolValue get points => _points;

  BoolValue get lines => _lines;

  BoolValue get emptyNodes => _emptyNodes;

  BoolValue get branchNodes => _branchNodes;

  BoolValue get passNodes => _passNodes;

  BoolValue get pointNodes => _pointNodes;

  BoolValue get boundary => _boundary;

  BoolValue get rootBoundary => _rootBoundary;

  BoolValue get panView => _panView;

  BoolValue get addPolygon1 => _addPolygon1;

  BoolValue get addPolygon2 => _addPolygon2;

  BoolValue get addPolygon3 => _addPolygon3;

  BoolValue get addPolygon4 => _addPolygon4;

  BoolValue get addPolygon5 => _addPolygon5;

  BoolValue get checkRegion => _checkRegion;

  BoolValue get validate => _validate;

  BoolValue get printTree => _printTree;

  BoolValue get clearAll => _clearAll;

  void _onCenterViewChange(bool value) {
    if (value) {
      _centerView.value = false;
      final bounds = _regions.tree.boundary;
      if (bounds.empty) {
        _plot.plotter.focusOnBounds(BoundsImpl(-100.0, -100.0, 100.0, 100.0));
      } else {
        _plot.plotter.focusOnBounds(
          BoundsImpl(
            bounds.xmin.toDouble(),
            bounds.ymin.toDouble(),
            bounds.xmax.toDouble(),
            bounds.ymax.toDouble(),
          ),
        );
      }
      _svgPlot.refresh();
    }
  }

  void _onPointsChange(bool value) {
    _plotItem.showPoints = value;
    _svgPlot.refresh();
  }

  void _onLinesChange(bool value) {
    _plotItem.showEdges = value;
    _svgPlot.refresh();
  }

  void _onEmptyNodesChange(bool value) {
    _plotItem.showEmptyNodes = value;
    _svgPlot.refresh();
  }

  void _onBranchNodesChange(bool value) {
    _plotItem.showBranchNodes = value;
    _svgPlot.refresh();
  }

  void _onPassNodesChange(bool value) {
    _plotItem.showPassNodes = value;
    _svgPlot.refresh();
  }

  void _onPointNodesChange(bool value) {
    _plotItem.showPointNodes = value;
    _svgPlot.refresh();
  }

  void _onBoundaryChange(bool value) {
    _plotItem.showBoundary = value;
    _svgPlot.refresh();
  }

  void _onRootBoundaryChange(bool value) {
    _plotItem.showRootBoundary = value;
    _svgPlot.refresh();
  }

  void _onPanViewChange(bool value) {
    _setTool(Tool.PanView, value);
  }

  void _onAddPolygon1Change(bool value) {
    _setTool(Tool.AddPolygon, value, 1);
  }

  void _onAddPolygon2Change(bool value) {
    _setTool(Tool.AddPolygon, value, 2);
  }

  void _onAddPolygon3Change(bool value) {
    _setTool(Tool.AddPolygon, value, 3);
  }

  void _onAddPolygon4Change(bool value) {
    _setTool(Tool.AddPolygon, value, 4);
  }

  void _onAddPolygon5Change(bool value) {
    _setTool(Tool.AddPolygon, value, 5);
  }

  void _onCheckRegion(bool value) {
    _setTool(Tool.CheckRegion, value);
  }

  void _setTool(Tool newTool, bool value, [int regionId = 0]) {
    if (!value) {
      return;
    }
    _selectedTool = newTool;
    _panView.value = _selectedTool == Tool.PanView;
    _addPolygon1.value = (_selectedTool == Tool.AddPolygon) && (regionId == 1);
    _addPolygon2.value = (_selectedTool == Tool.AddPolygon) && (regionId == 2);
    _addPolygon3.value = (_selectedTool == Tool.AddPolygon) && (regionId == 3);
    _addPolygon4.value = (_selectedTool == Tool.AddPolygon) && (regionId == 4);
    _addPolygon5.value = (_selectedTool == Tool.AddPolygon) && (regionId == 5);
    _checkRegion.value = _selectedTool == Tool.CheckRegion;
    _panViewTool.enabled = _selectedTool == Tool.PanView;
    _polygonAdderTool.enabled = _selectedTool == Tool.AddPolygon;
    _polygonAdderTool.enabled = _selectedTool == Tool.AddPolygon;
    _regionCheckTool.enabled = _selectedTool == Tool.CheckRegion;
    if (_selectedTool == Tool.AddPolygon) {
      _polygonAdderTool.finishRegion();
      _polygonAdderTool.regionId = regionId;
      _svgPlot.refresh();
    }
  }

  void _onValidateChange(bool value) {
    if (value) {
      _validate.value = false;
      _regions.tree.validate();
    }
  }

  void _onPrintTreeChange(bool value) {
    if (value) {
      _printTree.value = false;
      print(_regions.tree.toString());
    }
  }

  void _onClearAllChange(bool value) {
    if (value) {
      _clearAll.value = false;
      _regions.tree.clear();
      _polygonAdderTool.reset();
      _plotItem.updateTree();
      _svgPlot.refresh();
    }
  }
}

/// A mouse handler for adding lines.
class PolygonAdder implements PlotterMouseHandle {
  final PlotterMouseButtonState _addPointState;
  final PlotterMouseButtonState _finishRegionState;
  final qt_plot.QuadTreePlotter _plot;
  final qt_plot.QuadTreeGroup _plotItem;
  final Regions _regions;
  bool _enabled;
  int regionId;
  bool _mouseDown;
  final List<QTPointImpl> _points;
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
      _regions.addRegion(regionId, _points);
    }
    _plotItem.updateTree();
    _points.clear();
    _tempLines.clear();
  }

  /// Translates the mouse location into the tree space based on the view.
  List<double> _transMouse(PlotterMouseEvent e) {
    final trans = e.projection.mul(_plot.plotter.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  @override
  void mouseDown(PlotterMouseEvent e) {
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
      _tempLines.set(_tempLines.count - 1, [last[0], last[1], loc[0].roundToDouble(), loc[1].roundToDouble()]);
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
      _tempLines.set(_tempLines.count - 1, [last[0], last[1], loc[0].roundToDouble(), loc[1].roundToDouble()]);
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

/// The colors to draw for different regions
List<Color> regionColors = [
  ColorImpl(0.0, 0.0, 0.0),
  ColorImpl(0.0, 0.0, 1.0),
  ColorImpl(0.0, 1.0, 1.0),
  ColorImpl(0.0, 1.0, 0.0),
  ColorImpl(1.0, 1.0, 0.0),
  ColorImpl(1.0, 0.0, 0.0),
  ColorImpl(1.0, 0.0, 1.0),
];

/// A mouse handler for adding lines.
class RegionChecker implements PlotterMouseHandle {
  final qt_plot.QuadTreePlotter _plot;
  final qt_plot.QuadTreeGroup _plotItem; // ignore: unused_field
  final Regions _regions;
  bool _enabled;
  final Lines _lines;
  final ColorAttr _pointColor;
  final Points _points;

  /// Creates a new mouse handler for adding lines.
  RegionChecker(
    final this._regions,
    final this._plot,
    final this._plotItem,
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

  set enabled(bool value) {
    _enabled = value;
    _points.clear();
    _lines.clear();
  }

  /// Translates the mouse location into the tree space based on the view.
  List<double> _transMouse(PlotterMouseEvent e) {
    final trans = e.projection.mul(_plot.plotter.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  @override
  void mouseDown(PlotterMouseEvent e) {
    if (_enabled) {
      final loc = _transMouse(e);
      final x = loc[0].round();
      final y = loc[1].round();
      final pnt = QTPointImpl(x, y);
      final region = _regions.getRegion(pnt);
      print("[$x, $y] -> $region");
    }
  }

  /// handles mouse moved.
  @override
  void mouseMove(PlotterMouseEvent e) {
    if (_enabled) {
      final loc = _transMouse(e);
      final x = loc[0].round();
      final y = loc[1].round();
      final pnt = QTPointImpl(x, y);
      _points.clear();
      final region = _regions.getRegion(pnt);
      _pointColor.color = regionColors[region];
      _points.add([x.toDouble(), y.toDouble()]);
      _lines.clear();
      final edge = _regions.tree.firstLeftEdge(pnt);
      if (edge != null) {
        _lines.add([edge.start.x.toDouble(), edge.start.y.toDouble(), edge.end.x.toDouble(), edge.end.y.toDouble()]);
        final x = (pnt.y - edge.start.y) * edge.dx / edge.dy + edge.start.x;
        _lines.add([pnt.x.toDouble(), pnt.y.toDouble(), x, pnt.y.toDouble()]);
      }
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(PlotterMouseEvent e) {}
}
