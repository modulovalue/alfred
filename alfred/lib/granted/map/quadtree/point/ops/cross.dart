import '../qt_point.dart';

/// Finds the origin based cross product for the given points.
double pointCross(
  final QTPoint a,
  final QTPoint b,
) =>
    (a.x * b.y).toDouble() - (a.y * b.x).toDouble();
