import 'dart:html';

/// Animation is used for running a set of timed events.
class Animation {
  /// Indicates the animation is running.
  bool _running;

  /// Indicates the animation should restart after the last shifter finishes.
  final bool _loop;

  /// Is the start time for the animation.
  DateTime _start;

  /// The set of shifters for the animation.
  final List<Shifter> _shifters;

  /// Creates a new animation which optionally loops.
  Animation({
    final bool loop = false,
  })  : this._running = false,
        this._loop = loop,
        this._start = DateTime.now(),
        this._shifters = [];

  /// Adds a shifter to this animation.
  Shifter add({
    final int delay = 0,
    final int duration = 1000,
    final bool init = false,
    final Smoother? easing,
  }) {
    final shifter = Shifter(
      delay: delay,
      duration: duration,
      init: init,
      easing: easing,
    );
    this._shifters.add(shifter);
    return shifter;
  }

  /// Indicates if the animation is running or not.
  bool get running => this._running;

  /// Resets the shifters and animation.
  void _reset() {
    this._start = this._now;
    for (final shifter in this._shifters) {
      shifter._reset();
    }
  }

  /// Starts the animation running.
  /// If the animation is already running then this has no effect.
  void start() {
    if (!this._running) {
      this._running = true;
      this._reset();
      this._requestUpdate();
    }
  }

  /// Stops the animation running.
  /// If the animation is not running this has no effect.
  void stop() {
    if (this._running) {
      this._running = false;
    }
  }

  /// Gets the current time.
  DateTime get _now => DateTime.now();

  /// Requests an update at the next browser animation frame event.
  void _requestUpdate() => window.requestAnimationFrame(this._update);

  /// Performs an update of the animation.
  void _update(
    final num num,
  ) {
    if (this._running) {
      final offset = this._now.difference(this._start).inMilliseconds;
      bool done = true;
      for (final shifter in this._shifters) {
        done = shifter._update(offset) && done;
      }
      if (done) {
        if (this._loop) {
          this._reset();
        } else {
          this._running = false;
          return;
        }
      }
      this._requestUpdate();
    }
  }
}

/// Cubic Bezier smoother class.
class CubicBezier extends Polynomial {
  /// The Cubic Bezier function from P0=0, P1, P2, and P3=1.
  static double _curve(
    final double p1,
    final double p2,
    final double t,
  ) {
    final t2 = t * t;
    final t3 = t2 * t;
    final i = 1.0 - t;
    final i2 = i * i;
    return 3.0 * p1 * i2 * t + 3.0 * p2 * i * t2 + t3;
  }

  /// Internal smoother for creating constant cubic Bezier.
  CubicBezier(
    final double dx1,
    final double dy1,
    final double dx2,
    final double dy2, [
    final int samples = 20,
  ]) : super(
          (final t) => _curve(
            clamp(dx1),
            clamp(dx2),
            t,
          ),
          (final t) => _curve(
            dy1,
            dy2,
            t,
          ),
          samples,
        );
}

/// A class for smoothing movements.
class Handler implements Smoother {
  /// The handler function to call on smooth.
  final double Function(double t) _handle;

  /// Privatize the constructor for the smoother.
  Handler(
    final this._handle,
  );

  /// [smooth] changes a linear 0.0 to 1.0 into different order of movements.
  /// This should return 0.0 for 0.0 and be a continuous function up to 1.0 which should return 1.0.
  @override
  double smooth(
    final double t,
  ) =>
      this._handle(t);
}

/// Linear interpolation between the start and goal.
/// The given [i] must be between 0.0 and 1.0.
double Lerp(
  final double start,
  final double goal,
  final double i,
) =>
    start * (1.0 - i) + goal * i;

/// A double modifier for setting a value for a mover.
class _Modifier {
  /// The initial value to start from.
  final double start;

  /// The final value to end at.
  final double goal;

  /// The handler to set the value with.
  final void Function(double value) _setHndl;

  /// Creates a new double modifier.
  _Modifier(
    final this.start,
    final this.goal,
    final this._setHndl,
  );

  /// Updates the value for the mover.
  void _update(
    final double i,
  ) =>
      this._setHndl(Lerp(start, goal, i));
}

/// A smoother which is initialized with a polynomial.
class Polynomial implements Smoother {
  /// The precalculated data for the polynomial.
  List<double> _data = [];

  /// Finds a specific t value for a given x value and the t to x function.
  /// This reverses the given function so that a x to y can be figured out.
  static double _find(
    final double Function(double double) xFunc,
    final double x,
    double tmin,
    double tmax,
  ) {
    double t = x;
    while (tmin < tmax) {
      final xp = xFunc(t);
      if ((xp - x).abs() < 1.0e-9) {
        return t;
      } else {
        if (x > xp) {
          // ignore: parameter_assignments
          tmin = t;
        } else {
          // ignore: parameter_assignments
          tmax = t;
        }
        t = (tmax + tmin) / 2;
      }
    }
    return t;
  }

  /// Creates a new polynomial for the two given functions.
  /// This precalculates the polynomial with the given number of sample locations.
  /// The more the samples, the slower the precalculations take and more memory used.
  /// The less samples, the rougher the polynomial result data is.
  Polynomial(
    final double Function(double double) xFunc,
    final double Function(double double) yFunc, [
    final int samples = 20,
  ]) {
    final yValues = List<double>.filled(samples, 0.0);
    double t = 0.0;
    for (int i = 0; i < samples; i++) {
      final x = i / samples;
      t = _find(xFunc, x, t, 1.0);
      yValues[i] = yFunc(t);
    }
    this._data = yValues;
  }

  /// Linear interpolates between the precalculated polynomial data.
  @override
  double smooth(
    final double x,
  ) {
    final len = this._data.length;
    final f = x * len;
    final i = f.floor();
    if (i < 0) {
      return 0.0;
    } else if (i >= len) {
      return 1.0;
    } else {
      final p0 = this._data[i];
      final p1 = (i == len - 1) ? 1.0 : this._data[i + 1];
      final r = f - i;
      return p0 * (1.0 - r) + p1 * r;
    }
  }
}

/// Shifter for changing several values from start values to another in a specific duration.
class Shifter {
  /// Set of values to be modified.
  List<_Modifier> _mods;

  /// The milliseconds to delay before starting shifting.
  final int _delay;

  /// The milliseconds this shifter is run.
  final int _duration;

  /// Indicates if the value should initialize during the initial delay.
  final bool _init;

  /// The smoother effects the rate of change
  final Smoother _smoother;

  /// Indicates the shifter is done.
  bool _done;

  /// Indicates the shifter has been initialized.
  bool _inited;

  /// Creates a new shifter for the given duration and optional smoother.
  factory Shifter({
    int delay = 0,
    int duration = 1000,
    final bool init = false,
    Smoother? easing,
  }) {
    if (delay < 0) delay = 0;
    if (duration < 1) duration = 1;
    easing ??= Smoothers.linear;
    return Shifter._(
      delay,
      duration,
      init,
      easing,
    );
  }

  /// Constructs a shifter with the final information set.
  Shifter._(
    final this._delay,
    final this._duration,
    final this._init,
    final this._smoother,
  )   : this._mods = [],
        this._done = false,
        this._inited = false;

  /// Updates the shifter to the new time.
  /// The given offset it the milliseconds since the animation started.
  /// Returns true if done, false to keep going.
  bool _update(
    final int offset,
  ) {
    if (this._done) {
      return true;
    } else {
      final t = (offset - this._delay) / this._duration;
      if ((!this._init || this._inited) && (t < 0.0)) {
        return false;
      } else {
        final y = clamp(this._smoother.smooth(clamp(t)));
        for (final mod in this._mods) {
          mod._update(y);
        }
        this._done = t >= 1.0;
        this._inited = true;
        return this._done;
      }
    }
  }

  /// Resets the done flag.
  void _reset() => this._done = this._inited = false;

  /// Adds a value that will be moved.
  void move(
    final double start,
    final double end,
    final void Function(double value) hndl,
  ) =>
      this._mods.add(
            _Modifier(start, end, hndl),
          );
}

/// A class for smoothing movements.
abstract class Smoother {
  /// [smooth] changes a linear 0.0 to 1.0 into different order of movements.
  /// This should return 0.0 for 0.0 and be a continuous function up to 1.0 which should return 1.0.
  double smooth(
    final double t,
  );
}

/// Clamps the given value to between 0.0 and 1.0 inclusively.
double clamp(
  final double val,
) {
  if (val < 0.0) {
    return 0.0;
  } else {
    if (val > 1.0) {
      return 1.0;
    } else {
      return val;
    }
  }
}

/// Set of predefined smoothers.
abstract class Smoothers {
  /// Default linear interpretation.
  static Smoother get linear => _linearLazy ??= Handler((t) => t);
  static Smoother? _linearLazy;

  /// Stays still until the very end then snaps to the stop location.
  static Smoother get snapEnd => _snapEndLazy ??= Handler((t) => t > 0.99 ? 1.0 : 0.0);
  static Smoother? _snapEndLazy;

  /// Stays still until half-way then snaps to the stop location.
  static Smoother get snapHalf => _snapHalfLazy ??= Handler((t) => t >= 0.5 ? 1.0 : 0.0);
  static Smoother? _snapHalfLazy;

  /// Stays snaps stop location at the start.
  static Smoother get snapStart => _snapStartLazy ??= Handler((t) => t < 0.01 ? 0.0 : 1.0);
  static Smoother? _snapStartLazy;

  /// Starts out slow and ends linear movement.
  static Smoother get easeInSine => _easeInSineLazy ??= CubicBezier(0.47, 0.0, 0.745, 0.715);
  static Smoother? _easeInSineLazy;

  /// Starts out linear and ends slow movement.
  static Smoother get easeOutSine => _easeOutSineLazy ??= CubicBezier(0.39, 0.575, 0.565, 1.0);
  static Smoother? _easeOutSineLazy;

  /// Start out slow and ends slow with a linear middle movement.
  static Smoother get easeInOutSine => _easeInOutSineLazy ??= CubicBezier(0.445, 0.05, 0.55, 0.95);
  static Smoother? _easeInOutSineLazy;

  /// Start out slow and ends a little faster.
  static Smoother get easeInQuad => _easeInQuadLazy ??= CubicBezier(0.55, 0.085, 0.68, 0.53);
  static Smoother? _easeInQuadLazy;

  /// Start out a little faster and ends slow.
  static Smoother get easeOutQuad => _easeOutQuadLazy ??= CubicBezier(0.25, 0.46, 0.45, 0.94);
  static Smoother? _easeOutQuadLazy;

  /// Start out slow and ends slow with a little faster in the middle.
  static Smoother get easeInOutQuad => _easeInOutQuadLazy ??= CubicBezier(0.645, 0.045, 0.355, 1.0);
  static Smoother? _easeInOutQuadLazy;

  /// Start out slow and ends a slightly faster.
  static Smoother get easeInQuart => _easeInQuartLazy ??= CubicBezier(0.895, 0.03, 0.685, 0.22);
  static Smoother? _easeInQuartLazy;

  /// Start out a slightly faster and ends slow.
  static Smoother get easeOutQuart => _easeOutQuartLazy ??= CubicBezier(0.165, 0.84, 0.44, 1.0);
  static Smoother? _easeOutQuartLazy;

  /// Start out slow and ends slow with a slightly faster in the middle.
  static Smoother get easeInOutQuart => _easeInOutQuartLazy ??= CubicBezier(0.77, 0.0, 0.175, 1.0);
  static Smoother? _easeInOutQuartLazy;

  /// Start out very slow and ends a fast.
  static Smoother get easeInQuint => _easeInQuintLazy ??= CubicBezier(0.755, 0.05, 0.855, 0.06);
  static Smoother? _easeInQuintLazy;

  /// Start out a very fast and ends slow.
  static Smoother get easeOutQuint => _easeOutQuintLazy ??= CubicBezier(0.23, 1.0, 0.32, 1.0);
  static Smoother? _easeOutQuintLazy;

  /// Start out very slow and ends slow with a fast in the middle.
  static Smoother get easeInOutQuint => _easeInOutQuintLazy ??= CubicBezier(0.86, 0.0, 0.07, 1.0);
  static Smoother? _easeInOutQuintLazy;

  /// Start out very slow and ends a fast.
  static Smoother get easeInExpo => _easeInExpoLazy ??= CubicBezier(0.95, 0.05, 0.795, 0.035);
  static Smoother? _easeInExpoLazy;

  /// Start out a very fast and ends slow.
  static Smoother get easeOutExpo => _easeOutExpoLazy ??= CubicBezier(0.19, 1.0, 0.22, 1.0);
  static Smoother? _easeOutExpoLazy;

  /// Start out very slow and ends slow with a fast in the middle.
  static Smoother get easeInOutExpo => _easeInOutExpoLazy ??= CubicBezier(1.0, 0.0, 0.0, 1.0);
  static Smoother? _easeInOutExpoLazy;

  /// Start out a little slow and ends a fast.
  static Smoother get easeInCirc => _easeInCircLazy ??= CubicBezier(0.6, 0.04, 0.98, 0.335);
  static Smoother? _easeInCircLazy;

  /// Start out a very fast and a little slow.
  static Smoother get easeOutCirc => _easeOutCircLazy ??= CubicBezier(0.075, 0.82, 0.165, 1.0);
  static Smoother? _easeOutCircLazy;

  /// Start out a little slow and ends a little slow with a fast in the middle.
  static Smoother get easeInOutCirc => _easeInOutCircLazy ??= CubicBezier(0.785, 0.135, 0.15, 0.86);
  static Smoother? _easeInOutCircLazy;

  /// Start out going a little the wrong way and ends a fast.
  static Smoother get easeInBack => _easeInBackLazy ??= CubicBezier(0.6, -0.28, 0.735, 0.045);
  static Smoother? _easeInBackLazy;

  /// Start out a very fast and over shoots a little.
  static Smoother get easeOutBack => _easeOutBackLazy ??= CubicBezier(0.175, 0.885, 0.32, 1.275);
  static Smoother? _easeOutBackLazy;

  /// Start out going a little the wrong way and then over shoots a little with a fast in the middle.
  static Smoother get easeInOutBack => _easeInOutBackLazy ??= CubicBezier(0.68, -0.55, 0.265, 1.55);
  static Smoother? _easeInOutBackLazy;
}
