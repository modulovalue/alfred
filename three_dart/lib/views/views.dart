// Views describes the cameras and render targets.
//
// The cameras define the mathematics for the projection of the render scene.
// The render targets are the storage mechanism or buffers to write the scene
// to. Together they create the view into a scene.
import 'dart:web_gl' as webgl;

import '../core/core.dart';
import '../events/events.dart';
import '../math/math.dart';
import '../movers/movers.dart';
import '../textures/textures.dart';

/// A rendering target which renders to a texture instead of the screen.
class BackTarget extends Target {
  int _width;
  int _height;
  int _actualWidth;
  int _actualHeight;
  final bool _hasDepth;
  bool _autoResize;
  double _autoResizeScalarX;
  double _autoResizeScalarY;
  webgl.Framebuffer? _framebuffer;
  webgl.Texture? _colorBuffer;
  webgl.Renderbuffer? _depthBuffer;
  final Texture2DSolid _colorTxt;
  Color4? _color;
  bool _clearColor;
  double _depth;
  bool _clearDepth;
  Region2? _region;
  Event? _changed;

  /// Creates a new back target.
  BackTarget(
      {int width = 512,
        int height = 512,
        bool autoResize = false,
        double autoResizeScalarX = 1.0,
        double autoResizeScalarY = 1.0,
        Color4? color,
        bool clearColor = true,
        double depth = 2000.0,
        bool clearDepth = true,
        Region2? region})
      : this._width = 512,
        this._height = 512,
        this._actualWidth = 512,
        this._actualHeight = 512,
        this._hasDepth = true,
        this._autoResize = false,
        this._autoResizeScalarX = 1.0,
        this._autoResizeScalarY = 1.0,
        this._framebuffer = null,
        this._colorBuffer = null,
        this._depthBuffer = null,
        this._colorTxt = Texture2DSolid(),
        this._color = Color4.black(),
        this._clearColor = true,
        this._depth = 2000.0,
        this._clearDepth = true,
        this._region = Region2.unit,
        this._changed = null {
    this.width = width;
    this.height = height;
    this.color = color;
    this.clearColor = clearColor;
    this.depth = depth;
    this.clearDepth = clearDepth;
    this.autoResize = autoResize;
    this.autoResizeScalarX = autoResizeScalarX;
    this.autoResizeScalarY = autoResizeScalarY;
    this.region = region;
  }

  /// Indicates that this target has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a change in this target.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Handles a change of a boolean value.
  void _onBoolChanged(String name, bool value) =>
      this._onChanged(ValueChangedEventArgs(this, name, !value, value));

  /// The requested width in pixels of the back buffer.
  int get width => this._width;

  set width(int width) {
    // ignore: parameter_assignments
    if (width < 1) width = 1;
    if (this._width != width) {
      final int old = this._width;
      this._framebuffer = null;
      this._width = width;
      this._actualWidth = width;
      this._onChanged(ValueChangedEventArgs(this, 'width', old, width));
    }
  }

  /// The requested height in pixels of the back buffer.
  int get height => this._height;

  set height(int height) {
    // ignore: parameter_assignments
    if (height < 1) height = 1;
    if (this._height != height) {
      final int old = this._height;
      this._framebuffer = null;
      this._height = height;
      this._actualHeight = height;
      this._onChanged(ValueChangedEventArgs(this, 'height', old, height));
    }
  }

  /// The actual width in pixel of the back buffer.
  int get actualWidth => this._actualWidth;

  /// The actual height in pixel of the back buffer.
  int get actualHeight => this._actualHeight;

  /// Indicates is a back buffer has ben attached to this back target.
  /// True indicates depth is enabled.
  bool get hasDepth => this._hasDepth;

  /// The color texture which is being rendered to.
  Texture2D get colorTexture => this._colorTxt;

  /// The clear color to clear the target to before rendering.
  Color4? get color => this._color;

  set color(Color4? color) {
    // ignore: parameter_assignments
    color ??= Color4.black();
    if (this._color != color) {
      final Color4? prev = this._color;
      this._color = color;
      this._onChanged(ValueChangedEventArgs(this, 'color', prev, this._color));
    }
  }

  /// Indicates if the color target should be cleared with the clear color.
  bool get clearColor => this._clearColor;

  set clearColor(bool clearColor) {
    if (this._clearColor != clearColor) {
      this._clearColor = clearColor;
      this._onBoolChanged('clearColor', this._clearColor);
    }
  }

  /// The clear depth to clear the target to before rendering.
  double get depth => this._depth;

  set depth(double depth) {
    if (!Comparer.equals(this._depth, depth)) {
      final double prev = this._depth;
      this._depth = depth;
      this._onChanged(ValueChangedEventArgs(this, 'depth', prev, this._depth));
    }
  }

  /// Indicates if the depth target should be cleared with the clear depth.
  bool get clearDepth => this._clearDepth;

  set clearDepth(bool clearDepth) {
    if (this._clearDepth != clearDepth) {
      this._clearDepth = clearDepth;
      this._onBoolChanged('clearDepth', this._clearDepth);
    }
  }

  /// Indicates if the target buffer should automatically resize to the size of the canvas.
  bool get autoResize => this._autoResize;

  set autoResize(bool autoResize) {
    if (this._autoResize != autoResize) {
      this._autoResize = autoResize;
      this._onBoolChanged('autoResize', this._autoResize);
    }
  }

  /// The scalar to apply to the width when an automatic resize occurs.
  double get autoResizeScalarX => this._autoResizeScalarX;

  set autoResizeScalarX(double scalar) {
    if (!Comparer.equals(this._autoResizeScalarX, scalar)) {
      final double prev = this._autoResizeScalarX;
      this._autoResizeScalarX = scalar;
      this._onChanged(ValueChangedEventArgs(this, 'autoResizeScalarX', prev, this._autoResizeScalarX));
    }
  }

  /// The scalar to apply to the height when an automatic resize occurs.
  double get autoResizeScalarY => this._autoResizeScalarY;

  set autoResizeScalarY(double scalar) {
    if (!Comparer.equals(this._autoResizeScalarY, scalar)) {
      final double prev = this._autoResizeScalarY;
      this._autoResizeScalarY = scalar;
      this._onChanged(ValueChangedEventArgs(this, 'autoResizeScalarY', prev, this._autoResizeScalarY));
    }
  }

  /// The region of the front target to render to.
  /// <0, 0> is top left corner and <1, 1> is bottom right.
  @override
  Region2? get region => this._region;

  @override
  set region(Region2? region) {
    // ignore: parameter_assignments
    region ??= Region2.unit;
    if (this._region != region) {
      final Region2? prev = this._region;
      this._region = region;
      this._onChanged(ValueChangedEventArgs(this, 'region', prev, this._region));
    }
  }

  /// Initializes the back target.
  void _initialize(webgl.RenderingContext2 gl) {
    // Setup color buffer
    this._colorTxt.replace(Texture2DSolid.fromSize(gl, this._width, this._height));
    this._colorBuffer = this._colorTxt.texture;
    this._actualWidth = this._colorTxt.actualWidth;
    this._actualHeight = this._colorTxt.actualHeight;
    gl.bindTexture(webgl.WebGL.TEXTURE_2D, this._colorBuffer);

    // Setup depth buffer.
    if (this._hasDepth) {
      this._depthBuffer = gl.createRenderbuffer();
      gl.bindRenderbuffer(webgl.WebGL.RENDERBUFFER, this._depthBuffer);
      gl.renderbufferStorage(
          webgl.WebGL.RENDERBUFFER, webgl.WebGL.DEPTH_COMPONENT16, this._actualWidth, this._actualHeight);
    }

    // Bind render buffers to a render target frame buffer.
    this._framebuffer = gl.createFramebuffer();
    gl.bindFramebuffer(webgl.WebGL.FRAMEBUFFER, this._framebuffer);
    gl.framebufferTexture2D(
        webgl.WebGL.FRAMEBUFFER, webgl.WebGL.COLOR_ATTACHMENT0, webgl.WebGL.TEXTURE_2D, this._colorBuffer, 0);
    if (this._hasDepth) {
      gl.framebufferRenderbuffer(
          webgl.WebGL.FRAMEBUFFER, webgl.WebGL.DEPTH_ATTACHMENT, webgl.WebGL.RENDERBUFFER, this._depthBuffer);
    }

    // Clean up and release buffers.
    gl.bindTexture(webgl.WebGL.TEXTURE_2D, null);
    if (this._hasDepth) gl.bindRenderbuffer(webgl.WebGL.RENDERBUFFER, null);
    gl.bindFramebuffer(webgl.WebGL.FRAMEBUFFER, null);
  }

  /// Binds this target to the [state].
  @override
  void bind(RenderState state) {
    if (this._autoResize) {
      this.width = ((state.gl.drawingBufferWidth ?? 512) * this._autoResizeScalarX).round();
      this.height = ((state.gl.drawingBufferHeight ?? 512) * this._autoResizeScalarY).round();
    }

    if (this._framebuffer == null) {
      this._initialize(state.gl);
    }

    state.gl.bindFramebuffer(webgl.WebGL.FRAMEBUFFER, this._framebuffer);
    state.gl.enable(webgl.WebGL.CULL_FACE);
    if (this._hasDepth) state.gl.enable(webgl.WebGL.DEPTH_TEST);
    state.gl.depthFunc(webgl.WebGL.LESS);

    final Region2 region = this._region ?? Region2.unit;
    state.width = (region.dx * this._width).round();
    state.height = (region.dy * this._height).round();
    final int xOffset = (region.x * this._actualWidth).round();
    final int yOffset = (region.y * this._actualHeight).round();
    final int width = (region.dx * this._actualWidth).round();
    final int height = (region.dy * this._actualHeight).round();
    state.gl.viewport(xOffset, yOffset, width, height);

    int clearMask = 0;
    if (this._clearDepth && this._hasDepth) {
      state.gl.clearDepth(this._depth);
      clearMask |= webgl.WebGL.DEPTH_BUFFER_BIT;
    }
    if (this._clearColor) {
      state.gl.clearColor(
          this._color?.red ?? 0.0, this._color?.green ?? 0.0, this._color?.blue ?? 0.0, this._color?.alpha ?? 1.0);
      clearMask |= webgl.WebGL.COLOR_BUFFER_BIT;
    }
    if (clearMask > 0) {
      state.gl.clear(clearMask);
    }
  }

  /// Unbinds this target from the [state].
  @override
  void unbind(RenderState state) {
    state.gl.bindFramebuffer(webgl.WebGL.FRAMEBUFFER, null);
  }
}

/// A camera defining how the rendering is being viewed.
abstract class Camera implements Bindable, Changeable, Movable {
  // Empty
}

/// The front target to write the result of a render to the HTML canvas.
class FrontTarget extends Target {
  Color4 _color;
  bool _clearColor;
  double _depth;
  bool _clearDepth;
  int _stencil;
  bool _clearStencil;
  Region2 _region;
  Event? _changed;

  /// Constructs a new front target.
  FrontTarget(
      {Color4? color,
        bool clearColor = true,
        double depth = 2000.0,
        bool clearDepth = true,
        int stencil = 0,
        bool clearStencil = false,
        Region2? region})
      : this._color = color ?? Color4.black(),
        this._clearColor = clearColor,
        this._depth = depth,
        this._clearDepth = clearDepth,
        this._stencil = stencil,
        this._clearStencil = clearStencil,
        this._region = region ?? Region2.unit,
        this._changed = null;

  /// Indicates that this target has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a change in this target.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Handles a change of a boolean value.
  void _onBoolChanged(String name, bool value) =>
      this._onChanged(ValueChangedEventArgs(this, name, !value, value));

  /// The clear color to clear the target to before rendering.
  Color4 get color => this._color;

  set color(Color4 color) {
    if (this._color != color) {
      final Color4 prev = this._color;
      this._color = color;
      this._onChanged(ValueChangedEventArgs(this, 'color', prev, this._color));
    }
  }

  /// Indicates if the color target should be cleared with the clear color.
  bool get clearColor => this._clearColor;

  set clearColor(bool clearColor) {
    if (this._clearColor != clearColor) {
      this._clearColor = clearColor;
      this._onBoolChanged('clearColor', this._clearColor);
    }
  }

  /// The clear depth to clear the target to before rendering.
  double get depth => this._depth;

  set depth(double depth) {
    if (!Comparer.equals(this._depth, depth)) {
      final double prev = this._depth;
      this._depth = depth;
      this._onChanged(ValueChangedEventArgs(this, 'depth', prev, this._depth));
    }
  }

  /// Indicates if the depth target should be cleared with the clear depth.
  bool get clearDepth => this._clearDepth;

  set clearDepth(bool clearDepth) {
    if (this._clearDepth = clearDepth) {
      this._clearDepth = clearDepth;
      this._onBoolChanged('clearDepth', this._clearDepth);
    }
  }

  /// The clear stencil value to clear the stencil target to before rendering.
  int get stencil => this._stencil;

  set stencil(int stencil) {
    if (this._stencil != stencil) {
      final int prev = this._stencil;
      this._stencil = stencil;
      this._onChanged(ValueChangedEventArgs(this, 'stencil', prev, this._stencil));
    }
  }

  /// Indicates if the stencil target should be cleared with the clear stencil.
  bool get clearStencil => this._clearStencil;

  set clearStencil(bool clearStencil) {
    if (this._clearStencil != clearStencil) {
      this._clearStencil = clearStencil;
      this._onBoolChanged('clearStencil', this._clearStencil);
    }
  }

  /// The region of the front target to render to.
  /// <0, 0> is top left corner and <1, 1> is bottom right.
  @override
  Region2? get region => this._region;

  @override
  set region(Region2? region) {
    // ignore: parameter_assignments
    region ??= Region2.unit;
    if (this._region != region) {
      final Region2 prev = this._region;
      this._region = region;
      this._onChanged(ValueChangedEventArgs(this, 'region', prev, this._region));
    }
  }

  /// Binds this target to the given state so that the following render
  /// will target the front target.
  @override
  void bind(RenderState state) {
    state.gl.bindFramebuffer(webgl.WebGL.FRAMEBUFFER, null);
    state.gl.enable(webgl.WebGL.CULL_FACE);
    state.gl.enable(webgl.WebGL.DEPTH_TEST);
    state.gl.depthFunc(webgl.WebGL.LESS);

    final int width = state.gl.drawingBufferWidth ?? 512;
    final int height = state.gl.drawingBufferHeight ?? 512;
    final int xOffset = (this._region.x * width).round();
    final int yOffset = (this._region.y * height).round();
    state.width = (this._region.dx * width).round();
    state.height = (this._region.dy * height).round();
    state.gl.viewport(xOffset, yOffset, state.width, state.height);

    int clearMask = 0;
    if (this._clearStencil) {
      state.gl.clearStencil(this._stencil);
      clearMask |= webgl.WebGL.STENCIL_BUFFER_BIT;
    }
    if (this._clearDepth) {
      state.gl.clearDepth(this._depth);
      clearMask |= webgl.WebGL.DEPTH_BUFFER_BIT;
    }
    if (this._clearColor) {
      state.gl.clearColor(this._color.red, this._color.green, this._color.blue, this._color.alpha);
      clearMask |= webgl.WebGL.COLOR_BUFFER_BIT;
    }
    if (clearMask > 0) {
      state.gl.clear(clearMask);
    }
  }

  /// Unbinds the front target.
  /// Actually has no effect because the front target is the default target.
  @override
  void unbind(RenderState state) {
    // Empty
  }
}

/// A identity camera for rendering of a scene.
class IdentityCamera implements Camera {
  Mover? _mover;
  Event? _changed;

  /// Creates a new identity camera.
  IdentityCamera({Mover? mover})
      : this._mover = mover,
        this._changed = null;

  /// Indicates that this target has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a change in this target.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// The mover to position this camera.
  @override
  Mover? get mover => this._mover;

  @override
  set mover(Mover? mover) {
    if (this._mover != mover) {
      this._mover?.changed.remove(this._onChanged);
      final Mover? prev = this._mover;
      this._mover = mover;
      this._mover?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'mover', prev, this._mover));
    }
  }

  /// Binds this camera to the state.
  @override
  void bind(RenderState state) {
    state.projection.push(Matrix4.identity);
    Matrix4 look = Matrix4.identity;
    final mover = this.mover;
    if (mover != null) {
      final Matrix4 mat = mover.update(state, this);
      look = mat * look;
    }
    state.view.push(look);
  }

  /// Unbinds this camera and returns to the previous camera.
  @override
  void unbind(RenderState state) {
    state.projection.pop();
    state.view.pop();
  }
}

/// A camera for a perspective rendering of a scene.
class Perspective implements Camera {
  static final Matrix4 _lookMat = Matrix4.lookTowards(Point3.zero, Vector3.posY, Vector3.negZ);

  Mover? _premover;
  Mover? _mover;
  double _fov;
  double _near;
  double _far;
  Event? _changed;

  /// Creates a new perspective camera.
  Perspective(
      {Mover? premover,
        Mover? mover,
        double fov = PI_3,
        double near = 0.1,
        double far = 2000.0})
      : this._premover = null,
        this._mover = null,
        this._fov = PI_3,
        this._near = 0.1,
        this._far = 2000.0,
        this._changed = null {
    this.premover = premover;
    this.mover = mover;
    this.fov = fov;
    this.near = near;
    this.far = far;
  }

  /// Indicates that this target has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a change in this target.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Field of view vertically in radians of the camera.
  double get fov => this._fov;

  set fov(double fov) {
    if (!Comparer.equals(this._fov, fov)) {
      final double prev = this._fov;
      this._fov = fov;
      this._onChanged(ValueChangedEventArgs(this, 'fov', prev, this._fov));
    }
  }

  /// The near depth, distance from the camera, to start rendering at.
  double get near => this._near;

  set near(double near) {
    if (!Comparer.equals(this._near, near)) {
      final double prev = this._near;
      this._near = near;
      this._onChanged(ValueChangedEventArgs(this, 'near', prev, this._near));
    }
  }

  /// The far depth, distance from the camera, to stop rendering at.
  double get far => this._far;

  set far(double far) {
    if (!Comparer.equals(this._far, far)) {
      final double prev = this._far;
      this._far = far;
      this._onChanged(ValueChangedEventArgs(this, 'far', prev, this._far));
    }
  }

  /// The mover to position this camera.
  @override
  Mover? get mover => this._mover;

  @override
  set mover(Mover? mover) {
    if (this._mover != mover) {
      this._mover?.changed.remove(this._onChanged);
      final Mover? prev = this._mover;
      this._mover = mover;
      this._mover?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'mover', prev, this._mover));
    }
  }

  /// The mover to offset the focal point of the world prior to the camera projection.
  Mover? get premover => this._premover;

  set premover(Mover? mover) {
    if (this._premover != mover) {
      this._premover?.changed.remove(this._onChanged);
      final Mover? prev = this._premover;
      this._premover = mover;
      this._premover?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'premover', prev, this._premover));
    }
  }

  /// Binds this camera to the state.
  @override
  void bind(RenderState state) {
    final double aspect = state.width.toDouble() / state.height.toDouble();
    Matrix4 proj = Matrix4.perspective(this._fov, aspect, this._near, this._far);
    final premover = this._premover;
    if (premover != null) {
      final Matrix4 mat = premover.update(state, this);
      proj = mat * proj;
    }
    state.projection.push(proj);

    Matrix4 look = _lookMat;
    final mover = this._mover;
    if (mover != null) {
      final Matrix4 mat = mover.update(state, this);
      look = mat * look;
    }
    state.view.push(look);
  }

  /// Unbinds this camera and returns to the previous camera.
  @override
  void unbind(RenderState state) {
    state.projection.pop();
    state.view.pop();
  }
}

/// A camera for an orthogonal rendering of a scene.
class Orthogonal implements Camera {
  Mover? _mover;
  double _near;
  double _far;
  Event? _changed;

  /// Creates a new orthogonal camera.
  Orthogonal({Mover? mover, double near = 1.0, double far = 100.0})
      : this._mover = mover,
        this._near = near,
        this._far = far,
        this._changed = null;

  /// Indicates that this target has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a change in this target.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// The near depth, distance from the camera, to start rendering at.
  double get near => this._near;

  set near(double near) {
    if (!Comparer.equals(this._near, near)) {
      final double prev = this._near;
      this._near = near;
      this._onChanged(ValueChangedEventArgs(this, 'near', prev, this._near));
    }
  }

  /// The far depth, distance from the camera, to stop rendering at.
  double get far => this._far;

  set far(double far) {
    if (!Comparer.equals(this._far, far)) {
      final double prev = this._far;
      this._far = far;
      this._onChanged(ValueChangedEventArgs(this, 'far', prev, this._far));
    }
  }

  /// The mover to position this camera.
  @override
  Mover? get mover => this._mover;

  @override
  set mover(Mover? mover) {
    if (this._mover != mover) {
      this._mover?.changed.remove(this._onChanged);
      final Mover? prev = this._mover;
      this._mover = mover;
      this._mover?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'mover', prev, this._mover));
    }
  }

  /// Binds this camera to the state.
  @override
  void bind(RenderState state) {
    final double width = state.width.toDouble() * 0.5;
    final double height = state.height.toDouble() * 0.5;
    state.projection.push(Matrix4.ortho(-width, width, -height, height, this._near, this._far));

    Matrix4 look = Matrix4.lookTowards(Point3.zero, Vector3.posY, Vector3.posZ);
    final mover = this.mover;
    if (mover != null) {
      final Matrix4 mat = mover.update(state, this);
      look = look * mat;
    }
    state.view.push(look);
  }

  /// Unbinds this camera and returns to the previous camera.
  @override
  void unbind(RenderState state) {
    state.projection.pop();
    state.view.pop();
  }
}

/// The target to write the result of a render to when rendering.
abstract class Target implements Bindable, Changeable {
  /// The region of the front target to render to.
  /// <0, 0> is top left corner and <1, 1> is bottom right.
  Region2? get region;

  set region(Region2? region);
}
