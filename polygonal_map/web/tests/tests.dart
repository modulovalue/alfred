// @dart = 2.9
import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:plotter_dart/framework/mouse/mouse_handle_impl.dart';
import 'package:plotter_dart/framework/plotter/plotter_impl.dart';
import 'package:plotter_dart/impl/html_svg.dart';
import 'package:polyonal_map_dart/maps.dart';
import 'package:polyonal_map_dart/plotter.dart';
import 'package:polyonal_map_dart/quadtree/boundary/boundary.dart' as qt;
import 'package:polyonal_map_dart/quadtree/boundary/boundary_impl.dart' as qt;
import 'package:polyonal_map_dart/quadtree/edge/edge.dart' as qt;
import 'package:polyonal_map_dart/quadtree/edge/edge_impl.dart' as qt;
import 'package:polyonal_map_dart/quadtree/formatter/formatter_impl.dart';
import 'package:polyonal_map_dart/quadtree/point/ops/intersect.dart';
import 'package:polyonal_map_dart/quadtree/point/point.dart' as qt;
import 'package:polyonal_map_dart/quadtree/point/point_impl.dart' as qt;
import 'package:polyonal_map_dart/quadtree/quadtree.dart' as qt;
import 'package:polyonal_map_dart/quadtree/quadtree_impl.dart' as qt;

void addTests(
  final TestManager tests,
) {
  addConversionsTests(tests);
  addEdgeIntersectTests(tests);
  addFindAllIntersectionsTests(tests);
  addFindNearestPointTests(tests);
  addFirstLeftEdgeTests(tests);
  addForeachPointInBoundaryTests(tests);
  addInsertEdgesTests(tests);
  addInsertPointTests(tests);
  addOverlapsTests(tests);
  addPolygonClipperTests(tests);
  addRegionMapTests(tests);
  addRegionTests(tests);
}

void main() {
  final html.DivElement elem = html.DivElement();
  addTests(TestManager(elem));
  final html.DivElement scrollPage = html.DivElement();
  scrollPage.className = "scroll_page";
  final html.DivElement pageCenter = html.DivElement();
  pageCenter.className = "page_center";
  scrollPage.append(pageCenter);
  final html.DivElement elemContainer = html.DivElement();
  pageCenter.append(elemContainer);
  elemContainer.append(elem);
  final html.DivElement endPage = html.DivElement();
  endPage.className = "end_page";
  elemContainer.append(endPage);
  html.document.title = "Unit-tests";
  final html.BodyElement body = html.document.body;
  body.append(scrollPage);
}

/// The method handler for unit-tests.
/// [args] are provided to call-back the status of the test.
typedef TestHandler = void Function(TestArgs args);

/// The interface for the unit-test to callback with.
abstract class TestArgs {
  /// The title of the unit-test.
  String get title;

  set title(String title);

  /// Indicates if the test has failed.
  bool get failed;

  // addDiv adds a div element to the test output.
  html.DivElement addDiv();

  /// Marks this test as failed.
  void fail();

  /// Prints text to the test's output console as an information.
  void info(String text);

  /// Prints text to the test's output console as a notice.
  void notice(String text);

  /// Prints text to the test's output console as a warning.
  void warning(String text);

  /// Prints text to the test's output console as an error.
  /// This will also mark this test as a failure.
  void error(String text);
}

class points {
  points._();

  static List<qt.QTPointImpl> parse(
    final String pnts,
  ) {
    final RegExp exp = RegExp(r"(-?[0-9]+)");
    final Iterable<Match> matches = exp.allMatches(pnts);
    final List<qt.QTPointImpl> result = <qt.QTPointImpl>[];
    for (int i = 1; i < matches.length; i += 2) {
      final String xStr = matches.elementAt(i - 1).group(0).toString();
      final String yStr = matches.elementAt(i).group(0).toString();
      final int x = int.parse(xStr.trim());
      final int y = int.parse(yStr.trim());
      result.add(qt.QTPointImpl(x, y));
    }
    return result;
  }

  static String format(List<qt.QTPointImpl> pnts) {
    String result = "{";
    final int pntsLen = pnts.length;
    for (int i = 0; i < pntsLen; ++i) {
      if (i != 0) result += ", ";
      // ignore: use_string_buffers
      result += "[${pnts[i].x}, ${pnts[i].y}]";
    }
    return result + "}";
  }

  static bool equals(List<qt.QTPointImpl> a, List<qt.QTPointImpl> b) {
    final int aLen = a.length;
    if (aLen != b.length) {
      return false;
    } else {
      for (int i = 0; i < aLen; ++i) {
        if (a[i].x != b[i].x) {
          return false;
        } else if (a[i].y != b[i].y) {
          return false;
        }
      }
      return true;
    }
  }

  static bool equals2(
    final List<qt.QTPointImpl> a,
    final List<qt.QTPoint> b,
  ) {
    final int aLen = a.length;
    if (aLen != b.length) {
      return false;
    } else {
      for (int i = 0; i < aLen; ++i) {
        if (a[i].x != b[i].x) {
          return false;
        } else if (a[i].y != b[i].y) {
          return false;
        }
      }
      return true;
    }
  }
}

/// A testing tool to help unit-test quad-trees.
class QuadTreeTester {
  final TestArgs _args;
  final qt.QuadTree _tree;

  /// Create a new quad-tree tester.
  QuadTreeTester(final this._args) : _tree = qt.QuadTree();

  /// Gets the testing arguments.
  TestArgs get args => _args;

  /// Gets the tree being tested.
  qt.QuadTree get tree => _tree;

  /// This shows the plot if the test has failed.
  void showPlotOnFail() {
    if (_args.failed) showPlot();
  }

  /// Shows the plot of the tree.
  void showPlot({
    bool showPassNodes = true,
    bool showPointNodes = true,
    bool showEmptyNodes = false,
    bool showBranchNodes = false,
    bool showEdges = true,
    bool showPoints = true,
    bool showBoundary = true,
    bool showRootBoundary = true,
  }) =>
      QuadTreePlotter.Show(
        _tree,
        _args.addDiv(),
        showPassNodes: showPassNodes,
        showPointNodes: showPointNodes,
        showEmptyNodes: showEmptyNodes,
        showBranchNodes: showBranchNodes,
        showEdges: showEdges,
        showPoints: showPoints,
        showBoundary: showBoundary,
        showRootBoundary: showRootBoundary,
      );

  /// Shows the given plot in this test.
  PlotSvg _showPlot(Plotter plot) {
    return PlotSvg.fromElem(_args.addDiv(), plot);
  }

  /// Inserts a point into the test tree.
  qt.PointNode insertPoint(int x, int y) {
    final qt.QTPointImpl pnt = qt.QTPointImpl(x, y);
    final int oldCount = _tree.pointCount;
    final qt.PointNode oldPoint = _tree.findPoint(pnt);
    final qt.PointNode point = _tree.insertPoint(pnt);
    final int newCount = _tree.pointCount;
    final qt.PointNode newPoint = _tree.findPoint(pnt);
    if (oldPoint == null) {
      if (oldCount + 1 != newCount) {
        _args.error("The old count should be one less than the new count after insertPoint($x, $y):" +
            "\n   Old Count: $oldCount" +
            "\n   New Count: $newCount");
      }
    } else {
      if (oldCount != newCount) {
        _args.error("The old count should be the same as the new count after insertPoint($x, $y):" +
            "\n   Old Count: $oldCount" +
            "\n   New Count: $newCount");
      }
      if (oldPoint != point) {
        _args.error("The pre-insert found point does not equal the inserted point after insertPoint($x, $y):" +
            "\n   Found Point:    $oldPoint" +
            "\n   Inserted Point: $point");
      }
    }
    if (point != newPoint) {
      _args.error("The post-insert found point does not equal the inserted point after insertPoint($x, $y):" +
          "\n   Found Point:    $newPoint" +
          "\n   Inserted Point: $point");
    }
    final StringBuffer sout = StringBuffer();
    if (!_tree.validate(sout, null)) {
      _args.error("Failed validation after insertPoint($x, $y):" + "\n${sout.toString()}");
    }
    return point;
  }

  /// Inserts a set of points into the test tree.
  void insertPoints(String pntCoords) {
    final List<qt.QTPointImpl> pnts = points.parse(pntCoords);
    final int count = pnts.length;
    for (int i = 0; i < count; ++i) {
      insertPoint(pnts[i].x, pnts[i].y);
    }
  }

  /// Inserts an edge into the test tree.
  qt.QTEdgeNodeImpl insertEdge(int x1, int y1, int x2, int y2) {
    final qt.QTEdgeImpl e = qt.QTEdgeImpl(qt.QTPointImpl(x1, y1), qt.QTPointImpl(x2, y2));
    final int oldCount = _tree.edgeCount;
    final qt.QTEdgeNodeImpl oldEdge = _tree.findEdge(e, false);
    final qt.QTEdgeNodeImpl edge = _tree.insertEdge(e);
    final int newCount = _tree.edgeCount;
    final qt.QTEdgeNodeImpl newEdge = _tree.findEdge(e, false);
    if (oldEdge == null) {
      if (oldCount + 1 != newCount) {
        _args.error("The old count should be one less than the new count after insertEdge($x1, $y1, $x2, $y2):" +
            "\n   Old Count: $oldCount" +
            "\n   New Count: $newCount");
      }
    } else {
      if (oldCount != newCount) {
        _args.error("The old count should be the same as the new count after insertEdge($x1, $y1, $x2, $y2):" +
            "\n   Old Count: $oldCount" +
            "\n   New Count: $newCount");
      }
      if (oldEdge != edge) {
        _args.error("The pre-insert found edge does not equal the inserted edge after insertEdge($x1, $y1, $x2, $y2):" +
            "\n   Found Edge:    $oldEdge" +
            "\n   Inserted Edge: $edge");
      }
    }
    if (edge != newEdge) {
      _args.error("The post-insert found edge does not equal the inserted edge after insertEdge($x1, $y1, $x2, $y2):" +
          "\n   Found Edge:    $newEdge" +
          "\n   Inserted Edge: $edge");
    }
    final StringBuffer sout = StringBuffer();
    if (!_tree.validate(sout, null)) {
      _args.error("Failed validation after insertEdge($x1, $y1, $x2, $y2):\n${sout.toString()}");
    }
    return edge;
  }

  /// Inserts a polygon into the test tree.
  void insertPolygon(String pntCoords) {
    final List<qt.QTPointImpl> pnts = points.parse(pntCoords);
    final qt.PointNodeVector nodes = qt.PointNodeVector();
    final int count = pnts.length;
    for (int i = 0; i < count; ++i) {
      final qt.PointNode node = _tree.insertPoint(pnts[i]);
      nodes.nodes.add(node);
    }
    for (int i = 0; i < count; ++i) {
      final qt.QTEdge edge = nodes.edge(i);
      insertEdge(edge.x1, edge.y1, edge.x2, edge.y2);
    }
  }

  /// Checks that the first left result was as expected.
  void checkFirstLeftEdge(int x, int y, int x1, int y1, int x2, int y2) {
    final qt.QTEdgeNodeImpl node = _tree.firstLeftEdge(qt.QTPointImpl(x, y));
    bool showPlot = false;
    if (node == null) {
      _args.info("Found to find first edge.\n\n");
      showPlot = true;
    } else if ((node.x1 != x1) || (node.y1 != y1) || (node.x2 != x2) || (node.y2 != y2)) {
      _args.error("First edge found didn't match expected:\n" +
          "   Gotten:   ${node.edge}\n" +
          "   Expected: [$x1, $y1, $x2, $y2]\n\n");
      showPlot = true;
    }
    if (showPlot) {
      final QuadTreePlotter plot = QuadTreePlotter();
      plot.addTree(_tree);
      if (node != null) {
        plot.plotter.addLines(
            [node.x1.toDouble(), node.y1.toDouble(), node.x2.toDouble(), node.y2.toDouble()]).addColor(0.2, 0.2, 1.0);
      }
      plot.plotter.addPoints([x.toDouble(), y.toDouble()])
        ..addColor(1.0, 0.0, 0.0)
        ..addPointSize(3.0);
      plot.plotter.updateBounds();
      plot.plotter.focusOnData();
      _showPlot(plot.plotter);
    }
  }

  /// Checks the expected result from finding all the intersections.
  void findAllIntersections(int x1, int y1, int x2, int y2, int count, [bool showPlot = true]) {
    final qt.QTEdgeImpl edge = qt.QTEdgeImpl(qt.QTPointImpl(x1, y1), qt.QTPointImpl(x2, y2));
    final IntersectionSetImpl inters = IntersectionSetImpl();
    _tree.findAllIntersections(edge, null, inters);
    final StringBuffer sout = StringBuffer();
    if (!_tree.validate(sout, null)) {
      _args.info(sout.toString());
      _args.info(_tree.toString());
      _args.fail();
      // ignore: parameter_assignments
      showPlot = true;
    }
    _args.info("$edge => $inters\n");
    if (inters.results.length != count) {
      _args.error("Expected to find $count intersections but found ${inters.results.length}.\n" +
          "${inters.toString()}\n" +
          "${_tree.toString()}\n\n");
      // ignore: parameter_assignments
      showPlot = true;
    }
    final IntersectionResult firstInt = _tree.findFirstIntersection(edge, null);
    if (firstInt != null) {
      if (count < 1) {
        _args.error("Expected to find no intersections but found a first intersection.\n" +
            "${firstInt.toString()}\n" +
            "${_tree.toString()}\n\n");
        // ignore: parameter_assignments
        showPlot = true;
      }
    } else {
      if (count > 0) {
        _args.error(
            "Expected to find $count intersections but found no first intersection.\n" + "${_tree.toString()}\n\n");
        // ignore: parameter_assignments
        showPlot = true;
      }
    }
    if (showPlot) {
      final QuadTreePlotter plot = QuadTreePlotter();
      plot.addTree(_tree, "Intersects: $edge => $count");
      final Lines lines = Lines();
      lines.add([edge.x1.toDouble(), edge.y1.toDouble(), edge.x2.toDouble(), edge.y2.toDouble()]);
      lines.addColor(0.0, 0.0, 0.8);
      plot.plotter.addItems([lines]);
      final Points points = Points();
      for (final IntersectionResult inter in inters.results) {
        if (inter.point != null) {
          points.add([inter.point.x.toDouble(), inter.point.y.toDouble()]);
        }
      }
      points.addPointSize(4.0);
      points.addColor(1.0, 0.0, 0.0);
      plot.plotter.addItems([points]);
      plot.plotter.updateBounds();
      plot.plotter.focusOnData();
      _showPlot(plot.plotter);
    }
  }

  /// Checks if the first found intersection returned the expected results.
  void findFirstIntersection(int x1, int y1, int x2, int y2, int expX1, int expY1, int expX2, int expY2,
      [bool showPlot = true, qt.QTEdgeHandler edgeFilter]) {
    final qt.QTEdgeImpl edge = qt.QTEdgeImpl(qt.QTPointImpl(x1, y1), qt.QTPointImpl(x2, y2));
    final qt.QTEdgeImpl exp = qt.QTEdgeImpl(qt.QTPointImpl(expX1, expY1), qt.QTPointImpl(expX2, expY2));
    final IntersectionResult result = _tree.findFirstIntersection(edge, edgeFilter);
    final StringBuffer sout = StringBuffer();
    if (!_tree.validate(sout, null)) {
      _args.info(sout.toString());
      _args.info(_tree.toString());
      _args.fail();
      // ignore: parameter_assignments
      showPlot = true;
    }
    _args.info("Edge:     $edge\n");
    _args.info("Result:   $result\n");
    _args.info("Expected: $exp\n");
    if (!qt.QTEdgeImpl.equals(result.edgeB, exp, false)) {
      _args.error("Expected to find an intersections but found a first intersection.\n" +
          "${result.toString()}\n" +
          "${_tree.toString()}\n\n");
      // ignore: parameter_assignments
      showPlot = true;
    }
    if (showPlot) {
      final QuadTreePlotter plot = QuadTreePlotter();
      plot.addTree(_tree, "Intersects: $edge");
      final Lines lines = Lines();
      lines.add([edge.x1.toDouble(), edge.y1.toDouble(), edge.x2.toDouble(), edge.y2.toDouble()]);
      lines.addColor(0.0, 0.0, 0.8);
      plot.plotter.addItems([lines]);
      final Points points = Points();
      if (result?.point != null) {
        points.add([result.point.x.toDouble(), result.point.y.toDouble()]);
      }
      points.addPointSize(4.0);
      points.addColor(1.0, 0.0, 0.0);
      plot.plotter.addItems([points]);
      plot.plotter.updateBounds();
      plot.plotter.focusOnData();
      _showPlot(plot.plotter);
    }
  }

  /// Checkst the bounded foreach method works as expected.
  void checkForeach(List<qt.QTPointImpl> inside, List<qt.QTPointImpl> outside, int x1, int y1, int x2, int y2,
      [bool showPlot = true]) {
    final Set<qt.PointNode> expOutside = <qt.PointNode>{};
    for (int i = 0; i < outside.length; ++i) {
      expOutside.add(insertPoint(outside[i].x, outside[i].y));
    }
    final Set<qt.PointNode> expInside = <qt.PointNode>{};
    for (int i = 0; i < inside.length; ++i) {
      expInside.add(insertPoint(inside[i].x, inside[i].y));
    }
    final qt.QTBoundaryImpl boundary = qt.QTBoundaryImpl(x1, y1, x2, y2);
    final qt.QTPointHandlerCollectorImpl collector = qt.QTPointHandlerCollectorImpl();
    _tree.foreachPoint(collector, boundary);
    final Set<qt.PointNode> foundPoints = collector.collection;
    final Set<qt.PointNode> wrongOutside = <qt.PointNode>{};
    for (final qt.PointNode point in expInside) {
      if (!foundPoints.remove(point)) {
        wrongOutside.add(point);
      }
    }
    final Set<qt.PointNode> wrongInside = <qt.PointNode>{};
    wrongInside.addAll(foundPoints);
    if ((wrongOutside.isNotEmpty) || (wrongInside.isNotEmpty)) {
      _args.error("Foreach point failed to return expected results:" +
          "\n   Expected Outside: $expOutside" +
          "\n   Expected Inside:  $expInside" +
          "\n   Wrong Outside:    $wrongOutside" +
          "\n   Wrong Inside:     $wrongInside");
      // ignore: parameter_assignments
      showPlot = true;
    }
    if (showPlot) {
      final QuadTreePlotter plot = QuadTreePlotter();
      plot.addTree(_tree);
      final Points expOutsidePoint = plot.plotter.addGroup("Expected Outside").addPoints([])
        ..addColor(0.0, 0.0, 1.0)
        ..addPointSize(4.0);
      plot.addPointSet(expOutsidePoint, expOutside);
      final Points expInsidePoint = plot.plotter.addGroup("Expected Inside").addPoints([])
        ..addColor(0.0, 1.0, 0.0)
        ..addPointSize(4.0);
      plot.addPointSet(expInsidePoint, expInside);
      final Points wrongOutsidePoint = plot.plotter.addGroup("Wrong Outside").addPoints([])
        ..addColor(1.0, 0.0, 0.0)
        ..addPointSize(4.0);
      plot.addPointSet(wrongOutsidePoint, wrongOutside);
      final Points wrongInsidePoint = plot.plotter.addGroup("Wrong Inside").addPoints([])
        ..addColor(1.0, 0.5, 0.0)
        ..addPointSize(4.0);
      plot.addPointSet(wrongInsidePoint, wrongInside);
      plot.plotter
          .addGroup("Boundary")
          .addRects([x1.toDouble(), y1.toDouble(), (x2 - x1).toDouble(), (y2 - y1).toDouble()]);
      plot.plotter.updateBounds();
      plot.plotter.focusOnData();
      _showPlot(plot.plotter);
    }
  }

  /// Checks the find nearest point for point returns the expected results.
  void checkFindNearestPoint(int x, int y, int expX, int expY, [bool showPlot = true]) {
    final qt.QTPointImpl focus = qt.QTPointImpl(x, y);
    final qt.QTPointImpl exp = qt.QTPointImpl(expX, expY);
    final qt.PointNode result = _tree.findNearestPointToPoint(focus);
    _args.info("$focus => $result\n");
    if (!qt.QTPointImpl.equals(exp, result)) {
      _args.error("Foreach point failed to return expected results:" +
          "\n   Focus:     ${focus.toString()}" +
          "\n   Exp:       ${exp.toString()}" +
          "\n   Exp Dist2: ${qt.QTPointImpl.distance2(exp, focus)}" +
          "\n   Result:    ${result.toString()}");
      // ignore: parameter_assignments
      showPlot = true;
    }
    final _testNearestPointHandle hndl = _testNearestPointHandle()..focus = focus;
    _tree.foreachPoint(hndl);
    if (!qt.QTPointImpl.equals(hndl.found, result)) {
      _args.error("FindNearestPoint didn't find nearest point:" +
          "\n   Focus:        ${focus.toString()}" +
          "\n   Result:       ${result.toString()}" +
          "\n   Result Dist2: ${qt.QTPointImpl.distance2(focus, result)}" +
          "\n   Found:        ${hndl.found.toString()}" +
          "\n   Found Dist2:  ${hndl.minDist2}");
      // ignore: parameter_assignments
      showPlot = true;
    }
    if (showPlot) {
      final QuadTreePlotter plot = QuadTreePlotter();
      plot.addTree(_tree);
      final Points focusPnt = plot.plotter.addGroup("Focus").addPoints([])
        ..addColor(0.0, 0.0, 1.0)
        ..addPointSize(4.0);
      plot.addPoint(focusPnt, focus);
      final Points resultPnt = plot.plotter.addGroup("Result").addPoints([])
        ..addColor(0.0, 1.0, 0.0)
        ..addPointSize(4.0);
      plot.addPoint(resultPnt, result);
      final Points foundPnt = plot.plotter.addGroup("Found").addPoints([])
        ..addColor(1.0, 0.0, 0.0)
        ..addPointSize(4.0);
      plot.addPoint(foundPnt, hndl.found);
      plot.plotter.updateBounds();
      plot.plotter.focusOnData();
      _showPlot(plot.plotter);
    }
  }
}

/// A point handler used to find the neasest point while checking all points.
/// This is not as fast as findNearestPointToPoint but can be used to test it.
class _testNearestPointHandle implements qt.QTPointHandler {
  /// minimum distance squared to found point.
  double minDist2 = double.maxFinite;

  /// The point to get the point closest to.
  qt.QTPointImpl focus;

  /// The found point closest the the focus or null if none has been found yet.
  qt.PointNode found;

  /// handles each point given to it to check if it is closer.
  @override
  bool handle(qt.PointNode point) {
    final double dist2 = qt.QTPointImpl.distance2(focus, point);
    if (dist2 < minDist2) {
      minDist2 = dist2;
      found = point;
    }
    return true;
  }
}

/// The block for the unit-test output and the test arguments.
class TestBlock extends TestArgs {
  final TestManager _man;
  html.DivElement _body;
  html.DivElement _title;
  DateTime _start;
  DateTime _end;
  final TestHandler _test;
  String _testName;
  bool _started;
  bool _failed;
  bool _finished;

  /// Creates a new test block for the given test.
  TestBlock(this._man, this._test, this._testName) {
    _body = html.DivElement()..className = "test_body body_hidden";
    _title = html.DivElement()
      ..className = "running top_header"
      ..onClick.listen(_titleClicked);
    _man._elem.children..add(_title)..add(_body);
    _start = null;
    _end = null;
    _started = false;
    _failed = false;
    _finished = false;
    _update();
  }

  /// Handles the test title clicked to show and hide the test output.
  void _titleClicked(dynamic _) {
    if (_body.className != "test_body body_hidden") {
      _body.className = "test_body body_hidden";
    } else {
      _body.className = "test_body body_shown";
    }
  }

  /// Updates the test header.
  void _update() {
    String time = "";
    if (_start != null) {
      DateTime end = _end;
      end ??= DateTime.now();
      time = ((end.difference(_start).inMilliseconds) * 0.001).toStringAsFixed(2);
      time = "(${time}s)";
    }
    if (!_started) {
      _title
        ..className = "test_header queued"
        ..text = "Queued: $_testName $time";
    } else if (_failed) {
      _title
        ..className = "test_header failed"
        ..text = "Failed: $_testName $time";
    } else if (_finished) {
      _title
        ..className = "test_header passed"
        ..text = "Passed: $_testName $time";
    } else {
      _title
        ..className = "test_header running"
        ..text = "Running: $_testName $time";
    }
    _man._update();
  }

  /// Runs this test asynchronously in the event loop.
  void run() {
    Future(() {
      _started = true;
      _update();
      html.window.requestAnimationFrame((_) {});
    }).then((_) {
      _start = DateTime.now();
      _test(this);
      _end = DateTime.now();
    }).catchError((final dynamic exception, final StackTrace stackTrace) {
      _end = DateTime.now();
      error("\nException: $exception");
      warning("\nStack: $stackTrace");
    }).then((_) {
      _finished = true;
      _man._testDone(this);
      _update();
      html.window.requestAnimationFrame((_) {});
    });
  }

  /// Adds a div element to the test output.
  @override
  html.DivElement addDiv() {
    final html.DivElement div = html.DivElement()
      ..className = "test_div"
      ..id = "testDiv${_man.takeDivIndex}";
    _body.children.add(div);
    return div;
  }

  /// Adds a new log event
  void _addLog(String text, String type) {
    final List<String> entries = text.split("\n");
    if (entries.isNotEmpty) {
      if (entries[0].isNotEmpty) {
        _body.children.add(html.DivElement()
          ..className = type
          ..text = entries[0]);
      }
      for (int i = 1; i < entries.length; i++) {
        _body.children.add(html.BRElement()..className = "br_log");
        if (entries[i].isNotEmpty) {
          _body.children.add(html.DivElement()
            ..className = type
            ..text = entries[i]);
        }
      }
    }
  }

  /// Prints text to the test's output console as an information.
  @override
  void info(String text) {
    _addLog(text, "info_log");
  }

  /// Prints text to the test's output console as a notice.
  @override
  void notice(String text) {
    _addLog(text, "notice_log");
  }

  /// Prints text to the test's output console as a warning.
  @override
  void warning(String text) {
    _addLog(text, "warning_log");
  }

  /// Prints text to the test's output console as an error.
  /// This will also mark this test as a failure.
  @override
  void error(String text) {
    _addLog(text, "error_log");
    fail();
  }

  /// The title of the unit-test.
  @override
  String get title => _testName;

  @override
  set title(String title) {
    _testName = title;
    _update();
  }

  /// Indicates if the test had started.
  bool get stated => _started;

  /// Indicates if the test had finished.
  bool get finished => _finished;

  /// Indicates if the test has failed.
  @override
  bool get failed => _failed;

  /// Marks this test as failed.
  @override
  void fail() {
    if (!_failed) {
      _failed = true;
      _body.className = "test_body body_shown";
      _update();
    }
  }
}

/// The manager to run the tests.
class TestManager {
  final html.Element _elem;
  html.DivElement _header;
  DateTime _start;
  List<TestBlock> _tests;
  int _finished;
  int _failed;
  int _testDivIndex;

  /// The filter to only let tests with the given prefix to be run.
  /// Set to empty to run all tests.
  String testPrefixFilter;

  /// Creates new test manager attached to the given element.
  TestManager(this._elem) {
    _header = html.DivElement();
    _elem.children.add(_header);
    final html.DivElement checkBoxes = html.DivElement()..className = "log_checkboxes";
    _createLogSwitch(checkBoxes, "Information", "info_log");
    _createLogSwitch(checkBoxes, "Notice", "notice_log");
    _createLogSwitch(checkBoxes, "Warning", "warning_log");
    _createLogSwitch(checkBoxes, "Error", "error_log");
    _elem.children.add(checkBoxes);
    _start = DateTime.now();
    _tests = <TestBlock>[];
    _finished = 0;
    _failed = 0;
    _testDivIndex = 0;
    testPrefixFilter = "";
  }

  /// Gets an index for a test div which is unique.
  int get takeDivIndex {
    final int result = _testDivIndex;
    _testDivIndex++;
    return result;
  }

  /// Creates a check box for changing the visibility of logs with the given [type].
  void _createLogSwitch(html.DivElement checkBoxes, String text, String type) {
    final html.CheckboxInputElement checkBox = html.CheckboxInputElement()
      ..className = "log_checkbox"
      ..checked = true;
    checkBox.onChange.listen((_) {
      final html.ElementList<html.Element> myElements = html.document.querySelectorAll(".$type");
      final String display = checkBox.checked ? "block" : "none";
      for (int i = 0; i < myElements.length; i++) {
        myElements[i].style.display = display;
      }
    });
    checkBoxes.children.add(checkBox);
    final html.SpanElement span = html.SpanElement()..text = text;
    checkBoxes.children.add(span);
  }

  /// Callback from a test to indicate it is done
  /// and to have the manager start a new test.
  void _testDone(TestBlock block) {
    _finished++;
    if (block.failed) _failed++;
    _update();
    if (_finished < _tests.length) {
      Future(() {
        html.window.requestAnimationFrame((_) {});
        _tests[_finished].run();
      });
    }
  }

  /// Updates the top header of the tests.
  void _update() {
    final String time = ((DateTime.now().difference(_start).inMilliseconds) * 0.001).toStringAsFixed(2);
    final int testCount = _tests.length;
    if (testCount <= _finished) {
      if (_failed > 0) {
        _header.className = "top_header failed";
        if (_failed == 1) {
          _header.text = "Failed 1 Test (${time}s)";
        } else {
          _header.text = "Failed ${this._failed} Tests (${time}s)";
        }
      } else {
        _header
          ..text = "Tests Passed (${time}s)"
          ..className = "top_header passed";
      }
    } else {
      final String prec = ((_finished.toDouble() / testCount) * 100.0).toStringAsFixed(2);
      _header.text = "Running Tests: ${this._finished}/${testCount} ($prec%)";
      if (_failed > 0) {
        _header
          ..text = "${this._header.text} - ${this._failed} failed)"
          ..className = "topHeader failed";
      } else {
        _header.className = "topHeader running";
      }
    }
  }

  /// Adds a new test to be run.
  void add(String testName, TestHandler test) {
    if (testName.isEmpty) {
      // ignore: parameter_assignments
      testName = "$test";
    }
    if (!testName.startsWith(testPrefixFilter)) {
      return;
    }
    _tests.add(TestBlock(this, test, testName));
    _update();
    // If currently none are running, start this one.
    if (_finished + 1 == _tests.length) {
      Future(() {
        html.window.requestAnimationFrame((_) {});
        _tests[_finished].run();
      });
    }
  }
}

void addConversionsTests(TestManager tests) {
  tests.add("Conversions Test", (TestArgs args) {
    final QTFormatterImpl coords =
        QTFormatterImpl(230.0, 15000.0, 0.0001, 0.01, NumberFormat("#0.0000", "en_US"), NumberFormat("#0.00", "en_US"));
    final qt.QuadTree tree = qt.QuadTree();
    final qt.QTPoint pnt = tree.insertPoint(coords.toPoint(3.5555555555555, 3.55555555555));
    final String result = coords.toPointString(pnt);
    const String exp = "[3.5556, 3.56]";
    if (result != exp) {
      args.error("Failed: Coordinates expected to be " + exp + " but got " + result + ".\n\n");
    } else {
      args.info("Passed: $result\n");
    }
  });
}

void addEdgeIntersectTests(TestManager tests) {
  tests.add("Edge Intersect Test", (TestArgs args) {
    edgeIntersectTest(args, e(0, 0, 1, 1), e(0, 0, 1, 1), "Hit Same null None None");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(1, 1, 0, 0), "Hit Opposite null None None");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(1, 1, 2, 2), "Hit Collinear [1, 1] AtEnd AtStart");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(2, 2, 1, 1), "Hit Collinear [1, 1] AtEnd AtEnd");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(1, 1, 2, 2), "Hit Collinear [1, 1] AtStart AtStart");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(2, 2, 1, 1), "Hit Collinear [1, 1] AtStart AtEnd");
    edgeIntersectTest(args, e(0, 0, 1, 0), e(1, 0, 2, 0), "Hit Collinear [1, 0] AtEnd AtStart");
    edgeIntersectTest(args, e(0, 0, 1, 0), e(2, 0, 1, 0), "Hit Collinear [1, 0] AtEnd AtEnd");
    edgeIntersectTest(args, e(1, 0, 0, 0), e(1, 0, 2, 0), "Hit Collinear [1, 0] AtStart AtStart");
    edgeIntersectTest(args, e(1, 0, 0, 0), e(2, 0, 1, 0), "Hit Collinear [1, 0] AtStart AtEnd");
    edgeIntersectTest(args, e(0, 0, 1, 0), e(2, 0, 3, 0), "Miss Collinear null None None");
    edgeIntersectTest(args, e(0, 0, 1, 0), e(3, 0, 2, 0), "Miss Collinear null None None");
    edgeIntersectTest(args, e(1, 0, 0, 0), e(2, 0, 3, 0), "Miss Collinear null None None");
    edgeIntersectTest(args, e(1, 0, 0, 0), e(3, 0, 2, 0), "Miss Collinear null None None");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(2, 2, 3, 3), "Miss Collinear null None None");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(3, 3, 2, 2), "Miss Collinear null None None");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(2, 2, 3, 3), "Miss Collinear null None None");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(3, 3, 2, 2), "Miss Collinear null None None");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(1, 1, 0, 2), "Hit Point [1, 1] AtEnd AtStart");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(0, 2, 1, 1), "Hit Point [1, 1] AtEnd AtEnd");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(1, 1, 0, 2), "Hit Point [1, 1] AtStart AtStart");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(0, 2, 1, 1), "Hit Point [1, 1] AtStart AtEnd");
    edgeIntersectTest(args, e(0, 2, 4, 2), e(2, 0, 2, 4), "Hit Point [2, 2] InMiddle InMiddle");
    edgeIntersectTest(args, e(0, 2, 4, 2), e(2, 0, 2, 2), "Hit Point [2, 2] InMiddle AtEnd");
    edgeIntersectTest(args, e(0, 2, 4, 2), e(2, 2, 2, 4), "Hit Point [2, 2] InMiddle AtStart");
    edgeIntersectTest(args, e(0, 2, 2, 2), e(2, 0, 2, 4), "Hit Point [2, 2] AtEnd InMiddle");
    edgeIntersectTest(args, e(2, 2, 4, 2), e(2, 0, 2, 4), "Hit Point [2, 2] AtStart InMiddle");
  });
}

qt.QTEdgeImpl e(int x1, int y1, int x2, int y2) {
  return qt.QTEdgeImpl(qt.QTPointImpl(x1, y1), qt.QTPointImpl(x2, y2));
}

void edgeIntersectTest(TestArgs args, qt.QTEdgeImpl edgeA, qt.QTEdgeImpl edgeB, String exp) {
  final IntersectionResult result = intersect(edgeA, edgeB);
  final String type = "${result.type}".substring("IntersectionType.".length);
  final String locA = "${result.locA}".substring("IntersectionLocation.".length);
  final String locB = "${result.locB}".substring("IntersectionLocation.".length);
  final String resultStr = (result.intersects ? "Hit" : "Miss") + " " + "$type ${result.point} $locA $locB";
  if (exp != resultStr) {
    if (!args.failed) {
      final Plotter plot = makePlotter();
      plot.addLines([
        edgeA.x1.toDouble(),
        edgeA.y1.toDouble(),
        edgeA.x2.toDouble(),
        edgeA.y2.toDouble(),
        edgeB.x1.toDouble(),
        edgeB.y1.toDouble(),
        edgeB.x2.toDouble(),
        edgeB.y2.toDouble()
      ]);
      plot.updateBounds();
      plot.focusOnData();
      PlotSvg.fromElem(args.addDiv(), plot);
    }
    args.error("Failed: Unexpected result from edge interscetion:\n" +
        "   Edge A:   $edgeA\n" +
        "   Edge B:   $edgeB\n" +
        "   Full:     ${result.toString("\n                 ")}\n" +
        "   Result:   $resultStr\n" +
        "   Expected: $exp\n\n");
  } else {
    args.info("Passed: $resultStr\n");
  }
}

void addFindAllIntersectionsTests(TestManager tests) {
  tests.add("Find All Intersections Test", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertEdge(0, 0, 10, 0);
    test.insertEdge(10, 0, 10, 10);
    test.insertEdge(10, 10, 0, 10);
    test.insertEdge(0, 10, 0, 0);
    test.findAllIntersections(-2, -4, 12, 14, 2);
    test.findAllIntersections(-2, 4, 12, 14, 2);
    test.findAllIntersections(-2, 4, 5, 5, 1);
    test.findAllIntersections(5, 5, 12, 14, 1);
    test.findAllIntersections(3, 6, 6, 3, 0);
    test.findAllIntersections(0, 10, 10, 10, 3);
    test.findAllIntersections(3, 10, 6, 10, 1);
    test.findAllIntersections(-3, 10, 12, 10, 3);
    test.findAllIntersections(5, 5, 15, 5, 1);
  });
  tests.add("Find Intersections Incoming Lines Test", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertEdge(50, 60, 100, 10);
    test.insertEdge(100, 10, 0, 10);
    test.insertEdge(0, 10, 50, 60);
    test.findFirstIntersection(90, 20, 90, 0, 100, 10, 0, 10);
  });
}

void addFindNearestPointTests(TestManager tests) {
  tests.add("Find Nearest Point Basic Test", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertPoints("(-3, -3) (-3, 3) (3, 3) (3, -3)");
    test.checkFindNearestPoint(0, 0, 3, 3);
  });
  tests.add("Find Nearest Point Test", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertPoints("(1, 5) (5, 1) (3, 3) (2, 6) (8, 8) (4, 1) (10, 10) (0, 10) (10, 0) (0, 0)..." +
        "(0, 1) (0, 2) (1, 0) (2, 0) (10, 1) (10, 8) (7, 10) (4, 10) (10, 12)..." +
        "(20, 21) (12, 2) (1, 12) (13, 5) (-1, 3) (11, 11) (-1, -1)");
    test.checkFindNearestPoint(0, 0, 0, 0);
    test.checkFindNearestPoint(10, 10, 10, 10);
    test.checkFindNearestPoint(2, 2, 3, 3);
    test.checkFindNearestPoint(0, 2, 0, 2);
    test.checkFindNearestPoint(14, 14, 11, 11);
    test.checkFindNearestPoint(42, 31, 20, 21);
    test.checkFindNearestPoint(-2, 8, 0, 10);
  });
}

void addFirstLeftEdgeTests(TestManager tests) {
  tests.add("First Left Edge Basic Test", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertPolygon("(5, 5) (10, 5) (15, 5) (15, 15) (5, 15) (5, 10)");
    test.checkFirstLeftEdge(10, 10, 5, 10, 5, 5);
  });
  tests.add("First Left Edge Test", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertPolygon("(0, 0) (0, 10) (30, 10) (30, 30) (0, 30) (0, 40) (40, 40) (40, 0)");
    test.checkFirstLeftEdge(10, 5, 0, 0, 0, 10);
  });
}

void addForeachPointInBoundaryTests(TestManager tests) {
  tests.add("Foreach Point In Boundary Test 1", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    final List<qt.QTPointImpl> inside = points.parse(
        "(1, 5) (5, 1) (3, 3) (2, 6) (8, 8) (4, 1) (10, 10) (0, 10) (10, 0)..." +
            "(0, 0) (0, 1) (0, 2) (1, 0) (2, 0) (10, 1) (10, 8) (7, 10) (4, 10)");
    final List<qt.QTPointImpl> outside =
        points.parse("(10, 12) (20, 21) (12, 2) (1, 12) (13, 5) (-1, 3) (11, 11) (-1, -1)");
    test.checkForeach(inside, outside, 0, 0, 10, 10);
  });
  tests.add("Foreach Point In Boundary Test 2", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    final List<qt.QTPointImpl> inside = points.parse("(3, 3)");
    final List<qt.QTPointImpl> outside = points.parse(
        "(10, 12) (20, 21) (12, 2) (1, 12) (13, 5) (-1, 3) (11, 11) (-1, -1)..." +
            "(1, 5) (5, 1) (8, 8) (4, 1) (10, 10) (0, 10) (10, 0) (0, 0) (2, 6)");
    test.checkForeach(inside, outside, 3, 2, 5, 6);
  });
  tests.add("Foreach Point In Boundary Test 3", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    final List<qt.QTPointImpl> inside = points.parse("(3, 3) (5, 5)");
    final List<qt.QTPointImpl> outside = points.parse(
        "(10, 12) (20, 21) (12, 2) (1, 12) (13, 5) (-1, 3) (11, 11) (-1, -1) (1, 5) (5, 1)..." +
            "(8, 8) (4, 1) (10, 10) (0, 10) (10, 0) (0, 0) (2, 6) (40, 40) (40, 2) (2, 46)");
    test.checkForeach(inside, outside, 2, 3, 6, 5);
  });
  tests.add("Foreach Point In Boundary Test 4", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    final List<qt.QTPointImpl> inside = points.parse("(15, 15)");
    final List<qt.QTPointImpl> outside = points.parse("(0, 0) (30, 30)");
    test.checkForeach(inside, outside, 10, 10, 20, 20);
  });
  tests.add("Foreach Point In Boundary Test 5", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    final List<qt.QTPointImpl> inside = points.parse("(15, 15)");
    final List<qt.QTPointImpl> outside = points.parse("");
    test.checkForeach(inside, outside, 10, 10, 20, 20);
  });
}

void addInsertEdgesTests(TestManager tests) {
  tests.add("Insert Edges Basic Test", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertPoint(0, 1);
    test.insertPoint(1, 2);
    test.insertPoint(2, 3);
    test.insertPoint(8, 3);
    test.insertPoint(9, 2);
    test.insertPoint(10, 1);
    test.insertEdge(0, 1, 10, 1);
    test.insertEdge(1, 2, 9, 2);
    test.insertEdge(2, 3, 8, 3);
    test.showPlot();
  });
  tests.add("Insert Edges Test", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertEdge(0, 0, 0, 10);
    test.insertEdge(0, 10, 10, 10);
    test.insertEdge(10, 10, 10, 0);
    test.insertEdge(10, 0, 0, 0);
    test.insertEdge(5, 5, 5, 15);
    test.insertEdge(5, 15, 15, 15);
    test.insertEdge(15, 15, 15, 5);
    test.insertEdge(15, 5, 5, 5);
    test.insertEdge(0, 0, 5, 5);
    test.insertEdge(0, 10, 5, 15);
    test.insertEdge(10, 10, 15, 15);
    test.insertEdge(10, 0, 15, 5);
    test.showPlot();
  });
}

void addInsertPointTests(TestManager tests) {
  tests.add("Basic Point Insertion", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertPoint(0, 0);
    test.insertPoint(0, 10);
    test.insertPoint(10, 10);
    test.insertPoint(10, 0);
    test.insertPoint(5, 5);
    test.insertPoint(5, 15);
    test.insertPoint(15, 15);
    test.insertPoint(15, 5);
    test.showPlot();
  });
  tests.add("Another Point Insertion", (TestArgs args) {
    final QuadTreeTester test = QuadTreeTester(args);
    test.insertPoint(0, -1);
    test.insertPoint(0, 1);
    test.insertPoint(10, -1);
    test.insertPoint(10, 1);
    test.showPlot();
  });
}

void addOverlapsTests(TestManager tests) {
  tests.add("Overlaps Test", (TestArgs args) {
    final qt.QTBoundaryImpl rectA = qt.QTBoundaryImpl(8, 8, 15, 15);
    final qt.QTBoundaryImpl rectB = qt.QTBoundaryImpl(0, 8, 7, 15);
    final qt.QTBoundaryImpl rectC = qt.QTBoundaryImpl(8, 0, 15, 7);
    final qt.QTBoundaryImpl rectD = qt.QTBoundaryImpl(0, 0, 7, 7);
    final qt.QTEdgeImpl edgeA = qt.QTEdgeImpl(qt.QTPointImpl(-2, -4), qt.QTPointImpl(12, 14));
    overlapTest(args, rectA, edgeA, true);
    overlapTest(args, rectB, edgeA, true);
    overlapTest(args, rectC, edgeA, false);
    overlapTest(args, rectD, edgeA, true);
    final qt.QTBoundaryImpl rectE = qt.QTBoundaryImpl(-15, 32, 0, 47);
    final qt.QTEdgeImpl edgeB = qt.QTEdgeImpl(qt.QTPointImpl(4, 33), qt.QTPointImpl(-1, 52));
    overlapTest(args, rectE, edgeB, true);
  });
}

void overlapTest(TestArgs args, qt.QTBoundary bounds, qt.QTEdge edge, bool overlaps) {
  final bool result = bounds.overlapsEdge(edge);
  if (result != overlaps) {
    args.error("Failed: Expected overlap ($overlaps) didn't match result:\n" +
        "   Bounds: $bounds\n" +
        "   Edge:   $edge\n\n");
    final Plotter plot = makePlotter();
    plot.addRects([bounds.xmin.toDouble(), bounds.ymin.toDouble(), bounds.width.toDouble(), bounds.height.toDouble()])
      ..addColor(0.8, 0.0, 0.0)
      ..addPointSize(4.0);
    plot.addLines([edge.x1.toDouble(), edge.y1.toDouble(), edge.x2.toDouble(), edge.y2.toDouble()])
      ..addColor(0.0, 0.8, 0.0)
      ..addPointSize(4.0);
    plot.updateBounds();
    plot.focusOnData();
    plot.mouseHandles.add(makeMouseCoords(plot));
    PlotSvg.fromElem(args.addDiv(), plot);
  } else {
    args.info("Passed: $bounds.overlaps($edge) => $overlaps");
  }
}

void addPolygonClipperTests(TestManager tests) {
  tests.add("Polygon Clipper 1 - No change", (TestArgs args) {
    _testClipper(args, "(0, 5) (0, 0) (5, 0) (5, 5)", ["(0, 5) (0, 0) (5, 0) (5, 5)"]);
  });
  tests.add("Polygon Clipper 2 - Change to CCW", (TestArgs args) {
    _testClipper(args, "(0, 0) (0, 5) (5, 5) (5, 0)", ["(5, 5) (0, 5) (0, 0) (5, 0)"]);
  });
  tests.add("Polygon Clipper 3 - Bowtie", (TestArgs args) {
    _testClipper(args, "(0, 0) (0, 5) (5, 0) (5, 5)", ["(3, 3) (5, 0) (5, 5)", "(0, 5) (0, 0) (3, 3)"]);
  });
  tests.add("Polygon Clipper 4 - Bowtie reversed", (TestArgs args) {
    _testClipper(args, "(0, 5) (0, 0) (5, 5) (5, 0)", ["(0, 5) (0, 0) (3, 3)", "(5, 5) (3, 3) (5, 0)"]);
  });
  tests.add("Polygon Clipper 5 - Big bowtie", (TestArgs args) {
    _testClipper(args, "(-59, 81) (-23, 32) (-88, 38) (-90, 75) (-35, 69) (-39, 24) (-78, 84)", [
      "(-59, 81) (-78, 84) (-71, 73) (-90, 75) (-88, 38) (-45, 34)..." +
          "(-39, 24) (-38, 33) (-23, 32) (-37, 50) (-35, 69) (-52, 71)",
      "(-52, 71) (-71, 73) (-45, 34) (-38, 33) (-37, 50)"
    ]);
  });
  tests.add("Polygon Clipper 6 - Big bowtie reversed", (TestArgs args) {
    _testClipper(args, "(-78, 84) (-39, 24) (-35, 69) (-90, 75) (-88, 38) (-23, 32) (-59, 81)", [
      "(-71, 73) (-45, 34) (-38, 33) (-37, 50) (-52, 71)",
      "(-78, 84) (-71, 73) (-90, 75) (-88, 38) (-45, 34) (-39, 24)..." +
          "(-38, 33) (-23, 32) (-37, 50) (-35, 69) (-52, 71) (-59, 81)"
    ]);
  });
  tests.add("Polygon Clipper 7 - Repeats", (TestArgs args) {
    _testClipper(args, "(-68, 67) (-68, 67) (-24, 16) (2, 57) (-68, 67)", ["(-68, 67) (-24, 16) (2, 57)"]);
  });
  tests.add("Polygon Clipper 8 - Degenerate", (TestArgs args) {
    _testClipper(args, "(-40, 21) (-40, 21) (0, 0)", []);
  });
  tests.add("Polygon Clipper 9 - Zero Area", (TestArgs args) {
    _testClipper(args, "(-40, 20) (-20, 10) (0, 0)", []);
  });
}

void _testClipper(TestArgs args, String input, List<String> results, [bool plot = true]) {
  final List<qt.QTPointImpl> inputPnts = points.parse(input);
  final List<List<qt.QTPointImpl>> expPnts = <List<qt.QTPointImpl>>[];
  for (int i = 0; i < results.length; ++i) {
    expPnts.add(points.parse(results[i]));
  }
  final List<List<qt.QTPoint>> resultPnts = PolygonClipper.Clip(inputPnts);
  if (expPnts.length != resultPnts.length) {
    args.error("Lengths do not match: expected ${expPnts.length} but got ${resultPnts.length}:\n");
    args.info("input: ${points.format(inputPnts)}\n");
    for (int i = 0; i < max(expPnts.length, resultPnts.length); i++) {
      if (i < expPnts.length) args.info("exp $i: ${points.format(expPnts[i])}\n");
      if (i < resultPnts.length) args.info("got $i: ${points.format(resultPnts[i])}\n");
    }
    // ignore: parameter_assignments
    plot = true;
  } else {
    bool failed = false;
    for (int i = 0; i < expPnts.length; ++i) {
      if (!points.equals2(expPnts[i], resultPnts[i])) {
        failed = true;
        break;
      }
    }
    if (failed) {
      // ignore: parameter_assignments
      plot = true;
      args.error("Some results did not match:\n");
      args.info("input: ${points.format(inputPnts)}\n");
      for (int i = 0; i < expPnts.length; ++i) {
        if (points.equals(expPnts[i], resultPnts[i])) {
          args.info("same $i: ${points.format(expPnts[i])}\n");
        } else {
          args.info("exp  $i: ${points.format(expPnts[i])}\n");
          args.info("got  $i: ${points.format(resultPnts[i])}\n");
        }
      }
    }
  }
  if (plot) {
    final QuadTreePlotter plot = QuadTreePlotter();
    final Polygon inputPoly = plot.plotter.addGroup("Input").addPolygon([])
      ..addColor(0.0, 0.0, 0.0)
      ..addDirected(true);
    for (int i = 0; i < inputPnts.length; ++i) {
      inputPoly.add([inputPnts[i].x.toDouble(), inputPnts[i].y.toDouble()]);
    }
    for (int i = 0; i < resultPnts.length; ++i) {
      final double f = i / resultPnts.length;
      final Polygon poly = plot.plotter.addGroup("Result $i").addPolygon([])
        ..addColor(0.0, 1.0 - f, f)
        ..addDirected(true);
      final List<qt.QTPoint> pnts = resultPnts[i];
      for (int j = 0; j < pnts.length; ++j) {
        poly.add([pnts[j].x.toDouble(), pnts[j].y.toDouble()]);
      }
    }
    final html.DivElement div = args.addDiv();
    plot.plotter.updateBounds();
    plot.plotter.focusOnData();
    PlotSvg.fromElem(div, plot.plotter);
  }
}

void addRegionMapTests(TestManager tests) {
  tests.add("Region Map 1", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([0, 0, 0, 10, 10, 10, 10, 0]);
    test.add([15, 5, 15, 15, 5, 15, 5, 5]);
    test.pointTest(0, 0, 0);
    test.pointTest(1, 1, 1);
    test.pointTest(4, 4, 1);
    test.pointTest(5, 5, 1);
    test.pointTest(6, 6, 2);
    test.pointTest(9, 9, 2);
    test.pointTest(10, 10, 2);
    test.pointTest(11, 11, 2);
    test.pointTest(14, 14, 2);
    test.pointTest(15, 15, 0);
    test.pointTest(16, 16, 0);
    test.pointTest(4, 11, 0);
    test.pointTest(6, 11, 2);
    test.pointTest(4, 9, 1);
    test.pointTest(6, 9, 2);
    test.pointTest(11, 4, 0);
    test.pointTest(11, 6, 2);
    test.pointTest(9, 4, 1);
    test.pointTest(9, 6, 2);
    test.showPlot();
  });
  tests.add("Region Map 2", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([0, 3, 0, 7, 3, 10, 7, 10, 10, 7, 10, 3, 7, 0, 3, 0]);
    test.add([5, 8, 5, 12, 8, 15, 12, 15, 15, 12, 15, 8, 12, 5, 8, 5]);
    test.pointTest(4, 11, 0);
    test.pointTest(6, 11, 2);
    test.pointTest(4, 9, 1);
    test.pointTest(6, 9, 2);
    test.pointTest(11, 4, 0);
    test.pointTest(11, 6, 2);
    test.pointTest(9, 4, 1);
    test.pointTest(9, 6, 2);
    test.showPlot();
  });
  tests.add("Region Map 3", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([0, 0, 0, 40, 10, 40, 10, 0]);
    test.add([0, 0, 0, 10, 30, 10, 30, 30, 0, 30, 0, 40, 40, 40, 40, 0]);
    test.pointTest(-2, 5, 0);
    test.pointTest(2, 5, 2);
    test.pointTest(8, 5, 2);
    test.pointTest(12, 5, 2);
    test.pointTest(28, 5, 2);
    test.pointTest(34, 5, 2);
    test.pointTest(42, 5, 0);
    test.pointTest(-2, 20, 0);
    test.pointTest(2, 20, 1);
    test.pointTest(8, 20, 1);
    test.pointTest(12, 20, 0);
    test.pointTest(28, 20, 0);
    test.pointTest(34, 20, 2);
    test.pointTest(42, 20, 0);
    test.pointTest(-2, 35, 0);
    test.pointTest(2, 35, 2);
    test.pointTest(8, 35, 2);
    test.pointTest(12, 35, 2);
    test.pointTest(28, 35, 2);
    test.pointTest(34, 35, 2);
    test.pointTest(42, 35, 0);
    test.showPlot();
  });
  tests.add("Region Map 4", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([10, 0, 0, 0, 0, 4, 6, 5, 0, 6, 0, 10, 10, 10]);
    test.add([3, 0, 3, 10, 10, 10, 10, 0]);
    test.pointTest(4, 7, 2);
    test.pointTest(4, 5, 2);
    test.pointTest(4, 3, 2);
    test.pointTest(2, 7, 1);
    test.pointTest(2, 5, 0);
    test.pointTest(2, 3, 1);
    test.showPlot();
  });
  tests.add("Region Map 5", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([0, 2, 0, 4, 4, 4, 4, 6, 0, 6, 0, 8, 10, 8, 10, 2]);
    test.add([2, 0, 2, 10, 8, 10, 8, 0]);
    test.pointTest(1, 1, 0);
    test.pointTest(1, 3, 1);
    test.pointTest(1, 5, 0);
    test.pointTest(1, 7, 1);
    test.pointTest(1, 9, 0);
    test.pointTest(3, 1, 2);
    test.pointTest(3, 3, 2);
    test.pointTest(3, 5, 2);
    test.pointTest(3, 7, 2);
    test.pointTest(3, 9, 2);
    test.pointTest(9, 1, 0);
    test.pointTest(9, 3, 1);
    test.pointTest(9, 5, 1);
    test.pointTest(9, 7, 1);
    test.pointTest(9, 9, 0);
    test.showPlot();
  });
  tests.add("Region Map 6", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([3, 0, 3, 15, 12, 15, 12, 0]);
    test.add([0, 0, 3, 3, 3, 15, 12, 15, 12, 0]);
    test.pointTest(2, 1, 2);
    test.pointTest(3, 1, 2);
    test.pointTest(4, 1, 2);
    test.pointTest(1, 2, 0);
    test.showPlot();
  });
  tests.add("Region Map 7 - Two identical regions", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([15, 5, 15, 15, 5, 15, 5, 5]);
    test.add([15, 5, 15, 15, 5, 15, 5, 5]);
    test.pointTest(10, 10, 2);
    test.showPlot();
  });
  tests.add("Region Map 8 - Overwrite a smaller region", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([10, 5, 10, 10, 5, 10, 5, 5]);
    test.add([15, 0, 15, 15, 0, 15, 0, 0]);
    test.pointTest(-2, -2, 0);
    test.pointTest(2, 2, 2);
    test.pointTest(7, 7, 2);
    test.pointTest(12, 12, 2);
    test.pointTest(17, 17, 0);
    test.showPlot();
  });
  tests.add("Region Map 9 - Add a hole", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([15, 0, 15, 15, 0, 15, 0, 0]);
    test.add([10, 5, 10, 10, 5, 10, 5, 5]);
    test.pointTest(-2, 2, 0);
    test.pointTest(2, 2, 1);
    test.pointTest(6, 2, 1);
    test.pointTest(9, 2, 1);
    test.pointTest(12, 2, 1);
    test.pointTest(16, 2, 0);
    test.pointTest(-2, 8, 0);
    test.pointTest(2, 8, 1);
    test.pointTest(6, 8, 2);
    test.pointTest(9, 8, 2);
    test.pointTest(12, 8, 1);
    test.pointTest(16, 8, 0);
    test.showPlot();
  });
  tests.add("Region Map 10 - Four corners", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([0, 10, 100, 10, 50, 60]);
    test.add([90, 0, 90, 100, 40, 50]);
    test.add([100, 90, 0, 90, 50, 40]);
    test.add([10, 100, 10, 0, 60, 50]);
    test.pointTest(50, 50, 4);
    test.pointTest(50, 30, 1);
    test.pointTest(70, 50, 2);
    test.pointTest(50, 70, 3);
    test.pointTest(30, 50, 4);
    test.pointTest(20, 20, 4);
    test.pointTest(80, 20, 2);
    test.pointTest(80, 80, 3);
    test.pointTest(20, 80, 4);
    test.showPlot();
  });
  tests.add("Region Map 11 - Create a bounded region", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([0, 0, 0, 40, 10, 40, 10, 0], 1);
    test.add([0, 0, 0, 10, 30, 10, 30, 30, 0, 30, 0, 40, 40, 40, 40, 0], 1);
    test.pointTest(-2, 5, 0);
    test.pointTest(2, 5, 1);
    test.pointTest(8, 5, 1);
    test.pointTest(12, 5, 1);
    test.pointTest(28, 5, 1);
    test.pointTest(34, 5, 1);
    test.pointTest(42, 5, 0);
    test.pointTest(-2, 20, 0);
    test.pointTest(2, 20, 1);
    test.pointTest(8, 20, 1);
    test.pointTest(12, 20, 0);
    test.pointTest(28, 20, 0);
    test.pointTest(34, 20, 1);
    test.pointTest(42, 20, 0);
    test.pointTest(-2, 35, 0);
    test.pointTest(2, 35, 1);
    test.pointTest(8, 35, 1);
    test.pointTest(12, 35, 1);
    test.pointTest(28, 35, 1);
    test.pointTest(34, 35, 1);
    test.pointTest(42, 35, 0);
    test.showPlot();
  });
  tests.add("Region Map 12 - Two triangles, boundary issue", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([9, 59, -11, 54, -7, 37], 1);
    test.add([17, 47, -1, 52, 4, 33], 1);
    test.pointTest(5, 35, 1);
    test.showPlot();
  });
  tests.add("Region Map 13 - Overlapping lines of same regions", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([5, 0, 5, 5, 3, 0], 1);
    test.add([5, 0, 5, 5, 7, 5], 1);
    test.pointTest(4, 1, 1);
    test.pointTest(6, 4, 1);
    test.showPlot();
  });
  tests.add("Region Map 14 - Overlapping lines of different regions", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([5, 0, 5, 5, 3, 0], 1);
    test.add([5, 0, 5, 5, 7, 5], 2);
    test.pointTest(4, 1, 1);
    test.pointTest(6, 4, 2);
    test.showPlot();
  });
  tests.add("Region Map 15 - Repeat point", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([5, 0, 5, 0, 5, 5, 3, 0], 1);
    test.pointTest(4, 1, 1);
    test.showPlot();
  });
  tests.add("Region Map 16 - Bow tie", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([-36, 42, -36, 42, -38, -10, 32, 53, 49, -17], 1);
    test.add([-15, 60, -15, 60, 13, 61, 19, -35, -17, -39], 1);
    test.pointTest(0, 50, 1);
    test.showPlot();
  });
  tests.add("Region Map 17 - Sailboat", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([-6, 7, 0, 0, 6, 7], 1);
    test.add([-2, 5, 2, 5, 0, 10], 1);
    final qt.PointNode pnt = test._map.tree.findPoint(qt.QTPointImpl(-2, 5));
    if (pnt != null) test._args.error("Point ${pnt.toString()} should have been removed");
    test.showPlot();
  });
  tests.add("Region Map 18 - Two large triangles", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([418, 74, 545, 298, 294, 296], 1);
    test.add([321, 160, 444, 373, 199, 371], 2);
    test.pointTest(402, 298, 0);
    test.pointTest(402, 296, 1);
    test.pointTest(399, 298, 2);
    test.showPlot();
  });
  tests.add("Region Map 19 - Three large triangles", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([418, 74, 545, 298, 294, 296], 1);
    test.add([321, 160, 444, 373, 199, 371], 2);
    test.add([425, 187, 549, 406, 302, 408], 3);
    test.pointTest(380, 240, 1);
    test.pointTest(410, 240, 3);
    final qt.QTEdgeNodeImpl edge = test._map.tree.findNearestEdge(qt.QTPointImpl(406, 221));
    final EdgeSide side = edge.data as EdgeSide;
    if ((side.left != 3) || (side.right != 1)) test._args.error("Expected [3|1] but got $side");
    test.showPlot();
  });
  tests.add("Region Map 20 - Complex bow tie", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([10, 10, 10, -10, -20, 0], 1);
    test.add([-30, 10, -30, -10, -1, -1], 2);
    test.add([-26, 4, -26, -6, -10, 0], 3);
    test.add([4, 5, -22, -1, 4, -5], 4);
    test.pointTest(7, 0, 1);
    test.pointTest(0, 5, 1);
    test.pointTest(-2, -1, 4);
    test.pointTest(-23, -3, 3);
    test.pointTest(-23, 1, 3);
    test.pointTest(-18, 3, 2);
    test.pointTest(-28, 6, 2);
    test.pointTest(-21, -6, 2);
    test.pointTest(-6, 4, 1);
    test.pointTest(0, -5, 1);
    test.showPlot();
  });
  tests.add("Region Map 21 - Three polygons", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([-91, 53, -34, 43, 10, 5, -11, -44, -66, -37, -96, -2], 1);
    test.add([-39, 58, -47, 16, -41, -2, 43, -8, 34, 41], 2);
    test.add([-6, 13, -28, -22, -36, -55, 17, -62, 58, -35, 59, 25], 3);
    test.pointTest(42, 32, 0);
    test.pointTest(66, 15, 0);
    test.pointTest(66, -12, 0);
    test.pointTest(44, -4, 3);
    test.pointTest(32, 31, 2);
    test.pointTest(41, 39, 0);
    test.showPlot();
  });
  tests.add("Region Map 22 - Three large triangles with a hole", (TestArgs args) {
    final RegionMapTester test = RegionMapTester(args);
    test.add([20, 38, 264, 29, 140, 246], 1);
    test.add([154, 58, 398, 58, 275, 268], 2);
    test.add([95, 203, 338, 203, 216, 412], 3);
    test.pointTest(198, 241, 3);
    test.pointTest(139, 216, 3);
    test.pointTest(270, 222, 3);
    test.pointTest(156, 164, 1);
    test.pointTest(201, 104, 2);
    test.pointTest(246, 163, 2);
    test.pointTest(202, 180, 0);
    test.showPlot();
  });
}

class RegionMapTester {
  final TestArgs _args;
  Regions _map;
  List<List<int>> _polygons;
  List<int> _regions;
  Map<int, List<int>> _points;
  Map<int, List<int>> _errPnts;
  List<List<double>> _colors;

  RegionMapTester(this._args) {
    this._map = Regions();
    this._polygons = <List<int>>[];
    this._regions = <int>[];
    this._points = <int, List<int>>{};
    this._errPnts = <int, List<int>>{};
    this._colors = <List<double>>[];
    this._addColor(0.0, 0.0, 0.0);
    this._addColor(1.0, 0.0, 0.0);
    this._addColor(0.0, 1.0, 0.0);
    this._addColor(0.0, 0.0, 1.0);
    this._addColor(0.6, 0.6, 0.0);
    this._addColor(0.6, 0.0, 0.6);
    this._addColor(0.0, 0.6, 0.6);
  }

  void _addColor(double red, double green, double blue) {
    this._colors.add([red, green, blue]);
  }

  void add(List<int> polygon, [int region = -1]) {
    if (region < 0) {
      // ignore: parameter_assignments
      region = this._polygons.length + 1;
    }
    this._polygons.add(polygon);
    this._regions.add(region);
    this._map.addRegionWithCoords(region, polygon);
    if (!this._map.tree.validate()) this._args.fail();
  }

  void _addPoint(Map<int, List<int>> points, int x, int y, int value) {
    List<int> pnts = points[value];
    pnts ??= <int>[];
    pnts.add(x);
    pnts.add(y);
    points[value] = pnts;
  }

  void pointTest(int x, int y, int exp) {
    this._addPoint(this._points, x, y, exp);
    final int result = this._map.getRegion(qt.QTPointImpl(x, y));
    if (exp != result) {
      this._addPoint(this._errPnts, x, y, result);
      this._args.error("Expected $exp but got $result from $x, $y.\n");
    }
  }

  PlotSvg showPlot() {
    final QuadTreePlotter plot = QuadTreePlotter();
    plot.addTree(this._map.tree);
    final int count = this._polygons.length;
    final Group initPolys = plot.plotter.addGroup("Initial Polygons");
    for (int i = 0; i < count; i++) {
      final List<int> poly = this._polygons[i];
      final int region = this._regions[i];
      if (poly != null) {
        final List<double> clr = this._colors[region];
        final Polygon polyItem = initPolys.addGroup("Polygon #$i").addPolygon([])
          ..addColor(clr[0], clr[1], clr[2])
          ..addDirected(true);
        for (int j = 0; j < poly.length - 1; j += 2) {
          polyItem.add([poly[j].toDouble(), poly[j + 1].toDouble()]);
        }
      }
    }
    final Group finalPolys = plot.plotter.addGroup("Final Polygons");
    this._map.tree.foreachEdge(
          _LineCollector(
            List<Lines>.generate(
              count + 1,
              (final i) {
                final clr = this._colors[i];
                return finalPolys.addGroup("#$i Edges").addLines([])
                  ..addColor(clr[0], clr[1], clr[2])
                  ..addDirected(true);
              },
            ),
          ),
        );
    final Group errPntGroup = plot.plotter.addGroup("Error Points");
    for (int i = 0; i <= count; i++) {
      final List<int> points = this._errPnts[i];
      if (points != null) {
        final List<double> clr = this._colors[i];
        final Points pnts = errPntGroup.addPoints([])
          ..addColor(clr[0], clr[1], clr[2])
          ..addPointSize(6.0);
        for (int j = 0; j < points.length; j += 2) {
          pnts.add([points[j].toDouble(), points[j + 1].toDouble()]);
        }
      }
    }
    final Group testPnts = plot.plotter.addGroup("Test Points");
    for (int i = 0; i <= count; i++) {
      final List<int> points = this._points[i];
      if (points != null) {
        final List<double> clr = this._colors[i];
        final Points pnts = testPnts.addPoints([])
          ..addColor(clr[0], clr[1], clr[2])
          ..addPointSize(3.0);
        for (int j = 0; j < points.length; j += 2) {
          pnts.add([points[j].toDouble(), points[j + 1].toDouble()]);
        }
      }
    }
    final html.DivElement div = this._args.addDiv();
    plot.plotter.updateBounds();
    plot.plotter.focusOnData();
    return PlotSvg.fromElem(div, plot.plotter);
  }
}

class _LineCollector implements qt.QTEdgeHandler {
  final List<Lines> _lines;

  _LineCollector(this._lines);

  @override
  bool handle(
    final qt.QTEdge edge,
  ) {
    final EdgeSide pair = edge.data;
    double dx = edge.dx.toDouble();
    double dy = edge.dy.toDouble();
    final double length = sqrt(dx * dx + dy * dy);
    if (length > 1.0e-12) {
      const double height = 0.1;
      dx = dx * height / length;
      dy = dy * height / length;
      this._lines[pair.left].add([edge.x1 - dy, edge.y1 + dx, edge.x2 - dy, edge.y2 + dx]);
      this._lines[pair.right].add([edge.x1 + dy, edge.y1 - dx, edge.x2 + dy, edge.y2 - dx]);
    }
    return true;
  }
}

void addRegionTests(
  final TestManager tests,
) =>
    tests.add("Boundary Region Test", (TestArgs args) {
      final qt.QTBoundaryImpl rect = qt.QTBoundaryImpl(-2, -2, 2, 2);
      regionTest(args, rect, 0, 0, qt.BoundaryRegionImpl.Inside);
      regionTest(args, rect, 2, 2, qt.BoundaryRegionImpl.Inside);
      regionTest(args, rect, 2, -2, qt.BoundaryRegionImpl.Inside);
      regionTest(args, rect, -2, 2, qt.BoundaryRegionImpl.Inside);
      regionTest(args, rect, -2, -2, qt.BoundaryRegionImpl.Inside);
      regionTest(args, rect, 0, 4, qt.BoundaryRegionImpl.North);
      regionTest(args, rect, 4, 0, qt.BoundaryRegionImpl.East);
      regionTest(args, rect, 0, -4, qt.BoundaryRegionImpl.South);
      regionTest(args, rect, -4, 0, qt.BoundaryRegionImpl.West);
      regionTest(args, rect, 4, 4, qt.BoundaryRegionImpl.NorthEast);
      regionTest(args, rect, 4, -4, qt.BoundaryRegionImpl.SouthEast);
      regionTest(args, rect, -4, 4, qt.BoundaryRegionImpl.NorthWest);
      regionTest(args, rect, -4, -4, qt.BoundaryRegionImpl.SouthWest);
    });

void regionTest(
  final TestArgs args,
  final qt.QTBoundaryImpl rect,
  final int x,
  final int y,
  final qt.BoundaryRegion expRegion,
) {
  final qt.BoundaryRegion result = rect.region(qt.QTPointImpl(x, y));
  if (result != expRegion) {
    args.error("Failed: Unexpected result from region:\n" +
        "   Boundary: $rect\n" +
        "   Point:    $x, $y\n" +
        "   Expected: $expRegion, $expRegion\n" +
        "   Result:   $result, $result\n\n");
    final Plotter plot = makePlotter();
    plot.addRects([rect.xmin.toDouble(), rect.ymin.toDouble(), rect.width.toDouble(), rect.height.toDouble()])
      ..addColor(0.8, 0.0, 0.0)
      ..addPointSize(4.0);
    plot.addPoints([x.toDouble(), y.toDouble()])
      ..addColor(0.0, 0.8, 0.0)
      ..addPointSize(4.0);
    plot.updateBounds();
    plot.focusOnData();
    PlotSvg.fromElem(args.addDiv(), plot);
  } else {
    args.info("Passed: BoundaryRegion($rect, [$x, $y]) => $expRegion\n\n");
  }
}
