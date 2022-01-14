import 'dart:html';

import 'package:alfred/granted/framework/basic/bounds.dart';
import 'package:alfred/granted/framework/basic/mouse_button_state.dart';
import 'package:alfred/granted/framework/mouse/impl/line_adder.dart';
import 'package:alfred/granted/framework/mouse/impl/line_remover.dart';
import 'package:alfred/granted/framework/mouse/impl/mouse_pan.dart';
import 'package:alfred/granted/framework/mouse/impl/point_adder_qt.dart';
import 'package:alfred/granted/framework/mouse/impl/point_remover_qt.dart';
import 'package:alfred/granted/framework/plot/impl/html_svg.dart';
import 'package:alfred/granted/map/plotter.dart';
import 'package:alfred/granted/map/quadtree/quadtree/quadtree.dart';

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
  addMenuItem(items, "Add Points", dvr.addPoints);
  addMenuItem(items, "Remove Points", dvr.removePoints);
  addMenuItem(items, "Add Lines", dvr.addLines);
  addMenuItem(items, "Remove Lines", dvr.removeLines);
  addMenuItem(items, "Remove Lines And Trim", dvr.removeLinesAndTrim);
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
    ..onClick.listen((final _) {
      value.onClick();
    });
  value.onChange.add((final bool value) {
    item.className = () {
      if (value) {
        return "dropdown-item-active";
      } else {
        return "dropdown-item-inactive";
      }
    }();
  });
  dropDownItems.append(item);
}

/// Boolean value handler for keeping track of changes in the UI and driver.
/// Kind of like a mini-store variable.
class BoolValue {
  final bool _toggle;
  bool _value;

  /// Gets the list of listeners who are watching for changes to this value.
  final List<void Function(bool newValue)> onChange;

  /// Creates a new boolean value.
  /// [toggle] indicates if the value will changed to true when value is false
  /// and false when the value is true or if the value should only be set to true on click.
  BoolValue(
    final bool toggle, [
    final bool value = false,
  ])  : _toggle = toggle,
        _value = value,
        onChange = <void Function(bool newValue)>[];

  /// Handles the value being clicked on.
  void onClick() {
    if (_toggle) {
      value = !_value;
    } else {
      value = true;
    }
  }

  /// Handles the value being set.
  set value(
    final bool value,
  ) {
    if (_value != value) {
      _value = value;
      for (final hndl in onChange) {
        hndl(_value);
      }
    }
  }

  /// Gets the currently set value.
  bool get value => _value;
}

enum Tool {
  None,
  PanView,
  AddPoints,
  RemovePoints,
  AddLines,
  RemoveLines,
  RemoveLinesAndTrim,
}

class Driver {
  final PlotHtmlSvg _svgPlot;
  final QuadTreePlotter _plot;
  final QuadTree _tree;
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
  late BoolValue _addPoints;
  late BoolValue _removePoints;
  late BoolValue _addLines;
  late BoolValue _removeLines;
  late BoolValue _removeLinesAndTrim;
  late BoolValue _validate;
  late BoolValue _printTree;
  late BoolValue _clearAll;

  late Tool _selectedTool;
  late PlotterMousePan _shiftPanViewTool;
  late PlotterMousePan _panViewTool;
  late PointAdder _pointAdderTool;
  late PointRemover _pointRemoverTool;
  late LineAdder _lineAdderTool;
  late LineRemover _lineRemoverTool;
  late LineRemover _lineRemoverAndTrimTool;

  Driver(
    final this._svgPlot,
    final this._plot,
  ) : _tree = QuadTreeImpl() {
    _plotItem = _plot.addTree(_tree);
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
    _addPoints = BoolValue(false, true)..onChange.add(_onAddPointsChange);
    _removePoints = BoolValue(false)..onChange.add(_onRemovePointsChange);
    _addLines = BoolValue(false)..onChange.add(_onAddLinesChange);
    _removeLines = BoolValue(false)..onChange.add(_onRemoveLinesChange);
    _removeLinesAndTrim = BoolValue(false)..onChange.add(_onRemoveLinesAndTrimChange);
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
    const leftMsButton = PlotterMouseButtonStateImpl(
      button: 0,
    );
    _panViewTool = makeMousePan(
        _plot.plotter.windowToViewTransformer, _plot.plotter.setOffsetOfTheViewTransformation, leftMsButton);
    _pointAdderTool = PointAdder(_tree, _plot, _plotItem, leftMsButton);
    _pointRemoverTool = PointRemover(_tree, _plot, _plotItem, leftMsButton);
    _lineAdderTool = LineAdder(_tree, _plot, _plotItem, leftMsButton);
    _lineRemoverTool = LineRemover(_tree, _plot, _plotItem, leftMsButton, false);
    _lineRemoverAndTrimTool = LineRemover(_tree, _plot, _plotItem, leftMsButton, true);
    _plot.plotter.mouseHandles
      ..clear()
      ..add(_shiftPanViewTool)
      ..add(_panViewTool)
      ..add(_pointAdderTool)
      ..add(_pointRemoverTool)
      ..add(_lineAdderTool)
      ..add(_lineRemoverTool)
      ..add(_lineRemoverAndTrimTool);
    _plot.plotter.focusViewOnGivenBounds(BoundsImpl(-100.0, -100.0, 100.0, 100.0));
    _setTool(Tool.AddPoints, true);
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

  BoolValue get addPoints => _addPoints;

  BoolValue get removePoints => _removePoints;

  BoolValue get addLines => _addLines;

  BoolValue get removeLines => _removeLines;

  BoolValue get removeLinesAndTrim => _removeLinesAndTrim;

  BoolValue get validate => _validate;

  BoolValue get printTree => _printTree;

  BoolValue get clearAll => _clearAll;

  void _onCenterViewChange(
    final bool value,
  ) {
    if (value) {
      _centerView.value = false;
      final bounds = _tree.tightBoundingBodyOfAllData;
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

  void _onPointsChange(
    final bool value,
  ) {
    _plotItem.showPoints = value;
    _svgPlot.refresh();
  }

  void _onLinesChange(
    final bool value,
  ) {
    _plotItem.showEdges = value;
    _svgPlot.refresh();
  }

  void _onEmptyNodesChange(
    final bool value,
  ) {
    _plotItem.showEmptyNodes = value;
    _svgPlot.refresh();
  }

  void _onBranchNodesChange(
    final bool value,
  ) {
    _plotItem.showBranchNodes = value;
    _svgPlot.refresh();
  }

  void _onPassNodesChange(
    final bool value,
  ) {
    _plotItem.showPassNodes = value;
    _svgPlot.refresh();
  }

  void _onPointNodesChange(
    final bool value,
  ) {
    _plotItem.showPointNodes = value;
    _svgPlot.refresh();
  }

  void _onBoundaryChange(
    final bool value,
  ) {
    _plotItem.showBoundary = value;
    _svgPlot.refresh();
  }

  void _onRootBoundaryChange(
    final bool value,
  ) {
    _plotItem.showRootBoundary = value;
    _svgPlot.refresh();
  }

  void _onPanViewChange(
    final bool value,
  ) {
    _setTool(Tool.PanView, value);
  }

  void _onAddPointsChange(
    final bool value,
  ) {
    _setTool(Tool.AddPoints, value);
  }

  void _onRemovePointsChange(
    final bool value,
  ) {
    _setTool(Tool.RemovePoints, value);
  }

  void _onAddLinesChange(
    final bool value,
  ) {
    _setTool(Tool.AddLines, value);
  }

  void _onRemoveLinesChange(
    final bool value,
  ) {
    _setTool(Tool.RemoveLines, value);
  }

  void _onRemoveLinesAndTrimChange(
    final bool value,
  ) {
    _setTool(Tool.RemoveLinesAndTrim, value);
  }

  void _setTool(
    final Tool newTool,
    final bool value,
  ) {
    if (value && _selectedTool != newTool) {
      _selectedTool = newTool;
      _panView.value = _selectedTool == Tool.PanView;
      _addPoints.value = _selectedTool == Tool.AddPoints;
      _removePoints.value = _selectedTool == Tool.RemovePoints;
      _addLines.value = _selectedTool == Tool.AddLines;
      _removeLines.value = _selectedTool == Tool.RemoveLines;
      _removeLinesAndTrim.value = _selectedTool == Tool.RemoveLinesAndTrim;
      _panViewTool.enabled = _selectedTool == Tool.PanView;
      _pointAdderTool.enabled = _selectedTool == Tool.AddPoints;
      _pointRemoverTool.enabled = _selectedTool == Tool.RemovePoints;
      _lineAdderTool.enabled = _selectedTool == Tool.AddLines;
      _lineRemoverTool.enabled = _selectedTool == Tool.RemoveLines;
      _lineRemoverAndTrimTool.enabled = _selectedTool == Tool.RemoveLinesAndTrim;
    }
  }

  void _onValidateChange(
    final bool value,
  ) {
    if (value) {
      _validate.value = false;
      _tree.validate();
    }
  }

  void _onPrintTreeChange(
    final bool value,
  ) {
    if (value) {
      _printTree.value = false;
      print(_tree.toString());
    }
  }

  void _onClearAllChange(
    final bool value,
  ) {
    if (value) {
      _clearAll.value = false;
      _tree.clearPointsEdgeNodesButAdditionalData();
      _plotItem.updateTree();
      _svgPlot.refresh();
    }
  }
}
