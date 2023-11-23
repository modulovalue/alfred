/// Linearly interpolate between two numbers.
double? nullLerpDouble(
  final num? a,
  final num? b,
  final double t,
) {
  if (a == null && b == null) {
    // ignore: avoid_returning_null
    return null;
  } else {
    return lerpDouble(a ?? 0.0, b ?? 0.0, t);
  }
}

/// Linearly interpolate between two numbers.
double lerpDouble(
  final num a,
  final num b,
  final double t,
) =>
    a + (b - a) * t;
