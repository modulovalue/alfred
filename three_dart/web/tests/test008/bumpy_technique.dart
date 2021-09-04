part of three_dart.test.test008;

/// The bumpy test rendering technique.
class BumpyTechnique extends Technique {
  BumpyShader? _shader;
  Texture2D? _txt;
  double _offsetScalar;
  Event? _changed;

  /// Creates a new bumpy test technique technique.
  BumpyTechnique():
    this._shader = null,
    this._txt = null,
    this._offsetScalar = 1.0,
    this._changed = null;

  /// Emits an event when the technique being changed.
  @override
  Event get changed =>
    this._changed ??= Event();

  /// Handles the technique being changed.
  void _onChanged([EventArgs? args]) =>
    this._changed?.emit(args);

  /// The bumpy texture to render with.
  Texture2D? get bumpyTexture => this._txt;
  set bumpyTexture(Texture2D? txt) {
    if (this._txt != txt) {
      this._txt?.changed.remove(this._onChanged);
      final Texture2D? prev = this._txt;
      this._txt = txt;
      this._txt?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, "bumpyTexture", prev, this._txt));
    }
  }

  /// The offset scalar for the size of the normal vectors.
  double get offsetScalar => this._offsetScalar;
  set offsetScalar(double scalar) {
    if (!Comparer.equals(this._offsetScalar, scalar)) {
      final double prev = this._offsetScalar;
      this._offsetScalar = scalar;
      this._onChanged(ValueChangedEventArgs(this, "offsetScalar", prev, this._offsetScalar));
    }
  }

  /// Gets the vertex source code used for the shader used by this technique.
  String get vertexSourceCode => this._shader?.vertexSourceCode ?? '';

  /// Gets the fragment source code used for the shader used by this technique.
  String get fragmentSourceCode => this._shader?.fragmentSourceCode ?? '';

  /// Updates this technique for the given state.
  @override
  void update(three_dart.RenderState state) {
    // Do Nothing
  }

  /// Renders the given [obj] with the current texture for the given [state].
  @override
  void render(three_dart.RenderState state, three_dart.Entity obj) {
    var shader = this._shader;
    shader ??= this._shader = BumpyShader.cached(state);
    if (obj.cacheNeedsUpdate) {
      obj.cache = obj.shape?.build(WebGLBufferBuilder(state.gl),
        VertexType.Pos|VertexType.Norm|VertexType.Binm|
        VertexType.Txt2D|VertexType.Weight)
        ?..findAttribute(VertexType.Pos)?.attr = shader.posAttr?.loc ?? 0
        ..findAttribute(VertexType.Norm)?.attr = shader.normAttr?.loc ?? 1
        ..findAttribute(VertexType.Binm)?.attr = shader.binmAttr?.loc ?? 2
        ..findAttribute(VertexType.Txt2D)?.attr = shader.txtAttr?.loc ?? 3
        ..findAttribute(VertexType.Weight)?.attr = shader.weightAttr?.loc ?? 4;
    }
    final txt = this._txt;
    if (txt != null) {
      txt.index = 0;
      shader
        ..bind(state)
        ..bumpTexture = txt
        ..projectMatrix = state.projection.matrix
        ..viewMatrix = state.view.matrix
        ..objectMatrix = state.object.matrix
        ..offsetScalar = this._offsetScalar;
      txt.bind(state);
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
      txt.unbind(state);
    }
  }
}
