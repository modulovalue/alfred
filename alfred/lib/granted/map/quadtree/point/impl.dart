import 'interface.dart';

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
    final this.x,
    final this.y, [
    final this.data,
  ]);

  @override
  String toString() => "[" + x.toString() + ", " + y.toString() + "]";
}
