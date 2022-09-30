// Techniques are a set of rendering styles which can be applied to objects in the
// scene to creates specific look, feel, and effects. The techniques use shaders
// to perform the render.

import 'dart:math' as math;
import 'dart:web_gl' as webgl;

import 'collections.dart';
import 'core.dart';
import 'data.dart';
import 'events.dart' as events;
import 'lights.dart' as lights_;
import 'math.dart';
import 'shaders.dart' as shaders;
import 'shapes.dart';
import 'textures.dart';

/// A technique for debugging entities with by writing strings to a buffer
/// which can be compared against instead of rendering to the target.
class Debugger extends Technique {
  /// Buffer to write output to, or null not to output.
  final StringBuffer? _buf;

  /// The list of resulting points from a render.
  final List<Point3> _results;

  /// An event to indicate when this technique has been changed.
  events.Event? _changed;

  /// Creates a new debugging technique.
  Debugger([this._buf])
      : this._results = [],
        this._changed = null;

  /// The list of resulting points from a render.
  List<Point3> get results => this._results;

  /// Since there are no setting, this is currently never emitted.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Updates this technique for the given state.
  @override
  void update(RenderState state) {
    // Do Nothing
  }

  /// Renders this technique for the given state and entity.
  @override
  void render(RenderState state, Entity obj) {
    final Matrix4 projMat = state.projection.matrix;
    final Matrix4 viewMat = state.view.matrix;
    final Matrix4 objMat = state.object.matrix;
    final buf = this._buf;

    if (buf != null) {
      buf.write('Object:     ' + objMat.format('            ') + '\n\n');
      buf.write('View:       ' + viewMat.format('            ') + '\n\n');
      buf.write('Projection: ' + projMat.format('            ') + '\n\n');
    }

    this._results.clear();
    if (obj.shape != null) {
      final VertexCollection? vertices = obj.shape?.vertices;
      if (vertices == null) return;
      final int length = vertices.length;
      for (int i = 0; i < length; ++i) {
        final Point3 pnt0 = vertices[i].location ?? Point3.zero;
        final Point4 pnt1 = Point4.fromPoint3(pnt0, 1.0);
        final Point4 pnt2 = objMat.transPnt4(pnt1);
        final Point4 pnt3 = viewMat.transPnt4(pnt2);
        final Point4 pnt4 = projMat.transPnt4(pnt3);
        final Point3 pnt5 = Point3.fromPoint4(pnt4) / pnt4.w;

        if (buf != null) {
          buf.write(pnt1.format(3, 2) +
              ' => ' +
              pnt2.format(3, 2) +
              ' => ' +
              pnt3.format(3, 2) +
              ' => ' +
              pnt4.format(3, 2) +
              ' => ' +
              pnt5.format(3, 2) +
              '\n');
        }

        this._results.add(pnt5);
      }
    }
  }
}

/// A technique for rendering entities with a depth fog.
class Depth extends Technique {
  shaders.Depth? _shader;
  double _start;
  double _stop;
  bool _grey;
  bool _invert;
  bool _focus;
  events.Event? _changed;

  /// Creates a new depth technique with the given initial values.
  Depth({double start = 1.0, double stop = 10.0, bool grey = false, bool invert = false, bool focus = false})
      : this._shader = null,
        this._start = 1.0,
        this._stop = 10.0,
        this._grey = false,
        this._invert = false,
        this._focus = false,
        this._changed = null {
    this.start = start;
    this.stop = stop;
    this.grey = grey;
    this.invert = invert;
    this.focus = focus;
  }

  /// Indicates that this technique has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this technique.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  /// The value of the depth labelled 1. Closer than this will all be 1.
  double get start => this._start;

  set start(double start) {
    if (!Comparer.equals(this._start, start)) {
      final double prev = this._start;
      this._start = start;
      this._onChanged(events.ValueChangedEventArgs(this, 'start', prev, this._start));
    }
  }

  /// The value of the depth labelled 0. Farther than this will all be 0.
  double get stop => this._stop;

  set stop(double stop) {
    if (!Comparer.equals(this._stop, stop)) {
      final double prev = this._stop;
      this._stop = stop;
      this._onChanged(events.ValueChangedEventArgs(this, 'stop', prev, this._stop));
    }
  }

  /// Indicates that grey scale should be outputted,
  /// otherwise high quality depth using RGB values.
  bool get grey => this._grey;

  set grey(bool grey) {
    if (this._grey != grey) {
      final bool prev = this._grey;
      this._grey = grey;
      this._shader = null;
      this._onChanged(events.ValueChangedEventArgs(this, 'grey', prev, this._grey));
    }
  }

  /// Indicates that the backside of the shape should be used
  /// instead of the front. This is used when getting shadow depth textures.
  bool get invert => this._invert;

  set invert(bool invert) {
    if (this._invert != invert) {
      final bool prev = this._invert;
      this._invert = invert;
      this._onChanged(events.ValueChangedEventArgs(this, 'invert', prev, this._invert));
    }
  }

  /// Indicates that the depth should be based off of the camera's focal point instead of the camera's view.
  bool get focus => this._focus;

  set focus(bool focus) {
    if (this._focus != focus) {
      final bool prev = this._focus;
      this._focus = focus;
      this._onChanged(events.ValueChangedEventArgs(this, 'focus', prev, this._focus));
    }
  }

  /// Gets the vertex source code used for the shader used by this technique.
  String get vertexSourceCode => this._shader?.vertexSourceCode ?? '';

  /// Gets the fragment source code used for the shader used by this technique.
  String get fragmentSourceCode => this._shader?.fragmentSourceCode ?? '';

  /// Updates this technique for the given state.
  @override
  void update(RenderState state) {
    // Do Nothing
  }

  /// Renders this technique for the given state and entity.
  @override
  void render(RenderState state, Entity obj) {
    final shaders.Depth shader = this._shader ??= shaders.Depth.cached(this._grey, this._focus, state);

    if (obj.cache is! BufferStore) obj.clearCache();
    if (obj.cacheNeedsUpdate) {
      obj.cache = obj.shapeBuilder?.build(WebGLBufferBuilder(state.gl), VertexType.Pos)
        ?..findAttribute(VertexType.Pos)?.attr = shader.posAttr?.loc ?? 0;
    }

    shader
      ..bind(state)
      ..width = this._start - this._stop
      ..stop = this._stop
      ..projectMatrix = state.projection.matrix
      ..viewObjectMatrix = state.viewObjectMatrix;

    if (this._invert) {
      state.gl.frontFace(webgl.WebGL.CW);
    }

    (obj.cache as BufferStore?)!
      ..bind(state)
      ..render(state)
      ..unbind(state);

    if (this._invert) {
      state.gl.frontFace(webgl.WebGL.CCW);
    }

    shader.unbind(state);
  }
}

/// A technique for a cover pass with a distorted image based off depth.
class Distort extends Technique {
  shaders.Distort? _shader;

  /// TODO: Need to allow the color texture to also be a Cube texture.
  Texture2D? _colorTxt;
  Texture2D? _bumpTxt;
  Matrix3 _colorTxt2DMat;
  Matrix3 _bumpTxt2DMat;
  Matrix4 _bumpMat;
  events.Event? _changed;

  /// Creates a new distort cover technique with the given initial values.
  Distort({Texture2D? colorTxt, Texture2D? bumpTxt, Matrix3? colorTxt2DMat, Matrix3? bumpTxt2DMat, Matrix4? bumpMat})
      : this._shader = null,
        this._colorTxt = null,
        this._bumpTxt = null,
        this._colorTxt2DMat = Matrix3.identity,
        this._bumpTxt2DMat = Matrix3.identity,
        this._bumpMat = Matrix4.identity,
        this._changed = null {
    this.colorTexture = colorTxt;
    this.bumpTexture = bumpTxt;
    this.colorTexture2DMatrix = colorTxt2DMat ?? Matrix3.identity;
    this.bumpTexture2DMatrix = bumpTxt2DMat ?? Matrix3.identity;
    this.bumpMatrix = bumpMat ?? Matrix4.identity;
  }

  /// Indicates that this technique has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this technique.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  /// The color texture.
  Texture2D? get colorTexture => this._colorTxt;

  set colorTexture(Texture2D? txt) {
    if (this._colorTxt != txt) {
      this._colorTxt = txt;
      this._onChanged();
    }
  }

  /// The bump texture.
  Texture2D? get bumpTexture => this._bumpTxt;

  set bumpTexture(Texture2D? txt) {
    if (this._bumpTxt != txt) {
      this._bumpTxt = txt;
      this._onChanged();
    }
  }

  /// The color texture modification matrix.
  Matrix3 get colorTexture2DMatrix => this._colorTxt2DMat;

  set colorTexture2DMatrix(Matrix3 mat) {
    if (this._colorTxt2DMat != mat) {
      this._colorTxt2DMat = mat;
      this._onChanged();
    }
  }

  /// The bump texture modification matrix.
  Matrix3 get bumpTexture2DMatrix => this._bumpTxt2DMat;

  set bumpTexture2DMatrix(Matrix3 mat) {
    if (this._bumpTxt2DMat != mat) {
      this._bumpTxt2DMat = mat;
      this._onChanged();
    }
  }

  /// The matrix to modify the bump normal with.
  Matrix4 get bumpMatrix => this._bumpMat;

  set bumpMatrix(Matrix4 mat) {
    if (this._bumpMat != mat) {
      this._bumpMat = mat;
      this._onChanged();
    }
  }

  /// Gets the vertex source code used for the shader used by this technique.
  String get vertexSourceCode => this._shader?.vertexSourceCode ?? '';

  /// Gets the fragment source code used for the shader used by this technique.
  String get fragmentSourceCode => this._shader?.fragmentSourceCode ?? '';

  /// Updates this technique for the given state.
  @override
  void update(RenderState state) {
    // Do Nothing
  }

  /// Checks if the texture is in the list and if not, sets it's index and adds it to the list.
  void _addToTextureList(List<Texture> textures, Texture? txt) {
    if (txt != null) {
      if (!textures.contains(txt)) {
        txt.index = textures.length;
        textures.add(txt);
      }
    }
  }

  /// Renders this technique for the given state and entity.
  @override
  void render(RenderState state, Entity obj) {
    this._shader ??= shaders.Distort.cached(state);

    if (obj.cacheNeedsUpdate) {
      obj.cache = obj.shapeBuilder?.build(WebGLBufferBuilder(state.gl), VertexType.Pos | VertexType.Txt2D)
        ?..findAttribute(VertexType.Pos)?.attr = this._shader?.posAttr?.loc ?? 0
        ..findAttribute(VertexType.Txt2D)?.attr = this._shader?.txtAttr?.loc ?? 1;
    }

    final List<Texture> textures = [];
    this._addToTextureList(textures, this._colorTxt);
    this._addToTextureList(textures, this._bumpTxt);
    if (textures.isEmpty) return;

    for (int i = 0; i < textures.length; i++) {
      textures[i].bind(state);
    }

    this._shader
      ?..bind(state)
      ..colorTexture = this._colorTxt
      ..bumpTexture = this._bumpTxt
      ..projectViewObjectMatrix = state.projectionViewObjectMatrix
      ..colorTextureMatrix = this._colorTxt2DMat
      ..bumpTextureMatrix = this._bumpTxt2DMat
      ..bumpMatrix = this._bumpMat;

    final _cache = obj.cache;
    if (_cache is BufferStore) {
      _cache
        ..bind(state)
        ..render(state)
        ..unbind(state);
    } else {
      obj.clearCache();
    }
    this._shader?.unbind(state);

    for (int i = 0; i < textures.length; i++) {
      textures[i].unbind(state);
    }
  }
}

/// A technique for a cover pass with a Gaussian blurred image based off of a file.
class GaussianBlur extends Technique {
  shaders.GaussianBlur? _shader;
  Matrix3 _txtMat;
  Vector4 _blurAdj;
  Vector2 _blurDir;
  Texture2D? _colorTxt;
  Texture2D? _blurTxt;
  double _blurValue;
  events.Event? _changed;

  /// Creates a new cover Gaussian blur technique with the given initial values.
  GaussianBlur(
      {Texture2D? colorTxt,
      Texture2D? blurTxt,
      Matrix3? txtMat,
      Vector4? blurAdj,
      Vector2? blurDir,
      double blurValue = 0.0})
      : this._shader = null,
        this._txtMat = Matrix3.identity,
        this._blurAdj = Vector4.zero,
        this._blurDir = Vector2.zero,
        this._colorTxt = null,
        this._blurTxt = null,
        this._blurValue = 0.0,
        this._changed = null {
    this.textureMatrix = txtMat ?? Matrix3.identity;
    this.blurAdjust = blurAdj ?? Vector4.zero;
    this.blurDirection = blurDir ?? Vector2.zero;
    this.colorTexture = colorTxt;
    this.blurTexture = blurTxt;
    this.blurValue = blurValue;
  }

  /// Indicates that this technique has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this technique.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  /// Resets the shader when a component has changed.
  void _resetShader([events.EventArgs? args]) {
    this._shader = null;
    this._onChanged(args);
  }

  /// The blur value, this will be overridden by blur texture.
  double get blurValue => this._blurValue;

  set blurValue(double value) {
    if (!Comparer.equals(this._blurValue, value)) {
      final double prev = this._blurValue;
      this._blurValue = value;
      this._onChanged(events.ValueChangedEventArgs(this, 'blurValue', prev, this._blurValue));
    }
  }

  /// The color texture.
  Texture2D? get colorTexture => this._colorTxt;

  set colorTexture(Texture2D? txt) {
    if (this._colorTxt != txt) {
      this._colorTxt?.changed.remove(this._onChanged);
      final Texture2D? prev = this._colorTxt;
      this._colorTxt = txt;
      this._colorTxt?.changed.add(this._onChanged);
      this._onChanged(events.ValueChangedEventArgs(this, 'colorTexture', prev, this._colorTxt));
    }
  }

  /// The blur texture, this will override the blur value.
  Texture2D? get blurTexture => this._blurTxt;

  set blurTexture(Texture2D? txt) {
    if (this._blurTxt != txt) {
      this._blurTxt?.changed.remove(this._onChanged);
      final Texture2D? prev = this._blurTxt;
      this._blurTxt = txt;
      this._blurTxt?.changed.add(this._onChanged);
      this._onChanged(events.ValueChangedEventArgs(this, 'blurTexture', prev, this._blurTxt));
      if (((this._blurTxt == null) && (prev != null)) || ((this._blurTxt != null) && (prev == null))) {
        this._resetShader();
      }
    }
  }

  /// The texture modification matrix.
  Matrix3 get textureMatrix => this._txtMat;

  set textureMatrix(Matrix3 mat) {
    if (this._txtMat != mat) {
      final Matrix3 prev = this._txtMat;
      this._txtMat = mat;
      this._onChanged(events.ValueChangedEventArgs(this, 'textureMatrix', prev, this._txtMat));
    }
  }

  /// The blur value modification vector.
  /// This is the vector to apply to the color from the blur texture
  /// to get the blur value from the blur texture.
  Vector4 get blurAdjust => this._blurAdj;

  set blurAdjust(Vector4 vec) {
    if (this._blurAdj != vec) {
      final Vector4 prev = this._blurAdj;
      this._blurAdj = vec;
      this._onChanged(events.ValueChangedEventArgs(this, 'blurAdjust', prev, this._blurAdj));
    }
  }

  /// The direction to apply the direction, by default it is horizontal.
  Vector2 get blurDirection => this._blurDir;

  set blurDirection(Vector2 vec) {
    if (this._blurDir != vec) {
      final Vector2 prev = this._blurDir;
      this._blurDir = vec;
      this._onChanged(events.ValueChangedEventArgs(this, 'blurDirection', prev, this._blurDir));
    }
  }

  /// Gets the vertex source code used for the shader used by this technique.
  String get vertexSourceCode => this._shader?.vertexSourceCode ?? '';

  /// Gets the fragment source code used for the shader used by this technique.
  String get fragmentSourceCode => this._shader?.fragmentSourceCode ?? '';

  /// Updates this technique for the given state.
  @override
  void update(RenderState state) {
    // Do Nothing
  }

  /// Checks if the texture is in the list and if not, sets it's index and adds it to the list.
  void _addToTextureList(List<Texture> textures, Texture? txt) {
    if (txt != null) {
      if (!textures.contains(txt)) {
        txt.index = textures.length;
        textures.add(txt);
      }
    }
  }

  /// Renders this technique for the given state and entity.
  @override
  void render(RenderState state, Entity obj) {
    if (this._shader == null) {
      final bool hasBlurTxt = blurTexture != null;
      final shaders.GaussianBlurConfig cfg = shaders.GaussianBlurConfig(hasBlurTxt);
      this._shader = shaders.GaussianBlur.cached(cfg, state);
      obj.clearCache();
    }

    final shaders.GaussianBlurConfig? cfg = this._shader?.configuration;
    if (cfg == null) return;
    if (obj.cache is! BufferStore) obj.clearCache();
    if (obj.cacheNeedsUpdate) {
      obj.cache = obj.shapeBuilder?.build(WebGLBufferBuilder(state.gl), VertexType.Pos | VertexType.Txt2D)
        ?..findAttribute(VertexType.Pos)?.attr = this._shader?.posAttr?.loc ?? 0
        ..findAttribute(VertexType.Txt2D)?.attr = this._shader?.txtAttr?.loc ?? 1;
    }

    final List<Texture> textures = [];
    this._addToTextureList(textures, this._colorTxt);
    if (cfg.blurTxt) this._addToTextureList(textures, this._blurTxt);
    if (textures.isEmpty) return;

    for (int i = 0; i < textures.length; i++) {
      textures[i].bind(state);
    }

    this._shader
      ?..bind(state)
      ..colorTexture = this._colorTxt
      ..textureMatrix = this._txtMat
      ..blurScalar = Vector2(this._blurDir.dx / state.width.toDouble(), this._blurDir.dy / state.height.toDouble())
      ..projectViewObjectMatrix = state.projectionViewObjectMatrix;

    if (cfg.blurTxt) {
      this._shader
        ?..blurTexture = this._blurTxt
        ..blurAdjust = this._blurAdj;
    } else {
      this._shader?.blurValue = this._blurValue;
    }

    final _cache = obj.cache;
    if (_cache is BufferStore) {
      _cache
        ..bind(state)
        ..render(state)
        ..unbind(state);
    } else {
      obj.clearCache();
    }
    this._shader?.unbind(state);

    for (int i = 0; i < textures.length; i++) {
      textures[i].unbind(state);
    }
  }
}

/// The inspection rendering technique for checking shape components.
class Inspection extends Technique {
  shaders.Inspection? _shader;
  Vector3 _lightVec;
  Color4 _diffuse1;
  Color4 _ambient1;
  Color4 _diffuse2;
  Color4 _ambient2;
  Color4 _diffuse3;
  Color4 _ambient3;
  Color4 _diffuse4;
  Color4 _ambient4;

  bool _showFilled;
  bool _showWireFrame;
  bool _showVertices;
  bool _showNormals;
  bool _showBinormals;
  bool _showTangentals;
  bool _showTxtCube;
  bool _showFaceCenters;
  bool _showFaceNormals;
  bool _showFaceBinormals;
  bool _showFaceTangentals;
  bool _showColorFill;
  bool _showTxt2DColor;
  bool _showWeight;
  bool _showAxis;
  bool _showAABB;
  bool _showBend;
  double _vectorScale;
  events.Event? _changed;

  /// Creates a new inspection technique.
  Inspection(
      {bool showFilled = false,
      bool showWireFrame = false,
      bool showVertices = false,
      bool showNormals = false,
      bool showBinormals = false,
      bool showTangentals = false,
      bool showTxtCube = false,
      bool showFaceCenters = false,
      bool showFaceNormals = false,
      bool showFaceBinormals = false,
      bool showFaceTangentals = false,
      bool showColorFill = false,
      bool showTxt2DColor = false,
      bool showWeight = false,
      bool showAxis = false,
      bool showAABB = false,
      bool showBend = false,
      double vectorScale = 1.0})
      : this._shader = null,
        this._lightVec = Vector3.negZ,
        this._diffuse1 = Color4(0.2, 0.3, 0.4),
        this._ambient1 = Color4(0.1, 0.2, 0.3),
        this._diffuse2 = Color4.gray(0.7),
        this._ambient2 = Color4.gray(0.3),
        this._diffuse3 = Color4.gray(0.5),
        this._ambient3 = Color4.gray(0.5),
        this._diffuse4 = Color4.white(),
        this._ambient4 = Color4.gray(0.8),
        this._showFilled = showFilled,
        this._showWireFrame = showWireFrame,
        this._showVertices = showVertices,
        this._showNormals = showNormals,
        this._showBinormals = showBinormals,
        this._showTangentals = showTangentals,
        this._showTxtCube = showTxtCube,
        this._showFaceCenters = showFaceCenters,
        this._showFaceNormals = showFaceNormals,
        this._showFaceBinormals = showFaceBinormals,
        this._showFaceTangentals = showFaceTangentals,
        this._showColorFill = showColorFill,
        this._showTxt2DColor = showTxt2DColor,
        this._showWeight = showWeight,
        this._showAxis = showAxis,
        this._showAABB = showAABB,
        this._showBend = showBend,
        this._vectorScale = vectorScale,
        this._changed = null;

  /// Indicates that this technique has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this technique.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  /// Handles a change to a boolean value.
  void _onBoolChanged(String name, bool value) =>
      this._onChanged(events.ValueChangedEventArgs(this, name, !value, value));

  /// Indicates if the filled shape should be showed.
  bool get showFilled => this._showFilled;

  set showFilled(bool show) {
    if (this._showFilled != show) {
      this._showFilled = show;
      this._onBoolChanged('showFilled', show);
    }
  }

  /// Indicates if the wire frame of the shape should be showed.
  bool get showWireFrame => this._showWireFrame;

  set showWireFrame(bool show) {
    if (this._showWireFrame != show) {
      this._showWireFrame = show;
      this._onBoolChanged('showWireFrame', show);
    }
  }

  /// Indicates if the vertices of the shape should be showed.
  bool get showVertices => this._showVertices;

  set showVertices(bool show) {
    if (this._showVertices != show) {
      this._showVertices = show;
      this._onBoolChanged('showVertices', show);
    }
  }

  /// Indicates if the normals of the shape should be showed.
  bool get showNormals => this._showNormals;

  set showNormals(bool show) {
    if (this._showNormals != show) {
      this._showNormals = show;
      this._onBoolChanged('showNormals', show);
    }
  }

  /// Indicates if the binormals of the shape should be showed.
  bool get showBinormals => this._showBinormals;

  set showBinormals(bool show) {
    if (this._showBinormals != show) {
      this._showBinormals = show;
      this._onBoolChanged('showBinormals', show);
    }
  }

  /// Indicates if the tangentals of the shape should be showed.
  bool get showTangentals => this._showTangentals;

  set showTangentals(bool show) {
    if (this._showTangentals != show) {
      this._showTangentals = show;
      this._onBoolChanged('showTangentals', show);
    }
  }

  /// Indicates if the texture cube vectors of the shape should be showed.
  bool get showTxtCube => this._showTxtCube;

  set showTxtCube(bool show) {
    if (this._showTxtCube != show) {
      this._showTxtCube = show;
      this._onBoolChanged('showTxtCube', show);
    }
  }

  /// Indicates if the face center points of the shape should be showed.
  bool get showFaceCenters => this._showFaceCenters;

  set showFaceCenters(bool show) {
    if (this._showFaceCenters != show) {
      this._showFaceCenters = show;
      this._onBoolChanged('showFaceCenters', show);
    }
  }

  /// Indicates if the face normals of the shape should be showed.
  bool get showFaceNormals => this._showFaceNormals;

  set showFaceNormals(bool show) {
    if (this._showFaceNormals != show) {
      this._showFaceNormals = show;
      this._onBoolChanged('showFaceNormals', show);
    }
  }

  /// Indicates if the face binormals of the shape should be showed.
  bool get showFaceBinormals => this._showFaceBinormals;

  set showFaceBinormals(bool show) {
    if (this._showFaceBinormals != show) {
      this._showFaceBinormals = show;
      this._onBoolChanged('showFaceBinormals', show);
    }
  }

  /// Indicates if the face tangentals of the shape should be showed.
  bool get showFaceTangentals => this._showFaceTangentals;

  set showFaceTangentals(bool show) {
    if (this._showFaceTangentals != show) {
      this._showFaceTangentals = show;
      this._onBoolChanged('showFaceTangentals', show);
    }
  }

  /// Indicates if the colors of the shape should be showed.
  bool get showColorFill => this._showColorFill;

  set showColorFill(bool show) {
    if (this._showColorFill != show) {
      this._showColorFill = show;
      this._onBoolChanged('showColorFill', show);
    }
  }

  /// Indicates if the texture 2D colors of the shape should be showed.
  bool get showTxt2DColor => this._showTxt2DColor;

  set showTxt2DColor(bool show) {
    if (this._showTxt2DColor != show) {
      this._showTxt2DColor = show;
      this._onBoolChanged('showTxt2DColor', show);
    }
  }

  /// Indicates if the weights of the shape should be showed.
  bool get showWeight => this._showWeight;

  set showWeight(bool show) {
    if (this._showWeight != show) {
      this._showWeight = show;
      this._onBoolChanged('showWeight', show);
    }
  }

  /// Indicates if the axis should be showed.
  bool get showAxis => this._showAxis;

  set showAxis(bool show) {
    if (this._showAxis != show) {
      this._showAxis = show;
      this._onBoolChanged('showAxis', show);
    }
  }

  /// Indicates if the axlal aligned bounding box of the shape should be showed.
  bool get showAABB => this._showAABB;

  set showAABB(bool show) {
    if (this._showAABB != show) {
      this._showAABB = show;
      this._onBoolChanged('showAABB', show);
    }
  }

  /// Indicates if the first bend should be showed.
  bool get showBend => this._showBend;

  set showBend(bool show) {
    if (this._showBend != show) {
      this._showBend = show;
      this._onBoolChanged('showBend', show);
    }
  }

  /// The scalar to apply to vectors lengths.
  /// To make the vectors change length the cache also has to be cleared.
  double get vectorScale => this._vectorScale;

  set vectorScale(double scale) {
    if (!Comparer.equals(this._vectorScale, scale)) {
      final double prevScale = this._vectorScale;
      this._vectorScale = scale;
      this._onChanged(events.ValueChangedEventArgs(this, 'vectorScale', prevScale, scale));
    }
  }

  /// The light vector to highlight the shape with.
  Vector3 get lightVector => this._lightVec;

  set lightVector(Vector3 vec) {
    if (this._lightVec != vec) {
      final Vector3 prevVec = this._lightVec;
      this._lightVec = vec;
      this._onChanged(events.ValueChangedEventArgs(this, 'lightVector', prevVec, vec));
    }
  }

  /// The first diffuse color, used for the fill color.
  Color4 get diffuse1 => this._diffuse1;

  set diffuse1(Color4 clr) {
    if (this._diffuse1 != clr) {
      final Color4 prevClr = this._diffuse1;
      this._diffuse1 = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'diffuse1', prevClr, clr));
    }
  }

  /// The first ambient color, used for the fill color.
  Color4 get ambient1 => this._ambient1;

  set ambient1(Color4 clr) {
    if (this._ambient1 != clr) {
      final Color4 prevClr = this._ambient1;
      this._ambient1 = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'ambient1', prevClr, clr));
    }
  }

  /// The second diffuse color, used for the wireframe color.
  Color4 get diffuse2 => this._diffuse2;

  set diffuse2(Color4 clr) {
    if (this._diffuse2 != clr) {
      final Color4 prevClr = this._diffuse2;
      this._diffuse2 = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'diffuse2', prevClr, clr));
    }
  }

  /// The second ambient color, used for the wireframe color.
  Color4 get ambient2 => this._ambient2;

  set ambient2(Color4 clr) {
    if (this._ambient2 != clr) {
      final Color4 prevClr = this._ambient2;
      this._ambient2 = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'ambient2', prevClr, clr));
    }
  }

  /// The third diffuse color.
  Color4 get diffuse3 => this._diffuse3;

  set diffuse3(Color4 clr) {
    if (this._diffuse3 != clr) {
      final Color4 prevClr = this._diffuse3;
      this._diffuse3 = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'diffuse3', prevClr, clr));
    }
  }

  /// The third ambient color.
  Color4 get ambient3 => this._ambient3;

  set ambient3(Color4 clr) {
    if (this._ambient3 != clr) {
      final Color4 prevClr = this._ambient3;
      this._ambient3 = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'ambient3', prevClr, clr));
    }
  }

  /// The fourth diffuse color.
  Color4 get diffuse4 => this._diffuse4;

  set diffuse4(Color4 clr) {
    if (this._diffuse4 != clr) {
      final Color4 prevClr = this._diffuse4;
      this._diffuse4 = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'diffuse4', prevClr, clr));
    }
  }

  /// The fourth ambient color.
  Color4 get ambient4 => this._ambient4;

  set ambient4(Color4 clr) {
    if (this._ambient4 != clr) {
      final Color4 prevClr = this._ambient4;
      this._ambient4 = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'ambient4', prevClr, clr));
    }
  }

  /// Updates this technique for the given state.
  @override
  void update(RenderState state) {
    // Do Nothing
  }

  /// Renders the current [obj] with the current [state].
  @override
  void render(RenderState state, Entity obj) {
    this._shader ??= shaders.Inspection.cached(state);

    if (obj.cacheNeedsUpdate) {
      obj.shapeBuilder?.calculateNormals();
      obj.shapeBuilder?.calculateBinormals();
      obj.shapeBuilder?.calculateCubeTextures();
      obj.cache = BufferStoreSet();
    }

    this._shader
      ?..bind(state)
      ..weightScalar = this._vectorScale
      ..lightVector = this._lightVec
      ..viewMatrix = state.view.matrix
      ..viewObjectMatrix = state.viewObjectMatrix
      ..projectViewObjectMatrix = state.projectionViewObjectMatrix;

    if (obj.cache is BufferStoreSet) {
      final store = (obj.cache as BufferStoreSet?)!;
      state.gl.blendFunc(webgl.WebGL.ONE, webgl.WebGL.ONE);

      if (obj.shape == null) {
        this._renderAllBuilderParts(store, state, obj);
      } else {
        this._renderAllShapeParts(store, state, obj);
      }
    } else {
      obj.clearCache();
    }

    this._shader?.unbind(state);
  }

  /// Renders the current [obj] with the current [state].
  /// Must have a shape, not just a shape builder, to do a full inspection.
  void _renderAllBuilderParts(BufferStoreSet store, RenderState state, Entity obj) {
    final builder = obj.shapeBuilder;
    if (builder == null) return;

    state.gl.disable(webgl.WebGL.DEPTH_TEST);
    state.gl.enable(webgl.WebGL.BLEND);
    state.gl.blendFunc(webgl.WebGL.ONE, webgl.WebGL.ONE);

    if (this._showAxis) {
      this._renderBuilder(state, store, builder, 'Axis', this._axisBuilder, this._ambient4, this._diffuse4);
    }
    if (this._showAABB) {
      this._renderBuilder(state, store, builder, 'AABB', this._aabbBuilder, this._ambient4, this._diffuse4);
    }

    state.gl.enable(webgl.WebGL.DEPTH_TEST);
    state.gl.blendFunc(webgl.WebGL.SRC_ALPHA, webgl.WebGL.ONE_MINUS_SRC_ALPHA);
  }

  /// Renders the current [obj] with the current [state].
  void _renderAllShapeParts(BufferStoreSet store, RenderState state, Entity obj) {
    final shape = obj.shape;
    if (shape == null) return;

    state.gl.enable(webgl.WebGL.DEPTH_TEST);
    state.gl.enable(webgl.WebGL.BLEND);
    state.gl.blendFunc(webgl.WebGL.SRC_ALPHA, webgl.WebGL.ONE_MINUS_SRC_ALPHA);

    if (this._showFilled) {
      this._render(state, store, shape, 'shapeFill', this._shapeFill, this._ambient1, this._diffuse1);
    }
    if (this._showColorFill) {
      this._render(state, store, shape, 'colorFill', this._colorFill, this._ambient3, this._diffuse3);
    }
    if (this._showTxt2DColor) {
      this._render(state, store, shape, 'txt2DColor', this._txt2DColor, this._ambient3, this._diffuse3);
    }
    if (this._showWeight) {
      this._render(state, store, shape, 'weight', this._weight, this._ambient3, this._diffuse3);
    }
    if (this._showBend) {
      this._render(state, store, shape, 'bend1', this._bendFill, this._ambient3, this._diffuse3);
    }

    state.gl.disable(webgl.WebGL.DEPTH_TEST);
    state.gl.blendFunc(webgl.WebGL.ONE, webgl.WebGL.ONE);

    if (this._showVertices) {
      this._render(state, store, shape, 'vertices', this._vertices, this._ambient2, this._diffuse2);
    }
    if (this._showFaceCenters) {
      this._render(state, store, shape, 'faceCenters', this._faceCenters, this._ambient2, this._diffuse2);
    }

    if (this._showWireFrame) {
      this._render(state, store, shape, 'wireFrame', this._wireFrame, this._ambient2, this._diffuse2);
    }
    if (this._showNormals) {
      this._render(state, store, shape, 'normals', this._normals, this._ambient2, this._diffuse2);
    }
    if (this._showBinormals) {
      this._render(state, store, shape, 'binormals', this._binormals, this._ambient2, this._diffuse2);
    }
    if (this._showTangentals) {
      this._render(state, store, shape, 'tangentals', this._tangentals, this._ambient2, this._diffuse2);
    }
    if (this._showTxtCube) {
      this._render(state, store, shape, 'textureCube', this._txtCube, this._ambient2, this._diffuse2);
    }
    if (this._showFaceNormals) {
      this._render(state, store, shape, 'faceNormals', this._faceNormals, this._ambient2, this._diffuse2);
    }
    if (this._showFaceBinormals) {
      this._render(state, store, shape, 'faceBinormals', this._faceBinormals, this._ambient3, this._diffuse3);
    }
    if (this._showFaceTangentals) {
      this._render(state, store, shape, 'faceTangentals', this._faceTangentals, this._ambient3, this._diffuse3);
    }
    if (this._showAxis) {
      this._render(state, store, shape, 'Axis', this._axis, this._ambient4, this._diffuse4);
    }
    if (this._showAABB) {
      this._render(state, store, shape, 'AABB', this._aabb, this._ambient4, this._diffuse4);
    }

    state.gl.enable(webgl.WebGL.DEPTH_TEST);
    state.gl.blendFunc(webgl.WebGL.SRC_ALPHA, webgl.WebGL.ONE_MINUS_SRC_ALPHA);
  }

  /// Renders one of the shape components to inspect.
  /// If the component of the shape isn't cached it will be created and cached.
  void _render(RenderState state, BufferStoreSet storeSet, Shape shape, String name,
      Shape Function(Shape shape) shapeModHndl, Color4 ambient, Color4 diffuse) {
    BufferStore? store = storeSet.map[name];
    if (store == null) {
      store = this._buildShape(state, shapeModHndl(shape));
      storeSet.map[name] = store;
    }
    this._shader?.setColors(ambient, diffuse);
    store.oneRender(state);
  }

  /// Renders one of the shape builder components to inspect.
  /// If the component of the shape isn't cached it will be created and cached.
  void _renderBuilder(RenderState state, BufferStoreSet storeSet, ShapeBuilder builder, String name,
      Shape Function(ShapeBuilder builder) shapeBuilderModHndl, Color4 ambient, Color4 diffuse) {
    BufferStore? store = storeSet.map[name];
    if (store == null) {
      store = this._buildShape(state, shapeBuilderModHndl(builder));
      storeSet.map[name] = store;
    }
    this._shader?.setColors(ambient, diffuse);
    store.oneRender(state);
  }

  /// Builds and sets up the shape for a component.
  BufferStore _buildShape(RenderState state, Shape shape) {
    final BufferStore store =
        shape.build(WebGLBufferBuilder(state.gl), VertexType.Pos | VertexType.Norm | VertexType.Binm | VertexType.Clr3);
    return store
      ..findAttribute(VertexType.Pos)?.attr = this._shader?.posAttr?.loc ?? 0
      ..findAttribute(VertexType.Norm)?.attr = this._shader?.normAttr?.loc ?? 1
      ..findAttribute(VertexType.Clr3)?.attr = this._shader?.clrAttr?.loc ?? 2
      ..findAttribute(VertexType.Binm)?.attr = this._shader?.binmAttr?.loc ?? 3;
  }

  /// Convertes the given [shape] into the filled shape.
  Shape _shapeFill(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4.white();
    shape.vertices.forEach((Vertex vertex) {
      result.vertices.add(vertex.copy()
        ..color = color
        ..binormal = Vector3.zero);
    });
    shape.faces.forEach((Face face) {
      final Vertex ver1 = result.vertices[face.vertex1?.index ?? 0];
      final Vertex ver2 = result.vertices[face.vertex2?.index ?? 0];
      final Vertex ver3 = result.vertices[face.vertex3?.index ?? 0];
      result.faces.add(ver1, ver2, ver3);
    });
    return result;
  }

  /// Convertes the given [shape] into the wire frame shape.
  Shape _wireFrame(Shape shape, {Color4? color}) {
    final Shape result = Shape();
    color ??= Color4(0.0, 0.7, 1.0);
    shape.vertices.forEach((Vertex vertex) {
      result.vertices.add(vertex.copy()
        ..color = color
        ..binormal = Vector3.zero);
    });
    void addLine(Vertex ver1, Vertex ver2) {
      if (ver1.firstLineBetween(ver2) == null) {
        result.lines.add(ver1, ver2);
      }
    }

    shape.lines.forEach((Line line) {
      final Vertex ver1 = result.vertices[line.vertex1?.index ?? 0];
      final Vertex ver2 = result.vertices[line.vertex2?.index ?? 0];
      addLine(ver1, ver2);
    });
    shape.faces.forEach((Face face) {
      final Vertex ver1 = result.vertices[face.vertex1?.index ?? 0];
      final Vertex ver2 = result.vertices[face.vertex2?.index ?? 0];
      final Vertex ver3 = result.vertices[face.vertex3?.index ?? 0];
      addLine(ver1, ver2);
      addLine(ver2, ver3);
      addLine(ver3, ver1);
    });
    return result;
  }

  /// Convertes the given [shape] into the vertices shape.
  Shape _vertices(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4.white();
    shape.vertices.forEach((Vertex vertex) {
      final Vertex ver = vertex.copy()
        ..color = color
        ..binormal = Vector3.zero;
      result.vertices.add(ver);
      result.points.add(ver);
    });
    return result;
  }

  /// Convertes the given [shape] into the normals shape.
  Shape _normals(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4(1.0, 1.0, 0.3);
    shape.vertices.forEach((Vertex vertex) {
      final Vertex ver1 = vertex.copy()
        ..color = color
        ..binormal = Vector3.zero;
      final Vertex ver2 = ver1.copy()..binormal = ver1.normal;
      result.vertices.add(ver1);
      result.vertices.add(ver2);
      result.lines.add(ver1, ver2);
    });
    return result;
  }

  /// Convertes the given [shape] into the binormals shape.
  Shape _binormals(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4(1.0, 0.3, 0.3);
    shape.vertices.forEach((Vertex vertex) {
      final Vertex ver1 = vertex.copy()
        ..color = color
        ..binormal = Vector3.zero;
      final Vertex ver2 = ver1.copy()..binormal = vertex.binormal;
      result.vertices.add(ver1);
      result.vertices.add(ver2);
      result.lines.add(ver1, ver2);
    });
    return result;
  }

  /// Convertes the given [shape] into the tangentals shape.
  Shape _tangentals(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4(1.0, 0.3, 1.0);
    shape.vertices.forEach((Vertex vertex) {
      final Vector3? norm = vertex.normal;
      final Vector3? binm = vertex.binormal;
      if (norm == null || binm == null) return;

      final Vertex ver1 = vertex.copy()
        ..color = color
        ..binormal = Vector3.zero;
      final Vertex ver2 = ver1.copy()..binormal = -binm.cross(norm);
      result.vertices.add(ver1);
      result.vertices.add(ver2);
      result.lines.add(ver1, ver2);
    });
    return result;
  }

  /// Convertes the given [shape] into the texture cube color shape.
  Shape _txtCube(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4(1.0, 0.3, 0.3);
    shape.vertices.forEach((Vertex vertex) {
      final Vertex ver1 = vertex.copy()
        ..color = color
        ..binormal = Vector3.zero;
      final Vertex ver2 = ver1.copy()..binormal = vertex.textureCube;
      result.vertices.add(ver1);
      result.vertices.add(ver2);
      result.lines.add(ver1, ver2);
    });
    return result;
  }

  /// Convertes the given [shape] into the face center point shape.
  Shape _faceCenters(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4(1.0, 1.0, 0.3);
    shape.faces.forEach((Face face) {
      final Point3? loc1 = face.vertex1?.location;
      final Point3? loc2 = face.vertex2?.location;
      final Point3? loc3 = face.vertex3?.location;
      if (loc1 == null || loc2 == null || loc3 == null) return;

      final Vertex ver = Vertex(loc: (loc1 + loc2 + loc3) / 3.0, norm: face.normal, binm: Vector3.zero, clr: color);
      result.vertices.add(ver);
      result.points.add(ver);
    });
    return result;
  }

  /// Convertes the given [shape] into the face normal shape.
  Shape _faceNormals(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4(1.0, 1.0, 0.3);
    shape.faces.forEach((Face face) {
      final Point3? loc1 = face.vertex1?.location;
      final Point3? loc2 = face.vertex2?.location;
      final Point3? loc3 = face.vertex3?.location;
      if (loc1 == null || loc2 == null || loc3 == null) return;

      final Vertex cen1 = Vertex(loc: (loc1 + loc2 + loc3) / 3.0, norm: face.normal, binm: Vector3.zero, clr: color);
      final Vertex cen2 = cen1.copy()..binormal = face.normal;
      result.vertices.add(cen1);
      result.vertices.add(cen2);
      result.lines.add(cen1, cen2);
    });
    return result;
  }

  /// Convertes the given [shape] into the face binormal shape.
  Shape _faceBinormals(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4(1.0, 0.3, 0.3);
    shape.faces.forEach((Face face) {
      final Point3? loc1 = face.vertex1?.location;
      final Point3? loc2 = face.vertex2?.location;
      final Point3? loc3 = face.vertex3?.location;
      if (loc1 == null || loc2 == null || loc3 == null) return;

      final Vertex cen1 = Vertex(loc: (loc1 + loc2 + loc3) / 3.0, norm: face.normal, binm: Vector3.zero, clr: color);
      final Vertex cen2 = cen1.copy()..binormal = face.binormal;
      result.vertices.add(cen1);
      result.vertices.add(cen2);
      result.lines.add(cen1, cen2);
    });
    return result;
  }

  /// Convertes the given [shape] into the face tangental shape.
  Shape _faceTangentals(Shape shape) {
    final Shape result = Shape();
    final Color4 color = Color4(1.0, 0.3, 1.0);
    shape.faces.forEach((Face face) {
      final Point3? loc1 = face.vertex1?.location;
      final Point3? loc2 = face.vertex2?.location;
      final Point3? loc3 = face.vertex3?.location;
      final Vector3? norm = face.normal;
      final Vector3? binm = face.binormal;
      if (loc1 == null || loc2 == null || loc3 == null || norm == null || binm == null) return;

      final Vertex cen1 = Vertex(loc: (loc1 + loc2 + loc3) / 3.0, norm: face.normal, binm: Vector3.zero, clr: color);
      final Vertex cen2 = cen1.copy()..binormal = -binm.cross(norm);
      result.vertices.add(cen1);
      result.vertices.add(cen2);
      result.lines.add(cen1, cen2);
    });
    return result;
  }

  /// Convertes the given [shape] into the color shape.
  Shape _colorFill(Shape shape) {
    final Shape result = Shape();
    shape.vertices.forEach((Vertex vertex) {
      result.vertices.add(vertex.copy()..binormal = Vector3.zero);
    });
    shape.faces.forEach((Face face) {
      final Vertex ver1 = result.vertices[face.vertex1?.index ?? 0];
      final Vertex ver2 = result.vertices[face.vertex2?.index ?? 0];
      final Vertex ver3 = result.vertices[face.vertex3?.index ?? 0];
      result.faces.add(ver1, ver2, ver3);
    });
    return result;
  }

  /// Convertes the given [shape] into the texture 2D color shape.
  Shape _txt2DColor(Shape shape) {
    final Shape result = Shape();
    shape.vertices.forEach((Vertex vertex) {
      final Point2 txt = vertex.texture2D ?? Point2.zero;
      result.vertices.add(vertex.copy()
        ..color = Color4(txt.x, txt.y, txt.y)
        ..binormal = Vector3.zero);
    });
    shape.faces.forEach((Face face) {
      final Vertex ver1 = result.vertices[face.vertex1?.index ?? 0];
      final Vertex ver2 = result.vertices[face.vertex2?.index ?? 0];
      final Vertex ver3 = result.vertices[face.vertex3?.index ?? 0];
      result.faces.add(ver1, ver2, ver3);
    });
    return result;
  }

  /// Convertes the given [shape] into the weight color shape.
  Shape _weight(Shape shape) {
    final Shape result = Shape();
    if (shape.vertices.length < 1) return result;
    double min = shape.vertices[0].weight;
    double max = min;
    shape.vertices.forEach((Vertex vertex) {
      if (min > vertex.weight) min = vertex.weight;
      if (max < vertex.weight) max = vertex.weight;
    });
    double div = max - min;
    if (div <= 0.0) div = 1.0;
    shape.vertices.forEach((Vertex vertex) {
      final double spectrum = (vertex.weight - min) / div;
      final Color3 clr = Color3.fromHVS(spectrum * 5.0 / 6.0, 1.0, 1.0);
      result.vertices.add(vertex.copy()
        ..binormal = Vector3.zero
        ..color = Color4.fromColor3(clr));
    });
    shape.faces.forEach((Face face) {
      final Vertex ver1 = result.vertices[face.vertex1?.index ?? 0];
      final Vertex ver2 = result.vertices[face.vertex2?.index ?? 0];
      final Vertex ver3 = result.vertices[face.vertex3?.index ?? 0];
      result.faces.add(ver1, ver2, ver3);
    });
    return result;
  }

  /// Gets the maximum bend index of the given [shape].
  int _maxIndex(Shape shape) {
    double maxBend = 0.0;
    shape.vertices.forEach((Vertex vertex) {
      final Point4 bend = vertex.bending ?? Point4.zero;
      maxBend = math.max(maxBend, bend.x);
      maxBend = math.max(maxBend, bend.y);
      maxBend = math.max(maxBend, bend.z);
      maxBend = math.max(maxBend, bend.w);
    });
    return ((maxBend + 1.5) * 0.5).floor();
  }

  /// Gets the spectrum color for the [bendVal] in the [maxIndex] range.
  Color3 _bendColor(double bendVal, int maxIndex) {
    if (bendVal < 0.0 || maxIndex <= 0) {
      return Color3(0.0, 0.0, 1.0);
    } else {
      final double index = ((bendVal + 0.5) * 0.5).floorToDouble();
      final double value = bendVal - index * 2.0;
      return Color3.fromHVS(index / maxIndex, value, 1.0);
    }
  }

  /// Convertes the given [shape] into the bend color shape.
  Shape _bendFill(Shape shape) {
    final int maxIndex = this._maxIndex(shape);
    final Shape result = Shape();
    shape.vertices.forEach((Vertex vertex) {
      final Point4 bend = vertex.bending ?? Point4.zero;
      Color3 clr = Color3.black();
      clr = clr + this._bendColor(bend.x, maxIndex);
      clr = clr + this._bendColor(bend.y, maxIndex);
      clr = clr + this._bendColor(bend.z, maxIndex);
      clr = clr + this._bendColor(bend.w, maxIndex);
      result.vertices.add(vertex.copy()
        ..binormal = Vector3.zero
        ..color = Color4.fromColor3(clr));
    });
    shape.faces.forEach((Face face) {
      final Vertex ver1 = result.vertices[face.vertex1?.index ?? 0];
      final Vertex ver2 = result.vertices[face.vertex2?.index ?? 0];
      final Vertex ver3 = result.vertices[face.vertex3?.index ?? 0];
      result.faces.add(ver1, ver2, ver3);
    });
    return result;
  }

  /// Creates the axii shape.
  Shape _axis(Shape shape) => this._axisBuilder(shape);

  /// Creates the axii shape for a shape builder.
  Shape _axisBuilder(ShapeBuilder builder) {
    final Shape result = Shape();
    final add = (double dx, double dy, double dz) {
      final Color4 clr = Color4(dx, dy, dz);
      final Vertex ver1 = result.vertices.addNewLoc(0.0, 0.0, 0.0)
        ..binormal = Vector3.zero
        ..normal = Vector3.posX
        ..color = clr;
      final Vertex ver2 = result.vertices.addNewLoc(dx, dy, dz)
        ..binormal = Vector3.zero
        ..normal = Vector3.posX
        ..color = clr;
      result.lines.add(ver1, ver2);
    };
    add(1.0, 0.0, 0.0);
    add(0.0, 1.0, 0.0);
    add(0.0, 0.0, 1.0);
    return result;
  }

  /// Converts the given [shape] into the axial aligned bounding box shape.
  Shape _aabb(Shape shape) => this._aabbBuilder(shape);

  /// Converts the given [builder] into the axial aligned bounding box
  /// shape for a shape builder.
  Shape _aabbBuilder(ShapeBuilder builder) {
    final Region3 aabb = builder.calculateAABB();
    final Shape result = Shape();
    final add = (double dx, double dy, double dz) {
      return result.vertices.addNewLoc(dx, dy, dz)
        ..binormal = Vector3.zero
        ..normal = Vector3(dx, dy, dz);
    };
    final Vertex ver1 = add(aabb.x, aabb.y, aabb.z);
    final Vertex ver2 = add(aabb.x + aabb.dx, aabb.y, aabb.z);
    final Vertex ver3 = add(aabb.x + aabb.dx, aabb.y + aabb.dy, aabb.z);
    final Vertex ver4 = add(aabb.x, aabb.y + aabb.dy, aabb.z);
    final Vertex ver5 = add(aabb.x, aabb.y, aabb.z + aabb.dz);
    final Vertex ver6 = add(aabb.x + aabb.dx, aabb.y, aabb.z + aabb.dz);
    final Vertex ver7 = add(aabb.x + aabb.dx, aabb.y + aabb.dy, aabb.z + aabb.dz);
    final Vertex ver8 = add(aabb.x, aabb.y + aabb.dy, aabb.z + aabb.dz);
    result.lines.add(ver1, ver2);
    result.lines.add(ver2, ver3);
    result.lines.add(ver3, ver4);
    result.lines.add(ver4, ver1);
    result.lines.add(ver5, ver6);
    result.lines.add(ver6, ver7);
    result.lines.add(ver7, ver8);
    result.lines.add(ver8, ver5);
    result.lines.add(ver1, ver5);
    result.lines.add(ver2, ver6);
    result.lines.add(ver3, ver7);
    result.lines.add(ver4, ver8);
    return result;
  }
}

/// The material/light rendering technique.
class MaterialLight extends Technique {
  shaders.MaterialLight? _shader;
  Matrix3? _txt2DMat;
  Matrix4? _txtCubeMat;
  Matrix4? _colorMat;
  Collection<Matrix4> _bendMats;
  MaterialLightColorComponent? _emission;
  MaterialLightColorComponent? _ambient;
  MaterialLightColorComponent? _diffuse;
  MaterialLightColorComponent? _invDiffuse;
  MaterialLightSpecularComponent? _specular;
  MaterialLightBumpComponent? _bump;
  TextureCube? _envSampler;
  MaterialLightColorComponent? _reflect;
  MaterialLightRefractionComponent? _refract;
  MaterialLightAlphaComponent? _alpha;
  lights_.LightCollection? _lights;
  MaterialLightFogComponent? _fog;
  events.Event? _changed;

  /// Creates a new material/light technique.
  MaterialLight()
      : this._shader = null,
        this._txt2DMat = null,
        this._txtCubeMat = null,
        this._colorMat = null,
        this._bendMats = Collection<Matrix4>(),
        this._emission = null,
        this._ambient = null,
        this._diffuse = null,
        this._invDiffuse = null,
        this._specular = null,
        this._bump = null,
        this._envSampler = null,
        this._reflect = null,
        this._refract = null,
        this._alpha = null,
        this._lights = null,
        this._fog = null,
        this._changed = null {
    this._bendMats.setHandlers(onAddedHndl: this._onBendMatsAdded, onRemovedHndl: this._onBendMatsRemoved);
    this.lights..changed.add(this._resetShader)..lightChanged.add(this._onChanged);
  }

  /// Creates a new emission material with an optional colored glow.
  factory MaterialLight.glow({Color3? color}) => MaterialLight()..emission.color = color ?? Color3.white();

  /// Indicates that this technique has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this technique.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  /// Resets the shader when a component has changed.
  void _resetShader([events.EventArgs? args]) {
    this._shader = null;
    this._onChanged(args);
  }

  /// Handles added matrices to the bend matrices.
  void _onBendMatsAdded(int index, Iterable<Matrix4> mats) =>
      this._onChanged(events.ItemsAddedEventArgs(this, index, mats));

  /// Handles removed matrices from the bend matrices.
  void _onBendMatsRemoved(int index, Iterable<Matrix4> mats) =>
      this._onChanged(events.ItemsRemovedEventArgs(this, index, mats));

  /// The lights to render with.
  lights_.LightCollection get lights =>
      this._lights ??= lights_.LightCollection()..changed.add(this._resetShader)..lightChanged.add(this._onChanged);

  /// The 2D texture modification matrix.
  Matrix3? get texture2DMatrix => this._txt2DMat;

  set texture2DMatrix(Matrix3? mat) {
    if (this._txt2DMat != mat) {
      if (xor(this._txt2DMat == null, mat == null)) this._shader = null;
      final Matrix3? prev = this._txt2DMat;
      this._txt2DMat = mat;
      this._onChanged(events.ValueChangedEventArgs(this, 'texture2DMatrix', prev, this._txt2DMat));
    }
  }

  /// The cube texture modification matrix.
  Matrix4? get textureCubeMatrix => this._txtCubeMat;

  set textureCubeMatrix(Matrix4? mat) {
    if (this._txtCubeMat != mat) {
      if (xor(this._txtCubeMat == null, mat == null)) this._shader = null;
      final Matrix4? prev = this._txtCubeMat;
      this._txtCubeMat = mat;
      this._onChanged(events.ValueChangedEventArgs(this, 'textureCubeMatrix', prev, this._txtCubeMat));
    }
  }

  /// The color modification matrix.
  Matrix4? get colorMatrix => this._colorMat;

  set colorMatrix(Matrix4? mat) {
    if (this._colorMat != mat) {
      if (xor(this._colorMat == null, mat == null)) this._shader = null;
      final Matrix4? prev = this._colorMat;
      this._colorMat = mat;
      this._onChanged(events.ValueChangedEventArgs(this, 'colorMatrix', prev, this._colorMat));
    }
  }

  /// The list of matrices for bending the shape by weights.
  Collection<Matrix4> get bendMatrices => this._bendMats;

  /// The emission component of the material.
  MaterialLightColorComponent get emission => this._emission ??= MaterialLightColorComponent._(this, 'emission');

  /// The ambient component of the material.
  MaterialLightColorComponent get ambient => this._ambient ??= MaterialLightColorComponent._(this, 'ambient');

  /// The diffuse component of the material.
  MaterialLightColorComponent get diffuse => this._diffuse ??= MaterialLightColorComponent._(this, 'diffuse');

  /// The inverse diffuse (transmission) component of the material.
  MaterialLightColorComponent get invDiffuse => this._invDiffuse ??= MaterialLightColorComponent._(this, 'invDiffuse');

  /// The specular component of the material.
  MaterialLightSpecularComponent get specular => this._specular ??= MaterialLightSpecularComponent._(this, 'specular');

  /// The specular component of the material.
  MaterialLightBumpComponent get bump => this._bump ??= MaterialLightBumpComponent._(this, 'bump');

  /// The fog component of to render with.
  MaterialLightFogComponent get fog => this._fog ??= MaterialLightFogComponent._(this);

  /// The environment cube texture for reflective and refractive materials.
  TextureCube? get environment => this._envSampler;

  set environment(TextureCube? txt) {
    if (this._envSampler != txt) {
      this._envSampler?.changed.remove(this._onChanged);
      final TextureCube? prev = this._envSampler;
      this._envSampler = txt;
      this._envSampler?.changed.add(this._onChanged);
      this._onChanged(events.ValueChangedEventArgs(this, 'environment', prev, this._envSampler));
    }
  }

  /// The reflection component of the material.
  MaterialLightColorComponent get reflection => this._reflect ??= MaterialLightColorComponent._(this, 'reflect');

  /// The refraction component of the material.
  MaterialLightRefractionComponent get refraction =>
      this._refract ??= MaterialLightRefractionComponent._(this, 'refract');

  /// The alpha value or scalar on the alpha texture for the material.
  MaterialLightAlphaComponent get alpha => this._alpha ??= MaterialLightAlphaComponent._(this, 'alpha');

  /// Gets the vertex source code used for the shader used by this technique.
  String get vertexSourceCode => this._shader?.vertexSourceCode ?? '';

  /// Gets the fragment source code used for the shader used by this technique.
  String get fragmentSourceCode => this._shader?.fragmentSourceCode ?? '';

  /// Calculates a limit for the lights and other arrays for the shader from
  /// the current number of lights and lengths. This helps reduce and reuse
  /// shaders with similar number of attributes.
  int _lengthLimit(int count) => ((count + 3) ~/ 4) * 4;

  /// Creates the configuration for this shader.
  shaders.MaterialLightConfig _config() {
    // Collect configuration for bar lights.
    final Map<int, int> barLightCounter = <int, int>{};
    for (final lights_.Bar light in this._lights?.barLights ?? []) {
      barLightCounter[light.configID] = barLightCounter[light.configID] ?? 0 + 1;
    }
    final List<shaders.BarLightConfig> barLights = [];
    barLightCounter.forEach(
        (int configID, int count) => barLights.add(shaders.BarLightConfig(configID, this._lengthLimit(count))));
    barLights.sort((shaders.BarLightConfig a, shaders.BarLightConfig b) => a.configID.compareTo(b.configID));

    // Collect configuration for directional lights.
    final Map<int, int> dirLightCounter = <int, int>{};
    for (final lights_.Directional light in this._lights?.directionalLights ?? []) {
      dirLightCounter[light.configID] = dirLightCounter[light.configID] ?? 0 + 1;
    }
    final List<shaders.DirectionalLightConfig> dirLights = [];
    dirLightCounter.forEach(
        (int configID, int count) => dirLights.add(shaders.DirectionalLightConfig(configID, this._lengthLimit(count))));
    dirLights
        .sort((shaders.DirectionalLightConfig a, shaders.DirectionalLightConfig b) => a.configID.compareTo(b.configID));

    // Collect configuration for point lights.
    final Map<int, int> pointLightCounter = <int, int>{};
    for (final lights_.Point light in this._lights?.pointLights ?? []) {
      pointLightCounter[light.configID] = pointLightCounter[light.configID] ?? 0 + 1;
    }
    final List<shaders.PointLightConfig> pointLights = [];
    pointLightCounter.forEach(
        (int configID, int count) => pointLights.add(shaders.PointLightConfig(configID, this._lengthLimit(count))));
    pointLights.sort((shaders.PointLightConfig a, shaders.PointLightConfig b) => a.configID.compareTo(b.configID));

    // Collect configuration for spot lights.
    final Map<int, int> spotLightCounter = <int, int>{};
    for (final lights_.Spot light in this._lights?.spotLights ?? []) {
      spotLightCounter[light.configID] = spotLightCounter[light.configID] ?? 0 + 1;
    }
    final List<shaders.SpotLightConfig> spotLights = [];
    spotLightCounter.forEach(
        (int configID, int count) => spotLights.add(shaders.SpotLightConfig(configID, this._lengthLimit(count))));
    spotLights.sort((shaders.SpotLightConfig a, shaders.SpotLightConfig b) => a.configID.compareTo(b.configID));

    final int bendMats = this._lengthLimit(this._bendMats.length);
    return shaders.MaterialLightConfig(
        this._txt2DMat != null,
        this._txtCubeMat != null,
        this._colorMat != null,
        this.fog.enabled,
        bendMats,
        this.emission.type,
        this.ambient.type,
        this.diffuse.type,
        this.invDiffuse.type,
        this.specular.type,
        this.bump.type,
        this.reflection.type,
        this.refraction.type,
        this.alpha.type,
        barLights,
        dirLights,
        pointLights,
        spotLights);
  }

  /// Checks if the texture is in the list and if not, sets it's index and adds it to the list.
  void _addToTextureList(List<Texture> textures, Texture? txt) {
    if (txt != null) {
      if (!textures.contains(txt)) {
        txt.index = textures.length;
        textures.add(txt);
      }
    }
  }

  /// Updates the light and material technique.
  @override
  void update(RenderState state) {
    for (final lights_.Light light in this._lights ?? []) {
      light.update(state);
    }
  }

  /// Renders the given [obj] with the current light and material for the given [state].
  @override
  void render(RenderState state, Entity obj) {
    var shader = this._shader;
    if (shader == null) {
      this._shader = shader = shaders.MaterialLight.cached(this._config(), state);
      obj.clearCache();
    }
    final shaders.MaterialLightConfig cfg = shader.configuration;
    final VertexType vertexType = cfg.vertexType;
    if (obj.cache is! BufferStore) obj.clearCache();
    if (obj.cacheNeedsUpdate || (obj.cache as BufferStore?)!.vertexType != vertexType) {
      if (cfg.norm) obj.shapeBuilder?.calculateNormals();
      if (cfg.binm) obj.shapeBuilder?.calculateBinormals();
      if (cfg.txtCube) obj.shapeBuilder?.calculateCubeTextures();
      final BufferStore? cache = obj.shapeBuilder?.build(WebGLBufferBuilder(state.gl), vertexType);
      if (cache == null) return;
      cache.findAttribute(VertexType.Pos)?.attr = shader.posAttr?.loc ?? 0;
      if (cfg.norm) cache.findAttribute(VertexType.Norm)?.attr = shader.normAttr?.loc ?? 1;
      if (cfg.binm) cache.findAttribute(VertexType.Binm)?.attr = shader.binmAttr?.loc ?? 2;
      if (cfg.txt2D) cache.findAttribute(VertexType.Txt2D)?.attr = shader.txt2DAttr?.loc ?? 3;
      if (cfg.txtCube) cache.findAttribute(VertexType.TxtCube)?.attr = shader.txtCubeAttr?.loc ?? 4;
      if (cfg.bending) cache.findAttribute(VertexType.Bending)?.attr = shader.bendAttr?.loc ?? 5;
      obj.cache = cache;
    }
    final List<Texture> textures = [];
    shader.bind(state);
    if (cfg.objMat) shader.objectMatrix = state.object.matrix;
    if (cfg.viewObjMat) shader.viewObjectMatrix = state.viewObjectMatrix;
    if (cfg.projViewObjMat) shader.projectViewObjectMatrix = state.projectionViewObjectMatrix;
    if (cfg.viewMat) shader.viewMatrix = state.view.matrix;
    if (cfg.projViewMat) shader.projectViewMatrix = state.projectionViewMatrix;
    if (cfg.txt2DMat) shader.texture2DMatrix = this._txt2DMat ?? Matrix3.identity;
    if (cfg.txtCubeMat) shader.textureCubeMatrix = this._txtCubeMat ?? Matrix4.identity;
    if (cfg.colorMat) shader.colorMatrix = this._colorMat ?? Matrix4.identity;
    if (cfg.bendMats > 0) {
      final int count = this._bendMats.length;
      shader.bendMatricesCount = count;
      for (int i = 0; i < count; ++i) {
        shader.setBendMatrix(i, this._bendMats[i]);
      }
    }
    if (cfg.emission.hasSolid) {
      shader.emissionColor = this._emission?.color ?? Color3.black();
    }
    if (cfg.emission.hasTxt2D) {
      this._addToTextureList(textures, this._emission?.texture2D);
      shader.emissionTexture2D = this._emission?.texture2D;
    } else if (cfg.emission.hasTxtCube) {
      this._addToTextureList(textures, this._emission?.textureCube);
      shader.emissionTextureCube = this._emission?.textureCube;
    }
    if (cfg.lights) {
      if (cfg.ambient.hasSolid) {
        shader.ambientColor = this._ambient?.color ?? Color3.black();
      }
      if (cfg.ambient.hasTxt2D) {
        this._addToTextureList(textures, this._ambient?.texture2D);
        shader.ambientTexture2D = this._ambient?.texture2D;
      } else if (cfg.ambient.hasTxtCube) {
        this._addToTextureList(textures, this._ambient?.textureCube);
        shader.ambientTextureCube = this._ambient?.textureCube;
      }
      if (cfg.diffuse.hasSolid) {
        shader.diffuseColor = this._diffuse?.color ?? Color3.black();
      }
      if (cfg.diffuse.hasTxt2D) {
        this._addToTextureList(textures, this._diffuse?.texture2D);
        shader.diffuseTexture2D = this._diffuse?.texture2D;
      } else if (cfg.diffuse.hasTxtCube) {
        this._addToTextureList(textures, this._diffuse?.textureCube);
        shader.diffuseTextureCube = this._diffuse?.textureCube;
      }
      if (cfg.invDiffuse.hasSolid) {
        shader.invDiffuseColor = this._invDiffuse?.color ?? Color3.black();
      }
      if (cfg.invDiffuse.hasTxt2D) {
        this._addToTextureList(textures, this._invDiffuse?.texture2D);
        shader.invDiffuseTexture2D = this._invDiffuse?.texture2D;
      } else if (cfg.invDiffuse.hasTxtCube) {
        this._addToTextureList(textures, this._invDiffuse?.textureCube);
        shader.invDiffuseTextureCube = this._invDiffuse?.textureCube;
      }
      if (cfg.specular.hasAny) {
        shader.shininess = this._specular?.shininess ?? 100.0;
      }
      if (cfg.specular.hasSolid) {
        shader.specularColor = this._specular?.color ?? Color3.white();
      }
      if (cfg.specular.hasTxt2D) {
        this._addToTextureList(textures, this._specular?.texture2D);
        shader.specularTexture2D = this._specular?.texture2D;
      } else if (cfg.specular.hasTxtCube) {
        this._addToTextureList(textures, this._specular?.textureCube);
        shader.specularTextureCube = this._specular?.textureCube;
      }
      if (cfg.barLights.isNotEmpty) {
        final Map<int, int> barLightCounter = <int, int>{};
        for (final lights_.Bar light in this._lights?.barLights ?? []) {
          final int configID = light.configID;
          final int index = barLightCounter[configID] ?? 0;
          barLightCounter[configID] = index + 1;
          final shaders.UniformBarLight uniform = shader.getBarLight(configID)[index];
          uniform.startPoint = light.startMatrix.transPnt3(Point3.zero);
          uniform.endPoint = light.endMatrix.transPnt3(Point3.zero);
          uniform.color = light.color ?? Color3.white();
          if (light.enableAttenuation) {
            uniform.attenuation0 = light.attenuation0;
            uniform.attenuation1 = light.attenuation1;
            uniform.attenuation2 = light.attenuation2;
          }
        }
        for (final shaders.BarLightConfig light in cfg.barLights) {
          final int count = barLightCounter[light.configID] ?? 0;
          shader.setBarLightCount(light.configID, count);
        }
      }
      if (cfg.dirLights.isNotEmpty) {
        final Matrix4 viewMat = state.view.matrix;
        final Map<int, int> dirLightCounter = <int, int>{};
        for (final lights_.Directional light in this._lights?.directionalLights ?? []) {
          final int configID = light.configID;
          final int index = dirLightCounter[configID] ?? 0;
          dirLightCounter[configID] = index + 1;
          final shaders.UniformDirectionalLight uniform = shader.getDirectionalLight(configID)[index];
          uniform.viewDir = viewMat.transVec3(light.direction).normal();
          uniform.color = light.color ?? Color3.white();
          if (light.texture != null) {
            uniform.objectDir = light.direction;
            uniform.objectUp = light.up;
            uniform.objectRight = light.right;
            this._addToTextureList(textures, light.texture);
            uniform.texture = light.texture;
          }
        }
        for (final shaders.DirectionalLightConfig light in cfg.dirLights) {
          final int count = dirLightCounter[light.configID] ?? 0;
          shader.setDirectionalLightCount(light.configID, count);
        }
      }
      if (cfg.pointLights.isNotEmpty) {
        final Matrix4 viewMat = state.view.matrix;
        final Map<int, int> pointLightCounter = <int, int>{};
        for (final lights_.Point light in this._lights?.pointLights ?? []) {
          final int configID = light.configID;
          final int index = pointLightCounter[configID] ?? 0;
          pointLightCounter[configID] = index + 1;
          final shaders.UniformPointLight uniform = shader.getPointLight(configID)[index];
          final Matrix4 viewObjMat = viewMat * light.matrix;
          uniform.point = light.matrix.transPnt3(Point3.zero);
          uniform.viewPoint = viewObjMat.transPnt3(Point3.zero);
          uniform.color = light.color ?? Color3.white();
          if (light.texture != null || light.shadow != null) {
            uniform.inverseViewRotationMatrix = Matrix3.fromMatrix4(viewObjMat.inverse());
          }
          if (light.texture != null) {
            this._addToTextureList(textures, light.texture);
            uniform.texture = light.texture;
          }
          if (light.shadow != null) {
            uniform.shadowAdjust = light.shadowAdjust ?? Vector4.zero;
            this._addToTextureList(textures, light.shadow);
            uniform.shadow = light.shadow;
          }
          if (light.enableAttenuation) {
            uniform.attenuation0 = light.attenuation0;
            uniform.attenuation1 = light.attenuation1;
            uniform.attenuation2 = light.attenuation2;
          }
        }
        for (final shaders.PointLightConfig light in cfg.pointLights) {
          final int count = pointLightCounter[light.configID] ?? 0;
          shader.setPointLightCount(light.configID, count);
        }
      }
      if (cfg.spotLights.isNotEmpty) {
        final Matrix4 viewMat = state.view.matrix;
        final Map<int, int> spotLightCounter = <int, int>{};
        for (final lights_.Spot light in this._lights?.spotLights ?? []) {
          final int configID = light.configID;
          final int index = spotLightCounter[configID] ?? 0;
          spotLightCounter[configID] = index + 1;
          final shaders.UniformSpotLight uniform = shader.getSpotLight(configID)[index];
          uniform.objectPoint = light.position;
          uniform.objectDirection = light.direction.normal();
          uniform.viewPoint = viewMat.transPnt3(light.position);
          uniform.color = light.color ?? Color3.white();
          if (light.texture != null || light.shadow != null) {
            uniform.objectUp = light.up;
            uniform.objectRight = light.right;
            uniform.tuScalar = light.tuScalar;
            uniform.tvScalar = light.tvScalar;
          }
          if (light.texture != null) {
            this._addToTextureList(textures, light.texture);
            uniform.texture = light.texture;
          }
          if (light.shadow != null) {
            uniform.shadowAdjust = light.shadowAdjust ?? Vector4.zero;
            this._addToTextureList(textures, light.shadow);
            uniform.shadow = light.shadow;
          }
          if (light.enableCutOff) {
            uniform.cutoff = light.cutoff;
            uniform.coneAngle = light.coneAngle;
          }
          if (light.enableAttenuation) {
            uniform.attenuation0 = light.attenuation0;
            uniform.attenuation1 = light.attenuation1;
            uniform.attenuation2 = light.attenuation2;
          }
        }
        for (final shaders.SpotLightConfig light in cfg.spotLights) {
          final int count = spotLightCounter[light.configID] ?? 0;
          shader.setSpotLightCount(light.configID, count);
        }
      }
    }
    if (cfg.bumpy.hasTxt2D) {
      this._addToTextureList(textures, this._bump?.texture2D);
      shader.bumpTexture2D = this._bump?.texture2D;
    } else if (cfg.bumpy.hasTxtCube) {
      this._addToTextureList(textures, this._bump?.textureCube);
      shader.bumpTextureCube = this._bump?.textureCube;
    }
    if (cfg.invViewMat) {
      shader.inverseViewMatrix = state.inverseViewMatrix;
    }
    if (cfg.environmental) {
      this._addToTextureList(textures, this._envSampler);
      shader.environmentTextureCube = this._envSampler;
      if (cfg.reflection.hasSolid) {
        shader.reflectionColor = this._reflect?.color ?? Color3.white();
      }
      if (cfg.reflection.hasTxt2D) {
        this._addToTextureList(textures, this._reflect?.texture2D);
        shader.reflectionTexture2D = this._reflect?.texture2D;
      } else if (cfg.reflection.hasTxtCube) {
        this._addToTextureList(textures, this._reflect?.textureCube);
        shader.reflectionTextureCube = this._reflect?.textureCube;
      }
      if (cfg.refraction.hasAny) {
        shader.refraction = this._refract?.deflection ?? 0.0;
      }
      if (cfg.refraction.hasSolid) {
        shader.refractionColor = this._refract?.color ?? Color3.white();
      }
      if (cfg.refraction.hasTxt2D) {
        this._addToTextureList(textures, this._refract?.texture2D);
        shader.refractionTexture2D = this._refract?.texture2D;
      } else if (cfg.refraction.hasTxtCube) {
        this._addToTextureList(textures, this._refract?.textureCube);
        shader.refractionTextureCube = this._refract?.textureCube;
      }
    }
    if (cfg.fog) {
      final fog = this._fog;
      if (fog != null) {
        shader.fogColor = fog.color ?? Color4.white();
        shader.fogStop = fog.stop;
        shader.fogWidth = fog.start - fog.stop;
      }
    }
    if (cfg.alpha.hasAny) {
      if (cfg.alpha.hasSolid) {
        shader.alpha = this._alpha?.value ?? 1.0;
      }
      if (cfg.alpha.hasTxt2D) {
        this._addToTextureList(textures, this._alpha?.texture2D);
        shader.alphaTexture2D = this._alpha?.texture2D;
      } else if (cfg.alpha.hasTxtCube) {
        this._addToTextureList(textures, this._alpha?.textureCube);
        shader.alphaTextureCube = this._alpha?.textureCube;
      }
      state.gl.enable(webgl.WebGL.BLEND);
      state.gl.blendFunc(webgl.WebGL.SRC_ALPHA, webgl.WebGL.ONE_MINUS_SRC_ALPHA);
    }
    for (int i = 0; i < textures.length; i++) {
      textures[i].bind(state);
    }
    (obj.cache as BufferStore?)!
      ..bind(state)
      ..render(state)
      ..unbind(state);
    if (cfg.alpha.hasAny) {
      state.gl.disable(webgl.WebGL.BLEND);
    }
    for (int i = 0; i < textures.length; i++) {
      textures[i].unbind(state);
    }
    shader.unbind(state);
  }

  /// The string for the technique
  @override
  String toString() {
    final shader = this._shader;
    if (shader != null) {
      return shader.name;
    } else {
      return this._config().name;
    }
  }
}

/// A material light component which allows setting an alpha value.
class MaterialLightAlphaComponent extends MaterialLightBaseComponent {
  double _alpha;

  /// Creates a new alpha material light component for the given [owner].
  MaterialLightAlphaComponent._(MaterialLight owner, String name)
      : this._alpha = 1.0,
        super._(owner, name);

  /// Handles setting the alpha member if it has changed.
  void _setAlpha(double alpha) {
    if (!Comparer.equals(this._alpha, alpha)) {
      final double prev = this._alpha;
      this._alpha = alpha;
      this._onChanged(events.ValueChangedEventArgs(this, this._name, prev, this._alpha));
    }
  }

  /// Handles clearing the alpha when the component is being cleared.
  @override
  void _onClear() {
    super._onClear();
    this._setAlpha(1.0);
  }

  /// Handles the component being set from None to some other source type.
  @override
  void _onComponentSet() {
    super._onComponentSet();
    this._setAlpha(1.0);
  }

  /// The alpha scalar for the color for the material.
  double get value => this._alpha;

  set value(double value) {
    if (value <= 0.0) {
      this._setNewType(this._type.enableSolid(false));
      this._setAlpha(0.0);
    } else {
      this._setNewType(this._type.enableSolid(true));
      this._setAlpha(value >= 1.0 ? 1.0 : value);
    }
  }
}

/// Base class for a material light component.
/// A material light component is the color, texture, and values
/// for a specific setting for the material light technique,
/// such as ambient, diffuse, specular, etc.
abstract class MaterialLightBaseComponent {
  final MaterialLight _owner;
  final String _name;
  shaders.ColorSourceType _type;
  Texture2D? _txt2D;
  TextureCube? _txtCube;

  /// Creates a new base component for the given [_owner] and [_name].
  MaterialLightBaseComponent._(this._owner, this._name)
      : this._type = shaders.ColorSourceType(),
        this._txt2D = null,
        this._txtCube = null;

  /// Handles changes in the component.
  void _onChanged([events.EventArgs? args]) => this._owner._onChanged(args);

  /// Handles type changes to the component.
  void _onTypeChanged() => this._owner._resetShader();

  /// Is called when the component is cleared.
  void _onClear() {
    // Do Nothing
  }

  /// Is called when the component is set from the
  /// source type None to any other source type.
  void _onComponentSet() {
    // Do Nothing
  }

  /// Sets the 2D texture member if it has changed.
  /// This will connect the changed events and call changed.
  void _setTxt2D(Texture2D? txt2D) {
    if (this._txt2D != txt2D) {
      this._txt2D?.changed.remove(this._onChanged);
      final Texture2D? prev = this._txt2D;
      this._txt2D = txt2D;
      this._txt2D?.changed.add(this._onChanged);
      this._onChanged(events.ValueChangedEventArgs(this, this._name + '.texture2D', prev, this._txt2D));
    }
  }

  /// Sets the Cube texture member if it has changed.
  /// This will connect the changed events and call changed.
  void _setTxtCube(TextureCube? txtCube) {
    if (this._txtCube != txtCube) {
      this._txtCube?.changed.remove(this._onChanged);
      final TextureCube? prev = this._txtCube;
      this._txtCube = txtCube;
      this._txtCube?.changed.add(this._onChanged);
      this._onChanged(events.ValueChangedEventArgs(this, this._name + '.textureCube', prev, this._txtCube));
    }
  }

  /// The type of source this component will get it's color from.
  shaders.ColorSourceType get type => this._type;

  /// Sets the type of the source type component will get it's color from.
  void _setNewType(shaders.ColorSourceType newType) {
    if (this._type != newType) {
      final bool componentChange = this._type.hasNone || newType.hasNone;
      this._type = newType;
      if (componentChange) this._onComponentSet();
      this._onTypeChanged();
    }
  }

  /// Removes any of this component from the material.
  void clear() {
    this._setNewType(shaders.ColorSourceType());
    this._onClear();
    this._setTxt2D(null);
    this._setTxtCube(null);
    this._onChanged();
  }

  /// The 2D texture for the material component.
  Texture2D? get texture2D => this._txt2D;

  set texture2D(Texture2D? txt) {
    if (txt == null) {
      this._setNewType(this._type.enableTxt2D(false));
    } else if (!this._type.hasTxt2D) {
      this._setNewType(this._type.enableTxt2D(true));
      this._setTxtCube(null);
    }
    this._setTxt2D(txt);
  }

  /// The cube texture for the material component.
  TextureCube? get textureCube => this._txtCube;

  set textureCube(TextureCube? txt) {
    if (txt == null) {
      this._setNewType(this._type.enableTxtCube(false));
    } else if (!this._type.hasTxtCube) {
      this._setNewType(this._type.enableTxtCube(true));
      this._setTxt2D(null);
    }
    this._setTxtCube(txt);
  }
}

/// A material light component for assigning a bump map.
class MaterialLightBumpComponent extends MaterialLightBaseComponent {
  /// Creates a new bump map material light component for the given [owner].
  MaterialLightBumpComponent._(MaterialLight owner, String name) : super._(owner, name) {
    // Do Nothing
  }
}

/// A material light component which allows a solid color.
class MaterialLightColorComponent extends MaterialLightBaseComponent {
  Color3? _color;

  /// Creates a new material light color component for the given [owner].
  MaterialLightColorComponent._(MaterialLight owner, String name)
      : this._color = Color3.black(),
        super._(owner, name);

  /// Handles setting the color member if it has changed.
  void _setColor(Color3? color) {
    if (this._color != color) {
      final Color3? prev = this._color;
      this._color = color;
      this._onChanged(events.ValueChangedEventArgs(this, this._name + '.color', prev, this._color));
    }
  }

  /// Handles clearing the color when the component is being cleared.
  @override
  void _onClear() {
    super._onClear();
    this._setColor(Color3.black());
  }

  /// Handles the component being set from None to some other source type.
  @override
  void _onComponentSet() {
    super._onComponentSet();
    this._setColor(Color3.white());
  }

  /// The color or scalar on the texture for the material component.
  Color3? get color => this._color;

  set color(Color3? clr) {
    this._setNewType(this._type.enableSolid(clr != null));
    this._setColor(clr);
  }
}

/// A material light component for fog.
class MaterialLightFogComponent {
  final MaterialLight _owner;
  Color4? _clr;
  double _start;
  double _stop;
  bool _enabled;

  /// Creates a new fog component for the given [_owner].
  MaterialLightFogComponent._(this._owner)
      : this._clr = Color4.transparent(),
        this._start = 1.0,
        this._stop = 10.0,
        this._enabled = false;

  /// Handles changes in the component.
  void _onChanged([events.EventArgs? args]) => this._owner._onChanged(args);

  /// Handles type changes to the component.
  void _onTypeChanged() => this._owner._resetShader();

  /// Gets or sets if fog should be enabled.
  bool get enabled => this._enabled;

  set enabled(bool enabled) {
    if (this._enabled != enabled) {
      this._enabled = enabled;
      this._onTypeChanged();
    }
  }

  /// The color for the material component fog.
  Color4? get color => this._clr;

  set color(Color4? color) {
    // ignore: parameter_assignments
    color ??= Color4.transparent();
    if (this._clr != color) {
      this.enabled = true;
      this._clr = color;
      this._onChanged();
    }
  }

  /// The maximum depth at which only the fog color would be drawn.
  double get start => this._start;

  set start(double start) {
    if (this._start != start) {
      this.enabled = true;
      this._start = start;
      this._onChanged();
    }
  }

  /// The minimum depth at which the fog was not drawn.
  double get stop => this._stop;

  set stop(double stop) {
    if (this._stop != stop) {
      this.enabled = true;
      this._stop = stop;
      this._onChanged();
    }
  }
}

/// A material light component which allows refraction to be assigned.
class MaterialLightRefractionComponent extends MaterialLightColorComponent {
  double _refraction;

  /// Creates a new refraction material light component for the given [owner].
  MaterialLightRefractionComponent._(MaterialLight owner, String name)
      : this._refraction = 1.0,
        super._(owner, name);

  /// Handles setting the refraction member if it has changed.
  void _setRefraction(double refraction) {
    if (!Comparer.equals(this._refraction, refraction)) {
      final double prev = this._refraction;
      this._refraction = refraction;
      this._onChanged(events.ValueChangedEventArgs(this, this._name + '.refraction', prev, this._refraction));
    }
  }

  /// Handles clearing the refraction when the component is being cleared.
  @override
  void _onClear() {
    super._onClear();
    this._setRefraction(1.0);
  }

  /// Handles the component being set from None to some other source type.
  @override
  void _onComponentSet() {
    super._onComponentSet();
    this._setRefraction(1.0);
  }

  /// The refraction scalar for the distortion for the material.
  double get deflection => this._refraction;

  set deflection(double value) {
    if (value <= 0.0) {
      this._setNewType(this._type.enableSolid(false));
      this._setRefraction(0.0);
    } else {
      this._setNewType(this._type.enableSolid(true));
      this._setRefraction(value);
    }
  }
}

/// A material light color component which allows a specular value to be assigned.
class MaterialLightSpecularComponent extends MaterialLightColorComponent {
  double _shininess;

  /// Creates a new specular component for the given [owner].
  MaterialLightSpecularComponent._(MaterialLight owner, String name)
      : this._shininess = 100.0,
        super._(owner, name);

  /// Handles setting the shininess specular member.
  void _setShininess(double shininess) {
    if (!Comparer.equals(this._shininess, shininess)) {
      final double prev = this._shininess;
      this._shininess = shininess;
      this._onChanged(events.ValueChangedEventArgs(this, this._name + '.shininess', prev, this._shininess));
    }
  }

  /// Handles clearing the shininess when the component is being cleared.
  @override
  void _onClear() {
    super._onClear();
    this._setShininess(100.0);
  }

  /// Handles the component being set from None to some other source type.
  @override
  void _onComponentSet() {
    super._onComponentSet();
    this._setShininess(100.0);
  }

  /// The specular color or scalar on the specular texture for the material.
  double get shininess => this._shininess;

  set shininess(double value) {
    if (value <= 0.0) {
      this._setNewType(this._type.enableSolid(false));
      this._setShininess(0.0);
    } else {
      this._setNewType(this._type.enableSolid(true));
      this._setShininess(value);
    }
  }
}

/// The normal rendering technique.
class Normal extends Technique {
  shaders.Normal? _shader;
  Matrix3 _txt2DMat;
  Matrix4 _txtCubeMat;
  shaders.ColorSourceType _bumpyType;
  Texture2D? _bump2D;
  TextureCube? _bumpCube;
  events.Event? _changed;

  /// Creates a new material/light technique.
  Normal()
      : this._shader = null,
        this._txt2DMat = Matrix3.identity,
        this._txtCubeMat = Matrix4.identity,
        this._bumpyType = shaders.ColorSourceType(),
        this._bump2D = null,
        this._bumpCube = null,
        this._changed = null {
    this.clearBump();
  }

  /// Indicates that this technique has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this technique.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  void _setBump2D(Texture2D? bump2D) {
    if (this._bump2D != bump2D) {
      this._bump2D?.changed.remove(this._onChanged);
      final Texture2D? prev = this._bump2D;
      this._bump2D = bump2D;
      this._bump2D?.changed.add(this._onChanged);
      this._onChanged(events.ValueChangedEventArgs(this, 'bumpyTexture2D', prev, this._bump2D));
    }
  }

  void _setBumpCube(TextureCube? bumpCube) {
    if (this._bumpCube != bumpCube) {
      this._bumpCube?.changed.remove(this._onChanged);
      final TextureCube? prev = this._bumpCube;
      this._bumpCube = bumpCube;
      this._bumpCube?.changed.add(this._onChanged);
      this._onChanged(events.ValueChangedEventArgs(this, 'bumpyTextureCube', prev, this._bumpCube));
    }
  }

  /// The 2D texture modification matrix.
  Matrix3? get texture2DMatrix => this._txt2DMat;

  set texture2DMatrix(Matrix3? mat) {
    // ignore: parameter_assignments
    mat ??= Matrix3.identity;
    if (this._txt2DMat != mat) {
      final prev = this._txt2DMat;
      this._txt2DMat = mat;
      this._onChanged(events.ValueChangedEventArgs(this, 'texture2DMatrix', prev, this._txt2DMat));
    }
  }

  /// The cube texture modification matrix.
  Matrix4? get textureCubeMatrix => this._txtCubeMat;

  set textureCubeMatrix(Matrix4? mat) {
    // ignore: parameter_assignments
    mat ??= Matrix4.identity;
    if (this._txtCubeMat != mat) {
      final prev = this._txtCubeMat;
      this._txtCubeMat = mat;
      this._onChanged(events.ValueChangedEventArgs(this, 'textureCubeMatrix', prev, this._txtCubeMat));
    }
  }

  /// Gets the vertex source code used for the shader used by this technique.
  String get vertexSourceCode => this._shader?.vertexSourceCode ?? '';

  /// Gets the fragment source code used for the shader used by this technique.
  String get fragmentSourceCode => this._shader?.fragmentSourceCode ?? '';

  /// Removes any normal distortion from the material.
  void clearBump() {
    if (this._bumpyType.hasAny) {
      this._shader = null;
      this._bumpyType = shaders.ColorSourceType();
    }
    this._setBump2D(null);
    this._setBumpCube(null);
    this._onChanged();
  }

  /// The normal distortion 2D texture for the material.
  Texture2D? get bumpyTexture2D => this._bump2D;

  set bumpyTexture2D(Texture2D? txt) {
    if (txt == null) {
      if (this._bumpyType.hasTxt2D) {
        this._shader = null;
        this._bumpyType = shaders.ColorSourceType();
      }
    } else if (!this._bumpyType.hasTxt2D) {
      this._bumpyType = this._bumpyType.enableTxt2D(true);
      this._setBumpCube(null);
      this._shader = null;
    }
    this._setBump2D(txt);
  }

  /// The normal distortion cube texture for the material.
  TextureCube? get bumpyTextureCube => this._bumpCube;

  set bumpyTextureCube(TextureCube? txt) {
    if (txt == null) {
      if (this._bumpyType.hasTxtCube) {
        this._shader = null;
        this._bumpyType = shaders.ColorSourceType();
      }
    } else if (!this._bumpyType.hasTxtCube) {
      this._bumpyType = this._bumpyType.enableTxtCube(true);
      this._setBump2D(null);
      this._shader = null;
    }
    this._setBumpCube(txt);
  }

  /// Creates the configuration for this shader.
  shaders.NormalConfig _config() {
    return shaders.NormalConfig(this._bumpyType);
  }

  /// Checks if the texture is in the list and if not, sets it's index and adds it to the list.
  void _addToTextureList(List<Texture> textures, Texture? txt) {
    if (txt != null) {
      if (!textures.contains(txt)) {
        txt.index = textures.length;
        textures.add(txt);
      }
    }
  }

  /// Updates the light and material technique.
  @override
  void update(RenderState state) {
    // Do Nothing
  }

  /// Renders the given [obj] with the current light and material for the given [state].
  @override
  void render(RenderState state, Entity obj) {
    var shader = this._shader;
    if (shader == null) {
      this._shader = shader = shaders.Normal.cached(this._config(), state);
      obj.clearCache();
    }
    final shaders.NormalConfig cfg = shader.configuration;
    final VertexType vertexType = cfg.vertexType;
    if (obj.cache is! BufferStore) obj.clearCache();
    if (obj.cacheNeedsUpdate || (obj.cache as BufferStore?)!.vertexType != vertexType) {
      obj.shapeBuilder?.calculateNormals();
      if (cfg.binm) obj.shapeBuilder?.calculateBinormals();
      if (cfg.txtCube) obj.shapeBuilder?.calculateCubeTextures();

      final BufferStore? cache = obj.shapeBuilder?.build(WebGLBufferBuilder(state.gl), vertexType);
      if (cache == null) return;
      cache.findAttribute(VertexType.Pos)?.attr = shader.posAttr?.loc ?? 0;
      cache.findAttribute(VertexType.Norm)?.attr = shader.normAttr?.loc ?? 1;
      if (cfg.binm) cache.findAttribute(VertexType.Binm)?.attr = shader.binmAttr?.loc ?? 2;
      if (cfg.txt2D) cache.findAttribute(VertexType.Txt2D)?.attr = shader.txt2DAttr?.loc ?? 3;
      if (cfg.txtCube) cache.findAttribute(VertexType.TxtCube)?.attr = shader.txtCubeAttr?.loc ?? 4;
      obj.cache = cache;
    }

    final List<Texture> textures = [];
    shader.bind(state);

    shader.viewObjectMatrix = state.viewObjectMatrix;
    shader.projectViewObjectMatrix = state.projectionViewObjectMatrix;
    if (cfg.txt2D) shader.texture2DMatrix = this._txt2DMat;
    if (cfg.txtCube) shader.textureCubeMatrix = this._txtCubeMat;

    if (cfg.bumpy.hasTxt2D) {
      final bump2D = this._bump2D;
      if (bump2D != null) {
        this._addToTextureList(textures, bump2D);
        shader.bumpTexture2D = bump2D;
      }
    } else if (cfg.bumpy.hasTxtCube) {
      final bumpCube = this._bumpCube;
      if (bumpCube != null) {
        this._addToTextureList(textures, bumpCube);
        shader.bumpTextureCube = bumpCube;
      }
    }

    for (int i = 0; i < textures.length; i++) {
      textures[i].bind(state);
    }

    (obj.cache as BufferStore?)!
      ..bind(state)
      ..render(state)
      ..unbind(state);

    for (int i = 0; i < textures.length; i++) {
      textures[i].unbind(state);
    }
    shader.unbind(state);
  }

  /// The string for the technique
  @override
  String toString() => this._shader?.name ?? this._config().name;
}

/// A technique for a cover pass with a sky box.
class Skybox extends Technique {
  shaders.Skybox? _shader;
  double _fov;
  TextureCube? _boxTxt;
  Color3 _boxClr;
  events.Event? _changed;

  /// Creates a new sky box technique with the given initial values.
  Skybox({double fov = PI_3, TextureCube? boxTexture, Color3? boxColor})
      : this._shader = null,
        this._fov = fov,
        this._boxTxt = null,
        this._boxClr = boxColor ?? Color3.white(),
        this._changed = null {
    this.boxTexture = boxTexture;
  }

  /// Indicates that this technique has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this technique.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  /// Field of view vertically in radians of the camera.
  double get fov => this._fov;

  set fov(double fov) {
    if (!Comparer.equals(this._fov, fov)) {
      final double prev = this._fov;
      this._fov = fov;
      this._onChanged(events.ValueChangedEventArgs(this, 'fov', prev, this._fov));
    }
  }

  /// The sky box texture.
  TextureCube? get boxTexture => this._boxTxt;

  set boxTexture(TextureCube? boxTxt) {
    if (this._boxTxt != boxTxt) {
      this._boxTxt?.changed.remove(this._onChanged);
      final TextureCube? prev = this._boxTxt;
      this._boxTxt = boxTxt;
      this._boxTxt?.changed.add(this._onChanged);
      this._onChanged(events.ValueChangedEventArgs(this, 'boxTexture', prev, this._boxTxt));
    }
  }

  /// The sky box color scalar.
  Color3 get boxColor => this._boxClr;

  set boxColor(Color3 color) {
    if (this._boxClr != color) {
      final Color3 prev = this._boxClr;
      this._boxClr = color;
      this._onChanged(events.ValueChangedEventArgs(this, 'boxColor', prev, this._boxClr));
    }
  }

  /// Gets the vertex source code used for the shader used by this technique.
  String get vertexSourceCode => this._shader?.vertexSourceCode ?? '';

  /// Gets the fragment source code used for the shader used by this technique.
  String get fragmentSourceCode => this._shader?.fragmentSourceCode ?? '';

  /// Updates this technique for the given state.
  @override
  void update(RenderState state) {
    // Do Nothing
  }

  /// Renders this technique for the given state and entity.
  @override
  void render(RenderState state, Entity obj) {
    this._shader ??= shaders.Skybox.cached(state);

    if (obj.cacheNeedsUpdate) {
      obj.cache = obj.shapeBuilder?.build(WebGLBufferBuilder(state.gl), VertexType.Pos)
        ?..findAttribute(VertexType.Pos)?.attr = this._shader?.posAttr?.loc ?? 0;
    }

    final boxTxt = this._boxTxt;
    if (boxTxt == null) return;
    boxTxt.index = 1;
    boxTxt.bind(state);

    final double aspect = state.height.toDouble() / state.width.toDouble();
    this._shader
      ?..bind(state)
      ..fov = fov
      ..ratio = aspect
      ..boxTexture = boxTxt
      ..boxColor = this._boxClr
      ..viewMatrix = state.view.matrix.inverse();

    final _cache = obj.cache;
    if (_cache is BufferStore) {
      _cache
        ..bind(state)
        ..render(state)
        ..unbind(state);
    } else {
      obj.clearCache();
    }
    this._shader?.unbind(state);

    boxTxt.unbind(state);
  }
}

/// A technique for rendering entities with a solid color.
class SolidColor extends Technique {
  shaders.SolidColor? _shader;
  Color4 _clr;
  events.Event? _changed;

  /// Creates a new solid color technique with the given initial values.
  SolidColor({Color4? color})
      : this._shader = null,
        this._clr = color ?? Color4.white(),
        this._changed = null;

  /// Indicates that this technique has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this technique.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  /// The color to draw the shape with.
  Color4 get color => this._clr;

  set color(Color4 clr) {
    if (this._clr != clr) {
      final Color4 prev = this._clr;
      this._clr = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'color', prev, this._clr));
    }
  }

  /// Gets the vertex source code used for the shader used by this technique.
  String get vertexSourceCode => this._shader?.vertexSourceCode ?? '';

  /// Gets the fragment source code used for the shader used by this technique.
  String get fragmentSourceCode => this._shader?.fragmentSourceCode ?? '';

  /// Updates this technique for the given state.
  @override
  void update(RenderState state) {
    // Do Nothing
  }

  /// Renders this technique for the given state and entity.
  @override
  void render(RenderState state, Entity obj) {
    this._shader ??= shaders.SolidColor.cached(state);

    if (obj.cache is! BufferStore) obj.clearCache();
    if (obj.cacheNeedsUpdate) {
      obj.cache = obj.shapeBuilder?.build(WebGLBufferBuilder(state.gl), VertexType.Pos)
        ?..findAttribute(VertexType.Pos)?.attr = this._shader?.posAttr?.loc ?? 0;
    }

    this._shader
      ?..bind(state)
      ..color = this._clr
      ..projViewObjectMatrix = state.projectionViewObjectMatrix;

    (obj.cache as BufferStore?)!
      ..bind(state)
      ..render(state)
      ..unbind(state);

    this._shader?.unbind(state);
  }
}

/// A technique for rendering an entity.
abstract class Technique implements events.Changeable {
  /// Updates the technique for the given state .
  /// If this technique attached to multiple entities then the update
  /// is called for each entity prior to render. The update isn't
  /// called for every entity that render will be called on.
  void update(RenderState state);

  /// Renders the technique for the given state and entity.
  /// The shape cache for this technique may
  /// be updated or set during this call.
  void render(RenderState state, Entity obj);
}

/// A technique for a cover pass which draws several textures.
class TextureLayout extends Technique {
  shaders.TextureLayout? _shader;
  Color4 _backClr;
  final Collection<TextureLayoutEntry> _entries;
  int _lastCount;
  shaders.ColorBlendType _blend;
  shaders.ColorBlendType _lastBlend;
  events.Event? _changed;

  /// Creates a new sky box technique with the given initial values.
  TextureLayout({Color4? backColor, shaders.ColorBlendType blend = shaders.ColorBlendType.AlphaBlend})
      : this._shader = null,
        this._backClr = backColor ?? Color4.transparent(),
        this._entries = Collection<TextureLayoutEntry>(),
        this._lastCount = 0,
        this._blend = blend,
        this._lastBlend = shaders.ColorBlendType.AlphaBlend,
        this._changed = null {
    this._entries.setHandlers(onAddedHndl: _onEntityAdded, onRemovedHndl: _onEntityRemoved);
  }

  /// Indicates that this technique has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this technique.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  /// Handles when texture layout entities have been added.
  void _onEntityAdded(int index, Iterable<TextureLayoutEntry> added) {
    for (final TextureLayoutEntry entity in added) {
      entity.changed.add(this._onChanged);
    }
    this._onChanged();
  }

  /// Handles when texture layout entities have been removed.
  void _onEntityRemoved(int index, Iterable<TextureLayoutEntry> removed) {
    for (final TextureLayoutEntry entity in removed) {
      entity.changed.remove(this._onChanged);
    }
    this._onChanged();
  }

  /// The list of layout entries.
  Collection<TextureLayoutEntry> get entries => this._entries;

  /// The background color for the layout.
  Color4 get backColor => this._backClr;

  set backColor(Color4 clr) {
    if (this._backClr != clr) {
      final Color4 prev = this._backClr;
      this._backClr = clr;
      this._onChanged(events.ValueChangedEventArgs(this, 'backColor', prev, this._backClr));
    }
  }

  /// The type of blending to use on overlapping layout textures.
  shaders.ColorBlendType get blend => this._blend;

  set blend(shaders.ColorBlendType blend) {
    if (this._blend != blend) {
      final shaders.ColorBlendType prev = this._blend;
      this._blend = blend;
      this._onChanged(events.ValueChangedEventArgs(this, 'blend', prev, this._blend));
    }
  }

  /// Updates this technique for the given state.
  @override
  void update(RenderState state) {
    // Do Nothing
  }

  /// Calculates a limit for the textures for the shader from
  /// the current number of textures. This helps reduce and reuse
  /// shaders with similar number of attributes.
  int _lengthLimit(int count) {
    // ignore: parameter_assignments
    count = ((count + 3) ~/ 4) * 4;
    if (count <= 0) return 4;
    return count;
  }

  /// Checks if the texture is in the list and if not, sets it's index and adds it to the list.
  void _addToTextureList(List<Texture> textures, Texture? txt) {
    if (txt != null) {
      if (!textures.contains(txt)) {
        txt.index = textures.length;
        textures.add(txt);
      }
    }
  }

  /// Renders this technique for the given state and entity.
  @override
  void render(RenderState state, Entity obj) {
    final int newCount = this._lengthLimit(this._entries.length);
    if ((newCount != this._lastCount) || (this._blend != this._lastBlend)) {
      this._lastCount = newCount;
      this._lastBlend = this._blend;
      this._shader = null;
    }

    var shader = this._shader;
    if (shader == null) {
      this._shader = shader = shaders.TextureLayout.cached(newCount, this._blend, state);
    }

    if (obj.cacheNeedsUpdate) {
      obj.cache = obj.shapeBuilder?.build(WebGLBufferBuilder(state.gl), VertexType.Pos)
        ?..findAttribute(VertexType.Pos)?.attr = shader.posAttr?.loc ?? 0;
    }

    shader.bind(state);
    final List<Texture> textures = [];
    int count = 0;
    for (int i = 0; i < this._entries.length; ++i) {
      final TextureLayoutEntry entry = this._entries[i];
      final txt = entry.texture;
      if (txt != null) {
        this._addToTextureList(textures, entry.texture);
        shader.setTexture(count, txt);
        shader.setColorMatrix(count, entry.colorMatrix);
        shader.setSourceRect(count, entry.source);
        shader.setDestinationRect(count, entry.destination);
        shader.setFlip(count, entry.flip);
        ++count;
      }
    }
    shader.textureCount = count;
    shader.backgroundColor = this._backClr;

    for (int i = 0; i < textures.length; i++) {
      textures[i].bind(state);
    }

    final _cache = obj.cache;
    if (_cache is BufferStore) {
      _cache
        ..bind(state)
        ..render(state)
        ..unbind(state);
    } else {
      obj.clearCache();
    }
    shader.unbind(state);

    for (int i = 0; i < textures.length; i++) {
      textures[i].unbind(state);
    }
  }
}

/// An entry in the TextureLayout technique describing the layout of one texture.
class TextureLayoutEntry implements events.Changeable {
  Texture2D? _txt;
  Matrix4 _clrMat;
  Region2 _src;
  Region2 _dest;
  bool _flip;
  events.Event? _changed;

  /// Creates an entry for the texture layout technique.
  TextureLayoutEntry(
      {Texture2D? texture, Matrix4? colorMatrix, Region2? source, Region2? destination, bool flip = false})
      : this._txt = texture,
        this._clrMat = colorMatrix ?? Matrix4.identity,
        this._src = source ?? Region2.unit,
        this._dest = destination ?? Region2.unit,
        this._flip = flip,
        this._changed = null;

  /// Indicates that this entity has changed.
  @override
  events.Event get changed => this._changed ??= events.Event();

  /// Handles a change in this entity.
  void _onChanged([events.EventArgs? args]) => this._changed?.emit(args);

  /// The texture to draw for this entry.
  Texture2D? get texture => this._txt;

  set texture(Texture2D? txt) {
    if (this._txt != txt) {
      this._txt?.changed.remove(this._onChanged);
      final Texture2D? prev = this._txt;
      this._txt = txt;
      this._txt?.changed.add(this._onChanged);
      this._onChanged(events.ValueChangedEventArgs(this, 'texture', prev, this._txt));
    }
  }

  /// The color adjustment matrix.
  Matrix4 get colorMatrix => this._clrMat;

  set colorMatrix(Matrix4 mat) {
    if (this._clrMat != mat) {
      final Matrix4 prev = this._clrMat;
      this._clrMat = mat;
      this._onChanged(events.ValueChangedEventArgs(this, 'colorMatrix', prev, this._clrMat));
    }
  }

  /// The source region of the texture to render with.
  Region2 get source => this._src;

  set source(Region2 src) {
    if (this._src != src) {
      final Region2 prev = this._src;
      this._src = src;
      this._onChanged(events.ValueChangedEventArgs(this, 'source', prev, this._src));
    }
  }

  /// The destination to render the source region into.
  Region2 get destination => this._dest;

  set destination(Region2 dest) {
    if (this._dest != dest) {
      final Region2 prev = this._dest;
      this._dest = dest;
      this._onChanged(events.ValueChangedEventArgs(this, 'destination', prev, this._dest));
    }
  }

  /// Indicates if the image should be flipped or not.
  bool get flip => this._flip;

  set flip(bool flip) {
    if (this._flip != flip) {
      this._flip = flip;
      this._onChanged(events.ValueChangedEventArgs(this, 'flip', !flip, this._flip));
    }
  }
}
