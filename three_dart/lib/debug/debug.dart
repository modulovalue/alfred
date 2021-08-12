/// Logger is an interface used for logging some information about the system.
/// This is used for unit-testing and validation.
abstract class Logger {
  /// Indicates if an error occurred.
  bool get failed;

  /// Prints text to the log's output console as an information.
  void info(String text);

  /// Prints text to the log's output console as a notice.
  void notice(String text);

  /// Prints text to the log's output console as a warning.
  void warning(String text);

  /// Prints text to the log's output console as an error.
  /// This will also mark this test as a failure.
  void error(String text);
}

/// DefaultLogger writes the output to the console.
class DefaultLogger implements Logger {
  bool _failed;

  /// Creates a new console logger.
  DefaultLogger() : this._failed = false;

  /// Indicates if an error occurred.
  @override
  bool get failed => this._failed;

  /// Prints text to the log's output console as an information.
  @override
  void info(String text) => print(text);

  /// Prints text to the log's output console as a notice.
  @override
  void notice(String text) => print(text);

  /// Prints text to the log's output console as a warning.
  @override
  void warning(String text) => print(text);

  /// Prints text to the log's output console as an error.
  /// This will also mark this test as a failure.
  @override
  void error(String text) {
    print(text);
    this._failed = true;
  }
}

/// String tree is a collection of hieratical string information.
class StringTree {
  static const String _singleStr = "--";
  static const String _startStr = ".-";
  static const String _branchStr = "+-";
  static const String _endStr = "'-";
  static const String _breakStr = "\n";
  static const String _spaceStr = "  ";
  static const String _pipeStr = "| ";

  /// This is the string to show on this part of the tree.
  String text;

  /// These are the children to this part of the tree.
  List<StringTree> children;

  /// Creates a new string tree.
  StringTree([this.text = '']) : this.children = [];

  /// Adds a child to this string tree.
  void append(StringTree child) => this.children.add(child);

  /// Creates a new child to this string tree and returns it.
  StringTree add(String text) {
    final child = StringTree(text);
    this.children.add(child);
    return child;
  }

  /// Outputs the string tree.
  @override
  String toString([String indent = '']) {
    final buf = StringBuffer();
    this._subString(buf, indent, true, true);
    return buf.toString();
  }

  /// Outputs a part of the tree and its children.
  void _subString(StringBuffer buf, String indent, bool first, bool last) {
    buf.write(indent);
    if (first) {
      buf.write(last ? _singleStr : _startStr);
    } else {
      buf.write(last ? _endStr : _branchStr);
    }
    final follow = indent + (last ? _spaceStr : _pipeStr);
    buf.write(this.text.replaceAll(_breakStr, _breakStr + follow));
    final count = this.children.length;
    for (int i = 0; i < count; ++i) {
      buf.write(_breakStr);
      this.children[i]._subString(buf, follow, false, i == count - 1);
    }
  }
}
