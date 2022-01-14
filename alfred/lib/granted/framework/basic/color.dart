/// A simple color for plotting.
///
/// Since there are many packages that the plotter could be used to
/// output to, such as opengl, svg, gnuplot, swing, etc.,
/// this is a generic color is used to reduce complexity and keep consistent.
class ColorImpl implements Color {
  /// The red component for the color, 0 .. 1.
  double _red;

  /// The green component for the color, 0 .. 1.
  double _green;

  /// The blue component for the color, 0 .. 1.
  double _blue;

  /// The alpha component for the color, 0 .. 1.
  double _alpha;

  /// Creates a color.
  ColorImpl(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ])  : _red = _clamp(red),
        _green = _clamp(green),
        _blue = _clamp(blue),
        _alpha = _clamp(alpha);

  @override
  void set(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]) {
    _red = _clamp(red);
    _green = _clamp(green);
    _blue = _clamp(blue);
    _alpha = _clamp(alpha);
  }

  @override
  double get red => _red;

  @override
  set red(
    final double red,
  ) =>
      _red = _clamp(red);

  @override
  double get green => _green;

  @override
  set green(
    final double green,
  ) =>
      _green = _clamp(green);

  @override
  double get blue => _blue;

  @override
  set blue(
    final double blue,
  ) =>
      _blue = _clamp(blue);

  @override
  double get alpha => _alpha;

  @override
  set alpha(
    final double alpha,
  ) =>
      _alpha = _clamp(alpha);
}

/// Clamps a value to between 0 and 1 inclusively.
double _clamp(
  final double val,
) {
  if (val > 1.0) {
    return 1.0;
  } else {
    if (val < 0.0) {
      return 0.0;
    } else {
      return val;
    }
  }
}

/// A simple color for plotting.
///
/// Since there are many packages that the plotter could be used to
/// output to, such as opengl, svg, gnuplot, swing, etc.,
/// this is a generic color is used to reduce complexity and keep consistent.
abstract class Color {
  /// The red component for the color, 0 .. 1.
  abstract double red;

  /// The green component for the color, 0 .. 1.
  abstract double green;

  /// The blue component for the color, 0 .. 1.
  abstract double blue;

  /// The alpha component for the color, 0 .. 1.
  abstract double alpha;

  /// Sets the color to the given values.
  void set(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]);
}
