// Lights defines a set of data objects used to define lighting in a scene.
// Not all techniques use lights. Typically the MaterialLight technique is used
// with lights to setup an effect for an object.
import 'dart:math' as math;

import '../collections/collections.dart';
import '../core/core.dart';
import '../events/events.dart';
import '../math/math.dart';
import '../movers/movers.dart';
import '../textures/textures.dart';

/// A collection of lights.
class LightCollection extends Collection<Light> {
  final List<Bar> _barLights;
  final List<Directional> _dirLights;
  final List<Point> _pntLights;
  final List<Spot> _spotLights;
  Event? _changed;
  Event? _lightChanged;

  /// Creates a new light collection.
  LightCollection()
      : this._barLights = [],
        this._dirLights = [],
        this._pntLights = [],
        this._spotLights = [],
        this._changed = null,
        this._lightChanged = null {
    this.setHandlers(
        onPreaddHndl: this._onPreaddLights, onAddedHndl: this._onAddedLights, onRemovedHndl: this._onRemovedLights);
  }

  /// The event emitted when the collection has changed.
  Event get changed => this._changed ??= Event();

  /// The event emitted when a light's value has changed.
  Event get lightChanged => this._lightChanged ??= Event();

  /// Handles changes to the collection.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Handles changes to the light's values.
  void _onLightChanged([EventArgs? args]) => this._lightChanged?.emit(args);

  /// Checks if the light can be added to this set.
  bool _onPreaddLights(Iterable<Light> added) {
    for (final light in added) {
      if (this._contains(light)) return false;
    }
    return true;
  }

  /// Handles a light being added.
  void _onAddedLights(int index, Iterable<Light> added) {
    for (final light in added) {
      this._addOther(light);
      light.changed.add(this._onLightChanged);
    }
    this._onChanged(ItemsAddedEventArgs(this, index, added));
  }

  /// Handles a light being removed.
  void _onRemovedLights(int index, Iterable<Light> removed) {
    for (final light in removed) {
      this._removeOther(light);
      light.changed.remove(this._onLightChanged);
    }
    this._onChanged(ItemsRemovedEventArgs(this, index, removed));
  }

  /// Gets the set of bar lights in this collection.
  Iterable<Bar> get barLights => this._barLights;

  /// Gets the set of directional lights in this collection.
  Iterable<Directional> get directionalLights => this._dirLights;

  /// Gets the set of point lights in this collection.
  Iterable<Point> get pointLights => this._pntLights;

  /// Gets the set of spot lights in this collection.
  Iterable<Spot> get spotLights => this._spotLights;

  /// Checks the given [light] is in the collection.
  bool _contains(Light light) {
    if (light is Bar) return this._barLights.contains(light);
    if (light is Directional) return this._dirLights.contains(light);
    if (light is Point) return this._pntLights.contains(light);
    if (light is Spot) return this._spotLights.contains(light);
    return false;
  }

  /// Adds the given [light] to this collection.
  void _addOther(Light light) {
    if (light is Bar) {
      this._barLights.add(light);
    } else if (light is Directional) {
      this._dirLights.add(light);
    } else if (light is Point) {
      this._pntLights.add(light);
    } else if (light is Spot) {
      this._spotLights.add(light);
    }
  }

  /// Removes the light from the specific lists of lights.
  void _removeOther(Light light) {
    if (light is Bar) {
      this._barLights.remove(light);
    } else if (light is Directional) {
      this._dirLights.remove(light);
    } else if (light is Point) {
      this._pntLights.remove(light);
    } else if (light is Spot) {
      this._spotLights.remove(light);
    }
  }
}

/// Storage for bar light data.
class Bar implements Light {
  Matrix4 _startMatrix;
  Matrix4 _endMatrix;
  Mover? _startMover;
  Mover? _endMover;
  Color3? _color;
  Vector4? _shadowAdj;
  double _attenuation0;
  double _attenuation1;
  double _attenuation2;
  bool _enableAttn;
  Event? _changed;

  /// Creates a new bar light data.
  Bar(
      {Mover? startMover,
        Mover? endMover,
        Color3? color,
        //Textures.Texture2D? texture: null, // TODO: Add Texture
        Vector4? shadowAdj,
        double attenuation0 = 1.0,
        double attenuation1 = 0.0,
        double attenuation2 = 0.0,
        bool enableAttenuation = true})
      : this._startMatrix = Matrix4.identity,
        this._endMatrix = Matrix4.identity,
        this._startMover = null,
        this._endMover = null,
        this._color = Color3.white(),
        this._shadowAdj = Vector4.zero,
        this._attenuation0 = 1.0,
        this._attenuation1 = 0.0,
        this._attenuation2 = 0.0,
        this._enableAttn = true,
        this._changed = null {
    this.startMover = startMover;
    this.endMover = endMover;
    this.color = color;
    //this.texture      = texture; // TODO: Add Texture
    this.shadowAdjust = shadowAdj;
    this.attenuation0 = attenuation0;
    this.attenuation1 = attenuation1;
    this.attenuation2 = attenuation2;
    this.enableAttenuation = enableAttenuation;
  }

  /// Emits when the light is changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles changes to the light.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Updates the light with the current state.
  @override
  void update(RenderState state) {
    this._startMatrix = this._startMover?.update(state, this) ?? Matrix4.identity;
    this._endMatrix = this._endMover?.update(state, this) ?? Matrix4.identity;
  }

  /// The identifier for the configuration to use when
  /// setting up the shader using this light.
  int get configID =>
      //((this._texture != null)? 0x01: 0) + // TODO: Add Texture
  this._enableAttn ? 0x04 : 0;

  /// The rotation and position of the start point of the bar light.
  Matrix4 get startMatrix => this._startMatrix;

  /// The rotation and position of the end point of the bar light.
  Matrix4 get endMatrix => this._endMatrix;

  /// This is an alias to the start mover, [startMover].
  @override
  Mover? get mover => this.startMover;

  @override
  set mover(Mover? mover) => this.startMover = mover;

  /// The mover to start position this light.
  Mover? get startMover => this._startMover;

  set startMover(Mover? mover) {
    if (this._startMover != mover) {
      this._startMover?.changed.remove(this._onChanged);
      final prev = this._startMover;
      this._startMover = mover;
      this._startMover?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'startMover', prev, this._startMover));
    }
  }

  /// The mover to end position this light.
  Mover? get endMover => this._endMover;

  set endMover(Mover? mover) {
    if (this._endMover != mover) {
      this._endMover?.changed.remove(this._onChanged);
      final prev = this._endMover;
      this._endMover = mover;
      this._endMover?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'endMover', prev, this._endMover));
    }
  }

  /// The color of the light.
  Color3? get color => this._color;

  set color(Color3? color) {
    if (this._color != color) {
      final prev = this._color;
      this._color = color;
      this._onChanged(ValueChangedEventArgs(this, 'color', prev, this._color));
    }
  }

  /* TODO: Add Texture
  /// The color texture of the light.
  Textures.Texture2D get texture => this._texture;
  set texture(Textures.Texture2D texture) {
    if (this._texture != texture) {
      if (this._texture != null) this._texture.changed.remove(this._onChanged);
      Textures.Texture2D prev = this._texture;
      this._texture = texture;
      if (this._texture != null) this._texture.changed.add(this._onChanged);
      this._onChanged(new Events.ValueChangedEventArgs(this, 'texture', prev, this._texture));
    }
  }
  */

  /// The shadow value modification vector.
  /// This is the vector to apply to the color from the shadow texture
  /// to get the shadow value from the shadow texture.
  Vector4? get shadowAdjust => this._shadowAdj;

  set shadowAdjust(Vector4? vec) {
    // ignore: parameter_assignments
    vec ??= Vector4.shadowAdjust;
    if (this._shadowAdj != vec) {
      final prev = this._shadowAdj;
      this._shadowAdj = vec;
      this._onChanged(ValueChangedEventArgs(this, 'shadowAdjust', prev, this._shadowAdj));
    }
  }

  /// The constant attenuation factor of the light.
  double get attenuation0 => this._attenuation0;

  set attenuation0(double attenuation0) {
    if (!Comparer.equals(this._attenuation0, attenuation0)) {
      final prev = this._attenuation0;
      this._attenuation0 = attenuation0;
      this._onChanged(ValueChangedEventArgs(this, 'attenuation0', prev, this._attenuation0));
    }
  }

  /// The linear attenuation factor of the light.
  double get attenuation1 => this._attenuation1;

  set attenuation1(double attenuation1) {
    if (!Comparer.equals(this._attenuation1, attenuation1)) {
      final prev = this._attenuation1;
      this._attenuation1 = attenuation1;
      this._onChanged(ValueChangedEventArgs(this, 'attenuation1', prev, this._attenuation1));
    }
  }

  /// The quadratic attenuation factor of the light.
  double get attenuation2 => this._attenuation2;

  set attenuation2(double attenuation2) {
    if (!Comparer.equals(this._attenuation2, attenuation2)) {
      final prev = this._attenuation2;
      this._attenuation2 = attenuation2;
      this._onChanged(ValueChangedEventArgs(this, 'attenuation2', prev, this._attenuation2));
    }
  }

  /// Indicates if attenuation should be determined or not.
  bool get enableAttenuation => this._enableAttn;

  set enableAttenuation(bool enable) {
    if (this._enableAttn != enable) {
      final prev = this._enableAttn;
      this._enableAttn = enable;
      this._onChanged(ValueChangedEventArgs(this, 'enableAttenuation', prev, this._enableAttn));
    }
  }
}

/// Storage for directional light data.
class Directional implements Light {
  Mover? _mover;
  Color3? _color;
  Vector3 _direction;
  Vector3 _up;
  Vector3 _right;
  Texture2D? _texture;
  Event? _changed;

  /// Creates a new directional light data.
  Directional({Mover? mover, Color3? color, Texture2D? texture})
      : this._mover = null,
        this._color = Color3.white(),
        this._direction = Vector3.posZ,
        this._up = Vector3.posY,
        this._right = Vector3.negX,
        this._texture = null,
        this._changed = null {
    this.mover = mover;
    this.color = color ?? Color3.white();
    this.texture = texture;
  }

  /// Emits when the light is changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a change in the light.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Updates the light with the current state.
  @override
  void update(RenderState state) {
    this._direction = Vector3.posZ;
    this._up = Vector3.posY;
    this._right = Vector3.negX;
    final mover = this._mover;
    if (mover != null) {
      final mat = mover.update(state, this);
      this._direction = mat.transVec3(this._direction).normal();
      this._up = mat.transVec3(this._up).normal();
      this._right = mat.transVec3(this._right).normal();
    }
  }

  /// The identifier for the configuration to use when
  /// setting up the shader using this light.
  int get configID => (this._texture != null) ? 0x01 : 0;

  /// The direction the light is pointing.
  /// Setting direction will override the mover with a constant mover pointing in the given direction.
  Vector3 get direction => this._direction;

  set direction(Vector3 vector) {
    this._mover = Constant.lookTowards(Point3.zero, Vector3.posY, vector);
  }

  /// The up vector of the texture for the light.
  Vector3 get up => this._up;

  /// The right vector of the texture for the light.
  Vector3 get right => this._right;

  /// The mover to position this light.
  @override
  Mover? get mover => this._mover;

  @override
  set mover(Mover? mover) {
    if (this._mover != mover) {
      this._mover?.changed.remove(this._onChanged);
      final prev = this._mover;
      this._mover = mover;
      this._mover?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'mover', prev, this._mover));
    }
  }

  /// The color of the light.
  Color3? get color => this._color;

  set color(Color3? color) {
    if (this._color != color) {
      final prev = this._color;
      this._color = color;
      this._onChanged(ValueChangedEventArgs(this, 'color', prev, this._color));
    }
  }

  /// The texture for the light.
  Texture2D? get texture => this._texture;

  set texture(Texture2D? texture) {
    if (this._texture != texture) {
      this._texture?.changed.remove(this._onChanged);
      final prev = this._texture;
      this._texture = texture;
      this._texture?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'texture', prev, this._texture));
    }
  }
}

/// The interface for any light.
abstract class Light implements Movable, Changeable {
  /// Updates the light with the current state.
  void update(RenderState state);
}

/// Storage for point light data.
class Point implements Light {
  Matrix4 _matrix;
  Mover? _mover;
  Color3? _color;
  TextureCube? _texture;
  TextureCube? _shadow;

  Vector4? _shadowAdj;
  double _attenuation0;
  double _attenuation1;
  double _attenuation2;
  bool _enableAttn;
  Event? _changed;

  /// Creates a new point light data.
  Point(
      {Mover? mover,
        Color3? color,
        TextureCube? texture,
        TextureCube? shadow,
        Vector4? shadowAdj,
        double attenuation0 = 1.0,
        double attenuation1 = 0.0,
        double attenuation2 = 0.0,
        bool enableAttenuation = true})
      : this._matrix = Matrix4.identity,
        this._mover = null,
        this._color = Color3.white(),
        this._texture = null,
        this._shadow = null,
        this._shadowAdj = null,
        this._attenuation0 = 1.0,
        this._attenuation1 = 0.0,
        this._attenuation2 = 0.0,
        this._enableAttn = true,
        this._changed = null {
    this.mover = mover;
    this.color = color;
    this.texture = texture;
    this.shadow = shadow;
    this.shadowAdjust = shadowAdj;
    this.attenuation0 = attenuation0;
    this.attenuation1 = attenuation1;
    this.attenuation2 = attenuation2;
    this.enableAttenuation = enableAttenuation;
  }

  /// Emits when the light is changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles changes to the light.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Updates the light with the current state.
  @override
  void update(RenderState state) => this._matrix = this._mover?.update(state, this) ?? Matrix4.identity;

  /// The identifier for the configuration to use when
  /// setting up the shader using this light.
  int get configID =>
      ((this._texture != null) ? 0x01 : 0) + ((this._shadow != null) ? 0x02 : 0) + (this._enableAttn ? 0x04 : 0);

  /// The rotation and position of the point light.
  Matrix4 get matrix => this._matrix;

  /// The mover to position this light.
  @override
  Mover? get mover => this._mover;

  @override
  set mover(Mover? mover) {
    if (this._mover != mover) {
      this._mover?.changed.remove(this._onChanged);
      final prev = this._mover;
      this._mover = mover;
      this._mover?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'mover', prev, this._mover));
    }
  }

  /// The color of the light.
  Color3? get color => this._color;

  set color(Color3? color) {
    // ignore: parameter_assignments
    color ??= Color3.white();
    if (this._color != color) {
      final prev = this._color;
      this._color = color;
      this._onChanged(ValueChangedEventArgs(this, 'color', prev, this._color));
    }
  }

  /// The color texture of the light.
  TextureCube? get texture => this._texture;

  set texture(TextureCube? texture) {
    if (this._texture != texture) {
      this._texture?.changed.remove(this._onChanged);
      final prev = this._texture;
      this._texture = texture;
      this._texture?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'texture', prev, this._texture));
    }
  }

  /// The shadow depth texture of the light.
  TextureCube? get shadow => this._shadow;

  set shadow(TextureCube? shadow) {
    if (this._shadow != shadow) {
      this._shadow?.changed.remove(this._onChanged);
      final prev = this._shadow;
      this._shadow = shadow;
      this._shadow?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'shadow', prev, this._shadow));
    }
  }

  /// The shadow value modification vector.
  /// This is the vector to apply to the color from the shadow texture
  /// to get the shadow value from the shadow texture.
  Vector4? get shadowAdjust => this._shadowAdj;

  set shadowAdjust(Vector4? vec) {
    // ignore: parameter_assignments
    vec ??= Vector4.shadowAdjust;
    if (this._shadowAdj != vec) {
      final prev = this._shadowAdj;
      this._shadowAdj = vec;
      this._onChanged(ValueChangedEventArgs(this, 'shadowAdjust', prev, this._shadowAdj));
    }
  }

  /// The constant attenuation factor of the light.
  double get attenuation0 => this._attenuation0;

  set attenuation0(double attenuation0) {
    if (!Comparer.equals(this._attenuation0, attenuation0)) {
      final prev = this._attenuation0;
      this._attenuation0 = attenuation0;
      this._onChanged(ValueChangedEventArgs(this, 'attenuation0', prev, this._attenuation0));
    }
  }

  /// The linear attenuation factor of the light.
  double get attenuation1 => this._attenuation1;

  set attenuation1(double attenuation1) {
    if (!Comparer.equals(this._attenuation1, attenuation1)) {
      final prev = this._attenuation1;
      this._attenuation1 = attenuation1;
      this._onChanged(ValueChangedEventArgs(this, 'attenuation1', prev, this._attenuation1));
    }
  }

  /// The quadratic attenuation factor of the light.
  double get attenuation2 => this._attenuation2;

  set attenuation2(double attenuation2) {
    if (!Comparer.equals(this._attenuation2, attenuation2)) {
      final prev = this._attenuation2;
      this._attenuation2 = attenuation2;
      this._onChanged(ValueChangedEventArgs(this, 'attenuation2', prev, this._attenuation2));
    }
  }

  /// Indicates if attenuation should be determined or not.
  bool get enableAttenuation => this._enableAttn;

  set enableAttenuation(bool enable) {
    if (this._enableAttn != enable) {
      final prev = this._enableAttn;
      this._enableAttn = enable;
      this._onChanged(ValueChangedEventArgs(this, 'enableAttenuation', prev, this._enableAttn));
    }
  }
}

/// Storage for spot light data.
class Spot implements Light {
  Point3 _position;
  Vector3 _direction;
  Vector3 _up;
  Vector3 _right;
  Vector4? _shadowAdj;
  Mover? _mover;
  Color3? _color;
  Texture2D? _texture;
  Texture2D? _shadow;
  double _tuScalar;
  double _tvScalar;
  double _fov;
  double _ratio;
  double _cutoff;
  bool _enableCutOff;
  double _coneAngle;
  double _attenuation0;
  double _attenuation1;
  double _attenuation2;
  bool _enableAttn;
  Event? _changed;

  /// Creates a new spot light data.
  Spot(
      {Mover? mover,
        Color3? color,
        Texture2D? texture,
        Texture2D? shadow,
        Vector4? shadowAdj,
        double fov = PI_3,
        double ratio = 1.0,
        double cutoff = PI_2,
        double coneAngle = PI_2,
        double attenuation0 = 1.0,
        double attenuation1 = 0.0,
        double attenuation2 = 0.0,
        bool enableCutOff = true,
        bool enableAttenuation = true})
      : this._position = Point3.zero,
        this._direction = Vector3.posZ,
        this._up = Vector3.posY,
        this._right = Vector3.negX,
        this._shadowAdj = null,
        this._mover = null,
        this._color = Color3.white(),
        this._texture = null,
        this._shadow = null,
        this._tuScalar = 1.0,
        this._tvScalar = 1.0,
        this._fov = PI_3,
        this._ratio = 1.0,
        this._cutoff = PI_2,
        this._enableCutOff = true,
        this._coneAngle = PI_2,
        this._attenuation0 = 1.0,
        this._attenuation1 = 0.0,
        this._attenuation2 = 0.0,
        this._enableAttn = true,
        this._changed = null {
    this.mover = mover;
    this.color = color;
    this.texture = texture;
    this.shadow = shadow;
    this.fov = fov;
    this.ratio = ratio;
    this.cutoff = cutoff;
    this.coneAngle = coneAngle;
    this.shadowAdjust = shadowAdj;
    this.attenuation0 = attenuation0;
    this.attenuation1 = attenuation1;
    this.attenuation2 = attenuation2;
    this.enableCutOff = enableCutOff;
    this.enableAttenuation = enableAttenuation;
  }

  /// The event emitted when the light has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles changes to the light.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Updates the light with the current state.
  @override
  void update(RenderState state) {
    this._position = Point3.zero;
    this._direction = Vector3.posZ;
    this._up = Vector3.posY;
    this._right = Vector3.negX;
    final mover = this._mover;
    if (mover != null) {
      final mat = mover.update(state, this);
      this._position = mat.transPnt3(this._position);
      this._direction = mat.transVec3(this._direction).normal();
      this._up = mat.transVec3(this._up).normal();
      this._right = mat.transVec3(this._right).normal();
    }
  }

  /// The identifier for the configuration to use when
  /// setting up the shader using this light.
  int get configID =>
      ((this._texture != null) ? 0x01 : 0) +
          ((this._shadow != null) ? 0x02 : 0) +
          (this._enableAttn ? 0x04 : 0) +
          (this._enableCutOff ? 0x08 : 0);

  /// The location the light.
  Point3 get position => this._position;

  /// The direction the light is pointing.
  Vector3 get direction => this._direction;

  /// The up direction of the light.
  Vector3 get up => this._up;

  /// The right direction of the light.
  Vector3 get right => this._right;

  /// The mover to position this light.
  @override
  Mover? get mover => this._mover;

  @override
  set mover(Mover? mover) {
    if (this._mover != mover) {
      this._mover?.changed.remove(this._onChanged);
      final prev = this._mover;
      this._mover = mover;
      this._mover?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'mover', prev, this._mover));
    }
  }

  /// The color of the light.
  Color3? get color => this._color;

  set color(Color3? color) {
    // ignore: parameter_assignments
    color ??= Color3.white();
    if (this._color != color) {
      final prev = this._color;
      this._color = color;
      this._onChanged(ValueChangedEventArgs(this, 'color', prev, this._color));
    }
  }

  /// The color texture for the light.
  Texture2D? get texture => this._texture;

  set texture(Texture2D? texture) {
    if (this._texture != texture) {
      this._texture?.changed.remove(this._onChanged);
      final prev = this._texture;
      this._texture = texture;
      this._texture?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'texture', prev, this._texture));
    }
  }

  /// The shadow depth texture for the light.
  Texture2D? get shadow => this._shadow;

  set shadow(Texture2D? shadow) {
    if (this._shadow != shadow) {
      this._shadow?.changed.remove(this._onChanged);
      final prev = this._shadow;
      this._shadow = shadow;
      this._shadow?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'shadow', prev, this._shadow));
    }
  }

  /// The shadow value modification vector.
  /// This is the vector to apply to the color from the shadow texture
  /// to get the shadow value from the shadow texture.
  Vector4? get shadowAdjust => this._shadowAdj;

  set shadowAdjust(Vector4? vec) {
    // ignore: parameter_assignments
    vec ??= Vector4.shadowAdjust;
    if (this._shadowAdj != vec) {
      final prev = this._shadowAdj;
      this._shadowAdj = vec;
      this._onChanged(ValueChangedEventArgs(this, 'shadowAdjust', prev, this._shadowAdj));
    }
  }

  /// The vertical texture scalar of the light.
  double get tuScalar => this._tuScalar;

  /// The horizontal texture scalar of the light.
  double get tvScalar => this._tvScalar;

  /// The field-of-view of the light in the y-axis (up) of the texture.
  double get fov => this._fov;

  set fov(double fov) {
    // ignore: parameter_assignments
    fov = clampVal(fov, 0.0, PI);
    if (!Comparer.equals(this._fov, fov)) {
      final prev = this._fov;
      this._fov = fov;
      this._tuScalar = 1.0 / (math.sqrt(2.0) * math.tan(this._fov));
      this._tvScalar = this._tuScalar * this._ratio;
      this._onChanged(ValueChangedEventArgs(this, 'fov', prev, this._fov));
    }
  }

  /// The ratio width to height of the texture.
  double get ratio => this._ratio;

  set ratio(double ratio) {
    if (!Comparer.equals(this._ratio, ratio)) {
      final prev = this._ratio;
      this._ratio = ratio;
      this._tvScalar = this._tuScalar * this._ratio;
      this._onChanged(ValueChangedEventArgs(this, 'ratio', prev, this._ratio));
    }
  }

  /// The cut-off angle, in radians, of the light cone.
  double get cutoff => this._cutoff;

  set cutoff(double cutoff) {
    // ignore: parameter_assignments
    cutoff = clampVal(cutoff, 0.0, PI);
    if (!Comparer.equals(this._cutoff, cutoff)) {
      final prev = this._cutoff;
      this._cutoff = cutoff;
      this._onChanged(ValueChangedEventArgs(this, 'cutoff', prev, this._cutoff));
    }
  }

  /// The cone angle, in radians, of the light.
  double get coneAngle => this._coneAngle;

  set coneAngle(double coneAngle) {
    // ignore: parameter_assignments
    coneAngle = clampVal(coneAngle, 0.0, PI);
    if (!Comparer.equals(this._coneAngle, coneAngle)) {
      final prev = this._coneAngle;
      this._coneAngle = coneAngle;
      this._onChanged(ValueChangedEventArgs(this, 'coneAngle', prev, this._coneAngle));
    }
  }

  /// Indicates if cone cutoff should be applied or not.
  bool get enableCutOff => this._enableCutOff;

  set enableCutOff(bool enable) {
    if (this._enableCutOff != enable) {
      final prev = this._enableCutOff;
      this._enableCutOff = enable;
      this._onChanged(ValueChangedEventArgs(this, 'enableCutOff', prev, this._enableCutOff));
    }
  }

  /// The constant attenuation factor of the light.
  double get attenuation0 => this._attenuation0;

  set attenuation0(double attenuation0) {
    if (!Comparer.equals(this._attenuation0, attenuation0)) {
      final prev = this._attenuation0;
      this._attenuation0 = attenuation0;
      this._onChanged(ValueChangedEventArgs(this, 'attenuation0', prev, this._attenuation0));
    }
  }

  /// The linear attenuation factor of the light.
  double get attenuation1 => this._attenuation1;

  set attenuation1(double attenuation1) {
    if (!Comparer.equals(this._attenuation1, attenuation1)) {
      final prev = this._attenuation1;
      this._attenuation1 = attenuation1;
      this._onChanged(ValueChangedEventArgs(this, 'attenuation1', prev, this._attenuation1));
    }
  }

  /// The quadratic attenuation factor of the light.
  double get attenuation2 => this._attenuation2;

  set attenuation2(double attenuation2) {
    if (!Comparer.equals(this._attenuation2, attenuation2)) {
      final prev = this._attenuation2;
      this._attenuation2 = attenuation2;
      this._onChanged(ValueChangedEventArgs(this, 'attenuation2', prev, this._attenuation2));
    }
  }

  /// Indicates if attenuation should be determined or not.
  bool get enableAttenuation => this._enableAttn;

  set enableAttenuation(bool enable) {
    if (this._enableAttn != enable) {
      final prev = this._enableAttn;
      this._enableAttn = enable;
      this._onChanged(ValueChangedEventArgs(this, 'enableAttenuation', prev, this._enableAttn));
    }
  }
}
