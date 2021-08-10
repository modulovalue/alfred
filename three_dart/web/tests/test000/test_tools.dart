part of three_dart.test.test000;

/// The method handler for unit-tests.
/// [args] are provided to call-back the status of the test.
typedef TestHandler = void Function(TestArgs args);

/// The method handler for unit-tests when benchmarking.
typedef TestBenchHandler = void Function();

/// The interface for the unit-test to callback with.
abstract class TestArgs extends Logger{

  /// The title of the unit-test.
  String get title;
  set title(String title);

  /// Marks this test as failed.
  void fail();
  
  /// Runs a benchmark for the approximately amount of time
  /// then prints the results of the benchmark.
  void bench(double seconds, TestBenchHandler hndl);
}

/// The block for the unit-test output and the test arguments.
class TestBlock implements TestArgs {
  final TestManager _man;
  final html.DivElement _body;
  final html.DivElement _title;
  DateTime? _start;
  DateTime? _end;
  final TestHandler _test;
  String _testName;
  final bool _skip;
  bool _started;
  bool _failed;
  bool _finished;

  /// Creates a new test block for the given test.
  TestBlock(this._man, this._skip, this._test, this._testName):
    this._body = html.DivElement()
      ..className = "test_body body_hidden",
    this._title = html.DivElement()
      ..className = "running top_header",
    this._start = null,
    this._end = null,
    this._started = false,
    this._failed = false,
    this._finished = false {
    this._title.onClick.listen(this._titleClicked);
    this._man._elem.children
      ..add(this._title)
      ..add(this._body);
    this._update();
  }

  /// Handles the test title clicked to show and hide the test output.
  void _titleClicked(Object _) {
    if (this._body.className != "test_body body_hidden") {
      this._body.className = "test_body body_hidden";
    } else {
      this._body.className = "test_body body_shown";
    }
  }

  /// Updates the test header.
  void _update() {
    String time = "";
    final start = this._start;
    if (start != null) {
      DateTime? end = this._end;
      end ??= DateTime.now();
      time = ((end.difference(start).inMilliseconds)*0.001).toStringAsFixed(2);
      time ="(${time}s)";
    }
    if (this._skip) {
      this._title
        ..className = "test_header skipped"
        ..text = "Skipped: ${this._testName}";
    } else if (!this._started) {
      this._title
        ..className = "test_header queued"
        ..text = "Queued: ${this._testName} ${time}";
    } else if (this._failed) {
      this._title
        ..className = "test_header failed"
        ..text = "Failed: ${this._testName} ${time}";
    } else if (this._finished) {
      this._title
        ..className = "test_header passed"
        ..text = "Passed: ${this._testName} ${time}";
    } else {
      this._title
        ..className = "test_header running"
        ..text = "Running: ${this._testName} ${time}";
    }
    this._man._update();
  }

  /// Runs this test asynchronously in the event loop.
  void run() {
    asy.Future(() {
      this._started = true;
      this._update();
    }).then((_) {
      this._start = DateTime.now();
      if (!this._skip) this._test(this);
      this._end = DateTime.now();
    }).catchError((dynamic exception, StackTrace stackTrace) {
      this._end = DateTime.now();
      this.error("\nException: $exception");
      this.warning("\nStack: $stackTrace");
    }).then((_) {
      this._finished = true;
      this._man._testDone(this);
      this._update();
    });
  }

  /// Adds a log to the output area of the test.
  void _addLog(String text, String type) {
    final String log = this._man._escape.convert(text)
      .replaceAll(" ", "&nbsp;")
      .replaceAll("\n", "</dir><br class=\"$type\"><dir class=\"$type\">");
    final html = this._body.innerHtml ?? '';
    this._body.innerHtml = html + "<dir class=\"$type\">$log</dir>";
  }

  /// Prints text to the test's output console as an information.
  @override
  void info(String text) =>
    this._addLog(text, "info_log");

  /// Prints text to the test's output console as a notice.
  @override
  void notice(String text) =>
    this._addLog(text, "notice_log");

  /// Prints text to the test's output console as a warning.
  @override
  void warning(String text) =>
    this._addLog(text, "warning_log");

  /// Prints text to the test's output console as an error.
  /// This will also mark this test as a failure.
  @override
  void error(String text) {
    this._addLog(text, "error_log");
    this.fail();
  }

  /// The title of the unit-test.
  @override
  String get title => this._testName;
  @override
  set title(String title) {
    this._testName = title;
    this._update();
  }

  /// Indicates if the test has been stated.
  bool get stated => this._started;

  /// Indicates if the test has been finished.
  bool get finished => this._finished;

  /// Indicates if the test has failed.
  @override
  bool get failed => this._failed;

  /// Indicates if the test has been or is to be skipped.
  bool get skipped => this._skip;

  /// Marks this test as failed.
  @override
  void fail() {
    if (!this._failed) {
      this._failed = true;
      this._body.className = "test_body body_shown";
      this._update();
    }
  }

  /// Runs a benchmark for the approximately amount of time
  /// then prints the results of the benchmark.
  @override
  void bench(double seconds, TestBenchHandler hndl) {
    final DateTime start = DateTime.now();
    double duration = 0.0;
    int count = 0;
    while (duration < seconds) {
      hndl();
      count++;
      final Duration diff = DateTime.now().difference(start);
      duration = diff.inMilliseconds / Duration.millisecondsPerSecond;
    }
    notice("Benchmark results:\n");
    notice("  count    = $count\n");
    notice("  duration = $duration secs\n");
    notice("  average  = ${duration/count} secs\n");
    notice("  estimate = ${count/duration} per sec\n");
  }
}

/// The manager to run the tests.
class TestManager {
  final html.Element _elem;
  final html.DivElement _header;
  final convert.HtmlEscape _escape;
  final DateTime _start;
  final List<TestBlock> _tests;
  int _finished;
  int _failed;
  String _prefix;

  /// Creates new test manager attached to the given element.
  TestManager(this._elem):
    this._escape = const convert.HtmlEscape(convert.HtmlEscapeMode.element),
    this._header = html.DivElement(),
    this._start  = DateTime.now(),
    this._tests  = [],
    this._finished = 0,
    this._failed   = 0,
    this._prefix   = "" {
    this._elem.children.add(this._header);
    final html.DivElement checkBoxes = html.DivElement()
      ..className = "log_checkboxes";
    this._createLogSwitch(checkBoxes, "Information", "info_log");
    this._createLogSwitch(checkBoxes, "Notice", "notice_log");
    this._createLogSwitch(checkBoxes, "Warning", "warning_log");
    this._createLogSwitch(checkBoxes, "Error", "error_log");
    this._elem.children.add(checkBoxes);
  }

  /// The filter to only let tests with the given prefix to be run.
  /// Set to empty to run all tests.
  String get testPrefixFilter => this._prefix;
  set testPrefixFilter(String prefix) => this._prefix = prefix;

  /// Creates a check box for changing the visibility of logs with the given [type].
  void _createLogSwitch(html.DivElement checkBoxes, String text, String type) {
    final html.CheckboxInputElement checkBox = html.CheckboxInputElement()
      ..className = "log_checkbox"
      ..checked = true;
    checkBox.onChange.listen((_) {
        final html.ElementList<html.Element> myElements = html.document.querySelectorAll(".$type");
        final String display = (checkBox.checked ?? false) ? "block": "none";
        for (int i = 0; i < myElements.length; i++) {
            myElements[i].style.display = display;
        }
      });
    checkBoxes.children.add(checkBox);
    final html.SpanElement span = html.SpanElement()
      ..text = text;
    checkBoxes.children.add(span);
  }

  /// Callback from a test to indicate it is done
  /// and to have the manager start a new test.
  void _testDone(TestBlock block) {
    this._finished++;
    if (block.failed) this._failed++;
    this._update();
    if (this._finished < this._tests.length) {
      asy.Timer.run(this._tests[this._finished].run);
    }
  }

  /// Updates the top header of the tests.
  void _update() {
    final String time = ((DateTime.now().difference(this._start).inMilliseconds)*0.001).toStringAsFixed(2);
    final int testCount = this._tests.length;
    if (testCount <= this._finished) {
      if (this._failed > 0) {
        this._header.className = "top_header failed";
        if (this._failed == 1) {
          this._header.text = "Failed 1 Test (${time}s)";
        } else {
          this._header.text = "Failed ${this._failed} Tests (${time}s)";
        }
      } else {
        this._header
          ..text = "Tests Passed (${time}s)"
          ..className = "top_header passed";
      }
    } else {
      final String prec = ((this._finished.toDouble()/testCount)*100.0).toStringAsFixed(2);
      this._header.text = "Running Tests: ${this._finished}/${testCount} ($prec%)";
      if (this._failed > 0) {
        this._header
          ..text = "${this._header.text} - ${this._failed} failed)"
          ..className = "topHeader failed";
      } else {
        this._header.className = "topHeader running";
      }
    }
  }

  /// Adds a new test to be run.
  void add(String testName, TestHandler test, {bool skip = false}) {
    // ignore: parameter_assignments
    if (testName.isEmpty) testName = "$test";
    if (!testName.startsWith(this._prefix)) return;
    this._tests.add(TestBlock(this, skip, test, testName));
    this._update();

    // If currently none are running, start this one.
    if (this._finished + 1 == this._tests.length) {
      asy.Timer.run(this._tests[this._finished].run);
    }
  }
}
