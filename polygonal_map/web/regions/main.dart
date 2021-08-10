// @dart = 2.9
import 'dart:html' as html;

import 'package:plotter_dart/framework/events/events.dart';
import 'package:plotter_dart/framework/events/events_impl.dart';
import 'package:plotter_dart/framework/mouse/mouse_handle.dart';
import 'package:plotter_dart/framework/mouse/mouse_handle_impl.dart';
import 'package:plotter_dart/framework/plotter/plotter_impl.dart';
import 'package:plotter_dart/framework/plotter_item/plotter_item.dart';
import 'package:plotter_dart/framework/plotter_item/plotter_item_impl.dart';
import 'package:plotter_dart/framework/primitives/primitives.dart';
import 'package:plotter_dart/framework/primitives/primitives_impl.dart';
import 'package:plotter_dart/impl/html_svg.dart';
import 'package:polyonal_map_dart/maps.dart' as maps;
import 'package:polyonal_map_dart/plotter.dart' as qt_plot;
import 'package:polyonal_map_dart/quadtree/boundary/boundary_impl.dart';
import 'package:polyonal_map_dart/quadtree/point/point_impl.dart';
import 'package:polyonal_map_dart/quadtree/quadtree_impl.dart';

void main() {
  html.document.title = "Points & Lines";
  final html.BodyElement body = html.document.body;
  final html.DivElement menu = html.DivElement();
  menu.className = "menu";
  body.append(menu);
  final html.DivElement plotElem = html.DivElement();
  plotElem.className = "plot_target";
  body.append(plotElem);
  final qt_plot.QuadTreePlotter plot = qt_plot.QuadTreePlotter();
  final PlotSvg svgPlot = PlotSvg.fromElem(plotElem, plot.plotter);
  final Driver dvr = Driver(svgPlot, plot);
  addMenuView(menu, dvr);
  addMenuTools(menu, dvr);
}

void addMenuView(html.DivElement menu, Driver dvr) {
  final html.DivElement dropDown = html.DivElement()..className = "dropdown";
  menu.append(dropDown);
  final html.DivElement text = html.DivElement()..text = "View";
  dropDown.append(text);
  final html.DivElement items = html.DivElement()..className = "dropdown-content";
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
  final html.DivElement dropDown = html.DivElement()..className = "dropdown";
  menu.append(dropDown);
  final html.DivElement text = html.DivElement()..text = "Tools";
  dropDown.append(text);
  final html.DivElement items = html.DivElement()..className = "dropdown-content";
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
  final html.DivElement item = html.DivElement()
    ..text = text
    ..className = (value.value ? "dropdown-item-active" : "dropdown-item-inactive")
    ..onClick.listen(
      (_) {
        value.onClick();
      },
    );
  value.onChange.add(
    (final value) => item.className = value ? "dropdown-item-active" : "dropdown-item-inactive",
  );
  dropDownItems.append(item);
}

/// The signature for handling changes to the boolean value.
typedef OnBoolValueChange = void Function(bool newValue);

/// Boolean value handler for keeping track of changes in the UI and driver.
/// Kind of like a mini-store variable.
class BoolValue {
  bool _toggle;
  bool _value;
  List<OnBoolValueChange> _changed;

  /// Creates a new boolean value.
  /// [toggle] indicates if the value will changed to true when value is false
  /// and false when the value is true or if the value should only be set to true on click.
  BoolValue(bool toggle, [bool value = false]) {
    _toggle = toggle;
    _value = value;
    _changed = <OnBoolValueChange>[];
  }

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
      for (final OnBoolValueChange hndl in _changed) {
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
  final PlotSvg _svgPlot;
  final qt_plot.QuadTreePlotter _plot;
  maps.Regions _regions;
  qt_plot.QuadTree _plotItem;

  BoolValue _centerView;
  BoolValue _points;
  BoolValue _lines;
  BoolValue _emptyNodes;
  BoolValue _branchNodes;
  BoolValue _passNodes;
  BoolValue _pointNodes;
  BoolValue _boundary;
  BoolValue _rootBoundary;

  BoolValue _panView;
  BoolValue _addPolygon1;
  BoolValue _addPolygon2;
  BoolValue _addPolygon3;
  BoolValue _addPolygon4;
  BoolValue _addPolygon5;
  BoolValue _checkRegion;
  BoolValue _validate;
  BoolValue _printTree;
  BoolValue _clearAll;

  Tool _selectedTool;
  MousePan _shiftPanViewTool;
  MousePan _panViewTool;
  PolygonAdder _polygonAdderTool;
  RegionChecker _regionCheckTool;

  Driver(this._svgPlot, this._plot) {
    _regions = maps.Regions();
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
      const MouseButtonStateImpl(
        button: 0,
        shiftKey: true,
      ),
    );
    _panViewTool = makeMousePan(
      _plot.plotter.view,
      _plot.plotter.setViewOffset,
      const MouseButtonStateImpl(button: 0),
    );
    _polygonAdderTool = PolygonAdder(
      _regions,
      _plot,
      _plotItem,
      const MouseButtonStateImpl(button: 0),
      const MouseButtonStateImpl(
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
      final QTBoundaryImpl bounds = _regions.tree.boundary;
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
    if (!value) return;
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
  final MouseButtonState _addPointState;
  final MouseButtonState _finishRegionState;
  final qt_plot.QuadTreePlotter _plot;
  final qt_plot.QuadTree _plotItem;
  final maps.Regions _regions;
  bool _enabled;
  int regionId;
  bool _mouseDown;
  List<QTPointImpl> _points;
  Lines _tempLines;

  /// Creates a new mouse handler for adding lines.
  PolygonAdder(this._regions, this._plot, this._plotItem, this._addPointState, this._finishRegionState) {
    _enabled = true;
    regionId = 1;
    _mouseDown = false;
    _points = <QTPointImpl>[];
    _tempLines = _plot.plotter.addLines([])
      ..addPointSize(5.0)
      ..addDirected(true)
      ..addColor(1.0, 0.0, 0.0);
  }

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
    for (final QTPointImpl pnt in _points) {
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
  List<double> _transMouse(MouseEvent e) {
    final Transformer trans = e.projection.mul(_plot.plotter.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  @override
  void mouseDown(MouseEvent e) {
    if (_enabled) {
      if (e.state.equals(_finishRegionState)) {
        finishRegion();
        e.redraw = true;
      } else if (e.state.equals(_addPointState)) {
        _mouseDown = true;
        final List<double> loc = _transMouse(e);
        final double x = loc[0].roundToDouble();
        final double y = loc[1].roundToDouble();
        if (_tempLines.count > 0) {
          final List<double> last = _tempLines.get(_tempLines.count - 1, 1);
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
  void mouseMove(MouseEvent e) {
    if (_mouseDown) {
      final List<double> loc = _transMouse(e);
      final List<double> last = _tempLines.get(_tempLines.count - 1, 1);
      _tempLines.set(_tempLines.count - 1, [last[0], last[1], loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(MouseEvent e) {
    if (_mouseDown) {
      final List<double> loc = _transMouse(e);
      final List<double> last = _tempLines.get(_tempLines.count - 1, 1);
      _tempLines.set(_tempLines.count - 1, [last[0], last[1], loc[0].roundToDouble(), loc[1].roundToDouble()]);
      if (_points.isNotEmpty) {
        final QTPointImpl lastPnt = _points[_points.length - 1];
        final int x = loc[0].round();
        final int y = loc[1].round();
        if ((lastPnt.x != x) || (lastPnt.y != y)) _points.add(QTPointImpl(x, y));
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
  final qt_plot.QuadTree _plotItem; // ignore: unused_field
  final maps.Regions _regions;
  bool _enabled;
  Lines _lines;
  ColorAttr _pointColor;
  Points _points;

  /// Creates a new mouse handler for adding lines.
  RegionChecker(this._regions, this._plot, this._plotItem) {
    _enabled = true;
    _lines = _plot.plotter.addLines([])..addColor(1.0, 0.5, 0.5);
    _pointColor = ColorAttrImpl.rgb(0.0, 0.0, 0.0);
    _points = _plot.plotter.addPoints([])
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
  List<double> _transMouse(MouseEvent e) {
    final Transformer trans = e.projection.mul(_plot.plotter.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  @override
  void mouseDown(MouseEvent e) {
    if (_enabled) {
      final List<double> loc = _transMouse(e);
      final int x = loc[0].round();
      final int y = loc[1].round();
      final QTPointImpl pnt = QTPointImpl(x, y);
      final int region = _regions.getRegion(pnt);
      print("[$x, $y] -> $region");
    }
  }

  /// handles mouse moved.
  @override
  void mouseMove(MouseEvent e) {
    if (_enabled) {
      final List<double> loc = _transMouse(e);
      final int x = loc[0].round();
      final int y = loc[1].round();
      final QTPointImpl pnt = QTPointImpl(x, y);
      _points.clear();
      final int region = _regions.getRegion(pnt);
      _pointColor.color = regionColors[region];
      _points.add([x.toDouble(), y.toDouble()]);
      _lines.clear();
      final QTEdgeNodeImpl edge = _regions.tree.firstLeftEdge(pnt);
      if (edge != null) {
        _lines.add([edge.start.x.toDouble(), edge.start.y.toDouble(), edge.end.x.toDouble(), edge.end.y.toDouble()]);
        final double x = (pnt.y - edge.start.y) * edge.dx / edge.dy + edge.start.x;
        _lines.add([pnt.x.toDouble(), pnt.y.toDouble(), x, pnt.y.toDouble()]);
      }
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(MouseEvent e) {}
}
