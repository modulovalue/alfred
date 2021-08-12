import '../interface.dart';

/// Gets the distance squared between the two given points.
double pointDistance2(
  final QTPoint a,
  final QTPoint b,
) {
  final dx = (b.x - a.x).toDouble();
  final dy = (b.y - a.y).toDouble();
  return dx * dx + dy * dy;
}
