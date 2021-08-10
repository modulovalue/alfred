/// Linearly interpolate between two numbers.
double? nullLerpDouble(num? a, num? b, double t) {
  if (a == null && b == null) {
    // ignore: avoid_returning_null
    return null;
  } else {
    return lerpDouble(a ?? 0.0, b ?? 0.0, t);
  }
}

/// Linearly interpolate between two numbers.
double lerpDouble(num a, num b, double t) => (a + (b - a) * t).toDouble();
