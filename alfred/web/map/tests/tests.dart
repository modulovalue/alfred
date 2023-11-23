// ignore_for_file: discarded_futures

import 'dart:html' as html;

import 'package:alfred/granted/framework/plot/impl/html_svg.dart';
import 'package:alfred/granted/framework/plotter_item/impl/plotter.dart';
import 'package:alfred/granted/map/quadtree/test_suite/tests.dart';

void main() {
  html.document
    ..title = "Unit-tests"
    ..body!.append(
      html.DivElement()
        ..className = "scroll_page"
        ..append(
          html.DivElement()
            ..className = "page_center"
            ..append(
              html.DivElement()
                ..append(
                  () {
                    final elem = html.DivElement();
                    runQuadtreeTestSuite<TestBlock>(
                      runTest: TestManager().add(elem),
                      suite: (final args) => QuadTreeTestSuiteHTML(
                        args: args,
                      ),
                    );
                    return elem;
                  }(),
                )
                ..append(
                  html.DivElement()..className = "end_page",
                ),
            ),
        ),
    );
}

class QuadTreeTestSuiteHTML with QuadTreeTestSuite {
  final TestBlock args;

  const QuadTreeTestSuiteHTML({
    required this.args,
  });

  @override
  void onPlot(
    final Plotter plotter,
  ) =>
      makePlotHtmlSvg(
        targetDiv: args.addDiv(),
        plot: plotter,
      );
}

/// The block for the unit-test output and the test arguments.
class TestBlock implements TestArgs {
  final TestManager _man;
  final html.DivElement _body;
  final html.DivElement _title;
  DateTime? _start;
  DateTime? _end;
  final void Function(TestBlock args) _test;
  final String _testName;
  bool _started;
  bool _failed;
  bool _finished;

  /// Creates a new test block for the given test.
  TestBlock(
    final html.Element _elem,
    this._man,
    this._test,
    this._testName,
  )   : _body = html.DivElement()..className = "test_body body_hidden",
        _title = html.DivElement()..className = "running top_header",
        _start = null,
        _end = null,
        _started = false,
        _failed = false,
        _finished = false {
    _elem.children
      ..add(_title)
      ..add(_body);
    _title.onClick.listen(_titleClicked);
    _update();
  }

  /// Handles the test title clicked to show and hide the test output.
  void _titleClicked(final dynamic _) {
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
      DateTime? end = _end;
      end ??= DateTime.now();
      time = ((end.difference(_start!).inMilliseconds) * 0.001).toStringAsFixed(2);
      time = "(" + time + "s)";
    }
    if (!_started) {
      _title
        ..className = "test_header queued"
        ..text = "Queued: " + _testName + " " + time;
    } else if (_failed) {
      _title
        ..className = "test_header failed"
        ..text = "Failed: " + _testName + " " + time;
    } else if (_finished) {
      _title
        ..className = "test_header passed"
        ..text = "Passed: " + _testName + " " + time;
    } else {
      _title
        ..className = "test_header running"
        ..text = "Running: " + _testName + " " + time;
    }
    _man._update();
  }

  /// Runs this test asynchronously in the event loop.
  void run() => Future(
        () {
          _started = true;
          _update();
          html.window.requestAnimationFrame(
            (final _) {},
          );
        },
      ).then(
        (final _) {
          _start = DateTime.now();
          _test(this);
          _end = DateTime.now();
        },
      ).catchError(
        (
          final dynamic exception,
          final StackTrace stackTrace,
        ) {
          _end = DateTime.now();
          error("\nException: " + exception.toString());
          warning("\nStack: " + stackTrace.toString());
        },
      ).then(
        (final _) {
          _finished = true;
          _man._testDone(this);
          _update();
          html.window.requestAnimationFrame((final _) {});
        },
      );

  html.DivElement addDiv() {
    final div = html.DivElement()
      ..className = "test_div"
      ..id = "testDiv" + _man.takeDivIndex.toString();
    _body.children.add(div);
    return div;
  }

  /// Adds a new log event
  void _addLog(
    final String text,
    final String type,
  ) {
    final entries = text.split("\n");
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
  void info(
    final String text,
  ) =>
      _addLog(text, "info_log");

  /// Prints text to the test's output console as a notice.
  @override
  void notice(
    final String text,
  ) =>
      _addLog(text, "notice_log");

  /// Prints text to the test's output console as a warning.
  @override
  void warning(
    final String text,
  ) =>
      _addLog(text, "warning_log");

  /// Prints text to the test's output console as an error.
  /// This will also mark this test as a failure.
  @override
  void error(
    final String text,
  ) {
    _addLog(text, "error_log");
    fail();
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
  final html.DivElement _header;
  final DateTime _start;
  final List<TestBlock> _tests;
  int _finished;
  int _failed;
  int _testDivIndex;

  /// The filter to only let tests with the given prefix to be run.
  /// Set to empty to run all tests.
  String testPrefixFilter;

  /// Creates new test manager attached to the given element.
  TestManager()
      : _header = html.DivElement(),
        _start = DateTime.now(),
        _tests = <TestBlock>[],
        _finished = 0,
        _failed = 0,
        _testDivIndex = 0,
        testPrefixFilter = "";

  /// Gets an index for a test div which is unique.
  int takeDivIndex() {
    final result = _testDivIndex;
    _testDivIndex++;
    return result;
  }

  /// Updates the top header of the tests.
  void _update() {
    final time = ((DateTime.now().difference(_start).inMilliseconds) * 0.001).toStringAsFixed(2);
    final testCount = _tests.length;
    if (testCount <= _finished) {
      if (_failed > 0) {
        _header.className = "top_header failed";
        if (_failed == 1) {
          _header.text = "Failed 1 Test (" + time + "s)";
        } else {
          _header.text = "Failed " + this._failed.toString() + " Tests (" + time + "s)";
        }
      } else {
        _header
          ..text = "Tests Passed (" + time + "s)"
          ..className = "top_header passed";
      }
    } else {
      final prec = ((_finished.toDouble() / testCount) * 100.0).toStringAsFixed(2);
      _header.text =
          "Running Tests: " + this._finished.toString() + "/" + testCount.toString() + " (" + prec + "%)";
      if (_failed > 0) {
        _header
          ..text = this._header.text.toString() + " - " + this._failed.toString() + " failed)"
          ..className = "topHeader failed";
      } else {
        _header.className = "topHeader running";
      }
    }
  }

  /// Callback from a test to indicate it is done
  /// and to have the manager start a new test.
  void _testDone(
    final TestBlock block,
  ) {
    _finished++;
    if (block.failed) {
      _failed++;
    }
    _update();
    if (_finished < _tests.length) {
      Future(
        () {
          html.window.requestAnimationFrame((final _) {});
          _tests[_finished].run();
        },
      );
    }
  }

  /// Adds a new test to be run.
  void Function(
    String testName,
    void Function(TestBlock args) test,
  ) add(
    final html.Element _elem,
  ) {
    _elem.children.add(_header);
    final checkBoxes = html.DivElement()..className = "log_checkboxes";
    // Creates a check box for changing the visibility of logs with the given [type].
    void _createLogSwitch(
      final html.DivElement checkBoxes,
      final String text,
      final String type,
    ) {
      final checkBox = html.CheckboxInputElement()
        ..className = "log_checkbox"
        ..checked = true;
      checkBox.onChange.listen((final _) {
        final myElements = html.document.querySelectorAll("." + type);
        final display = () {
          if (checkBox.checked!) {
            return "block";
          } else {
            return "none";
          }
        }();
        for (int i = 0; i < myElements.length; i++) {
          myElements[i].style.display = display;
        }
      });
      checkBoxes.children.add(checkBox);
      final span = html.SpanElement()..text = text;
      checkBoxes.children.add(span);
    }

    _createLogSwitch(checkBoxes, "Information", "info_log");
    _createLogSwitch(checkBoxes, "Notice", "notice_log");
    _createLogSwitch(checkBoxes, "Warning", "warning_log");
    _createLogSwitch(checkBoxes, "Error", "error_log");
    _elem.children.add(checkBoxes);
    return (testName, final test) {
      if (testName.isEmpty) {
        // ignore: parameter_assignments
        testName = test.toString();
      }
      if (testName.startsWith(testPrefixFilter)) {
        _tests.add(TestBlock(_elem, this, test, testName));
        _update();
        // If currently none are running, start this one.
        if (_finished + 1 == _tests.length) {
          Future(
            () {
              html.window.requestAnimationFrame((final _) {});
              _tests[_finished].run();
            },
          );
        }
      }
    };
  }
}
