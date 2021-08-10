/// The interface for both the geometric point and point node.
abstract class QTPoint {
  /// Gets the first integer coordinate component.
  int get x;

  /// Gets the second integer coordinate component.
  int get y;

  /// Any additional data that this point should contain.
  abstract Object? data;
}
