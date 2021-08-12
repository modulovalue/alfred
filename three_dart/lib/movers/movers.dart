// Movers are a set of tools which produce a matrix defining a movement.
// Movers are used to move objects, cameras, lights, etc.
// around in a scene.
import 'dart:math' as math;

import '../collections/collections.dart';
import '../core/core.dart';
import '../events/events.dart';
import '../input/input.dart';
import '../math/math.dart' as math2;

/// The interface for a moving an object.
abstract class Mover extends Changeable {
  /// Updates the mover to the new matrix for the given object.
  ///
  /// This updates with the given [state] and the [obj] this mover is attached to.
  /// The returned matrix is applied to the object.
  math2.Matrix4 update(RenderState state, Movable? obj);
}

/// The interface for an object which can be moved.
abstract class Movable {
  /// The mover to mover this object.
  Mover? get mover;

  set mover(Mover? mover);
}

/// A mover which inverts the matrix from another mover.
class Invert implements Mover {
  Mover? _mover;
  Event? _changed;
  math2.Matrix4 _mat;
  int _frameNum;

  /// Creates a new invert mover.
  Invert([Mover? mover])
      : this._mover = null,
        this._changed = null,
        this._mat = math2.Matrix4.identity,
        this._frameNum = 0 {
    this.mover = mover;
  }

  /// Emits when the mover has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// The internal mover to invert.
  Mover? get mover => this._mover;

  set mover(Mover? mover) {
    if (this._mover != mover) {
      final prev = this._mover;
      this._mover = mover;
      if (mover != null) mover.changed.add(this._onChanged);
      if (prev != null) prev.changed.remove(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, "mover", prev, this._mover));
    }
  }

  /// Matrix from the last update.
  math2.Matrix4 get matrix => this._mat;

  /// Handles a child mover being changed.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Updates the contained mover then inverts the result.
  ///
  /// This updates with the given [state] and the [obj] this mover is attached to.
  @override
  math2.Matrix4 update(RenderState state, Movable? obj) {
    if (this._frameNum < state.frameNumber) {
      this._frameNum = state.frameNumber;
      this._changed?.suspend();
      final mat = this._mover?.update(state, obj).inverse();
      this._mat = mat ?? math2.Matrix4.identity;
      this._changed?.resume();
    }
    return this._mat;
  }

  /// Determines if the given [other] variable is a [Invert] equal to this one.
  @override
  // TODO fix this
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Invert) return false;
    if (this._mover != other._mover) return false;
    return true;
  }

  /// The string for this invert mover.
  @override
  String toString() => 'Invert';
}

/// A mover which groups several movers.
class Group extends Collection<Mover?> implements Mover {
  Event? _changed;
  math2.Matrix4 _mat;
  int _frameNum;

  /// Creates a new group of movers.
  Group([List<Mover?>? movers])
      : this._changed = null,
        this._mat = math2.Matrix4.identity,
        this._frameNum = 0 {
    this.setHandlers(onAddedHndl: this._onAdded, onRemovedHndl: this._onRemoved);
    if (movers != null) this.addAll(movers);
  }

  /// Emits when the mover has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Matrix from the last update.
  math2.Matrix4 get matrix => this._mat;

  /// Handles a child mover being changed.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Is called when one or more items are added to this collection.
  ///
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void _onAdded(int index, Iterable<Mover?> added) {
    for (final mover in added) {
      if (mover != null) mover.changed.add(this._onChanged);
    }
    this._onChanged(ItemsAddedEventArgs(this, index, added));
  }

  /// Is called when one or more items are removed from this collection.
  ///
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void _onRemoved(int index, Iterable<Mover?> removed) {
    for (final mover in removed) {
      if (mover != null) mover.changed.remove(this._onChanged);
    }
    this._onChanged(ItemsRemovedEventArgs(this, index, removed));
  }

  /// Updates all of the contained movers then multiply their results in order.
  ///
  /// This updates with the given [state] and the [obj] this mover is attached to.
  @override
  math2.Matrix4 update(RenderState state, Movable? obj) {
    if (this._frameNum < state.frameNumber) {
      this._frameNum = state.frameNumber;
      this._changed?.suspend();
      math2.Matrix4? mat;
      for (final mover in this) {
        if (mover != null) {
          final next = mover.update(state, obj);
          if (mat == null) {
            mat = next;
          } else {
            mat = next * mat;
          }
        }
      }
      this._mat = mat ?? math2.Matrix4.identity;
      this._changed?.resume();
    }
    return this._mat;
  }

  /// Determines if the given [other] variable is a [Group] equal to this one.
  @override
  // TODO fix this
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Group) return false;
    final length = this.length;
    for (int i = 0; i < length; ++i) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }

  /// The string for this group mover.
  @override
  String toString() => 'Group';
}

/// Constant mover applies a constant matrix to an entity or group.
class Constant extends Mover {
  math2.Matrix4 _mat;
  Event? _changed;

  /// Creates a new constant mover.
  Constant([math2.Matrix4? mat])
      : this._mat = math2.Matrix4.identity,
        this._changed = null {
    this.matrix = mat;
  }

  /// Constructs a 4x4 identity constant mover.
  factory Constant.identity() => Constant(math2.Matrix4.identity);

  /// Constructs a 4x4 translation constant mover.
  factory Constant.translate(double tx, double ty, double tz) => Constant(math2.Matrix4.translate(tx, ty, tz));

  /// Constructs a 4x4 scalar constant mover.
  factory Constant.scale(double sx, double sy, double sz, [double sw = 1.0]) =>
      Constant(math2.Matrix4.scale(sx, sy, sz, sw));

  /// Constructs a 4x4 rotation constant mover.
  ///
  /// The given [angle] is in radians.
  /// The given [vec] is the vector to rotate around.
  factory Constant.rotate(double angle, math2.Vector3 vec) => Constant(math2.Matrix4.rotate(angle, vec));

  /// Constructs a 4x4 X axis rotation constant mover.
  ///
  /// The given [angle] is in radians.
  factory Constant.rotateX(double angle) => Constant(math2.Matrix4.rotateX(angle));

  /// Constructs a 4x4 Y axis rotation constant mover.
  ///
  /// The given [angle] is in radians.
  factory Constant.rotateY(double angle) => Constant(math2.Matrix4.rotateY(angle));

  /// Constructs a 4x4 Z axis rotation constant mover.
  ///
  /// The given [angle] is in radians.
  factory Constant.rotateZ(double angle) => Constant(math2.Matrix4.rotateZ(angle));

  /// Constructs a new perspective projection constant mover.
  ///
  /// Constructs a projection for a right hand coordinate system.
  /// The given [angle] is in radians of the field of view.
  /// The given [ratio] is the width over the height of the view.
  /// The [near] and [far] depth of the view.
  factory Constant.perspective(double angle, double ratio, double near, double far) =>
      Constant(math2.Matrix4.perspective(angle, ratio, near, far));

  /// Constructs a new orthographic projection constant mover.
  ///
  /// [left] and [right] are the horizontal visible range.
  /// [top] and [bottom] are the vertical visible range.
  /// The [near] and [far] depth of the view.
  factory Constant.ortho(double left, double right, double top, double bottom, double near, double far) =>
      Constant(math2.Matrix4.ortho(left, right, top, bottom, near, far));

  /// Constructs a constant mover with a vector towards the given direction.
  ///
  /// [x]. [y], and [z] is the vector direction.
  /// [upHint] is a hint to help correct the top direction of the rotation.
  factory Constant.vectorTowards(double x, double y, double z, {math2.Vector3? upHint}) =>
      Constant(math2.Matrix4.vectorTowards(x, y, z, upHint: upHint));

  /// Constructs a camera constant mover.
  ///
  /// [pos] is the position of the camera,
  /// [up] is the top direction of the camera,
  /// and [forward] is the direction the camera is looking towards.
  factory Constant.lookTowards(math2.Point3 pos, math2.Vector3 up, math2.Vector3 forward) =>
      Constant(math2.Matrix4.lookTowards(pos, up, forward));

  /// Constructs a camera constant mover.
  ///
  /// [pos] is the position of the camera,
  /// [up] is the top direction of the camera,
  /// and [focus] is the point the camera is looking at.
  factory Constant.lookAtTarget(math2.Point3 pos, math2.Vector3 up, math2.Point3 focus) =>
      Constant(math2.Matrix4.lookAtTarget(pos, up, focus));

  /// Emits when the mover has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles emitting a change.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// The matrix to apply to an entity or group.
  math2.Matrix4? get matrix => this._mat;

  set matrix(math2.Matrix4? mat) {
    // ignore: parameter_assignments
    mat ??= math2.Matrix4.identity;
    if (this._mat != mat) {
      final prev = this._mat;
      this._mat = mat;
      this._onChanged(ValueChangedEventArgs(this, 'matrix', prev, this._mat));
    }
  }

  /// Updates the mover, in this case just returns the current matrix.
  ///
  /// This updates with the given [state] and the [obj] this mover is attached to.
  @override
  math2.Matrix4 update(RenderState state, Movable? obj) => this._mat;

  /// Determines if the given [other] variable is a [Constant] equal to this one.
  ///
  /// The equality of the doubles is tested with the current Comparer method.
  @override
  // TODO fix this
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Constant) return false;
    return this._mat == other._mat;
  }

  /// The string for this constant mover.
  @override
  String toString() => 'Constant: ' + this._mat.format('          ');
}

/// A simple single component for shifting and smoothing movement.
class ComponentShift extends Changeable {
  bool _wrap;
  double _maxLoc;
  double _minLoc;
  double _loc;
  double _maxVel;
  double _vel;
  double _acc;
  double _velDamp;
  Event? _changed;

  /// Creates a new [ComponentShift] instance.
  ComponentShift()
      : this._wrap = true,
        this._maxLoc = 1.0e12,
        this._minLoc = -1.0e12,
        this._loc = 0.0,
        this._maxVel = 100.0,
        this._vel = 0.0,
        this._acc = 0.0,
        this._velDamp = 0.0,
        this._changed = null;

  /// Clamps or wraps the given location to the given minimum and maximum range.
  double _clapWrap(double loc) {
    if (this._wrap) {
      return math2.wrapVal(loc, this._minLoc, this._maxLoc);
    } else {
      return math2.clampVal(loc, this._minLoc, this._maxLoc);
    }
  }

  /// Emits when the component has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles emitting a change.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// True to wrap the location around the maximum and minimum values,
  /// false to clap to the maximum and minimum values.
  bool get wrap => this._wrap;

  set wrap(bool wrap) {
    if (this._wrap != wrap) {
      final prev = this._wrap;
      this._wrap = wrap;
      this._onChanged(ValueChangedEventArgs(this, "wrap", prev, this._wrap));
    }
  }

  /// The maximum allowed location.
  double get maximumLocation => this._maxLoc;

  set maximumLocation(double max) {
    if (!math2.Comparer.equals(this._maxLoc, max)) {
      final prev = this._maxLoc;
      this._maxLoc = max;
      if (this._maxLoc < this._minLoc) {
        this._minLoc = this._maxLoc;
        this._loc = this._maxLoc;
      } else if (this._maxLoc < this._loc) this._loc = this._clapWrap(this._loc);
      this._onChanged(ValueChangedEventArgs(this, "maximumLocation", prev, this._maxLoc));
    }
  }

  /// The minimum allowed location.
  double get minimumLocation => this._minLoc;

  set minimumLocation(double min) {
    if (!math2.Comparer.equals(this._minLoc, min)) {
      final prev = this._minLoc;
      this._minLoc = min;
      if (this._maxLoc < this._minLoc) {
        this._maxLoc = this._minLoc;
        this._loc = this._minLoc;
      } else if (this._minLoc > this._loc) this._loc = this._clapWrap(this._loc);
      this._onChanged(ValueChangedEventArgs(this, "minimumLocation", prev, this._minLoc));
    }
  }

  /// The location which is the component being shifted.
  double get location => this._loc;

  set location(double loc) {
    // ignore: parameter_assignments
    loc = this._clapWrap(loc);
    if (!math2.Comparer.equals(this._loc, loc)) {
      final prev = this._loc;
      this._loc = loc;
      this._onChanged(ValueChangedEventArgs(this, "location", prev, this._loc));
    }
  }

  /// The maximum allowed velocity.
  /// The minimum allowed velocity is the negation of this value.
  double get maximumVelocity => this._maxVel;

  set maximumVelocity(double max) {
    if (!math2.Comparer.equals(this._maxVel, max)) {
      final prev = this._maxVel;
      this._maxVel = max;
      if (this._maxVel < 0.0) {
        this._maxVel = 0.0;
        this._vel = 0.0;
      } else {
        this._vel = math2.clampVal(this._vel, -this._maxVel, this._maxVel);
      }
      this._onChanged(ValueChangedEventArgs(this, "maximumVelocity", prev, this._maxVel));
    }
  }

  /// The velocity of the component.
  double get velocity => this._vel;

  set velocity(double vel) {
    // ignore: parameter_assignments
    vel = math2.clampVal(vel, -this._maxVel, this._maxVel);
    if (!math2.Comparer.equals(this._vel, vel)) {
      final prev = this._vel;
      this._vel = vel;
      this._onChanged(ValueChangedEventArgs(this, "velocity", prev, this._vel));
    }
  }

  /// The acceleration of the component.
  double get acceleration => this._acc;

  set acceleration(double acc) {
    if (!math2.Comparer.equals(this._acc, acc)) {
      final prev = this._acc;
      this._acc = acc;
      this._onChanged(ValueChangedEventArgs(this, "acceleration", prev, this._acc));
    }
  }

  /// The amount of dampening applied to the velocity.
  ///
  /// 0 means no dampening to slow down the velocity,
  /// 1 means total dampening to apply no velocity.
  double get dampening => this._velDamp;

  set dampening(double dampening) {
    // ignore: parameter_assignments
    dampening = math2.clampVal(dampening);
    if (!math2.Comparer.equals(this._velDamp, dampening)) {
      final prev = this._velDamp;
      this._velDamp = dampening;
      this._onChanged(ValueChangedEventArgs(this, "dampening", prev, this._velDamp));
    }
  }

  /// Update the component with the given change in time, [dt].
  void update(double dt) {
    if (!math2.Comparer.equals(this._vel, 0.0) || !math2.Comparer.equals(this._acc, 0.0)) {
      double vel = this._vel + this._acc * dt;
      vel = math2.clampVal(vel, -this._maxVel, this._maxVel);
      this.location = this._loc + vel * dt;
      if (!math2.Comparer.equals(this._velDamp, 0.0)) {
        double act = vel * math.pow(1.0 - this._velDamp, dt);
        if (vel < 0.0) {
          act = math2.clampVal(act, vel, 0.0);
        } else {
          act = math2.clampVal(act, 0.0, vel);
        }
        vel = act;
      }
      this.velocity = vel;
    }
  }
}

/// A zoom mover which zooms on an object in response to user input.
class UserZoom implements Mover, Interactable {
  /// The user input this zoomer is attached to.
  UserInput? _input;

  /// Indicates if the modifier keys which must be pressed or released.
  Modifiers _modPressed;

  /// The scalar to change how fast the zoom occurs.
  double _zoomScalar;

  /// The current zoom value.
  double _zoom;

  /// The last frame the mover was updated for.
  int _frameNum;

  /// The matrix describing the zoom.
  math2.Matrix4 _mat;

  /// Event for handling changes to this mover.
  Event? _changed;

  /// Creates an instance of [UserZoom].
  /// If [mod] is provided it will override any value given to [ctrl], [alt], and [shift].
  UserZoom(
      {bool ctrl = false,
      bool alt = false,
      bool shift = false,
      Modifiers? mod,
      UserInput? input})
      : this._input = null,
        this._modPressed = Modifiers.none(),
        this._zoomScalar = 0.01,
        this._zoom = 0.0,
        this._frameNum = 0,
        this._mat = math2.Matrix4.identity,
        this._changed = null {
    this.modifiers = mod ?? Modifiers(ctrl, alt, shift);
    this.attach(input);
  }

  /// Emits when the mover has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a child mover being changed.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Attaches this mover to the user input.
  @override
  bool attach(UserInput? input) {
    if (input == null) return false;
    if (this._input != null) return false;
    this._input = input;
    input.mouse.wheel.add(this._mouseWheelHandle);
    input.locked.wheel.add(this._mouseWheelHandle);
    return true;
  }

  /// Detaches this mover from the user input.
  @override
  void detach() {
    final input = this._input;
    if (input != null) {
      input.mouse.wheel.remove(this._mouseWheelHandle);
      input.locked.wheel.remove(this._mouseWheelHandle);
      this._input = null;
    }
  }

  /// Handles the mouse wheel changing.
  void _mouseWheelHandle(EventArgs args) {
    if (this._modPressed != this._input?.key.modifiers) return;
    final margs = args as MouseWheelEventArgs;
    this.zoom += margs.wheel.dy * this._zoomScalar;
  }

  /// Indicates if the modifiers keys must be pressed or released.
  Modifiers get modifiers => this._modPressed;

  set modifiers(Modifiers mods) {
    if (this._modPressed != mods) {
      final prev = this._modPressed;
      this._modPressed = mods;
      this._onChanged(ValueChangedEventArgs(this, 'modifiers', prev, mods));
    }
  }

  /// The scalar to change how fast the zoom occurs.
  double get zoomScalar => this._zoomScalar;

  set zoomScalar(double value) {
    if (!math2.Comparer.equals(this._zoomScalar, value)) {
      final prev = this._zoomScalar;
      this._zoomScalar = value;
      this._onChanged(ValueChangedEventArgs(this, 'zoomScalar', prev, this._zoomScalar));
    }
  }

  /// The current zoom value, the exponent on the scalar.
  double get zoom => this._zoom;

  set zoom(double value) {
    if (this._zoom != value) {
      final prev = this._zoom;
      this._zoom = value;
      this._onChanged(ValueChangedEventArgs(this, 'zoom', prev, this._zoom));
    }
  }

  /// Updates this mover and returns the matrix for the given object.
  @override
  math2.Matrix4 update(RenderState state, Movable? obj) {
    if (this._frameNum < state.frameNumber) {
      this._frameNum = state.frameNumber;
      final pow = math.pow(10.0, this._zoom).toDouble();
      this._mat = math2.Matrix4.scale(pow, pow, pow);
    }
    return this._mat;
  }
}

/// The handler for handling collisions during the movement.
typedef CollisionHandle = math2.Point3 Function(math2.Point3 prev, math2.Point3 next);

/// A translation mover which translates on an object in response to user input.
class UserTranslator implements Mover, Interactable {
  final KeyGroup _xNegKey;
  final KeyGroup _xPosKey;
  final KeyGroup _yNegKey;
  final KeyGroup _yPosKey;
  final KeyGroup _zNegKey;
  final KeyGroup _zPosKey;
  final ComponentShift _offsetX;
  final ComponentShift _offsetY;
  final ComponentShift _offsetZ;
  math2.Matrix3 _velRot;
  math2.Matrix3 _velRotInv;
  double _deccel;
  double _accel;

  /// The last frame the mover was updated for.
  int _frameNum;

  /// The matrix describing the translation.
  math2.Matrix4 _mat;

  /// Event for handling changes to this mover.
  Event? _changed;

  /// A handler for optionally handling collisions in movement.
  CollisionHandle? _collision;

  /// Creates an instance of [UserTranslator].
  UserTranslator({UserInput? input})
      : this._xNegKey = KeyGroup(),
        this._xPosKey = KeyGroup(),
        this._yNegKey = KeyGroup(),
        this._yPosKey = KeyGroup(),
        this._zNegKey = KeyGroup(),
        this._zPosKey = KeyGroup(),
        this._offsetX = ComponentShift(),
        this._offsetY = ComponentShift(),
        this._offsetZ = ComponentShift(),
        this._velRot = math2.Matrix3.identity,
        this._velRotInv = math2.Matrix3.identity,
        this._deccel = 60.0,
        this._accel = 15.0,
        this._frameNum = 0,
        this._mat = math2.Matrix4.identity,
        this._changed = null,
        this._collision = null {
    this._xNegKey
      ..addKey(Key.rightArrow)
      ..addKey(Key.keyD)
      ..keyDown.add(this._onKeyDown);
    this._xPosKey
      ..addKey(Key.leftArrow)
      ..addKey(Key.keyA)
      ..keyDown.add(this._onKeyDown);
    this._yNegKey
      ..addKey(Key.keyQ)
      ..keyDown.add(this._onKeyDown);
    this._yPosKey
      ..addKey(Key.keyE)
      ..keyDown.add(this._onKeyDown);
    this._zNegKey
      ..addKey(Key.downArrow)
      ..addKey(Key.keyS)
      ..keyDown.add(this._onKeyDown);
    this._zPosKey
      ..addKey(Key.upArrow)
      ..addKey(Key.keyW)
      ..keyDown.add(this._onKeyDown);
    const maxVel = 30.0;
    const dampening = 0.0;
    this._offsetX
      ..maximumVelocity = maxVel
      ..dampening = dampening
      ..changed.add(this._onChanged);
    this._offsetY
      ..maximumVelocity = maxVel
      ..dampening = dampening
      ..changed.add(this._onChanged);
    this._offsetZ
      ..maximumVelocity = maxVel
      ..dampening = dampening
      ..changed.add(this._onChanged);

    this.attach(input);
  }

  /// Emits when the mover has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a child mover being changed.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// The group of keys which will cause movement down a negative X vector.
  KeyGroup get negativeXKey => this._xNegKey;

  /// The group of keys which will cause movement down a positive X vector.
  KeyGroup get positiveXKey => this._xPosKey;

  /// The group of keys which will cause movement down a negative Y vector.
  KeyGroup get negativeYKey => this._yNegKey;

  /// The group of keys which will cause movement down a positive Y vector.
  KeyGroup get positiveYKey => this._yPosKey;

  /// The group of keys which will cause movement down a negative Z vector.
  KeyGroup get negativeZKey => this._zNegKey;

  /// The group of keys which will cause movement down a positive Z vector.
  KeyGroup get positiveZKey => this._zPosKey;

  /// The X offset component shifter.
  ComponentShift get offsetX => this._offsetX;

  /// The Y offset component shifter.
  ComponentShift get offsetY => this._offsetY;

  /// The Z offset component shifter.
  ComponentShift get offsetZ => this._offsetZ;

  /// The amount to remove from the velocity when no key in a direction is being pressed.
  double get deceleration => this._deccel;

  set deceleration(double deccel) {
    if (this._deccel != deccel) {
      final prev = this._deccel;
      this._deccel = deccel;
      this._onChanged(ValueChangedEventArgs(this, 'deceleration', prev, this._deccel));
    }
  }

  /// The amount to add to the velocity when a key in a direction is being pressed.
  double get acceleration => this._accel;

  set acceleration(double accel) {
    if (this._accel != accel) {
      final prev = this._accel;
      this._accel = accel;
      this._onChanged(ValueChangedEventArgs(this, 'acceleration', prev, this._accel));
    }
  }

  /// The matrix describing the rotation to apply to the velocity of thr translation.
  /// This is typically the yaw rotation for the direction the user is looking.
  math2.Matrix3 get velocityRotation => this._velRot;

  set velocityRotation(math2.Matrix3 velRot) {
    if (this._velRot != velRot) {
      final prev = this._velRot;
      this._velRot = velRot;
      this._velRotInv = this._velRot.inverse();
      this._onChanged(ValueChangedEventArgs(this, 'velocityRotation', prev, this._velRot));
    }
  }

  /// Velocity is the velocity vector relative to the world.
  math2.Vector3 get velocity => math2.Vector3(this._offsetX.velocity, this._offsetY.velocity, this._offsetZ.velocity);

  set velocity(math2.Vector3 vec) {
    this._offsetX.velocity = vec.dx;
    this._offsetY.velocity = vec.dy;
    this._offsetZ.velocity = vec.dz;
  }

  /// Direction is the velocity vector relative to the users rotation.
  math2.Vector3 get direction => this._velRotInv.transVec3(this.velocity);

  set direction(math2.Vector3 vec) => this.velocity = this._velRot.transVec3(vec);

  /// Location is the position of the user in the world.
  math2.Point3 get location => math2.Point3(this._offsetX.location, this._offsetY.location, this._offsetZ.location);

  set location(math2.Point3 loc) {
    this._offsetX.location = loc.x;
    this._offsetY.location = loc.y;
    this._offsetZ.location = loc.z;
  }

  /// The amount to add to the velocity when a key in a direction is being pressed.
  CollisionHandle? get collisionHandle => this._collision;

  set collisionHandle(CollisionHandle? collision) => this._collision = collision;

  /// Handles a key pressed.
  void _onKeyDown(EventArgs args) => this._onChanged(args);

  /// Updates a single component of the movement for the given keys.
  double _updateComponent(KeyGroup negKey, KeyGroup posKey, double deccel, double accel, double value) {
    if (negKey.pressed) {
      // ignore: parameter_assignments
      value += accel;
    } else if (posKey.pressed) {
      // ignore: parameter_assignments
      value -= accel;
    } else if (value > 0.0) {
      // ignore: parameter_assignments
      value -= math.min(value, deccel);
    } else {
      // ignore: parameter_assignments
      value += math.min(-value, deccel);
    }
    return value;
  }

  /// Updates the movement of the translation.
  void _updateMovement(double dt) {
    // Limits initial speed caused by a large dt from lower than 0.1 second updates.
    // ignore: parameter_assignments
    if (dt > 0.1) dt = 0.1;
    final deccel = this._deccel * dt;
    final accel = this._accel * dt;
    final dir = this.direction;
    final x = this._updateComponent(this._xNegKey, this._xPosKey, deccel, accel, dir.dx);
    final y = this._updateComponent(this._yNegKey, this._yPosKey, deccel, accel, dir.dy);
    final z = this._updateComponent(this._zNegKey, this._zPosKey, deccel, accel, dir.dz);
    this.direction = math2.Vector3(x, y, z);
    this._offsetX.update(dt);
    this._offsetY.update(dt);
    this._offsetZ.update(dt);
  }

  /// Attaches this mover to the user input.
  @override
  bool attach(UserInput? input) {
    bool result = true;
    result = this._xNegKey.attach(input) && result;
    result = this._xPosKey.attach(input) && result;
    result = this._yNegKey.attach(input) && result;
    result = this._yPosKey.attach(input) && result;
    result = this._zNegKey.attach(input) && result;
    result = this._zPosKey.attach(input) && result;
    return result;
  }

  /// Detaches this mover from the user input.
  @override
  void detach() {
    this._xNegKey.detach();
    this._xPosKey.detach();
    this._yNegKey.detach();
    this._yPosKey.detach();
    this._zNegKey.detach();
    this._zPosKey.detach();
  }

  /// Updates this mover and returns the matrix for the given object.
  @override
  math2.Matrix4 update(RenderState state, Movable? obj) {
    if (this._frameNum < state.frameNumber) {
      this._frameNum = state.frameNumber;
      final prev = this.location;
      this._updateMovement(state.dt);
      final collision = this._collision;
      if (collision != null) this.location = collision(prev, this.location);
      this._mat = math2.Matrix4.translate(this._offsetX.location, -this._offsetY.location, this._offsetZ.location);
    }
    return this._mat;
  }
}

/// A rotator which rotates an object in response to user input.
class UserRotator implements Mover, Interactable {
  /// The user input this rotator is attached to.
  UserInput? _input;

  /// The pitch component for this rotator.
  ComponentShift _pitch;

  /// The yaw component for this rotator.
  ComponentShift _yaw;

  /// Indicates if the modifier keys which must be pressed or released.
  Modifiers _modPressed;

  /// Indicates if the rotations should be continuous or not.
  bool _cumulative;

  /// The invert the X mouse axis.
  bool _invertX;

  /// The invert the Y mouse axis.
  bool _invertY;

  /// The value to scale the pitch by.
  double _pitchScalar;

  /// The value to scale the yaw by.
  double _yawScalar;

  /// The range, in pixels, of the dead band.
  double _deadBand;

  /// The dead band squared.
  double _deadBand2;

  /// Indicates if the mouse has left the dead band area yet.
  bool _inDeadBand;

  /// True indicating the mouse is pressed, false for released.
  bool _pressed;

  /// The yaw rotation in radians when the button was pressed.
  double _lastYaw;

  /// The pitch rotation in radians when the button was pressed.
  double _lastPitch;

  /// The previous change of the mouse, the offset or delta.
  math2.Vector2 _prevVal;

  /// The last frame the mover was updated for.
  int _frameNum;

  /// The matrix describing the mover's rotation.
  math2.Matrix4 _mat;

  /// Event for handling changes to this mover.
  Event? _changed;

  /// Creates a new user rotator instance.
  /// If [mod] is provided it will override any value given to [ctrl], [alt], and [shift].
  UserRotator(
      {bool ctrl = false,
      bool alt = false,
      bool shift = false,
      bool invertX = false,
      bool invertY = false,
      Modifiers? mod,
      UserInput? input})
      : this._input = null,
        this._pitch = ComponentShift(),
        this._yaw = ComponentShift(),
        this._modPressed = Modifiers.none(),
        this._cumulative = false,
        this._invertX = false,
        this._invertY = false,
        this._pitchScalar = 2.5,
        this._yawScalar = 2.5,
        this._deadBand = 2.0,
        this._deadBand2 = 4.0,
        this._inDeadBand = false,
        this._pressed = false,
        this._lastYaw = 0.0,
        this._lastPitch = 0.0,
        this._prevVal = math2.Vector2.zero,
        this._frameNum = 0,
        this._mat = math2.Matrix4.identity,
        this._changed = null {
    this._pitch
      ..wrap = true
      ..maximumLocation = math2.PI * 2.0
      ..minimumLocation = 0.0
      ..location = 0.0
      ..maximumVelocity = 100.0
      ..velocity = 0.0
      ..dampening = 0.5
      ..changed.add(this._onChanged);
    this._yaw
      ..wrap = true
      ..maximumLocation = math2.PI * 2.0
      ..minimumLocation = 0.0
      ..location = 0.0
      ..maximumVelocity = 100.0
      ..velocity = 0.0
      ..dampening = 0.5
      ..changed.add(this._onChanged);
    this.modifiers = mod ?? Modifiers(ctrl, alt, shift);
    this.invertX = invertX;
    this.invertY = invertY;
    this.attach(input);
  }

  /// Creates a new flat movement like a typical first person view rotator.
  /// If [mod] is provided it will override any value given to ctrl, alt, and shift.
  factory UserRotator.flat({
    bool invertX = false,
    bool invertY = false,
    Modifiers? mod,
    UserInput? input,
  }) =>
      UserRotator(mod: mod, invertX: invertX, invertY: invertY, input: input)
        ..pitch.maximumLocation = math2.PI_2
        ..pitch.minimumLocation = -math2.PI_2
        ..pitch.dampening = 1.0
        ..yaw.dampening = 1.0
        ..pitch.wrap = false;

  /// Emits when the mover has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a child mover being changed.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Attaches this mover to the user input.
  @override
  bool attach(UserInput? input) {
    if (input == null) return false;
    if (this._input != null) return false;
    this._input = input;
    input.mouse.down.add(this._mouseDownHandle);
    input.mouse.move.add(this._mouseMoveHandle);
    input.mouse.up.add(this._mouseUpHandle);
    input.locked.lockChanged.add(this._lockChangedHandle);
    input.locked.move.add(this._lockedMoveHandle);
    input.touch.start.add(this._touchStartHandle);
    input.touch.move.add(this._touchMoveHandle);
    input.touch.end.add(this._touchEndHandle);
    return true;
  }

  /// Detaches this mover from the user input.
  @override
  void detach() {
    final input = this._input;
    if (input != null) {
      input.mouse.down.remove(this._mouseDownHandle);
      input.mouse.move.remove(this._mouseMoveHandle);
      input.mouse.up.remove(this._mouseUpHandle);
      input.locked.lockChanged.remove(this._lockChangedHandle);
      input.locked.move.remove(this._lockedMoveHandle);
      input.touch.start.remove(this._touchStartHandle);
      input.touch.move.remove(this._touchMoveHandle);
      input.touch.end.remove(this._touchEndHandle);
      this._input = null;
    }
  }

  /// Gets the given [vec] inverted based on settings.
  math2.Vector2 _getInverses(math2.Vector2 vec) {
    double dx = vec.dx;
    double dy = vec.dy;
    if (this._invertX) dx = -dx;
    if (this._invertY) dy = -dy;
    return math2.Vector2(dx, dy);
  }

  /// Handles the mouse down event.
  void _mouseDownHandle(EventArgs args) {
    final margs = args as MouseEventArgs;
    if (this._modPressed != margs.button.modifiers) return;
    this._pressed = true;
    this._inDeadBand = true;
    this._lastYaw = this._yaw.location;
    this._lastPitch = this._pitch.location;
  }

  /// Handles the mouse move event.
  void _mouseMoveHandle(EventArgs args) {
    final margs = args as MouseEventArgs;
    if (!this._pressed) return;
    if (this._inDeadBand) {
      if (margs.rawOffset.length2() < this._deadBand2) return;
      this._inDeadBand = false;
    }
    if (this._cumulative) {
      this._prevVal = this._getInverses(margs.adjustedOffset);
      this._yaw.velocity = -this._prevVal.dx * 10.0 * this._yawScalar;
      this._pitch.velocity = -this._prevVal.dy * 10.0 * this._pitchScalar;
    } else {
      final off = this._getInverses(margs.adjustedOffset);
      this._yaw.location = -off.dx * this._yawScalar + this._lastYaw;
      this._pitch.location = -off.dy * this._pitchScalar + this._lastPitch;
      this._pitch.velocity = 0.0;
      this._yaw.velocity = 0.0;
      this._prevVal = this._getInverses(margs.adjustedDelta);
    }

    this._onChanged();
  }

  /// Handle the mouse up event.
  void _mouseUpHandle(EventArgs _) {
    if (!this._pressed) return;
    this._pressed = false;
    if (this._inDeadBand) return;
    if (this._prevVal.length2() > 0.0001) {
      this._yaw.velocity = -this._prevVal.dx * 10.0 * this._yawScalar;
      this._pitch.velocity = -this._prevVal.dy * 10.0 * this._pitchScalar;
      this._onChanged();
    }
  }

  /// Handle the change in the mouse pointer lock.
  void _lockChangedHandle(EventArgs args) {
    final margs = args as LockedEventArgs;
    if (margs.locked) {
      this._inDeadBand = true;
      this._lastYaw = this._yaw.location;
      this._lastPitch = this._pitch.location;
    }
  }

  /// Handle the locked mouse movement.
  void _lockedMoveHandle(EventArgs args) {
    final margs = args as MouseEventArgs;
    if (this._modPressed != margs.button.modifiers) return;
    final off = this._getInverses(margs.adjustedOffset);
    this._yaw.location = -off.dx * this._yawScalar + this._lastYaw;
    this._pitch.location = -off.dy * this._pitchScalar + this._lastPitch;
    this._pitch.velocity = 0.0;
    this._yaw.velocity = 0.0;
    this._prevVal = this._getInverses(margs.adjustedDelta);

    this._onChanged();
  }

  /// Handle the touch screen touch start.
  void _touchStartHandle(EventArgs args) {
    this._pressed = true;
    this._inDeadBand = true;
    this._lastYaw = this._yaw.location;
    this._lastPitch = this._pitch.location;
  }

  /// Handle the touch screen move.
  void _touchMoveHandle(EventArgs args) {
    final targs = args as TouchEventArgs;
    if (!this._pressed) return;
    if (this._inDeadBand) {
      if (targs.rawOffset.length2() < this._deadBand2) return;
      this._inDeadBand = false;
    }
    if (this._cumulative) {
      this._prevVal = this._getInverses(targs.adjustedOffset);
      this._yaw.velocity = -this._prevVal.dx * 10.0 * this._yawScalar;
      this._pitch.velocity = -this._prevVal.dy * 10.0 * this._pitchScalar;
    } else {
      final off = this._getInverses(targs.adjustedOffset);
      this._yaw.location = -off.dx * this._yawScalar + this._lastYaw;
      this._pitch.location = -off.dy * this._pitchScalar + this._lastPitch;
      this._pitch.velocity = 0.0;
      this._yaw.velocity = 0.0;
      this._prevVal = this._getInverses(targs.adjustedDelta);
    }

    this._onChanged();
  }

  /// Handle the touch screen end.
  void _touchEndHandle(EventArgs args) {
    if (!this._pressed) return;
    this._pressed = false;
    if (this._inDeadBand) return;
    if (this._prevVal.length2() > 0.0001) {
      this._yaw.velocity = -this._prevVal.dx * 10.0 * this._yawScalar;
      this._pitch.velocity = -this._prevVal.dy * 10.0 * this._pitchScalar;
      this._onChanged();
    }
  }

  /// The pitch component for this rotator.
  ComponentShift get pitch => this._pitch;

  /// The yaw component for this rotator.
  ComponentShift get yaw => this._yaw;

  /// Gets the matrix calculated during the last update.
  math2.Matrix4 get matrix => this._mat;

  /// Indicates if the modifiers keys must be pressed or released.
  /// This does not apply when using a touch input.
  Modifiers get modifiers => this._modPressed;

  set modifiers(Modifiers mods) {
    if (this._modPressed != mods) {
      final prev = this._modPressed;
      this._modPressed = mods;
      this._onChanged(ValueChangedEventArgs(this, 'modifiers', prev, mods));
    }
  }

  /// Indicates if the rotations should be continuous or not.
  /// This does not apply when the mouse is locked.
  bool get cumulative => this._cumulative;

  set cumulative(bool enable) {
    if (this._cumulative != enable) {
      final prev = this._cumulative;
      this._cumulative = enable;
      this._onChanged(ValueChangedEventArgs(this, 'cumulative', prev, this._cumulative));
    }
  }

  /// Inverts the X mouse axis.
  bool get invertX => this._invertX;

  set invertX(bool invert) {
    if (this._invertX != invert) {
      final prev = this._invertX;
      this._invertX = invert;
      this._onChanged(ValueChangedEventArgs(this, 'invertX', prev, this._invertX));
    }
  }

  /// Inverts the Y mouse axis.
  bool get invertY => this._invertY;

  set invertY(bool invert) {
    if (this._invertY != invert) {
      final prev = this._invertY;
      this._invertY = invert;
      this._onChanged(ValueChangedEventArgs(this, 'invertY', prev, this._invertY));
    }
  }

  /// The scalar to apply to the mouse movements pitch.
  double get pitchScalar => this._pitchScalar;

  set pitchScalar(double value) {
    if (!math2.Comparer.equals(this._pitchScalar, value)) {
      final prev = this._pitchScalar;
      this._pitchScalar = value;
      this._onChanged(ValueChangedEventArgs(this, 'pitchScalar', prev, this._pitchScalar));
    }
  }

  /// The scalar to apply to the mouse movements yaw.
  double get yawScalar => this._yawScalar;

  set yawScalar(double value) {
    if (!math2.Comparer.equals(this._yawScalar, value)) {
      final prev = this._yawScalar;
      this._yawScalar = value;
      this._onChanged(ValueChangedEventArgs(this, 'yawScalar', prev, this._yawScalar));
    }
  }

  /// The dead-band, in pixels, before any movement is made.
  /// This does not apply when the mouse is locked.
  double get deadBand => this._deadBand;

  set deadBand(double value) {
    if (!math2.Comparer.equals(this._deadBand, value)) {
      final prev = this._deadBand;
      this._deadBand = value;
      this._deadBand2 = this._deadBand * this._deadBand;
      this._onChanged(ValueChangedEventArgs(this, 'deadBand', prev, this._deadBand));
    }
  }

  /// Updates this mover and returns the matrix for the given object.
  @override
  math2.Matrix4 update(RenderState state, Movable? obj) {
    if (this._frameNum < state.frameNumber) {
      this._frameNum = state.frameNumber;
      final dt = state.dt;
      this._yaw.update(dt);
      this._pitch.update(dt);
      this._mat = math2.Matrix4.rotateX(this._pitch.location) * math2.Matrix4.rotateY(this._yaw.location);
    }
    return this._mat;
  }
}

/// A roller which rotates an object in response to user input.
class UserRoller implements Mover, Interactable {
  /// The user input this roller is attached to.
  UserInput? _input;

  /// The roll component for this roller.
  final ComponentShift _roll;

  /// Indicates if the modifier keys which must be pressed or released.
  Modifiers _modPressed = Modifiers.none();

  /// Indicates if the rotations should be continuous or not.
  bool _cumulative = false;

  /// The value to scale the roll by.
  double _rollScalar = 2.5;

  /// The range, in pixels, of the dead band.
  double _deadBand = 2.0;

  /// The dead band squared.
  double _deadBand2 = 4.0;

  /// Indicates if the mouse has left the dead band area yet.
  bool _inDeadBand = false;

  /// True indicating the mouse is pressed, false for released.
  bool _pressed = false;

  /// The roll rotation in radians when the button was pressed.
  double _lastRoll = 0.0;

  /// The previous change of the mouse, the offset or delta.
  math2.Vector2 _prevVal = math2.Vector2.zero;

  /// The last frame the mover was updated for.
  int _frameNum = 0;

  /// The matrix describing the mover's rotation.
  math2.Matrix4 _mat = math2.Matrix4.identity;

  /// Event for handling changes to this mover.
  Event? _changed;

  /// Creates a new user rotator instance.
  /// If [mod] is provided it will override any value given to [ctrl], [alt], and [shift].
  UserRoller(
      {bool ctrl = false,
      bool alt = false,
      bool shift = false,
      Modifiers? mod,
      UserInput? input})
      : this._input = null,
        this._roll = ComponentShift(),
        this._modPressed = Modifiers.none(),
        this._cumulative = false,
        this._rollScalar = 2.5,
        this._deadBand = 2.0,
        this._deadBand2 = 4.0,
        this._inDeadBand = false,
        this._pressed = false,
        this._lastRoll = 0.0,
        this._prevVal = math2.Vector2.zero,
        this._frameNum = 0,
        this._mat = math2.Matrix4.identity,
        this._changed = null {
    this._roll
      ..wrap = true
      ..maximumLocation = math2.PI * 2.0
      ..minimumLocation = 0.0
      ..location = 0.0
      ..maximumVelocity = 100.0
      ..velocity = 0.0
      ..dampening = 0.2
      ..changed.add(this._onChanged);
    this.modifiers = mod ?? Modifiers(ctrl, alt, shift);
    this.attach(input);
  }

  /// Emits when the mover has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a child mover being changed.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Attaches this mover to the user input.
  @override
  bool attach(UserInput? input) {
    if (input == null) return false;
    if (this._input != null) return false;
    this._input = input;
    input.mouse.down.add(this._mouseDownHandle);
    input.mouse.move.add(this._mouseMoveHandle);
    input.mouse.up.add(this._mouseUpHandle);
    return true;
  }

  /// Detaches this mover from the user input.
  @override
  void detach() {
    final input = this._input;
    if (input != null) {
      input.mouse.down.remove(this._mouseDownHandle);
      input.mouse.move.remove(this._mouseMoveHandle);
      input.mouse.up.remove(this._mouseUpHandle);
      this._input = null;
    }
  }

  /// Handles the mouse down event.
  void _mouseDownHandle(EventArgs? args) {
    if (this._modPressed != this._input?.key.modifiers) return;
    this._pressed = true;
    this._inDeadBand = true;
    this._lastRoll = this._roll.location;
  }

  /// Handles the mouse move event.
  void _mouseMoveHandle(EventArgs? args) {
    final margs = (args as MouseEventArgs?)!;
    if (!this._pressed) {
      return;
    }
    if (this._inDeadBand) {
      if (margs.rawOffset.length2() < this._deadBand2) return;
      this._inDeadBand = false;
    }
    if (this._cumulative) {
      this._prevVal = margs.adjustedOffset;
      this._roll.velocity = this._prevVal.dx * 10.0 * this._rollScalar;
    } else {
      final off = margs.adjustedOffset;
      this._roll.location = -off.dx * this._rollScalar + this._lastRoll;
      this._roll.velocity = 0.0;
      this._prevVal = margs.adjustedDelta;
    }
    this._onChanged();
  }

  /// Handle the mouse up event.
  void _mouseUpHandle(EventArgs? args) {
    if (!this._pressed) return;
    this._pressed = false;
    if (this._inDeadBand) return;
    if (this._prevVal.length2() > 0.0001) {
      this._roll.velocity = this._prevVal.dx * 10.0 * this._rollScalar;
      this._onChanged();
    }
  }

  /// The roll component for this rotator.
  ComponentShift get roll => this._roll;

  /// Indicates if the modifiers keys must be pressed or released.
  Modifiers get modifiers => this._modPressed;

  set modifiers(Modifiers mods) {
    if (this._modPressed != mods) {
      final prev = this._modPressed;
      this._modPressed = mods;
      this._onChanged(ValueChangedEventArgs(this, 'modifiers', prev, mods));
    }
  }

  /// Indicates if the rotations should be continuous or not.
  bool get cumulative => this._cumulative;

  set cumulative(bool enable) {
    if (this._cumulative != enable) {
      final prev = this._cumulative;
      this._cumulative = enable;
      this._onChanged(ValueChangedEventArgs(this, 'cumulative', prev, this._cumulative));
    }
  }

  /// The scalar to apply to the mouse movements roll.
  double get rollScalar => this._rollScalar;

  set rollScalar(double value) {
    if (!math2.Comparer.equals(this._rollScalar, value)) {
      final prev = this._rollScalar;
      this._rollScalar = value;
      this._onChanged(ValueChangedEventArgs(this, 'rollScalar', prev, this._rollScalar));
    }
  }

  /// The dead-band, in pixels, before any movement is made.
  double get deadBand => this._deadBand;

  set deadBand(double value) {
    if (!math2.Comparer.equals(this._deadBand, value)) {
      final prev = this._deadBand;
      this._deadBand = value;
      this._deadBand2 = this._deadBand * this._deadBand;
      this._onChanged(ValueChangedEventArgs(this, 'deadBand', prev, this._deadBand));
    }
  }

  /// Updates this mover and returns the matrix for the given object.
  @override
  math2.Matrix4 update(RenderState state, Movable? obj) {
    if (this._frameNum < state.frameNumber) {
      this._frameNum = state.frameNumber;
      final dt = state.dt;
      this._roll.update(dt);
      this._mat = math2.Matrix4.rotateZ(this._roll.location);
    }
    return this._mat;
  }
}

/// A mover for rotating an object at a constant rate with euler angles.
class Rotator extends Mover {
  double _yaw;
  double _pitch;
  double _roll;
  double _deltaYaw;
  double _deltaPitch;
  double _deltaRoll;
  int _frameNum;
  math2.Matrix4 _mat;
  Event? _changed;

  /// Creates a new rotator.
  Rotator(
      {double yaw = 0.0,
      double pitch = 0.0,
      double roll = 0.0,
      double deltaYaw = 0.1,
      double deltaPitch = 0.21,
      double deltaRoll = 0.32})
      : this._yaw = 0.0,
        this._pitch = 0.0,
        this._roll = 0.0,
        this._deltaYaw = 0.0,
        this._deltaPitch = 0.0,
        this._deltaRoll = 0.0,
        this._frameNum = 0,
        this._mat = math2.Matrix4.identity,
        this._changed = null {
    this.yaw = yaw;
    this.pitch = pitch;
    this.roll = roll;
    this.deltaYaw = deltaYaw;
    this.deltaPitch = deltaPitch;
    this.deltaRoll = deltaRoll;
  }

  /// Emits when the mover has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a child mover being changed.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// The yaw rotation, in radians.
  double get yaw => this._yaw;

  set yaw(double value) {
    // ignore: parameter_assignments
    value = math2.wrapVal(value, 0.0, math2.TAU);
    if (!math2.Comparer.equals(this._yaw, value)) {
      final prev = this._yaw;
      this._yaw = value;
      this._onChanged(ValueChangedEventArgs(this, 'yaw', prev, this._yaw));
    }
  }

  /// The pitch rotation, in radians.
  double get pitch => this._pitch;

  set pitch(double value) {
    // ignore: parameter_assignments
    value = math2.wrapVal(value, 0.0, math2.TAU);
    if (!math2.Comparer.equals(this._pitch, value)) {
      final prev = this._pitch;
      this._pitch = value;
      this._onChanged(ValueChangedEventArgs(this, 'pitch', prev, this._pitch));
    }
  }

  /// The roll rotation, in radians.
  double get roll => this._roll;

  set roll(double value) {
    // ignore: parameter_assignments
    value = math2.wrapVal(value, 0.0, math2.TAU);
    if (!math2.Comparer.equals(this._roll, value)) {
      final prev = this._roll;
      this._roll = value;
      this._onChanged(ValueChangedEventArgs(this, 'roll', prev, this._roll));
    }
  }

  /// The change in yaw, in radians per second.
  double get deltaYaw => this._deltaYaw;

  set deltaYaw(double value) {
    if (!math2.Comparer.equals(this._deltaYaw, value)) {
      final prev = this._deltaYaw;
      this._deltaYaw = value;
      this._onChanged(ValueChangedEventArgs(this, 'deltaYaw', prev, this._deltaYaw));
    }
  }

  /// The change in pitch, in radians per second.
  double get deltaPitch => this._deltaPitch;

  set deltaPitch(double value) {
    if (!math2.Comparer.equals(this._deltaPitch, value)) {
      final prev = this._deltaPitch;
      this._deltaPitch = value;
      this._onChanged(ValueChangedEventArgs(this, 'deltaPitch', prev, this._deltaPitch));
    }
  }

  /// The change in roll, in radians per second.
  double get deltaRoll => this._deltaRoll;

  set deltaRoll(double value) {
    if (!math2.Comparer.equals(this._deltaRoll, value)) {
      final prev = this._deltaRoll;
      this._deltaRoll = value;
      this._onChanged(ValueChangedEventArgs(this, 'deltaRoll', prev, this._deltaRoll));
    }
  }

  /// Updates the rotation mover.
  ///
  /// This updates with the given [state] and the [obj] this mover is attached to.
  @override
  math2.Matrix4 update(RenderState state, Movable? obj) {
    if (this._frameNum < state.frameNumber) {
      this._frameNum = state.frameNumber;
      this._changed?.suspend();
      this.yaw += this._deltaYaw * state.dt;
      this.pitch += this._deltaPitch * state.dt;
      this.roll += this._deltaRoll * state.dt;
      this._mat = math2.Matrix4.rotateZ(this._roll) *
          math2.Matrix4.rotateY(this._pitch) *
          math2.Matrix4.rotateX(this._yaw);
      this._changed?.resume();
    }
    return this._mat;
  }

  /// Determines if the given [other] variable is a [Rotator] equal to this one.
  ///
  /// The equality of the doubles is tested with the current Comparer method.
  @override
  // TODO fix this
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Rotator) return false;
    if (!math2.Comparer.equals(this._yaw, other._yaw)) return false;
    if (!math2.Comparer.equals(this._pitch, other._pitch)) return false;
    if (!math2.Comparer.equals(this._roll, other._roll)) return false;
    if (!math2.Comparer.equals(this._deltaYaw, other._deltaYaw)) return false;
    if (!math2.Comparer.equals(this._deltaPitch, other._deltaPitch)) return false;
    if (!math2.Comparer.equals(this._deltaRoll, other._deltaRoll)) return false;
    return true;
  }

  /// The string for this constant mover.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this constant mover.
  String format([int fraction = 3, int whole = 0]) {
    return 'Rotator: [' +
        math2.formatDouble(this._yaw, fraction, whole) +
        ', ' +
        math2.formatDouble(this._pitch, fraction, whole) +
        ', ' +
        math2.formatDouble(this._roll, fraction, whole) +
        '], [' +
        math2.formatDouble(this._deltaYaw, fraction, whole) +
        ', ' +
        math2.formatDouble(this._deltaPitch, fraction, whole) +
        ', ' +
        math2.formatDouble(this._deltaRoll, fraction, whole) +
        ']';
  }
}
