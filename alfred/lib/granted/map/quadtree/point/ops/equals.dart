import '../qt_point.dart';

/// Checks if the two given points are equal.
bool pointEquals(
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
