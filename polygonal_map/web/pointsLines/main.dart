// @dart = 2.9
import 'dart:html' as html;

import 'package:plotter_dart/framework/events/events.dart';
import 'package:plotter_dart/framework/events/events_impl.dart';
import 'package:plotter_dart/framework/mouse/mouse_handle.dart';
import 'package:plotter_dart/framework/mouse/mouse_handle_impl.dart';
import 'package:plotter_dart/framework/plotter/plotter_impl.dart';
import 'package:plotter_dart/framework/primitives/primitives.dart';
import 'package:plotter_dart/framework/primitives/primitives_impl.dart';
import 'package:plotter_dart/impl/html_svg.dart';
import 'package:polyonal_map_dart/plotter.dart';
import 'package:polyonal_map_dart/quadtree/boundary/boundary_impl.dart';
import 'package:polyonal_map_dart/quadtree/edge/edge_impl.dart';
import 'package:polyonal_map_dart/quadtree/point/point_impl.dart' as qt;
import 'package:polyonal_map_dart/quadtree/quadtree.dart' as qt;
import 'package:polyonal_map_dart/quadtree/quadtree_impl.dart' as qt;

void main() {
  html.document.title = "Points & Lines";
  final html.BodyElement body = html.document.body;
  final html.DivElement menu = html.DivElement();
  menu.className = "menu";
  body.append(menu);
  final html.DivElement plotElem = html.DivElement();
  plotElem.className = "plot_target";
  body.append(plotElem);
  final QuadTreePlotter plot = QuadTreePlotter();
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
  addMenuItem(items, "Add Points", dvr.addPoints);
  addMenuItem(items, "Remove Points", dvr.removePoints);
  addMenuItem(items, "Add Lines", dvr.addLines);
  addMenuItem(items, "Remove Lines", dvr.removeLines);
  addMenuItem(items, "Remove Lines And Trim", dvr.removeLinesAndTrim);
  addMenuItem(items, "Validate", dvr.validate);
  addMenuItem(items, "Print Tree", dvr.printTree);
  addMenuItem(items, "Clear All", dvr.clearAll);
}

void addMenuItem(html.DivElement dropDownItems, String text, BoolValue value) {
  final html.DivElement item = html.DivElement()
    ..text = text
    ..className = (() {
      if (value.value) {
        return "dropdown-item-active";
      } else {
        return "dropdown-item-inactive";
      }
    }())
    ..onClick.listen((_) {
      value.onClick();
    });
  value.onChange.add((bool value) {
    item.className = value ? "dropdown-item-active" : "dropdown-item-inactive";
  });
  dropDownItems.append(item);
}

/// The signature for handling changes to the boolean vlue.
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
  final PlotSvg _svgPlot;
  final QuadTreePlotter _plot;
  qt.QuadTree _tree;
  QuadTree _plotItem;

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
  BoolValue _addPoints;
  BoolValue _removePoints;
  BoolValue _addLines;
  BoolValue _removeLines;
  BoolValue _removeLinesAndTrim;
  BoolValue _validate;
  BoolValue _printTree;
  BoolValue _clearAll;

  Tool _selectedTool;
  MousePan _shiftPanViewTool;
  MousePan _panViewTool;
  PointAdder _pointAdderTool;
  PointRemover _pointRemoverTool;
  LineAdder _lineAdderTool;
  LineRemover _lineRemoverTool;
  LineRemover _lineRemoverAndTrimTool;

  Driver(this._svgPlot, this._plot) {
    _tree = qt.QuadTree();
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
      _plot.plotter.view,
      _plot.plotter.setViewOffset,
      const MouseButtonStateImpl(
        button: 0,
        shiftKey: true,
      ),
    );
    const MouseButtonState leftMsButton = MouseButtonStateImpl(
      button: 0,
    );
    _panViewTool = makeMousePan(_plot.plotter.view, _plot.plotter.setViewOffset, leftMsButton);
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
    _plot.plotter.focusOnBounds(BoundsImpl(-100.0, -100.0, 100.0, 100.0));
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

  void _onCenterViewChange(bool value) {
    if (value) {
      _centerView.value = false;
      final QTBoundaryImpl bounds = _tree.boundary;
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

  void _onAddPointsChange(bool value) {
    _setTool(Tool.AddPoints, value);
  }

  void _onRemovePointsChange(bool value) {
    _setTool(Tool.RemovePoints, value);
  }

  void _onAddLinesChange(bool value) {
    _setTool(Tool.AddLines, value);
  }

  void _onRemoveLinesChange(bool value) {
    _setTool(Tool.RemoveLines, value);
  }

  void _onRemoveLinesAndTrimChange(bool value) {
    _setTool(Tool.RemoveLinesAndTrim, value);
  }

  void _setTool(Tool newTool, bool value) {
    if ((!value) || (_selectedTool == newTool)) return;
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

  void _onValidateChange(bool value) {
    if (value) {
      _validate.value = false;
      _tree.validate();
    }
  }

  void _onPrintTreeChange(bool value) {
    if (value) {
      _printTree.value = false;
      print(_tree.toString());
    }
  }

  void _onClearAllChange(bool value) {
    if (value) {
      _clearAll.value = false;
      _tree.clear();
      _plotItem.updateTree();
      _svgPlot.refresh();
    }
  }
}

/// A mouse handler for adding lines.
class LineAdder implements PlotterMouseHandle {
  final MouseButtonState _state;
  final QuadTreePlotter _plot;
  final QuadTree _plotItem;
  final qt.QuadTree _tree;
  bool enabled;
  bool _mouseDown;
  double _startX;
  double _startY;
  Lines _tempLine;

  /// Creates a new mouse handler for adding lines.
  LineAdder(this._tree, this._plot, this._plotItem, this._state) {
    enabled = true;
    _mouseDown = false;
    _tempLine = _plot.plotter.addLines([])
      ..addPointSize(5.0)
      ..addDirected(true)
      ..addColor(1.0, 0.0, 0.0);
  }

  /// Translates the mouse location into the tree space based on the view.
  List<double> _transMouse(MouseEvent e) {
    final Transformer trans = e.projection.mul(_plot.plotter.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  @override
  void mouseDown(MouseEvent e) {
    if (enabled && e.state.equals(_state)) {
      _mouseDown = true;
      final List<double> loc = _transMouse(e);
      _startX = loc[0].roundToDouble();
      _startY = loc[1].roundToDouble();
      _tempLine.add([_startX, _startY, _startX, _startY]);
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  @override
  void mouseMove(MouseEvent e) {
    if (_mouseDown) {
      final List<double> loc = _transMouse(e);
      _tempLine.set(0, [_startX, _startY, loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(MouseEvent e) {
    if (_mouseDown) {
      final List<double> loc = _transMouse(e);
      final qt.QTPointImpl pnt1 = qt.QTPointImpl(_startX.round(), _startY.round());
      final qt.QTPointImpl pnt2 = qt.QTPointImpl(loc[0].round(), loc[1].round());
      _tree.insertEdge(QTEdgeImpl(pnt1, pnt2));
      _mouseDown = false;
      _tempLine.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}

/// A mouse handler for removing lines.
class LineRemover implements PlotterMouseHandle {
  final MouseButtonState _state;
  final QuadTreePlotter _plot;
  final QuadTree _plotItem;
  final qt.QuadTree _tree;
  bool enabled;
  bool _mouseDown;
  final bool _trimTree;
  Lines _tempLine;

  /// Creates a new mouse handler for removing lines.
  LineRemover(this._tree, this._plot, this._plotItem, this._state, this._trimTree) {
    enabled = true;
    _mouseDown = false;
    _tempLine = _plot.plotter.addLines([])
      ..addPointSize(5.0)
      ..addDirected(true)
      ..addColor(1.0, 0.0, 0.0);
  }

  /// Finds the nearest edge for a point under the mouse.
  qt.QTEdgeNodeImpl _findEdge(MouseEvent e) {
    final Transformer trans = e.projection.mul(_plot.plotter.view);
    final int x = trans.untransformX(e.x).round();
    final int y = trans.untransformY(e.window.ymax - e.y).round();
    return _tree.findNearestEdge(qt.QTPointImpl(x, y));
  }

  /// handles mouse down.
  @override
  void mouseDown(MouseEvent e) {
    if (enabled && e.state.equals(_state)) {
      _mouseDown = true;
      final qt.QTEdgeNodeImpl edge = _findEdge(e);
      if (edge != null) {
        _tempLine.add([edge.start.x.toDouble(), edge.start.y.toDouble(), edge.end.x.toDouble(), edge.end.y.toDouble()]);
      }
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  @override
  void mouseMove(MouseEvent e) {
    if (_mouseDown) {
      _tempLine.clear();
      final qt.QTEdgeNodeImpl edge = _findEdge(e);
      if (edge != null) {
        _tempLine.add([edge.start.x.toDouble(), edge.start.y.toDouble(), edge.end.x.toDouble(), edge.end.y.toDouble()]);
      }
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(MouseEvent e) {
    if (_mouseDown) {
      final qt.QTEdgeNodeImpl edge = _findEdge(e);
      if (edge != null) _tree.removeEdge(edge, _trimTree);
      _mouseDown = false;
      _tempLine.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}

/// A mouse handler for adding points.
class PointAdder implements PlotterMouseHandle {
  final MouseButtonState _state;
  final QuadTreePlotter _plot;
  final QuadTree _plotItem;
  final qt.QuadTree _tree;
  bool enabled;
  bool _mouseDown;
  Points _tempPoint;

  /// Creates a new mouse handler for adding points.
  PointAdder(this._tree, this._plot, this._plotItem, this._state) {
    enabled = true;
    _mouseDown = false;
    _tempPoint = _plot.plotter.addPoints([])
      ..addPointSize(5.0)
      ..addColor(1.0, 0.0, 0.0);
  }

  /// Translates the mouse location into the tree space based on the view.
  List<double> _transMouse(MouseEvent e) {
    final Transformer trans = e.projection.mul(_plot.plotter.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  @override
  void mouseDown(MouseEvent e) {
    if (enabled && e.state.equals(_state)) {
      _mouseDown = true;
      final List<double> loc = _transMouse(e);
      _tempPoint.add([loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  @override
  void mouseMove(MouseEvent e) {
    if (_mouseDown) {
      final List<double> loc = _transMouse(e);
      _tempPoint.set(0, [loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(MouseEvent e) {
    if (_mouseDown) {
      final List<double> loc = _transMouse(e);
      final int msx = loc[0].round();
      final int msy = loc[1].round();
      _tree.insertPoint(qt.QTPointImpl(msx, msy));
      _mouseDown = false;
      _tempPoint.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}

/// A mouse handler for removing points.
class PointRemover implements PlotterMouseHandle {
  final MouseButtonState _state;
  final QuadTreePlotter _plot;
  final QuadTree _plotItem;
  final qt.QuadTree _tree;
  bool enabled;
  bool _mouseDown;
  Points _tempPoint;

  /// Creates a new mouse handler for removing points.
  PointRemover(this._tree, this._plot, this._plotItem, this._state) {
    enabled = true;
    _mouseDown = false;
    _tempPoint = _plot.plotter.addPoints([])
      ..addPointSize(5.0)
      ..addColor(1.0, 0.0, 0.0);
  }

  /// Finds the point which has its node under the mouse.
  qt.QTNode _findNearPoint(
    final MouseEvent e,
  ) {
    final Transformer trans = e.projection.mul(_plot.plotter.view);
    final int msx = trans.untransformX(e.x).round();
    final int msy = trans.untransformY(e.window.ymax - e.y).round();
    final qt.QTNodeBoundaryBase node = _tree.nodeContaining(qt.QTPointImpl(msx, msy));
    if (node is qt.QTNode) {
      return node;
    } else {
      return null;
    }
  }

  /// handles mouse down.
  @override
  void mouseDown(MouseEvent e) {
    if (enabled && e.state.equals(_state)) {
      _mouseDown = true;
      final qt.PointNode node = _findNearPoint(e);
      if (node != null) _tempPoint.add([node.point.x.toDouble(), node.point.y.toDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  @override
  void mouseMove(MouseEvent e) {
    if (_mouseDown) {
      _tempPoint.clear();
      final qt.PointNode node = _findNearPoint(e);
      if (node != null) _tempPoint.add([node.point.x.toDouble(), node.point.y.toDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  @override
  void mouseUp(MouseEvent e) {
    if (_mouseDown) {
      final qt.PointNode node = _findNearPoint(e);
      if (node != null) _tree.removePoint(node);
      _mouseDown = false;
      _tempPoint.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}
