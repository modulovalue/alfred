part of three_dart.test.test008;

/// A shader for rendering and testing bumpy normals.
class BumpyShader extends Shader {

  /// The name for this shader.
  static const String defaultName = "Bumpy Debugging Shader";

  /// The vertex shader source code in glsl.
  static const String _vertexSource =
      "uniform mat4 objMat;                                     \n"+
      "uniform mat4 viewMat;                                    \n"+
      "uniform mat4 projMat;                                    \n"+
      "uniform sampler2D bumpTxt;                               \n"+
      "uniform float offsetScalar;                              \n"+
      "                                                         \n"+
      "attribute vec3 posAttr;                                  \n"+
      "attribute vec3 normAttr;                                 \n"+
      "attribute vec3 binmAttr;                                 \n"+
      "attribute vec2 txtAttr;                                  \n"+
      "attribute float weightAttr;                              \n"+
      "                                                         \n"+
      "varying vec3 color;                                      \n"+
      "                                                         \n"+
      "vec3 bumpyNormal(vec3 color)                             \n"+
      "{                                                        \n"+
      "   vec3 n = normalize(objMat*vec4(normAttr, 0.0)).xyz;   \n"+
      "   vec3 b = normalize(objMat*vec4(binmAttr, 0.0)).xyz;   \n"+
      "   vec3 c = cross(b, n);                                 \n"+
      "   b = cross(n, c);                                      \n"+
      "   mat3 mat = mat3( b.x,  b.y,  b.z,                     \n"+
      "                   -c.x, -c.y, -c.z,                     \n"+
      "                    n.x,  n.y,  n.z);                    \n"+
      "   return mat * normalize(2.0*color - 1.0);              \n"+
      "}                                                        \n"+
      "                                                         \n"+
      "void main()                                              \n"+
      "{                                                        \n"+
      "   color = texture2D(bumpTxt, txtAttr).rgb;              \n"+
      "   vec4 pnt = projMat*viewMat*objMat*vec4(posAttr, 1.0); \n"+
      "   if (weightAttr > 0.5)                                 \n"+
      "   {                                                     \n"+
      "     pnt += vec4(bumpyNormal(color)*offsetScalar, 0.0);  \n"+
      "   }                                                     \n"+
      "   gl_Position = pnt;                                    \n"+
      "}                                                        \n";

  /// The fragment shader source code in glsl.
  static const String _fragmentSource =
      "precision mediump float;            \n"+
      "                                    \n"+
      "varying vec3 color;                 \n"+
      "                                    \n"+
      "void main()                         \n"+
      "{                                   \n"+
      "   gl_FragColor = vec4(color, 1.0); \n"+
      "}                                   \n";

  Attribute? _posAttr;
  Attribute? _normAttr;
  Attribute? _binmAttr;
  Attribute? _txtAttr;
  Attribute? _weightAttr;

  UniformSampler2D? _bumpTxt;
  UniformMat4? _objMat;
  UniformMat4? _viewMat;
  UniformMat4? _projMat;
  Uniform1f? _offsetScalar;

  /// Compiles this shader for the given rendering context.
  BumpyShader(webgl.RenderingContext2 gl): super(gl, defaultName) {
    this.initialize(_vertexSource, _fragmentSource);
    this._posAttr      = this.attributes["posAttr"];
    this._normAttr     = this.attributes["normAttr"];
    this._binmAttr     = this.attributes["binmAttr"];
    this._txtAttr      = this.attributes["txtAttr"];
    this._weightAttr   = this.attributes["weightAttr"];
    this._bumpTxt      = this.uniforms["bumpTxt"] as UniformSampler2D?;
    this._objMat       = this.uniforms["objMat"] as UniformMat4?;
    this._viewMat      = this.uniforms["viewMat"] as UniformMat4?;
    this._projMat      = this.uniforms["projMat"] as UniformMat4?;
    this._offsetScalar = this.uniforms["offsetScalar"] as Uniform1f?;
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory BumpyShader.cached(three_dart.RenderState state) {
    BumpyShader? shader = state.shader(defaultName) as BumpyShader?;
    if (shader == null) {
      shader = BumpyShader(state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// The normal vertex shader attribute.
  Attribute? get normAttr => this._normAttr;

  /// The binormal vertex shader attribute.
  Attribute? get binmAttr => this._binmAttr;

  /// The texture vertex shader attribute.
  Attribute? get txtAttr => this._txtAttr;

  /// The weight vertex shader attribute.
  Attribute? get weightAttr => this._weightAttr;

  /// The normal distortion texture of the object.
  set bumpTexture(Texture2D? txt) {
    if (txt != null) {
      this._bumpTxt?.setTexture2D(txt);
    }
  }

  /// The object matrix.
  Matrix4 get objectMatrix => this._objMat?.getMatrix4() ?? Matrix4.identity;
  set objectMatrix(Matrix4 mat) => this._objMat?.setMatrix4(mat);

  /// The view matrix.
  Matrix4 get viewMatrix => this._viewMat?.getMatrix4() ?? Matrix4.identity;
  set viewMatrix(Matrix4 mat) => this._viewMat?.setMatrix4(mat);

  /// The projection matrix.
  Matrix4 get projectMatrix => this._projMat?.getMatrix4() ?? Matrix4.identity;
  set projectMatrix(Matrix4 mat) => this._projMat?.setMatrix4(mat);

  /// The offset scalar for the length of the line to create.
  double get offsetScalar => this._offsetScalar?.getValue() ?? 1.0;
  set offsetScalar(double offset) => this._offsetScalar?.setValue(offset);
}
