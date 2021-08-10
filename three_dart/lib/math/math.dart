import 'dart:math' as math;

/// Pi constant.
const double PI = math.pi;

/// Pi / 2 constant.
const double PI_2 = PI / 2.0;

/// Pi * 3 / 2 constant.
const double PI3_2 = PI * 1.5;

/// Pi / 3 constant.
const double PI_3 = PI / 3.0;

/// Tau constant, twice Pi.
const double TAU = PI * 2.0;

/// Gets the linear interpolation between the two given doubles.
///
/// The [i] is interpolation factor. 0.0 or less will return [a].
/// 1.0 or more will return the [b]. Between 0.0 and 1.0 will be
/// a scaled mixture of the two given doubles.
double lerpVal(double a, double b, double i) {
  if (i <= 0.0) {
    return a;
  } else {
    if (i >= 1.0) {
      return b;
    } else {
      return a + i * (b - a);
    }
  }
}

/// Gets the clamped value.
///
/// If [v] is less than the [min] then the [min] is returned.
/// If [v] is greater than the [max] then the [max] is returned.
/// Otherwise [v] is returned unchanged.
double clampVal(double v, [double min = 0.0, double max = 1.0]) {
  if (v < min) {
    return min;
  } else {
    if (v > max) {
      return max;
    } else {
      return v;
    }
  }
}

/// Gets the wrapped value.
///
/// If [v] is out of the [min] and [max] range,
/// [v] will we wrapped until inside the range.
double wrapVal(double v, [double min = 0.0, double max = 1.0]) {
  if (max <= min) return min;
  final double w = max - min;
  // ignore: parameter_assignments
  v = (v - min) % w;
  // ignore: parameter_assignments
  if (v < 0.0) v += w;
  return v + min;
}

/// Determines if the given [v] value is in the given range [min] inclusive and [max] exclusive.
bool inRange(double v, double min, double max) => Comparer.lessThanEquals(min, v) && Comparer.lessThan(v, max);

/// Determines if the given range A overlaps range B at any point.
bool rangeOverlap(double minA, double maxA, double minB, double maxB) =>
    Comparer.lessThanEquals(minB, maxA) && Comparer.lessThanEquals(minA, maxB);

/// Determines the difference between the two times in seconds.
///
/// [a] is the older time and [b] is the newer time.
double diffInSecs(DateTime a, DateTime b) => b.difference(a).inMicroseconds * 1.0e-6;

/// Formats the given double value into a string.
///
/// [v] is the number to get a string for.
/// [fraction] is the length of the fractional part.
/// [whole] is the padding to put to the left of the number.
String formatDouble(double v, [int fraction = 3, int whole = 0]) {
  // ignore: parameter_assignments
  if (Comparer.equals(v, 0.0)) v = 0.0;
  return v.toStringAsFixed(fraction).padLeft(whole + fraction + 1);
}

/// Formats the given double values into strings for a column.
///
/// [vals] is the numbers to get the strings for.
/// [fraction] is the length of the fractional part.
/// [whole] is the padding to put to the left of the number.
List<String> formatColumn(List<double> vals, [int fraction = 3, int whole = 0]) {
  int maxWidth = 0;
  final List<String> results = [];
  for (final double v in vals) {
    final String str = formatDouble(v, fraction, whole);
    maxWidth = math.max(maxWidth, str.length);
    results.add(str);
  }
  for (int i = results.length - 1; i >= 0; i--) {
    results[i] = results[i].padLeft(maxWidth);
  }
  return results;
}

/// Trims the given color component into what would fit into an 8 bit value.
double trimColor8(double value) => (value * 255.0).floorToDouble() / 255.0;

/// Formats the given integer into a string.
///
/// [v] is the number to get a string for.
/// [whole] is the padding to put to the left of the number.
String formatInt(int v, [int whole = 0]) => v.toString().padLeft(whole);

/// Gets the nearest (lower) power of the [radix] to the given [value].
int nearestPower(int value, [int radix = 2]) => math.pow(radix, (math.log(value) / math.log(radix)).floor()).toInt();

/// Gets the exclusive OR for booleans.
bool xor(bool a, bool b) => (!a && b) || (a && !b);

/// A math structure for storing a red, green, and blue additive color.
///
/// There is no transparency component to [Color3] colors.
class Color3 {
  /// The red component between 0.0 and 1.0 inclusively.
  final double red;

  /// The green component between 0.0 and 1.0 inclusively.
  final double green;

  /// The blue component between 0.0 and 1.0 inclusively.
  final double blue;

  /// Constructs a new [Color3] instance.
  ///
  /// [red], [green], and [blue] are the initial color components between 0.0 and 1.0 inclusively.
  factory Color3(double red, double green, double blue) => Color3._(clampVal(red), clampVal(green), clampVal(blue));

  /// Constructs a new [Color3] instance.
  Color3._(this.red, this.green, this.blue);

  /// Constructs a new [Color3] instance with no color, black.
  factory Color3.black() => Color3._(0.0, 0.0, 0.0);

  /// Constructs a new [Color3] instance with a gray color from the optional [value].
  factory Color3.gray([double value = 0.5]) {
    value = clampVal(value);
    return Color3._(value, value, value);
  }

  /// Constructs a new [Color3] instance with full color, white.
  factory Color3.white() => Color3._(1.0, 1.0, 1.0);

  /// Constructs a new color from bytes.
  ///
  /// [red], [green], and [blue] are between 0 and 255.
  factory Color3.fromBytes(int red, int green, int blue) => Color3(red / 0xFF, green / 0xFF, blue / 0xFF);

  /// Constructs a new [Color3] instance from a [Color4] instance.
  ///
  /// [clr] contains the initial components for the color.
  /// The transparent component of [clr] is ignored.
  factory Color3.fromColor4(Color4 clr) => Color3._(clr.red, clr.green, clr.blue);

  /// Constructs a new [Color3] instance given a list of 3 doubles.
  ///
  /// [values] is a list of doubles are in the order red, green, then blue.
  /// [values] is the initial color components between 0.0 and 1.0 inclusively.
  factory Color3.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 3);
    return Color3(values[0], values[1], values[2]);
  }

  /// Constructs a new [Color3] instance given the hue, saturation, and value.
  ///
  /// [hue], [value], and [saturation] are from 0.0 to 1.0.
  factory Color3.fromHVS(double hue, double value, double saturation) {
    hue *= 6.0; // sector 0 to 5
    final int index = hue.floor();
    final double fract = hue - index; // factorial part of h
    final double p = value * (1.0 - saturation);
    final double q = value * (1.0 - saturation * fract);
    final double t = value * (1.0 - saturation * (1.0 - fract));
    switch (index) {
      case 0:
        return Color3(value, t, p);
      case 1:
        return Color3(q, value, p);
      case 2:
        return Color3(p, value, t);
      case 3:
        return Color3(p, q, value);
      case 4:
        return Color3(t, p, value);
      default:
        return Color3(value, p, q);
    }
  }

  /// Gets an list of 3 doubles in the order red, green, then blue.
  List<double> toList() => [this.red, this.green, this.blue];

  /// Gets the value at the zero based index in the order red, green, then blue.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.red;
      case 1:
        return this.green;
      case 2:
        return this.blue;
    }
    return 0.0;
  }

  /// Inverts the color, creating the complement color.
  Color3 invert() => Color3._(1.0 - this.red, 1.0 - this.green, 1.0 - this.blue);

  /// Trims the color into 24 bit space range.
  Color3 trim24() => Color3._(trimColor8(this.red), trimColor8(this.green), trimColor8(this.blue));

  /// Converts this color to an RGB 24 bit color integer.
  int toRGB24() =>
      ((this.red * 255.0).floor() << 16) + ((this.green * 255.0).floor() << 8) + (this.blue * 255.0).floor();

  /// Creates the linear interpolation between this color and the [other] color.
  ///
  /// The [i] is interpolation factor. 0.0 or less will return this color.
  /// 1.0 or more will return the [other] color. Between 0.0 and 1.0 will be
  /// a scaled mixture of the two colors.
  Color3 lerp(Color3 other, double i) =>
      Color3(lerpVal(this.red, other.red, i), lerpVal(this.green, other.green, i), lerpVal(this.blue, other.blue, i));

  /// Creates a new color as the sum of this color and the [other] color.
  ///
  /// The color components will saturate at 1.0 so are limited to 1.0.
  Color3 operator +(Color3 other) => Color3(this.red + other.red, this.green + other.green, this.blue + other.blue);

  /// Creates a new color as the difference of this color and the [other] color.
  ///
  /// The color components will deplete at 0.0 so are limited to 0.0.
  Color3 operator -(Color3 other) => Color3(this.red - other.red, this.green - other.green, this.blue - other.blue);

  /// Creates a new color scaled by the given [scalar].
  Color3 operator *(double scalar) => Color3(scalar * this.red, scalar * this.green, scalar * this.blue);

  /// Creates a new color inversely scaled by the given [scalar].
  Color3 operator /(double scalar) {
    if (Comparer.equals(scalar, 0.0)) return Color3.black();
    return Color3(this.red / scalar, this.green / scalar, this.blue / scalar);
  }

  /// Determines if the given [other] variable is a [Color3] equal to this color.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Color3) return false;
    if (!Comparer.equals(other.red, this.red)) return false;
    if (!Comparer.equals(other.green, this.green)) return false;
    if (!Comparer.equals(other.blue, this.blue)) return false;
    return true;
  }

  @override
  int get hashCode => red.hashCode ^ green.hashCode ^ blue.hashCode;

  /// Gets the string for this color.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this color.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.red, fraction, whole) +
      ', ' +
      formatDouble(this.green, fraction, whole) +
      ', ' +
      formatDouble(this.blue, fraction, whole) +
      ']';
}

/// A math structure for storing a red, green, blue, and alpha additive color.
///
/// The alpha color component is the transparency of the color.
/// 0.0 it completely transparent. 1.0 is completely opaque.
class Color4 {
  /// The red component between 0.0 and 1.0 inclusively.
  final double red;

  /// The green component between 0.0 and 1.0 inclusively.
  final double green;

  /// The blue component between 0.0 and 1.0 inclusively.
  final double blue;

  /// The alpha component between 0.0 and 1.0 inclusively.
  final double alpha;

  /// Constructs a new [Color4] instance.
  ///
  /// [red], [green], [blue], and [alpha] are the initial color components between 0.0 and 1.0 inclusively.
  factory Color4(double red, double green, double blue, [double alpha = 1.0]) =>
      Color4._(clampVal(red), clampVal(green), clampVal(blue), clampVal(alpha));

  /// Constructs a new [Color4] instance.
  Color4._(this.red, this.green, this.blue, this.alpha);

  /// Constructs a new [Color4] instance with no color, opaque black.
  factory Color4.black([double alpha = 1.0]) => Color4._(0.0, 0.0, 0.0, clampVal(alpha));

  /// Constructs a new [Color4] instance with a gray color from the optional [value].
  factory Color4.gray([double value = 0.5, double alpha = 1.0]) {
    value = clampVal(value);
    return Color4._(value, value, value, clampVal(alpha));
  }

  /// Constructs a new [Color4] instance with full color, white.
  factory Color4.white([double alpha = 1.0]) => Color4._(1.0, 1.0, 1.0, clampVal(alpha));

  /// Constructs a new transparent [Color4] instance, transparent black.
  factory Color4.transparent() => Color4._(0.0, 0.0, 0.0, 0.0);

  /// Constructs a new color from bytes.
  ///
  /// [red], [green], [blue], and [alpha] are between 0 and 255.
  factory Color4.fromBytes(int red, int green, int blue, [int alpha = 0xFF]) =>
      Color4(red / 0xFF, green / 0xFF, blue / 0xFF, alpha / 0xFF);

  /// Constructs a new [Color4] instance from a [Color3] instance.
  ///
  /// [clr] contains the initial components for the color.
  /// [alpha] is the transparent component of the new color.
  /// If [alpha] is not provided the color will be completely opaque.
  factory Color4.fromColor3(Color3 clr, [double alpha = 1.0]) =>
      Color4._(clr.red, clr.green, clr.blue, clampVal(alpha));

  /// Constructs a new [Color3] instance given a list of 4 doubles.
  ///
  /// [values] is a list of doubles are in the order red, green, blue, then alpha.
  /// [values] is the initial color components between 0.0 and 1.0 inclusively.
  factory Color4.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    return Color4(values[0], values[1], values[2], values[3]);
  }

  /// Constructs a new [Color4] instance given the hue, saturation, and value.
  ///
  /// [hue], [value], and [saturation] are from 0.0 to 1.0.
  factory Color4.fromHVS(double hue, double value, double saturation, [double alpha = 1.0]) =>
      Color4.fromColor3(Color3.fromHVS(hue, value, saturation), alpha);

  /// Gets an list of 4 doubles in the order red, green, blue, then alpha.
  List<double> toList() => [this.red, this.green, this.blue, this.alpha];

  /// Gets the value at the zero based index in the order red, green, blue, then alpha.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.red;
      case 1:
        return this.green;
      case 2:
        return this.blue;
      case 3:
        return this.alpha;
    }
    return 0.0;
  }

  /// Inverts the color, creating the complement color and inverted translucency.
  Color4 invert() => Color4._(1.0 - this.red, 1.0 - this.green, 1.0 - this.blue, 1.0 - this.alpha);

  /// Trims the color into 32 bit space range.
  Color4 trim32() =>
      Color4._(trimColor8(this.red), trimColor8(this.green), trimColor8(this.blue), trimColor8(this.alpha));

  /// Converts this color to an ARGB 32 bit color integer.
  int toARGB32() =>
      ((this.alpha * 255.0).floor() << 24) +
      ((this.red * 255.0).floor() << 16) +
      ((this.green * 255.0).floor() << 8) +
      (this.blue * 255.0).floor();

  /// Creates the linear interpolation between this color and the [other] color.
  ///
  /// The [i] is interpolation factor. 0.0 or less will return this color.
  /// 1.0 or more will return the [other] color. Between 0.0 and 1.0 will be
  /// a scaled mixture of the two colors.
  Color4 lerp(Color4 other, double i) => Color4(lerpVal(this.red, other.red, i), lerpVal(this.green, other.green, i),
      lerpVal(this.blue, other.blue, i), lerpVal(this.alpha, other.alpha, i));

  /// Creates a new color as the sum of this color and the [other] color.
  ///
  /// The color components will saturate at 1.0 so are limited to 1.0.
  Color4 operator +(Color4 other) =>
      Color4(this.red + other.red, this.green + other.green, this.blue + other.blue, this.alpha + other.alpha);

  /// Creates a new color as the difference of this color and the [other] color.
  ///
  /// The color components will deplete at 0.0 so are limited to 0.0.
  Color4 operator -(Color4 other) =>
      Color4(this.red - other.red, this.green - other.green, this.blue - other.blue, this.alpha - other.alpha);

  /// Creates a new color scaled by the given [scalar].
  Color4 operator *(double scalar) =>
      Color4(scalar * this.red, scalar * this.green, scalar * this.blue, scalar * this.alpha);

  /// Creates a new color inversely scaled by the given [scalar].
  Color4 operator /(double scalar) {
    if (Comparer.equals(scalar, 0.0)) return Color4.transparent();
    return Color4(this.red / scalar, this.green / scalar, this.blue / scalar, this.alpha / scalar);
  }

  /// Determines if the given [other] variable is a [Color4] equal to this color.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(
    final Object other,
  ) =>
      identical(this, other) ||
      other is Color4 &&
          Comparer.equals(other.red, this.red) &&
          Comparer.equals(other.green, this.green) &&
          Comparer.equals(other.blue, this.blue) &&
          Comparer.equals(other.alpha, this.alpha);

  @override
  int get hashCode => red.hashCode ^ green.hashCode ^ blue.hashCode ^ alpha.hashCode;

  /// Gets the string for this color.
  @override
  String toString() => format();

  /// Gets the formatted string for this color.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.red, fraction, whole) +
      ', ' +
      formatDouble(this.green, fraction, whole) +
      ', ' +
      formatDouble(this.blue, fraction, whole) +
      ', ' +
      formatDouble(this.alpha, fraction, whole) +
      ']';
}

// TODO remove this by having explicit, out of class, equalities that use EpsilonComparer.
/// A set of static methods and values used for comparing doubles.
class Comparer {
  /// The current comparer instance to use for comparing doubles.
  static const CustomComparer _currentComparer = EpsilonComparer();

  /// Determines if the two values are equal.
  static bool equals(
    final double a,
    final double b,
  ) =>
      _currentComparer.equals(a, b);

  /// Determines if the two values are not equal.
  static bool notEquals(
    final double a,
    final double b,
  ) =>
      !_currentComparer.equals(a, b);

  /// Determines if 'a' is less than 'b'.
  static bool lessThan(
    final double a,
    final double b,
  ) =>
      _currentComparer.lessThan(a, b);

  /// Determines if 'a' is less than or equal to 'b'.
  static bool lessThanEquals(
    final double a,
    final double b,
  ) =>
      _currentComparer.lessThanEquals(a, b);

  /// Determines if 'a' is greater than 'b'.
  static bool greaterThan(
    final double a,
    final double b,
  ) =>
      _currentComparer.lessThan(b, a);

  /// Determines if 'a' is greater than or equal to 'b'.
  static bool greaterThanEquals(
    final double a,
    final double b,
  ) =>
      _currentComparer.lessThanEquals(b, a);
}

/// A math structure for storing a 3D region with equal width, depth, and height.
/// This is used when defining cubes of spaces like needed by an Octree.
class Cube {
  /// Gets a [Cube] at the origin.
  static Cube get zero => _zeroSingleton ??= Cube(0.0, 0.0, 0.0, 0.0);
  static Cube? _zeroSingleton;

  /// Gets a [Cube] at the origin with a width, height, and depth of 1.
  static Cube get unit => _unitSingleton ??= Cube(0.0, 0.0, 0.0, 1.0);
  static Cube? _unitSingleton;

  /// Gets a [Cube] at the origin with a width, height, and depth of 2 centered on origin.
  static Cube get unit2 => _unit2Singleton ??= Cube(-1.0, -1.0, -1.0, 2.0);
  static Cube? _unit2Singleton;

  /// The left edge component of the cube.
  final double x;

  /// The top edge component of the cube.
  final double y;

  /// The front edge component of the cube.
  final double z;

  /// The width, height, and depth of the cube.
  final double size;

  /// Constructs a new [Cube] instance.
  factory Cube(double x, double y, double z, double size) {
    if (size < 0.0) {
      x = x + size;
      y = y + size;
      z = z + size;
      size = -size;
    }
    return Cube._(x, y, z, size);
  }

  /// Constructs a new [Cube] instance.
  const Cube._(this.x, this.y, this.z, this.size);

  /// Constructs a new [Cube] at the given point, [pnt].
  factory Cube.fromPoint(Point3 pnt, [double size = 0.0]) => Cube(pnt.x, pnt.y, pnt.z, size);

  /// Constructs a new [Cube] at the given center point, [pnt].
  factory Cube.fromCenter(Point3 pnt, [double size = 0.0]) =>
      Cube(pnt.x - size * 0.5, pnt.y - size * 0.5, pnt.z - size * 0.5, size);

  /// Constructs a new [Cube] instance given a list of 4 doubles.
  ///
  /// [values] is a list of doubles are in the order x, y, z, then size.
  factory Cube.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    return Cube(values[0], values[1], values[2], values[3]);
  }

  /// Gets a cube which tightly completely contained by the given region.
  factory Cube.inscribe(Region3 region) => Cube.fromCenter(region.center, region.minSide);

  /// Gets a cube which tightly completely contains the given region.
  factory Cube.circumscribe(Region3 region) => Cube.fromCenter(region.center, region.maxSide);

  /// The center point of the region.
  Point3 get center {
    final double half = this.size / 2.0;
    return Point3(this.x + half, this.y + half, this.z + half);
  }

  /// Gets an list of 4 doubles in the order x, y, z, then size.
  List<double> toList() => [this.x, this.y, this.z, this.size];

  /// Gets the value at the zero based index in the order x, y, z, then size.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x;
      case 1:
        return this.y;
      case 2:
        return this.z;
      case 3:
        return this.size;
    }
    return 0.0;
  }

  /// Gets a [Region3] which is equivalent to this cube.
  Region3 toRegion3() => Region3(this.x, this.y, this.z, this.size, this.size, this.size);

  /// Gets the adjusted vector of the given [raw] vector.
  /// This vector is normalized into the region.
  Vector3 adjustVector(Vector3 raw) => raw * 2.0 / this.size;

  /// Determines the location the given point is in relation to the region.
  HitRegion hit(Point3 a) {
    HitRegion region = HitRegion.None;

    if (a.x < this.x) {
      region |= HitRegion.XNeg;
    } else if (a.x >= this.x + this.size) {
      region |= HitRegion.XPos;
    } else {
      region |= HitRegion.XCenter;
    }

    if (a.y < this.y) {
      region |= HitRegion.YNeg;
    } else if (a.y >= this.y + this.size) {
      region |= HitRegion.YPos;
    } else {
      region |= HitRegion.YCenter;
    }

    if (a.z < this.z) {
      region |= HitRegion.ZNeg;
    } else if (a.z >= this.z + this.size) {
      region |= HitRegion.ZPos;
    } else {
      region |= HitRegion.ZCenter;
    }

    return region;
  }

  /// Determines if the given point is contained inside this cube.
  bool contains(Point3 a) =>
      inRange(a.x, this.x, this.x + this.size) &&
      inRange(a.y, this.y, this.y + this.size) &&
      inRange(a.z, this.z, this.z + this.size);

  /// Determines if the two cubes overlap even partially.
  bool overlaps(Cube a) =>
      rangeOverlap(a.x, a.x + a.size, this.x, this.x + this.size) &&
      rangeOverlap(a.y, a.y + a.size, this.y, this.y + this.size) &&
      rangeOverlap(a.z, a.z + a.size, this.z, this.z + this.size);

  /// Creates a new [Cube] as a translation of the other given cube.
  Cube translate(Vector3 offset) => Cube(this.x + offset.dx, this.y + offset.dy, this.z + offset.dz, this.size);

  /// Determines if the given [other] variable is a [Cube] equal to this cube.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Cube) return false;
    final Cube size = other;
    if (!Comparer.equals(size.x, this.x)) return false;
    if (!Comparer.equals(size.y, this.y)) return false;
    if (!Comparer.equals(size.z, this.z)) return false;
    if (!Comparer.equals(size.size, this.size)) return false;
    return true;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode ^ size.hashCode;

  /// Gets the string for this cube.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this cube.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.x, fraction, whole) +
      ', ' +
      formatDouble(this.y, fraction, whole) +
      ', ' +
      formatDouble(this.z, fraction, whole) +
      ', ' +
      formatDouble(this.size, fraction, whole) +
      ']';
}

/// The interface to implement for the custom comparer.
abstract class CustomComparer {
  /// Determines if the two values are equal.
  bool equals(double a, double b);

  /// Determines if 'a' is less than 'b'.
  bool lessThan(double a, double b);

  /// Determines if 'a' is less than or equal to 'b'.
  bool lessThanEquals(double a, double b);
}

/// An epsilon comparer where things are equal when two values are
/// with a given difference, epsilon, which is relatively small.
class EpsilonComparer implements CustomComparer {
  /// The default epsilon distance used in the default comparer.
  static const defaultEpsilon = 1.0e-9;

  /// The value to use as padding for equality closeness.
  final double epsilon;

  /// Constructs a new epsilon comparer with the given epsilon value.
  const EpsilonComparer([
    this.epsilon = defaultEpsilon,
  ]);

  /// Determines if the two values are equal.
  @override
  bool equals(double a, double b) => (a - b).abs() < epsilon;

  /// Determines if 'a' is less than 'b'.
  @override
  bool lessThan(double a, double b) => a < b;

  /// Determines if 'a' is less than or equal to 'b'.
  @override
  bool lessThanEquals(double a, double b) => a - epsilon < b;
}

/// The hit region is a location relative to a Region2 or Region3 for fast intersection.
class HitRegion {
  /// [None] indicates no hit region values at all.
  static final HitRegion None = HitRegion._(0x0000);

  /// [All] indicates all hit region values.
  static final HitRegion All = HitRegion._(0x01FF);

  /// [XPos] indicates the positive X hit region.
  static final HitRegion XPos = HitRegion._(0x0001);

  /// [XCenter] indicates the center X hit region.
  static final HitRegion XCenter = HitRegion._(0x0002);

  /// [XNeg] indicates the negative X hit region.
  static final HitRegion XNeg = HitRegion._(0x0004);

  /// [YPos] indicates the positive Y hit region.
  static final HitRegion YPos = HitRegion._(0x0008);

  /// [YCenter] indicates the center Y hit region.
  static final HitRegion YCenter = HitRegion._(0x0010);

  /// [YNeg] indicates the negative Y hit region.
  static final HitRegion YNeg = HitRegion._(0x0020);

  /// [ZPos] indicates the positive Z hit region.
  static final HitRegion ZPos = HitRegion._(0x0040);

  /// [ZCenter] indicates the center Z hit region.
  static final HitRegion ZCenter = HitRegion._(0x0080);

  /// [ZNeg] indicates the negative Z hit region.
  static final HitRegion ZNeg = HitRegion._(0x0100);

  /// [Inside] indicates the inside hit region, XCenter|YCenter|ZCenter
  static final HitRegion Inside = HitRegion._(0x0092);

  /// [XPosNeg] is the combination of both X cardinal directions, XPos|XNeg.
  static final HitRegion XPosNeg = HitRegion._(0x0005);

  /// [YPosNeg] is the combination of both Y cardinal directions, YPos|YNeg.
  static final HitRegion YPosNeg = HitRegion._(0x0028);

  /// [ZPosNeg] is the combination of both Z cardinal directions, ZPos|ZNeg.
  static final HitRegion ZPosNeg = HitRegion._(0x0140);

  /// [Cardinals] is the combination of all cardinal directions,
  /// XPos|XNeg|YPos|YNeg|ZPos|ZNeg.
  static final HitRegion Cardinals = HitRegion._(0x016D);

  /// The combined hit region value.
  final int _value;

  /// Creates a new hit region value.
  HitRegion._(this._value);

  /// Combines two hit region values into one.
  HitRegion operator |(HitRegion right) => HitRegion._(this._value | right._value);

  /// Unions two hit region values.
  HitRegion operator &(HitRegion right) => HitRegion._(this._value & right._value);

  /// Gets the opposite value of this hit region value from All.
  HitRegion operator ~() => HitRegion._(All._value & ~this._value);

  /// Gets the reverse of the the two opposite values.
  int _partialInverse(
    final HitRegion pos,
    final HitRegion neg,
  ) =>
      (() {
        if (this.has(pos)) {
          return neg._value;
        } else {
          return None._value;
        }
      }()) |
      (() {
        if (this.has(neg)) {
          return pos._value;
        } else {
          return None._value;
        }
      }());

  /// Gets the opposite of all the directions of the region.
  HitRegion inverse() => HitRegion._((Inside._value & this._value) |
      this._partialInverse(XPos, XNeg) |
      this._partialInverse(YPos, YNeg) |
      this._partialInverse(ZPos, ZNeg));

  /// The internal value of the hit region value.
  int get value => this._value;

  /// Determines if any part of the given hit region value is contained in this hit region value.
  bool overlaps(HitRegion region) => (this._value & region._value) != 0x0000;

  /// Determines if this hit region value contains the all of the given hit region value.
  bool has(HitRegion region) => (this._value & region._value) == region._value;

  /// Determines if the given [other] variable is a [HitRegion] equal to this value.
  @override
  bool operator ==(Object other) {
    if (other is! HitRegion) return false;
    return this._value == other._value;
  }

  @override
  int get hashCode => _value.hashCode;

  /// The string for this hit region value.
  @override
  String toString() {
    if (this._value == All.value) {
      return "All";
    } else if (this._value == Inside.value) {
      return "Inside";
    } else {
      final parts = <String>[];
      if (this.has(XPos)) parts.add("XPos");
      if (this.has(XCenter)) parts.add("XCenter");
      if (this.has(XNeg)) parts.add("XNeg");
      if (this.has(YPos)) parts.add("YPos");
      if (this.has(YCenter)) parts.add("YCenter");
      if (this.has(YNeg)) parts.add("YNeg");
      if (this.has(ZPos)) parts.add("ZPos");
      if (this.has(ZCenter)) parts.add("ZCenter");
      if (this.has(ZNeg)) parts.add("ZNeg");
      if (parts.isEmpty) return "None";
      return parts.join("|");
    }
  }
}

/// A math structure for storing and manipulating a Matrix 2x2.
class Matrix2 {
  /// Gets a 2x2 identity matrix.
  static Matrix2 get identity => _identSingleton ??= const Matrix2(1.0, 0.0, 0.0, 1.0);
  static Matrix2? _identSingleton;

  /// The 1st row and 1st column of the matrix, XX.
  final double m11;

  /// The 1st row and 2nd column of the matrix, XY.
  final double m21;

  /// The 2nd row and 1st column of the matrix, YX.
  final double m12;

  /// The 2nd row and 2nd column of the matrix, YY.
  final double m22;

  /// Constructs a new [Matrix2] with the given initial values.
  const Matrix2(
    final this.m11,
    final this.m21,
    final this.m12,
    final this.m22,
  );

  /// Constructs a 2x2 scalar matrix.
  ///
  /// [sx] scales the x axis and [sy] scales the y axis.
  factory Matrix2.scale(double sx, double sy) => Matrix2(sx, 0.0, 0.0, sy);

  /// Constructs a 2x2 rotation matrix.
  ///
  /// The given [angle] is in radians.
  /// This matrix rotates counter-clockwise around a virtual Z axis.
  factory Matrix2.rotate(double angle) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return Matrix2(c, -s, s, c);
  }

  /// Constructs a 2x2 matrix from a trimmed 3x3 matrix.
  ///
  /// The 3rd row and column are ignored from [mat].
  factory Matrix2.fromMatrix3(Matrix3 mat) => Matrix2(mat.m11, mat.m21, mat.m12, mat.m22);

  /// Constructs a 2x2 matrix from a trimmed 4x4 matrix.
  ///
  /// The 3rd and 4th row and column are ignored from [mat].
  factory Matrix2.fromMatrix4(Matrix4 mat) => Matrix2(mat.m11, mat.m21, mat.m12, mat.m22);

  /// Constructs a new [Matrix2] instance given a list of 4 doubles.
  /// By default the list is in row major order.
  factory Matrix2.fromList(List<double> values, [bool columnMajor = false]) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    if (columnMajor) {
      return Matrix2(values[0], values[2], values[1], values[3]);
    } else {
      return Matrix2(values[0], values[1], values[2], values[3]);
    }
  }

  /// Gets the list of 4 doubles for the matrix.
  /// By default the list is in row major order.
  List<double> toList([bool columnMajor = false]) {
    if (columnMajor) {
      return [this.m11, this.m12, this.m21, this.m22];
    } else {
      return [this.m11, this.m21, this.m12, this.m22];
    }
  }

  /// Gets the value at the zero based index in row major order.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.m11;
      case 1:
        return this.m12;
      case 2:
        return this.m21;
      case 3:
        return this.m22;
    }
    return 0.0;
  }

  /// Gets the determinant of this matrix.
  double det() => this.m11 * this.m22 - this.m21 * this.m12;

  /// Gets the transposition of this matrix.
  Matrix2 transpose() => Matrix2(this.m11, this.m12, this.m21, this.m22);

  /// Gets the inverse of this matrix.
  Matrix2 inverse() {
    final double det = this.det();
    if (Comparer.equals(det, 0.0)) return Matrix2.identity;
    final double q = 1.0 / det;
    return Matrix2(this.m22 * q, -this.m21 * q, -this.m12 * q, this.m11 * q);
  }

  /// Multiplies this matrix by the [other] matrix.
  Matrix2 operator *(Matrix2 other) => Matrix2(
      this.m11 * other.m11 + this.m21 * other.m12,
      this.m11 * other.m21 + this.m21 * other.m22,
      this.m12 * other.m11 + this.m22 * other.m12,
      this.m12 * other.m21 + this.m22 * other.m22);

  /// Transposes the given [vec] with this matrix.
  Vector2 transVec2(Vector2 vec) =>
      Vector2(this.m11 * vec.dx + this.m21 * vec.dy, this.m12 * vec.dx + this.m22 * vec.dy);

  /// Transposes the given [pnt] with this matrix.
  Point2 transPnt2(Point2 pnt) => Point2(this.m11 * pnt.x + this.m21 * pnt.y, this.m12 * pnt.x + this.m22 * pnt.y);

  /// Determines if the given [other] variable is a [Matrix2] equal to this matrix.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Matrix2) return false;
    if (!Comparer.equals(other.m11, this.m11)) return false;
    if (!Comparer.equals(other.m21, this.m21)) return false;
    if (!Comparer.equals(other.m12, this.m12)) return false;
    if (!Comparer.equals(other.m22, this.m22)) return false;
    return true;
  }

  @override
  int get hashCode => m11.hashCode ^ m21.hashCode ^ m12.hashCode ^ m22.hashCode;

  /// Gets the string for this matrix.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this matrix.
  String format([String indent = "", int fraction = 3, int whole = 0]) {
    final List<String> col1 = formatColumn([this.m11, this.m12], fraction, whole);
    final List<String> col2 = formatColumn([this.m21, this.m22], fraction, whole);
    return '[${col1[0]}, ${col2[0]},\n$indent ${col1[1]}, ${col2[1]}]';
  }
}

/// A math structure for storing and manipulating a Matrix 3x3.
class Matrix3 {
  /// Gets a 3x3 identity matrix.
  static Matrix3 get identity => _identSingleton ??= Matrix3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);
  static Matrix3? _identSingleton;

  /// The 1st row and 1st column of the matrix, XX.
  final double m11;

  /// The 1st row and 2nd column of the matrix, XY.
  final double m21;

  /// The 1st row and 3rd column of the matrix, XZ.
  final double m31;

  /// The 2nd row and 1st column of the matrix, YX.
  final double m12;

  /// The 2nd row and 2nd column of the matrix, YY.
  final double m22;

  /// The 2nd row and 3rd column of the matrix, YZ.
  final double m32;

  /// The 3rd row and 1st column of the matrix, ZX.
  final double m13;

  /// The 3rd row and 2nd column of the matrix, ZY.
  final double m23;

  /// The 3rd row and 3rd column of the matrix, ZZ.
  final double m33;

  /// Constructs a new [Matrix3] with the given initial values.
  Matrix3(this.m11, this.m21, this.m31, this.m12, this.m22, this.m32, this.m13, this.m23, this.m33);

  /// Constructs a 3x3 translation matrix.
  factory Matrix3.translate(double tx, double ty) => Matrix3(1.0, 0.0, tx, 0.0, 1.0, ty, 0.0, 0.0, 1.0);

  /// Constructs a 3x3 scalar matrix.
  factory Matrix3.scale(double sx, double sy, [double sz = 1.0]) => Matrix3(sx, 0.0, 0.0, 0.0, sy, 0.0, 0.0, 0.0, sz);

  /// Constructs a 3x3 X axis rotation matrix.
  ///
  /// The given [angle] is in radians.
  factory Matrix3.rotateX(double angle) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return Matrix3(1.0, 0.0, 0.0, 0.0, c, -s, 0.0, s, c);
  }

  /// Constructs a 3x3 Y axis rotation matrix.
  ///
  /// The given [angle] is in radians.
  factory Matrix3.rotateY(double angle) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return Matrix3(c, 0.0, -s, 0.0, 1.0, 0.0, s, 0.0, c);
  }

  /// Constructs a 3x3 Z axis rotation matrix.
  ///
  /// The given [angle] is in radians.
  factory Matrix3.rotateZ(double angle) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return Matrix3(c, -s, 0.0, s, c, 0.0, 0.0, 0.0, 1.0);
  }

  /// Constructs a 3x3 matrix from a 2x2 matrix.
  ///
  /// [mat] is padded with zeros except in ZZ which is set to 1.0.
  factory Matrix3.fromMatrix2(Matrix2 mat) => Matrix3(mat.m11, mat.m21, 0.0, mat.m12, mat.m22, 0.0, 0.0, 0.0, 1.0);

  /// Constructs a 3x3 matrix from a trimmed 4x4 matrix.
  ///
  /// The 4rd row and column are ignored from [mat].
  factory Matrix3.fromMatrix4(Matrix4 mat) =>
      Matrix3(mat.m11, mat.m21, mat.m31, mat.m12, mat.m22, mat.m32, mat.m13, mat.m23, mat.m33);

  /// Constructs a 3x3 matrix from the given quaternion.
  factory Matrix3.fromQuaternion(Quaternion a) {
    final aa = a.a + a.a, bb = a.b + a.b, cc = a.c + a.c;
    final a2 = a.a * aa, b2 = a.b * bb, c2 = a.c * cc;
    final bc = a.b * cc, ab = a.a * bb, ac = a.a * cc;
    final ta = a.t * aa, tb = a.t * bb, tc = a.t * cc;
    return Matrix3(
        1.0 - (b2 + c2), ab - tc, ac + tb, ab + tc, 1.0 - (a2 + c2), bc - ta, ac - tb, bc + ta, 1.0 - (a2 + b2));
  }

  /// Constructs a new [Matrix3] instance given a list of 9 doubles.
  /// By default the list is in row major order.
  factory Matrix3.fromList(List<double> values, [bool columnMajor = false]) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 9);
    if (columnMajor) {
      return Matrix3(values[0], values[3], values[6], values[1], values[4], values[7], values[2], values[5], values[8]);
    } else {
      return Matrix3(values[0], values[1], values[2], values[3], values[4], values[5], values[6], values[7], values[8]);
    }
  }

  /// Gets the list of 9 doubles for the matrix.
  /// By default the list is in row major order.
  List<double> toList([bool columnMajor = false]) {
    if (columnMajor) {
      return [this.m11, this.m12, this.m13, this.m21, this.m22, this.m23, this.m31, this.m32, this.m33];
    } else {
      return [this.m11, this.m21, this.m31, this.m12, this.m22, this.m32, this.m13, this.m23, this.m33];
    }
  }

  /// Gets the value at the zero based index in row major order.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.m11;
      case 1:
        return this.m12;
      case 2:
        return this.m13;
      case 3:
        return this.m21;
      case 4:
        return this.m22;
      case 5:
        return this.m23;
      case 6:
        return this.m31;
      case 7:
        return this.m32;
      case 8:
        return this.m33;
    }
    return 0.0;
  }

  /// Gets the determinant of this matrix.
  double det() =>
      this.m11 * (this.m22 * this.m33 - this.m32 * this.m23) -
      this.m12 * (this.m21 * this.m33 - this.m23 * this.m31) +
      this.m13 * (this.m21 * this.m32 - this.m22 * this.m31);

  /// Gets the transposition of this matrix.
  Matrix3 transpose() =>
      Matrix3(this.m11, this.m12, this.m13, this.m21, this.m22, this.m23, this.m31, this.m32, this.m33);

  /// Gets the inverse of this matrix.
  Matrix3 inverse() {
    final double det = this.det();
    if (Comparer.equals(det, 0.0)) return Matrix3.identity;
    final double q = 1.0 / det;
    return Matrix3(
        (this.m22 * this.m33 - this.m23 * this.m32) * q,
        (this.m23 * this.m31 - this.m21 * this.m33) * q,
        (this.m21 * this.m32 - this.m22 * this.m31) * q,
        (this.m13 * this.m32 - this.m12 * this.m33) * q,
        (this.m11 * this.m33 - this.m13 * this.m31) * q,
        (this.m12 * this.m31 - this.m11 * this.m32) * q,
        (this.m12 * this.m23 - this.m13 * this.m22) * q,
        (this.m13 * this.m21 - this.m11 * this.m23) * q,
        (this.m11 * this.m22 - this.m12 * this.m21) * q);
  }

  /// Multiplies this matrix by the [other] matrix.
  Matrix3 operator *(Matrix3 other) => Matrix3(
      this.m11 * other.m11 + this.m21 * other.m12 + this.m31 * other.m13,
      this.m11 * other.m21 + this.m21 * other.m22 + this.m31 * other.m23,
      this.m11 * other.m31 + this.m21 * other.m32 + this.m31 * other.m33,
      this.m12 * other.m11 + this.m22 * other.m12 + this.m32 * other.m13,
      this.m12 * other.m21 + this.m22 * other.m22 + this.m32 * other.m23,
      this.m12 * other.m31 + this.m22 * other.m32 + this.m32 * other.m33,
      this.m13 * other.m11 + this.m23 * other.m12 + this.m33 * other.m13,
      this.m13 * other.m21 + this.m23 * other.m22 + this.m33 * other.m23,
      this.m13 * other.m31 + this.m23 * other.m32 + this.m33 * other.m33);

  /// Transposes the given [vec] with this matrix.
  ///
  /// The Z component of the point is treated a 0.0,
  /// meaning the 3rd (Z) row and column of the matrix are not used.
  Vector2 transVec2(Vector2 vec) =>
      Vector2(this.m11 * vec.dx + this.m21 * vec.dy, this.m12 * vec.dx + this.m22 * vec.dy);

  /// Transposes the given [pnt] with this matrix.
  ///
  /// The Z component of the point is treated a 1.0,
  /// meaning the 3rd (Z) column of the matrix can be used for translation.
  Point2 transPnt2(Point2 pnt) =>
      Point2(this.m11 * pnt.x + this.m21 * pnt.y + this.m31, this.m12 * pnt.x + this.m22 * pnt.y + this.m32);

  /// Transposes the given [vec] with this matrix.
  Vector3 transVec3(Vector3 vec) => Vector3(
      this.m11 * vec.dx + this.m21 * vec.dy + this.m31 * vec.dz,
      this.m12 * vec.dx + this.m22 * vec.dy + this.m32 * vec.dz,
      this.m13 * vec.dx + this.m23 * vec.dy + this.m33 * vec.dz);

  /// Transposes the given [pnt] with this matrix.
  Point3 transPnt3(Point3 pnt) => Point3(this.m11 * pnt.x + this.m21 * pnt.y + this.m31 * pnt.z,
      this.m12 * pnt.x + this.m22 * pnt.y + this.m32 * pnt.z, this.m13 * pnt.x + this.m23 * pnt.y + this.m33 * pnt.z);

  /// Transposes the given [clr] with this matrix.
  Color3 transClr3(Color3 clr) => Color3(
      this.m11 * clr.red + this.m21 * clr.green + this.m31 * clr.blue,
      this.m12 * clr.red + this.m22 * clr.green + this.m32 * clr.blue,
      this.m13 * clr.red + this.m23 * clr.green + this.m33 * clr.blue);

  /// Transposes the given [clr] with this matrix.
  ///
  /// The alpha component is not modified.
  Color4 transClr4(Color4 clr) => Color4(
      this.m11 * clr.red + this.m21 * clr.green + this.m31 * clr.blue,
      this.m12 * clr.red + this.m22 * clr.green + this.m32 * clr.blue,
      this.m13 * clr.red + this.m23 * clr.green + this.m33 * clr.blue,
      clr.alpha);

  /// Determines if the given [other] variable is a [Matrix3] equal to this matrix.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Matrix3) return false;
    if (!Comparer.equals(other.m11, this.m11)) return false;
    if (!Comparer.equals(other.m21, this.m21)) return false;
    if (!Comparer.equals(other.m31, this.m31)) return false;
    if (!Comparer.equals(other.m12, this.m12)) return false;
    if (!Comparer.equals(other.m22, this.m22)) return false;
    if (!Comparer.equals(other.m32, this.m32)) return false;
    if (!Comparer.equals(other.m13, this.m13)) return false;
    if (!Comparer.equals(other.m23, this.m23)) return false;
    if (!Comparer.equals(other.m33, this.m33)) return false;
    return true;
  }

  @override
  int get hashCode =>
      m11.hashCode ^
      m21.hashCode ^
      m31.hashCode ^
      m12.hashCode ^
      m22.hashCode ^
      m32.hashCode ^
      m13.hashCode ^
      m23.hashCode ^
      m33.hashCode;

  /// Gets the string for this matrix.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this matrix.
  String format([String indent = "", int fraction = 3, int whole = 0]) {
    final List<String> col1 = formatColumn([this.m11, this.m12, this.m13], fraction, whole);
    final List<String> col2 = formatColumn([this.m21, this.m22, this.m23], fraction, whole);
    final List<String> col3 = formatColumn([this.m31, this.m32, this.m33], fraction, whole);
    return '[${col1[0]}, ${col2[0]}, ${col3[0]},\n' +
        '$indent ${col1[1]}, ${col2[1]}, ${col3[1]},\n' +
        '$indent ${col1[2]}, ${col2[2]}, ${col3[2]}]';
  }
}

/// A math structure for storing and manipulating a Matrix 4x4.
class Matrix4 {
  /// Gets a 4x4 identity matrix.
  static Matrix4 get identity =>
      _identSingleton ??= Matrix4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0);
  static Matrix4? _identSingleton;

  /// The 1st row and 1st column of the matrix, XX.
  final double m11;

  /// The 1st row and 2nd column of the matrix, XY.
  final double m21;

  /// The 1st row and 3rd column of the matrix, XZ.
  final double m31;

  /// The 1st row and 4th column of the matrix, XW.
  final double m41;

  /// The 2nd row and 1st column of the matrix, YX.
  final double m12;

  /// The 2nd row and 2nd column of the matrix, YY.
  final double m22;

  /// The 2nd row and 3rd column of the matrix, YZ.
  final double m32;

  /// The 2nd row and 4th column of the matrix, YW.
  final double m42;

  /// The 3rd row and 1st column of the matrix, ZX.
  final double m13;

  /// The 3rd row and 2nd column of the matrix, ZY.
  final double m23;

  /// The 3rd row and 3rd column of the matrix, ZZ.
  final double m33;

  /// The 3rd row and 4th column of the matrix, ZW.
  final double m43;

  /// The 4th row and 1st column of the matrix, WX.
  final double m14;

  /// The 4th row and 2nd column of the matrix, WY.
  final double m24;

  /// The 4th row and 3rd column of the matrix, WZ.
  final double m34;

  /// The 4th row and 4th column of the matrix, WW.
  final double m44;

  /// Constructs a new [Matrix4] with the given initial values.
  Matrix4(this.m11, this.m21, this.m31, this.m41, this.m12, this.m22, this.m32, this.m42, this.m13, this.m23, this.m33,
      this.m43, this.m14, this.m24, this.m34, this.m44);

  /// Constructs a 4x4 translation matrix.
  factory Matrix4.translate(double tx, double ty, double tz) =>
      Matrix4(1.0, 0.0, 0.0, tx, 0.0, 1.0, 0.0, ty, 0.0, 0.0, 1.0, tz, 0.0, 0.0, 0.0, 1.0);

  /// Constructs a 4x4 scalar matrix.
  factory Matrix4.scale(double sx, double sy, double sz, [double sw = 1.0]) =>
      Matrix4(sx, 0.0, 0.0, 0.0, 0.0, sy, 0.0, 0.0, 0.0, 0.0, sz, 0.0, 0.0, 0.0, 0.0, sw);

  /// Constructs a 4x4 rotation matrix.
  ///
  /// The given [angle] is in radians.
  /// The given [vec] is the vector to rotate around.
  factory Matrix4.rotate(double angle, Vector3 vec) {
    final double c = math.cos(angle);
    final double n = 1.0 - c;
    final double s = math.sin(angle);
    final m11 = vec.dx * vec.dx * n + c,
        m21 = vec.dx * vec.dy * n - vec.dz * s,
        m31 = vec.dx * vec.dz * n + vec.dy * s,
        m12 = vec.dy * vec.dx * n + vec.dz * s,
        m22 = vec.dy * vec.dy * n + c,
        m32 = vec.dy * vec.dz * n - vec.dx * s,
        m13 = vec.dz * vec.dx * n - vec.dy * s,
        m23 = vec.dx * vec.dy * n + vec.dx * s,
        m33 = vec.dz * vec.dz * n + c;
    return Matrix4(m11, m21, m31, 0.0, m12, m22, m32, 0.0, m13, m23, m33, 0.0, 0.0, 0.0, 0.0, 1.0);
  }

  /// Constructs a 4x4 X axis rotation matrix.
  ///
  /// The given [angle] is in radians.
  factory Matrix4.rotateX(double angle) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return Matrix4(1.0, 0.0, 0.0, 0.0, 0.0, c, -s, 0.0, 0.0, s, c, 0.0, 0.0, 0.0, 0.0, 1.0);
  }

  /// Constructs a 4x4 Y axis rotation matrix.
  ///
  /// The given [angle] is in radians.
  factory Matrix4.rotateY(double angle) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return Matrix4(c, 0.0, -s, 0.0, 0.0, 1.0, 0.0, 0.0, s, 0.0, c, 0.0, 0.0, 0.0, 0.0, 1.0);
  }

  /// Constructs a 4x4 Z axis rotation matrix.
  ///
  /// The given [angle] is in radians.
  factory Matrix4.rotateZ(double angle) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return Matrix4(c, -s, 0.0, 0.0, s, c, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0);
  }

  /// Constructs a new perspective projection matrix.
  ///
  /// Constructs a projection for a right hand coordinate system.
  /// The given [angle] is in radians of the field of view.
  /// The given [ratio] is the width over the height of the view.
  /// The [near] and [far] depth of the view.
  factory Matrix4.perspective(double angle, double ratio, double near, double far) {
    final double depth = far - near;
    final double yy = 1.0 / math.tan(angle * 0.5);
    final double xx = -yy / ratio;
    final double zz = far / depth;
    final double zw = -far * near / depth;
    return Matrix4(xx, 0.0, 0.0, 0.0, 0.0, yy, 0.0, 0.0, 0.0, 0.0, zz, zw, 0.0, 0.0, 1.0, 0.0);
  }

  /// Constructs a new orthographic projection matrix.
  ///
  /// [left] and [right] are the horizontal visible range.
  /// [top] and [bottom] are the vertical visible range.
  /// The [near] and [far] depth of the view.
  factory Matrix4.ortho(double left, double right, double top, double bottom, double near, double far) {
    final double xx = 2.0 / (right - left);
    final double yy = 2.0 / (top - bottom);
    final double zz = 2.0 / (far - near);
    final double wx = -(left + right) / (right - left);
    final double wy = -(top + bottom) / (top - bottom);
    final double wz = (far + near) / (far - near);
    return Matrix4(xx, 0.0, 0.0, wx, 0.0, yy, 0.0, wy, 0.0, 0.0, zz, wz, 0.0, 0.0, 0.0, 1.0);
  }

  /// Constructs a matrix with a vector towards the given direction.
  ///
  /// [x]. [y], and [z] is the vector direction.
  /// [upHint] is a hint to help correct the top direction of the rotation.
  factory Matrix4.vectorTowards(double x, double y, double z, {Vector3? upHint}) {
    upHint ??= Vector3.posY;
    final Vector3 forward = Vector3(x, y, z);
    return Matrix4.lookTowards(Point3.zero, upHint, forward);
  }

  /// Constructs a camera matrix.
  ///
  /// [pos] is the position of the camera,
  /// [up] is the top direction of the camera,
  /// and [forward] is the direction the camera is looking towards.
  factory Matrix4.lookTowards(Point3 pos, Vector3 up, Vector3 forward) {
    final Vector3 zaxis = forward.normal();
    final Vector3 xaxis = up.cross(zaxis).normal();
    final Vector3 yaxis = zaxis.cross(xaxis);
    final Vector3 toPos = Vector3.fromPoint3(pos);
    final double tx = (-xaxis).dot(toPos);
    final double ty = (-yaxis).dot(toPos);
    final double tz = (-zaxis).dot(toPos);
    return Matrix4(xaxis.dx, yaxis.dx, zaxis.dx, tx, xaxis.dy, yaxis.dy, zaxis.dy, ty, xaxis.dz, yaxis.dz, zaxis.dz, tz,
        0.0, 0.0, 0.0, 1.0);
  }

  /// Constructs a camera matrix.
  ///
  /// [pos] is the position of the camera,
  /// [up] is the top direction of the camera,
  /// and [focus] is the point the camera is looking at.
  factory Matrix4.lookAtTarget(Point3 pos, Vector3 up, Point3 focus) =>
      Matrix4.lookTowards(pos, up, pos.vectorTo(focus));

  /// Constructs a 4x4 matrix from a 2x3 matrix.
  ///
  /// [mat] is padded with zeros except in ZZ and WW which is set to 1.0.
  factory Matrix4.fromMatrix2(Matrix2 mat) =>
      Matrix4(mat.m11, mat.m21, 0.0, 0.0, mat.m12, mat.m22, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0);

  /// Constructs a 4x4 matrix from a 3x3 matrix.
  ///
  /// [mat] is padded with zeros except in WW which is set to 1.0.
  factory Matrix4.fromMatrix3(Matrix3 mat) => Matrix4(mat.m11, mat.m21, mat.m31, 0.0, mat.m12, mat.m22, mat.m32, 0.0,
      mat.m13, mat.m23, mat.m33, 0.0, 0.0, 0.0, 0.0, 1.0);

  /// Constructs a new [Matrix4] instance given a list of 16 doubles.
  /// By default the list is in row major order.
  factory Matrix4.fromList(List<double> values, [bool columnMajor = false]) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 16);
    if (columnMajor) {
      return Matrix4(values[0], values[4], values[8], values[12], values[1], values[5], values[9], values[13],
          values[2], values[6], values[10], values[14], values[3], values[7], values[11], values[15]);
    } else {
      return Matrix4(values[0], values[1], values[2], values[3], values[4], values[5], values[6], values[7], values[8],
          values[9], values[10], values[11], values[12], values[13], values[14], values[15]);
    }
  }

  /// Gets the list of 16 doubles for the matrix.
  /// By default the list is in row major order.
  List<double> toList([bool columnMajor = false]) {
    if (columnMajor) {
      return [
        this.m11,
        this.m12,
        this.m13,
        this.m14,
        this.m21,
        this.m22,
        this.m23,
        this.m24,
        this.m31,
        this.m32,
        this.m33,
        this.m34,
        this.m41,
        this.m42,
        this.m43,
        this.m44
      ];
    } else {
      return [
        this.m11,
        this.m21,
        this.m31,
        this.m41,
        this.m12,
        this.m22,
        this.m32,
        this.m42,
        this.m13,
        this.m23,
        this.m33,
        this.m43,
        this.m14,
        this.m24,
        this.m34,
        this.m44
      ];
    }
  }

  /// Gets the value at the zero based index in row major order.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.m11;
      case 1:
        return this.m12;
      case 2:
        return this.m13;
      case 3:
        return this.m14;
      case 4:
        return this.m21;
      case 5:
        return this.m22;
      case 6:
        return this.m23;
      case 7:
        return this.m24;
      case 8:
        return this.m31;
      case 9:
        return this.m32;
      case 10:
        return this.m33;
      case 11:
        return this.m34;
      case 12:
        return this.m41;
      case 13:
        return this.m42;
      case 14:
        return this.m43;
      case 15:
        return this.m44;
    }
    return 0.0;
  }

  /// Gets the determinant of this matrix.
  double det() {
    final double a = this.m14 * this.m23 - this.m13 * this.m24;
    final double b = this.m12 * this.m24 - this.m14 * this.m22;
    final double c = this.m13 * this.m22 - this.m12 * this.m23;
    final double d = this.m14 * this.m21 - this.m11 * this.m24;
    final double e = this.m11 * this.m23 - this.m13 * this.m21;
    final double f = this.m12 * this.m21 - this.m11 * this.m22;
    return (a * this.m32 + b * this.m33 + c * this.m34) * this.m41 -
        (a * this.m31 - d * this.m33 - e * this.m34) * this.m42 -
        (b * this.m31 + d * this.m32 - f * this.m34) * this.m43 -
        (c * this.m31 + e * this.m32 + f * this.m33) * this.m44;
  }

  /// Gets the transposition of this matrix.
  Matrix4 transpose() => Matrix4(this.m11, this.m12, this.m13, this.m14, this.m21, this.m22, this.m23, this.m24,
      this.m31, this.m32, this.m33, this.m34, this.m41, this.m42, this.m43, this.m44);

  /// Gets the inverse of this matrix.
  Matrix4 inverse() {
    final a = this.m11 * this.m22 - this.m21 * this.m12,
        b = this.m11 * this.m32 - this.m31 * this.m12,
        c = this.m11 * this.m42 - this.m41 * this.m12,
        e = this.m21 * this.m32 - this.m31 * this.m22,
        g = this.m21 * this.m42 - this.m41 * this.m22,
        h = this.m31 * this.m42 - this.m41 * this.m32,
        i = this.m13 * this.m24 - this.m23 * this.m14,
        j = this.m13 * this.m34 - this.m33 * this.m14,
        l = this.m13 * this.m44 - this.m43 * this.m14,
        m = this.m23 * this.m34 - this.m33 * this.m24,
        n = this.m23 * this.m44 - this.m43 * this.m24,
        o = this.m33 * this.m44 - this.m43 * this.m34;
    final double det = a * o - b * n + c * m + e * l - g * j + h * i;
    if (Comparer.equals(det, 0.0)) return Matrix4.identity;
    final double q = 1.0 / det;
    return Matrix4(
        (this.m22 * o - this.m32 * n + this.m42 * m) * q,
        (-this.m21 * o + this.m31 * n - this.m41 * m) * q,
        (this.m24 * h - this.m34 * g + this.m44 * e) * q,
        (-this.m23 * h + this.m33 * g - this.m43 * e) * q,
        (-this.m12 * o + this.m32 * l - this.m42 * j) * q,
        (this.m11 * o - this.m31 * l + this.m41 * j) * q,
        (-this.m14 * h + this.m34 * c - this.m44 * b) * q,
        (this.m13 * h - this.m33 * c + this.m43 * b) * q,
        (this.m12 * n - this.m22 * l + this.m42 * i) * q,
        (-this.m11 * n + this.m21 * l - this.m41 * i) * q,
        (this.m14 * g - this.m24 * c + this.m44 * a) * q,
        (-this.m13 * g + this.m23 * c - this.m43 * a) * q,
        (-this.m12 * m + this.m22 * j - this.m32 * i) * q,
        (this.m11 * m - this.m21 * j + this.m31 * i) * q,
        (-this.m14 * e + this.m24 * b - this.m34 * a) * q,
        (this.m13 * e - this.m23 * b + this.m33 * a) * q);
  }

  /// Multiplies this matrix by the [other] matrix.
  Matrix4 operator *(Matrix4 other) => Matrix4(
      this.m11 * other.m11 + this.m21 * other.m12 + this.m31 * other.m13 + this.m41 * other.m14,
      this.m11 * other.m21 + this.m21 * other.m22 + this.m31 * other.m23 + this.m41 * other.m24,
      this.m11 * other.m31 + this.m21 * other.m32 + this.m31 * other.m33 + this.m41 * other.m34,
      this.m11 * other.m41 + this.m21 * other.m42 + this.m31 * other.m43 + this.m41 * other.m44,
      this.m12 * other.m11 + this.m22 * other.m12 + this.m32 * other.m13 + this.m42 * other.m14,
      this.m12 * other.m21 + this.m22 * other.m22 + this.m32 * other.m23 + this.m42 * other.m24,
      this.m12 * other.m31 + this.m22 * other.m32 + this.m32 * other.m33 + this.m42 * other.m34,
      this.m12 * other.m41 + this.m22 * other.m42 + this.m32 * other.m43 + this.m42 * other.m44,
      this.m13 * other.m11 + this.m23 * other.m12 + this.m33 * other.m13 + this.m43 * other.m14,
      this.m13 * other.m21 + this.m23 * other.m22 + this.m33 * other.m23 + this.m43 * other.m24,
      this.m13 * other.m31 + this.m23 * other.m32 + this.m33 * other.m33 + this.m43 * other.m34,
      this.m13 * other.m41 + this.m23 * other.m42 + this.m33 * other.m43 + this.m43 * other.m44,
      this.m14 * other.m11 + this.m24 * other.m12 + this.m34 * other.m13 + this.m44 * other.m14,
      this.m14 * other.m21 + this.m24 * other.m22 + this.m34 * other.m23 + this.m44 * other.m24,
      this.m14 * other.m31 + this.m24 * other.m32 + this.m34 * other.m33 + this.m44 * other.m34,
      this.m14 * other.m41 + this.m24 * other.m42 + this.m34 * other.m43 + this.m44 * other.m44);

  /// Transposes the given [vec] with this matrix.
  ///
  /// The Z component of the point is treated a 0.0,
  /// meaning the 4th (W) row and column of the matrix are not used.
  Vector2 transVec2(Vector2 vec) =>
      Vector2(this.m11 * vec.dx + this.m21 * vec.dy, this.m12 * vec.dx + this.m22 * vec.dy);

  /// Transposes the given [pnt] with this matrix.
  ///
  /// The W component of the point is treated a 1.0,
  /// meaning the 4th (W) column of the matrix can be used for translation.
  Point2 transPnt2(Point2 pnt) =>
      Point2(this.m11 * pnt.x + this.m21 * pnt.y + this.m41, this.m12 * pnt.x + this.m22 * pnt.y + this.m42);

  /// Transposes the given [vec] with this matrix.
  ///
  /// The Z component of the point is treated a 0.0,
  /// meaning the 4th (W) row and column of the matrix are not used.
  Vector3 transVec3(Vector3 vec) => Vector3(
      this.m11 * vec.dx + this.m21 * vec.dy + this.m31 * vec.dz,
      this.m12 * vec.dx + this.m22 * vec.dy + this.m32 * vec.dz,
      this.m13 * vec.dx + this.m23 * vec.dy + this.m33 * vec.dz);

  /// Transposes the given [pnt] with this matrix.
  ///
  /// The W component of the point is treated a 1.0,
  /// meaning the 4th (W) column of the matrix can be used for translation.
  Point3 transPnt3(Point3 pnt) => Point3(
      this.m11 * pnt.x + this.m21 * pnt.y + this.m31 * pnt.z + this.m41,
      this.m12 * pnt.x + this.m22 * pnt.y + this.m32 * pnt.z + this.m42,
      this.m13 * pnt.x + this.m23 * pnt.y + this.m33 * pnt.z + this.m43);

  /// Transposes the given [vec] with this matrix.
  Vector4 transVec4(Vector4 vec) => Vector4(
      this.m11 * vec.dx + this.m21 * vec.dy + this.m31 * vec.dz + this.m41 * vec.dw,
      this.m12 * vec.dx + this.m22 * vec.dy + this.m32 * vec.dz + this.m42 * vec.dw,
      this.m13 * vec.dx + this.m23 * vec.dy + this.m33 * vec.dz + this.m43 * vec.dw,
      this.m14 * vec.dx + this.m24 * vec.dy + this.m34 * vec.dz + this.m44 * vec.dw);

  /// Transposes the given [pnt] with this matrix.
  Point4 transPnt4(Point4 pnt) => Point4(
      this.m11 * pnt.x + this.m21 * pnt.y + this.m31 * pnt.z + this.m41 * pnt.w,
      this.m12 * pnt.x + this.m22 * pnt.y + this.m32 * pnt.z + this.m42 * pnt.w,
      this.m13 * pnt.x + this.m23 * pnt.y + this.m33 * pnt.z + this.m43 * pnt.w,
      this.m14 * pnt.x + this.m24 * pnt.y + this.m34 * pnt.z + this.m44 * pnt.w);

  /// Transposes the given [clr] with this matrix.
  ///
  /// The A component of the color is treated a 1.0,
  /// meaning the 4th (A) column of the matrix can be used for translation.
  Color3 transClr3(Color3 clr) => Color3(
      this.m11 * clr.red + this.m21 * clr.green + this.m31 * clr.blue + this.m41,
      this.m12 * clr.red + this.m22 * clr.green + this.m32 * clr.blue + this.m42,
      this.m13 * clr.red + this.m23 * clr.green + this.m33 * clr.blue + this.m43);

  /// Transposes the given [clr] with this matrix.
  Color4 transClr4(Color4 clr) => Color4(
      this.m11 * clr.red + this.m21 * clr.green + this.m31 * clr.blue + this.m41 * clr.alpha,
      this.m12 * clr.red + this.m22 * clr.green + this.m32 * clr.blue + this.m42 * clr.alpha,
      this.m13 * clr.red + this.m23 * clr.green + this.m33 * clr.blue + this.m43 * clr.alpha,
      this.m14 * clr.red + this.m24 * clr.green + this.m34 * clr.blue + this.m44 * clr.alpha);

  /// Determines if the given [other] variable is a [Matrix4] equal to this matrix.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Matrix4) return false;
    if (!Comparer.equals(other.m11, this.m11)) return false;
    if (!Comparer.equals(other.m21, this.m21)) return false;
    if (!Comparer.equals(other.m31, this.m31)) return false;
    if (!Comparer.equals(other.m41, this.m41)) return false;
    if (!Comparer.equals(other.m12, this.m12)) return false;
    if (!Comparer.equals(other.m22, this.m22)) return false;
    if (!Comparer.equals(other.m32, this.m32)) return false;
    if (!Comparer.equals(other.m42, this.m42)) return false;
    if (!Comparer.equals(other.m13, this.m13)) return false;
    if (!Comparer.equals(other.m23, this.m23)) return false;
    if (!Comparer.equals(other.m33, this.m33)) return false;
    if (!Comparer.equals(other.m43, this.m43)) return false;
    if (!Comparer.equals(other.m14, this.m14)) return false;
    if (!Comparer.equals(other.m24, this.m24)) return false;
    if (!Comparer.equals(other.m34, this.m34)) return false;
    if (!Comparer.equals(other.m44, this.m44)) return false;
    return true;
  }

  @override
  int get hashCode =>
      m11.hashCode ^
      m21.hashCode ^
      m31.hashCode ^
      m41.hashCode ^
      m12.hashCode ^
      m22.hashCode ^
      m32.hashCode ^
      m42.hashCode ^
      m13.hashCode ^
      m23.hashCode ^
      m33.hashCode ^
      m43.hashCode ^
      m14.hashCode ^
      m24.hashCode ^
      m34.hashCode ^
      m44.hashCode;

  /// Gets the string for this matrix.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this matrix.
  String format([String indent = "", int fraction = 3, int whole = 0]) {
    final List<String> col1 = formatColumn([this.m11, this.m12, this.m13, this.m14], fraction, whole);
    final List<String> col2 = formatColumn([this.m21, this.m22, this.m23, this.m24], fraction, whole);
    final List<String> col3 = formatColumn([this.m31, this.m32, this.m33, this.m34], fraction, whole);
    final List<String> col4 = formatColumn([this.m41, this.m42, this.m43, this.m44], fraction, whole);
    return '[${col1[0]}, ${col2[0]}, ${col3[0]}, ${col4[0]},\n' +
        '$indent ${col1[1]}, ${col2[1]}, ${col3[1]}, ${col4[1]},\n' +
        '$indent ${col1[2]}, ${col2[2]}, ${col3[2]}, ${col4[2]},\n' +
        '$indent ${col1[3]}, ${col2[3]}, ${col3[3]}, ${col4[3]}]';
  }
}

/// A math structure for defining a plane.
class Plane {
  /// The x component of the vector for the plane's normal.
  final double dx;

  /// The y component of the vector for the plane's normal.
  final double dy;

  /// The z component of the vector for the plane's normal.
  final double dz;

  /// The normal's scalar used as an offset from the origin
  /// along the normal to the surface of the plane.
  final double offset;

  /// Constructs a new [Plane].
  /// The given vector and offset will be normalized.
  factory Plane(double dx, double dy, double dz, [double offset = 0.0]) =>
      Plane.fromVector(Vector3(dx, dy, dz), offset);

  /// Constructs a new [Plane].
  Plane._(this.dx, this.dy, this.dz, this.offset);

  /// Constructs a new [Plane] with the given vector.
  /// The given vector and offset will be normalized.
  factory Plane.fromVector(Vector3 normal, [double offset = 0.0]) {
    final double len = normal.length();
    return Plane._(normal.dx / len, normal.dy / len, normal.dz / len, offset);
  }

  /// Constructs a new [Plane] with the given points on the surface of the plane.
  factory Plane.fromTriangle(Triangle3 tri) {
    final Vector3 normal = tri.normal;
    final Vector3 toA = Vector3.fromPoint3(tri.point1);
    final double offset = normal.dot(toA);
    return Plane._(normal.dx, normal.dy, normal.dz, offset);
  }

  /// Constructs a new [Plane] instance given a list of 4 doubles.
  ///
  /// [values] is a list of doubles are in the order dx, dy, dz, then offset.
  factory Plane.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    return Plane(values[0], values[1], values[2], values[3]);
  }

  /// Gets an list of 4 doubles in the order dx, dy, dz, then offset.
  List<double> toList() => [this.dx, this.dy, this.dz, this.offset];

  /// Gets the value at the zero based index in the order dx, dy, dz, then other.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.dx;
      case 1:
        return this.dy;
      case 2:
        return this.dz;
      case 3:
        return this.offset;
    }
    return 0.0;
  }

  /// Gets the normal vector of this plain.
  Vector3 get normal => Vector3(this.dx, this.dy, this.dz);

  /// Gets the origin of the plain, the closes point on the plain to the nermeric origin.
  Point3 get origin => Point3(this.dx * this.offset, this.dy * this.offset, this.dz * this.offset);

  /// Gets the nearest point on the plain to the given point [pnt].
  Point3 nearestPoint(Point3 pnt) {
    final Vector3 norm = this.normal;
    final Vector3 origin = norm * this.offset;
    return Point3.fromVector3(origin + norm * (this.offset - origin.dot(norm)));
  }

  /// Gets the side of the point on the plain were Right is on the positive normal size (above),
  /// Same is on the plane and Left is on the negative normal size (below).
  Side sideOfPointComponents(double x, double y, double z) {
    final double value = this.dx * x + this.dy * y + this.dz * z;
    if (Comparer.equals(value, 0.0)) return Side.Inside;
    if (value < 0.0) return Side.Right;
    return Side.Left;
  }

  /// Gets the side of the point on the plain were Right is on the positive normal size (above),
  /// Same is on the plane and Left is on the negative normal size (below).
  Side sideOfPoint(Point3 pnt) => this.sideOfPointComponents(pnt.x, pnt.y, pnt.z);

  /// Determines if the given [other] variable is a [Plane] equal to this plane.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Plane) return false;
    if (!Comparer.equals(other.dx, this.dx)) return false;
    if (!Comparer.equals(other.dy, this.dy)) return false;
    if (!Comparer.equals(other.dz, this.dz)) return false;
    if (!Comparer.equals(other.offset, this.offset)) return false;
    return true;
  }

  @override
  int get hashCode => dx.hashCode ^ dy.hashCode ^ dz.hashCode ^ offset.hashCode;

  /// Gets the string for this plane.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this plane.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.dx, fraction, whole) +
      ', ' +
      formatDouble(this.dy, fraction, whole) +
      ', ' +
      formatDouble(this.dz, fraction, whole) +
      ', ' +
      formatDouble(this.offset, fraction, whole) +
      ']';
}

/// A math structure for storing a 2D point.
class Point2 {
  /// Gets a [Point2] at the origin.
  static Point2 get zero => _zeroSingleton ??= Point2(0.0, 0.0);
  static Point2? _zeroSingleton;

  /// The x component of the point.
  final double x;

  /// The y component of the point.
  final double y;

  /// Constructs a new [Point2] instance.
  Point2(this.x, this.y);

  /// Constructs a new [Point2] from a [Vector2].
  factory Point2.fromVector2(Vector2 vec) => Point2(vec.dx, vec.dy);

  /// Constructs a new [Point2] from a [Vector3].
  ///
  /// The dZ component is ignored.
  factory Point2.fromVector3(Vector3 vec) => Point2(vec.dx, vec.dy);

  /// Constructs a new [Point2] from a [Vector4].
  ///
  /// The dZ and dW component is ignored.
  factory Point2.fromVector4(Vector4 vec) => Point2(vec.dx, vec.dy);

  /// Constructs a new [Point2] from a [Point3].
  ///
  /// The Z component is ignored.
  factory Point2.fromPoint3(Point3 pnt) => Point2(pnt.x, pnt.y);

  /// Constructs a new [Point2] from a [Point4].
  ///
  /// The Z and W components are ignored.
  factory Point2.fromPoint4(Point4 pnt) => Point2(pnt.x, pnt.y);

  /// Constructs a new [Point2] instance given a list of 2 doubles.
  ///
  /// [values] is a list of doubles are in the order x then y.
  factory Point2.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 2);
    return Point2(values[0], values[1]);
  }

  /// Gets an list of 2 doubles in the order x then y.
  List<double> toList() => [this.x, this.y];

  /// Gets the value at the zero based index in the order x then y.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x;
      case 1:
        return this.y;
    }
    return 0.0;
  }

  /// The distance squared between this point and the [other] point.
  double distance2(Point2 other) {
    final double dx = this.x - other.x;
    final double dy = this.y - other.y;
    return (dx * dx) + (dy * dy);
  }

  /// The distance between this point and the [other] point.
  ///
  /// [distance2] is faster since it does not take the square root,
  /// therefore it should be used instead of [distance] where possible.
  double distance(Point2 other) => math.sqrt(this.distance2(other));

  /// Creates the linear interpolation between this point and the [other] point.
  ///
  /// The [i] is interpolation factor. 0.0 or less will return this point.
  /// 1.0 or more will return the [other] point. Between 0.0 and 1.0 will be
  /// a scaled mixture of the two points.
  Point2 lerp(Point2 other, double i) => Point2(lerpVal(this.x, other.x, i), lerpVal(this.y, other.y, i));

  /// Gets the vector from this point to the [other] point.
  Vector2 vectorTo(Point2 other) => Vector2(other.x - this.x, other.y - this.y);

  /// Creates a new point as the sum of this point and the [other] point.
  Point2 operator +(Point2 other) => Point2(this.x + other.x, this.y + other.y);

  /// Creates a new point as the difference of this point and the [other] point.
  Point2 operator -(Point2 other) => Point2(this.x - other.x, this.y - other.y);

  /// Creates the negation of this point.
  Point2 operator -() => Point2(-this.x, -this.y);

  /// Creates a new point scaled by the given [scalar].
  Point2 operator *(double scalar) => Point2(this.x * scalar, this.y * scalar);

  /// Creates a new point inversely scaled by the given [scalar].
  Point2 operator /(double scalar) {
    if (Comparer.equals(scalar, 0.0)) return Point2.zero;
    return Point2(this.x / scalar, this.y / scalar);
  }

  /// Determines if the given [other] variable is a [Point2] equal to this point.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Point2) return false;
    if (!Comparer.equals(other.x, this.x)) return false;
    if (!Comparer.equals(other.y, this.y)) return false;
    return true;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  /// Gets the string for this point.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this point.
  String format([int fraction = 3, int whole = 0]) =>
      '[' + formatDouble(this.x, fraction, whole) + ', ' + formatDouble(this.y, fraction, whole) + ']';
}

/// A math structure for storing a 3D point.
class Point3 {
  /// Gets a [Point3] at the origin.
  static Point3 get zero => _zeroSingleton ??= Point3(0.0, 0.0, 0.0);
  static Point3? _zeroSingleton;

  /// The x component of the point.
  final double x;

  /// The y component of the point.
  final double y;

  /// The z component of the point.
  final double z;

  /// Constructs a new [Point3] instance.
  Point3(this.x, this.y, this.z);

  /// Constructs a new [Point3] from a [Vector2].
  ///
  /// The Z component is defaulted to 0.0.
  factory Point3.fromVector2(Vector2 vec, [double z = 0.0]) => Point3(vec.dx, vec.dy, z);

  /// Constructs a new [Point3] from a [Vector3].
  factory Point3.fromVector3(Vector3 vec) => Point3(vec.dx, vec.dy, vec.dz);

  /// Constructs a new [Point3] from a [Vector4].
  ///
  /// The W component is ignored.
  factory Point3.fromVector4(Vector4 vec) => Point3(vec.dx, vec.dy, vec.dz);

  /// Constructs a new [Point3] from a [Point2].
  ///
  /// The Z component is defaulted to 0.0.
  factory Point3.fromPoint2(Point2 pnt, [double z = 0.0]) => Point3(pnt.x, pnt.y, z);

  /// Constructs a new [Point3] from a [Point4].
  ///
  /// The W component from [pnt] is ignored.
  factory Point3.fromPoint4(Point4 pnt) => Point3(pnt.x, pnt.y, pnt.z);

  /// Constructs a new [Point3] instance given a list of 3 doubles.
  ///
  /// [values] is a list of doubles are in the order x, y, then z.
  factory Point3.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 3);
    return Point3(values[0], values[1], values[2]);
  }

  /// Gets an list of 3 doubles in the order x, y, then z.
  List<double> toList() => [this.x, this.y, this.z];

  /// Gets the value at the zero based index in the order x, y, then z.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x;
      case 1:
        return this.y;
      case 2:
        return this.z;
    }
    return 0.0;
  }

  /// The distance squared between this point and the [other] point.
  double distance2(Point3 other) {
    final double dx = this.x - other.x;
    final double dy = this.y - other.y;
    final double dz = this.z - other.z;
    return (dx * dx) + (dy * dy) + (dz * dz);
  }

  /// The distance between this point and the [other] point.
  ///
  /// [distance2] is faster since it does not take the square root,
  /// therefore it should be used instead of [distance] where possible.
  double distance(Point3 other) => math.sqrt(this.distance2(other));

  /// Creates the linear interpolation between this point and the [other] point.
  ///
  /// The [i] is interpolation factor. 0.0 or less will return this point.
  /// 1.0 or more will return the [other] point. Between 0.0 and 1.0 will be
  /// a scaled mixture of the two points.
  Point3 lerp(Point3 other, double i) =>
      Point3(lerpVal(this.x, other.x, i), lerpVal(this.y, other.y, i), lerpVal(this.z, other.z, i));

  /// Gets the vector from this point to the [other] point.
  Vector3 vectorTo(Point3 other) => Vector3(other.x - this.x, other.y - this.y, other.z - this.z);

  /// Gets the point of this point offset with the given vector.
  Point3 offset(Vector3 offset) => Point3(this.x + offset.dx, this.y + offset.dy, this.z + offset.dz);

  /// Creates a new point as the sum of this point and the [other] point.
  Point3 operator +(Point3 other) => Point3(this.x + other.x, this.y + other.y, this.z + other.z);

  /// Creates a new point as the difference of this point and the [other] point.
  Point3 operator -(Point3 other) => Point3(this.x - other.x, this.y - other.y, this.z - other.z);

  /// Creates the negation of this point.
  Point3 operator -() => Point3(-this.x, -this.y, -this.z);

  /// Creates a new point scaled by the given [scalar].
  Point3 operator *(double scalar) => Point3(this.x * scalar, this.y * scalar, this.z * scalar);

  /// Creates a new point inversely scaled by the given [scalar].
  Point3 operator /(double scalar) {
    if (Comparer.equals(scalar, 0.0)) return Point3.zero;
    return Point3(this.x / scalar, this.y / scalar, this.z / scalar);
  }

  /// Determines if the given [other] variable is a [Point3] equal to this point.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Point3) return false;
    if (!Comparer.equals(other.x, this.x)) return false;
    if (!Comparer.equals(other.y, this.y)) return false;
    if (!Comparer.equals(other.z, this.z)) return false;
    return true;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;

  /// Gets the string for this point.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this point.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.x, fraction, whole) +
      ', ' +
      formatDouble(this.y, fraction, whole) +
      ', ' +
      formatDouble(this.z, fraction, whole) +
      ']';
}

/// A math structure for storing a 4D point.
class Point4 {
  /// Gets a [Point4] at the origin.
  static Point4 get zero => _zeroSingleton ??= Point4(0.0, 0.0, 0.0, 0.0);
  static Point4? _zeroSingleton;

  /// The x component of the point.
  final double x;

  /// The y component of the point.
  final double y;

  /// The z component of the point.
  final double z;

  /// The w component of the point.
  final double w;

  /// Constructs a new [Point4] instance.
  Point4(this.x, this.y, this.z, this.w);

  /// Constructs a new [Point4] from a [Vector2].
  ///
  /// The Z and W components are defaulted to 0.0.
  factory Point4.fromVector2(Vector2 vec, [double z = 0.0, double w = 0.0]) => Point4(vec.dx, vec.dy, z, w);

  /// Constructs a new [Point4] from a [Vector3].
  ///
  /// The W component is defaulted to 0.0.
  factory Point4.fromVector3(Vector3 vec, [double w = 0.0]) => Point4(vec.dx, vec.dy, vec.dz, w);

  /// Constructs a new [Point4] from a [Vector4].
  factory Point4.fromVector4(Vector4 vec) => Point4(vec.dx, vec.dy, vec.dz, vec.dw);

  /// Constructs a new [Point4] from a [Point2].
  ///
  /// The Z and W components are defaulted to 0.0.
  factory Point4.fromPoint2(Point2 pnt, [double z = 0.0, double w = 0.0]) => Point4(pnt.x, pnt.y, z, w);

  /// Constructs a new [Point4] from a [Point3].
  ///
  /// The W component is defaulted to 0.0.
  factory Point4.fromPoint3(Point3 pnt, [double w = 0.0]) => Point4(pnt.x, pnt.y, pnt.z, w);

  /// Constructs a new [Point3] instance given a list of 3 doubles.
  ///
  /// [values] is a list of doubles are in the order x, y, z, then w.
  factory Point4.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    return Point4(values[0], values[1], values[2], values[3]);
  }

  /// Gets an list of 3 doubles in the order x, y, z, then w.
  List<double> toList() => [this.x, this.y, this.z, this.w];

  /// Gets the value at the zero based index in the order x, y, z, then w.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x;
      case 1:
        return this.y;
      case 2:
        return this.z;
      case 3:
        return this.w;
    }
    return 0.0;
  }

  /// The distance squared between this point and the [other] point.
  double distance2(Point4 other) {
    final double dx = this.x - other.x;
    final double dy = this.y - other.y;
    final double dz = this.z - other.z;
    final double dw = this.w - other.w;
    return (dx * dx) + (dy * dy) + (dz * dz) + (dw * dw);
  }

  /// The distance between this point and the [other] point.
  ///
  /// [distance2] is faster since it does not take the square root,
  /// therefore it should be used instead of [distance] where possible.
  double distance(Point4 other) => math.sqrt(this.distance2(other));

  /// Creates the linear interpolation between this point and the [other] point.
  ///
  /// The [i] is interpolation factor. 0.0 or less will return this point.
  /// 1.0 or more will return the [other] point. Between 0.0 and 1.0 will be
  /// a scaled mixture of the two points.
  Point4 lerp(Point4 other, double i) => Point4(lerpVal(this.x, other.x, i), lerpVal(this.y, other.y, i),
      lerpVal(this.z, other.z, i), lerpVal(this.w, other.w, i));

  /// Creates a new point as the sum of this point and the [other] point.
  Point4 operator +(Point4 other) => Point4(this.x + other.x, this.y + other.y, this.z + other.z, this.w + other.w);

  /// Creates a new point as the difference of this point and the [other] point.
  Point4 operator -(Point4 other) => Point4(this.x - other.x, this.y - other.y, this.z - other.z, this.w - other.w);

  /// Creates the negation of this point.
  Point4 operator -() => Point4(-this.x, -this.y, -this.z, -this.w);

  /// Creates a new point scaled by the given [scalar].
  Point4 operator *(double scalar) => Point4(this.x * scalar, this.y * scalar, this.z * scalar, this.w * scalar);

  /// Creates a new point inversely scaled by the given [scalar].
  Point4 operator /(double scalar) {
    if (Comparer.equals(scalar, 0.0)) return Point4.zero;
    return Point4(this.x / scalar, this.y / scalar, this.z / scalar, this.w / scalar);
  }

  /// Determines if the given [other] variable is a [Point4] equal to this point.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Point4) return false;
    if (!Comparer.equals(other.x, this.x)) return false;
    if (!Comparer.equals(other.y, this.y)) return false;
    if (!Comparer.equals(other.z, this.z)) return false;
    if (!Comparer.equals(other.w, this.w)) return false;
    return true;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode ^ w.hashCode;

  /// Gets the string for this point.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this point.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.x, fraction, whole) +
      ', ' +
      formatDouble(this.y, fraction, whole) +
      ', ' +
      formatDouble(this.z, fraction, whole) +
      ', ' +
      formatDouble(this.w, fraction, whole) +
      ']';
}

/// A math structure for storing a quaternion.
class Quaternion {
  /// Gets a [Quaternion] at the origin.
  static Quaternion get zero => _zeroSingleton ??= Quaternion(0.0, 0.0, 0.0, 0.0);
  static Quaternion? _zeroSingleton;

  /// The imaginary 'i' scalar of the quaternion.
  final double a;

  /// The imaginary 'j' scalar of the quaternion.
  final double b;

  /// The imaginary 'k' scalar of the quaternion.
  final double c;

  /// The real axis scalar of the quaternion.
  final double t;

  /// Constructs a new [Quaternion] instance.
  ///
  /// [a], [b], and [c] are the scalars on the imaginary 'i', 'j', and 'k' axii respectively.
  /// [t] is the scalar on the real axis.
  Quaternion(this.a, this.b, this.c, this.t);

  /// Constructs a scaled quaternion of the given [quat] scaled by the given [scalar].
  factory Quaternion.scale(Quaternion quat, double scalar) =>
      Quaternion(quat.a * scalar, quat.b * scalar, quat.c * scalar, quat.t * scalar);

  /// Constructs a quaternion from the given 3x3 matrix.
  factory Quaternion.fromMatrix3(Matrix3 mat) {
    final double tr = mat.m11 + mat.m22 + mat.m33;
    if (tr > 0) {
      final double scalar = math.sqrt(tr + 1.0) * 2.0; // 4*q.t
      return Quaternion(
          (mat.m32 - mat.m23) / scalar, (mat.m13 - mat.m31) / scalar, (mat.m21 - mat.m12) / scalar, 0.25 * scalar);
    } else if ((mat.m11 > mat.m22) && (mat.m11 > mat.m33)) {
      final double scalar = math.sqrt(1.0 + mat.m11 - mat.m22 - mat.m33) * 2.0; // 4*q.a
      return Quaternion(
          0.25 * scalar, (mat.m12 + mat.m21) / scalar, (mat.m13 + mat.m31) / scalar, (mat.m32 - mat.m23) / scalar);
    } else if (mat.m22 > mat.m33) {
      final double scalar = math.sqrt(1.0 + mat.m22 - mat.m11 - mat.m33) * 2.0; // 4*q.b
      return Quaternion(
          (mat.m12 + mat.m21) / scalar, 0.25 * scalar, (mat.m23 + mat.m32) / scalar, (mat.m13 - mat.m31) / scalar);
    } else {
      final double scalar = math.sqrt(1.0 + mat.m33 - mat.m11 - mat.m22) * 2.0; // 4*q.c
      return Quaternion(
          (mat.m13 + mat.m31) / scalar, (mat.m23 + mat.m32) / scalar, 0.25 * scalar, (mat.m21 - mat.m12) / scalar);
    }
  }

  /// Constructs a new [Quaternion] instance given a list of 4 doubles.
  ///
  /// [values] is a list of doubles are in the order a, b, c, then t.
  factory Quaternion.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    return Quaternion(values[0], values[1], values[2], values[3]);
  }

  /// Gets a list of 4 doubles in the order a, b, c, then t.
  List<double> toList() => [this.a, this.b, this.c, this.t];

  /// Gets the value at the zero based index in the order a, b, c, then t.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.a;
      case 1:
        return this.b;
      case 2:
        return this.c;
      case 3:
        return this.t;
    }
    return 0.0;
  }

  /// The length squared of this quaternion.
  double length2() => this.a * this.a + this.b * this.b + this.c * this.c + this.t * this.t;

  /// The length of this quaternion.
  ///
  /// [length2] is faster since it does not take the square root,
  /// therefore it should be used instead of [length] where possible.
  double length() => math.sqrt(this.length2());

  /// Calculates the W component of this quaternion.
  Quaternion calculateW() {
    double t2 = 1.0 - this.a * this.a - this.b * this.b - this.c * this.c;
    if (t2 < 0.0) t2 = -t2;
    final double t = -math.sqrt(t2);
    return Quaternion(this.a, this.b, this.c, t);
  }

  /// Gets the inverse of the quaternion.
  Quaternion inverse() => Quaternion(-this.a, -this.b, -this.c, this.t);

  /// Gets normalized quaternion of this quaternion.
  Quaternion normal() {
    final double length = this.length();
    if (Comparer.equals(length, 0.0)) return Quaternion.zero;
    return Quaternion.scale(this, 1.0 / length);
  }

  /// Gets a linear interpolation between this quaternion and the [other] quaternion.
  ///
  /// The [i] is interpolation factor. 0.0 or less will return this quaternion.
  /// 1.0 or more will return the [other] quaternion. Between 0.0 and 1.0 will be
  /// a scaled mixture of the two quaternions.
  Quaternion slerp(Quaternion other, double i) {
    double d = i;
    final double dot = this.a * other.a + this.b * other.b + this.c * other.c + this.t * other.t;
    if (dot < 0.0) d = -1.0 * i;
    return Quaternion(1.0 - i * this.a + d * other.a, 1.0 - i * this.b + d * other.b, 1.0 - i * this.c + d * other.c,
        1.0 - i * this.t + d * other.t);
  }

  /// Gets the product of this quaternion and the given [other] quaternion.
  Quaternion operator *(Quaternion other) => Quaternion(
      this.a * other.t + this.t * other.a + this.b * other.c - this.c * other.b,
      this.b * other.t + this.t * other.b + this.c * other.a - this.a * other.c,
      this.c * other.t + this.t * other.c + this.a * other.b - this.b * other.a,
      this.t * other.t - this.a * other.a - this.b * other.b - this.c * other.c);

  /// Transforms the given [vec] with this quaternion.
  Vector3 trans(Vector3 vec) {
    final c = this.c * vec.dx + this.a * vec.dz - this.b * vec.dy,
        d = this.c * vec.dy + this.b * vec.dx - this.t * vec.dz,
        e = this.c * vec.dz + this.t * vec.dy - this.a * vec.dx,
        f = -this.t * vec.dx - this.a * vec.dy - this.b * vec.dz;
    return Vector3(c * this.c - d * this.b + e * this.a - f * this.t, c * this.b + d * this.c - e * this.t - f * this.a,
        -c * this.a + d * this.t + e * this.c - f * this.b);
  }

  /// Determines if the given [other] variable is a [Quaternion] equal to this point.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Quaternion) return false;
    if (!Comparer.equals(other.a, this.a)) return false;
    if (!Comparer.equals(other.b, this.b)) return false;
    if (!Comparer.equals(other.c, this.c)) return false;
    if (!Comparer.equals(other.t, this.t)) return false;
    return true;
  }

  @override
  int get hashCode => a.hashCode ^ b.hashCode ^ c.hashCode ^ t.hashCode;

  /// Gets the string for this quaternion.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this quaternion.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.a, fraction, whole) +
      'i + ' +
      formatDouble(this.b, fraction, whole) +
      'j + ' +
      formatDouble(this.c, fraction, whole) +
      'k + ' +
      formatDouble(this.t, fraction, whole) +
      ']';
}

/// A 2D ray is a vector with a starting point.
class Ray2 {
  /// Gets a [Ray2] at the origin with no vector.
  static Ray2 get zero => _zeroSingleton ??= Ray2(0.0, 0.0, 0.0, 0.0);
  static Ray2? _zeroSingleton;

  /// The x component of the ray.
  final double x;

  /// The y component of the ray.
  final double y;

  /// The delta X component of the ray.
  final double dx;

  /// The delta Y component of the ray.
  final double dy;

  /// Constructs a new [Ray2].
  Ray2(this.x, this.y, this.dx, this.dy);

  /// Constructs a new [Ray2] with the given point and vector.
  factory Ray2.fromVector(Point2 pnt, Vector2 vec) => Ray2(pnt.x, pnt.y, vec.dx, vec.dy);

  /// Constructs a new [Ray2] with the two given points.
  factory Ray2.fromPoints(Point2 a, Point2 b) => Ray2(a.x, a.y, b.x - a.x, b.y - a.y);

  /// Constructs a new [Ray2] by using only the x and y components of a [Ray3].
  factory Ray2.fromRay3(Ray3 a) => Ray2(a.x, a.y, a.dx, a.dy);

  /// Constructs a new [Ray2] instance given a list of 4 doubles.
  ///
  /// [values] is a list of doubles are in the order x, y, dx, then dy.
  factory Ray2.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    return Ray2(values[0], values[1], values[2], values[3]);
  }

  /// Gets the point at the start of this ray.
  Point2 get start => Point2(this.x, this.y);

  /// Gets the point at the end of this ray.
  Point2 get end => Point2(this.x + this.dx, this.y + this.dy);

  /// Gets the vector of this ray.
  Vector2 get vector => Vector2(this.dx, this.dy);

  /// Gets an list of 4 doubles in the order x, y, dx, then dy.
  List<double> toList() => [this.x, this.y, this.dx, this.dy];

  /// Gets the value at the zero based index in the order x, y, dx, then dy.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x;
      case 1:
        return this.y;
      case 2:
        return this.dx;
      case 3:
        return this.dy;
    }
    return 0.0;
  }

  /// Determines if the given [other] variable is a [Ray2] equal to this ray.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Ray2) return false;
    if (!Comparer.equals(other.x, this.x)) return false;
    if (!Comparer.equals(other.y, this.y)) return false;
    if (!Comparer.equals(other.dx, this.dx)) return false;
    if (!Comparer.equals(other.dy, this.dy)) return false;
    return true;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ dx.hashCode ^ dy.hashCode;

  /// Gets the string for this ray.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this ray.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.x, fraction, whole) +
      ', ' +
      formatDouble(this.y, fraction, whole) +
      ', ' +
      formatDouble(this.dx, fraction, whole) +
      ', ' +
      formatDouble(this.dy, fraction, whole) +
      ']';
}

/// A 3D ray is a vector with a starting point.
class Ray3 {
  /// Gets a [Ray3] at the origin with no vector.
  static Ray3 get zero => _zeroSingleton ??= Ray3(0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
  static Ray3? _zeroSingleton;

  /// The x component of the ray.
  final double x;

  /// The y component of the ray.
  final double y;

  /// The z component of the ray.
  final double z;

  /// The delta X component of the ray.
  final double dx;

  /// The delta Y component of the ray.
  final double dy;

  /// The delta Z component of the ray.
  final double dz;

  /// Constructs a new [Ray3].
  Ray3(this.x, this.y, this.z, this.dx, this.dy, this.dz);

  /// Constructs a new [Ray3] with the given point and vector.
  factory Ray3.fromVector(Point3 pnt, Vector3 vec) => Ray3(pnt.x, pnt.y, pnt.z, vec.dx, vec.dy, vec.dz);

  /// Constructs a new [Ray3] with the two given points.
  factory Ray3.fromPoints(Point3 a, Point3 b) => Ray3(a.x, a.y, a.z, b.x - a.x, b.y - a.y, b.z - a.z);

  /// Constructs a new [Ray3] from a [Ray2] with the optional z components.
  factory Ray3.fromRay3(Ray2 a, [double z = 0.0, double dz = 0.0]) => Ray3(a.x, a.y, z, a.dx, a.dy, dz);

  /// Constructs a new [Ray3] instance given a list of 6 doubles.
  ///
  /// [values] is a list of doubles are in the order x, y, z, dx, dy, then dz.
  factory Ray3.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 6);
    return Ray3(values[0], values[1], values[2], values[3], values[4], values[5]);
  }

  /// Gets an list of 6 doubles in the order x, y, z, dx, dy, then dz.
  List<double> toList() => [this.x, this.y, this.z, this.dx, this.dy, this.dz];

  /// Gets the value at the zero based index in the order x, y, z, dx, dy, then dz.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x;
      case 1:
        return this.y;
      case 2:
        return this.z;
      case 3:
        return this.dx;
      case 4:
        return this.dy;
      case 5:
        return this.dz;
    }
    return 0.0;
  }

  /// Gets the point at the start of this ray.
  Point3 get start => Point3(this.x, this.y, this.z);

  /// Gets the point at the end of this ray.
  Point3 get end => Point3(this.x + this.dx, this.y + this.dy, this.z + this.dz);

  /// Gets the vector of this ray.
  Vector3 get vector => Vector3(this.dx, this.dy, this.dz);

  /// Creates a ray heading from the tip of this ray backwards to the origin.
  Ray3 get reverse => Ray3.fromVector(this.end, -this.vector);

  /// Determines if the given [other] variable is a [Ray3] equal to this ray.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is Ray3 &&
          Comparer.equals(other.x, this.x) &&
          Comparer.equals(other.y, this.y) &&
          Comparer.equals(other.z, this.z) &&
          Comparer.equals(other.dx, this.dx) &&
          Comparer.equals(other.dy, this.dy) &&
          Comparer.equals(other.dz, this.dz);

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode ^ dx.hashCode ^ dy.hashCode ^ dz.hashCode;

  /// Gets the string for this ray.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this ray.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.x, fraction, whole) +
      ', ' +
      formatDouble(this.y, fraction, whole) +
      ', ' +
      formatDouble(this.z, fraction, whole) +
      ', ' +
      formatDouble(this.dx, fraction, whole) +
      ', ' +
      formatDouble(this.dy, fraction, whole) +
      ', ' +
      formatDouble(this.dz, fraction, whole) +
      ']';
}

/// A math structure for storing a 2D region, like a rectangle.
/// This is also used for AABBs (axial aligned bounding boxes).
class Region2 {
  /// Gets a [Region2] at the origin.
  static Region2 get zero => _zeroSingleton ??= Region2(0.0, 0.0, 0.0, 0.0);
  static Region2? _zeroSingleton;

  /// Gets a [Region2] at the origin with a width and height of 1.
  static Region2 get unit => _unitSingleton ??= Region2(0.0, 0.0, 1.0, 1.0);
  static Region2? _unitSingleton;

  /// Gets a [Region2] at the origin with a width and height of 2 centered on origin.
  static Region2 get unit2 => _unit2Singleton ??= Region2(-1.0, -1.0, 2.0, 2.0);
  static Region2? _unit2Singleton;

  /// Constructs the union of the given regions. If both are null, null is returned.
  static Region2? union(Region2? a, Region2? b) {
    if (a == null) return b;
    if (b == null) return a;
    final double x = math.min(a.x, b.x);
    final double y = math.min(a.y, b.y);
    final double x2 = math.max(a.x + a.dx, b.x + b.dx);
    final double y2 = math.max(a.y + a.dy, b.y + b.dy);
    return Region2._(x, y, x2 - x, y2 - y);
  }

  /// The left edge component of the region.
  final double x;

  /// The top edge component of the region.
  final double y;

  /// The width component of the region.
  final double dx;

  /// The height component of the region.
  final double dy;

  /// Constructs a new [Region2] instance.
  factory Region2(double x, double y, double dx, double dy) {
    if (dx < 0.0) {
      x = x + dx;
      dx = -dx;
    }
    if (dy < 0.0) {
      y = y + dy;
      dy = -dy;
    }
    return Region2._(x, y, dx, dy);
  }

  /// Constructs a new [Region2] instance.
  Region2._(this.x, this.y, this.dx, this.dy);

  /// Constructs a new [Region2] at the given point, [pnt].
  factory Region2.fromPoint(Point2 pnt, [double dx = 0.0, double dy = 0.0]) => Region2(pnt.x, pnt.y, dx, dy);

  /// Constructs a new [Region2] from two opposite corners.
  factory Region2.fromCorners(Point2 a, Point2 b) => Region2(a.x, a.y, b.x - a.x, b.y - a.y);

  /// Constructs a new [Region2] at the given ray.
  factory Region2.fromRay(Ray2 ray) => Region2(ray.x, ray.y, ray.dx, ray.dy);

  /// Constructs a new [Region2] instance given a list of 4 doubles.
  /// [values] is a list of doubles are in the order x, y, dx, then dy.
  factory Region2.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    return Region2(values[0], values[1], values[2], values[3]);
  }

  /// The minimum corner point in the region.
  Point2 get minCorner => Point2(this.x, this.y);

  /// The maximum corner point in the region.
  Point2 get maxCorner => Point2(this.x + this.dx, this.y + this.dy);

  /// The center point of the region.
  Point2 get center => Point2(this.x + this.dx / 2.0, this.y + this.dy / 2.0);

  /// Expands the region to include the given point, [pnt].
  Region2 expandWithPoint(Point2 pnt) => this.expand(pnt.x, pnt.y);

  /// Expands the region to include the given location components.
  Region2 expand(double x, double y) {
    double dx = this.dx;
    if (x < this.x) {
      dx = this.dx + (this.x - x);
    } else {
      if (x > this.x + this.dx) dx = x - this.x;
      // ignore: parameter_assignments
      x = this.x;
    }
    double dy = this.dy;
    if (y < this.y) {
      dy = this.dy + (this.y - y);
    } else {
      if (y > this.y + this.dy) dy = y - this.y;
      // ignore: parameter_assignments
      y = this.y;
    }
    return Region2._(x, y, dx, dy);
  }

  /// Expands the region to include the given region components.
  Region2 expandWithRegion(Region2 region) {
    final double x1 = math.min(this.x, region.x);
    final double x2 = math.max(this.x + this.dx, region.x + region.dx);
    final double y1 = math.min(this.y, region.y);
    final double y2 = math.max(this.y + this.dy, region.y + region.dy);
    return Region2._(x1, y1, x2 - x1, y2 - y1);
  }

  /// Gets an list of 4 doubles in the order x, y, dx, then dy.
  List<double> toList() => [this.x, this.y, this.dx, this.dy];

  /// Gets the value at the zero based index in the order x, y, dx, then dy.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x;
      case 1:
        return this.y;
      case 2:
        return this.dx;
      case 3:
        return this.dy;
    }
    return 0.0;
  }

  /// The minimum side of the region.
  double get minSide {
    if (this.dx > this.dy) {
      return this.dy;
    } else {
      return this.dx;
    }
  }

  /// The maximum side of the region.
  double get maxSide {
    if (this.dx > this.dy) {
      return this.dx;
    } else {
      return this.dy;
    }
  }

  /// Indicates if the region is a square, ie has equal dx and dy.
  bool get isSquare => Comparer.equals(this.dx, this.dy);

  /// Gets the adjusted point of the given [raw] point.
  /// This point is normalized into the region.
  Point2 adjustPoint(Point2 raw) {
    final double width = this.dx * 0.5;
    final double height = this.dy * 0.5;
    final double x = raw.x - this.x - width;
    final double y = raw.y - this.y - height;
    return Point2(x, y) * 2.0 / this.minSide;
  }

  /// Gets the adjusted vector of the given [raw] vector.
  /// This vector is normalized into the region.
  Vector2 adjustVector(Vector2 raw) => raw * 2.0 / this.minSide;

  /// Determines the location the given point is in relation to the region.
  HitRegion hit(Point2 a) {
    HitRegion region = HitRegion.None;

    if (a.x < this.x) {
      region |= HitRegion.XNeg;
    } else if (a.x >= this.x + this.dx) {
      region |= HitRegion.XPos;
    } else {
      region |= HitRegion.XCenter;
    }

    if (a.y < this.y) {
      region |= HitRegion.YNeg;
    } else if (a.y >= this.y + this.dy) {
      region |= HitRegion.YPos;
    } else {
      region |= HitRegion.YCenter;
    }

    return region;
  }

  /// nearestPoint finds the closest point in or on the edge of this region to the given point.
  Point2 nearestPoint(Point2 a) {
    final HitRegion reg = this.hit(a);
    final double x;
    if (reg.has(HitRegion.XNeg)) {
      x = this.x;
    } else {
      if (reg.has(HitRegion.XPos)) {
        x = this.x + this.dx;
      } else {
        x = a.x;
      }
    }
    final double y;
    if (reg.has(HitRegion.YNeg)) {
      y = this.y;
    } else {
      if (reg.has(HitRegion.YPos)) {
        y = this.y + this.dy;
      } else {
        y = a.y;
      }
    }
    return Point2(x, y);
  }

  /// Determines if the given point is contained inside this region.
  bool contains(Point2 a) => inRange(a.x, this.x, this.x + this.dx) && inRange(a.y, this.y, this.y + this.dy);

  /// Determines if the two regions overlap even partially.
  bool overlaps(Region2 a) =>
      rangeOverlap(a.x, a.x + a.dx, this.x, this.x + this.dx) &&
      rangeOverlap(a.y, a.y + a.dy, this.y, this.y + this.dy);

  /// Creates a new [Region2] as a translation of the other given region.
  Region2 translate(Vector2 offset) => Region2(this.x + offset.dx, this.y + offset.dy, this.dx, this.dy);

  /// Determines if the given [other] variable is a [Region2] equal to this region.
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Region2) return false;
    if (!Comparer.equals(other.x, this.x)) return false;
    if (!Comparer.equals(other.y, this.y)) return false;
    if (!Comparer.equals(other.dx, this.dx)) return false;
    if (!Comparer.equals(other.dy, this.dy)) return false;
    return true;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ dx.hashCode ^ dy.hashCode;

  /// Gets the string for this region.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this region.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.x, fraction, whole) +
      ', ' +
      formatDouble(this.y, fraction, whole) +
      ', ' +
      formatDouble(this.dx, fraction, whole) +
      ', ' +
      formatDouble(this.dy, fraction, whole) +
      ']';
}

/// A math structure for storing a 3D region, like a rectangular cube.
/// This is also used for AABBs (axial aligned bounding boxes).
class Region3 {
  /// Gets a [Region3] at the origin.
  static Region3 get zero => _zeroSingleton ??= Region3(0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
  static Region3? _zeroSingleton;

  /// Gets a [Region3] at the origin with a width, height, and depth of 1.
  static Region3 get unit => _unitSingleton ??= Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
  static Region3? _unitSingleton;

  /// Gets a [Region3] at the origin with a width, height, and depth of 2 centered on origin.
  static Region3 get unit2 => _unit2Singleton ??= Region3(-1.0, -1.0, -1.0, 2.0, 2.0, 2.0);
  static Region3? _unit2Singleton;

  /// Constructs the union of the given regions. If both are null, null is returned.
  static Region3? union(Region3? a, Region3? b) {
    if (a == null) return b ?? zero;
    if (b == null) return a;
    final double x = math.min(a.x, b.x);
    final double y = math.min(a.y, b.y);
    final double z = math.min(a.z, b.z);
    final double x2 = math.max(a.x + a.dx, b.x + b.dx);
    final double y2 = math.max(a.y + a.dy, b.y + b.dy);
    final double z2 = math.max(a.z + a.dz, b.z + b.dz);
    return Region3._(x, y, z, x2 - x, y2 - y, z2 - z);
  }

  /// The left edge component of the region.
  final double x;

  /// The top edge component of the region.
  final double y;

  /// The front edge component of the region.
  final double z;

  /// The width component of the region.
  final double dx;

  /// The height component of the region.
  final double dy;

  /// The depth component of the region.
  final double dz;

  /// Constructs a new [Region3] instance.
  factory Region3(double x, double y, double z, double dx, double dy, double dz) {
    if (dx < 0.0) {
      x = x + dx;
      dx = -dx;
    }
    if (dy < 0.0) {
      y = y + dy;
      dy = -dy;
    }
    if (dz < 0.0) {
      z = z + dz;
      dz = -dz;
    }
    return Region3._(x, y, z, dx, dy, dz);
  }

  /// Constructs a new [Region3] instance.
  Region3._(this.x, this.y, this.z, this.dx, this.dy, this.dz);

  /// Constructs a new [Region3] at the given point, [pnt].
  factory Region3.fromPoint(Point3 pnt, [double dx = 0.0, double dy = 0.0, double dz = 0.0]) =>
      Region3(pnt.x, pnt.y, pnt.z, dx, dy, dz);

  /// Constructs a new [Region3] from two opposite corners.
  factory Region3.fromCorners(Point3 a, Point3 b) => Region3(a.x, a.y, a.z, b.x - a.x, b.y - a.y, b.z - a.z);

  /// Constructs a new [Region3] from the given [Cube].
  factory Region3.fromCube(Cube cube) => Region3(cube.x, cube.y, cube.z, cube.size, cube.size, cube.size);

  /// Constructs a new [Region3] at the given ray.
  factory Region3.fromRay(Ray3 ray) => Region3(ray.x, ray.y, ray.z, ray.dx, ray.dy, ray.dz);

  /// Constructs a new [Region3] instance given a list of 6 doubles.
  ///
  /// [values] is a list of doubles are in the order x, y, z, dx, dy, then dz.
  factory Region3.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 6);
    return Region3(values[0], values[1], values[2], values[3], values[4], values[5]);
  }

  /// The minimum corner point in the region.
  Point3 get minCorner => Point3(this.x, this.y, this.z);

  /// The maximum corner point in the region.
  Point3 get maxCorner => Point3(this.x + this.dx, this.y + this.dy, this.z + this.dz);

  /// The center point of the region.
  Point3 get center => Point3(this.x + this.dx / 2.0, this.y + this.dy / 2.0, this.z + this.dz / 2.0);

  /// Expands the region to include the given point, [pnt].
  Region3 expandWithPoint(Point3? pnt) {
    if (pnt == null) {
      return this;
    } else {
      return this.expand(pnt.x, pnt.y, pnt.z);
    }
  }

  /// Expands the region to include the given location components.
  Region3 expand(double x, double y, double z) {
    double dx = this.dx;
    if (x < this.x) {
      dx = this.dx + (this.x - x);
    } else {
      if (x > this.x + this.dx) dx = x - this.x;
      // ignore: parameter_assignments
      x = this.x;
    }
    double dy = this.dy;
    if (y < this.y) {
      dy = this.dy + (this.y - y);
    } else {
      if (y > this.y + this.dy) dy = y - this.y;
      // ignore: parameter_assignments
      y = this.y;
    }
    double dz = this.dz;
    if (z < this.z) {
      dz = this.dz + (this.z - z);
    } else {
      if (z > this.z + this.dz) dz = z - this.z;
      // ignore: parameter_assignments
      z = this.z;
    }
    return Region3._(x, y, z, dx, dy, dz);
  }

  /// Expands the region to include the given region components.
  Region3 expandWithRegion(Region3 region) {
    final double x1 = math.min(this.x, region.x);
    final double x2 = math.max(this.x + this.dx, region.x + region.dx);
    final double y1 = math.min(this.y, region.y);
    final double y2 = math.max(this.y + this.dy, region.y + region.dy);
    final double z1 = math.min(this.z, region.z);
    final double z2 = math.max(this.z + this.dz, region.z + region.dz);
    return Region3._(x1, y1, z1, x2 - x1, y2 - y1, z2 - z1);
  }

  /// Gets an list of 6 doubles in the order x, y, z, dx, dy, then dz.
  List<double> toList() => [this.x, this.y, this.z, this.dx, this.dy, this.dz];

  /// Gets the value at the zero based index in the order x, y, z, dx, dy, then dz.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x;
      case 1:
        return this.y;
      case 2:
        return this.z;
      case 3:
        return this.dx;
      case 4:
        return this.dy;
      case 5:
        return this.dz;
    }
    return 0.0;
  }

  /// The minimum side of the region.
  double get minSide {
    double side = this.dx;
    if (side > this.dy) side = this.dy;
    if (side > this.dz) side = this.dz;
    return side;
  }

  /// The maximum side of the region.
  double get maxSide {
    double side = this.dx;
    if (side < this.dy) side = this.dy;
    if (side < this.dz) side = this.dz;
    return side;
  }

  /// Indicates if the region is a cube, ie has equal dx, dy, and dz.
  bool get isCube => Comparer.equals(this.dx, this.dy) && Comparer.equals(this.dx, this.dz);

  /// Gets the adjusted point of the given [raw] point.
  /// This point is normalized into the region.
  Point3 adjustPoint(Point3 raw) {
    final double width = this.dx * 0.5;
    final double height = this.dy * 0.5;
    final double depth = this.dz * 0.5;
    final double x = raw.x - this.x - width;
    final double y = raw.y - this.y - height;
    final double z = raw.z - this.z - depth;
    return Point3(x, y, z) * 2.0 / this.minSide;
  }

  /// Gets the adjusted vector of the given [raw] vector.
  /// This vector is normalized into the region.
  Vector3 adjustVector(Vector3 raw) => raw * 2.0 / this.minSide;

  /// Determines the location the given point is in relation to the region.
  HitRegion hit(Point3 a) {
    HitRegion region = HitRegion.None;

    if (a.x < this.x) {
      region |= HitRegion.XNeg;
    } else if (a.x >= this.x + this.dx) {
      region |= HitRegion.XPos;
    } else {
      region |= HitRegion.XCenter;
    }

    if (a.y < this.y) {
      region |= HitRegion.YNeg;
    } else if (a.y >= this.y + this.dy) {
      region |= HitRegion.YPos;
    } else {
      region |= HitRegion.YCenter;
    }

    if (a.z < this.z) {
      region |= HitRegion.ZNeg;
    } else if (a.z >= this.z + this.dz) {
      region |= HitRegion.ZPos;
    } else {
      region |= HitRegion.ZCenter;
    }

    return region;
  }

  /// Determines if the given point is contained inside this region.
  bool contains(Point3 a) =>
      inRange(a.x, this.x, this.x + this.dx) &&
      inRange(a.y, this.y, this.y + this.dy) &&
      inRange(a.z, this.z, this.z + this.dz);

  /// Determines if the two regions overlap even partially.
  bool overlaps(Region3 a) =>
      rangeOverlap(a.x, a.x + a.dx, this.x, this.x + this.dx) &&
      rangeOverlap(a.y, a.y + a.dy, this.y, this.y + this.dy) &&
      rangeOverlap(a.z, a.z + a.dz, this.z, this.z + this.dz);

  /// Creates a new [Region3] as a translation of the other given region.
  Region3 translate(Vector3 offset) =>
      Region3(this.x + offset.dx, this.y + offset.dy, this.z + offset.dz, this.dx, this.dy, this.dz);

  /// Determines if the given [other] variable is a [Region3] equal to this region.
  ///
  /// The equality of the doubles is tested with the current Comparer method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Region3) return false;
    if (!Comparer.equals(other.x, this.x)) return false;
    if (!Comparer.equals(other.y, this.y)) return false;
    if (!Comparer.equals(other.z, this.z)) return false;
    if (!Comparer.equals(other.dx, this.dx)) return false;
    if (!Comparer.equals(other.dy, this.dy)) return false;
    if (!Comparer.equals(other.dz, this.dz)) return false;
    return true;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode ^ dx.hashCode ^ dy.hashCode ^ dx.hashCode;

  /// Gets the string for this region.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this region.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.x, fraction, whole) +
      ', ' +
      formatDouble(this.y, fraction, whole) +
      ', ' +
      formatDouble(this.z, fraction, whole) +
      ', ' +
      formatDouble(this.dx, fraction, whole) +
      ', ' +
      formatDouble(this.dy, fraction, whole) +
      ', ' +
      formatDouble(this.dz, fraction, whole) +
      ']';
}

/// Side indicates which side of a ray point is on.
enum Side {
  /// Left indicates the point is to the left of the ray
  /// when looking from the start towards the end.
  Left,

  /// Right indicates the point is to the right of the ray
  /// when looking from the start towards the end.
  Right,

  /// Inside indicates the point is on the ray.
  Inside,
}

/// A math structure for defining a sphere.
class Sphere {
  /// The x component of the point for the sphere's center point.
  final double x;

  /// The y component of the point for the sphere's center point.
  final double y;

  /// The z component of the point for the sphere's center point.
  final double z;

  /// The positive radius of the sphere.
  final double radius;

  /// Constructs a new [Sphere].
  factory Sphere(double x, double y, double z, double radius) => Sphere._(x, y, z, radius.abs());

  /// Constructs a new [Sphere].
  Sphere._(this.x, this.y, this.z, this.radius);

  /// Constructs a new [Sphere] with the given center point.
  factory Sphere.fromPoint(Point3 center, double radius) => Sphere(center.x, center.y, center.z, radius);

  /// Constructs a new [Sphere] instance given a list of 4 doubles.
  ///
  /// [values] is a list of doubles are in the order x, y, z, then radius.
  factory Sphere.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    return Sphere(values[0], values[1], values[2], values[3]);
  }

  /// Gets an list of 4 doubles in the order x, y, z, then radius.
  List<double> toList() => [this.x, this.y, this.z, this.radius];

  /// Gets the value at the zero based index in the order x, y, z, then radius.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x;
      case 1:
        return this.y;
      case 2:
        return this.z;
      case 3:
        return this.radius;
    }
    return 0.0;
  }

  /// Gets the center point of this sphere.
  Point3 get center => Point3(this.x, this.y, this.z);

  /// Gets the closest point on the sphere's surface.
  Point3 closestPoint(Point3 pnt) {
    final Point3 center = this.center;
    final Vector3 toPnt = center.vectorTo(pnt);
    final double dist = toPnt.length();
    return center.offset(toPnt * (this.radius / dist));
  }

  /// Determines if the given [other] variable is a [Sphere] equal to this sphere.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is Sphere &&
          Comparer.equals(other.x, this.x) &&
          Comparer.equals(other.y, this.y) &&
          Comparer.equals(other.z, this.z) &&
          Comparer.equals(other.radius, this.radius);

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode ^ radius.hashCode;

  /// Gets the string for this sphere.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this sphere.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.x, fraction, whole) +
      ', ' +
      formatDouble(this.y, fraction, whole) +
      ', ' +
      formatDouble(this.z, fraction, whole) +
      ', ' +
      formatDouble(this.radius, fraction, whole) +
      ']';
}

/// A math structure for storing a 2D triangle.
class Triangle2 {
  /// The x component of the first point.
  final double x1;

  /// The y component of the first point.
  final double y1;

  /// The x component of the second point.
  final double x2;

  /// The y component of the second point.
  final double y2;

  /// The x component of the third point.
  final double x3;

  /// The y component of the third point.
  final double y3;

  /// Constructs a new [Triangle2] instance.
  Triangle2(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);

  /// Constructs a new [Triangle2] with the given points.
  factory Triangle2.fromPoints(Point2 pnt1, Point2 pnt2, Point2 pnt3) =>
      Triangle2(pnt1.x, pnt1.y, pnt2.x, pnt2.y, pnt3.x, pnt3.y);

  /// Constructs a new [Triangle2] with the given [Triangle3] ignoring the z value.
  factory Triangle2.fromTriangle3(Triangle3 tri) => Triangle2(tri.x1, tri.y1, tri.x2, tri.y2, tri.x3, tri.y3);

  /// Constructs a new [Triangle2] instance given a list of 6 doubles.
  ///
  /// [values] is a list of doubles are in the order x then y
  /// for the first, second, and third point.
  factory Triangle2.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 6);
    return Triangle2(values[0], values[1], values[2], values[3], values[4], values[5]);
  }

  /// Gets an list of 6 doubles in the order x then y
  /// for the first, second, and third point.
  List<double> toList() => [this.x1, this.y1, this.x2, this.y2, this.x3, this.y3];

  /// Gets the value at the zero based index in the order x then y
  /// for the first, second, and third point. If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x1;
      case 1:
        return this.y1;
      case 3:
        return this.x2;
      case 4:
        return this.y2;
      case 6:
        return this.x3;
      case 7:
        return this.y3;
    }
    return 0.0;
  }

  /// Gets the first point of the triangle.
  Point2 get point1 => Point2(this.x1, this.y1);

  /// Gets the second point of the triangle.
  Point2 get point2 => Point2(this.x2, this.y2);

  /// Gets the third point of the triangle.
  Point2 get point3 => Point2(this.x3, this.y3);

  /// Get the area of the triangle.
  double get area {
    final Vector2 d1 = Vector2(this.x2 - this.x1, this.y2 - this.y1);
    final Vector2 d2 = Vector2(this.x3 - this.x2, this.y3 - this.y2);
    return d1.cross(d2) * 0.5;
  }

  /// Gets the average point of the triangles points.
  Point2 get centroid => Point2((this.x1 + this.x2 + this.x3) / 3.0, (this.y1 + this.y2 + this.y3) / 3.0);

  /// Convertex from the given barycentric coorinates vector to the cartesian coordinate point.
  Point2 fromBarycentricCoordinates(double x, double y, double z) =>
      Point2(x * this.x1 + y * this.x2 + z * this.x3, x * this.y1 + y * this.y2 + z * this.y3);

  /// Convertex from the given barycentric coorinates vector to the cartesian coordinate point.
  Point2 fromBarycentric(Vector3 vec) => this.fromBarycentricCoordinates(vec.dx, vec.dy, vec.dz);

  /// Convertex from the given cartesian coordinate point to the barycentric coorinates vector.
  /// If the triangle is degenerate (area is zero) then null will be returned.
  Vector3? toBarycentric(Point2 pnt) {
    final double x23 = this.x2 - this.x3;
    final double x31 = this.x3 - this.x1;
    final double y23 = this.y2 - this.y3;
    final double y31 = this.y3 - this.y1;
    final double div = y23 * x31 - y31 * x23;
    if (div == 0.0) {
      // Degenerate triangle
      return null;
    }

    final double x12 = this.x1 - this.x2;
    final double y12 = this.y1 - this.y2;
    return Vector3(
        ((pnt.y - this.y3) * x23 + y23 * (this.x3 - pnt.x)) / div,
        ((pnt.y - this.y1) * x31 + y31 * (this.x1 - pnt.x)) / div,
        ((pnt.y - this.y2) * x12 + y12 * (this.x2 - pnt.x)) / div);
  }

  /// Gets the sphere where the intersection of the sphere and the plane for the triangle is a circle
  /// which touches each side only once. The circle is inscribed in the triangle.
  /// If the triangle is degenerate (area is zero) then null will be returned.
  Sphere? get incenter {
    final Point2 v1 = this.point1;
    final Point2 v2 = this.point2;
    final Point2 v3 = this.point3;
    final double len1 = v2.distance(v3);
    final double len2 = v1.distance(v3);
    final double len3 = v1.distance(v2);
    final double p = len1 + len2 + len3;
    if (p == 0.0) {
      // Degenerate triangle
      return null;
    }
    final Point2 center = this.fromBarycentricCoordinates(len1 / p, len2 / p, len3 / p);
    return Sphere.fromPoint(Point3.fromPoint2(center), this.area / p);
  }

  /// Gets the sphere where the intersection of the sphere and the plane for the triangle is a circle
  /// which touches each point of the triangle. The circle is circumscribed around the triangle.
  Sphere? get circumcenter {
    final e1 = Vector2(this.x3 - this.x2, this.y3 - this.y2);
    final e2 = Vector2(this.x1 - this.x3, this.y1 - this.y3);
    final e3 = Vector2(this.x2 - this.x1, this.y2 - this.y1);
    final d1 = -e2.dot(e3);
    final d2 = -e3.dot(e1);
    final d3 = -e1.dot(e2);
    final c1 = d2 * d3;
    final c2 = d3 * d1;
    final c3 = d1 * d2;
    final c = c1 + c2 + c3;
    if (c == 0) {
      return null;
    } else {
      final div = 2.0 * c;
      final center = this.fromBarycentricCoordinates((c2 + c3) / div, (c2 + c3) / div, (c2 + c3) / div);
      final diam = math.sqrt((d1 + d2) * (d2 + d3) * (d3 + d1) / c);
      return Sphere.fromPoint(Point3.fromPoint2(center), diam / 2.0);
    }
  }

  /// Determines if the given [other] variable is a [Triangle2] equal to this triangle.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is Triangle2 &&
          Comparer.equals(other.x1, this.x1) &&
          Comparer.equals(other.y1, this.y1) &&
          Comparer.equals(other.x2, this.x2) &&
          Comparer.equals(other.y2, this.y2) &&
          Comparer.equals(other.x3, this.x3) &&
          Comparer.equals(other.y3, this.y3);

  @override
  int get hashCode => x1.hashCode ^ y1.hashCode ^ x2.hashCode ^ y2.hashCode ^ x3.hashCode ^ y3.hashCode;

  /// Gets the string for this triangle.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this triangle.
  String format([int fraction = 3, int whole = 0]) =>
      '[[' +
      formatDouble(this.x1, fraction, whole) +
      ', ' +
      formatDouble(this.y1, fraction, whole) +
      '], [' +
      formatDouble(this.x2, fraction, whole) +
      ', ' +
      formatDouble(this.y2, fraction, whole) +
      '], [' +
      formatDouble(this.x3, fraction, whole) +
      ', ' +
      formatDouble(this.y3, fraction, whole) +
      ']]';
}

/// A math structure for storing a 3D triangle.
class Triangle3 {
  /// The x component of the first point.
  final double x1;

  /// The y component of the first point.
  final double y1;

  /// The z component of the first point.
  final double z1;

  /// The x component of the second point.
  final double x2;

  /// The y component of the second point.
  final double y2;

  /// The z component of the second point.
  final double z2;

  /// The x component of the third point.
  final double x3;

  /// The y component of the third point.
  final double y3;

  /// The z component of the third point.
  final double z3;

  /// Constructs a new [Triangle3] instance.
  Triangle3(this.x1, this.y1, this.z1, this.x2, this.y2, this.z2, this.x3, this.y3, this.z3);

  /// Constructs a new [Triangle3] with the given points.
  factory Triangle3.fromPoints(Point3 pnt1, Point3 pnt2, Point3 pnt3) =>
      Triangle3(pnt1.x, pnt1.y, pnt1.z, pnt2.x, pnt2.y, pnt2.z, pnt3.x, pnt3.y, pnt3.z);

  /// Constructs a new [Triangle3] with the given [Triangle2] with the given z value.
  factory Triangle3.fromTriangle2(Triangle2 tri, [double z = 0.0]) =>
      Triangle3(tri.x1, tri.y1, z, tri.x2, tri.y2, z, tri.x3, tri.y3, z);

  /// Constructs a new [Triangle3] instance given a list of 9 doubles.
  ///
  /// [values] is a list of doubles are in the order x, y, then z
  /// for the first, second, and third point.
  factory Triangle3.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 9);
    return Triangle3(values[0], values[1], values[2], values[3], values[4], values[5], values[6], values[7], values[8]);
  }

  /// Gets an list of 9 doubles in the order x, y, then z
  /// for the first, second, and third point.
  List<double> toList() => [this.x1, this.y1, this.z1, this.x2, this.y2, this.z2, this.x3, this.y3, this.z3];

  /// Gets the value at the zero based index in the order x, y, then z
  /// for the first, second, and third point. If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.x1;
      case 1:
        return this.y1;
      case 2:
        return this.z1;
      case 3:
        return this.x2;
      case 4:
        return this.y2;
      case 5:
        return this.z2;
      case 6:
        return this.x3;
      case 7:
        return this.y3;
      case 8:
        return this.z3;
    }
    return 0.0;
  }

  /// Gets the first point of the triangle.
  Point3 get point1 => Point3(this.x1, this.y1, this.z1);

  /// Gets the second point of the triangle.
  Point3 get point2 => Point3(this.x2, this.y2, this.z2);

  /// Gets the third point of the triangle.
  Point3 get point3 => Point3(this.x3, this.y3, this.z3);

  /// Gets the normal of the triangle plane.
  Vector3 get normal {
    final Vector3 d1 = Vector3(this.x2 - this.x1, this.y2 - this.y1, this.z2 - this.z1);
    final Vector3 d2 = Vector3(this.x3 - this.x2, this.y3 - this.y2, this.z3 - this.z2);
    return d1.cross(d2).normal();
  }

  /// Get the area of the triangle.
  double get area {
    final Vector3 d1 = Vector3(this.x2 - this.x1, this.y2 - this.y1, this.z2 - this.z1);
    final Vector3 d2 = Vector3(this.x3 - this.x2, this.y3 - this.y2, this.z3 - this.z2);
    return d1.cross(d2).length() * 0.5;
  }

  /// Gets the average point of the triangles points.
  Point3 get centroid => Point3(
      (this.x1 + this.x2 + this.x3) / 3.0, (this.y1 + this.y2 + this.y3) / 3.0, (this.z1 + this.z2 + this.z3) / 3.0);

  /// Convertex from the given barycentric coorinates vector to the cartesian coordinate point.
  Point3 fromBarycentricCoordinates(double x, double y, double z) => Point3(x * this.x1 + y * this.x2 + z * this.x3,
      x * this.y1 + y * this.y2 + z * this.y3, x * this.z1 + y * this.z2 + z * this.z3);

  /// Convertex from the given barycentric coorinates vector to the cartesian coordinate point.
  Point3 fromBarycentric(Vector3 vec) => fromBarycentricCoordinates(vec.dx, vec.dy, vec.dz);

  /// Convertex from the given cartesian coordinate point to the barycentric coorinates vector.
  /// If the triangle is degenerate (area is zero) then null will be returned.
  Vector3? toBarycentric(Point3 pnt) {
    final Vector3 n = this.normal;
    final double nxa = n.dx.abs();
    final double nya = n.dy.abs();
    final double nza = n.dz.abs();
    double u1, u2, u3, u4;
    double v1, v2, v3, v4;
    if ((nxa >= nya) && (nxa >= nza)) {
      // Discard x, project onto yz plane
      u1 = this.y1 - this.y3;
      u2 = this.y2 - this.y3;
      u3 = pnt.y - this.y1;
      u4 = pnt.y - this.y3;

      v1 = this.z1 - this.z3;
      v2 = this.z2 - this.z3;
      v3 = pnt.z - this.z1;
      v4 = pnt.z - this.z3;
    } else if (nya >= nza) {
      // Discard y, project onto xz plane
      u1 = this.z1 - this.z3;
      u2 = this.z2 - this.z3;
      u3 = pnt.z - this.z1;
      u4 = pnt.z - this.z3;

      v1 = this.x1 - this.x3;
      v2 = this.x2 - this.x3;
      v3 = pnt.x - this.x1;
      v4 = pnt.x - this.x3;
    } else {
      // Discard z, project onto xy plane
      u1 = this.x1 - this.x3;
      u2 = this.x2 - this.x3;
      u3 = pnt.x - this.x1;
      u4 = pnt.x - this.x3;

      v1 = this.y1 - this.y3;
      v2 = this.y2 - this.y3;
      v3 = pnt.y - this.y1;
      v4 = pnt.y - this.y3;
    }

    final double div = v1 * u3 - v2 * u1;
    if (div == 0.0) {
      // Degenerate triangle
      return null;
    }

    final double x = (v4 * u2 - v2 * u4) / div;
    final double y = (v1 * u3 - v3 * u1) / div;
    return Vector3(x, y, 1.0 - x - y);
  }

  /// Gets the sphere where the intersection of the sphere and the plane for the triangle is a circle
  /// which touches each side only once. The circle is inscribed in the triangle.
  /// If the triangle is degenerate (area is zero) then null will be returned.
  Sphere? get incenter {
    final Point3 v1 = this.point1;
    final Point3 v2 = this.point2;
    final Point3 v3 = this.point3;
    final double len1 = v2.distance(v3);
    final double len2 = v1.distance(v3);
    final double len3 = v1.distance(v2);
    final double p = len1 + len2 + len3;
    if (p == 0.0) {
      // Degenerate triangle
      return null;
    }
    final Point3 center = this.fromBarycentricCoordinates(len1 / p, len2 / p, len3 / p);
    return Sphere.fromPoint(center, this.area / p);
  }

  /// Gets the sphere where the intersection of the sphere and the plane for the triangle is a circle
  /// which touches each point of the triangle. The circle is circumscribed around the triangle.
  Sphere? get circumcenter {
    final Vector3 e1 = Vector3(this.x3 - this.x2, this.y3 - this.y2, this.z3 - this.z2);
    final Vector3 e2 = Vector3(this.x1 - this.x3, this.y1 - this.y3, this.z1 - this.z3);
    final Vector3 e3 = Vector3(this.x2 - this.x1, this.y2 - this.y1, this.z2 - this.z1);
    final double d1 = -e2.dot(e3);
    final double d2 = -e3.dot(e1);
    final double d3 = -e1.dot(e2);
    final double c1 = d2 * d3;
    final double c2 = d3 * d1;
    final double c3 = d1 * d2;
    final double c = c1 + c2 + c3;
    if (c == 0) return null;
    final double div = 2.0 * c;
    final Point3 center = this.fromBarycentricCoordinates((c2 + c3) / div, (c2 + c3) / div, (c2 + c3) / div);
    final double diam = math.sqrt((d1 + d2) * (d2 + d3) * (d3 + d1) / c);
    return Sphere.fromPoint(center, diam / 2.0);
  }

  /// Determines if the given [other] variable is a [Triangle3] equal to this triangle.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Triangle3) return false;
    if (!Comparer.equals(other.x1, this.x1)) return false;
    if (!Comparer.equals(other.y1, this.y1)) return false;
    if (!Comparer.equals(other.z1, this.z1)) return false;
    if (!Comparer.equals(other.x2, this.x2)) return false;
    if (!Comparer.equals(other.y2, this.y2)) return false;
    if (!Comparer.equals(other.z2, this.z2)) return false;
    if (!Comparer.equals(other.x3, this.x3)) return false;
    if (!Comparer.equals(other.y3, this.y3)) return false;
    if (!Comparer.equals(other.z3, this.z3)) return false;
    return true;
  }

  @override
  int get hashCode =>
      x1.hashCode ^
      y1.hashCode ^
      z1.hashCode ^
      x2.hashCode ^
      y2.hashCode ^
      z2.hashCode ^
      x3.hashCode ^
      y3.hashCode ^
      3.hashCode;

  /// Gets the string for this triangle.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this triangle.
  String format([int fraction = 3, int whole = 0]) =>
      '[[' +
      formatDouble(this.x1, fraction, whole) +
      ', ' +
      formatDouble(this.y1, fraction, whole) +
      ', ' +
      formatDouble(this.z1, fraction, whole) +
      '], [' +
      formatDouble(this.x2, fraction, whole) +
      ', ' +
      formatDouble(this.y2, fraction, whole) +
      ', ' +
      formatDouble(this.z2, fraction, whole) +
      '], [' +
      formatDouble(this.x3, fraction, whole) +
      ', ' +
      formatDouble(this.y3, fraction, whole) +
      ', ' +
      formatDouble(this.z3, fraction, whole) +
      ']]';
}

/// A math structure for storing a 2D vector.
class Vector2 {
  /// Gets a zeroed [Vector2].
  static Vector2 get zero => _zeroSingleton ??= Vector2(0.0, 0.0);
  static Vector2? _zeroSingleton;

  /// Gets a new positive X [Vector2].
  static Vector2 get posX => _posXSingleton ??= Vector2(1.0, 0.0);
  static Vector2? _posXSingleton;

  /// Gets a new negative X [Vector2].
  static Vector2 get negX => _negXSingleton ??= Vector2(-1.0, 0.0);
  static Vector2? _negXSingleton;

  /// Gets a new positive Y [Vector2].
  static Vector2 get posY => _posYSingleton ??= Vector2(0.0, 1.0);
  static Vector2? _posYSingleton;

  /// Gets a new negative Y [Vector2].
  static Vector2 get negY => _negYSingleton ??= Vector2(0.0, -1.0);
  static Vector2? _negYSingleton;

  /// The dX component of the vector.
  final double dx;

  /// The dY component of the vector.
  final double dy;

  /// Constructs a new [Vector2] instance.
  Vector2(this.dx, this.dy);

  /// Constructs a new [Vector2] from a [Vector3].
  ///
  /// The dZ component is ignored.
  factory Vector2.fromVector3(Vector3 vec) => Vector2(vec.dx, vec.dy);

  /// Constructs a new [Vector2] from a [Vector4].
  ///
  /// The dZ and dW components are ignored.
  factory Vector2.fromVector4(Vector4 vec) => Vector2(vec.dx, vec.dy);

  /// Constructs a new [Vector2] from a [Point2].
  factory Vector2.fromPoint2(Point2 pnt) => Vector2(pnt.x, pnt.y);

  /// Constructs a new [Vector2] from a [Point3].
  ///
  /// The Z component is ignored.
  factory Vector2.fromPoint3(Point3 pnt) => Vector2(pnt.x, pnt.y);

  /// Constructs a new [Vector2] from a [Point4].
  ///
  /// The Z and W components are ignored.
  factory Vector2.fromPoint4(Point4 pnt) => Vector2(pnt.x, pnt.y);

  /// Constructs a new [Vector2] instance given a list of 2 doubles.
  ///
  /// [values] is a list of doubles are in the order dX then dY.
  factory Vector2.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 2);
    return Vector2(values[0], values[1]);
  }

  /// Gets an list of 2 doubles in the order dX then dY.
  List<double> toList() => [this.dx, this.dy];

  /// Gets the value at the zero based index in the order dX then dY.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.dx;
      case 1:
        return this.dy;
    }
    return 0.0;
  }

  /// The length squared of this vector.
  double length2() => this.dot(this);

  /// The length of this vector.
  ///
  /// [length2] is faster since it does not take the square root,
  /// therefore it should be used instead of [length] where possible.
  double length() => math.sqrt(this.length2());

  /// Gets the dot product of this vector and the [other] vector.
  double dot(Vector2 other) => this.dx * other.dx + this.dy * other.dy;

  /// Finds the origin based cross product for this vector and the [other] vector.
  double cross(Vector2 other) => this.dx * other.dy - this.dy * other.dx;

  /// Determines if the two vectors are acute or not.
  /// Returns true if the two vectors are acute (<90), false if not.
  bool acute(Vector2 other) => this.dot(other) > 0.0;

  /// Determines if the two vectors are obtuse or not.
  /// Returns true if the two vectors are obtuse (>90), false if not.
  bool obtuse(Vector2 other) => this.dot(other) < 0.0;

  /// Gets the side of the edge the given point is on.
  Side side(Point2 point) {
    final double value = this.dx * point.y - this.dy * point.x;
    if (Comparer.equals(value, 0.0)) return Side.Inside;
    if (value < 0.0) return Side.Right;
    return Side.Left;
  }

  /// Gets a linear interpolation between this vector and the [other] vector.
  ///
  /// The [i] is interpolation factor. 0.0 or less will return this vector.
  /// 1.0 or more will return the [other] vector. Between 0.0 and 1.0 will be
  /// a scaled mixture of the two vectors.
  Vector2 lerp(Vector2 other, double i) => Vector2(lerpVal(this.dx, other.dx, i), lerpVal(this.dy, other.dy, i));

  /// Gets normalized vector of this vector.
  Vector2 normal() => this / this.length();

  /// Creates a new vector as the sum of this vector and the [other] vector.
  Vector2 operator +(Vector2 other) => Vector2(this.dx + other.dx, this.dy + other.dy);

  /// Creates a new vector as the difference of this vector and the [other] vector.
  Vector2 operator -(Vector2 other) => Vector2(this.dx - other.dx, this.dy - other.dy);

  /// Creates the negation of this vector.
  Vector2 operator -() => Vector2(-this.dx, -this.dy);

  /// Creates a new vector scaled by the given [scalar].
  Vector2 operator *(double scalar) => Vector2(this.dx * scalar, this.dy * scalar);

  /// Creates a new vector inversely scaled by the given [scalar].
  Vector2 operator /(double scalar) {
    if (Comparer.equals(scalar, 0.0)) return Vector2.zero;
    return Vector2(this.dx / scalar, this.dy / scalar);
  }

  /// Determines if the given [other] variable is a [Vector2] equal to this vector.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Vector2) return false;
    if (!Comparer.equals(other.dx, this.dx)) return false;
    if (!Comparer.equals(other.dy, this.dy)) return false;
    return true;
  }

  @override
  int get hashCode => dx.hashCode ^ dy.hashCode;

  /// Gets the string for this vector.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this vector.
  String format([int fraction = 3, int whole = 0]) =>
      '[' + formatDouble(this.dx, fraction, whole) + ', ' + formatDouble(this.dy, fraction, whole) + ']';
}

/// A math structure for storing a 3D vector.
class Vector3 {
  /// Gets a zeroed [Vector3].
  static Vector3 get zero => _zeroSingleton ??= Vector3(0.0, 0.0, 0.0);
  static Vector3? _zeroSingleton;

  /// Gets a new positive X [Vector3].
  static Vector3 get posX => _posXSingleton ??= Vector3(1.0, 0.0, 0.0);
  static Vector3? _posXSingleton;

  /// Gets a new negative X [Vector3].
  static Vector3 get negX => _negXSingleton ??= Vector3(-1.0, 0.0, 0.0);
  static Vector3? _negXSingleton;

  /// Gets a new positive Y [Vector3].
  static Vector3 get posY => _posYSingleton ??= Vector3(0.0, 1.0, 0.0);
  static Vector3? _posYSingleton;

  /// Gets a new negative Y [Vector3].
  static Vector3 get negY => _negYSingleton ??= Vector3(0.0, -1.0, 0.0);
  static Vector3? _negYSingleton;

  /// Gets a new positive Z [Vector3].
  static Vector3 get posZ => _posZSingleton ??= Vector3(0.0, 0.0, 1.0);
  static Vector3? _posZSingleton;

  /// Gets a new negative Z [Vector3].
  static Vector3 get negZ => _negZSingleton ??= Vector3(0.0, 0.0, -1.0);
  static Vector3? _negZSingleton;

  /// The dX component of the vector.
  final double dx;

  /// The dY component of the vector.
  final double dy;

  /// The dZ component of the vector.
  final double dz;

  /// Constructs a new [Vector3] instance.
  Vector3(this.dx, this.dy, this.dz);

  /// Constructs a new [Vector3] from a [Vector2].
  ///
  /// The dz component is defaulted to 0.0.
  factory Vector3.fromVector2(Vector2 vec, [double dz = 0.0]) => Vector3(vec.dx, vec.dy, dz);

  /// Constructs a new [Vector3] from a [Vector4].
  ///
  /// The dW component is ignored.
  factory Vector3.fromVector4(Vector4 vec) => Vector3(vec.dx, vec.dy, vec.dz);

  /// Constructs a new [Vector3] from a [Point2].
  ///
  /// The dz component is defaulted to 0.0.
  factory Vector3.fromPoint2(Point2 pnt, [double dz = 0.0]) => Vector3(pnt.x, pnt.y, dz);

  /// Constructs a new [Vector3] from a [Point3].
  factory Vector3.fromPoint3(Point3 pnt) => Vector3(pnt.x, pnt.y, pnt.z);

  /// Constructs a new [Vector3] from a [Point4].
  ///
  /// The W component is ignored.
  factory Vector3.fromPoint4(Point4 pnt) => Vector3(pnt.x, pnt.y, pnt.z);

  /// Constructs a new [Vector3] instance given a list of 3 doubles.
  ///
  /// [values] is a list of doubles are in the order dX, dY, then dZ.
  factory Vector3.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 3);
    return Vector3(values[0], values[1], values[2]);
  }

  /// Gets an list of 3 doubles in the order dX, dY, then dZ.
  List<double> toList() => [this.dx, this.dy, this.dz];

  /// Gets the value at the zero based index in the order dX, dY, then dZ.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.dx;
      case 1:
        return this.dy;
      case 2:
        return this.dz;
    }
    return 0.0;
  }

  /// The length squared of this vector.
  double length2() => this.dot(this);

  /// The length of this vector.
  ///
  /// [length2] is faster since it does not take the square root,
  /// therefore it should be used instead of [length] where possible.
  double length() => math.sqrt(this.length2());

  /// Gets the dot product of this vector and the [other] vector.
  double dot(Vector3 other) => this.dx * other.dx + this.dy * other.dy + this.dz * other.dz;

  /// Gets a linear interpolation between this vector and the [other] vector.
  ///
  /// The [i] is interpolation factor. 0.0 or less will return this vector.
  /// 1.0 or more will return the [other] vector. Between 0.0 and 1.0 will be
  /// a scaled mixture of the two vectors.
  Vector3 lerp(Vector3 other, double i) =>
      Vector3(lerpVal(this.dx, other.dx, i), lerpVal(this.dy, other.dy, i), lerpVal(this.dz, other.dz, i));

  /// Gets normalized vector of this vector.
  Vector3 normal() {
    final double len = this.length();
    if (len == 1.0) return this;
    return this / len;
  }

  /// Gets the cross of this vector and the given [other] vector.
  Vector3 cross(Vector3 other) => Vector3(this.dy * other.dz - this.dz * other.dy,
      this.dz * other.dx - this.dx * other.dz, this.dx * other.dy - this.dy * other.dx);

  /// Creates a new vector as the sum of this vector and the [other] vector.
  Vector3 operator +(Vector3 other) => Vector3(this.dx + other.dx, this.dy + other.dy, this.dz + other.dz);

  /// Creates a new vector as the difference of this vector and the [other] vector.
  Vector3 operator -(Vector3 other) => Vector3(this.dx - other.dx, this.dy - other.dy, this.dz - other.dz);

  /// Creates the negation of this vector.
  Vector3 operator -() => Vector3(-this.dx, -this.dy, -this.dz);

  /// Creates a new vector scaled by the given [scalar].
  Vector3 operator *(double scalar) => Vector3(this.dx * scalar, this.dy * scalar, this.dz * scalar);

  /// Creates a new vector inversely scaled by the given [scalar].
  Vector3 operator /(double scalar) {
    if (Comparer.equals(scalar, 0.0)) return Vector3.zero;
    return Vector3(this.dx / scalar, this.dy / scalar, this.dz / scalar);
  }

  /// Determines if this vector is equal to zero.
  bool isZero() {
    if (!Comparer.equals(0.0, this.dx)) return false;
    if (!Comparer.equals(0.0, this.dy)) return false;
    if (!Comparer.equals(0.0, this.dz)) return false;
    return true;
  }

  /// Determines if the given [other] variable is a [Vector3] equal to this vector.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Vector3) return false;
    if (!Comparer.equals(other.dx, this.dx)) return false;
    if (!Comparer.equals(other.dy, this.dy)) return false;
    if (!Comparer.equals(other.dz, this.dz)) return false;
    return true;
  }

  @override
  int get hashCode => dx.hashCode ^ dy.hashCode ^ dz.hashCode;

  /// Gets the string for this vector.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this vector.
  String format([int fraction = 3, int whole = 0]) =>
      '[' +
      formatDouble(this.dx, fraction, whole) +
      ', ' +
      formatDouble(this.dy, fraction, whole) +
      ', ' +
      formatDouble(this.dz, fraction, whole) +
      ']';
}

/// A math structure for storing a 4D vector.
class Vector4 {
  /// Gets a zeroed [Vector3].
  static Vector4 get zero => _zeroSingleton ??= Vector4(0.0, 0.0, 0.0, 0.0);
  static Vector4? _zeroSingleton;

  /// Gets a new positive X [Vector4].
  static Vector4 get posX => _posXSingleton ??= Vector4(1.0, 0.0, 0.0, 0.0);
  static Vector4? _posXSingleton;

  /// Gets a new negative X [Vector4].
  static Vector4 get negX => _negXSingleton ??= Vector4(-1.0, 0.0, 0.0, 0.0);
  static Vector4? _negXSingleton;

  /// Gets a new positive Y [Vector4].
  static Vector4 get posY => _posYSingleton ??= Vector4(0.0, 1.0, 0.0, 0.0);
  static Vector4? _posYSingleton;

  /// Gets a new negative Y [Vector4].
  static Vector4 get negY => _negYSingleton ??= Vector4(0.0, -1.0, 0.0, 0.0);
  static Vector4? _negYSingleton;

  /// Gets a new positive Z [Vector4].
  static Vector4 get posZ => _posZSingleton ??= Vector4(0.0, 0.0, 1.0, 0.0);
  static Vector4? _posZSingleton;

  /// Gets a new negative Z [Vector4].
  static Vector4 get negZ => _negZSingleton ??= Vector4(0.0, 0.0, -1.0, 0.0);
  static Vector4? _negZSingleton;

  /// Gets a new positive W [Vector4].
  static Vector4 get posW => _posWSingleton ??= Vector4(0.0, 0.0, 0.0, 1.0);
  static Vector4? _posWSingleton;

  /// Gets a new negative W [Vector4].
  static Vector4 get negW => _negWSingleton ??= Vector4(0.0, 0.0, 0.0, -1.0);
  static Vector4? _negWSingleton;

  /// Gets the default shadow adjustment.
  /// The RGB higher quality depth vector `<1.0, 1.0/256.0, 1.0/65536.0, 0.0>`
  /// which is the default for shadow depth adjustment.
  static Vector4 get shadowAdjust => _shadowAdjust ??= Vector4(1.0, 1.0 / 256.0, 1.0 / 65536.0, 0.0);
  static Vector4? _shadowAdjust;

  /// The dX component of the vector.
  final double dx;

  /// The dY component of the vector.
  final double dy;

  /// The dZ component of the vector.
  final double dz;

  /// The dW component of the vector.
  final double dw;

  /// Constructs a new [Vector4] instance.
  Vector4(this.dx, this.dy, this.dz, this.dw);

  /// Constructs a new [Vector4] from a [Vector2].
  ///
  /// The dZ and dW components are default to 0.0.
  factory Vector4.fromVector2(Vector2 vec, [double dz = 0.0, double dw = 0.0]) => Vector4(vec.dx, vec.dy, dz, dw);

  /// Constructs a new [Vector4] from a [Vector3].
  ///
  /// The dW component is default to 0.0.
  factory Vector4.fromVector3(Vector3 vec, [double dw = 0.0]) => Vector4(vec.dx, vec.dy, vec.dz, dw);

  /// Constructs a new [Vector4] from a [Point2].
  ///
  /// The dZ and dW components are default to 0.0.
  factory Vector4.fromPoint2(Point2 pnt, [double dz = 0.0, double dw = 0.0]) => Vector4(pnt.x, pnt.y, dz, dw);

  /// Constructs a new [Vector4] from a [Point3].
  ///
  /// The dW component is initialized to 0.0.
  factory Vector4.fromPoint3(Point3 pnt, [double dw = 0.0]) => Vector4(pnt.x, pnt.y, pnt.z, dw);

  /// Constructs a new [Vector4] from a [Point4].
  factory Vector4.fromPoint4(Point4 pnt) => Vector4(pnt.x, pnt.y, pnt.z, pnt.w);

  /// Constructs a new [Vector4] instance given a list of 4 doubles.
  ///
  /// [values] is a list of doubles are in the order dX, dY, dZ, then dW.
  factory Vector4.fromList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    return Vector4(values[0], values[1], values[2], values[3]);
  }

  /// Gets an list of 4 doubles in the order dX, dY, dZ, then dW.
  List<double> toList() => [this.dx, this.dy, this.dz, this.dw];

  /// Gets the value at the zero based index in the order dX, dY, dZ, then dW.
  /// If out-of-bounds, zero is returned.
  double atIndex(int i) {
    switch (i) {
      case 0:
        return this.dx;
      case 1:
        return this.dy;
      case 2:
        return this.dz;
      case 3:
        return this.dw;
    }
    return 0.0;
  }

  /// The length squared of this vector.
  double length2() => this.dot(this);

  /// The length of this vector.
  ///
  /// [length2] is faster since it does not take the square root],
  /// therefore it should be used instead of [length] where possible.
  double length() => math.sqrt(this.length2());

  /// Gets the dot product of this vector and the [other] vector.
  double dot(Vector4 other) => this.dx * other.dx + this.dy * other.dy + this.dz * other.dz + this.dw * other.dw;

  /// Gets a linear interpolation between this vector and the [other] vector.
  ///
  /// The [i] is interpolation factor. 0.0 or less will return this vector.
  /// 1.0 or more will return the [other] vector. Between 0.0 and 1.0 will be
  /// a scaled mixture of the two vectors.
  Vector4 lerp(Vector4 other, double i) => Vector4(lerpVal(this.dx, other.dx, i), lerpVal(this.dy, other.dy, i),
      lerpVal(this.dz, other.dz, i), lerpVal(this.dw, other.dw, i));

  /// Gets normalized vector of this vector.
  Vector4 normal() => this / this.length();

  /// Creates a new vector as the sum of this vector and the [other] vector.
  Vector4 operator +(Vector4 other) =>
      Vector4(this.dx + other.dx, this.dy + other.dy, this.dz + other.dz, this.dw + other.dw);

  /// Creates a new vector as the difference of this vector and the [other] vector.
  Vector4 operator -(Vector4 other) =>
      Vector4(this.dx - other.dx, this.dy - other.dy, this.dz - other.dz, this.dw - other.dw);

  /// Creates the negation of this vector.
  Vector4 operator -() => Vector4(-this.dx, -this.dy, -this.dz, -this.dw);

  /// Creates a new vector scaled by the given [scalar].
  Vector4 operator *(double scalar) => Vector4(this.dx * scalar, this.dy * scalar, this.dz * scalar, this.dw * scalar);

  /// Creates a new vector inversely scaled by the given [scalar].
  Vector4 operator /(double scalar) {
    if (Comparer.equals(scalar, 0.0)) return Vector4.zero;
    return Vector4(this.dx / scalar, this.dy / scalar, this.dz / scalar, this.dw / scalar);
  }

  /// Determines if the given [other] variable is a [Vector4] equal to this vector.
  ///
  /// The equality of the doubles is tested with the current Comparer method.
  @override
  bool operator ==(
    final Object other,
  ) =>
      identical(this, other) ||
      other is Vector4 &&
          Comparer.equals(other.dx, this.dx) &&
          Comparer.equals(other.dy, this.dy) &&
          Comparer.equals(other.dz, this.dz) &&
          Comparer.equals(other.dw, this.dw);

  @override
  int get hashCode => dx.hashCode ^ dy.hashCode ^ dz.hashCode ^ dw.hashCode;

  /// Gets the string for this vector.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this vector.
  String format([
    final int fraction = 3,
    final int whole = 0,
  ]) =>
      '[' +
      formatDouble(this.dx, fraction, whole) +
      ', ' +
      formatDouble(this.dy, fraction, whole) +
      ', ' +
      formatDouble(this.dz, fraction, whole) +
      ', ' +
      formatDouble(this.dw, fraction, whole) +
      ']';
}

/// A list of predefined colors.
class Colors {
  // Keep colors from being constructed.
  Colors._();

  // Gets the color #FFF0F8FF
  static Color4 get aliceBlue => Color4.fromBytes(0xF0, 0xF8, 0xFF);

  // Gets the color #FFFAEBD7
  static Color4 get antiqueWhite => Color4.fromBytes(0xFA, 0xEB, 0xD7);

  // Gets the color #FF00FFFF
  static Color4 get aqua => Color4.fromBytes(0x00, 0xFF, 0xFF);

  // Gets the color #FF7FFFD4
  static Color4 get aquamarine => Color4.fromBytes(0x7F, 0xFF, 0xD4);

  // Gets the color #FFF0FFFF
  static Color4 get azure => Color4.fromBytes(0xF0, 0xFF, 0xFF);

  // Gets the color #FFF5F5DC
  static Color4 get beige => Color4.fromBytes(0xF5, 0xF5, 0xDC);

  // Gets the color #FFFFE4C4
  static Color4 get bisque => Color4.fromBytes(0xFF, 0xE4, 0xC4);

  // Gets the color #FF000000
  static Color4 get black => Color4.fromBytes(0x00, 0x00, 0x00);

  // Gets the color #FFFFEBCD
  static Color4 get blanchedAlmond => Color4.fromBytes(0xFF, 0xEB, 0xCD);

  // Gets the color #FF0000FF
  static Color4 get blue => Color4.fromBytes(0x00, 0x00, 0xFF);

  // Gets the color #FF8A2BE2
  static Color4 get blueViolet => Color4.fromBytes(0x8A, 0x2B, 0xE2);

  // Gets the color #FFA52A2A
  static Color4 get brown => Color4.fromBytes(0xA5, 0x2A, 0x2A);

  // Gets the color #FFDEB887
  static Color4 get burlyWood => Color4.fromBytes(0xDE, 0xB8, 0x87);

  // Gets the color #FF5F9EA0
  static Color4 get cadetBlue => Color4.fromBytes(0x5F, 0x9E, 0xA0);

  // Gets the color #FF7FFF00
  static Color4 get chartreuse => Color4.fromBytes(0x7F, 0xFF, 0x00);

  // Gets the color #FFD2691E
  static Color4 get chocolate => Color4.fromBytes(0xD2, 0x69, 0x1E);

  // Gets the color #FFFF7F50
  static Color4 get coral => Color4.fromBytes(0xFF, 0x7F, 0x50);

  // Gets the color #FF6495ED
  static Color4 get cornflowerBlue => Color4.fromBytes(0x64, 0x95, 0xED);

  // Gets the color #FFFFF8DC
  static Color4 get cornsilk => Color4.fromBytes(0xFF, 0xF8, 0xDC);

  // Gets the color #FFDC143C
  static Color4 get crimson => Color4.fromBytes(0xDC, 0x14, 0x3C);

  // Gets the color #FF00FFFF
  static Color4 get cyan => Color4.fromBytes(0x00, 0xFF, 0xFF);

  // Gets the color #FF00008B
  static Color4 get darkBlue => Color4.fromBytes(0x00, 0x00, 0x8B);

  // Gets the color #FF008B8B
  static Color4 get darkCyan => Color4.fromBytes(0x00, 0x8B, 0x8B);

  // Gets the color #FFB8860B
  static Color4 get darkGoldenrod => Color4.fromBytes(0xB8, 0x86, 0x0B);

  // Gets the color #FFA9A9A9
  static Color4 get darkGray => Color4.fromBytes(0xA9, 0xA9, 0xA9);

  // Gets the color #FF006400
  static Color4 get darkGreen => Color4.fromBytes(0x00, 0x64, 0x00);

  // Gets the color #FFBDB76B
  static Color4 get darkKhaki => Color4.fromBytes(0xBD, 0xB7, 0x6B);

  // Gets the color #FF8B008B
  static Color4 get darkMagenta => Color4.fromBytes(0x8B, 0x00, 0x8B);

  // Gets the color #FF556B2F
  static Color4 get darkOliveGreen => Color4.fromBytes(0x55, 0x6B, 0x2F);

  // Gets the color #FFFF8C00
  static Color4 get darkOrange => Color4.fromBytes(0xFF, 0x8C, 0x00);

  // Gets the color #FF9932CC
  static Color4 get darkOrchid => Color4.fromBytes(0x99, 0x32, 0xCC);

  // Gets the color #FF8B0000
  static Color4 get darkRed => Color4.fromBytes(0x8B, 0x00, 0x00);

  // Gets the color #FFE9967A
  static Color4 get darkSalmon => Color4.fromBytes(0xE9, 0x96, 0x7A);

  // Gets the color #FF8FBC8B
  static Color4 get darkSeaGreen => Color4.fromBytes(0x8F, 0xBC, 0x8B);

  // Gets the color #FF483D8B
  static Color4 get darkSlateBlue => Color4.fromBytes(0x48, 0x3D, 0x8B);

  // Gets the color #FF2F4F4F
  static Color4 get darkSlateGray => Color4.fromBytes(0x2F, 0x4F, 0x4F);

  // Gets the color #FF00CED1
  static Color4 get darkTurquoise => Color4.fromBytes(0x00, 0xCE, 0xD1);

  // Gets the color #FF9400D3
  static Color4 get darkViolet => Color4.fromBytes(0x94, 0x00, 0xD3);

  // Gets the color #FFFF1493
  static Color4 get deepPink => Color4.fromBytes(0xFF, 0x14, 0x93);

  // Gets the color #FF00BFFF
  static Color4 get deepSkyBlue => Color4.fromBytes(0x00, 0xBF, 0xFF);

  // Gets the color #FF696969
  static Color4 get dimGray => Color4.fromBytes(0x69, 0x69, 0x69);

  // Gets the color #FF1E90FF
  static Color4 get dodgerBlue => Color4.fromBytes(0x1E, 0x90, 0xFF);

  // Gets the color #FFB22222
  static Color4 get firebrick => Color4.fromBytes(0xB2, 0x22, 0x22);

  // Gets the color #FFFFFAF0
  static Color4 get floralWhite => Color4.fromBytes(0xFF, 0xFA, 0xF0);

  // Gets the color #FF228B22
  static Color4 get forestGreen => Color4.fromBytes(0x22, 0x8B, 0x22);

  // Gets the color #FFFF00FF
  static Color4 get fuchsia => Color4.fromBytes(0xFF, 0x00, 0xFF);

  // Gets the color #FFDCDCDC
  static Color4 get gainsboro => Color4.fromBytes(0xDC, 0xDC, 0xDC);

  // Gets the color #FFF8F8FF
  static Color4 get ghostWhite => Color4.fromBytes(0xF8, 0xF8, 0xFF);

  // Gets the color #FFFFD700
  static Color4 get gold => Color4.fromBytes(0xFF, 0xD7, 0x00);

  // Gets the color #FFDAA520
  static Color4 get goldenrod => Color4.fromBytes(0xDA, 0xA5, 0x20);

  // Gets the color #FF808080
  static Color4 get gray => Color4.fromBytes(0x80, 0x80, 0x80);

  // Gets the color #FF008000
  static Color4 get green => Color4.fromBytes(0x00, 0x80, 0x00);

  // Gets the color #FFADFF2F
  static Color4 get greenYellow => Color4.fromBytes(0xAD, 0xFF, 0x2F);

  // Gets the color #FFF0FFF0
  static Color4 get honeydew => Color4.fromBytes(0xF0, 0xFF, 0xF0);

  // Gets the color #FFFF69B4
  static Color4 get hotPink => Color4.fromBytes(0xFF, 0x69, 0xB4);

  // Gets the color #FFCD5C5C
  static Color4 get indianRed => Color4.fromBytes(0xCD, 0x5C, 0x5C);

  // Gets the color #FF4B0082
  static Color4 get indigo => Color4.fromBytes(0x4B, 0x00, 0x82);

  // Gets the color #FFFFFFF0
  static Color4 get ivory => Color4.fromBytes(0xFF, 0xFF, 0xF0);

  // Gets the color #FFF0E68C
  static Color4 get khaki => Color4.fromBytes(0xF0, 0xE6, 0x8C);

  // Gets the color #FFE6E6FA
  static Color4 get lavender => Color4.fromBytes(0xE6, 0xE6, 0xFA);

  // Gets the color #FFFFF0F5
  static Color4 get lavenderBlush => Color4.fromBytes(0xFF, 0xF0, 0xF5);

  // Gets the color #FF7CFC00
  static Color4 get lawnGreen => Color4.fromBytes(0x7C, 0xFC, 0x00);

  // Gets the color #FFFFFACD
  static Color4 get lemonChiffon => Color4.fromBytes(0xFF, 0xFA, 0xCD);

  // Gets the color #FFADD8E6
  static Color4 get lightBlue => Color4.fromBytes(0xAD, 0xD8, 0xE6);

  // Gets the color #FFF08080
  static Color4 get lightCoral => Color4.fromBytes(0xF0, 0x80, 0x80);

  // Gets the color #FFE0FFFF
  static Color4 get lightCyan => Color4.fromBytes(0xE0, 0xFF, 0xFF);

  // Gets the color #FFFAFAD2
  static Color4 get lightGoldenrodYellow => Color4.fromBytes(0xFA, 0xFA, 0xD2);

  // Gets the color #FFD3D3D3
  static Color4 get lightGray => Color4.fromBytes(0xD3, 0xD3, 0xD3);

  // Gets the color #FF90EE90
  static Color4 get lightGreen => Color4.fromBytes(0x90, 0xEE, 0x90);

  // Gets the color #FFFFB6C1
  static Color4 get lightPink => Color4.fromBytes(0xFF, 0xB6, 0xC1);

  // Gets the color #FFFFA07A
  static Color4 get lightSalmon => Color4.fromBytes(0xFF, 0xA0, 0x7A);

  // Gets the color #FF20B2AA
  static Color4 get lightSeaGreen => Color4.fromBytes(0x20, 0xB2, 0xAA);

  // Gets the color #FF87CEFA
  static Color4 get lightSkyBlue => Color4.fromBytes(0x87, 0xCE, 0xFA);

  // Gets the color #FF778899
  static Color4 get lightSlateGray => Color4.fromBytes(0x77, 0x88, 0x99);

  // Gets the color #FFB0C4DE
  static Color4 get lightSteelBlue => Color4.fromBytes(0xB0, 0xC4, 0xDE);

  // Gets the color #FFFFFFE0
  static Color4 get lightYellow => Color4.fromBytes(0xFF, 0xFF, 0xE0);

  // Gets the color #FF00FF00
  static Color4 get lime => Color4.fromBytes(0x00, 0xFF, 0x00);

  // Gets the color #FF32CD32
  static Color4 get limeGreen => Color4.fromBytes(0x32, 0xCD, 0x32);

  // Gets the color #FFFAF0E6
  static Color4 get linen => Color4.fromBytes(0xFA, 0xF0, 0xE6);

  // Gets the color #FFFF00FF
  static Color4 get magenta => Color4.fromBytes(0xFF, 0x00, 0xFF);

  // Gets the color #FF800000
  static Color4 get maroon => Color4.fromBytes(0x80, 0x00, 0x00);

  // Gets the color #FF66CDAA
  static Color4 get mediumAquamarine => Color4.fromBytes(0x66, 0xCD, 0xAA);

  // Gets the color #FF0000CD
  static Color4 get mediumBlue => Color4.fromBytes(0x00, 0x00, 0xCD);

  // Gets the color #FFBA55D3
  static Color4 get mediumOrchid => Color4.fromBytes(0xBA, 0x55, 0xD3);

  // Gets the color #FF9370DB
  static Color4 get mediumPurple => Color4.fromBytes(0x93, 0x70, 0xDB);

  // Gets the color #FF3CB371
  static Color4 get mediumSeaGreen => Color4.fromBytes(0x3C, 0xB3, 0x71);

  // Gets the color #FF7B68EE
  static Color4 get mediumSlateBlue => Color4.fromBytes(0x7B, 0x68, 0xEE);

  // Gets the color #FF00FA9A
  static Color4 get mediumSpringGreen => Color4.fromBytes(0x00, 0xFA, 0x9A);

  // Gets the color #FF48D1CC
  static Color4 get mediumTurquoise => Color4.fromBytes(0x48, 0xD1, 0xCC);

  // Gets the color #FFC71585
  static Color4 get mediumVioletRed => Color4.fromBytes(0xC7, 0x15, 0x85);

  // Gets the color #FF191970
  static Color4 get midnightBlue => Color4.fromBytes(0x19, 0x19, 0x70);

  // Gets the color #FFF5FFFA
  static Color4 get mintCream => Color4.fromBytes(0xF5, 0xFF, 0xFA);

  // Gets the color #FFFFE4E1
  static Color4 get mistyRose => Color4.fromBytes(0xFF, 0xE4, 0xE1);

  // Gets the color #FFFFE4B5
  static Color4 get moccasin => Color4.fromBytes(0xFF, 0xE4, 0xB5);

  // Gets the color #FFFFDEAD
  static Color4 get navajoWhite => Color4.fromBytes(0xFF, 0xDE, 0xAD);

  // Gets the color #FF000080
  static Color4 get navy => Color4.fromBytes(0x00, 0x00, 0x80);

  // Gets the color #FFFDF5E6
  static Color4 get oldLace => Color4.fromBytes(0xFD, 0xF5, 0xE6);

  // Gets the color #FF808000
  static Color4 get olive => Color4.fromBytes(0x80, 0x80, 0x00);

  // Gets the color #FF6B8E23
  static Color4 get oliveDrab => Color4.fromBytes(0x6B, 0x8E, 0x23);

  // Gets the color #FFFFA500
  static Color4 get orange => Color4.fromBytes(0xFF, 0xA5, 0x00);

  // Gets the color #FFFF4500
  static Color4 get orangeRed => Color4.fromBytes(0xFF, 0x45, 0x00);

  // Gets the color #FFDA70D6
  static Color4 get orchid => Color4.fromBytes(0xDA, 0x70, 0xD6);

  // Gets the color #FFEEE8AA
  static Color4 get paleGoldenrod => Color4.fromBytes(0xEE, 0xE8, 0xAA);

  // Gets the color #FF98FB98
  static Color4 get paleGreen => Color4.fromBytes(0x98, 0xFB, 0x98);

  // Gets the color #FFAFEEEE
  static Color4 get paleTurquoise => Color4.fromBytes(0xAF, 0xEE, 0xEE);

  // Gets the color #FFDB7093
  static Color4 get paleVioletRed => Color4.fromBytes(0xDB, 0x70, 0x93);

  // Gets the color #FFFFEFD5
  static Color4 get papayaWhip => Color4.fromBytes(0xFF, 0xEF, 0xD5);

  // Gets the color #FFFFDAB9
  static Color4 get peachPuff => Color4.fromBytes(0xFF, 0xDA, 0xB9);

  // Gets the color #FFCD853F
  static Color4 get peru => Color4.fromBytes(0xCD, 0x85, 0x3F);

  // Gets the color #FFFFC0CB
  static Color4 get pink => Color4.fromBytes(0xFF, 0xC0, 0xCB);

  // Gets the color #FFDDA0DD
  static Color4 get plum => Color4.fromBytes(0xDD, 0xA0, 0xDD);

  // Gets the color #FFB0E0E6
  static Color4 get powderBlue => Color4.fromBytes(0xB0, 0xE0, 0xE6);

  // Gets the color #FF800080
  static Color4 get purple => Color4.fromBytes(0x80, 0x00, 0x80);

  // Gets the color #FFFF0000
  static Color4 get red => Color4.fromBytes(0xFF, 0x00, 0x00);

  // Gets the color #FFBC8F8F
  static Color4 get rosyBrown => Color4.fromBytes(0xBC, 0x8F, 0x8F);

  // Gets the color #FF4169E1
  static Color4 get royalBlue => Color4.fromBytes(0x41, 0x69, 0xE1);

  // Gets the color #FF8B4513
  static Color4 get saddleBrown => Color4.fromBytes(0x8B, 0x45, 0x13);

  // Gets the color #FFFA8072
  static Color4 get salmon => Color4.fromBytes(0xFA, 0x80, 0x72);

  // Gets the color #FFF4A460
  static Color4 get sandyBrown => Color4.fromBytes(0xF4, 0xA4, 0x60);

  // Gets the color #FF2E8B57
  static Color4 get seaGreen => Color4.fromBytes(0x2E, 0x8B, 0x57);

  // Gets the color #FFFFF5EE
  static Color4 get seaShell => Color4.fromBytes(0xFF, 0xF5, 0xEE);

  // Gets the color #FFA0522D
  static Color4 get sienna => Color4.fromBytes(0xA0, 0x52, 0x2D);

  // Gets the color #FFC0C0C0
  static Color4 get silver => Color4.fromBytes(0xC0, 0xC0, 0xC0);

  // Gets the color #FF87CEEB
  static Color4 get skyBlue => Color4.fromBytes(0x87, 0xCE, 0xEB);

  // Gets the color #FF6A5ACD
  static Color4 get slateBlue => Color4.fromBytes(0x6A, 0x5A, 0xCD);

  // Gets the color #FF708090
  static Color4 get slateGray => Color4.fromBytes(0x70, 0x80, 0x90);

  // Gets the color #FFFFFAFA
  static Color4 get snow => Color4.fromBytes(0xFF, 0xFA, 0xFA);

  // Gets the color #FF00FF7F
  static Color4 get springGreen => Color4.fromBytes(0x00, 0xFF, 0x7F);

  // Gets the color #FF4682B4
  static Color4 get steelBlue => Color4.fromBytes(0x46, 0x82, 0xB4);

  // Gets the color #FFD2B48C
  static Color4 get tan => Color4.fromBytes(0xD2, 0xB4, 0x8C);

  // Gets the color #FF008080
  static Color4 get teal => Color4.fromBytes(0x00, 0x80, 0x80);

  // Gets the color #FFD8BFD8
  static Color4 get thistle => Color4.fromBytes(0xD8, 0xBF, 0xD8);

  // Gets the color #FFFF6347
  static Color4 get tomato => Color4.fromBytes(0xFF, 0x63, 0x47);

  // Gets the color #00000000
  static Color4 get transparent => Color4.fromBytes(0x00, 0x00, 0x00, 0x00);

  // Gets the color #FF40E0D0
  static Color4 get turquoise => Color4.fromBytes(0x40, 0xE0, 0xD0);

  // Gets the color #FFEE82EE
  static Color4 get violet => Color4.fromBytes(0xEE, 0x82, 0xEE);

  // Gets the color #FFF5DEB3
  static Color4 get wheat => Color4.fromBytes(0xF5, 0xDE, 0xB3);

  // Gets the color #FFFFFFFF
  static Color4 get white => Color4.fromBytes(0xFF, 0xFF, 0xFF);

  // Gets the color #FFF5F5F5
  static Color4 get whiteSmoke => Color4.fromBytes(0xF5, 0xF5, 0xF5);

  // Gets the color #FFFFFF00
  static Color4 get yellow => Color4.fromBytes(0xFF, 0xFF, 0x00);

  // Gets the color #FF9ACD32
  static Color4 get yellowGreen => Color4.fromBytes(0x9A, 0xCD, 0x32);
}
