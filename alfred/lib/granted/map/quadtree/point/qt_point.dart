/// A point is a two dimensional integer coordinate.
// TODO remove bound.
class QTPointImpl<T extends Object> implements QTPoint<T?> {
  /// The first integer coordinate component.
  @override
  final int x;

  /// The second integer coordinate component.
  @override
  final int y;

  /// Any additional data that this point should contain.
  @override
  T? data;

  /// Creates a new point.
  QTPointImpl(
    this.x,
    this.y, [
    this.data,
  ]);

  @override
  String toString() => "[" + x.toString() + ", " + y.toString() + "]";
}

/// The interface for both the geometric point and point node.
// TODO remove bound.
abstract class QTPoint<T extends Object?> {
  /// Gets the first integer coordinate component.
  int get x;

  /// Gets the second integer coordinate component.
  int get y;

  /// Any additional data that this point should contain.
  abstract T data;
}
