import 'package:alfred/granted/framework/plotter_item/impl/plotter.dart';
import 'package:alfred/granted/map/quadtree/test_suite/tests.dart';
import 'package:test/test.dart';

void main() => runQuadtreeTestSuite<TestBlock>(
      runTest: (final testName, final testfn) => test(
        testName,
        () => testfn(
          TestBlock(),
        ),
      ),
      suite: (final args) => QuadTreeTestSuiteTest(
        args: args,
      ),
    );

class QuadTreeTestSuiteTest with QuadTreeTestSuite {
  final TestBlock args;

  const QuadTreeTestSuiteTest({
    required final this.args,
  });

  @override
  void onPlot(
    final Plotter plotter,
  ) {
    // Don't plot.
  }
}

class TestBlock implements TestArgs {
  bool _failed;

  TestBlock() : _failed = false;

  @override
  void info(
    final String text,
  ) =>
      print("INFO: " + text);

  @override
  void notice(
    final String text,
  ) =>
      print("NOTICE: " + text);

  @override
  void warning(
    final String text,
  ) =>
      print("WARNING: " + text);

  @override
  void error(
    final String text,
  ) {
    print("ERROR: " + text);
    fail();
  }

  @override
  bool get failed => _failed;

  @override
  void fail() => _failed = true;
}
