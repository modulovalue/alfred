import 'dart:math';

import '../../../framework/mouse/impl/mouse_coordinates.dart';
import '../../../framework/plotter_item/impl/lines.dart';
import '../../../framework/plotter_item/impl/plotter.dart';
import '../../../framework/plotter_item/impl/points.dart';
import '../../maps/polygon_clipper.dart';
import '../../maps/regions.dart';
import '../../plotter.dart';
import '../basic/boundary_region.dart';
import '../basic/qt_edge.dart';
import '../basic/qt_edge_handler.dart';
import '../basic/qt_point_handler.dart';
import '../boundary.dart';
import '../node/point/interface.dart';
import '../point/ops/distance2.dart';
import '../point/ops/equals.dart';
import '../point/ops/intersect.dart';
import '../point/qt_point.dart';
import '../quadtree/quadtree.dart';

/// A test framework agnostic test suite
/// that supports different test frameworks.
void runQuadtreeTestSuite<T extends TestArgs>({
  required final void Function(String, void Function(T)) runTest,
  required final QuadTreeTestSuite Function(T) suite,
}) {
  runTest("Edge Intersect Test", (final args) {
    QTEdgeImpl e(
      final int x1,
      final int y1,
      final int x2,
      final int y2,
    ) =>
        QTEdgeImpl(
          QTPointImpl(x1, y1),
          QTPointImpl(x2, y2),
          null,
        );
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 1), e(0, 0, 1, 1), "Hit Same null None None");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 1), e(1, 1, 0, 0), "Hit Opposite null None None");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 1), e(1, 1, 2, 2), "Hit Collinear [1, 1] AtEnd AtStart");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 1), e(2, 2, 1, 1), "Hit Collinear [1, 1] AtEnd AtEnd");
    suite(args).edgeIntersectTest(args, e(1, 1, 0, 0), e(1, 1, 2, 2), "Hit Collinear [1, 1] AtStart AtStart");
    suite(args).edgeIntersectTest(args, e(1, 1, 0, 0), e(2, 2, 1, 1), "Hit Collinear [1, 1] AtStart AtEnd");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 0), e(1, 0, 2, 0), "Hit Collinear [1, 0] AtEnd AtStart");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 0), e(2, 0, 1, 0), "Hit Collinear [1, 0] AtEnd AtEnd");
    suite(args).edgeIntersectTest(args, e(1, 0, 0, 0), e(1, 0, 2, 0), "Hit Collinear [1, 0] AtStart AtStart");
    suite(args).edgeIntersectTest(args, e(1, 0, 0, 0), e(2, 0, 1, 0), "Hit Collinear [1, 0] AtStart AtEnd");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 0), e(2, 0, 3, 0), "Miss Collinear null None None");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 0), e(3, 0, 2, 0), "Miss Collinear null None None");
    suite(args).edgeIntersectTest(args, e(1, 0, 0, 0), e(2, 0, 3, 0), "Miss Collinear null None None");
    suite(args).edgeIntersectTest(args, e(1, 0, 0, 0), e(3, 0, 2, 0), "Miss Collinear null None None");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 1), e(2, 2, 3, 3), "Miss Collinear null None None");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 1), e(3, 3, 2, 2), "Miss Collinear null None None");
    suite(args).edgeIntersectTest(args, e(1, 1, 0, 0), e(2, 2, 3, 3), "Miss Collinear null None None");
    suite(args).edgeIntersectTest(args, e(1, 1, 0, 0), e(3, 3, 2, 2), "Miss Collinear null None None");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 1), e(1, 1, 0, 2), "Hit Point [1, 1] AtEnd AtStart");
    suite(args).edgeIntersectTest(args, e(0, 0, 1, 1), e(0, 2, 1, 1), "Hit Point [1, 1] AtEnd AtEnd");
    suite(args).edgeIntersectTest(args, e(1, 1, 0, 0), e(1, 1, 0, 2), "Hit Point [1, 1] AtStart AtStart");
    suite(args).edgeIntersectTest(args, e(1, 1, 0, 0), e(0, 2, 1, 1), "Hit Point [1, 1] AtStart AtEnd");
    suite(args).edgeIntersectTest(args, e(0, 2, 4, 2), e(2, 0, 2, 4), "Hit Point [2, 2] InMiddle InMiddle");
    suite(args).edgeIntersectTest(args, e(0, 2, 4, 2), e(2, 0, 2, 2), "Hit Point [2, 2] InMiddle AtEnd");
    suite(args).edgeIntersectTest(args, e(0, 2, 4, 2), e(2, 2, 2, 4), "Hit Point [2, 2] InMiddle AtStart");
    suite(args).edgeIntersectTest(args, e(0, 2, 2, 2), e(2, 0, 2, 4), "Hit Point [2, 2] AtEnd InMiddle");
    suite(args).edgeIntersectTest(args, e(2, 2, 4, 2), e(2, 0, 2, 4), "Hit Point [2, 2] AtStart InMiddle");
  });
  runTest("Find All Intersections Test", (final args) {
    final test = QuadTreeTester(args);
    test.insertEdge(0, 0, 10, 0);
    test.insertEdge(10, 0, 10, 10);
    test.insertEdge(10, 10, 0, 10);
    test.insertEdge(0, 10, 0, 0);
    suite(args).findAllIntersections(test, -2, -4, 12, 14, 2);
    suite(args).findAllIntersections(test, -2, 4, 12, 14, 2);
    suite(args).findAllIntersections(test, -2, 4, 5, 5, 1);
    suite(args).findAllIntersections(test, 5, 5, 12, 14, 1);
    suite(args).findAllIntersections(test, 3, 6, 6, 3, 0);
    suite(args).findAllIntersections(test, 0, 10, 10, 10, 3);
    suite(args).findAllIntersections(test, 3, 10, 6, 10, 1);
    suite(args).findAllIntersections(test, -3, 10, 12, 10, 3);
    suite(args).findAllIntersections(test, 5, 5, 15, 5, 1);
  });
  runTest("Find Intersections Incoming Lines Test", (final args) {
    final test = QuadTreeTester(args);
    test.insertEdge(50, 60, 100, 10);
    test.insertEdge(100, 10, 0, 10);
    test.insertEdge(0, 10, 50, 60);
    suite(args).findFirstIntersection(test, 90, 20, 90, 0, 100, 10, 0, 10);
  });
  runTest("Find Nearest Point Basic Test", (final args) {
    final test = QuadTreeTester(args);
    test.insertPoints("(-3, -3) (-3, 3) (3, 3) (3, -3)");
    suite(args).checkFindNearestPoint(test, 0, 0, 3, 3);
  });
  runTest("Find Nearest Point Test", (final args) {
    final test = QuadTreeTester(args);
    test.insertPoints("(1, 5) (5, 1) (3, 3) (2, 6) (8, 8) (4, 1) (10, 10) (0, 10) (10, 0) (0, 0)..." +
        "(0, 1) (0, 2) (1, 0) (2, 0) (10, 1) (10, 8) (7, 10) (4, 10) (10, 12)..." +
        "(20, 21) (12, 2) (1, 12) (13, 5) (-1, 3) (11, 11) (-1, -1)");
    suite(args).checkFindNearestPoint(test, 0, 0, 0, 0);
    suite(args).checkFindNearestPoint(test, 10, 10, 10, 10);
    suite(args).checkFindNearestPoint(test, 2, 2, 3, 3);
    suite(args).checkFindNearestPoint(test, 0, 2, 0, 2);
    suite(args).checkFindNearestPoint(test, 14, 14, 11, 11);
    suite(args).checkFindNearestPoint(test, 42, 31, 20, 21);
    suite(args).checkFindNearestPoint(test, -2, 8, 0, 10);
  });
  runTest("First Left Edge Basic Test", (final args) {
    final test = QuadTreeTester(args);
    test.insertPolygon("(5, 5) (10, 5) (15, 5) (15, 15) (5, 15) (5, 10)");
    suite(args).checkFirstLeftEdge(test, 10, 10, 5, 10, 5, 5);
  });
  runTest("First Left Edge Test", (final args) {
    final test = QuadTreeTester(args);
    test.insertPolygon("(0, 0) (0, 10) (30, 10) (30, 30) (0, 30) (0, 40) (40, 40) (40, 0)");
    suite(args).checkFirstLeftEdge(test, 10, 5, 0, 0, 0, 10);
  });
  runTest("Foreach Point In Boundary Test 1", (final args) {
    final test = QuadTreeTester(args);
    final inside = _Points.parse("(1, 5) (5, 1) (3, 3) (2, 6) (8, 8) (4, 1) (10, 10) (0, 10) (10, 0)..." +
        "(0, 0) (0, 1) (0, 2) (1, 0) (2, 0) (10, 1) (10, 8) (7, 10) (4, 10)");
    final outside = _Points.parse("(10, 12) (20, 21) (12, 2) (1, 12) (13, 5) (-1, 3) (11, 11) (-1, -1)");
    suite(args).checkForeach(test, inside, outside, 0, 0, 10, 10);
  });
  runTest("Foreach Point In Boundary Test 2", (final args) {
    final test = QuadTreeTester(args);
    final inside = _Points.parse("(3, 3)");
    final outside = _Points.parse("(10, 12) (20, 21) (12, 2) (1, 12) (13, 5) (-1, 3) (11, 11) (-1, -1)..." +
        "(1, 5) (5, 1) (8, 8) (4, 1) (10, 10) (0, 10) (10, 0) (0, 0) (2, 6)");
    suite(args).checkForeach(test, inside, outside, 3, 2, 5, 6);
  });
  runTest("Foreach Point In Boundary Test 3", (final args) {
    final test = QuadTreeTester(args);
    final inside = _Points.parse("(3, 3) (5, 5)");
    final outside = _Points.parse(
        "(10, 12) (20, 21) (12, 2) (1, 12) (13, 5) (-1, 3) (11, 11) (-1, -1) (1, 5) (5, 1)..." +
            "(8, 8) (4, 1) (10, 10) (0, 10) (10, 0) (0, 0) (2, 6) (40, 40) (40, 2) (2, 46)");
    suite(args).checkForeach(test, inside, outside, 2, 3, 6, 5);
  });
  runTest("Foreach Point In Boundary Test 4", (final args) {
    final test = QuadTreeTester(args);
    final inside = _Points.parse("(15, 15)");
    final outside = _Points.parse("(0, 0) (30, 30)");
    suite(args).checkForeach(test, inside, outside, 10, 10, 20, 20);
  });
  runTest("Foreach Point In Boundary Test 5", (final args) {
    final test = QuadTreeTester(args);
    final inside = _Points.parse("(15, 15)");
    final outside = _Points.parse("");
    suite(args).checkForeach(test, inside, outside, 10, 10, 20, 20);
  });
  runTest("Insert Edges Basic Test", (final args) {
    final test = QuadTreeTester(args);
    test.insertPoint(0, 1);
    test.insertPoint(1, 2);
    test.insertPoint(2, 3);
    test.insertPoint(8, 3);
    test.insertPoint(9, 2);
    test.insertPoint(10, 1);
    test.insertEdge(0, 1, 10, 1);
    test.insertEdge(1, 2, 9, 2);
    test.insertEdge(2, 3, 8, 3);
    suite(args).showPlot2(test);
  });
  runTest("Insert Edges Test", (final args) {
    final test = QuadTreeTester(args);
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
    suite(args).showPlot2(test);
  });
  runTest("Basic Point Insertion", (final args) {
    final test = QuadTreeTester(args);
    test.insertPoint(0, 0);
    test.insertPoint(0, 10);
    test.insertPoint(10, 10);
    test.insertPoint(10, 0);
    test.insertPoint(5, 5);
    test.insertPoint(5, 15);
    test.insertPoint(15, 15);
    test.insertPoint(15, 5);
    suite(args).showPlot2(test);
  });
  runTest("Another Point Insertion", (final args) {
    final test = QuadTreeTester(args);
    test.insertPoint(0, -1);
    test.insertPoint(0, 1);
    test.insertPoint(10, -1);
    test.insertPoint(10, 1);
    suite(args).showPlot2(test);
  });
  runTest("Overlaps Test", (final args) {
    final rectA = QTBoundaryImpl.make(8, 8, 15, 15);
    final rectB = QTBoundaryImpl.make(0, 8, 7, 15);
    final rectC = QTBoundaryImpl.make(8, 0, 15, 7);
    final rectD = QTBoundaryImpl.make(0, 0, 7, 7);
    final edgeA = QTEdgeImpl(QTPointImpl(-2, -4), QTPointImpl(12, 14), null);
    suite(args).overlapTest(args, rectA, edgeA, true);
    suite(args).overlapTest(args, rectB, edgeA, true);
    suite(args).overlapTest(args, rectC, edgeA, false);
    suite(args).overlapTest(args, rectD, edgeA, true);
    final rectE = QTBoundaryImpl.make(-15, 32, 0, 47);
    final edgeB = QTEdgeImpl(QTPointImpl(4, 33), QTPointImpl(-1, 52), null);
    suite(args).overlapTest(args, rectE, edgeB, true);
  });
  runTest("Polygon Clipper 1 - No change", (final args) {
    suite(args)._testClipper(args, "(0, 5) (0, 0) (5, 0) (5, 5)", ["(0, 5) (0, 0) (5, 0) (5, 5)"]);
  });
  runTest("Polygon Clipper 2 - Change to CCW", (final args) {
    suite(args)._testClipper(args, "(0, 0) (0, 5) (5, 5) (5, 0)", ["(5, 5) (0, 5) (0, 0) (5, 0)"]);
  });
  runTest("Polygon Clipper 3 - Bowtie", (final args) {
    suite(args)
        ._testClipper(args, "(0, 0) (0, 5) (5, 0) (5, 5)", ["(3, 3) (5, 0) (5, 5)", "(0, 5) (0, 0) (3, 3)"]);
  });
  runTest("Polygon Clipper 4 - Bowtie reversed", (final args) {
    suite(args)
        ._testClipper(args, "(0, 5) (0, 0) (5, 5) (5, 0)", ["(0, 5) (0, 0) (3, 3)", "(5, 5) (3, 3) (5, 0)"]);
  });
  runTest("Polygon Clipper 5 - Big bowtie", (final args) {
    suite(args)._testClipper(args, "(-59, 81) (-23, 32) (-88, 38) (-90, 75) (-35, 69) (-39, 24) (-78, 84)", [
      "(-59, 81) (-78, 84) (-71, 73) (-90, 75) (-88, 38) (-45, 34)..." +
          "(-39, 24) (-38, 33) (-23, 32) (-37, 50) (-35, 69) (-52, 71)",
      "(-52, 71) (-71, 73) (-45, 34) (-38, 33) (-37, 50)"
    ]);
  });
  runTest("Polygon Clipper 6 - Big bowtie reversed", (final args) {
    suite(args)._testClipper(args, "(-78, 84) (-39, 24) (-35, 69) (-90, 75) (-88, 38) (-23, 32) (-59, 81)", [
      "(-71, 73) (-45, 34) (-38, 33) (-37, 50) (-52, 71)",
      "(-78, 84) (-71, 73) (-90, 75) (-88, 38) (-45, 34) (-39, 24)..." +
          "(-38, 33) (-23, 32) (-37, 50) (-35, 69) (-52, 71) (-59, 81)"
    ]);
  });
  runTest("Polygon Clipper 7 - Repeats", (final args) {
    suite(args)._testClipper(
        args, "(-68, 67) (-68, 67) (-24, 16) (2, 57) (-68, 67)", ["(-68, 67) (-24, 16) (2, 57)"]);
  });
  runTest("Polygon Clipper 8 - Degenerate", (final args) {
    suite(args)._testClipper(args, "(-40, 21) (-40, 21) (0, 0)", []);
  });
  runTest("Polygon Clipper 9 - Zero Area", (final args) {
    suite(args)._testClipper(args, "(-40, 20) (-20, 10) (0, 0)", []);
  });
  runTest("Region Map 1", (final args) {
    final test = RegionMapTester(args);
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
    suite(args).showPlot(test);
  });
  runTest("Region Map 2", (final args) {
    final test = RegionMapTester(args);
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
    suite(args).showPlot(test);
  });
  runTest("Region Map 3", (final args) {
    final test = RegionMapTester(args);
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
    suite(args).showPlot(test);
  });
  runTest("Region Map 4", (final args) {
    final test = RegionMapTester(args);
    test.add([10, 0, 0, 0, 0, 4, 6, 5, 0, 6, 0, 10, 10, 10]);
    test.add([3, 0, 3, 10, 10, 10, 10, 0]);
    test.pointTest(4, 7, 2);
    test.pointTest(4, 5, 2);
    test.pointTest(4, 3, 2);
    test.pointTest(2, 7, 1);
    test.pointTest(2, 5, 0);
    test.pointTest(2, 3, 1);
    suite(args).showPlot(test);
  });
  runTest("Region Map 5", (final args) {
    final test = RegionMapTester(args);
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
    suite(args).showPlot(test);
  });
  runTest("Region Map 6", (final args) {
    final test = RegionMapTester(args);
    test.add([3, 0, 3, 15, 12, 15, 12, 0]);
    test.add([0, 0, 3, 3, 3, 15, 12, 15, 12, 0]);
    test.pointTest(2, 1, 2);
    test.pointTest(3, 1, 2);
    test.pointTest(4, 1, 2);
    test.pointTest(1, 2, 0);
    suite(args).showPlot(test);
  });
  runTest("Region Map 7 - Two identical regions", (final args) {
    final test = RegionMapTester(args);
    test.add([15, 5, 15, 15, 5, 15, 5, 5]);
    test.add([15, 5, 15, 15, 5, 15, 5, 5]);
    test.pointTest(10, 10, 2);
    suite(args).showPlot(test);
  });
  runTest("Region Map 8 - Overwrite a smaller region", (final args) {
    final test = RegionMapTester(args);
    test.add([10, 5, 10, 10, 5, 10, 5, 5]);
    test.add([15, 0, 15, 15, 0, 15, 0, 0]);
    test.pointTest(-2, -2, 0);
    test.pointTest(2, 2, 2);
    test.pointTest(7, 7, 2);
    test.pointTest(12, 12, 2);
    test.pointTest(17, 17, 0);
    suite(args).showPlot(test);
  });
  runTest("Region Map 9 - Add a hole", (final args) {
    final test = RegionMapTester(args);
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
    suite(args).showPlot(test);
  });
  runTest("Region Map 10 - Four corners", (final args) {
    final test = RegionMapTester(args);
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
    suite(args).showPlot(test);
  });
  runTest("Region Map 11 - Create a bounded region", (final args) {
    final test = RegionMapTester(args);
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
    suite(args).showPlot(test);
  });
  runTest("Region Map 12 - Two triangles, boundary issue", (final args) {
    final test = RegionMapTester(args);
    test.add([9, 59, -11, 54, -7, 37], 1);
    test.add([17, 47, -1, 52, 4, 33], 1);
    test.pointTest(5, 35, 1);
    suite(args).showPlot(test);
  });
  runTest("Region Map 13 - Overlapping lines of same regions", (final args) {
    final test = RegionMapTester(args);
    test.add([5, 0, 5, 5, 3, 0], 1);
    test.add([5, 0, 5, 5, 7, 5], 1);
    test.pointTest(4, 1, 1);
    test.pointTest(6, 4, 1);
    suite(args).showPlot(test);
  });
  runTest("Region Map 14 - Overlapping lines of different regions", (final args) {
    final test = RegionMapTester(args);
    test.add([5, 0, 5, 5, 3, 0], 1);
    test.add([5, 0, 5, 5, 7, 5], 2);
    test.pointTest(4, 1, 1);
    test.pointTest(6, 4, 2);
    suite(args).showPlot(test);
  });
  runTest("Region Map 15 - Repeat point", (final args) {
    final test = RegionMapTester(args);
    test.add([5, 0, 5, 0, 5, 5, 3, 0], 1);
    test.pointTest(4, 1, 1);
    suite(args).showPlot(test);
  });
  runTest("Region Map 16 - Bow tie", (final args) {
    final test = RegionMapTester(args);
    test.add([-36, 42, -36, 42, -38, -10, 32, 53, 49, -17], 1);
    test.add([-15, 60, -15, 60, 13, 61, 19, -35, -17, -39], 1);
    test.pointTest(0, 50, 1);
    suite(args).showPlot(test);
  });
  runTest("Region Map 17 - Sailboat", (final args) {
    final test = RegionMapTester(args);
    test.add([-6, 7, 0, 0, 6, 7], 1);
    test.add([-2, 5, 2, 5, 0, 10], 1);
    final pnt = test._map.tree.findPoint(QTPointImpl(-2, 5));
    if (pnt != null) {
      test._args.error("Point " + pnt.toString() + " should have been removed");
    }
    suite(args).showPlot(test);
  });
  runTest("Region Map 18 - Two large triangles", (final args) {
    final test = RegionMapTester(args);
    test.add([418, 74, 545, 298, 294, 296], 1);
    test.add([321, 160, 444, 373, 199, 371], 2);
    test.pointTest(402, 298, 0);
    test.pointTest(402, 296, 1);
    test.pointTest(399, 298, 2);
    suite(args).showPlot(test);
  });
  runTest("Region Map 19 - Three large triangles", (final args) {
    final test = RegionMapTester(args);
    test.add([418, 74, 545, 298, 294, 296], 1);
    test.add([321, 160, 444, 373, 199, 371], 2);
    test.add([425, 187, 549, 406, 302, 408], 3);
    test.pointTest(380, 240, 1);
    test.pointTest(410, 240, 3);
    final edge = test._map.tree.findNearestEdge(QTPointImpl(406, 221));
    final side = (edge!.data as EdgeSide?)!;
    if ((side.left != 3) || (side.right != 1)) {
      test._args.error("Expected [3|1] but got " + side.toString());
    }
    suite(args).showPlot(test);
  });
  runTest("Region Map 20 - Complex bow tie", (final args) {
    final test = RegionMapTester(args);
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
    suite(args).showPlot(test);
  });
  runTest("Region Map 21 - Three polygons", (final args) {
    final test = RegionMapTester(args);
    test.add([-91, 53, -34, 43, 10, 5, -11, -44, -66, -37, -96, -2], 1);
    test.add([-39, 58, -47, 16, -41, -2, 43, -8, 34, 41], 2);
    test.add([-6, 13, -28, -22, -36, -55, 17, -62, 58, -35, 59, 25], 3);
    test.pointTest(42, 32, 0);
    test.pointTest(66, 15, 0);
    test.pointTest(66, -12, 0);
    test.pointTest(44, -4, 3);
    test.pointTest(32, 31, 2);
    test.pointTest(41, 39, 0);
    suite(args).showPlot(test);
  });
  runTest("Region Map 22 - Three large triangles with a hole", (final args) {
    final test = RegionMapTester(args);
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
    suite(args).showPlot(test);
  });
  runTest("Boundary Region Test", (final args) {
    final rect = QTBoundaryImpl.make(-2, -2, 2, 2);
    suite(args).regionTest(args, rect, 0, 0, BoundaryRegionImpl.Inside);
    suite(args).regionTest(args, rect, 2, 2, BoundaryRegionImpl.Inside);
    suite(args).regionTest(args, rect, 2, -2, BoundaryRegionImpl.Inside);
    suite(args).regionTest(args, rect, -2, 2, BoundaryRegionImpl.Inside);
    suite(args).regionTest(args, rect, -2, -2, BoundaryRegionImpl.Inside);
    suite(args).regionTest(args, rect, 0, 4, BoundaryRegionImpl.North);
    suite(args).regionTest(args, rect, 4, 0, BoundaryRegionImpl.East);
    suite(args).regionTest(args, rect, 0, -4, BoundaryRegionImpl.South);
    suite(args).regionTest(args, rect, -4, 0, BoundaryRegionImpl.West);
    suite(args).regionTest(args, rect, 4, 4, BoundaryRegionImpl.NorthEast);
    suite(args).regionTest(args, rect, 4, -4, BoundaryRegionImpl.SouthEast);
    suite(args).regionTest(args, rect, -4, 4, BoundaryRegionImpl.NorthWest);
    suite(args).regionTest(args, rect, -4, -4, BoundaryRegionImpl.SouthWest);
  });
}

/// The interface for the unit-test to callback with.
abstract class TestArgs {
  /// Indicates if the test has failed.
  bool get failed;

  /// Marks this test as failed.
  void fail();

  /// Prints text to the test's output console as an information.
  void info(
    final String text,
  );

  /// Prints text to the test's output console as a notice.
  void notice(
    final String text,
  );

  /// Prints text to the test's output console as a warning.
  void warning(
    final String text,
  );

  /// Prints text to the test's output console as an error.
  /// This will also mark this test as a failure.
  void error(
    final String text,
  );
}

abstract class _Points {
  static List<QTPointImpl> parse(
    final String pnts,
  ) {
    final exp = RegExp(r"(-?[0-9]+)");
    final matches = exp.allMatches(pnts);
    final result = <QTPointImpl>[];
    for (var i = 1; i < matches.length; i += 2) {
      final xStr = matches.elementAt(i - 1).group(0).toString();
      final yStr = matches.elementAt(i).group(0).toString();
      final x = int.parse(xStr.trim());
      final y = int.parse(yStr.trim());
      result.add(QTPointImpl(x, y));
    }
    return result;
  }

  static String format(
    final List<QTPoint> pnts,
  ) {
    String result = "{";
    final pntsLen = pnts.length;
    for (int i = 0; i < pntsLen; ++i) {
      if (i != 0) {
        result += ", ";
      }
      // ignore: use_string_buffers
      result += "[${pnts[i].x}, ${pnts[i].y}]";
    }
    return result + "}";
  }

  static bool equals(
    final List<QTPoint> a,
    final List<QTPoint> b,
  ) {
    final aLen = a.length;
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
    final List<QTPointImpl> a,
    final List<QTPoint> b,
  ) {
    final aLen = a.length;
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
  final TestArgs args;
  final QuadTree tree;

  /// Create a new quad-tree tester.
  QuadTreeTester(
    final this.args,
  ) : tree = QuadTreeImpl();

  /// Inserts a point into the test tree.
  PointNode insertPoint(
    final int x,
    final int y,
  ) {
    final pnt = QTPointImpl(x, y);
    final oldCount = tree.numberofPointsInTheTree;
    final oldPoint = tree.findPoint(pnt);
    final point = tree.insertPoint(pnt);
    final newCount = tree.numberofPointsInTheTree;
    final newPoint = tree.findPoint(pnt);
    if (oldPoint == null) {
      if (oldCount + 1 != newCount) {
        args.error(
          "The old count should be one less than the new count after insertPoint($x, $y):" +
              "\n   Old Count: $oldCount" +
              "\n   New Count: $newCount",
        );
      }
    } else {
      if (oldCount != newCount) {
        args.error(
          "The old count should be the same as the new count after insertPoint($x, $y):" +
              "\n   Old Count: $oldCount" +
              "\n   New Count: $newCount",
        );
      }
      if (oldPoint != point) {
        args.error(
          "The pre-insert found point does not equal the inserted point after insertPoint($x, $y):" +
              "\n   Found Point:    $oldPoint" +
              "\n   Inserted Point: $point",
        );
      }
    }
    if (point != newPoint) {
      args.error(
        "The post-insert found point does not equal the inserted point after insertPoint($x, $y):" +
            "\n   Found Point:    $newPoint" +
            "\n   Inserted Point: $point",
      );
    }
    final sout = StringBuffer();
    if (!tree.validate(sout)) {
      args.error("Failed validation after insertPoint($x, $y):" + "\n${sout.toString()}");
    }
    return point;
  }

  /// Inserts a set of points into the test tree.
  void insertPoints(
    final String pntCoords,
  ) {
    final pnts = _Points.parse(pntCoords);
    final count = pnts.length;
    for (int i = 0; i < count; ++i) {
      insertPoint(pnts[i].x, pnts[i].y);
    }
  }

  /// Inserts an edge into the test tree.
  QTEdge? insertEdge(
    final int x1,
    final int y1,
    final int x2,
    final int y2,
  ) {
    final e = QTEdgeImpl(
      QTPointImpl(x1, y1),
      QTPointImpl(x2, y2),
      null,
    );
    final oldCount = tree.numberOfEdgesInTheTree;
    final oldEdge = tree.findEdge(e, false);
    final edge = tree.insertEdge(e, null);
    final newCount = tree.numberOfEdgesInTheTree;
    final newEdge = tree.findEdge(e, false);
    if (oldEdge == null) {
      if (oldCount + 1 != newCount) {
        args.error(
          "The old count should be one less than the new count after insertEdge($x1, $y1, $x2, $y2):" +
              "\n   Old Count: $oldCount" +
              "\n   New Count: $newCount",
        );
      }
    } else {
      if (oldCount != newCount) {
        args.error(
          "The old count should be the same as the new count after insertEdge($x1, $y1, $x2, $y2):" +
              "\n   Old Count: $oldCount" +
              "\n   New Count: $newCount",
        );
      }
      if (oldEdge != edge) {
        args.error(
          "The pre-insert found edge does not equal the inserted edge after insertEdge($x1, $y1, $x2, $y2):" +
              "\n   Found Edge:    $oldEdge" +
              "\n   Inserted Edge: $edge",
        );
      }
    }
    if (edge != newEdge) {
      args.error(
        "The post-insert found edge does not equal the inserted edge after insertEdge($x1, $y1, $x2, $y2):" +
            "\n   Found Edge:    $newEdge" +
            "\n   Inserted Edge: $edge",
      );
    }
    final sout = StringBuffer();
    if (!tree.validate(sout)) {
      args.error(
        "Failed validation after insertEdge($x1, $y1, $x2, $y2):\n${sout.toString()}",
      );
    }
    return edge;
  }

  /// Inserts a polygon into the test tree.
  void insertPolygon(
    final String pntCoords,
  ) {
    final pnts = _Points.parse(pntCoords);
    final nodes = PointNodeVector();
    final count = pnts.length;
    for (int i = 0; i < count; ++i) {
      final node = tree.insertPoint(pnts[i]);
      nodes.nodes.add(node);
    }
    for (int i = 0; i < count; ++i) {
      final edge = nodes.edge(i);
      insertEdge(edge.x1, edge.y1, edge.x2, edge.y2);
    }
  }
}

/// A point handler used to find the nearest point while checking all points.
/// This is not as fast as findNearestPointToPoint but can be used to test it.
class _TestNearestPointHandle implements QTPointHandler {
  /// minimum distance squared to found point.
  double minDist2 = double.maxFinite;

  /// The point to get the point closest to.
  QTPointImpl? focus;

  /// The found point closest the the focus or null if none has been found yet.
  PointNode? found;

  _TestNearestPointHandle();

  /// handles each point given to it to check if it is closer.
  @override
  bool handle(
    final PointNode point,
  ) {
    final dist2 = pointDistance2(focus!, point);
    if (dist2 < minDist2) {
      minDist2 = dist2;
      found = point;
    }
    return true;
  }
}

class RegionMapTester {
  final TestArgs _args;
  final Regions _map;
  final List<List<int>> _polygons;
  final List<int> _regions;
  final Map<int, List<int>> _points;
  final Map<int, List<int>> _errPnts;
  final List<List<double>> _colors;

  RegionMapTester(
    final this._args,
  )   : _map = Regions(),
        _polygons = <List<int>>[],
        _regions = <int>[],
        _points = <int, List<int>>{},
        _errPnts = <int, List<int>>{},
        _colors = <List<double>>[] {
    _addColor(0.0, 0.0, 0.0);
    _addColor(1.0, 0.0, 0.0);
    _addColor(0.0, 1.0, 0.0);
    _addColor(0.0, 0.0, 1.0);
    _addColor(0.6, 0.6, 0.0);
    _addColor(0.6, 0.0, 0.6);
    _addColor(0.0, 0.6, 0.6);
  }

  void _addColor(
    final double red,
    final double green,
    final double blue,
  ) {
    this._colors.add([red, green, blue]);
  }

  void add(
    final List<int> polygon, [
    int region = -1,
  ]) {
    if (region < 0) {
      // ignore: parameter_assignments
      region = _polygons.length + 1;
    }
    _polygons.add(polygon);
    _regions.add(region);
    _map.quadTreeAddRegionWithCoords(
          regionId: region,
          pntCoords: polygon,
        );
    if (!_map.tree.validate()) _args.fail();
  }

  void _addPoint(
    final Map<int, List<int>> points,
    final int x,
    final int y,
    final int value,
  ) {
    var pnts = points[value];
    pnts ??= <int>[];
    pnts.add(x);
    pnts.add(y);
    points[value] = pnts;
  }

  void pointTest(
    final int x,
    final int y,
    final int exp,
  ) {
    this._addPoint(_points, x, y, exp);
    final result = _map.quadTreeGetRegion(
      pnt: QTPointImpl(
        x,
        y,
      ),
    );
    if (exp != result) {
      _addPoint(_errPnts, x, y, result);
      _args.error(
            "Expected " +
                exp.toString() +
                " but got " +
                result.toString() +
                " from " +
                x.toString() +
                ", " +
                y.toString() +
                ".\n",
          );
    }
  }
}

class _LineCollector implements QTEdgeHandler<Object?> {
  final List<Lines> _lines;

  _LineCollector(
    final this._lines,
  );

  @override
  bool handle(
    final QTEdge edge,
  ) {
    final pair = (edge.data as EdgeSide?)!;
    double dx = edge.dx.toDouble();
    double dy = edge.dy.toDouble();
    final length = sqrt(dx * dx + dy * dy);
    if (length > 1.0e-12) {
      const height = 0.1;
      dx = dx * height / length;
      dy = dy * height / length;
      _lines[pair.left].add([edge.x1 - dy, edge.y1 + dx, edge.x2 - dy, edge.y2 + dx]);
      _lines[pair.right].add([edge.x1 + dy, edge.y1 - dx, edge.x2 + dy, edge.y2 - dx]);
    }
    return true;
  }
}

mixin QuadTreeTestSuite {
  void onPlot(
    final Plotter plotter,
  );

  void showPlot(
    final RegionMapTester tester,
  ) {
    final plot = QuadTreePlotter();
    plot.addTree(tester._map.tree);
    final count = tester._polygons.length;
    final initPolys = plot.plotter.addGroup("Initial Polygons");
    for (int i = 0; i < count; i++) {
      final poly = tester._polygons[i];
      final region = tester._regions[i];
      final clr = tester._colors[region];
      final polyItem = initPolys.addGroup("Polygon #$i").addPolygon([])
        ..addColor(clr[0], clr[1], clr[2])
        ..addDirected(true);
      for (int j = 0; j < poly.length - 1; j += 2) {
        polyItem.add([poly[j].toDouble(), poly[j + 1].toDouble()]);
      }
    }
    final finalPolys = plot.plotter.addGroup("Final Polygons");
    tester._map.tree.foreachEdge(
      _LineCollector(
        List<Lines>.generate(
          count + 1,
          (final i) {
            final clr = tester._colors[i];
            return finalPolys.addGroup("#$i Edges").addLines([])
              ..addColor(clr[0], clr[1], clr[2])
              ..addDirected(true);
          },
        ),
      ),
    );
    final errPntGroup = plot.plotter.addGroup("Error Points");
    for (int i = 0; i <= count; i++) {
      final points = tester._errPnts[i];
      if (points != null) {
        final clr = tester._colors[i];
        final pnts = errPntGroup.addPoints([])
          ..addColor(clr[0], clr[1], clr[2])
          ..addPointSize(6.0);
        for (int j = 0; j < points.length; j += 2) {
          pnts.add([points[j].toDouble(), points[j + 1].toDouble()]);
        }
      }
    }
    final testPnts = plot.plotter.addGroup("Test Points");
    for (int i = 0; i <= count; i++) {
      final points = tester._points[i];
      if (points != null) {
        final clr = tester._colors[i];
        final pnts = testPnts.addPoints([])
          ..addColor(clr[0], clr[1], clr[2])
          ..addPointSize(3.0);
        for (int j = 0; j < points.length; j += 2) {
          pnts.add([points[j].toDouble(), points[j + 1].toDouble()]);
        }
      }
    }
    plot.plotter.updateDataBounds();
    plot.plotter.focusOnData();
    onPlot(plot.plotter);
  }

  void regionTest(
    final TestArgs args,
    final QTBoundaryImpl rect,
    final int x,
    final int y,
    final BoundaryRegion expRegion,
  ) {
    final result = rect.region(
      QTPointImpl(
        x,
        y,
      ),
    );
    if (result != expRegion) {
      args.error(
        [
          "Failed: Unexpected result from region:",
          "   Boundary: " + rect.toString(),
          "   Point:    " + x.toString() + ", " + y.toString(),
          "   Expected: " + expRegion.toString() + ", " + expRegion.toString(),
          "   Result:  z " + result.toString() + ", " + result.toString() + "\n",
        ].join("\n"),
      );
      final plot = makePlotter();
      plot.addRects(
        [
          rect.xmin.toDouble(),
          rect.ymin.toDouble(),
          rect.width.toDouble(),
          rect.height.toDouble(),
        ],
      )
        ..addColor(0.8, 0.0, 0.0)
        ..addPointSize(4.0);
      plot.addPoints(
        [
          x.toDouble(),
          y.toDouble(),
        ],
      )
        ..addColor(0.0, 0.8, 0.0)
        ..addPointSize(4.0);
      plot.updateDataBounds();
      plot.focusOnData();
      onPlot(plot);
    } else {
      args.info(
        "Passed: BoundaryRegion(" +
            rect.toString() +
            ", [" +
            x.toString() +
            ", " +
            y.toString() +
            "]) => " +
            expRegion.toString() +
            "\n\n",
      );
    }
  }

  void overlapTest(
    final TestArgs args,
    final QTBoundary bounds,
    final QTEdge edge,
    final bool overlaps,
  ) {
    final result = bounds.overlapsEdge(edge);
    if (result != overlaps) {
      args.error("Failed: Expected overlap ($overlaps) didn't match result:\n" +
          "   Bounds: $bounds\n" +
          "   Edge:   $edge\n\n");
      final plot = makePlotter();
      plot.addRects(
          [bounds.xmin.toDouble(), bounds.ymin.toDouble(), bounds.width.toDouble(), bounds.height.toDouble()])
        ..addColor(0.8, 0.0, 0.0)
        ..addPointSize(4.0);
      plot.addLines([edge.x1.toDouble(), edge.y1.toDouble(), edge.x2.toDouble(), edge.y2.toDouble()])
        ..addColor(0.0, 0.8, 0.0)
        ..addPointSize(4.0);
      plot.updateDataBounds();
      plot.focusOnData();
      plot.mouseHandles.add(makeMouseCoords(plot));
      onPlot(plot);
    } else {
      args.info(
          "Passed: " + bounds.toString() + ".overlaps(" + edge.toString() + ") => " + overlaps.toString());
    }
  }

  void _testClipper(
    final TestArgs args,
    final String input,
    final List<String> results, [
    bool plot = true,
  ]) {
    final inputPnts = _Points.parse(input);
    final expPnts = <List<QTPointImpl>>[];
    for (int i = 0; i < results.length; ++i) {
      expPnts.add(_Points.parse(results[i]));
    }
    final resultPnts = polygonClip(inputPnts);
    if (expPnts.length != resultPnts.length) {
      args.error("Lengths do not match: expected ${expPnts.length} but got ${resultPnts.length}:\n");
      args.info("input: " + _Points.format(inputPnts) + "\n");
      for (int i = 0; i < max(expPnts.length, resultPnts.length); i++) {
        if (i < expPnts.length) args.info("exp $i: ${_Points.format(expPnts[i])}\n");
        if (i < resultPnts.length) args.info("got $i: ${_Points.format(resultPnts[i])}\n");
      }
      // ignore: parameter_assignments
      plot = true;
    } else {
      bool failed = false;
      for (int i = 0; i < expPnts.length; ++i) {
        if (!_Points.equals2(expPnts[i], resultPnts[i])) {
          failed = true;
          break;
        }
      }
      if (failed) {
        // ignore: parameter_assignments
        plot = true;
        args.error("Some results did not match:\n");
        args.info("input: ${_Points.format(inputPnts)}\n");
        for (int i = 0; i < expPnts.length; ++i) {
          if (_Points.equals(expPnts[i], resultPnts[i])) {
            args.info("same $i: ${_Points.format(expPnts[i])}\n");
          } else {
            args.info("exp  $i: ${_Points.format(expPnts[i])}\n");
            args.info("got  $i: ${_Points.format(resultPnts[i])}\n");
          }
        }
      }
    }
    if (plot) {
      final plot = QuadTreePlotter();
      final inputPoly = plot.plotter.addGroup("Input").addPolygon([])
        ..addColor(0.0, 0.0, 0.0)
        ..addDirected(true);
      for (int i = 0; i < inputPnts.length; ++i) {
        inputPoly.add([inputPnts[i].x.toDouble(), inputPnts[i].y.toDouble()]);
      }
      for (int i = 0; i < resultPnts.length; ++i) {
        final f = i / resultPnts.length;
        final poly = plot.plotter.addGroup("Result $i").addPolygon([])
          ..addColor(0.0, 1.0 - f, f)
          ..addDirected(true);
        final pnts = resultPnts[i];
        for (int j = 0; j < pnts.length; ++j) {
          poly.add([pnts[j].x.toDouble(), pnts[j].y.toDouble()]);
        }
      }
      plot.plotter.updateDataBounds();
      plot.plotter.focusOnData();
      onPlot(plot.plotter);
    }
  }

  /// Checks that the first left result was as expected.
  void checkFirstLeftEdge(
    QuadTreeTester tester,
    final int x,
    final int y,
    final int x1,
    final int y1,
    final int x2,
    final int y2,
  ) {
    final node = tester.tree.firstLeftEdge(
      QTPointImpl(
        x,
        y,
      ),
    );
    bool showPlot = false;
    if (node == null) {
      tester.args.info("Found to find first edge.\n\n");
      showPlot = true;
    } else if ((node.x1 != x1) || (node.y1 != y1) || (node.x2 != x2) || (node.y2 != y2)) {
      tester.args.error("First edge found didn't match expected:\n" +
          "   Gotten:   ${node.edge}\n" +
          "   Expected: [$x1, $y1, $x2, $y2]\n\n");
      showPlot = true;
    }
    if (showPlot) {
      final plot = QuadTreePlotter();
      plot.addTree(tester.tree);
      if (node != null) {
        plot.plotter.addLines(
          [
            node.x1.toDouble(),
            node.y1.toDouble(),
            node.x2.toDouble(),
            node.y2.toDouble(),
          ],
        ).addColor(0.2, 0.2, 1.0);
      }
      plot.plotter.addPoints(
        [
          x.toDouble(),
          y.toDouble(),
        ],
      )
        ..addColor(1.0, 0.0, 0.0)
        ..addPointSize(3.0);
      plot.plotter.updateDataBounds();
      plot.plotter.focusOnData();
      onPlot(plot.plotter);
    }
  }

  /// Checks the expected result from finding all the intersections.
  void findAllIntersections(
    final QuadTreeTester tester,
    final int x1,
    final int y1,
    final int x2,
    final int y2,
    final int count, [
    bool showPlot = true,
  ]) {
    final edge = QTEdgeImpl(
      QTPointImpl(x1, y1),
      QTPointImpl(x2, y2),
      null,
    );
    final inters = IntersectionSetImpl();
    tester.tree.findAllIntersections(edge, null, inters);
    final sout = StringBuffer();
    if (!tester.tree.validate(sout)) {
      tester.args.info(sout.toString());
      tester.args.info(tester.tree.toString());
      tester.args.fail();
      // ignore: parameter_assignments
      showPlot = true;
    }
    tester.args.info("$edge => $inters\n");
    if (inters.results.length != count) {
      tester.args.error("Expected to find $count intersections but found ${inters.results.length}.\n" +
          "${inters.toString()}\n" +
          "${tester.tree.toString()}\n\n");
      // ignore: parameter_assignments
      showPlot = true;
    }
    final firstInt = tester.tree.findFirstIntersection(edge, null);
    if (firstInt != null) {
      if (count < 1) {
        tester.args.error("Expected to find no intersections but found a first intersection.\n" +
            "${firstInt.toString()}\n" +
            "${tester.tree.toString()}\n\n");
        // ignore: parameter_assignments
        showPlot = true;
      }
    } else {
      if (count > 0) {
        tester.args.error(
          "Expected to find $count intersections but found no first intersection.\n" +
              "${tester.tree.toString()}\n\n",
        );
        // ignore: parameter_assignments
        showPlot = true;
      }
    }
    if (showPlot) {
      final plot = QuadTreePlotter();
      plot.addTree(tester.tree, "Intersects: $edge => $count");
      final lines = Lines();
      lines.add(
        [
          edge.x1.toDouble(),
          edge.y1.toDouble(),
          edge.x2.toDouble(),
          edge.y2.toDouble(),
        ],
      );
      lines.addColor(0.0, 0.0, 0.8);
      plot.plotter.addItems([lines]);
      final points = Points();
      for (final inter in inters.results) {
        final _point = inter.point;
        if (_point != null) {
          points.add(
            [
              _point.x.toDouble(),
              _point.y.toDouble(),
            ],
          );
        }
      }
      points.addPointSize(4.0);
      points.addColor(1.0, 0.0, 0.0);
      plot.plotter.addItems([points]);
      plot.plotter.updateDataBounds();
      plot.plotter.focusOnData();
      onPlot(plot.plotter);
    }
  }

  void edgeIntersectTest(
    final TestArgs args,
    final QTEdgeImpl edgeA,
    final QTEdgeImpl edgeB,
    final String exp,
  ) {
    final result = intersect(edgeA, edgeB)!;
    final type = "${result.type}".substring("IntersectionType.".length);
    final locA = "${result.locA}".substring("IntersectionLocation.".length);
    final locB = "${result.locB}".substring("IntersectionLocation.".length);
    final resultStr = (() {
          if (result.intersects) {
            return "Hit";
          } else {
            return "Miss";
          }
        }()) +
        " " +
        "$type ${result.point} $locA $locB";
    if (exp != resultStr) {
      if (!args.failed) {
        final plot = makePlotter();
        plot.addLines(
          [
            edgeA.x1.toDouble(),
            edgeA.y1.toDouble(),
            edgeA.x2.toDouble(),
            edgeA.y2.toDouble(),
            edgeB.x1.toDouble(),
            edgeB.y1.toDouble(),
            edgeB.x2.toDouble(),
            edgeB.y2.toDouble()
          ],
        );
        plot.updateDataBounds();
        plot.focusOnData();
        onPlot(plot);
      }
      args.error(
        "Failed: Unexpected result from edge interscetion:\n" +
            "   Edge A:   $edgeA\n" +
            "   Edge B:   $edgeB\n" +
            "   Full:     ${result.toString("\n                 ")}\n" +
            "   Result:   $resultStr\n" +
            "   Expected: $exp\n\n",
      );
    } else {
      args.info("Passed: $resultStr\n");
    }
  }

  /// Checks if the first found intersection returned the expected results.
  void findFirstIntersection(
    final QuadTreeTester args,
    final int x1,
    final int y1,
    final int x2,
    final int y2,
    final int expX1,
    final int expY1,
    final int expX2,
    final int expY2, [
    bool showPlot = true,
    final QTEdgeHandler<Object?>? edgeFilter,
  ]) {
    final edge = QTEdgeImpl(
      QTPointImpl(x1, y1),
      QTPointImpl(x2, y2),
      null,
    );
    final exp = QTEdgeImpl(
      QTPointImpl(expX1, expY1),
      QTPointImpl(expX2, expY2),
      null,
    );
    final result = args.tree.findFirstIntersection(edge, edgeFilter);
    final sout = StringBuffer();
    if (!args.tree.validate(sout)) {
      args.args.info(sout.toString());
      args.args.info(args.tree.toString());
      args.args.fail();
      // ignore: parameter_assignments
      showPlot = true;
    }
    args.args.info("Edge:     $edge\n");
    args.args.info("Result:   $result\n");
    args.args.info("Expected: $exp\n");
    if (!qtEdgeEquals(result!.edgeB, exp, false)) {
      args.args.error("Expected to find an intersections but found a first intersection.\n" +
          "${result.toString()}\n" +
          "${args.tree.toString()}\n\n");
      // ignore: parameter_assignments
      showPlot = true;
    }
    if (showPlot) {
      final plot = QuadTreePlotter();
      plot.addTree(args.tree, "Intersects: $edge");
      final lines = Lines();
      lines.add(
        [
          edge.x1.toDouble(),
          edge.y1.toDouble(),
          edge.x2.toDouble(),
          edge.y2.toDouble(),
        ],
      );
      lines.addColor(0.0, 0.0, 0.8);
      plot.plotter.addItems([lines]);
      final points = Points();
      final _point = result.point;
      if (_point != null) {
        points.add(
          [
            _point.x.toDouble(),
            _point.y.toDouble(),
          ],
        );
      }
      points.addPointSize(4.0);
      points.addColor(1.0, 0.0, 0.0);
      plot.plotter.addItems([points]);
      plot.plotter.updateDataBounds();
      plot.plotter.focusOnData();
      onPlot(plot.plotter);
    }
  }

  /// Checkst the bounded foreach method works as expected.
  void checkForeach(
    final QuadTreeTester args,
    final List<QTPointImpl> inside,
    final List<QTPointImpl> outside,
    final int x1,
    final int y1,
    final int x2,
    final int y2, [
    bool showPlot = true,
  ]) {
    final expOutside = <PointNode>{};
    for (int i = 0; i < outside.length; ++i) {
      expOutside.add(args.insertPoint(outside[i].x, outside[i].y));
    }
    final expInside = <PointNode>{};
    for (int i = 0; i < inside.length; ++i) {
      expInside.add(args.insertPoint(inside[i].x, inside[i].y));
    }
    final boundary = QTBoundaryImpl.make(x1, y1, x2, y2);
    final collector = QTPointHandlerCollectorImpl();
    args.tree.foreachPoint(collector, boundary);
    final foundPoints = collector.collection;
    final wrongOutside = <PointNode>{};
    for (final point in expInside) {
      if (!foundPoints.remove(point)) {
        wrongOutside.add(point);
      }
    }
    final wrongInside = <PointNode>{};
    wrongInside.addAll(foundPoints);
    if ((wrongOutside.isNotEmpty) || (wrongInside.isNotEmpty)) {
      args.args.error("Foreach point failed to return expected results:" +
          "\n   Expected Outside: $expOutside" +
          "\n   Expected Inside:  $expInside" +
          "\n   Wrong Outside:    $wrongOutside" +
          "\n   Wrong Inside:     $wrongInside");
      // ignore: parameter_assignments
      showPlot = true;
    }
    if (showPlot) {
      final plot = QuadTreePlotter();
      plot.addTree(args.tree);
      final expOutsidePoint = plot.plotter.addGroup("Expected Outside").addPoints([])
        ..addColor(0.0, 0.0, 1.0)
        ..addPointSize(4.0);
      plot.addPointSet(expOutsidePoint, expOutside);
      final expInsidePoint = plot.plotter.addGroup("Expected Inside").addPoints([])
        ..addColor(0.0, 1.0, 0.0)
        ..addPointSize(4.0);
      plot.addPointSet(expInsidePoint, expInside);
      final wrongOutsidePoint = plot.plotter.addGroup("Wrong Outside").addPoints([])
        ..addColor(1.0, 0.0, 0.0)
        ..addPointSize(4.0);
      plot.addPointSet(wrongOutsidePoint, wrongOutside);
      final wrongInsidePoint = plot.plotter.addGroup("Wrong Inside").addPoints([])
        ..addColor(1.0, 0.5, 0.0)
        ..addPointSize(4.0);
      plot.addPointSet(wrongInsidePoint, wrongInside);
      plot.plotter
          .addGroup("Boundary")
          .addRects([x1.toDouble(), y1.toDouble(), (x2 - x1).toDouble(), (y2 - y1).toDouble()]);
      plot.plotter.updateDataBounds();
      plot.plotter.focusOnData();
      onPlot(plot.plotter);
    }
  }

  /// Checks the find nearest point for point returns the expected results.
  void checkFindNearestPoint(
    final QuadTreeTester args,
    final int x,
    final int y,
    final int expX,
    final int expY, [
    bool showPlot = true,
  ]) {
    final focus = QTPointImpl(x, y);
    final exp = QTPointImpl(expX, expY);
    final result = args.tree.findNearestPointToPoint(focus);
    args.args.info("$focus => $result\n");
    if (!pointEquals(exp, result)) {
      args.args.error("Foreach point failed to return expected results:" +
          "\n   Focus:     ${focus.toString()}" +
          "\n   Exp:       ${exp.toString()}" +
          "\n   Exp Dist2: ${pointDistance2(exp, focus)}" +
          "\n   Result:    ${result.toString()}");
      // ignore: parameter_assignments
      showPlot = true;
    }
    final hndl = _TestNearestPointHandle()..focus = focus;
    args.tree.foreachPoint(hndl);
    if (!pointEquals(hndl.found, result)) {
      args.args.error("FindNearestPoint didn't find nearest point:" +
          "\n   Focus:        ${focus.toString()}" +
          "\n   Result:       ${result.toString()}" +
          "\n   Result Dist2: ${pointDistance2(focus, result!)}" +
          "\n   Found:        ${hndl.found.toString()}" +
          "\n   Found Dist2:  ${hndl.minDist2}");
      // ignore: parameter_assignments
      showPlot = true;
    }
    if (showPlot) {
      final plot = QuadTreePlotter();
      plot.addTree(args.tree);
      final focusPnt = plot.plotter.addGroup("Focus").addPoints([])
        ..addColor(0.0, 0.0, 1.0)
        ..addPointSize(4.0);
      plot.addPoint(focusPnt, focus);
      final resultPnt = plot.plotter.addGroup("Result").addPoints([])
        ..addColor(0.0, 1.0, 0.0)
        ..addPointSize(4.0);
      plot.addPoint(resultPnt, result!);
      final foundPnt = plot.plotter.addGroup("Found").addPoints([])
        ..addColor(1.0, 0.0, 0.0)
        ..addPointSize(4.0);
      plot.addPoint(foundPnt, hndl.found!);
      plot.plotter.updateDataBounds();
      plot.plotter.focusOnData();
      onPlot(plot.plotter);
    }
  }

  /// Shows the plot of the tree.
  void showPlot2(
    final QuadTreeTester tree, {
    final bool showPassNodes = true,
    final bool showPointNodes = true,
    final bool showEmptyNodes = false,
    final bool showBranchNodes = false,
    final bool showEdges = true,
    final bool showPoints = true,
    final bool showBoundary = true,
    final bool showRootBoundary = true,
  }) {
    final plot = QuadTreePlotter();
    plot.addTree(tree.tree)
      ..showPassNodes = showPassNodes
      ..showPointNodes = showPointNodes
      ..showEmptyNodes = showEmptyNodes
      ..showBranchNodes = showBranchNodes
      ..showEdges = showEdges
      ..showPoints = showPoints
      ..showBoundary = showBoundary
      ..showRootBoundary = showRootBoundary;
    plot.plotter
      ..updateDataBounds()
      ..focusOnData();
    onPlot(plot.plotter);
  }
}
