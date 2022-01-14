import 'dart:html';

import 'package:alfred/granted/framework/basic/bounds.dart';
import 'package:alfred/granted/framework/basic/mouse_button_state.dart';
import 'package:alfred/granted/framework/mouse/impl/mouse_coordinates.dart';
import 'package:alfred/granted/framework/mouse/impl/mouse_pan.dart';
import 'package:alfred/granted/framework/mouse/impl/polygon_adder.dart';
import 'package:alfred/granted/framework/mouse/impl/region_checker.dart';
import 'package:alfred/granted/framework/plot/impl/html_svg.dart';
import 'package:alfred/granted/map/maps/regions.dart';
import 'package:alfred/granted/map/plotter.dart';

void main() {
  document.title = "Points & Lines";
  final body = document.body!;
  final menu = DivElement();
  menu.className = "menu";
  body.append(menu);
  final plotElem = DivElement();
  plotElem.className = "plot_target";
  body.append(plotElem);
  final plot = QuadTreePlotter();
  final svgPlot = makePlotHtmlSvg(
    targetDiv: plotElem,
    plot: plot.plotter,
  );
  final dvr = Driver(svgPlot, plot);
  addMenuView(menu, dvr);
  addMenuTools(menu, dvr);
}

void addMenuView(
  final DivElement menu,
  final Driver dvr,
) {
  final dropDown = DivElement()..className = "dropdown";
  menu.append(dropDown);
  final text = DivElement()..text = "View";
  dropDown.append(text);
  final items = DivElement()..className = "dropdown-content";
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

void addMenuTools(
  final DivElement menu,
  final Driver dvr,
) {
  final dropDown = DivElement()..className = "dropdown";
  menu.append(dropDown);
  final text = DivElement()..text = "Tools";
  dropDown.append(text);
  final items = DivElement()..className = "dropdown-content";
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

void addMenuItem(
  final DivElement dropDownItems,
  final String text,
  final BoolValue value,
) {
  final item = DivElement()
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

/// Boolean value handler for keeping track of changes in the UI and driver.
/// Kind of like a mini-store variable.
class BoolValue {
  final bool _toggle;
  bool _value;
  final List<void Function(bool newValue)> _changed;

  /// Creates a new boolean value.
  /// [toggle] indicates if the value will changed to true when value is false
  /// and false when the value is true or if the value should only be set to true on click.
  BoolValue(bool toggle, [bool value = false])
      : _toggle = toggle,
        _value = value,
        _changed = <void Function(bool newValue)>[];

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
  List<void Function(bool newValue)> get onChange => _changed;
}

enum Tool {
  None,
  PanView,
  AddPolygon,
  CheckRegion,
}

class Driver {
  final PlotHtmlSvg _svgPlot;
  final QuadTreePlotter _plot;
  late Regions _regions;
  late QuadTreeGroup _plotItem;

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

  Driver(
    final this._svgPlot,
    final this._plot,
  ) {
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
      _plot.plotter.windowToViewTransformer,
      _plot.plotter.setOffsetOfTheViewTransformation,
      const PlotterMouseButtonStateImpl(
        button: 0,
        shiftKey: true,
      ),
    );
    _panViewTool = makeMousePan(
      _plot.plotter.windowToViewTransformer,
      _plot.plotter.setOffsetOfTheViewTransformation,
      const PlotterMouseButtonStateImpl(
        button: 0,
      ),
    );
    _polygonAdderTool = PolygonAdder(
      _regions,
      _plot,
      _plotItem,
      const PlotterMouseButtonStateImpl(
        button: 0,
      ),
      const PlotterMouseButtonStateImpl(
        button: 0,
        ctrlKey: true,
      ),
    );
    _regionCheckTool = RegionChecker(_regions, _plot);
    _plot.plotter.mouseHandles
      ..clear()
      ..add(_shiftPanViewTool)
      ..add(_panViewTool)
      ..add(_polygonAdderTool)
      ..add(_regionCheckTool)
      ..add(makeMouseCoords(_plot.plotter));
    _plot.plotter.focusViewOnGivenBounds(BoundsImpl(-100.0, -100.0, 100.0, 100.0));
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
      final bounds = _regions.tree.tightBoundingBodyOfAllData;
      if (bounds.empty) {
        _plot.plotter.focusViewOnGivenBounds(BoundsImpl(-100.0, -100.0, 100.0, 100.0));
      } else {
        _plot.plotter.focusViewOnGivenBounds(
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
      _regions.tree.clearPointsEdgeNodesButAdditionalData();
      _polygonAdderTool.reset();
      _plotItem.updateTree();
      _svgPlot.refresh();
    }
  }
}
