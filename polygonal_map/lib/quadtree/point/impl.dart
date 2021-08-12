import 'interface.dart';

/// A point is a two dimensional integer coordinate.
class QTPointImpl implements QTPoint {
  /// The first integer coordinate component.
  final int _x;

  /// The second integer coordinate component.
  final int _y;

  /// Any additional data that this point should contain.
  @override
  Object? data;

  /// Creates a new point.
  QTPointImpl(
    final this._x,
    final this._y, [
    final this.data,
  ]);

  /// Gets the first integer coordinate component.
  @override
  int get x => _x;

  /// Gets the second integer coordinate component.
  @override
  int get y => _y;

  @override
  String toString() => "[$_x, $_y]";
}
