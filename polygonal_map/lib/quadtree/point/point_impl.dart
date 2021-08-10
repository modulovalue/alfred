import 'point.dart';

/// A point is a two dimensional integer coordinate.
class QTPointImpl implements QTPoint {
  /// Gets the distance squared between the two given points.
  static double distance2(
    final QTPoint a,
    final QTPoint b,
  ) {
    final dx = (b.x - a.x).toDouble();
    final dy = (b.y - a.y).toDouble();
    return dx * dx + dy * dy;
  }

  /// Checks if the two given points are equal.
  static bool equals(
    final QTPoint? a,
    final QTPoint? b,
  ) {
    if (a == null) {
      return b == null;
    } else if (b == null) {
      return false;
    } else {
      return (a.x == b.x) && (a.y == b.y);
    }
  }

  /// Finds the origin based cross product for the given points.
  static double cross(
    final QTPoint a,
    final QTPoint b,
  ) =>
      (a.x * b.y).toDouble() - (a.y * b.x).toDouble();

  /// Finds the origin based dot product for the given points.
  static double dot(
    final QTPoint a,
    final QTPoint b,
  ) =>
      (a.x * b.x).toDouble() + (a.y * b.y).toDouble();

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
