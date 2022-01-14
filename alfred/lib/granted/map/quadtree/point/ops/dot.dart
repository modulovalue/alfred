import '../qt_point.dart';

/// Finds the origin based dot product for the given points.
double pointDot(
  final QTPoint a,
  final QTPoint b,
) =>
    (a.x * b.x).toDouble() + (a.y * b.y).toDouble();
