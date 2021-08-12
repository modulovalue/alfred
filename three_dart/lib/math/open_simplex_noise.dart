library open_simplex_noise;

/// This generates smoothly-changing deterministic random values in
/// 2 or 3 dimensions. This can be used for procedurally generated textures,
/// shapes, or terrain.
///
/// OpenSimplex noise is a Dart implementation of Kurt Spencer's patent-free
/// alternative to Perlin and Simplex noise.
///
/// For more information: http://uniblock.tumblr.com/post/97868843242/noise
/// or https://gist.github.com/KdotJPG/b1270127455a94ac5d19
class OpenSimplexNoise {
  final List<int> _perm;

  // Initializes using a permutation array generated from a seed.
  // The seed is 53-bits when Dart has been transpiled into JS.
  factory OpenSimplexNoise([int seed = 0]) {
    final perm = List<int>.filled(256, 0);
    final source = List<int>.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      source[i] = i;
    }

    // The following parsers may seem silly but these parses allow 64-bit integers to be initialized
    // when running in an environment which allows 64-bit integers, such as the console.
    // In a 64-bit environment this Open Simplex Noise gets the same results as any other.
    // However, in JS there are only 53-bit integers and the dart compiler complains
    // about this value being used, so the `int.parse` will return a valid 59-bit number which
    // will result in a functional Open Simplex Noise but with different results from others.
    final seedMul = int.parse("6364136223846793005");
    final seedAdd = int.parse("1442695040888963407");
    seed = (seed * seedMul + seedAdd).toSigned(64);
    seed = (seed * seedMul + seedAdd).toSigned(64);
    seed = (seed * seedMul + seedAdd).toSigned(64);
    for (int i = 255; i >= 0; i--) {
      seed = (seed * seedMul + seedAdd).toSigned(64);
      int r = (seed + 31) % (i + 1);
      if (r < 0) r += i + 1;
      perm[i] = source[r];
      source[r] = source[i];
    }
    return OpenSimplexNoise.fromPerm(perm);
  }

  // Initializes using the given permutation array.
  OpenSimplexNoise.fromPerm(this._perm);

  // Calculates 2D OpenSimplex Noise for the given 2D point.
  double eval2D(double x, double y) {
    return Eval2D(_perm, Point2(x, y)).eval();
  }

  // Calculates 3D OpenSimplex Noise for the given 3D point.
  double eval3D(double x, double y, double z) {
    return Eval3D(_perm, Point3(x, y, z)).eval();
  }

  // Calculates 4D OpenSimplex Noise for the given 4D point.
  double eval4D(double x, double y, double z, double w) {
    return Eval4D(_perm, Point4(x, y, z, w)).eval();
  }
}

/// Open Simplex for 4D Noise
class Eval4D {
  /// (1 / sqrt(4 + 1) - 1) / 4;
  static const double _stretch = -0.138196601125011;

  /// (sqrt(4 + 1) - 1) / 4;
  static const double _squish = 0.309016994374947;

  /// Normalizing scalar to the result
  static const double _norm = 30.0;

  /// Gradients for 4D. They approximate the directions to the
  /// vertices of a disprismatotesseractihexadecachoron from the center,
  /// skewed so that the tetrahedral and cubic facets can be inscribed inside
  /// spheres of the same radius.
  static final List<Point4> _gradients = [
    Point4(3.0, 1.0, 1.0, 1.0),
    Point4(1.0, 3.0, 1.0, 1.0),
    Point4(1.0, 1.0, 3.0, 1.0),
    Point4(1.0, 1.0, 1.0, 3.0),
    Point4(-3.0, 1.0, 1.0, 1.0),
    Point4(-1.0, 3.0, 1.0, 1.0),
    Point4(-1.0, 1.0, 3.0, 1.0),
    Point4(-1.0, 1.0, 1.0, 3.0),
    Point4(3.0, -1.0, 1.0, 1.0),
    Point4(1.0, -3.0, 1.0, 1.0),
    Point4(1.0, -1.0, 3.0, 1.0),
    Point4(1.0, -1.0, 1.0, 3.0),
    Point4(-3.0, -1.0, 1.0, 1.0),
    Point4(-1.0, -3.0, 1.0, 1.0),
    Point4(-1.0, -1.0, 3.0, 1.0),
    Point4(-1.0, -1.0, 1.0, 3.0),
    Point4(3.0, 1.0, -1.0, 1.0),
    Point4(1.0, 3.0, -1.0, 1.0),
    Point4(1.0, 1.0, -3.0, 1.0),
    Point4(1.0, 1.0, -1.0, 3.0),
    Point4(-3.0, 1.0, -1.0, 1.0),
    Point4(-1.0, 3.0, -1.0, 1.0),
    Point4(-1.0, 1.0, -3.0, 1.0),
    Point4(-1.0, 1.0, -1.0, 3.0),
    Point4(3.0, -1.0, -1.0, 1.0),
    Point4(1.0, -3.0, -1.0, 1.0),
    Point4(1.0, -1.0, -3.0, 1.0),
    Point4(1.0, -1.0, -1.0, 3.0),
    Point4(-3.0, -1.0, -1.0, 1.0),
    Point4(-1.0, -3.0, -1.0, 1.0),
    Point4(-1.0, -1.0, -3.0, 1.0),
    Point4(-1.0, -1.0, -1.0, 3.0),
    Point4(3.0, 1.0, 1.0, -1.0),
    Point4(1.0, 3.0, 1.0, -1.0),
    Point4(1.0, 1.0, 3.0, -1.0),
    Point4(1.0, 1.0, 1.0, -3.0),
    Point4(-3.0, 1.0, 1.0, -1.0),
    Point4(-1.0, 3.0, 1.0, -1.0),
    Point4(-1.0, 1.0, 3.0, -1.0),
    Point4(-1.0, 1.0, 1.0, -3.0),
    Point4(3.0, -1.0, 1.0, -1.0),
    Point4(1.0, -3.0, 1.0, -1.0),
    Point4(1.0, -1.0, 3.0, -1.0),
    Point4(1.0, -1.0, 1.0, -3.0),
    Point4(-3.0, -1.0, 1.0, -1.0),
    Point4(-1.0, -3.0, 1.0, -1.0),
    Point4(-1.0, -1.0, 3.0, -1.0),
    Point4(-1.0, -1.0, 1.0, -3.0),
    Point4(3.0, 1.0, -1.0, -1.0),
    Point4(1.0, 3.0, -1.0, -1.0),
    Point4(1.0, 1.0, -3.0, -1.0),
    Point4(1.0, 1.0, -1.0, -3.0),
    Point4(-3.0, 1.0, -1.0, -1.0),
    Point4(-1.0, 3.0, -1.0, -1.0),
    Point4(-1.0, 1.0, -3.0, -1.0),
    Point4(-1.0, 1.0, -1.0, -3.0),
    Point4(3.0, -1.0, -1.0, -1.0),
    Point4(1.0, -3.0, -1.0, -1.0),
    Point4(1.0, -1.0, -3.0, -1.0),
    Point4(1.0, -1.0, -1.0, -3.0),
    Point4(-3.0, -1.0, -1.0, -1.0),
    Point4(-1.0, -3.0, -1.0, -1.0),
    Point4(-1.0, -1.0, -3.0, -1.0),
    Point4(-1.0, -1.0, -1.0, -3.0)];

  /// Deltas for 2D contributions to the value.
  static final List<Point4> _deltas = [
    Point4(1.0, -1.0, 0.0, 0.0),
    Point4(1.0, 0.0, -1.0, 0.0),
    Point4(1.0, 0.0, 0.0, -1.0),
    Point4(-1.0, 1.0, 0.0, 0.0),
    Point4(0.0, 1.0, -1.0, 0.0),
    Point4(0.0, 1.0, 0.0, -1.0),
    Point4(-1.0, 0.0, 1.0, 0.0),
    Point4(0.0, -1.0, 1.0, 0.0),
    Point4(0.0, 0.0, 1.0, -1.0),
    Point4(-1.0, 0.0, 0.0, 1.0),
    Point4(0.0, -1.0, 0.0, 1.0),
    Point4(0.0, 0.0, -1.0, 1.0),
    Point4(1.0, 1.0, 0.0, 0.0),
    Point4(1.0, 1.0, -1.0, 0.0),
    Point4(1.0, 1.0, 0.0, -1.0),
    Point4(1.0, 0.0, 1.0, 0.0),
    Point4(1.0, -1.0, 1.0, 0.0),
    Point4(1.0, 0.0, 1.0, -1.0),
    Point4(0.0, 1.0, 1.0, 0.0),
    Point4(-1.0, 1.0, 1.0, 0.0),
    Point4(0.0, 1.0, 1.0, -1.0),
    Point4(1.0, 0.0, 0.0, 1.0),
    Point4(1.0, -1.0, 0.0, 1.0),
    Point4(1.0, 0.0, -1.0, 1.0),
    Point4(0.0, 1.0, 0.0, 1.0),
    Point4(-1.0, 1.0, 0.0, 1.0),
    Point4(0.0, 1.0, -1.0, 1.0),
    Point4(0.0, 0.0, 1.0, 1.0),
    Point4(-1.0, 0.0, 1.0, 1.0),
    Point4(0.0, -1.0, 1.0, 1.0),
    Point4(0.0, 0.0, 0.0, 0.0),
    Point4(1.0, 0.0, 0.0, 0.0),
    Point4(0.0, 1.0, 0.0, 0.0),
    Point4(0.0, 0.0, 1.0, 0.0),
    Point4(0.0, 0.0, 0.0, 1.0),
    Point4(2.0, 1.0, 1.0, 0.0),
    Point4(1.0, 2.0, 1.0, 0.0),
    Point4(1.0, 1.0, 2.0, 0.0),
    Point4(2.0, 1.0, 0.0, 1.0),
    Point4(1.0, 2.0, 0.0, 1.0),
    Point4(1.0, 1.0, 0.0, 2.0),
    Point4(2.0, 0.0, 1.0, 1.0),
    Point4(1.0, 0.0, 2.0, 1.0),
    Point4(1.0, 0.0, 1.0, 2.0),
    Point4(0.0, 2.0, 1.0, 1.0),
    Point4(0.0, 1.0, 2.0, 1.0),
    Point4(0.0, 1.0, 1.0, 2.0),
    Point4(2.0, 1.0, 0.0, 0.0),
    Point4(1.0, 2.0, 0.0, 0.0),
    Point4(2.0, 0.0, 1.0, 0.0),
    Point4(1.0, 0.0, 2.0, 0.0),
    Point4(0.0, 2.0, 1.0, 0.0),
    Point4(0.0, 1.0, 2.0, 0.0),
    Point4(2.0, 0.0, 0.0, 1.0),
    Point4(1.0, 0.0, 0.0, 2.0),
    Point4(0.0, 2.0, 0.0, 1.0),
    Point4(0.0, 1.0, 0.0, 2.0),
    Point4(0.0, 0.0, 2.0, 1.0),
    Point4(0.0, 0.0, 1.0, 2.0),
    Point4(1.0, 1.0, 1.0, 0.0),
    Point4(1.0, 1.0, 0.0, 1.0),
    Point4(1.0, 0.0, 1.0, 1.0),
    Point4(0.0, 1.0, 1.0, 1.0),
    Point4(1.0, 1.0, 1.0, 1.0),
    Point4(1.0, 1.0, 1.0, -1.0),
    Point4(1.0, 1.0, -1.0, 1.0),
    Point4(1.0, -1.0, 1.0, 1.0),
    Point4(-1.0, 1.0, 1.0, 1.0),
    Point4(2.0, 0.0, 0.0, 0.0),
    Point4(0.0, 2.0, 0.0, 0.0),
    Point4(0.0, 0.0, 2.0, 0.0),
    Point4(0.0, 0.0, 0.0, 2.0)];

  /// Predefined point with each componenent equal to the [_stretch] value.
  static final Point4 _pntStretch = Point4(_stretch, _stretch, _stretch, _stretch);

  /// Predefined point with each componenent equal to the [_squish] value.
  static final Point4 _pntSquish = Point4(_squish, _squish, _squish, _squish);

  /// Noise permutation set.
  final List<int> _perm;

  /// The simplectic honeycomb coordinates of rhombohedron (stretched cube) super-cell origin.
  final Point4 _grid;

  /// The position relative to the origin point.
  final Point4 _origin;

  /// The simplectic honeycomb coordinates relative to rhombohedral origin.
  final Point4 _ins;

  /// The accumulator of the noise value.
  double _value = 0.0;

  /// Creates a new evaluator for 3D noise and calcuate the initial values.
  factory Eval4D(List<int> perm, Point4 input) {
    // Place input coordinates on simplectic honeycomb.
    final stretch = input + _pntStretch * input.sum;
    final grid = stretch.floor;
    // Skew out to get actual coordinates of rhombohedron origin.
    final squish = grid + _pntSquish * grid.sum;
    final ins = stretch - grid;
    final origin = input - squish;
    return Eval4D._(perm, grid, origin, ins);
  }

  /// Contructs a new evaluator for 3D noise.
  Eval4D._(this._perm, this._grid, this._origin, this._ins);

  /// Extrapolates the offset grid point to the permutation of noise.
  double _extrapolate(Point4 grid, Point4 delta) {
    final index = (grid.gradientIndex(_perm) & 0xFC) >> 2;
    final pnt = _gradients[index];
    return pnt.dot(delta);
  }

  /// Contributes a point into the noise value if the attenuation is positive.
  void _contribute(int index) {
    final delta = _deltas[index];
    final shifted = _origin - delta - _pntSquish * delta.sum;
    final attn = shifted.attn;
    if (attn > 0.0) {
      final attn2 = attn * attn;
      _value += attn2 * attn2 * _extrapolate(_grid + delta, shifted);
    }
  }

  /// Calculate 4D OpenSimplex noise value.
  double eval() {
    // Sum those together to get a value that determines the region.
    final inSum = _ins.sum;
    if (inSum <= 1) {
      // We're inside the pentachoron (4-Simplex) at (0,0,0,0)
      //
      // Determine which two of (0,0,0,1), (0,0,1,0), (0,1,0,0), (1,0,0,0) are closest.
      int aPoint = 0x01;
      int bPoint = 0x02;
      double aScore = _ins.x;
      double bScore = _ins.y;
      if (aScore >= bScore && _ins.z > bScore) {
        bScore = _ins.z;
        bPoint = 0x04;
      } else if (aScore < bScore && _ins.z > aScore) {
        aScore = _ins.z;
        aPoint = 0x04;
      }
      if (aScore >= bScore && _ins.w > bScore) {
        bScore = _ins.w;
        bPoint = 0x08;
      } else if (aScore < bScore && _ins.w > aScore) {
        aScore = _ins.w;
        aPoint = 0x08;
      }
      // Now we determine the three lattice points not part of the pentachoron that may contribute.
      // This depends on the closest two pentachoron vertices, including (0, 0, 0, 0)
      final uins = 1.0 - inSum;
      if (uins > aScore || uins > bScore) {
        // (0, 0, 0, 0) is one of the closest two pentachoron vertices.
        // Our other closest vertex is the closest out of a and b.
        final closest = (bScore > aScore) ? bPoint : aPoint;
        if (closest == 1) {
          _contribute(0);
          _contribute(1);
          _contribute(2);
        } else if (closest == 2) {
          _contribute(3);
          _contribute(4);
          _contribute(5);
        } else if (closest == 4) {
          _contribute(6);
          _contribute(7);
          _contribute(8);
        } else {
          // closest == 8
          _contribute(9);
          _contribute(10);
          _contribute(11);
        }
      } else {
        // (0, 0, 0, 0) is not one of the closest two pentachoron vertices.
        // Our three extra vertices are determined by the closest two.
        final closest = aPoint | bPoint;
        if (closest == 3) {
          _contribute(12);
          _contribute(13);
          _contribute(14);
        } else if (closest == 5) {
          _contribute(15);
          _contribute(16);
          _contribute(17);
        } else if (closest == 6) {
          _contribute(18);
          _contribute(19);
          _contribute(20);
        } else if (closest == 9) {
          _contribute(21);
          _contribute(22);
          _contribute(23);
        } else if (closest == 10) {
          _contribute(24);
          _contribute(25);
          _contribute(26);
        } else {
          // closest == 12
          _contribute(27);
          _contribute(28);
          _contribute(29);
        }
      }

      _contribute(30);
      _contribute(31);
      _contribute(32);
      _contribute(33);
      _contribute(34);
    } else if (inSum >= 3.0) {
      // We're inside the pentachoron (4-Simplex) at (1, 1, 1, 1)
      // Determine which two of (1, 1, 1, 0), (1, 1, 0, 1), (1, 0, 1, 1), (0, 1, 1, 1) are closest.
      int aPoint = 0x0E;
      int bPoint = 0x0D;
      double aScore = _ins.x;
      double bScore = _ins.y;
      if (aScore <= bScore && _ins.z < bScore) {
        bScore = _ins.z;
        bPoint = 0x0B;
      } else if (aScore > bScore && _ins.z < aScore) {
        aScore = _ins.z;
        aPoint = 0x0B;
      }
      if (aScore <= bScore && _ins.w < bScore) {
        bScore = _ins.w;
        bPoint = 0x07;
      } else if (aScore > bScore && _ins.w < aScore) {
        aScore = _ins.w;
        aPoint = 0x07;
      }

      // Now we determine the three lattice points not part of the pentachoron that may contribute.
      // This depends on the closest two pentachoron vertices, including (0, 0, 0, 0)
      final uins = 4.0 - inSum;
      if (uins < aScore || uins < bScore) {
        // (1, 1, 1, 1) is one of the closest two pentachoron vertices.
        // Our other closest vertex is the closest out of a and b.
        final closest = (bScore < aScore) ? bPoint : aPoint;
        if (closest == 7) {
          _contribute(35);
          _contribute(36);
          _contribute(37);
        } else if (closest == 11) {
          _contribute(38);
          _contribute(39);
          _contribute(40);
        } else if (closest == 13) {
          _contribute(41);
          _contribute(42);
          _contribute(43);
        } else {
          // closest == 14
          _contribute(44);
          _contribute(45);
          _contribute(46);
        }
      } else {
        // (1,1,1,1) is not one of the closest two pentachoron vertices.
        // Our three extra vertices are determined by the closest two.
        final closest = aPoint & bPoint;
        if (closest == 3) {
          _contribute(12);
          _contribute(47);
          _contribute(48);
        } else if (closest == 5) {
          _contribute(15);
          _contribute(49);
          _contribute(50);
        } else if (closest == 6) {
          _contribute(18);
          _contribute(51);
          _contribute(52);
        } else if (closest == 9) {
          _contribute(21);
          _contribute(53);
          _contribute(54);
        } else if (closest == 10) {
          _contribute(24);
          _contribute(55);
          _contribute(56);
        } else {
          // closest == 12
          _contribute(27);
          _contribute(57);
          _contribute(58);
        }
      }

      _contribute(59);
      _contribute(60);
      _contribute(61);
      _contribute(62);
      _contribute(63);
    } else if (inSum <= 2.0) {
      // We're inside the first dispentachoron (Rectified 4-Simplex)
      double aScore, bScore;
      int aPoint, bPoint;
      bool aIsBiggerSide = true;
      bool bIsBiggerSide = true;
      // Decide between (1, 1, 0, 0) and (0, 0, 1, 1)
      if (_ins.x + _ins.y > _ins.z + _ins.w) {
        aScore = _ins.x + _ins.y;
        aPoint = 0x03;
      } else {
        aScore = _ins.z + _ins.w;
        aPoint = 0x0C;
      }
      // Decide between (1, 0, 1, 0) and (0, 1, 0, 1)
      if (_ins.x + _ins.z > _ins.y + _ins.w) {
        bScore = _ins.x + _ins.z;
        bPoint = 0x05;
      } else {
        bScore = _ins.y + _ins.w;
        bPoint = 0x0A;
      }
      // Closer between (1, 0, 0, 1) and (0, 1, 1, 0) will replace the further of a and b, if closer.
      if (_ins.x + _ins.w > _ins.y + _ins.z) {
        final score = _ins.x + _ins.w;
        if (aScore >= bScore && score > bScore) {
          bScore = score;
          bPoint = 0x09;
        } else if (aScore < bScore && score > aScore) {
          aScore = score;
          aPoint = 0x09;
        }
      } else {
        final score = _ins.y + _ins.z;
        if (aScore >= bScore && score > bScore) {
          bScore = score;
          bPoint = 0x06;
        } else if (aScore < bScore && score > aScore) {
          aScore = score;
          aPoint = 0x06;
        }
      }
      // Decide if (1, 0, 0, 0) is closer.
      final p1 = 2.0 - inSum + _ins.x;
      if (aScore >= bScore && p1 > bScore) {
        bScore = p1;
        bPoint = 0x01;
        bIsBiggerSide = false;
      } else if (aScore < bScore && p1 > aScore) {
        aScore = p1;
        aPoint = 0x01;
        aIsBiggerSide = false;
      }
      // Decide if (0, 1, 0, 0) is closer.
      final p2 = 2.0 - inSum + _ins.y;
      if (aScore >= bScore && p2 > bScore) {
        bScore = p2;
        bPoint = 0x02;
        bIsBiggerSide = false;
      } else if (aScore < bScore && p2 > aScore) {
        aScore = p2;
        aPoint = 0x02;
        aIsBiggerSide = false;
      }
      // Decide if (0, 0, 1, 0) is closer.
      final p3 = 2.0 - inSum + _ins.z;
      if (aScore >= bScore && p3 > bScore) {
        bScore = p3;
        bPoint = 0x04;
        bIsBiggerSide = false;
      } else if (aScore < bScore && p3 > aScore) {
        aScore = p3;
        aPoint = 0x04;
        aIsBiggerSide = false;
      }
      // Decide if (0, 0, 0, 1) is closer.
      final p4 = 2.0 - inSum + _ins.w;
      if (aScore >= bScore && p4 > bScore) {
        bScore = p4;
        bPoint = 0x08;
        bIsBiggerSide = false;
      } else if (aScore < bScore && p4 > aScore) {
        aScore = p4;
        aPoint = 0x08;
        aIsBiggerSide = false;
      }
      // Where each of the two closest points are determines how the extra three
      // vertices are calculated.
      if (aIsBiggerSide == bIsBiggerSide) {
        if (aIsBiggerSide) {
          // Both closest points on the bigger side
          final c1 = aPoint | bPoint;
          if (c1 == 7) {
            _contribute(59);
            _contribute(64);
          } else if (c1 == 11) {
            _contribute(60);
            _contribute(65);
          } else if (c1 == 13) {
            _contribute(61);
            _contribute(66);
          } else {
            // c1 == 14
            _contribute(62);
            _contribute(67);
          }
          // One combination is a permutation of (0, 0, 0, 2) based on c2
          final c2 = aPoint & bPoint;
          if (c2 == 1) {
            _contribute(68);
          } else if (c2 == 2) {
            _contribute(69);
          } else if (c2 == 4) {
            _contribute(70);
          } else {
            _contribute(71);
          }
        } else {
          // Both closest points on the smaller side
          // One of the two extra points is (0, 0, 0, 0)
          _contribute(30);
          // Other two points are based on the omitted axes.
          final closest = aPoint | bPoint;
          if (closest == 3) {
            _contribute(13);
            _contribute(14);
          } else if (closest == 5) {
            _contribute(16);
            _contribute(17);
          } else if (closest == 6) {
            _contribute(19);
            _contribute(20);
          } else if (closest == 9) {
            _contribute(22);
            _contribute(23);
          } else if (closest == 10) {
            _contribute(25);
            _contribute(26);
          } else {
            // closest == 12
            _contribute(28);
            _contribute(29);
          }
        }
      } else {
        // One point on each "side"
        int c1, c2;
        if (aIsBiggerSide) {
          c1 = aPoint;
          c2 = bPoint;
        } else {
          c1 = bPoint;
          c2 = aPoint;
        }

        // Two contributions are the bigger-sided point with each 0 replaced with -1.
        if (c1 == 3) {
          _contribute(13);
          _contribute(14);
        } else if (c1 == 5) {
          _contribute(16);
          _contribute(17);
        } else if (c1 == 6) {
          _contribute(19);
          _contribute(20);
        } else if (c1 == 9) {
          _contribute(22);
          _contribute(23);
        } else if (c1 == 10) {
          _contribute(25);
          _contribute(26);
        } else if (c1 == 12) {
          _contribute(28);
          _contribute(29);
        }

        // One contribution is a permutation of (0, 0, 0, 2) based on the smaller-sided point
        if (c2 == 1) {
          _contribute(68);
        } else if (c2 == 2) {
          _contribute(69);
        } else if (c2 == 4) {
          _contribute(70);
        } else {
          _contribute(71);
        }
      }

      _contribute(31);
      _contribute(32);
      _contribute(33);
      _contribute(34);
      _contribute(12);
      _contribute(15);
      _contribute(21);
      _contribute(18);
      _contribute(24);
      _contribute(27);
    } else {
      // We're inside the second dispentachoron (Rectified 4-Simplex)
      double aScore, bScore;
      int aPoint, bPoint;
      bool aIsBiggerSide = true;
      bool bIsBiggerSide = true;
      // Decide between (0,0,1,1) and (1,1,0,0)
      if (_ins.x + _ins.y < _ins.z + _ins.w) {
        aScore = _ins.x + _ins.y;
        aPoint = 0x0C;
      } else {
        aScore = _ins.z + _ins.w;
        aPoint = 0x03;
      }
      // Decide between (0,1,0,1) and (1,0,1,0)
      if (_ins.x + _ins.z < _ins.y + _ins.w) {
        bScore = _ins.x + _ins.z;
        bPoint = 0x0A;
      } else {
        bScore = _ins.y + _ins.w;
        bPoint = 0x05;
      }
      // Closer between (0,1,1,0) and (1,0,0,1) will replace the further of a and b,
      // if closer.
      if (_ins.x + _ins.w < _ins.y + _ins.z) {
        final score = _ins.x + _ins.w;
        if (aScore <= bScore && score < bScore) {
          bScore = score;
          bPoint = 0x06;
        } else if (aScore > bScore && score < aScore) {
          aScore = score;
          aPoint = 0x06;
        }
      } else {
        final score = _ins.y + _ins.z;
        if (aScore <= bScore && score < bScore) {
          bScore = score;
          bPoint = 0x09;
        } else if (aScore > bScore && score < aScore) {
          aScore = score;
          aPoint = 0x09;
        }
      }
      // Decide if (0, 1, 1, 1) is closer.
      final p1 = 3.0 - inSum + _ins.x;
      if (aScore <= bScore && p1 < bScore) {
        bScore = p1;
        bPoint = 0x0E;
        bIsBiggerSide = false;
      } else if (aScore > bScore && p1 < aScore) {
        aScore = p1;
        aPoint = 0x0E;
        aIsBiggerSide = false;
      }
      // Decide if (1, 0, 1, 1) is closer.
      final p2 = 3.0 - inSum + _ins.y;
      if (aScore <= bScore && p2 < bScore) {
        bScore = p2;
        bPoint = 0x0D;
        bIsBiggerSide = false;
      } else if (aScore > bScore && p2 < aScore) {
        aScore = p2;
        aPoint = 0x0D;
        aIsBiggerSide = false;
      }
      // Decide if (1, 1, 0, 1) is closer.
      final p3 = 3.0 - inSum + _ins.z;
      if (aScore <= bScore && p3 < bScore) {
        bScore = p3;
        bPoint = 0x0B;
        bIsBiggerSide = false;
      } else if (aScore > bScore && p3 < aScore) {
        aScore = p3;
        aPoint = 0x0B;
        aIsBiggerSide = false;
      }
      // Decide if (1, 1, 1, 0) is closer.
      final p4 = 3.0 - inSum + _ins.w;
      if (aScore <= bScore && p4 < bScore) {
        bScore = p4;
        bPoint = 0x07;
        bIsBiggerSide = false;
      } else if (aScore > bScore && p4 < aScore) {
        aScore = p4;
        aPoint = 0x07;
        aIsBiggerSide = false;
      }
      // Where each of the two closest points are determines how the extra three
      // vertices are calculated.
      if (aIsBiggerSide == bIsBiggerSide) {
        if (aIsBiggerSide) {
          // Both closest points on the bigger side
          //
          // Two contributions are permutations of (0, 0, 0, 1) and (0, 0, 0, 2) based on c1
          final c1 = aPoint & bPoint;
          if (c1 == 1) {
            _contribute(31);
            _contribute(68);
          } else if (c1 == 2) {
            _contribute(32);
            _contribute(69);
          } else if (c1 == 4) {
            _contribute(33);
            _contribute(70);
          } else {
            // c2 == 8
            _contribute(34);
            _contribute(71);
          }
          // One contribution is a permutation of (1, 1, 1, -1) based on c2
          final c2 = aPoint | bPoint;
          if ((c2 & 0x01) == 0) {
            _contribute(67);
          } else if ((c2 & 0x02) == 0) {
            _contribute(66);
          } else if ((c2 & 0x04) == 0) {
            _contribute(65);
          } else {
            // (c2 & 0x08) == 0
            _contribute(64);
          }
        } else {
          // Both closest points on the smaller side
          // One of the two extra points is (1, 1, 1, 1)
          _contribute(63);
          // Other two points are based on the shared axes.
          final closest = aPoint & bPoint;
          if (closest == 3) {
            _contribute(47);
            _contribute(48);
          } else if (closest == 5) {
            _contribute(49);
            _contribute(50);
          } else if (closest == 6) {
            _contribute(51);
            _contribute(52);
          } else if (closest == 9) {
            _contribute(53);
            _contribute(54);
          } else if (closest == 10) {
            _contribute(55);
            _contribute(56);
          } else {
            // closest == 12
            _contribute(57);
            _contribute(58);
          }
        }
      } else {
        // One point on each "side"
        int c1, c2;
        if (aIsBiggerSide) {
          c1 = aPoint;
          c2 = bPoint;
        } else {
          c1 = bPoint;
          c2 = aPoint;
        }

        // Two contributions are the bigger-sided point with each 1 replaced with 2.
        if (c1 == 3) {
          _contribute(47);
          _contribute(48);
        } else if (c1 == 5) {
          _contribute(49);
          _contribute(50);
        } else if (c1 == 6) {
          _contribute(51);
          _contribute(52);
        } else if (c1 == 9) {
          _contribute(53);
          _contribute(54);
        } else if (c1 == 10) {
          _contribute(55);
          _contribute(56);
        } else if (c1 == 12) {
          _contribute(57);
          _contribute(58);
        }

        // One contribution is a permutation of (1, 1, 1, -1) based on the smaller-sided point
        if (c2 == 7) {
          _contribute(64);
        } else if (c2 == 11) {
          _contribute(65);
        } else if (c2 == 13) {
          _contribute(66);
        } else {
          _contribute(67);
        }
      }

      _contribute(59);
      _contribute(60);
      _contribute(61);
      _contribute(62);
      _contribute(12);
      _contribute(15);
      _contribute(21);
      _contribute(18);
      _contribute(24);
      _contribute(27);
    }

    return _value / _norm;
  }
}

/// An immutable 4D point for working with the mathmatics for eval 4D noise.
class Point4 {
  /// The x component of the point.
  final double x;

  /// The y component of the point.
  final double y;

  /// The z component of the point.
  final double z;

  /// The w component of the point.
  final double w;

  /// Contructs a new 4D point.
  Point4(this.x, this.y, this.z, this.w);

  /// Creates a point where each component is the floor value.
  Point4 get floor => Point4(x.floorToDouble(), y.floorToDouble(), z.floorToDouble(), w.floorToDouble());

  /// Gets the sum of the components.
  double get sum => x + y + z + w;

  /// Gets the attenuation factor of the point assuming the point is offset from an origin.
  double get attn => 2.0 - (x * x) - (y * y) - (z * z) - (w * w);

  /// Gets the dot product between these two points.
  double dot(Point4 other) => x * other.x + y * other.y + z * other.z + w * other.w;

  /// Determines the gradient index this point represents using the given noise permutation.
  int gradientIndex(List<int> perm) {
    int index = x.toInt();
    index = perm[index & 0xFF] + y.toInt();
    index = perm[index & 0xFF] + z.toInt();
    index = perm[index & 0xFF] + w.toInt();
    return perm[index & 0xFF];
  }

  /// Creates a point where each component is the sum of the given two points' components.
  Point4 operator +(Point4 other) => Point4(x + other.x, y + other.y, z + other.z, w + other.w);

  /// Creates a point where each component is the difference of the given two points' components.
  Point4 operator -(Point4 other) => Point4(x - other.x, y - other.y, z - other.z, w - other.w);

  /// Creates a point which is the scaled point of the given point's components and scalar.
  Point4 operator *(double scalar) => Point4(x * scalar, y * scalar, z * scalar, w * scalar);

  /// Gets a human readable string for the point.
  @override
  String toString() => "$x, $y, $z, $w";
}
/// Open Simplex for 3D Noise
class Eval3D {
  /// (1 / sqrt(3 + 1) - 1) / 3
  static const double _stretch = -1.0 / 6.0;

  /// (sqrt(3 + 1) - 1) / 3
  static const double _squish = 1.0 / 3.0;

  /// Normalizing scalar to the result
  static const double _norm = 103.0;

  /// Gradients for 3D. They approximate the directions to the
  /// vertices of a rhombicuboctahedron from the center, skewed so
  /// that the triangular and square facets can be inscribed inside
  /// circles of the same radius.
  static final List<Point3> _gradients = [
    Point3(-11.0,   4.0,   4.0),
    Point3( -4.0,  11.0,   4.0),
    Point3( -4.0,   4.0,  11.0),
    Point3( 11.0,   4.0,   4.0),
    Point3(  4.0,  11.0,   4.0),
    Point3(  4.0,   4.0,  11.0),
    Point3(-11.0,  -4.0,   4.0),
    Point3( -4.0, -11.0,   4.0),
    Point3( -4.0,  -4.0,  11.0),
    Point3( 11.0,  -4.0,   4.0),
    Point3(  4.0, -11.0,   4.0),
    Point3(  4.0,  -4.0,  11.0),
    Point3(-11.0,   4.0,  -4.0),
    Point3( -4.0,  11.0,  -4.0),
    Point3( -4.0,   4.0, -11.0),
    Point3( 11.0,   4.0,  -4.0),
    Point3(  4.0,  11.0,  -4.0),
    Point3(  4.0,   4.0, -11.0),
    Point3(-11.0,  -4.0,  -4.0),
    Point3( -4.0, -11.0,  -4.0),
    Point3( -4.0,  -4.0, -11.0),
    Point3( 11.0,  -4.0,  -4.0),
    Point3(  4.0, -11.0,  -4.0),
    Point3(  4.0,  -4.0, -11.0)];

  /// Deltas for 2D contributions to the value.
  static final List<Point3> _deltas = [
    Point3( 1.0, -1.0,  0.0),
    Point3( 1.0,  0.0, -1.0),
    Point3(-1.0,  1.0,  0.0),
    Point3( 0.0,  1.0, -1.0),
    Point3(-1.0,  0.0,  1.0),
    Point3( 0.0, -1.0,  1.0),
    Point3( 1.0,  1.0,  0.0),
    Point3( 1.0,  1.0, -1.0),
    Point3( 1.0,  0.0,  1.0),
    Point3( 1.0, -1.0,  1.0),
    Point3( 0.0,  1.0,  1.0),
    Point3(-1.0,  1.0,  1.0),
    Point3( 0.0,  0.0,  0.0),
    Point3( 1.0,  0.0,  0.0),
    Point3( 0.0,  1.0,  0.0),
    Point3( 0.0,  0.0,  1.0),
    Point3( 2.0,  1.0,  0.0),
    Point3( 1.0,  2.0,  0.0),
    Point3( 2.0,  0.0,  1.0),
    Point3( 1.0,  0.0,  2.0),
    Point3( 0.0,  2.0,  1.0),
    Point3( 0.0,  1.0,  2.0),
    Point3( 2.0,  0.0,  0.0),
    Point3( 0.0,  2.0,  0.0),
    Point3( 0.0,  0.0,  2.0),
    Point3( 1.0,  1.0,  1.0)];

  /// Predefined point with each componenent equal to the [_stretch] value.
  static final Point3 _pntStretch = Point3(_stretch, _stretch, _stretch);

  /// Predefined point with each componenent equal to the [_squish] value.
  static final Point3 _pntSquish = Point3(_squish, _squish, _squish);

  /// Noise permutation set.
  final List<int> _perm;

  /// The simplectic honeycomb coordinates of rhombohedron (stretched cube) super-cell origin.
  final Point3 _grid;

  /// The position relative to the origin point.
  final Point3 _origin;

  /// The simplectic honeycomb coordinates relative to rhombohedral origin.
  final Point3 _ins;

  /// The accumulator of the noise value.
  double _value = 0.0;

  /// Creates a new evaluator for 3D noise and calcuate the initial values.
  factory Eval3D(List<int> perm, Point3 input) {
    // Place input coordinates on simplectic honeycomb.
    final stretch = input + _pntStretch * input.sum;
    final grid = stretch.floor;
    // Skew out to get actual coordinates of rhombohedron origin.
    final squish = grid + _pntSquish * grid.sum;
    final ins = stretch - grid;
    final origin = input - squish;
    return Eval3D._(perm, grid, origin, ins);
  }

  /// Contructs a new evaluator for 3D noise.
  Eval3D._(this._perm, this._grid, this._origin, this._ins);

  /// Extrapolates the offset grid point to the permutation of noise.
  double _extrapolate(Point3 grid, Point3 delta) {
    final index = grid.gradientIndex(_perm) % _gradients.length;
    final pnt = _gradients[index];
    return pnt.dot(delta);
  }

  /// Contributes a point into the noise value if the attenuation is positive.
  void _contribute(int index) {
    final delta = _deltas[index];
    final shifted = _origin - delta - _pntSquish * delta.sum;
    final attn = shifted.attn;
    if (attn > 0.0) {
      final attn2 = attn * attn;
      _value += attn2 * attn2 * _extrapolate(_grid + delta, shifted);
    }
  }

  /// Compute 3D OpenSimplex noise value.
  double eval() {
    // Sum those together to get a value that determines the region.
    final inSum = _ins.sum;
    if (inSum <= 1.0) {
      // Inside the tetrahedron (3-Simplex) at (0, 0, 0)
      //
      // Determine which two of (0, 0, 1), (0, 1, 0), (1, 0, 0) are closest.
      double aScore = _ins.x;
      double bScore = _ins.y;
      int aPoint = 0x01;
      int bPoint = 0x02;
      if (_ins.x >= _ins.y && _ins.z > _ins.y) {
        bScore = _ins.z;
        bPoint = 0x04;
      } else if (_ins.x < _ins.y && _ins.z > _ins.x) {
        aScore = _ins.z;
        aPoint = 0x04;
      }
      // Now we determine the two lattice points not part of the tetrahedron that may contribute.
      // This depends on the closest two tetrahedral vertices, including (0, 0, 0)
      final wins = 1 - inSum;
      if (wins > aScore || wins > bScore) {
        // (0, 0, 0) is one of the closest two tetrahedral vertices.
        // Our other closest vertex is the closest out of a and b.
        final closest = (bScore > aScore) ? bPoint : aPoint;
        if (closest == 1) {
          _contribute(0);
          _contribute(1);
        } else if (closest == 2) {
          _contribute(2);
          _contribute(3);
        } else {
          // closest == 4
          _contribute(4);
          _contribute(5);
        }
      } else {
        // (0, 0, 0) is not one of the closest two tetrahedral vertices.
        // Our two extra vertices are determined by the closest two.
        final closest = aPoint | bPoint;
        if (closest == 3) {
          _contribute(6);
          _contribute(7);
        } else if (closest == 5) {
          _contribute(8);
          _contribute(9);
        } else {
          // closest == 6
          _contribute(10);
          _contribute(11);
        }
      }

      _contribute(12);
      _contribute(13);
      _contribute(14);
      _contribute(15);
    } else if (inSum >= 2.0) {
      // Inside the tetrahedron (3-Simplex) at (1, 1, 1)
      //
      // Determine which two tetrahedral vertices are the closest, out of (1, 1, 0), (1, 0, 1), (0, 1, 1) but not (1, 1, 1).
      int aPoint = 0x06;
      double aScore = _ins.x;
      int bPoint = 0x05;
      double bScore = _ins.y;
      if (aScore <= bScore && _ins.z < bScore) {
        bScore = _ins.z;
        bPoint = 0x03;
      } else if (aScore > bScore && _ins.z < aScore) {
        aScore = _ins.z;
        aPoint = 0x03;
      }
      // Now we determine the two lattice points not part of the tetrahedron that may contribute.
      // This depends on the closest two tetrahedral vertices, including (1, 1, 1)
      final wins = 3.0 - inSum;
      if (wins < aScore || wins < bScore) {
        // (1, 1, 1) is one of the closest two tetrahedral vertices.
        // Our other closest vertex is the closest out of a and b.
        final closest = bScore < aScore ? bPoint : aPoint;
        if (closest == 3) {
          _contribute(16);
          _contribute(17);
        } else if (closest == 5) {
          _contribute(18);
          _contribute(19);
        } else {
          // closest == 6
          _contribute(20);
          _contribute(21);
        }
      } else {
        // (1, 1, 1) is not one of the closest two tetrahedral vertices.
        // Our two extra vertices are determined by the closest two.
        final closest = aPoint & bPoint;
        if (closest == 1) {
          _contribute(13);
          _contribute(22);
        } else if (closest == 2) {
          _contribute(14);
          _contribute(23);
        } else {
          // closest == 4
          _contribute(15);
          _contribute(24);
        }
      }

      _contribute(6);
      _contribute(8);
      _contribute(10);
      _contribute(25);
    } else {
      // Inside the octahedron (Rectified 3-Simplex) in between.
      double aScore, bScore;
      int aPoint, bPoint;
      bool aIsFurtherSide, bIsFurtherSide;
      // Decide between point (0, 0, 1) and (1, 1, 0) as closest
      final p1 = _ins.x + _ins.y;
      if (p1 > 1.0) {
        aScore = p1 - 1.0;
        aPoint = 0x03;
        aIsFurtherSide = true;
      } else {
        aScore = 1.0 - p1;
        aPoint = 0x04;
        aIsFurtherSide = false;
      }
      // Decide between point (0, 1, 0) and (1, 0, 1) as closest
      final p2 = _ins.x + _ins.z;
      if (p2 > 1.0) {
        bScore = p2 - 1.0;
        bPoint = 0x05;
        bIsFurtherSide = true;
      } else {
        bScore = 1.0 - p2;
        bPoint = 0x02;
        bIsFurtherSide = false;
      }
      // The closest out of the two (1, 0, 0) and (0, 1, 1) will replace
      // the furthest out of the two decided above, if closer.
      final p3 = _ins.y + _ins.z;
      if (p3 > 1.0) {
        final score = p3 - 1.0;
        if (aScore <= bScore && aScore < score) {
          aScore = score;
          aPoint = 0x06;
          aIsFurtherSide = true;
        } else if (aScore > bScore && bScore < score) {
          bScore = score;
          bPoint = 0x06;
          bIsFurtherSide = true;
        }
      } else {
        final score = 1.0 - p3;
        if (aScore <= bScore && aScore < score) {
          aScore = score;
          aPoint = 0x01;
          aIsFurtherSide = false;
        } else if (aScore > bScore && bScore < score) {
          bScore = score;
          bPoint = 0x01;
          bIsFurtherSide = false;
        }
      }

      // Where each of the two closest points are determines how the extra two vertices are calculated.
      if (aIsFurtherSide == bIsFurtherSide) {
        if (aIsFurtherSide) {
          // Both closest points on (1, 1, 1) side
          //
          // One of the two extra points is (1, 1, 1)
          _contribute(25);
          // Other extra point is based on the shared axis.
          final closest = aPoint & bPoint;
          if (closest == 1) {
            _contribute(22);
          } else if (closest == 2) {
            _contribute(23);
          } else {
            _contribute(24);
          }
        } else {
          // Both closest points on (0, 0, 0) side
          //
          // One of the two extra points is (0, 0, 0)
          _contribute(12);
          // Other extra point is based on the omitted axis.
          final closest = aPoint | bPoint;
          if (closest == 3) {
            _contribute(7);
          } else if (closest == 5) {
            _contribute(9);
          } else {
            _contribute(11);
          }
        }
      } else {
        // One point on (0, 0, 0) side, one point on (1, 1, 1) side
        int c1, c2;
        if (aIsFurtherSide) {
          c1 = aPoint;
          c2 = bPoint;
        } else {
          c1 = bPoint;
          c2 = aPoint;
        }

        // One contribution is a permutation of (1, 1, -1)
        if (c1 == 3) {
          _contribute(7);
        } else if (c1 == 5) {
          _contribute(9);
        } else {
          _contribute(11);
        }

        // One contribution is a permutation of (0, 0, 2)
        if (c2 == 1) {
          _contribute(22);
        } else if (c2 == 2) {
          _contribute(23);
        } else {
          _contribute(24);
        }
      }

      _contribute(13);
      _contribute(14);
      _contribute(15);
      _contribute(6);
      _contribute(8);
      _contribute(10);
    }
    return _value / _norm;
  }
}

/// An immutable 3D point for working with the mathmatics for eval 3D noise.
class Point3 {
  /// The x component of the point.
  final double x;

  /// The y component of the point.
  final double y;

  /// The z component of the point.
  final double z;

  /// Contructs a new 3D point.
  Point3(this.x, this.y, this.z);

  /// Creates a point where each component is the floor value.
  Point3 get floor => Point3(x.floorToDouble(), y.floorToDouble(), z.floorToDouble());

  /// Gets the sum of the components.
  double get sum => x + y + z;

  /// Gets the attenuation factor of the point assuming the point is offset from an origin.
  double get attn => 2.0 - (x * x) - (y * y) - (z * z);

  /// Gets the dot product between these two points.
  double dot(Point3 other) => x * other.x + y * other.y + z * other.z;

  /// Determines the gradient index this point represents using the given noise permutation.
  int gradientIndex(List<int> perm) {
    int index = x.toInt();
    index = perm[index & 0xFF] + y.toInt();
    index = perm[index & 0xFF] + z.toInt();
    return perm[index & 0xFF];
  }

  /// Creates a point where each component is the sum of the given two points' components.
  Point3 operator +(Point3 other) => Point3(x + other.x, y + other.y, z + other.z);

  /// Creates a point where each component is the difference of the given two points' components.
  Point3 operator -(Point3 other) => Point3(x - other.x, y - other.y, z - other.z);

  /// Creates a point which is the scaled point of the given point's components and scalar.
  Point3 operator *(double scalar) => Point3(x * scalar, y * scalar, z * scalar);

  /// Gets a human readable string for the point.
  @override
  String toString() => "$x, $y, $z";
}

/// Open Simplex for 2D Noise
class Eval2D {
  /// (1 / sqrt(2 + 1) - 1) / 2
  static const double _stretch = -0.211324865405187;

  /// (sqrt(2 + 1) - 1) / 2
  static const double _squish = 0.366025403784439;

  /// Normalizing scalar to the result
  static const double _norm = 47.0;

  /// Gradients for 2D. They approximate the directions to the
  /// vertices of an octagon from the center.
  static final List<Point2> _gradients = [
    Point2( 5.0,  2.0),
    Point2( 2.0,  5.0),
    Point2(-5.0,  2.0),
    Point2(-2.0,  5.0),
    Point2( 5.0, -2.0),
    Point2( 2.0, -5.0),
    Point2(-5.0, -2.0),
    Point2(-2.0, -5.0)];

  /// Deltas for 2D contributions to the value.
  static final List<Point2> _deltas = [
    Point2( 1.0,  0.0),
    Point2( 0.0,  1.0),
    Point2( 1.0, -1.0),
    Point2(-1.0,  1.0),
    Point2( 1.0,  1.0),
    Point2( 0.0,  0.0),
    Point2( 2.0,  0.0),
    Point2( 0.0,  2.0)];

  /// Predefined point with each componenent equal to the [_stretch] value.
  static final Point2 _pntStretch = Point2(_stretch, _stretch);

  /// Predefined point with each componenent equal to the [_squish] value.
  static final Point2 _pntSquish = Point2(_squish, _squish);

  /// Noise permutation set.
  final List<int> _perm;

  /// The grid coordinates of rhombus (stretched square) super-cell origin.
  final Point2 _grid;

  /// The position relative to the origin point.
  final Point2 _origin;

  /// The grid coordinates relative to rhombus origin.
  final Point2 _ins;

  /// The accumulator of the noise value.
  double _value = 0.0;

  /// Creates a new evaluator for 2D noise and calcuate the initial values.
  factory Eval2D(List<int> perm, Point2 input) {
    // stretch input coordinates onto grid.
    final stretch = input + _pntStretch * input.sum;
    final grid = stretch.floor;
    // Skew out to get actual coordinates of rhombus origin.
    final squashed = grid + _pntSquish * grid.sum;
    final ins = stretch - grid;
    final origin = input - squashed;
    return Eval2D._(perm, grid, origin, ins);
  }

  /// Contructs a new evaluator for 2D noise.
  Eval2D._(this._perm, this._grid, this._origin, this._ins);

  /// Extrapolates the offset grid point to the permutation of noise.
  double _extrapolate(Point2 grid, Point2 delta) {
    final index = (grid.gradientIndex(_perm) & 0x0E) >> 1;
    final pnt = _gradients[index];
    return pnt.dot(delta);
  }

  /// Contributes a point into the noise value if the attenuation is positive.
  void _contribute(int index) {
    final delta = _deltas[index];
    final shifted = _origin - delta - _pntSquish * delta.sum;
    final attn = shifted.attn;
    if (attn > 0.0) {
      final attn2 = attn * attn;
      _value += attn2 * attn2 * _extrapolate(_grid + delta, shifted);
    }
  }

  /// Compute 2D OpenSimplex noise value.
  double eval() {
    _contribute(0);
    _contribute(1);
    // Sum those together to get a value that determines the region.
    final inSum = _ins.sum;
    if (inSum <= 1.0) {
      // Inside the triangle (2-Simplex) at (0, 0)
      final zins = 1.0 - inSum;
      if (zins > _ins.x || zins > _ins.y) {
        // (0, 0) is one of the closest two triangular vertices
        if (_ins.x > _ins.y) {
          _contribute(2);
        } else {
          _contribute(3);
        }
      } else {
        // (1, 0) and (0, 1) are the closest two vertices.
        _contribute(4);
      }
      _contribute(5);
    } else {
      // Inside the triangle (2-Simplex) at (1, 1)
      final zins = 2.0 - inSum;
      if (zins < _ins.x || zins < _ins.y) {
        // (0, 0) is one of the closest two triangular vertices
        if (_ins.x > _ins.y) {
          _contribute(6);
        } else {
          _contribute(7);
        }
      } else {
        // (1, 0) and (0, 1) are the closest two vertices.
        _contribute(5);
      }
      _contribute(4);
    }
    return _value / _norm;
  }
}

/// An immutable 2D point for working with the mathmatics for eval 2D noise.
class Point2 {
  /// The x component of the point.
  final double x;

  /// The y component of the point.
  final double y;

  /// Contructs a new 2D point.
  Point2(this.x, this.y);

  /// Creates a point where each component is the floor value.
  Point2 get floor => Point2(x.floorToDouble(), y.floorToDouble());

  /// Gets the sum of the components.
  double get sum => x + y;

  /// Gets the attenuation factor of the point assuming the point is offset from an origin.
  double get attn => 2.0 - (x * x) - (y * y);

  /// Gets the dot product between these two points.
  double dot(Point2 other) => x * other.x + y * other.y;

  /// Determines the gradient index this point represents using the given noise permutation.
  int gradientIndex(List<int> perm) {
    int index = x.toInt();
    index = perm[index & 0xFF] + y.toInt();
    return perm[index & 0xFF];
  }

  /// Creates a point where each component is the sum of the given two points' components.
  Point2 operator +(Point2 other) => Point2(x + other.x, y + other.y);

  /// Creates a point where each component is the difference of the given two points' components.
  Point2 operator -(Point2 other) => Point2(x - other.x, y - other.y);

  /// Creates a point which is the scaled point of the given point's components and scalar.
  Point2 operator *(double scalar) => Point2(x * scalar, y * scalar);

  /// Gets a human readable string for the point.
  @override
  String toString() => "$x, $y";
}
