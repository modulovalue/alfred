import 'package:alfred/granted/framework/plotter/plotter_impl.dart';
import 'package:alfred/granted/map/quadtree/test_suite/tests.dart';
import 'package:test/test.dart';

void main() {
  runQuadtreeTestSuite<TestBlock>(
    runTest: (
      final testName,
      final testfn,
    ) =>
        test(
      testName,
      () => testfn(
        TestBlock(),
      ),
    ),
    suite: (final args) => QuadTreeTestSuiteTest(
      args: args,
    ),
  );
}

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

/// The block for the unit-test output and the test arguments.
class TestBlock implements TestArgs {
  bool _failed;

  /// Creates a new test block for the given test.
  TestBlock() : _failed = false;

  /// Prints text to the test's output console as an information.
  @override
  void info(
    final String text,
  ) =>
      print("INFO: " + text);

  /// Prints text to the test's output console as a notice.
  @override
  void notice(
    final String text,
  ) =>
      print("NOTICE: " + text);

  /// Prints text to the test's output console as a warning.
  @override
  void warning(
    final String text,
  ) =>
      print("WARNING: " + text);

  /// Prints text to the test's output console as an error.
  /// This will also mark this test as a failure.
  @override
  void error(
    final String text,
  ) {
    print("ERROR: " + text);
    fail();
  }

  /// Indicates if the test has failed.
  @override
  bool get failed => _failed;

  /// Marks this test as failed.
  @override
  void fail() => _failed = true;
}
