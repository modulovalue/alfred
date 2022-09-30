// A set of WebGL vertex and fragment shaders used by
// techniques to perform specific graphical effects.
import 'dart:typed_data' as typed;
import 'dart:web_gl' as webgl;

import 'core.dart';
import 'data.dart';
import 'math.dart';
import 'textures.dart';

/// The type of blending of multiple colors together.
enum ColorBlendType {
  /// Overwrite means that the last color is shown.
  Overwrite,

  /// The colors are added up.
  Additive,

  /// The colors are added up then divided by the number of added colors.
  Average,

  /// The current alpha is used to blend with previous color.
  AlphaBlend
}

/// Gets the string to indicate a color blend type used for the name of the material light.
String stringForColorBlendType(ColorBlendType type) => type.index.toString();

/// Inserts a number for each line in the given [text].
String numberLines(String text) {
  final List<String> lines = text.split("\n");
  for (int i = 0; i < lines.length; i++) {
    lines[i] = "${i + 1}  ${lines[i]}";
  }
  return lines.join("\n");
}

/// Gets the uppercase of just the first character of the given string.
String toTitleCase(String name) => name[0].toUpperCase() + name.substring(1);

/// The vertex attribute of a shader.
class Attribute {
  /// The rendering context for the shader.
  final webgl.RenderingContext2 _gl;

  /// The name of the attribute in the shader code.
  final String name;

  /// The attribute's code location in the shader.
  final int loc;

  /// Creates a new shader attribute.
  Attribute._(this._gl, this.name, this.loc);

  /// Enables this attribute in the rendering context.
  void enable() => this._gl.enableVertexAttribArray(this.loc);

  /// Disables this attribute from the rendering context.
  void disable() => this._gl.disableVertexAttribArray(this.loc);
}

/// The container for several shader attributes.
class AttributeContainer {
  /// The attributes being contained.
  final List<Attribute> _attrs;

  /// Creates a new attribute container.
  /// [_attrs] is the complete list of attributes for a single shader.
  AttributeContainer._(this._attrs);

  /// The number of attributes in the container.
  int get count => this._attrs.length;

  /// Gets the attribute at [i].
  Attribute? at(int i) => this._attrs[i];

  /// Gets the attribute with the given [name].
  Attribute? operator [](String name) {
    for (final Attribute attr in this._attrs) {
      if (attr.name == name) return attr;
    }
    return null;
  }

  /// Gets the index of an attribute for the given [name].
  int indexOf(String name) {
    for (int i = this._attrs.length - 1; i >= 0; --i) {
      if (this._attrs[i].name == name) return i;
    }
    return -1;
  }

  /// Indicates if an attribute for the given [name] exists.
  bool contains(String name) {
    for (final Attribute attr in this._attrs) {
      if (attr.name == name) return true;
    }
    return false;
  }

  /// Enables all the shader attributes.
  void enableAll() {
    for (final Attribute attr in this._attrs) {
      attr.enable();
    }
  }

  /// Disables all the shader attributes.
  void disableAll() {
    for (final Attribute attr in this._attrs) {
      attr.disable();
    }
  }
}

/// A description of what kind of source the color comes from.
class ColorSourceType {
  /// Indicates that the source color has a solid value such as a float or RGB color.
  final bool hasSolid;

  /// Indicates that the source color comes from a 2D texture.
  final bool hasTxt2D;

  /// Indicates that the source color comes from a cube texture.
  final bool hasTxtCube;

  /// Creates a new color source with none as the source.
  factory ColorSourceType() => ColorSourceType._(false, false, false);

  /// Creates a new color source with the given values.
  ColorSourceType._(this.hasSolid, this.hasTxt2D, this.hasTxtCube);

  /// Indicates that there is no color source being used.
  bool get hasNone => !hasAny;

  /// Indicates that there is some kind of color source being used.
  bool get hasAny => this.hasSolid || this.hasTxt2D || this.hasTxtCube;

  /// Creates a new color source by enabling/disabling the solid color.
  ColorSourceType enableSolid(bool enable) => ColorSourceType._(enable, this.hasTxt2D, this.hasTxtCube);

  /// Creates a new color source by enabling/disabling the 3D texture color.
  ColorSourceType enableTxt2D(bool enable) =>
      ColorSourceType._(this.hasSolid, enable, enable ? false : this.hasTxtCube);

  /// Creates a new color source by enabling/disabling the cube texture color.
  ColorSourceType enableTxtCube(bool enable) =>
      ColorSourceType._(this.hasSolid, enable ? false : this.hasTxt2D, enable);

  /// Gets a integer value which represents this source color.
  int get value => (this.hasSolid ? 1 : 0) | (this.hasTxt2D ? 2 : 0) | (this.hasTxtCube ? 4 : 0);

  /// Gets a string for the source color.
  @override
  String toString() => '$value';

  /// Checks if this source color is equal to the given other type.
  @override
  bool operator ==(dynamic other) {
    if (other is! ColorSourceType) return false;
    return (this.hasSolid == other.hasSolid) &&
        (this.hasTxt2D == other.hasTxt2D) &&
        (this.hasTxtCube == other.hasTxtCube);
  }

  @override
  int get hashCode => hasSolid.hashCode ^ hasTxt2D.hashCode ^ hasTxtCube.hashCode;
}

/// A shader for very basic depth rendering.
class Depth extends Shader {
  /// The vertex shader source code in glsl.
  static String _vertexSource() {
    final StringBuffer buf = StringBuffer();
    buf.writeln('uniform mat4 viewObjMat;');
    buf.writeln('uniform mat4 projMat;');
    buf.writeln('');
    buf.writeln('attribute vec3 posAttr;');
    buf.writeln('');
    buf.writeln('varying vec3 loc;');
    buf.writeln('');
    buf.writeln('void main()');
    buf.writeln('{');
    buf.writeln('  vec4 pos = viewObjMat*vec4(posAttr, 1.0);');
    buf.writeln('  loc = pos.xyz;');
    buf.writeln('  gl_Position = projMat*pos;');
    buf.writeln('}');
    return buf.toString();
  }

  /// The fragment shader source code in glsl.
  static String _fragmentSource(bool grey, bool focus) {
    final StringBuffer buf = StringBuffer();
    buf.writeln('precision mediump float;');
    buf.writeln('');
    buf.writeln('uniform float width;');
    buf.writeln('uniform float stop;');
    buf.writeln('');
    buf.writeln('varying vec3 loc;');
    buf.writeln('');
    buf.writeln('void main()');
    buf.writeln('{');
    if (focus) {
      buf.writeln('  float dist = length(loc.xyz);');
    } else {
      buf.writeln('  float dist = loc.z;');
    }
    buf.writeln('  float depth = (dist - stop) / width;');
    buf.writeln('  float f = clamp(depth, 0.0, 1.0);');
    if (grey) {
      buf.writeln('   vec3 clr = vec3(f, f, f);');
    } else {
      buf.writeln('  f = f * 256.0;');
      buf.writeln('  float r = floor(f);');
      buf.writeln('  f = (f - r) * 256.0;');
      buf.writeln('  float g = floor(f);');
      buf.writeln('  f = (f - g) * 256.0;');
      buf.writeln('  float b = floor(f);');
      buf.writeln('  vec3 clr = vec3(r, g, b) / 256.0;');
    }
    buf.writeln('  gl_FragColor = vec4(clr, 1.0);');
    buf.writeln('}');
    return buf.toString();
  }

  Attribute? _posAttr;
  Uniform1f? _width;
  Uniform1f? _stop;
  UniformMat4? _viewObjMat;
  UniformMat4? _projMat;

  /// Gets the name for the depth shader.
  static String _getName(bool grey, bool point) => (grey ? 'High' : 'Grey') + (point ? 'Point' : 'View') + 'Depth';

  /// Compiles this shader for the given rendering context.
  Depth(bool grey, bool focus, webgl.RenderingContext2 gl) : super(gl, _getName(grey, focus)) {
    this.initialize(_vertexSource(), _fragmentSource(grey, focus));
    this._posAttr = this.attributes['posAttr'];
    this._width = this.uniforms['width'] as Uniform1f?;
    this._stop = this.uniforms['stop'] as Uniform1f?;
    this._viewObjMat = this.uniforms['viewObjMat'] as UniformMat4?;
    this._projMat = this.uniforms['projMat'] as UniformMat4?;
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory Depth.cached(bool grey, bool focus, RenderState state) {
    final String name = _getName(grey, focus);
    Depth? shader = state.shader(name) as Depth?;
    if (shader == null) {
      shader = Depth(grey, focus, state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// The width of the depth values which map between 0 and 1.
  double get width => this._width?.getValue() ?? 0.0;

  set width(double value) => this._width?.setValue(value);

  /// The value when the depth stops.
  double get stop => this._stop?.getValue() ?? 0.0;

  set stop(double value) => this._stop?.setValue(value);

  /// The view matrix times the object matrix.
  Matrix4 get viewObjectMatrix => this._viewObjMat?.getMatrix4() ?? Matrix4.identity;

  set viewObjectMatrix(Matrix4 mat) => this._viewObjMat?.setMatrix4(mat);

  /// The projection matrix.
  Matrix4 get projectMatrix => this._projMat?.getMatrix4() ?? Matrix4.identity;

  set projectMatrix(Matrix4 mat) => this._projMat?.setMatrix4(mat);
}

/// A shader for cover pass distortion rendering.
class Distort extends Shader {
  /// The name for this shader.
  static const String defaultName = "Distort";

  /// The vertex shader source code in glsl.
  static const String _vertexSource = "uniform mat4 projViewObjMat;                             \n" +
      "uniform mat3 colorTxt2DMat;                              \n" +
      "uniform mat3 bumpTxt2DMat;                               \n" +
      "                                                         \n" +
      "attribute vec3 posAttr;                                  \n" +
      "attribute vec2 txt2DAttr;                                \n" +
      "                                                         \n" +
      "varying vec2 colorTxt2D;                                 \n" +
      "varying vec2 bumpTxt2D;                                  \n" +
      "                                                         \n" +
      "void main()                                              \n" +
      "{                                                        \n" +
      "   vec3 txt2D = vec3(txt2DAttr.x, 1.0-txt2DAttr.y, 1.0); \n" +
      "   colorTxt2D = (colorTxt2DMat * txt2D).xy;              \n" +
      "   bumpTxt2D = (bumpTxt2DMat * vec3(txt2DAttr, 1.0)).xy; \n" +
      "   gl_Position = projViewObjMat * vec4(posAttr, 1.0);    \n" +
      "}                                                        \n";

  /// The fragment shader source code in glsl.
  static const String _fragmentSource = "precision mediump float;                           \n" +
      "                                                   \n" +
      "uniform sampler2D colorTxt;                        \n" +
      "uniform sampler2D bumpTxt;                         \n" +
      "uniform mat4 bumpMat;                              \n" +
      "                                                   \n" +
      "varying vec2 colorTxt2D;                           \n" +
      "varying vec2 bumpTxt2D;                            \n" +
      "                                                   \n" +
      "vec2 offset()                                      \n" +
      "{                                                  \n" +
      "   vec3 txt2D = texture2D(bumpTxt, bumpTxt2D).rgb; \n" +
      "   txt2D = normalize(txt2D*2.0 - 1.0);             \n" +
      "   return (bumpMat * vec4(txt2D, 1.0)).xy;         \n" +
      "}                                                  \n" +
      "                                                   \n" +
      "void main()                                        \n" +
      "{                                                  \n" +
      "   vec2 txt2D = colorTxt2D + offset();             \n" +
      "   gl_FragColor = texture2D(colorTxt, txt2D);      \n" +
      "}                                                  \n";

  Attribute? _posAttr;
  Attribute? _txtAttr;
  UniformMat4? _projViewObjMat;
  UniformMat3? _colorTxt2DMat;
  UniformMat3? _bumpTxt2DMat;
  UniformSampler2D? _colorTxt;
  UniformSampler2D? _bumpTxt;
  UniformMat4? _bumpMat;

  /// Compiles this shader for the given rendering context.
  Distort(webgl.RenderingContext2 gl) : super(gl, defaultName) {
    this.initialize(_vertexSource, _fragmentSource);
    this._posAttr = this.attributes["posAttr"];
    this._txtAttr = this.attributes["txt2DAttr"];
    this._projViewObjMat = this.uniforms.required("projViewObjMat") as UniformMat4;
    this._colorTxt2DMat = this.uniforms.required("colorTxt2DMat") as UniformMat3;
    this._bumpTxt2DMat = this.uniforms.required("bumpTxt2DMat") as UniformMat3;
    this._colorTxt = this.uniforms.required("colorTxt") as UniformSampler2D;
    this._bumpTxt = this.uniforms.required("bumpTxt") as UniformSampler2D;
    this._bumpMat = this.uniforms.required("bumpMat") as UniformMat4;
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory Distort.cached(RenderState state) {
    Distort? shader = state.shader(defaultName) as Distort?;
    if (shader == null) {
      shader = Distort(state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// Sets the texture 2D and null texture indicator for the shader.
  void _setTexture2D(UniformSampler2D? txt2D, Texture2D? txt) {
    if ((txt != null) && txt.loaded) txt2D?.setTexture2D(txt);
  }

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// The texture vertex shader attribute.
  Attribute? get txtAttr => this._txtAttr;

  /// The matrix for modifying the project view object matrix.
  Matrix4 get projectViewObjectMatrix => this._projViewObjMat?.getMatrix4() ?? Matrix4.identity;

  set projectViewObjectMatrix(Matrix4 mat) => this._projViewObjMat?.setMatrix4(mat);

  /// The matrix for modifying the color texture coordinates.
  Matrix3 get colorTextureMatrix => this._colorTxt2DMat?.getMatrix3() ?? Matrix3.identity;

  set colorTextureMatrix(Matrix3 mat) => this._colorTxt2DMat?.setMatrix3(mat);

  /// The matrix for modifying the bump texture coordinates.
  Matrix3 get bumpTextureMatrix => this._bumpTxt2DMat?.getMatrix3() ?? Matrix3.identity;

  set bumpTextureMatrix(Matrix3 mat) => this._bumpTxt2DMat?.setMatrix3(mat);

  /// The color texture to cover with.
  set colorTexture(Texture2D? txt) => this._setTexture2D(this._colorTxt, txt);

  /// The bump distortion texture to cover with.
  set bumpTexture(Texture2D? txt) => this._setTexture2D(this._bumpTxt, txt);

  /// The matrix for modifying the bump normals.
  Matrix4 get bumpMatrix => this._bumpMat?.getMatrix4() ?? Matrix4.identity;

  set bumpMatrix(Matrix4 mat) => this._bumpMat?.setMatrix4(mat);
}

/// A shader for cover pass Gaussian blurring rendering.
class GaussianBlur extends Shader {
  GaussianBlurConfig _cfg;

  Attribute? _posAttr;
  Attribute? _txtAttr;

  UniformMat4? _projViewObjMat;
  UniformMat3? _txt2DMat;
  Uniform4f? _blurAdj;
  Uniform2f? _blurScale;

  UniformSampler2D? _colorTxt;
  UniformSampler2D? _blurTxt;
  Uniform1f? _blurValue;

  /// Compiles this shader for the given rendering context.
  GaussianBlur(this._cfg, webgl.RenderingContext2 gl) : super(gl, _cfg.name) {
    final String vertexSource = this._cfg.createVertexSource();
    final String fragmentSource = this._cfg.createFragmentSource();

    this.initialize(vertexSource, fragmentSource);
    this._posAttr = this.attributes["posAttr"];
    this._txtAttr = this.attributes["txtAttr"];
    this._projViewObjMat = this.uniforms["projViewObjMat"] as UniformMat4?;
    this._txt2DMat = this.uniforms["txt2DMat"] as UniformMat3?;
    this._colorTxt = this.uniforms["colorTxt"] as UniformSampler2D?;
    this._blurScale = this.uniforms["blurScale"] as Uniform2f?;

    if (this._cfg.blurTxt) {
      this._blurTxt = this.uniforms["blurTxt"] as UniformSampler2D?;
      this._blurAdj = this.uniforms["blurAdj"] as Uniform4f?;
    } else {
      this._blurValue = this.uniforms["blurValue"] as Uniform1f?;
    }
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory GaussianBlur.cached(GaussianBlurConfig cfg, RenderState state) {
    GaussianBlur? shader = state.shader(cfg.name) as GaussianBlur?;
    if (shader == null) {
      shader = GaussianBlur(cfg, state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// Sets the texture 2D and null texture indicator for the shader.
  void _setTexture2D(UniformSampler2D? txt2D, Texture2D? txt) {
    if ((txt != null) && txt.loaded) txt2D?.setTexture2D(txt);
  }

  /// The configuration the shader is built for.
  GaussianBlurConfig get configuration => this._cfg;

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// The texture vertex shader attribute.
  Attribute? get txtAttr => this._txtAttr;

  /// The width of the target in pixels.
  Matrix4 get projectViewObjectMatrix => this._projViewObjMat?.getMatrix4() ?? Matrix4.identity;

  set projectViewObjectMatrix(Matrix4 mat) => this._projViewObjMat?.setMatrix4(mat);

  /// The width of the target in pixels.
  Matrix3 get textureMatrix => this._txt2DMat?.getMatrix3() ?? Matrix3.identity;

  set textureMatrix(Matrix3 mat) => this._txt2DMat?.setMatrix3(mat);

  /// The color adjustment to apply to the blur texture colors to get the blur value with a texture.
  Vector4 get blurAdjust => this._blurAdj?.getVector4() ?? Vector4.zero;

  set blurAdjust(Vector4 vec) => this._blurAdj?.setVector4(vec);

  /// The direction of the blur divided by the textures width and height.
  Vector2 get blurScalar => this._blurScale?.getVector2() ?? Vector2.zero;

  set blurScalar(Vector2 vec) => this._blurScale?.setVector2(vec);

  /// The color texture to cover with.
  set colorTexture(Texture2D? txt) => this._setTexture2D(this._colorTxt, txt);

  /// The blur texture to cover with.
  set blurTexture(Texture2D? txt) => this._setTexture2D(this._blurTxt, txt);

  /// The blur value to use when not using a texture.
  double get blurValue => this._blurValue?.getValue() ?? 0.0;

  set blurValue(double value) => this._blurValue?.setValue(value);
}

/// The shader configuration for a gaussian blur.
class GaussianBlurConfig {
  /// Indicates blur source type is a texture instead of a single solid value.
  final bool blurTxt;

  /// The name of this shader configuration.
  final String name;

  /// Creates a new gaussian blur configuration.
  /// The configuration for the gaussian blur shader.
  factory GaussianBlurConfig(bool blurTxt) {
    final StringBuffer buf = StringBuffer();
    buf.write("GaussianBlur_");
    buf.write(blurTxt ? "1" : "0");
    final String name = buf.toString();
    return GaussianBlurConfig._(blurTxt, name);
  }

  /// Creates a new gaussian blur configuration with all final values
  /// calculated by the other GaussianBlurConfig constructor.
  GaussianBlurConfig._(this.blurTxt, this.name);

  /// Creates the vertex source code for the gaussian blur shader for the given configurations.
  String createVertexSource() {
    final StringBuffer buf = StringBuffer();
    buf.writeln("uniform mat4 projViewObjMat;");
    buf.writeln("uniform mat3 txt2DMat;");
    buf.writeln("");
    buf.writeln("attribute vec3 posAttr;");
    buf.writeln("attribute vec2 txtAttr;");
    buf.writeln("");
    buf.writeln("varying vec2 txt2D;");
    buf.writeln("");
    buf.writeln("void main()");
    buf.writeln("{");
    buf.writeln("  txt2D = (txt2DMat*vec3(txtAttr.x, 1.0-txtAttr.y, 1.0)).xy;");
    buf.writeln("  gl_Position = projViewObjMat*vec4(posAttr, 1.0);");
    buf.writeln("}");
    return buf.toString();
  }

  /// Adds a blur method to the given buffer with the given data.
  void _addBlurMethod(StringBuffer buf, int blurSize, List<double> offsets, List<double> weights) {
    int count = offsets.length;
    final bool hasCenter = Comparer.equals(offsets[0], 0.0000);
    double centerWeight = 0.0;
    if (hasCenter) {
      centerWeight = weights[0];
      // ignore: parameter_assignments
      weights = weights.sublist(1);
      // ignore: parameter_assignments
      offsets = offsets.sublist(1);
      count--;
    }

    buf.writeln("vec4 blur${blurSize}()");
    buf.writeln("{");
    if (hasCenter) {
      buf.writeln("  vec4 color = texture2D(colorTxt, txt2D)*$centerWeight;");
    } else {
      buf.writeln("  vec4 color = vec4(0.0);");
    }
    buf.writeln("  vec2 offset;");
    for (int i = 0; i < count; ++i) {
      buf.writeln("  offset = blurScale * ${offsets[i]};");
      buf.writeln("  color += texture2D(colorTxt, txt2D + offset) * ${weights[i]};");
      buf.writeln("  color += texture2D(colorTxt, txt2D - offset) * ${weights[i]};");
    }
    buf.writeln("  return color; ");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Creates the fragment source code for the gaussian blur shader for the given configurations.
  ///
  /// This blur method is based off of Daniel Rákos, "Efficient Gaussian blur with linear sampling",
  /// http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
  String createFragmentSource() {
    final StringBuffer buf = StringBuffer();
    buf.writeln("precision mediump float;");
    buf.writeln("");
    buf.writeln("uniform sampler2D colorTxt;");
    if (this.blurTxt) {
      buf.writeln("uniform sampler2D blurTxt;");
      buf.writeln("uniform vec4 blurAdj;");
    } else {
      buf.writeln("uniform float blurValue;");
    }
    buf.writeln("uniform vec2 blurScale;");
    buf.writeln("");
    buf.writeln("varying vec2 txt2D;");
    buf.writeln("");

    _addBlurMethod(buf, 3, [0.75000], [0.50000]);
    _addBlurMethod(buf, 6, [0.42857, 2.14286], [0.41667, 0.08333]);
    _addBlurMethod(buf, 9, [0.00000, 1.80000], [0.51220, 0.24390]);
    _addBlurMethod(buf, 12, [0.00000, 1.38462, 3.23077], [0.22703, 0.31622, 0.07027]);
    _addBlurMethod(buf, 15, [0.93750, 2.81250], [0.36184, 0.13816]);
    _addBlurMethod(buf, 18, [0.47368, 2.36842, 4.26316], [0.29916, 0.16318, 0.03766]);

    buf.writeln("void main()");
    buf.writeln("{");
    if (this.blurTxt) buf.writeln("   float blurValue = dot(texture2D(blurTxt, txt2D), blurAdj);");
    buf.writeln("   float blurOffset = abs(blurValue);");
    buf.writeln("");

    buf.writeln("   if     (blurOffset < 0.15) gl_FragColor = texture2D(colorTxt, txt2D);");
    buf.writeln("   else if(blurOffset < 0.3)  gl_FragColor = blur3();");
    buf.writeln("   else if(blurOffset < 0.45) gl_FragColor = blur6();");
    buf.writeln("   else if(blurOffset < 0.6)  gl_FragColor = blur9();");
    buf.writeln("   else if(blurOffset < 0.75) gl_FragColor = blur12();");
    buf.writeln("   else if(blurOffset < 0.9)  gl_FragColor = blur15();");
    buf.writeln("   else                       gl_FragColor = blur18();");
    buf.writeln("}");
    return buf.toString();
  }

  /// Gets the name for the configuration.
  @override
  String toString() => this.name;
}

/// A shader designed for inspecting shapes.
class Inspection extends Shader {
  /// The name for this shader.
  static const String defaultName = "Inspection";

  /// The vertex shader source code in glsl.
  static const String _vertexSource = "uniform mat4 viewMat;                                         \n" +
      "uniform mat4 viewObjMatrix;                                   \n" +
      "uniform mat4 projViewObjMatrix;                               \n" +
      "uniform vec3 lightVec;                                        \n" +
      "uniform float weightScalar;                                   \n" +
      "                                                              \n" +
      "attribute vec3 posAttr;                                       \n" +
      "attribute vec3 normAttr;                                      \n" +
      "attribute vec4 clrAttr;                                       \n" +
      "attribute vec3 binmAttr;                                      \n" +
      "                                                              \n" +
      "varying vec3 normal;                                          \n" +
      "varying vec4 color;                                           \n" +
      "varying vec3 litVec;                                          \n" +
      "varying vec3 camPos;                                          \n" +
      "                                                              \n" +
      "void main()                                                   \n" +
      "{                                                             \n" +
      "   gl_PointSize = 6.0;                                        \n" +
      "   color = clrAttr;                                           \n" +
      "   normal = normalize(viewObjMatrix*vec4(normAttr, 0.0)).xyz; \n" +
      "   litVec = normalize((viewMat*vec4(-lightVec, 0.0)).xyz);    \n" +
      "   vec3 pos = posAttr + binmAttr*weightScalar;                \n" +
      "   gl_Position = projViewObjMatrix*vec4(pos, 1.0);            \n" +
      "}                                                             \n";

  /// The fragment shader source code in glsl.
  static const String _fragmentSource = "precision mediump float;                        \n" +
      "                                                \n" +
      "uniform vec4 ambientClr;                        \n" +
      "uniform vec4 diffuseClr;                        \n" +
      "                                                \n" +
      "varying vec3 normal;                            \n" +
      "varying vec4 color;                             \n" +
      "varying vec3 litVec;                            \n" +
      "                                                \n" +
      "void main()                                     \n" +
      "{                                               \n" +
      "   vec3 norm = normalize(normal);               \n" +
      "   float scalar = dot(norm, litVec);            \n" +
      "   vec4 diffuse = diffuseClr*max(scalar, 0.0);  \n" +
      "   gl_FragColor = color*(ambientClr + diffuse); \n" +
      "}                                               \n";

  Attribute? _posAttr;
  Attribute? _normAttr;
  Attribute? _clrAttr;
  Attribute? _binmAttr;

  Uniform3f? _lightVec;
  Uniform4f? _ambientClr;
  Uniform4f? _diffuseClr;
  Uniform1f? _weightScalar;
  UniformMat4? _viewMat;
  UniformMat4? _viewObjMatrix;
  UniformMat4? _projViewObjMatrix;

  /// Compiles this shader for the given rendering context.
  Inspection(webgl.RenderingContext2 gl) : super(gl, defaultName) {
    this.initialize(_vertexSource, _fragmentSource);
    this._posAttr = this.attributes["posAttr"];
    this._normAttr = this.attributes["normAttr"];
    this._clrAttr = this.attributes["clrAttr"];
    this._binmAttr = this.attributes["binmAttr"];
    this._lightVec = this.uniforms["lightVec"] as Uniform3f?;
    this._ambientClr = this.uniforms["ambientClr"] as Uniform4f?;
    this._diffuseClr = this.uniforms["diffuseClr"] as Uniform4f?;
    this._weightScalar = this.uniforms["weightScalar"] as Uniform1f?;
    this._viewMat = this.uniforms["viewMat"] as UniformMat4?;
    this._viewObjMatrix = this.uniforms["viewObjMatrix"] as UniformMat4?;
    this._projViewObjMatrix = this.uniforms["projViewObjMatrix"] as UniformMat4?;
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory Inspection.cached(RenderState state) {
    Inspection? shader = state.shader(defaultName) as Inspection?;
    if (shader == null) {
      shader = Inspection(state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// The normal vertex shader attribute.
  Attribute? get normAttr => this._normAttr;

  /// The color vertex shader attribute.
  Attribute? get clrAttr => this._clrAttr;

  /// The binormal vertex shader attribute.
  Attribute? get binmAttr => this._binmAttr;

  /// The direction of the light on to the shape.
  Vector3 get lightVector => this._lightVec?.getVector3() ?? Vector3.zero;

  set lightVector(Vector3 vec) => this._lightVec?.setVector3(vec);

  /// The ambient color of the shape.
  Color4 get ambientColor => this._ambientClr?.getColor4() ?? Color4.white();

  set ambientColor(Color4 clr) => this._ambientClr?.setColor4(clr);

  /// The diffuse color of the shape.
  Color4 get diffuseColor => this._diffuseClr?.getColor4() ?? Color4.white();

  set diffuseColor(Color4 clr) => this._diffuseClr?.setColor4(clr);

  /// Sets both the ambient color and diffuse color of the shape.
  void setColors(Color4 ambientClr, Color4 diffuseClr) {
    this._ambientClr?.setColor4(ambientClr);
    this._diffuseClr?.setColor4(diffuseClr);
  }

  /// The scalar of the weighting for the shape.
  double get weightScalar => this._weightScalar?.getValue() ?? 0.0;

  set weightScalar(double scalar) => this._weightScalar?.setValue(scalar);

  /// The view matrix.
  Matrix4 get viewMatrix => this._viewMat?.getMatrix4() ?? Matrix4.identity;

  set viewMatrix(Matrix4 mat) => this._viewMat?.setMatrix4(mat);

  /// The view object matrix.
  Matrix4 get viewObjectMatrix => this._viewObjMatrix?.getMatrix4() ?? Matrix4.identity;

  set viewObjectMatrix(Matrix4 mat) => this._viewObjMatrix?.setMatrix4(mat);

  /// The projection view object matrix.
  Matrix4 get projectViewObjectMatrix => this._projViewObjMatrix?.getMatrix4() ?? Matrix4.identity;

  set projectViewObjectMatrix(Matrix4 mat) => this._projViewObjMatrix?.setMatrix4(mat);
}

/// A shader for rendering solid color light.
class MaterialLight extends Shader {
  MaterialLightConfig _cfg;

  Attribute? _posAttr;
  Attribute? _binmAttr;
  Attribute? _normAttr;
  Attribute? _txt2DAttr;
  Attribute? _txtCubeAttr;
  Attribute? _bendAttr;

  UniformMat4? _objMat;
  UniformMat4? _viewObjMat;
  UniformMat4? _viewMat;
  UniformMat4? _projViewObjMat;
  UniformMat4? _projViewMat;
  UniformMat4? _invViewMat;
  UniformMat3? _txt2DMat;
  UniformMat4? _txtCubeMat;
  UniformMat4? _colorMat;

  Uniform1i? _bendMatCount;
  List<UniformMat4?> _bendMatrices = [];

  Uniform3f? _emissionClr;
  UniformSampler2D? _emission2D;
  UniformSamplerCube? _emissionCube;

  Uniform3f? _ambientClr;
  UniformSampler2D? _ambient2D;
  UniformSamplerCube? _ambientCube;

  Uniform3f? _diffuseClr;
  UniformSampler2D? _diffuse2D;
  UniformSamplerCube? _diffuseCube;

  Uniform3f? _invDiffuseClr;
  UniformSampler2D? _invDiffuse2D;
  UniformSamplerCube? _invDiffuseCube;

  Uniform3f? _specularClr;
  UniformSampler2D? _specular2D;
  UniformSamplerCube? _specularCube;
  Uniform1f? _shininess;

  UniformSampler2D? _bump2D;
  UniformSamplerCube? _bumpCube;

  UniformSamplerCube? _envSampler;

  Uniform3f? _reflectClr;
  UniformSampler2D? _reflect2D;
  UniformSamplerCube? _reflectCube;

  Uniform1f? _refraction;
  Uniform3f? _refractClr;
  UniformSampler2D? _refract2D;
  UniformSamplerCube? _refractCube;

  Uniform1f? _alpha;
  UniformSampler2D? _alpha2D;
  UniformSamplerCube? _alphaCube;

  Map<int, Uniform1i?> _barLightCounts = {};
  Map<int, List<UniformBarLight>> _barLights = {};

  Map<int, Uniform1i?> _dirLightCounts = {};
  Map<int, List<UniformDirectionalLight>> _dirLights = {};

  Map<int, Uniform1i?> _pointLightCounts = {};
  Map<int, List<UniformPointLight>> _pointLights = {};

  Map<int, Uniform1i?> _spotLightCounts = {};
  Map<int, List<UniformSpotLight>> _spotLights = {};

  Uniform4f? _fogClr;
  Uniform1f? _fogStop;
  Uniform1f? _fogWidth;

  /// Compiles this shader for the given rendering context.
  MaterialLight(this._cfg, webgl.RenderingContext2 gl) : super(gl, _cfg.name) {
    final String vertexSource = this._cfg.createVertexSource();
    final String fragmentSource = this._cfg.createFragmentSource();
    // print(this._cfg.toString());
    // print(numberLines(vertexSource));
    // print(numberLines(fragmentSource));
    this.initialize(vertexSource, fragmentSource);
    this._posAttr = this.attributes["posAttr"];
    this._normAttr = this.attributes["normAttr"];
    this._binmAttr = this.attributes["binmAttr"];
    this._txt2DAttr = this.attributes["txt2DAttr"];
    this._txtCubeAttr = this.attributes["txtCubeAttr"];
    this._bendAttr = this.attributes["bendAttr"];
    // print(numberLines(this.uniforms.toString()));
    // print(this._cfg.vertexType);
    if (this._cfg.invViewMat) this._invViewMat = this.uniforms.required("invViewMat") as UniformMat4;
    if (this._cfg.objMat) this._objMat = this.uniforms.required("objMat") as UniformMat4;
    if (this._cfg.viewObjMat) this._viewObjMat = this.uniforms.required("viewObjMat") as UniformMat4;
    if (this._cfg.projViewObjMat) this._projViewObjMat = this.uniforms.required("projViewObjMat") as UniformMat4;
    if (this._cfg.viewMat) this._viewMat = this.uniforms.required("viewMat") as UniformMat4;
    if (this._cfg.projViewMat) this._projViewMat = this.uniforms.required("projViewMat") as UniformMat4;
    if (this._cfg.txt2DMat) this._txt2DMat = this.uniforms.required("txt2DMat") as UniformMat3;
    if (this._cfg.txtCubeMat) this._txtCubeMat = this.uniforms.required("txtCubeMat") as UniformMat4;
    if (this._cfg.colorMat) this._colorMat = this.uniforms.required("colorMat") as UniformMat4;
    this._bendMatrices = [];
    if (this._cfg.bendMats > 0) {
      this._bendMatCount = this.uniforms.required("bendMatCount") as Uniform1i;
      for (int i = 0; i < this._cfg.bendMats; ++i) {
        this._bendMatrices.add(this.uniforms.required("bendValues[$i].mat") as UniformMat4);
      }
    }
    if (this._cfg.emission.hasSolid) this._emissionClr = this.uniforms.required("emissionClr") as Uniform3f;
    if (this._cfg.emission.hasTxt2D) {
      this._emission2D = this.uniforms.required("emissionTxt") as UniformSampler2D;
    } else if (this._cfg.emission.hasTxtCube) {
      this._emissionCube = this.uniforms.required("emissionTxt") as UniformSamplerCube;
    }
    if (this._cfg.ambient.hasSolid) this._ambientClr = this.uniforms.required("ambientClr") as Uniform3f;
    if (this._cfg.ambient.hasTxt2D) {
      this._ambient2D = this.uniforms.required("ambientTxt") as UniformSampler2D;
    } else if (this._cfg.ambient.hasTxtCube) {
      this._ambientCube = this.uniforms.required("ambientTxt") as UniformSamplerCube;
    }
    if (this._cfg.diffuse.hasSolid) this._diffuseClr = this.uniforms.required("diffuseClr") as Uniform3f;
    if (this._cfg.diffuse.hasTxt2D) {
      this._diffuse2D = this.uniforms.required("diffuseTxt") as UniformSampler2D;
    } else if (this._cfg.diffuse.hasTxtCube) {
      this._diffuseCube = this.uniforms.required("diffuseTxt") as UniformSamplerCube;
    }
    if (this._cfg.invDiffuse.hasSolid) this._invDiffuseClr = this.uniforms.required("invDiffuseClr") as Uniform3f;
    if (this._cfg.invDiffuse.hasTxt2D) {
      this._invDiffuse2D = this.uniforms.required("invDiffuseTxt") as UniformSampler2D;
    } else if (this._cfg.invDiffuse.hasTxtCube) {
      this._invDiffuseCube = this.uniforms.required("invDiffuseTxt") as UniformSamplerCube;
    }
    if (this._cfg.specular.hasAny) {
      this._shininess = this.uniforms.required("shininess") as Uniform1f;
      if (this._cfg.specular.hasSolid) this._specularClr = this.uniforms.required("specularClr") as Uniform3f;
      if (this._cfg.specular.hasTxt2D) {
        this._specular2D = this.uniforms.required("specularTxt") as UniformSampler2D;
      } else if (this._cfg.specular.hasTxtCube) {
        this._specularCube = this.uniforms.required("specularTxt") as UniformSamplerCube;
      }
    }
    if (this._cfg.bumpy.hasTxt2D) {
      this._bump2D = this.uniforms.required("bumpTxt") as UniformSampler2D;
    } else if (this._cfg.bumpy.hasTxtCube) {
      this._bumpCube = this.uniforms.required("bumpTxt") as UniformSamplerCube;
    }
    if (this._cfg.environmental) {
      this._envSampler = this.uniforms.required("envSampler") as UniformSamplerCube;
      if (this._cfg.reflection.hasSolid) this._reflectClr = this.uniforms.required("reflectClr") as Uniform3f;
      if (this._cfg.reflection.hasTxt2D) {
        this._reflect2D = this.uniforms.required("reflectTxt") as UniformSampler2D;
      } else if (this._cfg.reflection.hasTxtCube) {
        this._reflectCube = this.uniforms.required("reflectTxt") as UniformSamplerCube;
      }
      if (this._cfg.refraction.hasAny) {
        this._refraction = this.uniforms.required("refraction") as Uniform1f;
        if (this._cfg.refraction.hasSolid) this._refractClr = this.uniforms.required("refractClr") as Uniform3f;
        if (this._cfg.refraction.hasTxt2D) {
          this._refract2D = this.uniforms.required("refractTxt") as UniformSampler2D;
        } else if (this._cfg.refraction.hasTxtCube) {
          this._refractCube = this.uniforms.required("refractTxt") as UniformSamplerCube;
        }
      }
    }
    if (this._cfg.alpha.hasSolid) this._alpha = this.uniforms.required("alpha") as Uniform1f;
    if (this._cfg.alpha.hasTxt2D) {
      this._alpha2D = this.uniforms.required("alphaTxt") as UniformSampler2D;
    } else if (this._cfg.alpha.hasTxtCube) {
      this._alphaCube = this.uniforms.required("alphaTxt") as UniformSamplerCube;
    }
    if (this._cfg.lights) {
      if (this._cfg.barLights.isNotEmpty) {
        this._barLightCounts = {};
        this._barLights = {};
        for (final BarLightConfig light in this._cfg.barLights) {
          final int configID = light.configID;
          final String name = light.toString();
          final List<UniformBarLight> lights = [];
          for (int i = 0; i < light.lightCount; ++i) {
            final Uniform3f startPnt = this.uniforms.required("${name}s[$i].startPnt") as Uniform3f;
            final Uniform3f endPnt = this.uniforms.required("${name}s[$i].endPnt") as Uniform3f;
            final Uniform3f color = this.uniforms.required("${name}s[$i].color") as Uniform3f;
            Uniform1f? att0, att1, att2;
            if (light.hasAttenuation) {
              att0 = this.uniforms.required("${name}s[$i].att0") as Uniform1f;
              att1 = this.uniforms.required("${name}s[$i].att1") as Uniform1f;
              att2 = this.uniforms.required("${name}s[$i].att2") as Uniform1f;
            }
            lights.add(UniformBarLight._(i, startPnt, endPnt, color, att0, att1, att2));
          }
          this._barLights[configID] = lights;
          this._barLightCounts[configID] = this.uniforms.required("${name}Count") as Uniform1i;
        }
      }
      if (this._cfg.dirLights.isNotEmpty) {
        this._dirLightCounts = {};
        this._dirLights = {};
        for (final DirectionalLightConfig light in this._cfg.dirLights) {
          final int configID = light.configID;
          final String name = light.toString();
          final List<UniformDirectionalLight> lights = [];
          for (int i = 0; i < light.lightCount; ++i) {
            Uniform3f? objUp, objRight, objDir;
            if (light.hasTexture) {
              objUp = this.uniforms.required("${name}s[$i].objUp") as Uniform3f;
              objRight = this.uniforms.required("${name}s[$i].objRight") as Uniform3f;
              objDir = this.uniforms.required("${name}s[$i].objDir") as Uniform3f;
            }
            final viewDir = this.uniforms.required("${name}s[$i].viewDir") as Uniform3f;
            final color = this.uniforms.required("${name}s[$i].color") as Uniform3f;
            UniformSampler2D? txt;
            if (light.colorTexture) txt = this.uniforms.required("${name}sTexture2D$i") as UniformSampler2D;
            lights.add(UniformDirectionalLight._(i, objUp, objRight, objDir, viewDir, color, txt));
          }
          this._dirLights[configID] = lights;
          this._dirLightCounts[configID] = this.uniforms.required("${name}Count") as Uniform1i;
        }
      }
      if (this._cfg.pointLights.isNotEmpty) {
        this._pointLightCounts = {};
        this._pointLights = {};
        for (final PointLightConfig light in this._cfg.pointLights) {
          final int configID = light.configID;
          final String name = light.toString();
          final List<UniformPointLight> lights = [];
          for (int i = 0; i < light.lightCount; ++i) {
            final Uniform3f point = this.uniforms.required("${name}s[$i].point") as Uniform3f;
            final Uniform3f viewPnt = this.uniforms.required("${name}s[$i].viewPnt") as Uniform3f;
            final Uniform3f color = this.uniforms.required("${name}s[$i].color") as Uniform3f;
            UniformMat3? invViewRotMat;
            if (light.hasTexture) invViewRotMat = this.uniforms.required("${name}s[$i].invViewRotMat") as UniformMat3;
            Uniform4f? shadowAdj;
            UniformSamplerCube? txt;
            UniformSamplerCube? shadow;
            if (light.colorTexture) txt = this.uniforms.required("${name}sTextureCube$i") as UniformSamplerCube;
            if (light.shadowTexture) {
              shadow = this.uniforms.required("${name}sShadowCube$i") as UniformSamplerCube;
              shadowAdj = this.uniforms.required("${name}s[$i].shadowAdj") as Uniform4f;
            }
            Uniform1f? att0, att1, att2;
            if (light.hasAttenuation) {
              att0 = this.uniforms.required("${name}s[$i].att0") as Uniform1f;
              att1 = this.uniforms.required("${name}s[$i].att1") as Uniform1f;
              att2 = this.uniforms.required("${name}s[$i].att2") as Uniform1f;
            }
            lights.add(UniformPointLight._(
                i, point, viewPnt, invViewRotMat, color, txt, shadow, shadowAdj, att0, att1, att2));
          }
          this._pointLights[configID] = lights;
          this._pointLightCounts[configID] = this.uniforms.required("${name}Count") as Uniform1i;
        }
      }
      if (this._cfg.spotLights.isNotEmpty) {
        this._spotLightCounts = {};
        this._spotLights = {};
        for (final SpotLightConfig light in this._cfg.spotLights) {
          final int configID = light.configID;
          final String name = light.toString();
          final List<UniformSpotLight> lights = [];
          for (int i = 0; i < light.lightCount; ++i) {
            final Uniform3f objPnt = this.uniforms.required("${name}s[$i].objPnt") as Uniform3f;
            final Uniform3f objDir = this.uniforms.required("${name}s[$i].objDir") as Uniform3f;
            final Uniform3f viewPnt = this.uniforms.required("${name}s[$i].viewPnt") as Uniform3f;
            final Uniform3f color = this.uniforms.required("${name}s[$i].color") as Uniform3f;
            Uniform3f? objUp, objRight;
            Uniform1f? tuScalar, tvScalar;
            if (light.hasTexture) {
              objUp = this.uniforms.required("${name}s[$i].objUp") as Uniform3f;
              objRight = this.uniforms.required("${name}s[$i].objRight") as Uniform3f;
              tuScalar = this.uniforms.required("${name}s[$i].tuScalar") as Uniform1f;
              tvScalar = this.uniforms.required("${name}s[$i].tvScalar") as Uniform1f;
            }
            Uniform4f? shadowAdj;
            if (light.shadowTexture) shadowAdj = this.uniforms.required("${name}s[$i].shadowAdj") as Uniform4f;
            Uniform1f? cutoff, coneAngle;
            if (light.hasCutOff) {
              cutoff = this.uniforms.required("${name}s[$i].cutoff") as Uniform1f;
              coneAngle = this.uniforms.required("${name}s[$i].coneAngle") as Uniform1f;
            }
            Uniform1f? att0, att1, att2;
            if (light.hasAttenuation) {
              att0 = this.uniforms.required("${name}s[$i].att0") as Uniform1f;
              att1 = this.uniforms.required("${name}s[$i].att1") as Uniform1f;
              att2 = this.uniforms.required("${name}s[$i].att2") as Uniform1f;
            }
            UniformSampler2D? txt, shadow;
            if (light.colorTexture) txt = this.uniforms.required("${name}sTexture2D$i") as UniformSampler2D;
            if (light.shadowTexture) shadow = this.uniforms.required("${name}sShadow2D$i") as UniformSampler2D;
            lights.add(UniformSpotLight._(i, objPnt, objDir, viewPnt, color, objUp, objRight, tuScalar, tvScalar,
                shadowAdj, cutoff, coneAngle, att0, att1, att2, txt, shadow));
          }
          this._spotLights[configID] = lights;
          this._spotLightCounts[configID] = this.uniforms.required("${name}Count") as Uniform1i;
        }
      }
    }
    if (this._cfg.fog) {
      this._fogClr = this.uniforms.required("fogColor") as Uniform4f;
      this._fogStop = this.uniforms.required("fogStop") as Uniform1f;
      this._fogWidth = this.uniforms.required("fogWidth") as Uniform1f;
    }
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory MaterialLight.cached(MaterialLightConfig cfg, RenderState state) {
    MaterialLight? shader = state.shader(cfg.name) as MaterialLight?;
    if (shader == null) {
      shader = MaterialLight(cfg, state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// Sets the texture 2D and null texture indicator for the shader.
  void _setTexture2D(UniformSampler2D? txt2D, Texture2D? txt) {
    if ((txt != null) && txt.loaded) txt2D?.setTexture2D(txt);
  }

  /// Sets the texture cube and null texture indicator for the shader.
  void _setTextureCube(UniformSamplerCube? txtCube, TextureCube? txt) {
    if ((txt != null) && txt.loaded) txtCube?.setTextureCube(txt);
  }

  /// The configuration the shader is built for.
  MaterialLightConfig get configuration => this._cfg;

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// The normal vertex shader attribute.
  Attribute? get normAttr => this._normAttr;

  /// The binormal vertex shader attribute.
  Attribute? get binmAttr => this._binmAttr;

  /// The texture 2D vertex shader attribute.
  Attribute? get txt2DAttr => this._txt2DAttr;

  /// The texture Cube vertex shader attribute.
  Attribute? get txtCubeAttr => this._txtCubeAttr;

  /// The bending value shader attribute.
  Attribute? get bendAttr => this._bendAttr;

  /// The object matrix.
  Matrix4 get objectMatrix => this._objMat?.getMatrix4() ?? Matrix4.identity;

  set objectMatrix(Matrix4 mat) => this._objMat?.setMatrix4(mat);

  /// The view matrix multiplied by the object matrix.
  Matrix4 get viewObjectMatrix => this._viewObjMat?.getMatrix4() ?? Matrix4.identity;

  set viewObjectMatrix(Matrix4 mat) => this._viewObjMat?.setMatrix4(mat);

  /// The view matrix.
  Matrix4 get viewMatrix => this._viewMat?.getMatrix4() ?? Matrix4.identity;

  set viewMatrix(Matrix4 mat) => this._viewMat?.setMatrix4(mat);

  /// The product of the projection matrix, view matrix, and object matrix.
  Matrix4 get projectViewObjectMatrix => this._projViewObjMat?.getMatrix4() ?? Matrix4.identity;

  set projectViewObjectMatrix(Matrix4 mat) => this._projViewObjMat?.setMatrix4(mat);

  /// The product of the projection matrix and view matrix.
  Matrix4 get projectViewMatrix => this._projViewMat?.getMatrix4() ?? Matrix4.identity;

  set projectViewMatrix(Matrix4 mat) => this._projViewMat?.setMatrix4(mat);

  /// The inverse view matrix.
  Matrix4 get inverseViewMatrix => this._invViewMat?.getMatrix4() ?? Matrix4.identity;

  set inverseViewMatrix(Matrix4 mat) => this._invViewMat?.setMatrix4(mat);

  /// The 2D texture modification matrix.
  Matrix3 get texture2DMatrix => this._txt2DMat?.getMatrix3() ?? Matrix3.identity;

  set texture2DMatrix(Matrix3 mat) => this._txt2DMat?.setMatrix3(mat);

  /// The cube texture modification matrix.
  Matrix4 get textureCubeMatrix => this._txtCubeMat?.getMatrix4() ?? Matrix4.identity;

  set textureCubeMatrix(Matrix4 mat) => this._txtCubeMat?.setMatrix4(mat);

  /// The color modification matrix.
  Matrix4 get colorMatrix => this._colorMat?.getMatrix4() ?? Matrix4.identity;

  set colorMatrix(Matrix4 mat) => this._colorMat?.setMatrix4(mat);

  /// The number of bend matrices.
  int get bendMatricesCount => this._bendMatCount?.getValue() ?? 0;

  set bendMatricesCount(int count) => this._bendMatCount?.setValue(count);

  /// Sets the bend matrix with to the given [index].
  void setBendMatrix(int index, Matrix4 mat) => this._bendMatrices[index]?.setMatrix4(mat);

  /// Gets the bend matrix from the given [index].
  Matrix4 getBendMatrix(int index) => this._bendMatrices[index]?.getMatrix4() ?? Matrix4.identity;

  /// The emission color scalar of the object.
  Color3 get emissionColor => this._emissionClr?.getColor3() ?? Color3.white();

  set emissionColor(Color3 clr) => this._emissionClr?.setColor3(clr);

  /// The emission texture 2D of the object.
  set emissionTexture2D(Texture2D? txt) => this._setTexture2D(this._emission2D, txt);

  /// The emission texture cube of the object.
  set emissionTextureCube(TextureCube? txt) => this._setTextureCube(this._emissionCube, txt);

  /// The ambient color scalar of the object.
  Color3 get ambientColor => this._ambientClr?.getColor3() ?? Color3.white();

  set ambientColor(Color3 clr) => this._ambientClr?.setColor3(clr);

  /// The ambient texture 2D of the object.
  set ambientTexture2D(Texture2D? txt) => this._setTexture2D(this._ambient2D, txt);

  /// The ambient texture cube of the object.
  set ambientTextureCube(TextureCube? txt) => this._setTextureCube(this._ambientCube, txt);

  /// The diffuse color scalar of the object.
  Color3 get diffuseColor => this._diffuseClr?.getColor3() ?? Color3.white();

  set diffuseColor(Color3 clr) => this._diffuseClr?.setColor3(clr);

  /// The diffuse texture 2D of the object.
  set diffuseTexture2D(Texture2D? txt) => this._setTexture2D(this._diffuse2D, txt);

  /// The diffuse texture cube of the object.
  set diffuseTextureCube(TextureCube? txt) => this._setTextureCube(this._diffuseCube, txt);

  /// The inverse diffuse color scalar of the object.
  Color3 get invDiffuseColor => this._invDiffuseClr?.getColor3() ?? Color3.white();

  set invDiffuseColor(Color3 clr) => this._invDiffuseClr?.setColor3(clr);

  /// The inverse diffuse texture 2D of the object.
  set invDiffuseTexture2D(Texture2D? txt) => this._setTexture2D(this._invDiffuse2D, txt);

  /// The inverse diffuse texture cube of the object.
  set invDiffuseTextureCube(TextureCube? txt) => this._setTextureCube(this._invDiffuseCube, txt);

  /// The specular color scalar of the object.
  Color3 get specularColor => this._specularClr?.getColor3() ?? Color3.white();

  set specularColor(Color3 clr) => this._specularClr?.setColor3(clr);

  /// The specular texture 2D of the object.
  set specularTexture2D(Texture2D? txt) => this._setTexture2D(this._specular2D, txt);

  /// The specular texture cube of the object.
  set specularTextureCube(TextureCube? txt) => this._setTextureCube(this._specularCube, txt);

  /// The shininess value of the specular.
  double get shininess => this._shininess?.getValue() ?? 10.0;

  set shininess(double value) => this._shininess?.setValue(value);

  /// The normal distortion texture 2D of the object.
  set bumpTexture2D(Texture2D? txt) => this._setTexture2D(this._bump2D, txt);

  /// The normal distortion texture cube of the object.
  set bumpTextureCube(TextureCube? txt) => this._setTextureCube(this._bumpCube, txt);

  /// The environment texture cube of the object.
  set environmentTextureCube(TextureCube? txt) => this._setTextureCube(this._envSampler, txt);

  /// The refraction value of the specular.
  double get refraction => this._refraction?.getValue() ?? 0.0;

  set refraction(double value) => this._refraction?.setValue(value);

  /// The reflection color scalar of the object.
  Color3 get reflectionColor => this._reflectClr?.getColor3() ?? Color3.white();

  set reflectionColor(Color3 clr) => this._reflectClr?.setColor3(clr);

  /// The reflection texture 2D scalar of the object.
  set reflectionTexture2D(Texture2D? txt) => this._setTexture2D(this._reflect2D, txt);

  /// The reflection texture cube scalar of the object.
  set reflectionTextureCube(TextureCube? txt) => this._setTextureCube(this._reflectCube, txt);

  /// The refraction color scalar of the object.
  Color3 get refractionColor => this._refractClr?.getColor3() ?? Color3.white();

  set refractionColor(Color3 clr) => this._refractClr?.setColor3(clr);

  /// The refraction texture 2D scalar of the object.
  set refractionTexture2D(Texture2D? txt) => this._setTexture2D(this._refract2D, txt);

  /// The refraction texture cube scalar of the object.
  set refractionTextureCube(TextureCube? txt) => this._setTextureCube(this._refractCube, txt);

  /// The alpha scalar of the object.
  double get alpha => this._alpha?.getValue() ?? 1.0;

  set alpha(double alpha) => this._alpha?.setValue(alpha);

  /// The alpha texture 2D of the object.
  set alphaTexture2D(Texture2D? txt) => this._setTexture2D(this._alpha2D, txt);

  /// The alpha texture cube of the object.
  set alphaTextureCube(TextureCube? txt) => this._setTextureCube(this._alphaCube, txt);

  /// The number of currently used bar lights.
  int getBarLightCount(int configID) => this._barLightCounts[configID]?.getValue() ?? 0;

  void setBarLightCount(int configID, int count) => this._barLightCounts[configID]?.setValue(count);

  /// The list of bar lights grouped by the configuration IDs.
  List<UniformBarLight> getBarLight(int configID) => this._barLights[configID] ?? [];

  /// The number of currently used directional lights.
  int getDirectionalLightCount(int configID) => this._dirLightCounts[configID]?.getValue() ?? 0;

  void setDirectionalLightCount(int configID, int count) => this._dirLightCounts[configID]?.setValue(count);

  /// The list of directional lights grouped by the configuration IDs.
  List<UniformDirectionalLight> getDirectionalLight(int configID) => this._dirLights[configID] ?? [];

  /// The number of currently used point lights.
  int getPointLightCount(int configID) => this._pointLightCounts[configID]?.getValue() ?? 0;

  void setPointLightCount(int configID, int count) => this._pointLightCounts[configID]?.setValue(count);

  /// The list of point lights grouped by the configuration IDs.
  List<UniformPointLight> getPointLight(int configID) => this._pointLights[configID] ?? [];

  /// The number of currently used spot lights.
  int getSpotLightCount(int configID) => this._spotLightCounts[configID]?.getValue() ?? 0;

  void setSpotLightCount(int configID, int count) => this._spotLightCounts[configID]?.setValue(count);

  /// The list of spot lights grouped by the configuration IDs.
  List<UniformSpotLight> getSpotLight(int configID) => this._spotLights[configID] ?? [];

  /// The color of the fog.
  Color4 get fogColor => this._fogClr?.getColor4() ?? Color4.white();

  set fogColor(Color4 clr) => this._fogClr?.setColor4(clr);

  /// The fog stop is the minimum depth at which fog stops being applied.
  double get fogStop => this._fogStop?.getValue() ?? 1.0;

  set fogStop(double value) => this._fogStop?.setValue(value);

  /// The fog width from the fog stop to when the only color returned is the fog color.
  double get fogWidth => this._fogWidth?.getValue() ?? 1.0;

  set fogWidth(double value) => this._fogWidth?.setValue(value);
}

/// The configuration for a specific type of bar lights
/// that can be added to the material light shader.
class BarLightConfig {
  /// The identifier for the type of bar light this configuration is for.
  final int configID;

  /// Indicates the number of bar lights of this type.
  final int lightCount;

  /// Constructs a new bar light configuration.
  BarLightConfig(this.configID, this.lightCount);

  /// Indicates if this type of bar light has light attenuation.
  bool get hasAttenuation => (this.configID & 0x04) != 0x00;

  /// Indicates if this type of bar light has either attenuation or shadow
  /// meaning that it will require calculating distance from light.
  bool get hasDist => (this.configID & 0x06) != 0x00;

  /// Gets the string for this bar light configuration.
  @override
  String toString() => "barLight${this.configID}";
}

/// The configuration for a specific type of directional lights
/// that can be added to the material light shader.
class DirectionalLightConfig {
  /// The identifier for the type of directional light this configuration is for.
  final int configID;

  /// Indicates the number of directional lights of this type.
  final int lightCount;

  /// Constructs a new directional light configuration.
  DirectionalLightConfig(this.configID, this.lightCount);

  /// Indicates if this type of directional light has a color texture.
  bool get colorTexture => (this.configID & 0x01) != 0x00;

  /// Indicates if this type of directional light has either a color or shadow texture.
  bool get hasTexture => (this.configID & 0x01) != 0x00;

  /// Gets the string for this directional light configuration.
  @override
  String toString() => "dirLight${this.configID}";
}

/// The configuration for a specific type of point lights
/// that can be added to the material light shader.
class PointLightConfig {
  /// The identifier for the type of point light this configuration is for.
  final int configID;

  /// Indicates the number of point lights of this type.
  final int lightCount;

  /// Constructs a new point light configuration.
  PointLightConfig(this.configID, this.lightCount);

  /// Indicates if this type of point light has a color texture.
  bool get colorTexture => (this.configID & 0x01) != 0x00;

  /// Indicates if this type of point light has a shadow texture.
  bool get shadowTexture => (this.configID & 0x02) != 0x00;

  /// Indicates if this type of point light has light attenuation.
  bool get hasAttenuation => (this.configID & 0x04) != 0x00;

  /// Indicates if this type of point light has either a color or shadow texture.
  bool get hasTexture => (this.configID & 0x03) != 0x00;

  /// Indicates if this type of point light has either attenuation or shadow
  /// meaning that it will require calculating distance from light.
  bool get hasDist => (this.configID & 0x06) != 0x00;

  /// Gets the string for this point light configuration.
  @override
  String toString() => "pointLight${this.configID}";
}

/// The configuration for a specific type of spot lights
/// that can be added to the material light shader.
class SpotLightConfig {
  /// The identifier for the type of spot light this configuration is for.
  final int configID;

  /// Indicates the number of spot lights of this type.
  final int lightCount;

  /// Constructs a new spot light configuration.
  SpotLightConfig(this.configID, this.lightCount);

  /// Indicates if this type of spot light has a color texture.
  bool get colorTexture => (this.configID & 0x01) != 0x00;

  /// Indicates if this type of spot light has a shadow texture.
  bool get shadowTexture => (this.configID & 0x02) != 0x00;

  /// Indicates if this type of spot light has light attenuation.
  bool get hasAttenuation => (this.configID & 0x04) != 0x00;

  /// Indicates if this type of spot light has a light cone cut off.
  bool get hasCutOff => (this.configID & 0x08) != 0x00;

  /// Indicates if this type of spot light has either a color or shadow texture.
  bool get hasTexture => (this.configID & 0x03) != 0x00;

  /// Indicates if this type of spot light has either attenuation or shadow
  /// meaning that it will require calculating distance from light.
  bool get hasDist => (this.configID & 0x06) != 0x00;

  /// Gets the string for this spot light configuration.
  @override
  String toString() => "spotLight${this.configID}";
}

/// The shader configuration for rendering material light.
class MaterialLightConfig {
  /// The emission color source type.
  final ColorSourceType emission;

  /// The ambient color source type.
  final ColorSourceType ambient;

  /// The diffuse color source type.
  final ColorSourceType diffuse;

  /// The inverse diffuse color source type.
  final ColorSourceType invDiffuse;

  /// The specular color source type.
  final ColorSourceType specular;

  /// The bumpy color source type.
  final ColorSourceType bumpy;

  /// The reflection color source type.
  final ColorSourceType reflection;

  /// The refraction color source type.
  final ColorSourceType refraction;

  /// The alpha color source type.
  final ColorSourceType alpha;

  /// The bar light configurations.
  final List<BarLightConfig> barLights;

  /// The directional light configurations.
  final List<DirectionalLightConfig> dirLights;

  /// The point light configurations.
  final List<PointLightConfig> pointLights;

  /// The spot light configurations.
  final List<SpotLightConfig> spotLights;

  /// The total number of any type of light.
  final int totalLights;

  /// Indicates there is either reflection or refraction
  /// meaning that an environmental map is needed for this shader.
  final bool environmental;

  /// Indicates that there is intense light illumination via
  /// diffuse, inverse diffuse, and specular.
  final bool intense;

  /// Indicates the inverse view matrix is needed for this shader.
  final bool invViewMat;

  /// Indicates the object matrix is needed for this shader.
  final bool objMat;

  /// Indicates the view object matrix is needed for this shader.
  final bool viewObjMat;

  /// Indicates the projection view object matrix is needed for this shader.
  final bool projViewObjMat;

  /// Indicates the view matrix is needed by the fragment shader.
  final bool viewMat;

  /// Indicates the projection view matrix is needed for this shader.
  final bool projViewMat;

  /// Indicates the ambient, diffuse, inverse diffuse, or specular
  /// material component is used meaning lighting is needed for this shader.
  /// If lighting is needed but no lights are provided a default light is used.
  final bool lights;

  /// Indicates the object's position is needed by the fragment shader.
  final bool objPos;

  /// Indicates the camera's position is needed by the fragment shader.
  final bool viewPos;

  /// Indicates the normal vector is needed by the fragment shader.
  final bool norm;

  /// Indicates the binormal vector is needed by the fragment shader.
  final bool binm;

  /// Indicates the 2D texture coordinate is needed by the fragment shader.
  final bool txt2D;

  /// Indicates the cube texture coordinate is needed by the fragment shader.
  final bool txtCube;

  /// Indicates the bending is needed by the vertex shader.
  final bool bending;

  /// Indicates the 2D texture matrix is needed by the vertex shader.
  final bool txt2DMat;

  /// Indicates the cube texture matrix is needed by the vertex shader.
  final bool txtCubeMat;

  /// Indicates the color matrix is needed by the fragment shader.
  final bool colorMat;

  /// Indicates that fog is enabled.
  final bool fog;

  /// The total number of bend matrices allowed by this shader.
  final int bendMats;

  /// The name of this shader configuration.
  final String name;

  /// The vertex type required from shapes to be drawn using this shader.
  final VertexType vertexType;

  /// Creates a new material light configuration.
  /// The configuration for the material light shader.
  factory MaterialLightConfig(
      bool txt2DMat,
      bool txtCubeMat,
      bool colorMat,
      bool fog,
      int bendMats,
      ColorSourceType emission,
      ColorSourceType ambient,
      ColorSourceType diffuse,
      ColorSourceType invDiffuse,
      ColorSourceType specular,
      ColorSourceType bumpy,
      ColorSourceType reflection,
      ColorSourceType refraction,
      ColorSourceType alpha,
      List<BarLightConfig> barLights,
      List<DirectionalLightConfig> dirLights,
      List<PointLightConfig> pointLights,
      List<SpotLightConfig> spotLights) {
    final StringBuffer buf = StringBuffer();
    buf.write("MaterialLight_");
    buf.write(emission.toString());
    buf.write(ambient.toString());
    buf.write(diffuse.toString());
    buf.write(invDiffuse.toString());
    buf.write(specular.toString());
    buf.write(bumpy.toString());
    buf.write(reflection.toString());
    buf.write(refraction.toString());
    buf.write(alpha.toString());
    buf.write("_");
    buf.write(txt2DMat ? "1" : "0");
    buf.write(txtCubeMat ? "1" : "0");
    buf.write(colorMat ? "1" : "0");
    buf.write(fog ? "1" : "0");
    buf.write("_");
    buf.write(bendMats);

    if (barLights.isNotEmpty) {
      buf.write("_Bar");
      for (final BarLightConfig light in barLights) {
        buf.write("_${light.configID}");
      }
    }

    if (dirLights.isNotEmpty) {
      buf.write("_Dir");
      for (final DirectionalLightConfig light in dirLights) {
        buf.write("_${light.configID}");
      }
    }

    if (pointLights.isNotEmpty) {
      buf.write("_Point");
      for (final PointLightConfig light in pointLights) {
        buf.write("_${light.configID}");
      }
    }

    if (spotLights.isNotEmpty) {
      buf.write("_Spot");
      for (final SpotLightConfig light in spotLights) {
        buf.write("_${light.configID}");
      }
    }
    final String name = buf.toString();

    int totalLights = 0;
    bool objPos = fog;
    for (final BarLightConfig light in barLights) {
      totalLights += light.lightCount;
      objPos = true;
    }
    for (final DirectionalLightConfig light in dirLights) {
      totalLights += light.lightCount;
      objPos = true;
    }
    for (final PointLightConfig light in pointLights) {
      totalLights += light.lightCount;
      objPos = true;
    }
    for (final SpotLightConfig light in spotLights) {
      totalLights += light.lightCount;
      objPos = true;
    }

    final bool environmental = reflection.hasAny || refraction.hasAny;
    final bool invViewMat = environmental;
    final bool hasBar = barLights.isNotEmpty;
    final bool lights = ambient.hasAny || diffuse.hasAny || invDiffuse.hasAny || specular.hasAny;
    final bool viewPos = (specular.hasAny) || hasBar || (pointLights.isNotEmpty) || environmental;
    final bool intense = diffuse.hasAny || invDiffuse.hasAny || specular.hasAny;

    final bool norm = intense || bumpy.hasAny || environmental;
    final bool binm = bumpy.hasAny;
    final bool txt2D = emission.hasTxt2D ||
        ambient.hasTxt2D ||
        diffuse.hasTxt2D ||
        invDiffuse.hasTxt2D ||
        specular.hasTxt2D ||
        bumpy.hasTxt2D ||
        reflection.hasTxt2D ||
        refraction.hasTxt2D ||
        alpha.hasTxt2D;
    final bool txtCube = emission.hasTxtCube ||
        ambient.hasTxtCube ||
        diffuse.hasTxtCube ||
        invDiffuse.hasTxtCube ||
        specular.hasTxtCube ||
        bumpy.hasTxtCube ||
        reflection.hasTxtCube ||
        refraction.hasTxtCube ||
        alpha.hasTxtCube;
    final bool bending = bendMats > 0;
    final bool objMat = objPos;
    final bool viewObjMat = norm || binm || viewPos || fog;
    final bool viewMat = hasBar && intense;
    const bool projViewObjMat = true;
    const bool projViewMat = false;
    txt2DMat = txt2DMat && txt2D;
    txtCubeMat = txtCubeMat && txtCube;

    VertexType vertexType = VertexType.Pos;
    if (norm) vertexType |= VertexType.Norm;
    if (binm) vertexType |= VertexType.Binm;
    if (txt2D) vertexType |= VertexType.Txt2D;
    if (txtCube) vertexType |= VertexType.TxtCube;
    if (bending) vertexType |= VertexType.Bending;

    return MaterialLightConfig._(
        emission,
        ambient,
        diffuse,
        invDiffuse,
        specular,
        bumpy,
        reflection,
        refraction,
        alpha,
        barLights,
        dirLights,
        pointLights,
        spotLights,
        totalLights,
        environmental,
        intense,
        invViewMat,
        objMat,
        viewObjMat,
        projViewObjMat,
        viewMat,
        projViewMat,
        lights,
        objPos,
        viewPos,
        norm,
        binm,
        txt2D,
        txtCube,
        bending,
        txt2DMat,
        txtCubeMat,
        colorMat,
        fog,
        bendMats,
        name,
        vertexType);
  }

  /// Creates a new material light configuration with all final values
  /// calculated by the other MaterialLightConfig constructor.
  MaterialLightConfig._(
      this.emission,
      this.ambient,
      this.diffuse,
      this.invDiffuse,
      this.specular,
      this.bumpy,
      this.reflection,
      this.refraction,
      this.alpha,
      this.barLights,
      this.dirLights,
      this.pointLights,
      this.spotLights,
      this.totalLights,
      this.environmental,
      this.intense,
      this.invViewMat,
      this.objMat,
      this.viewObjMat,
      this.projViewObjMat,
      this.viewMat,
      this.projViewMat,
      this.lights,
      this.objPos,
      this.viewPos,
      this.norm,
      this.binm,
      this.txt2D,
      this.txtCube,
      this.bending,
      this.txt2DMat,
      this.txtCubeMat,
      this.colorMat,
      this.fog,
      this.bendMats,
      this.name,
      this.vertexType);

  /// Creates the vertex source code for the material light shader for the given configurations.
  String createVertexSource() => _materialLightVS.createVertexSource(this);

  /// Creates the fragment source code for the material light shader for the given configurations.
  String createFragmentSource() => _materialLightFS.createFragmentSource(this);

  /// Gets the name for the configuration.
  @override
  String toString() => this.name;
}

/// The fragment shader writer for rendering material light.
class _materialLightFS {
  /// Writes the typical variables for the given source type
  /// with the given [name] to the fragment shader [buf].
  static void _fragmentSrcTypeVars(StringBuffer buf, ColorSourceType srcType, String name) {
    if (srcType.hasSolid) buf.writeln("uniform vec3 ${name}Clr;");
    if (srcType.hasTxt2D) {
      buf.writeln("uniform sampler2D ${name}Txt;");
    } else if (srcType.hasTxtCube) {
      buf.writeln("uniform samplerCube ${name}Txt;");
    }
  }

  /// Writes the basics for a color source in a vertex fragment.
  static void _writeColorSource(StringBuffer buf, ColorSourceType srcType, String name) {
    _fragmentSrcTypeVars(buf, srcType, name);
    buf.writeln("");
    buf.writeln("vec3 ${name}Color;");
    buf.writeln("");
    buf.writeln("void set${toTitleCase(name)}Color()");
    buf.writeln("{");
    if (srcType.hasSolid) {
      if (srcType.hasTxt2D) {
        buf.writeln("   ${name}Color = ${name}Clr*texture2D(${name}Txt, txt2D).rgb;");
      } else if (srcType.hasTxtCube) {
        buf.writeln("   ${name}Color = ${name}Clr*textureCube(${name}Txt, txtCube).rgb;");
      } else {
        buf.writeln("   ${name}Color = ${name}Clr;");
      }
    } else if (srcType.hasTxt2D) {
      buf.writeln("   ${name}Color = texture2D(${name}Txt, txt2D).rgb;");
    } else if (srcType.hasTxtCube) {
      buf.writeln("   ${name}Color = textureCube(${name}Txt, txtCube).rgb;");
    }
    buf.writeln("}");
  }

  /// Writes the emission material component to the fragment shader [buf].
  static void _writeEmission(MaterialLightConfig cfg, StringBuffer buf) {
    if (cfg.emission.hasNone) return;
    buf.writeln("// === Emission ===");
    buf.writeln("");
    _fragmentSrcTypeVars(buf, cfg.emission, "emission");
    buf.writeln("");
    buf.writeln("vec3 emissionColor()");
    buf.writeln("{");
    if (cfg.emission.hasSolid) {
      if (cfg.emission.hasTxt2D) {
        buf.writeln("   return emissionClr*texture2D(emissionTxt, txt2D).rgb;");
      } else if (cfg.emission.hasTxtCube) {
        buf.writeln("   return emissionClr*textureCube(emissionTxt, txtCube).rgb;");
      } else {
        buf.writeln("   return emissionClr;");
      }
    } else if (cfg.emission.hasTxt2D) {
      buf.writeln("   return texture2D(emissionTxt, txt2D).rgb;");
    } else if (cfg.emission.hasTxtCube) {
      buf.writeln("   return textureCube(emissionTxt, txtCube).rgb;");
    }
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the ambient material component to the fragment shader [buf].
  static void _writeAmbient(MaterialLightConfig cfg, StringBuffer buf) {
    if (cfg.ambient.hasNone) return;
    buf.writeln("// === Ambient ===");
    buf.writeln("");
    _writeColorSource(buf, cfg.ambient, "ambient");
    buf.writeln("");
  }

  /// Writes the diffuse material component to the fragment shader [buf].
  static void _writeDiffuse(MaterialLightConfig cfg, StringBuffer buf) {
    if (cfg.diffuse.hasNone) return;
    buf.writeln("// === Diffuse ===");
    buf.writeln("");
    _writeColorSource(buf, cfg.diffuse, "diffuse");
    buf.writeln("");
    buf.writeln("vec3 diffuse(vec3 norm, vec3 litVec)");
    buf.writeln("{");
    buf.writeln("   float scalar = dot(norm, -litVec);");
    buf.writeln("   if(scalar < 0.0) return vec3(0.0, 0.0, 0.0);");
    buf.writeln("   return diffuseColor*scalar;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the inverse diffuse material component to the fragment shader [buf].
  static void _writeInvDiffuse(MaterialLightConfig cfg, StringBuffer buf) {
    if (cfg.invDiffuse.hasNone) return;
    buf.writeln("// === Inverse Diffuse ===");
    buf.writeln("");
    _writeColorSource(buf, cfg.invDiffuse, "invDiffuse");
    buf.writeln("");
    buf.writeln("vec3 invDiffuse(vec3 norm, vec3 litVec)");
    buf.writeln("{");
    buf.writeln("   float scalar = 1.0 - clamp(dot(norm, -litVec), 0.0, 1.0);");
    buf.writeln("   if(scalar < 0.0) return vec3(0.0, 0.0, 0.0);");
    buf.writeln("   return invDiffuseColor*scalar;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the specular material component to the fragment shader [buf].
  static void _writeSpecular(MaterialLightConfig cfg, StringBuffer buf) {
    if (cfg.specular.hasNone) return;
    buf.writeln("// === Specular ===");
    buf.writeln("");
    buf.writeln("uniform float shininess;");
    _writeColorSource(buf, cfg.specular, "specular");
    buf.writeln("");
    buf.writeln("vec3 specular(vec3 norm, vec3 litVec)");
    buf.writeln("{");
    buf.writeln("   if(dot(norm, -litVec) < 0.0) return vec3(0.0, 0.0, 0.0);");
    buf.writeln("   vec3 lightRef = normalize(reflect(litVec, norm));");
    buf.writeln("   float scalar = dot(lightRef, -normalize(viewPos));");
    buf.writeln("   if(scalar < 0.0) return vec3(0.0, 0.0, 0.0);");
    buf.writeln("   return specularColor*pow(scalar, shininess);");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the normal calculation to the fragment shader [buf].
  static void _writeNormal(MaterialLightConfig cfg, StringBuffer buf) {
    if (!cfg.norm) return;
    buf.writeln("// === Normal ===");
    buf.writeln("");
    if (cfg.bumpy.hasTxt2D) {
      buf.writeln("uniform sampler2D bumpTxt;");
      buf.writeln("");
    } else if (cfg.bumpy.hasTxtCube) {
      buf.writeln("uniform samplerCube bumpTxt;");
      buf.writeln("");
    }
    buf.writeln("vec3 normal()");
    buf.writeln("{");
    if (cfg.bumpy.hasNone || cfg.bumpy.hasSolid) {
      buf.writeln("   return normalize(normalVec);");
    } else {
      if (cfg.bumpy.hasTxt2D) {
        buf.writeln("   vec3 color = texture2D(bumpTxt, txt2D).rgb;");
      } else {
        // hasTxtCube
        buf.writeln("   vec3 color = textureCube(bumpTxt, txtCube).rgb;");
      }
      buf.writeln("   vec3 n = normalize(normalVec);");
      buf.writeln("   vec3 b = normalize(binormalVec);");
      buf.writeln("   vec3 c = normalize(cross(b, n));");
      buf.writeln("   b = cross(n, c);");
      buf.writeln("   mat3 mat = mat3( b.x,  b.y,  b.z,");
      buf.writeln("                   -c.x, -c.y, -c.z,");
      buf.writeln("                    n.x,  n.y,  n.z);");
      buf.writeln("   return mat * normalize(2.0*color - 1.0);");
    }
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the reflection calculation to the fragment shader [buf].
  static void _writeReflection(MaterialLightConfig cfg, StringBuffer buf) {
    if (cfg.reflection.hasNone) return;
    buf.writeln("// === Reflection ===");
    buf.writeln("");
    _fragmentSrcTypeVars(buf, cfg.reflection, "reflect");
    buf.writeln("");
    buf.writeln("vec3 reflect(vec3 refl)");
    buf.writeln("{");

    if (cfg.reflection.hasSolid) {
      if (cfg.reflection.hasTxt2D) {
        buf.writeln("   vec3 scalar = reflectClr*texture2D(reflectTxt, txt2D).rgb;");
      } else if (cfg.reflection.hasTxtCube) {
        buf.writeln("   vec3 scalar = reflectClr*textureCube(reflectTxt, txtCube).rgb;");
      } else {
        buf.writeln("   vec3 scalar = reflectClr;");
      }
    } else if (cfg.reflection.hasTxt2D) {
      buf.writeln("   vec3 scalar = texture2D(reflectTxt, txt2D).rgb;");
    } else if (cfg.reflection.hasTxtCube) {
      buf.writeln("   vec3 scalar = textureCube(reflectTxt, txtCube).rgb;");
    }

    buf.writeln("   vec3 invRefl = vec3(invViewMat*vec4(refl, 0.0));");
    buf.writeln("   return scalar*textureCube(envSampler, invRefl).rgb;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the refraction calculation to the fragment shader [buf].
  static void _writeRefraction(MaterialLightConfig cfg, StringBuffer buf) {
    if (cfg.refraction.hasNone) return;
    buf.writeln("// === Refraction ===");
    buf.writeln("");
    _fragmentSrcTypeVars(buf, cfg.refraction, "refract");
    buf.writeln("uniform float refraction;");
    buf.writeln("");
    buf.writeln("vec3 refract(vec3 refl)");
    buf.writeln("{");

    if (cfg.refraction.hasSolid) {
      if (cfg.refraction.hasTxt2D) {
        buf.writeln("   vec3 scalar = refractClr*texture2D(refractTxt, txt2D).rgb;");
      } else if (cfg.refraction.hasTxtCube) {
        buf.writeln("   vec3 scalar = refractClr*textureCube(refractTxt, txtCube).rgb;");
      } else {
        buf.writeln("   vec3 scalar = refractClr;");
      }
    } else if (cfg.refraction.hasTxt2D) {
      buf.writeln("   vec3 scalar = texture2D(refractTxt, txt2D).rgb;");
    } else if (cfg.refraction.hasTxtCube) {
      buf.writeln("   vec3 scalar = textureCube(refractTxt, txtCube).rgb;");
    }

    buf.writeln("   vec3 refr = mix(-refl, viewPos, refraction);");
    buf.writeln("   vec3 invRefr = vec3(invViewMat*vec4(refr, 0.0));");
    buf.writeln("   return scalar*textureCube(envSampler, invRefr).rgb;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the alpha component to the fragment shader [buf].
  static void _writeAlpha(MaterialLightConfig cfg, StringBuffer buf) {
    buf.writeln("// === Alpha ===");
    buf.writeln("");

    if (cfg.alpha.hasSolid) buf.writeln("uniform float alpha;");
    if (cfg.alpha.hasTxt2D) buf.writeln("uniform sampler2D alphaTxt;");
    if (cfg.alpha.hasTxtCube) buf.writeln("uniform samplerCube alphaTxt;");

    buf.writeln("float alphaValue()");
    buf.writeln("{");

    if (cfg.alpha.hasNone) {
      buf.writeln("   return 1.0;");
    } else if (cfg.alpha.hasTxt2D || cfg.alpha.hasTxtCube) {
      if (cfg.alpha.hasSolid) {
        if (cfg.alpha.hasTxt2D) {
          buf.writeln("   float a = alpha*texture2D(alphaTxt, txt2D).a;");
        } else if (cfg.alpha.hasTxtCube) {
          buf.writeln("   float a = alpha*textureCube(alphaTxt, txtCube).a;");
        }
      } else if (cfg.alpha.hasTxt2D) {
        buf.writeln("   float a = texture2D(alphaTxt, txt2D).a;");
      } else if (cfg.alpha.hasTxtCube) {
        buf.writeln("   float a = textureCube(alphaTxt, txtCube).a;");
      }
      buf.writeln("   if (a <= 0.000001) discard;");
      buf.writeln("   return a;");
    } else if (cfg.alpha.hasSolid) {
      buf.writeln("   return alpha;");
    }

    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the bar lights to the fragment shader [buf].
  static void _writeBarLight(MaterialLightConfig cfg, BarLightConfig light, StringBuffer buf) {
    if (light.lightCount <= 0) return;
    final String name = light.toString();
    final String title = toTitleCase(name);

    buf.writeln("// === ${title} ===");
    buf.writeln("");
    buf.writeln("struct ${title}");
    buf.writeln("{");
    buf.writeln("   vec3 startPnt;");
    buf.writeln("   vec3 endPnt;");
    buf.writeln("   vec3 color;");
    if (light.hasAttenuation) {
      buf.writeln("   float att0;");
      buf.writeln("   float att1;");
      buf.writeln("   float att2;");
    }
    buf.writeln("};");
    buf.writeln("");
    buf.writeln("uniform int ${name}Count;");
    buf.writeln("uniform ${title} ${name}s[${light.lightCount}];");
    buf.writeln("");
    buf.writeln("vec3 ${name}ClosestPoint($title lit)");
    buf.writeln("{");
    buf.writeln("   vec3 lineVec = lit.endPnt - lit.startPnt;");
    buf.writeln("   float lineLen2 = dot(lineVec, lineVec);");
    buf.writeln("   if(lineLen2 <= 0.0001) return lit.startPnt;");
    buf.writeln("   float t = dot(objPos - lit.startPnt, lineVec)/lineLen2;");
    buf.writeln("   if(t <= 0.0) return lit.startPnt;");
    buf.writeln("   if(t >= 1.0) return lit.endPnt;");
    buf.writeln("   return lit.startPnt + t*lineVec;");
    buf.writeln("}");
    buf.writeln("");

    buf.writeln("vec3 ${name}Intensity(vec3 normDir, vec3 litPnt, $title lit)");
    buf.writeln("{");
    if (light.hasAttenuation) {
      buf.writeln("   float dist = length(objPos - litPnt);");
      buf.writeln("   float attenuation = 1.0/(lit.att0 + (lit.att1 + lit.att2*dist)*dist);");
      buf.writeln("   if(attenuation <= 0.005) return vec3(0.0, 0.0, 0.0);");
      buf.writeln("");
    }
    List<String> parts = [];
    parts.add("lit.color");
    if (light.hasAttenuation) parts.add("attenuation");
    buf.writeln("   return ${parts.join(" * ")};");
    buf.writeln("}");
    buf.writeln("");

    buf.writeln("vec3 ${name}Value(vec3 norm, $title lit)");
    buf.writeln("{");
    parts = [];
    if (cfg.ambient.hasAny) parts.add("ambientColor");
    if (cfg.intense) {
      buf.writeln("   vec3 highLight = vec3(0.0, 0.0, 0.0);");
      parts.add("highLight");

      buf.writeln("   vec3 litPnt  = ${name}ClosestPoint(lit);");
      buf.writeln("   vec3 litView = (viewMat*vec4(litPnt, 1.0)).xyz;");
      buf.writeln("   vec3 normDir = normalize(viewPos - litView);");

      // TODO: Determine a better way to do the bar light than using closest point.
      // It doesn't work when a normal is perpendicular to the plane when it should work.
      // It might need some kind of integration or faking it using the best angle.

      buf.writeln("   vec3 intensity = ${name}Intensity(normDir, litPnt, lit);");
      buf.writeln("   if(length(intensity) > 0.0001) {");
      final List<String> subparts = [];
      if (cfg.diffuse.hasAny) subparts.add("diffuse(norm, normDir)");
      if (cfg.invDiffuse.hasAny) subparts.add("invDiffuse(norm, normDir)");
      if (cfg.specular.hasAny) subparts.add("specular(norm, normDir)");
      buf.writeln("      highLight = intensity*(${subparts.join(" + ")});");
      buf.writeln("   }");
    }
    buf.writeln("   return lit.color*(${parts.join(" + ")});");
    buf.writeln("}");
    buf.writeln("");

    buf.writeln("vec3 all${title}Values(vec3 norm)");
    buf.writeln("{");
    buf.writeln("   vec3 lightAccum = vec3(0.0, 0.0, 0.0);");
    buf.writeln("   for(int i = 0; i < ${light.lightCount}; ++i)");
    buf.writeln("   {");
    buf.writeln("      if(i >= ${name}Count) break;");
    buf.writeln("      lightAccum += ${name}Value(norm, ${name}s[i]);");
    buf.writeln("   }");
    buf.writeln("   return lightAccum;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the directional lights to the fragment shader [buf].
  static void _writeDirLight(MaterialLightConfig cfg, DirectionalLightConfig light, StringBuffer buf) {
    if (light.lightCount <= 0) return;
    final String name = light.toString();
    final String title = toTitleCase(name);

    buf.writeln("// === $title ===");
    buf.writeln("");
    buf.writeln("struct $title");
    buf.writeln("{");
    if (light.hasTexture) {
      buf.writeln("   vec3 objUp;");
      buf.writeln("   vec3 objRight;");
      buf.writeln("   vec3 objDir;");
    }
    buf.writeln("   vec3 viewDir;");
    buf.writeln("   vec3 color;");
    buf.writeln("};");
    buf.writeln("");
    buf.writeln("uniform int ${name}Count;");
    buf.writeln("uniform $title ${name}s[${light.lightCount}];");
    if (light.colorTexture) {
      for (int i = 0; i < light.lightCount; i++) {
        buf.writeln("uniform sampler2D ${name}sTexture2D$i;");
      }
    }
    buf.writeln("");

    String params = "";
    if (light.colorTexture) params += ", sampler2D txt2D";
    buf.writeln("vec3 ${name}Value(vec3 norm, $title lit${params})");
    buf.writeln("{");
    final List<String> parts = [];
    if (cfg.ambient.hasAny) parts.add("ambientColor");
    if (cfg.intense) {
      buf.writeln("   vec3 highLight = vec3(0.0, 0.0, 0.0);");
      final List<String> subparts = [];
      if (cfg.diffuse.hasAny) subparts.add("diffuse(norm, lit.viewDir)");
      if (cfg.invDiffuse.hasAny) subparts.add("invDiffuse(norm, lit.viewDir)");
      if (cfg.specular.hasAny) subparts.add("specular(norm, lit.viewDir)");
      if (light.colorTexture) {
        buf.writeln("   vec3 offset = objPos + lit.objDir*dot(objPos, lit.objDir);");
        buf.writeln("   float tu = dot(offset, lit.objUp);");
        buf.writeln("   float tv = dot(offset, lit.objRight);");
        buf.writeln("   vec2 txtLoc = vec2(tu, tv);");
        buf.writeln("   vec3 intensity = texture2D(txt2D, txtLoc).xyz;");
        buf.writeln("   if(length(intensity) > 0.0001)");
        buf.writeln("      highLight = intensity*(${subparts.join(" + ")});");
      } else {
        buf.writeln("   highLight = ${subparts.join(" + ")};");
      }
      parts.add("highLight");
    }
    buf.writeln("   return lit.color*(${parts.join(" + ")});");
    buf.writeln("}");
    buf.writeln("");

    buf.writeln("vec3 all${title}Values(vec3 norm)");
    buf.writeln("{");
    buf.writeln("   vec3 lightAccum = vec3(0.0, 0.0, 0.0);");
    if (light.colorTexture) {
      for (int i = 0; i < light.lightCount; ++i) {
        buf.writeln("   if(${name}Count <= $i) return lightAccum;");
        buf.writeln("   lightAccum += ${name}Value(norm, ${name}s[$i], ${name}sTexture2D$i);");
      }
    } else {
      buf.writeln("   for(int i = 0; i < ${light.lightCount}; ++i)");
      buf.writeln("   {");
      buf.writeln("      if(i >= ${name}Count) break;");
      buf.writeln("      lightAccum += ${name}Value(norm, ${name}s[i]);");
      buf.writeln("   }");
    }
    buf.writeln("   return lightAccum;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the point lights to the fragment shader [buf].
  static void _writePointLight(MaterialLightConfig cfg, PointLightConfig light, StringBuffer buf) {
    if (light.lightCount <= 0) return;
    final String name = light.toString();
    final String title = toTitleCase(name);

    buf.writeln("// === ${title} ===");
    buf.writeln("");
    buf.writeln("struct ${title}");
    buf.writeln("{");
    buf.writeln("   vec3 point;");
    buf.writeln("   vec3 viewPnt;");
    buf.writeln("   vec3 color;");
    if (light.hasTexture) buf.writeln("   mat3 invViewRotMat;");
    if (light.shadowTexture) buf.writeln("   vec4 shadowAdj;");
    if (light.hasAttenuation) {
      buf.writeln("   float att0;");
      buf.writeln("   float att1;");
      buf.writeln("   float att2;");
    }
    buf.writeln("};");
    buf.writeln("");
    buf.writeln("uniform int ${name}Count;");
    buf.writeln("uniform ${title} ${name}s[${light.lightCount}];");
    if (light.colorTexture) {
      for (int i = 0; i < light.lightCount; i++) {
        buf.writeln("uniform samplerCube ${name}sTextureCube$i;");
      }
    }
    buf.writeln("");

    String params = "";
    if (light.colorTexture) params += ", samplerCube txtCube";
    if (light.shadowTexture) params += ", samplerCube shadowCube";
    buf.writeln("vec3 ${name}Intensity(vec3 normDir, $title lit$params)");
    buf.writeln("{");
    buf.writeln("   float dist = length(objPos - lit.point);");
    if (light.hasAttenuation) {
      buf.writeln("   float attenuation = 1.0/(lit.att0 + (lit.att1 + lit.att2*dist)*dist);");
      buf.writeln("   if(attenuation <= 0.005) return vec3(0.0, 0.0, 0.0);");
      buf.writeln("");
    }
    if (light.hasTexture) buf.writeln("   vec3 invNormDir = lit.invViewRotMat*normDir;");
    if (light.shadowTexture) {
      buf.writeln("   float depth = dot(textureCube(shadowCube, invNormDir), lit.shadowAdj);");
      buf.writeln("   float dist2 = (dist - 20.0) / (1.0 - 20.0);"); // TODO: Fix scaling
      buf.writeln("   if(depth > dist2) return vec3(0.0, 0.0, 0.0);");
      buf.writeln("");
    }
    List<String> parts = [];
    parts.add("lit.color");
    if (light.hasAttenuation) parts.add("attenuation");
    if (light.colorTexture) parts.add("textureCube(txtCube, invNormDir).rgb");
    buf.writeln("   return ${parts.join(" * ")};");
    buf.writeln("}");
    buf.writeln("");

    buf.writeln("vec3 ${name}Value(vec3 norm, $title lit$params)");
    buf.writeln("{");
    parts = [];
    if (cfg.ambient.hasAny) parts.add("ambientColor");
    if (cfg.intense) {
      buf.writeln("   vec3 highLight = vec3(0.0, 0.0, 0.0);");
      parts.add("highLight");

      params = "";
      if (light.colorTexture) params += ", txtCube";
      if (light.shadowTexture) params += ", shadowCube";
      buf.writeln("   vec3 normDir = normalize(viewPos - lit.viewPnt);");
      buf.writeln("   vec3 intensity = ${name}Intensity(normDir, lit$params);");
      buf.writeln("   if(length(intensity) > 0.0001) {");
      final List<String> subparts = [];
      if (cfg.diffuse.hasAny) subparts.add("diffuse(norm, normDir)");
      if (cfg.invDiffuse.hasAny) subparts.add("invDiffuse(norm, normDir)");
      if (cfg.specular.hasAny) subparts.add("specular(norm, normDir)");
      buf.writeln("      highLight = intensity*(${subparts.join(" + ")});");
      buf.writeln("   }");
    }
    buf.writeln("   return lit.color*(${parts.join(" + ")});");
    buf.writeln("}");
    buf.writeln("");

    buf.writeln("vec3 all${title}Values(vec3 norm)");
    buf.writeln("{");
    buf.writeln("   vec3 lightAccum = vec3(0.0, 0.0, 0.0);");
    if (light.hasTexture) {
      for (int i = 0; i < light.lightCount; ++i) {
        buf.writeln("   if(${name}Count <= $i) return lightAccum;");
        String params = "";
        if (light.colorTexture) params += ", ${name}sTextureCube$i";
        if (light.shadowTexture) params += ", ${name}sShadowCube$i";
        buf.writeln("   lightAccum += ${name}Value(norm, ${name}s[$i]$params);");
      }
    } else {
      buf.writeln("   for(int i = 0; i < ${light.lightCount}; ++i)");
      buf.writeln("   {");
      buf.writeln("      if(i >= ${name}Count) break;");
      buf.writeln("      lightAccum += ${name}Value(norm, ${name}s[i]);");
      buf.writeln("   }");
    }
    buf.writeln("   return lightAccum;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the spot lights to the fragment shader [buf].
  static void _writeSpotLight(MaterialLightConfig cfg, SpotLightConfig light, StringBuffer buf) {
    if (light.lightCount <= 0) return;
    final String name = light.toString();
    final String title = toTitleCase(name);

    buf.writeln("// === $title ===");
    buf.writeln("");
    buf.writeln("struct $title");
    buf.writeln("{");
    buf.writeln("   vec3 objPnt;");
    buf.writeln("   vec3 objDir;");
    buf.writeln("   vec3 viewPnt;");
    buf.writeln("   vec3 color;");
    if (light.hasTexture) {
      buf.writeln("   vec3 objUp;");
      buf.writeln("   vec3 objRight;");
      buf.writeln("   float tuScalar;");
      buf.writeln("   float tvScalar;");
    }
    if (light.shadowTexture) buf.writeln("   vec4 shadowAdj;");
    if (light.hasCutOff) {
      buf.writeln("   float cutoff;");
      buf.writeln("   float coneAngle;");
    }
    if (light.hasAttenuation) {
      buf.writeln("   float att0;");
      buf.writeln("   float att1;");
      buf.writeln("   float att2;");
    }
    buf.writeln("};");
    buf.writeln("");
    buf.writeln("uniform int ${name}Count;");
    buf.writeln("uniform $title ${name}s[${light.lightCount}];");
    if (light.colorTexture) {
      for (int i = 0; i < light.lightCount; i++) {
        buf.writeln("uniform sampler2D ${name}sTexture2D$i;");
      }
    }
    if (light.shadowTexture) {
      for (int i = 0; i < light.lightCount; i++) {
        buf.writeln("uniform sampler2D ${name}sShadow2D$i;");
      }
    }
    buf.writeln("");

    String params = "";
    if (light.colorTexture) params += ", sampler2D txt2D";
    if (light.shadowTexture) params += ", sampler2D shadow2D";
    buf.writeln("vec3 ${name}Intensity($title lit$params)");
    buf.writeln("{");
    buf.writeln("   vec3 dir = objPos - lit.objPnt;");
    if (light.hasDist) buf.writeln("   float dist = length(dir);");
    if (light.hasAttenuation) {
      buf.writeln("   float attenuation = 1.0/(lit.att0 + (lit.att1 + lit.att2*dist)*dist);");
      buf.writeln("   if(attenuation <= 0.005) return vec3(0.0, 0.0, 0.0);");
      buf.writeln("");
    }
    buf.writeln("   vec3 normDir = normalize(dir);");
    buf.writeln("   float zScale = dot(normDir, lit.objDir);");
    buf.writeln("   if(zScale < 0.0) return vec3(0.0, 0.0, 0.0);");
    if (light.hasCutOff) {
      // On some Mac's `acos` doesn't work correctly so use the `atan` equivalent.
      if (Environment.os == OperatingSystem.mac) {
        buf.writeln("   float crossMag = length(cross(normDir, lit.objDir));");
        buf.writeln("   float angle = atan(crossMag, zScale);");
      } else {
        buf.writeln("   float angle = acos(zScale);");
      }
      buf.writeln("   float scale = (lit.cutoff-angle) / (lit.cutoff-lit.coneAngle);");
      buf.writeln("   if(scale <= 0.0) return vec3(0.0, 0.0, 0.0);");
      buf.writeln("   if(scale >= 1.0) scale = 1.0;");
      buf.writeln("");
    }
    if (light.hasTexture) {
      buf.writeln("   normDir = normDir / zScale;");
      buf.writeln("   float tu = 0.5 - dot(normDir, lit.objRight)*lit.tuScalar;");
      buf.writeln("   if((tu < 0.0) || (tu > 1.0)) return vec3(0.0, 0.0, 0.0);");
      buf.writeln("   float tv = dot(normDir, lit.objUp)*lit.tvScalar + 0.5;");
      buf.writeln("   if((tv < 0.0) || (tv > 1.0)) return vec3(0.0, 0.0, 0.0);");
      buf.writeln("   vec2 txtLoc = vec2(tu, tv);");
      buf.writeln("");
    }
    if (light.shadowTexture) {
      buf.writeln("   float depth = dot(texture2D(shadow2D, vec2(txtLoc.x, 1.0-txtLoc.y)), lit.shadowAdj);");
      buf.writeln("   float dist2 = (dist - 20.0) / (1.0 - 20.0);"); // TODO: Fix scaling
      buf.writeln("   if(depth > dist2) return vec3(0.0, 0.0, 0.0);");
      buf.writeln("");
    }
    List<String> parts = [];
    if (light.hasAttenuation) parts.add("attenuation");
    if (light.hasCutOff) parts.add("scale");
    if (light.colorTexture) {
      parts.add("texture2D(txt2D, txtLoc).rgb");
    } else {
      parts.add("vec3(1.0, 1.0, 1.0)");
    }
    buf.writeln("   return ${parts.join(" * ")};");
    buf.writeln("}");
    buf.writeln("");

    buf.writeln("vec3 ${name}Value(vec3 norm, $title lit$params)");
    buf.writeln("{");
    parts = [];
    if (cfg.ambient.hasAny) parts.add("ambientColor");
    if (cfg.intense) {
      buf.writeln("   vec3 highLight = vec3(0.0, 0.0, 0.0);");
      parts.add("highLight");

      params = "";
      if (light.colorTexture) params += ", txt2D";
      if (light.shadowTexture) params += ", shadow2D";
      buf.writeln("   vec3 intensity = ${name}Intensity(lit$params);");
      buf.writeln("   if(length(intensity) > 0.0001) {");
      buf.writeln("      vec3 litVec = normalize(viewPos - lit.viewPnt);");
      final List<String> subparts = [];
      if (cfg.diffuse.hasAny) subparts.add("diffuse(norm, litVec)");
      if (cfg.invDiffuse.hasAny) subparts.add("invDiffuse(norm, litVec)");
      if (cfg.specular.hasAny) subparts.add("specular(norm, litVec)");
      buf.writeln("      highLight = intensity*(${subparts.join(" + ")});");
      buf.writeln("   }");
    }

    buf.writeln("   return lit.color*(${parts.join(" + ")});");
    buf.writeln("}");
    buf.writeln("");

    buf.writeln("vec3 all${title}Values(vec3 norm)");
    buf.writeln("{");
    buf.writeln("   vec3 lightAccum = vec3(0.0, 0.0, 0.0);");
    if (light.hasTexture) {
      for (int i = 0; i < light.lightCount; ++i) {
        buf.writeln("   if(${name}Count <= $i) return lightAccum;");
        String params = "";
        if (light.colorTexture) params += ", ${name}sTexture2D$i";
        if (light.shadowTexture) params += ", ${name}sShadow2D$i";
        buf.writeln("   lightAccum += ${name}Value(norm, ${name}s[$i]$params);");
      }
    } else {
      buf.writeln("   for(int i = 0; i < ${light.lightCount}; ++i)");
      buf.writeln("   {");
      buf.writeln("      if(i >= ${name}Count) break;");
      buf.writeln("      lightAccum += ${name}Value(norm, ${name}s[i]);");
      buf.writeln("   }");
    }
    buf.writeln("   return lightAccum;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the no lights code to the fragment shader [buf].
  static void _writeNoLight(MaterialLightConfig cfg, StringBuffer buf) {
    if (cfg.totalLights > 0) return;
    buf.writeln("// === No Lights ===");
    buf.writeln("");
    buf.writeln("vec3 nonLightValues(vec3 norm)");
    buf.writeln("{");
    if (cfg.intense) buf.writeln("   vec3 litVec = vec3(0.0, 0.0, 1.0);");
    final List<String> parts = [];
    if (cfg.ambient.hasAny) parts.add("ambientColor");
    if (cfg.diffuse.hasAny) parts.add("diffuse(norm, litVec)");
    if (cfg.invDiffuse.hasAny) parts.add("invDiffuse(norm, litVec)");
    if (cfg.specular.hasAny) parts.add("specular(norm, litVec)");
    buf.writeln("   return ${parts.join(" + ")};");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Creates the fragment source code for the material light shader for the given configurations.
  static String createFragmentSource(MaterialLightConfig cfg) {
    final StringBuffer buf = StringBuffer();
    buf.writeln("precision mediump float;");
    buf.writeln("");

    if (cfg.norm) buf.writeln("varying vec3 normalVec;");
    if (cfg.binm) buf.writeln("varying vec3 binormalVec;");
    if (cfg.txt2D) buf.writeln("varying vec2 txt2D;");
    if (cfg.txtCube) buf.writeln("varying vec3 txtCube;");
    if (cfg.objPos) buf.writeln("varying vec3 objPos;");
    if (cfg.viewPos) buf.writeln("varying vec3 viewPos;");
    buf.writeln("");

    if (cfg.colorMat) buf.writeln("uniform mat4 colorMat;");
    if (cfg.viewMat) buf.writeln("uniform mat4 viewMat;");
    if (cfg.invViewMat) buf.writeln("uniform mat4 invViewMat;");
    if (cfg.fog) {
      buf.writeln("uniform vec4 fogColor;");
      buf.writeln("uniform float fogStop;");
      buf.writeln("uniform float fogWidth;");
    }
    buf.writeln("");

    _writeEmission(cfg, buf);
    _writeAmbient(cfg, buf);
    _writeDiffuse(cfg, buf);
    _writeInvDiffuse(cfg, buf);
    _writeSpecular(cfg, buf);
    if (cfg.environmental) {
      buf.writeln("// === Environmental ===");
      buf.writeln("");
      buf.writeln("uniform samplerCube envSampler;");
      buf.writeln("");
      _writeReflection(cfg, buf);
      _writeRefraction(cfg, buf);
    }
    _writeNormal(cfg, buf);
    _writeAlpha(cfg, buf);

    if (cfg.lights) {
      for (final BarLightConfig light in cfg.barLights) {
        _writeBarLight(cfg, light, buf);
      }

      for (final DirectionalLightConfig light in cfg.dirLights) {
        _writeDirLight(cfg, light, buf);
      }

      for (final PointLightConfig light in cfg.pointLights) {
        _writePointLight(cfg, light, buf);
      }

      for (final SpotLightConfig light in cfg.spotLights) {
        _writeSpotLight(cfg, light, buf);
      }

      _writeNoLight(cfg, buf);
    }

    buf.writeln("// === Main ===");
    buf.writeln("");
    buf.writeln("void main()");
    buf.writeln("{");
    buf.writeln("   float alpha = alphaValue();");
    if (cfg.norm) buf.writeln("   vec3 norm = normal();");
    if (cfg.environmental) {
      buf.writeln("   vec3 refl = reflect(normalize(viewPos), norm);");
    }
    final List<String> fragParts = [];
    if (cfg.lights) {
      buf.writeln("   vec3 lightAccum = vec3(0.0, 0.0, 0.0);");
      fragParts.add("lightAccum");
      if (cfg.ambient.hasAny) buf.writeln("   setAmbientColor();");
      if (cfg.diffuse.hasAny) buf.writeln("   setDiffuseColor();");
      if (cfg.invDiffuse.hasAny) buf.writeln("   setInvDiffuseColor();");
      if (cfg.specular.hasAny) buf.writeln("   setSpecularColor();");

      for (final BarLightConfig light in cfg.barLights) {
        final String title = toTitleCase(light.toString());
        buf.writeln("   lightAccum += all${title}Values(norm);");
      }

      for (final DirectionalLightConfig light in cfg.dirLights) {
        final String title = toTitleCase(light.toString());
        buf.writeln("   lightAccum += all${title}Values(norm);");
      }

      for (final PointLightConfig light in cfg.pointLights) {
        final String title = toTitleCase(light.toString());
        buf.writeln("   lightAccum += all${title}Values(norm);");
      }

      for (final SpotLightConfig light in cfg.spotLights) {
        final String title = toTitleCase(light.toString());
        buf.writeln("   lightAccum += all${title}Values(norm);");
      }

      if (cfg.totalLights <= 0) buf.writeln("   lightAccum += nonLightValues(norm);");
    }
    if (cfg.emission.hasAny) fragParts.add("emissionColor()");
    if (cfg.reflection.hasAny) fragParts.add("reflect(refl)");
    if (cfg.refraction.hasAny) fragParts.add("refract(refl)");
    if (fragParts.isEmpty) fragParts.add("vec3(0.0, 0.0, 0.0)");
    buf.writeln("   vec4 objClr = vec4(" + fragParts.join(" + ") + ", alpha);");
    if (cfg.colorMat) buf.writeln("   objClr = colorMat*objClr;");
    if (cfg.fog) {
      buf.writeln("   float fogFactor = (viewPos.z-fogStop) / fogWidth;");
      buf.writeln("   objClr = mix(fogColor, objClr, clamp(fogFactor, 0.0, 1.0));");
    }
    buf.writeln("   gl_FragColor = objClr;");
    buf.writeln("}");

    final String result = buf.toString();
    //print(numberLines(result));
    return result;
  }
}

/// Bar light uniform.
class UniformBarLight {
  /// Creates the bar light uniform.
  UniformBarLight._(this._index, this._startPnt, this._endPnt, this._color,
      this._att0, this._att1, this._att2);

  /// The index of this light in the list of point lights.
  int get index => this._index;
  final int _index;

  /// The point of the bars light's start location transformed by the object matrix.
  Point3 get startPoint => this._startPnt?.getPoint3() ?? Point3.zero;

  set startPoint(Point3 pnt) => this._startPnt?.setPoint3(pnt);
  final Uniform3f? _startPnt;

  /// The point of the bars light's end location transformed by the object matrix.
  Point3 get endPoint => this._endPnt?.getPoint3() ?? Point3.zero;

  set endPoint(Point3 pnt) => this._endPnt?.setPoint3(pnt);
  final Uniform3f? _endPnt;

  /// The bar light color.
  Color3 get color => this._color?.getColor3() ?? Color3.white();

  set color(Color3 clr) => this._color?.setColor3(clr);
  final Uniform3f? _color;

  /// The bar light constant attenuation.
  double get attenuation0 => this._att0?.getValue() ?? 1.0;

  set attenuation0(double att) => this._att0?.setValue(att);
  final Uniform1f? _att0;

  /// The bar light linear attenuation.
  double get attenuation1 => this._att1?.getValue() ?? 0.0;

  set attenuation1(double att) => this._att1?.setValue(att);
  final Uniform1f? _att1;

  /// The bar light quadratic attenuation.
  double get attenuation2 => this._att2?.getValue() ?? 0.0;

  set attenuation2(double att) => this._att2?.setValue(att);
  final Uniform1f? _att2;
}

/// Directional light uniform.
class UniformDirectionalLight {
  /// Creates the directional light uniform.
  UniformDirectionalLight._(this._index, this._objUp, this._objRight, this._objDir,
      this._viewDir, this._color, this._txt);

  /// The index of this light in the list of directional lights.
  int get index => this._index;
  final int _index;

  /// The directional light's up.
  Vector3 get objectUp => this._objUp?.getVector3() ?? Vector3.zero;

  set objectUp(Vector3 vec) => this._objUp?.setVector3(vec);
  final Uniform3f? _objUp;

  /// The directional light's right.
  Vector3 get objectRight => this._objRight?.getVector3() ?? Vector3.zero;

  set objectRight(Vector3 vec) => this._objRight?.setVector3(vec);
  final Uniform3f? _objRight;

  /// The directional light's direction.
  Vector3 get objectDir => this._objDir?.getVector3() ?? Vector3.zero;

  set objectDir(Vector3 vec) => this._objDir?.setVector3(vec);
  final Uniform3f? _objDir;

  /// The directional light's direction transformed by the view matrix.
  Vector3 get viewDir => this._viewDir?.getVector3() ?? Vector3.zero;

  set viewDir(Vector3 vec) => this._viewDir?.setVector3(vec);
  final Uniform3f? _viewDir;

  /// The directional light color.
  Color3 get color => this._color?.getColor3() ?? Color3.white();

  set color(Color3 clr) => this._color?.setColor3(clr);
  final Uniform3f? _color;

  /// The directional light texture.
  set texture(Texture2D? txt) {
    if ((txt != null) && txt.loaded) this._txt?.setTexture2D(txt);
  }

  final UniformSampler2D? _txt;
}

/// Point light uniform.
class UniformPointLight {
  /// Creates the point light uniform.
  UniformPointLight._(
      this._index,
      this._point,
      this._viewPnt,
      this._invViewRotMat,
      this._color,
      this._txt,
      this._shadow,
      this._shadowAdj,
      this._att0,
      this._att1,
      this._att2);

  /// The index of this light in the list of point lights.
  int get index => this._index;
  final int _index;

  /// The point light's location transformed by the object matrix.
  Point3 get point => this._point?.getPoint3() ?? Point3.zero;

  set point(Point3 pnt) => this._point?.setPoint3(pnt);
  final Uniform3f? _point;

  /// The point light's location transformed by the view matrix.
  Point3 get viewPoint => this._viewPnt?.getPoint3() ?? Point3.zero;

  set viewPoint(Point3 pnt) => this._viewPnt?.setPoint3(pnt);
  final Uniform3f? _viewPnt;

  /// The texture point light's rotation transformed by the inverse view matrix.
  Matrix3 get inverseViewRotationMatrix => this._invViewRotMat?.getMatrix3() ?? Matrix3.identity;

  set inverseViewRotationMatrix(Matrix3 mat) => this._invViewRotMat?.setMatrix3(mat);
  final UniformMat3? _invViewRotMat;

  /// The point light color.
  Color3 get color => this._color?.getColor3() ?? Color3.white();

  set color(Color3 clr) => this._color?.setColor3(clr);
  final Uniform3f? _color;

  /// The point light color texture.
  set texture(TextureCube? txt) {
    if ((txt != null) && txt.loaded) this._txt?.setTextureCube(txt);
  }

  final UniformSamplerCube? _txt;

  /// The point light shadow depth texture.
  set shadow(TextureCube? txt) {
    if ((txt != null) && txt.loaded) this._shadow?.setTextureCube(txt);
  }

  final UniformSamplerCube? _shadow;

  /// The spot light shadow depths adjustment vector.
  Vector4 get shadowAdjust => this._shadowAdj?.getVector4() ?? Vector4.zero;

  set shadowAdjust(Vector4 adj) => this._shadowAdj?.setVector4(adj);
  final Uniform4f? _shadowAdj;

  /// The point light constant attenuation.
  double get attenuation0 => this._att0?.getValue() ?? 0.0;

  set attenuation0(double att) => this._att0?.setValue(att);
  final Uniform1f? _att0;

  /// The point light linear attenuation.
  double get attenuation1 => this._att1?.getValue() ?? 0.0;

  set attenuation1(double att) => this._att1?.setValue(att);
  final Uniform1f? _att1;

  /// The point light quadratic attenuation.
  double get attenuation2 => this._att2?.getValue() ?? 0.0;

  set attenuation2(double att) => this._att2?.setValue(att);
  final Uniform1f? _att2;
}

/// Spot light uniform.
class UniformSpotLight {
  /// Creates the spot light uniform.
  UniformSpotLight._(
      this._index,
      this._objPnt,
      this._objDir,
      this._viewPnt,
      this._color,
      this._objUp,
      this._objRight,
      this._tuScalar,
      this._tvScalar,
      this._shadowAdj,
      this._cutoff,
      this._coneAngle,
      this._att0,
      this._att1,
      this._att2,
      this._txt,
      this._shadow);

  /// The index of this light in the list of spot lights.
  int get index => this._index;
  final int _index;

  /// The spot light's location transformed by the object matrix.
  Point3 get objectPoint => this._objPnt?.getPoint3() ?? Point3.zero;

  set objectPoint(Point3 pnt) => this._objPnt?.setPoint3(pnt);
  final Uniform3f? _objPnt;

  /// The directional light's direction.
  Vector3 get objectDirection => this._objDir?.getVector3() ?? Vector3.zero;

  set objectDirection(Vector3 vec) => this._objDir?.setVector3(vec);
  final Uniform3f? _objDir;

  /// The spot light's location transformed by the view matrix.
  Point3 get viewPoint => this._viewPnt?.getPoint3() ?? Point3.zero;

  set viewPoint(Point3 pnt) => this._viewPnt?.setPoint3(pnt);
  final Uniform3f? _viewPnt;

  /// The spot light color.
  Color3 get color => this._color?.getColor3() ?? Color3.white();

  set color(Color3 clr) => this._color?.setColor3(clr);
  final Uniform3f? _color;

  /// The spot light's up.
  Vector3 get objectUp => this._objUp?.getVector3() ?? Vector3.zero;

  set objectUp(Vector3 vec) => this._objUp?.setVector3(vec);
  final Uniform3f? _objUp;

  /// The spot light's right.
  Vector3 get objectRight => this._objRight?.getVector3() ?? Vector3.zero;

  set objectRight(Vector3 vec) => this._objRight?.setVector3(vec);
  final Uniform3f? _objRight;

  /// The spot light's horizontal scalar.
  double get tuScalar => this._tuScalar?.getValue() ?? 1.0;

  set tuScalar(double tuScalar) => this._tuScalar?.setValue(tuScalar);
  final Uniform1f? _tuScalar;

  /// The spot light's vertical scalar.
  double get tvScalar => this._tvScalar?.getValue() ?? 1.0;

  set tvScalar(double tvScalar) => this._tvScalar?.setValue(tvScalar);
  final Uniform1f? _tvScalar;

  /// The spot light shadow depths adjustment vector.
  Vector4 get shadowAdjust => this._shadowAdj?.getVector4() ?? Vector4.zero;

  set shadowAdjust(Vector4 adj) => this._shadowAdj?.setVector4(adj);
  final Uniform4f? _shadowAdj;

  /// The spot light cut-off, in radians.
  double get cutoff => this._cutoff?.getValue() ?? 1.0;

  set cutoff(double cutoff) => this._cutoff?.setValue(cutoff);
  final Uniform1f? _cutoff;

  /// The spot light cone angle, in radians.
  double get coneAngle => this._coneAngle?.getValue() ?? 1.0;

  set coneAngle(double coneAngle) => this._coneAngle?.setValue(coneAngle);
  final Uniform1f? _coneAngle;

  /// The spot light constant attenuation.
  double get attenuation0 => this._att0?.getValue() ?? 1.0;

  set attenuation0(double att) => this._att0?.setValue(att);
  final Uniform1f? _att0;

  /// The spot light linear attenuation.
  double get attenuation1 => this._att1?.getValue() ?? 0.0;

  set attenuation1(double att) => this._att1?.setValue(att);
  final Uniform1f? _att1;

  /// The spot light quadratic attenuation.
  double get attenuation2 => this._att2?.getValue() ?? 0.0;

  set attenuation2(double att) => this._att2?.setValue(att);
  final Uniform1f? _att2;

  /// The spot light texture.
  set texture(Texture2D? txt) {
    if ((txt != null) && txt.loaded) this._txt?.setTexture2D(txt);
  }

  final UniformSampler2D? _txt;

  /// The spot light shadow depth texture.
  set shadow(Texture2D? txt) {
    if ((txt != null) && txt.loaded) this._shadow?.setTexture2D(txt);
  }

  final UniformSampler2D? _shadow;
}

/// The vertex shader writer for rendering material light.
class _materialLightVS {
  /// Writes variables for the vertex shader [buf].
  static void _writeVariables(MaterialLightConfig cfg, StringBuffer buf) {
    if (cfg.objMat) buf.writeln("uniform mat4 objMat;");
    if (cfg.viewObjMat) buf.writeln("uniform mat4 viewObjMat;");
    buf.writeln("uniform mat4 projViewObjMat;");
    buf.writeln("");
    buf.writeln("attribute vec3 posAttr;");
    if (cfg.norm) buf.writeln("attribute vec3 normAttr;");
    if (cfg.binm) buf.writeln("attribute vec3 binmAttr;");
    buf.writeln("");
  }

  /// Writes vertex bending method for the vertex shader [buf].
  static void _writeBendSetup(MaterialLightConfig cfg, StringBuffer buf) {
    if (!cfg.bending) return;
    buf.writeln("struct BendingValue");
    buf.writeln("{");
    buf.writeln("   mat4 mat;");
    buf.writeln("};");
    buf.writeln("uniform int bendMatCount;");
    buf.writeln("uniform BendingValue bendValues[${cfg.bendMats}];");
    buf.writeln("attribute vec4 bendAttr;");
    buf.writeln("");
    buf.writeln("float weightSum;");
    buf.writeln("vec3 bendPos;");
    if (cfg.norm) buf.writeln("vec3 bendNorm;");
    if (cfg.binm) buf.writeln("vec3 bendBinm;");
    buf.writeln("");
    buf.writeln("void adjustBend(float bendVal)");
    buf.writeln("{");
    buf.writeln("   if(bendVal >= 0.0)");
    buf.writeln("   {");
    buf.writeln("      int index = int(floor((bendVal + 0.5)*0.5));");
    buf.writeln("      if(index < bendMatCount)");
    buf.writeln("      {");
    buf.writeln("         float weight = clamp(bendVal - float(index)*2.0, 0.0, 1.0);");
    buf.writeln("         mat4 m = bendValues[index].mat;");
    buf.writeln("         weightSum += weight;");
    buf.writeln("         bendPos += (m*vec4(posAttr, 1.0)).xyz*weight;");
    if (cfg.norm) buf.writeln("         bendNorm += (m*vec4(normAttr, 0.0)).xyz*weight;");
    if (cfg.binm) buf.writeln("         bendBinm += (m*vec4(binmAttr, 0.0)).xyz*weight;");
    buf.writeln("      }");
    buf.writeln("   }");
    buf.writeln("}");
    buf.writeln("");
    buf.writeln("void setupBendData()");
    buf.writeln("{");
    buf.writeln("   bendPos = vec3(0.0, 0.0, 0.0);");
    if (cfg.norm) buf.writeln("   bendNorm = vec3(0.0, 0.0, 0.0);");
    if (cfg.binm) buf.writeln("   bendBinm = vec3(0.0, 0.0, 0.0);");
    buf.writeln("   weightSum = 0.0;");
    buf.writeln("   adjustBend(bendAttr.x);");
    buf.writeln("   adjustBend(bendAttr.y);");
    buf.writeln("   adjustBend(bendAttr.z);");
    buf.writeln("   adjustBend(bendAttr.w);");
    buf.writeln("   if(weightSum < 1.0)");
    buf.writeln("   {");
    buf.writeln("      float weight = 1.0 - weightSum;");
    buf.writeln("      bendPos += posAttr*weight;");
    if (cfg.norm) buf.writeln("      bendNorm += normAttr*weight;");
    if (cfg.binm) buf.writeln("      bendBinm += binmAttr*weight;");
    buf.writeln("   }");
    buf.writeln("   else");
    buf.writeln("   {");
    buf.writeln("      bendPos = bendPos/weightSum;");
    buf.writeln("   }");
    if (cfg.norm) buf.writeln("   bendNorm = normalize(bendNorm);");
    if (cfg.binm) buf.writeln("   bendBinm = normalize(bendBinm);");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes normal coordinates for the vertex shader [buf].
  static void _writeNormCoord(MaterialLightConfig cfg, StringBuffer buf) {
    if (!cfg.norm) return;
    buf.writeln("varying vec3 normalVec;");
    buf.writeln("");
    buf.writeln("vec3 getNorm()");
    buf.writeln("{");
    final String normAttr = (cfg.bending) ? "bendNorm" : "normAttr";
    buf.writeln("   return normalize((viewObjMat*vec4($normAttr, 0.0)).xyz);");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes binormal coordinates for the vertex shader [buf].
  static void _writeBinmCoord(MaterialLightConfig cfg, StringBuffer buf) {
    if (!cfg.binm) return;
    buf.writeln("varying vec3 binormalVec;");
    buf.writeln("");
    buf.writeln("vec3 getBinm()");
    buf.writeln("{");
    final String binmAttr = (cfg.bending) ? "bendBinm" : "binmAttr";
    buf.writeln("   return normalize((viewObjMat*vec4($binmAttr, 0.0)).xyz);");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes texture 2D coordinates for the vertex shader [buf].
  static void _writeTxt2DCoord(MaterialLightConfig cfg, StringBuffer buf) {
    if (!cfg.txt2D) return;
    if (cfg.txt2DMat) buf.writeln("uniform mat3 txt2DMat;");
    buf.writeln("attribute vec2 txt2DAttr;");
    buf.writeln("varying vec2 txt2D;");
    buf.writeln("");
    buf.writeln("vec2 getTxt2D()");
    buf.writeln("{");
    if (cfg.txt2DMat) {
      buf.writeln("   return (txt2DMat*vec3(txt2DAttr, 1.0)).xy;");
    } else {
      buf.writeln("   return txt2DAttr;");
    }
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes texture Cube coordinates for the vertex shader [buf].
  static void _writeTxtCubeCoord(MaterialLightConfig cfg, StringBuffer buf) {
    if (!cfg.txtCube) return;
    if (cfg.txtCubeMat) buf.writeln("uniform mat4 txtCubeMat;");
    buf.writeln("attribute vec3 txtCubeAttr;");
    buf.writeln("varying vec3 txtCube;");
    buf.writeln("");
    buf.writeln("vec3 getTxtCube()");
    buf.writeln("{");
    if (cfg.txtCubeMat) {
      buf.writeln("   return (txtCubeMat*vec4(txtCubeAttr, 1.0)).xyz;");
    } else {
      buf.writeln("   return txtCubeAttr;");
    }
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes object position for the vertex shader [buf].
  static void _writeObjPos(MaterialLightConfig cfg, StringBuffer buf) {
    if (!cfg.objPos) return;
    buf.writeln("varying vec3 objPos;");
    buf.writeln("");
    buf.writeln("vec3 getObjPos()");
    buf.writeln("{");
    final String posAttr = (cfg.bending) ? "bendPos" : "posAttr";
    buf.writeln("   return (objMat*vec4($posAttr, 1.0)).xyz;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes view object position for the vertex shader [buf].
  static void _writeViewPos(MaterialLightConfig cfg, StringBuffer buf) {
    if (!cfg.viewPos) return;
    buf.writeln("varying vec3 viewPos;");
    buf.writeln("");
    buf.writeln("vec3 getViewPos()");
    buf.writeln("{");
    final String posAttr = (cfg.bending) ? "bendPos" : "posAttr";
    buf.writeln("   return (viewObjMat*vec4($posAttr, 1.0)).xyz;");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes projected object position for the vertex shader [buf].
  static void _writePos(MaterialLightConfig cfg, StringBuffer buf) {
    buf.writeln("vec4 getPos()");
    buf.writeln("{");
    final String posAttr = (cfg.bending) ? "bendPos" : "posAttr";
    buf.writeln("   return projViewObjMat*vec4($posAttr, 1.0);");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Writes the non-bending main method for the vertex shader [buf].
  static void _writeMain(MaterialLightConfig cfg, StringBuffer buf) {
    buf.writeln("void main()");
    buf.writeln("{");
    if (cfg.bending) buf.writeln("   setupBendData();");
    if (cfg.norm) buf.writeln("   normalVec = getNorm();");
    if (cfg.binm) buf.writeln("   binormalVec = getBinm();");
    if (cfg.txt2D) buf.writeln("   txt2D = getTxt2D();");
    if (cfg.txtCube) buf.writeln("   txtCube = getTxtCube();");
    if (cfg.objPos) buf.writeln("   objPos = getObjPos();");
    if (cfg.viewPos) buf.writeln("   viewPos = getViewPos();");
    buf.writeln("   gl_Position = getPos();");
    buf.writeln("}");
    buf.writeln("");
  }

  /// Creates the vertex source code for the material light shader for the given configurations.
  static String createVertexSource(MaterialLightConfig cfg) {
    final StringBuffer buf = StringBuffer();
    _writeVariables(cfg, buf);
    _writeBendSetup(cfg, buf);
    _writeNormCoord(cfg, buf);
    _writeBinmCoord(cfg, buf);
    _writeTxt2DCoord(cfg, buf);
    _writeTxtCubeCoord(cfg, buf);
    _writeObjPos(cfg, buf);
    _writeViewPos(cfg, buf);
    _writePos(cfg, buf);
    _writeMain(cfg, buf);
    return buf.toString();
  }
}

/// A shader for rendering the normals.
class Normal extends Shader {
  NormalConfig _cfg;

  Attribute? _posAttr;
  Attribute? _binmAttr;
  Attribute? _normAttr;
  Attribute? _txt2DAttr;
  Attribute? _txtCubeAttr;

  UniformMat4? _viewObjMat;
  UniformMat4? _projViewObjMat;
  UniformMat3? _txt2DMat;
  UniformMat4? _txtCubeMat;

  UniformSampler2D? _bump2D;
  UniformSamplerCube? _bumpCube;

  /// Compiles this shader for the given rendering context.
  Normal(this._cfg, webgl.RenderingContext2 gl) : super(gl, _cfg.name) {
    final String vertexSource = this._cfg.createVertexSource();
    final String fragmentSource = this._cfg.createFragmentSource();
    // print(this._cfg.toString());
    // print(numberLines(vertexSource));
    // print(numberLines(fragmentSource));
    this.initialize(vertexSource, fragmentSource);
    this._posAttr = this.attributes["posAttr"];
    this._normAttr = this.attributes["normAttr"];
    this._binmAttr = this.attributes["binmAttr"];
    this._txt2DAttr = this.attributes["txt2DAttr"];
    this._txtCubeAttr = this.attributes["txtCubeAttr"];
    // print(numberLines(this.uniforms.toString()));
    this._viewObjMat = this.uniforms.required("viewObjMat") as UniformMat4;
    this._projViewObjMat = this.uniforms.required("projViewObjMat") as UniformMat4;
    if (this._cfg.txt2D) this._txt2DMat = this.uniforms.required("txt2DMat") as UniformMat3;
    if (this._cfg.txtCube) this._txtCubeMat = this.uniforms.required("txtCubeMat") as UniformMat4;
    if (this._cfg.bumpy.hasTxt2D) {
      this._bump2D = this.uniforms.required("bumpTxt") as UniformSampler2D;
    } else if (this._cfg.bumpy.hasTxtCube) {
      this._bumpCube = this.uniforms.required("bumpTxt") as UniformSamplerCube;
    }
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory Normal.cached(NormalConfig cfg, RenderState state) {
    Normal? shader = state.shader(cfg.name) as Normal?;
    if (shader == null) {
      shader = Normal(cfg, state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// Sets the texture 2D and null texture indicator for the shader.
  void _setTexture2D(UniformSampler2D? txt2D, Texture2D? txt) {
    if ((txt != null) && txt.loaded) txt2D?.setTexture2D(txt);
  }

  /// Sets the texture cube and null texture indicator for the shader.
  void _setTextureCube(UniformSamplerCube? txtCube, TextureCube? txt) {
    if ((txt != null) && txt.loaded) txtCube?.setTextureCube(txt);
  }

  /// The configuration the shader is built for.
  NormalConfig get configuration => this._cfg;

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// The normal vertex shader attribute.
  Attribute? get normAttr => this._normAttr;

  /// The binormal vertex shader attribute.
  Attribute? get binmAttr => this._binmAttr;

  /// The texture 2D vertex shader attribute.
  Attribute? get txt2DAttr => this._txt2DAttr;

  /// The texture Cube vertex shader attribute.
  Attribute? get txtCubeAttr => this._txtCubeAttr;

  /// The view matrix multiplied by the object matrix.
  Matrix4 get viewObjectMatrix => this._viewObjMat?.getMatrix4() ?? Matrix4.identity;

  set viewObjectMatrix(Matrix4 mat) => this._viewObjMat?.setMatrix4(mat);

  /// The product of the projection matrix, view matrix, and object matrix.
  Matrix4 get projectViewObjectMatrix => this._projViewObjMat?.getMatrix4() ?? Matrix4.identity;

  set projectViewObjectMatrix(Matrix4 mat) => this._projViewObjMat?.setMatrix4(mat);

  /// The 2D texture modification matrix.
  Matrix3 get texture2DMatrix => this._txt2DMat?.getMatrix3() ?? Matrix3.identity;

  set texture2DMatrix(Matrix3 mat) => this._txt2DMat?.setMatrix3(mat);

  /// The cube texture modification matrix.
  Matrix4 get textureCubeMatrix => this._txtCubeMat?.getMatrix4() ?? Matrix4.identity;

  set textureCubeMatrix(Matrix4 mat) => this._txtCubeMat?.setMatrix4(mat);

  /// The normal distortion texture 2D of the object.
  set bumpTexture2D(Texture2D txt) => this._setTexture2D(this._bump2D, txt);

  /// The normal distortion texture cube of the object.
  set bumpTextureCube(TextureCube txt) => this._setTextureCube(this._bumpCube, txt);
}

/// The shader configuration for rendering solid color light.
class NormalConfig {
  /// The normal distortion color source type.
  final ColorSourceType bumpy;

  /// Indicates the binormal vector is needed by the fragment shader.
  final bool binm;

  /// Indicates the 2D texture coordinate is needed by the fragment shader.
  final bool txt2D;

  /// Indicates the cube texture coordinate is needed by the fragment shader.
  final bool txtCube;

  /// The name of this shader configuration.
  final String name;

  /// The vertex type required from shapes to be drawn using this shader.
  final VertexType vertexType;

  /// Creates a new normal configuration.
  /// The configuration for the normal shader.
  factory NormalConfig(ColorSourceType bumpy) {
    final bool binm = bumpy.hasAny;
    final bool txt2D = bumpy.hasTxt2D;
    final bool txtCube = bumpy.hasTxtCube;

    final String name = "Normal_${bumpy.toString()}";

    VertexType vertexType = VertexType.Pos | VertexType.Norm;
    if (binm) vertexType |= VertexType.Binm;
    if (txt2D) vertexType |= VertexType.Txt2D;
    if (txtCube) vertexType |= VertexType.TxtCube;

    return NormalConfig._(bumpy, binm, txt2D, txtCube, name, vertexType);
  }

  /// Creates a new normal configuration with all final values
  /// calculated by the other NormalConfig constructor.
  NormalConfig._(this.bumpy, this.binm, this.txt2D, this.txtCube, this.name,
      this.vertexType);

  /// Creates the vertex source code for the material light shader for the given configurations.
  String createVertexSource() {
    final StringBuffer buf = StringBuffer();
    buf.writeln("uniform mat4 viewObjMat;");
    buf.writeln("uniform mat4 projViewObjMat;");
    if (this.txt2D) buf.writeln("uniform mat3 txt2DMat;");
    if (this.txtCube) buf.writeln("uniform mat4 txtCubeMat;");
    buf.writeln("");

    buf.writeln("attribute vec3 posAttr;");
    buf.writeln("attribute vec3 normAttr;");
    if (this.binm) buf.writeln("attribute vec3 binmAttr;");
    if (this.txt2D) buf.writeln("attribute vec2 txt2DAttr;");
    if (this.txtCube) buf.writeln("attribute vec3 txtCubeAttr;");
    buf.writeln("");

    buf.writeln("varying vec3 normalVec;");
    if (this.binm) buf.writeln("varying vec3 binormalVec;");
    if (this.txt2D) buf.writeln("varying vec2 txt2D;");
    if (this.txtCube) buf.writeln("varying vec3 txtCube;");
    buf.writeln("");

    buf.writeln("void main()");
    buf.writeln("{");
    buf.writeln("   normalVec = normalize(viewObjMat*vec4(normAttr, 0.0)).xyz;");
    if (this.binm) buf.writeln("   binormalVec = normalize(viewObjMat*vec4(binmAttr, 0.0)).xyz;");
    if (this.txt2D) buf.writeln("   txt2D = (txt2DMat*vec3(txt2DAttr, 1.0)).xy;");
    if (this.txtCube) buf.writeln("   txtCube = (txtCubeMat*vec4(txtCubeAttr, 1.0)).xyz;");
    buf.writeln("   gl_Position = projViewObjMat*vec4(posAttr, 1.0);");
    buf.writeln("}");
    return buf.toString();
  }

  /// Creates the fragment source code for the material light shader for the given configurations.
  String createFragmentSource() {
    final StringBuffer buf = StringBuffer();
    buf.writeln("precision mediump float;");
    buf.writeln("");

    buf.writeln("varying vec3 normalVec;");
    if (this.binm) buf.writeln("varying vec3 binormalVec;");
    if (this.txt2D) buf.writeln("varying vec2 txt2D;");
    if (this.txtCube) buf.writeln("varying vec3 txtCube;");
    buf.writeln("");

    if (this.bumpy.hasTxt2D) {
      buf.writeln("uniform sampler2D bumpTxt;");
    } else if (this.bumpy.hasTxtCube) {
      buf.writeln("uniform samplerCube bumpTxt;");
    }
    buf.writeln("");

    buf.writeln("vec3 normal()");
    buf.writeln("{");
    if (this.bumpy.hasNone || this.bumpy.hasSolid) {
      buf.writeln("   return normalize(normalVec);");
    } else {
      if (this.bumpy.hasTxt2D) {
        buf.writeln("   vec3 color = texture2D(bumpTxt, txt2D).rgb;");
      } else {
        // hasTxtCube
        buf.writeln("   vec3 color = textureCube(bumpTxt, txtCube).rgb;");
      }
      buf.writeln("   vec3 n = normalize(normalVec);");
      buf.writeln("   vec3 b = normalize(binormalVec);");
      buf.writeln("   vec3 c = normalize(cross(b, n));");
      buf.writeln("   b = cross(n, c);");
      buf.writeln("   mat3 mat = mat3( b.x,  b.y,  b.z,");
      buf.writeln("                   -c.x, -c.y, -c.z,");
      buf.writeln("                    n.x,  n.y,  n.z);");
      buf.writeln("   return mat * normalize(2.0*color - 1.0);");
    }

    buf.writeln("}");
    buf.writeln("");

    buf.writeln("void main()");
    buf.writeln("{");
    buf.writeln("   vec3 norm = normal();");
    buf.writeln("   norm = -norm*0.5 + 0.5;");
    buf.writeln("   gl_FragColor = vec4(norm.x, 1.0-norm.y, norm.z, 1.0);");
    buf.writeln("}");
    return buf.toString();
  }

  /// Gets the name for the configuration.
  @override
  String toString() => this.name;
}

/// The base shader object.
abstract class Shader extends Bindable {
  final webgl.RenderingContext2 _gl;
  final String _name;

  String _vertexSourceCode = '';
  String _fragmentSourceCode = '';

  late webgl.Program _program;
  AttributeContainer? _attrs;
  UniformContainer? _uniforms;

  /// Creates a shader with the given rendering context and name.
  Shader(this._gl, this._name);

  /// initializes and compiles the shader with the given vertex and fragment sources.
  void initialize(String vertexSourceCode, String fragmentSourceCode) {
    this._vertexSourceCode = vertexSourceCode;
    this._fragmentSourceCode = fragmentSourceCode;
    this._createProgram();
    this._setupAttributes();
    this._setupUniform();
  }

  /// The name of the shader.
  String get name => this._name;

  /// Gets the vertex source code used for this shader.
  String get vertexSourceCode => this._vertexSourceCode;

  /// Gets the fragment source code used for this shader.
  String get fragmentSourceCode => this._fragmentSourceCode;

  /// The list of attributes for this shader.
  AttributeContainer get attributes {
    final AttributeContainer? attrs = this._attrs;
    if (attrs == null) throw Exception('Must initialize the shader prior to getting the attributes.');
    return attrs;
  }

  /// The list of uniforms for this shader.
  UniformContainer get uniforms {
    final UniformContainer? uniforms = this._uniforms;
    if (uniforms == null) throw Exception('Must initialize the shader prior to getting the uniforms.');
    return uniforms;
  }

  /// Gets a non-null instance of the program.
  webgl.Program get _glProgram {
    final webgl.Program prog = this._program;
    return prog;
  }

  /// Binds this shader to the render state.
  @override
  void bind(RenderState state) {
    state.gl.useProgram(this._program);
    this.attributes.enableAll();
  }

  /// Unbinds this shader from the render state.
  @override
  void unbind(RenderState state) {
    state.gl.useProgram(null);
    this.attributes.disableAll();
  }

  /// Compiles a shader component from the given [shaderSource] for
  /// either the shader type fragment shader or vertex shader.
  webgl.Shader _createShader(String shaderSource, int shaderType) {
    // print(numberLines(shaderSource));
    final webgl.Shader shader = this._gl.createShader(shaderType);
    this._gl.shaderSource(shader, shaderSource);
    this._gl.compileShader(shader);
    if (!(this._gl.getShaderParameter(shader, webgl.WebGL.COMPILE_STATUS) as bool?)!) {
      final String errorInfo = this._gl.getShaderInfoLog(shader) ?? 'undefined log error';
      this._gl.deleteShader(shader);
      throw Exception('Error compiling shader "$shader": $errorInfo');
    }
    return shader;
  }

  /// Creates the shader program by linking the shader components.
  void _createProgram() {
    final webgl.Shader vertexShader = this._createShader(this._vertexSourceCode, webgl.WebGL.VERTEX_SHADER);
    final webgl.Shader fragmentShader = this._createShader(this._fragmentSourceCode, webgl.WebGL.FRAGMENT_SHADER);
    this._program = this._gl.createProgram();
    this._gl.attachShader(this._glProgram, vertexShader);
    this._gl.attachShader(this._glProgram, fragmentShader);
    this._gl.linkProgram(this._glProgram);
    final bool linkStatus = (this._gl.getProgramParameter(this._glProgram, webgl.WebGL.LINK_STATUS) as bool?)!;
    if (!linkStatus) {
      final String errorInfo = this._gl.getProgramInfoLog(this._glProgram) ?? 'undefined log error';
      this._gl.deleteProgram(this._program);
      throw Exception('Failed to link shader: $errorInfo');
    }
  }

  /// Sets up all the attribute list.
  void _setupAttributes() {
    final List<Attribute> attrs = [];
    final int count = (this._gl.getProgramParameter(this._glProgram, webgl.WebGL.ACTIVE_ATTRIBUTES) as int?)!;
    for (int i = 0; i < count; ++i) {
      final webgl.ActiveInfo info = this._gl.getActiveAttrib(this._glProgram, i);
      final int loc = this._gl.getAttribLocation(this._glProgram, info.name);
      attrs.add(Attribute._(this._gl, info.name, loc));
    }
    this._attrs = AttributeContainer._(attrs);
  }

  /// Sets up all the uniform list.
  void _setupUniform() {
    final List<Uniform> uniforms = [];
    final int count = (this._gl.getProgramParameter(this._glProgram, webgl.WebGL.ACTIVE_UNIFORMS) as int?)!;
    for (int i = 0; i < count; ++i) {
      final webgl.ActiveInfo info = this._gl.getActiveUniform(this._glProgram, i);
      final webgl.UniformLocation loc = this._gl.getUniformLocation(this._glProgram, info.name);
      uniforms.add(this.createUniform(info.type, info.size, info.name, loc));
    }
    this._uniforms = UniformContainer._(uniforms);
  }

  /// Creates a new Uniform1i or Uniform1iv for the given [size], [name], and uniform location.
  Uniform _createUniform1i(int size, String name, webgl.UniformLocation loc) {
    if (size == 1) {
      return Uniform1i._(this._gl, this._program, name, loc);
    } else {
      return Uniform1iv._(this._gl, this._program, name, size, loc);
    }
  }

  /// Creates a new UniformSampler2D or Uniform1iv for the given [size], [name], and uniform location.
  Uniform _createUniformSampler2D(int size, String name, webgl.UniformLocation loc) {
    if (size == 1) {
      return UniformSampler2D._(this._gl, this._program, name, loc);
    } else {
      return Uniform1iv._(this._gl, this._program, name, size, loc);
    }
  }

  /// Creates a new UniformSamplerCube or Uniform1iv for the given [size], [name], and uniform location.
  Uniform _createUniformSamplerCube(int size, String name, webgl.UniformLocation loc) {
    if (size == 1) {
      return UniformSamplerCube._(this._gl, this._program, name, loc);
    } else {
      return Uniform1iv._(this._gl, this._program, name, size, loc);
    }
  }

  /// Creates an exception for unsupported types.
  Exception _unsupportedException(String type, String name) {
    return Exception(
        '$type uniform variables are unsupported by all browsers.\n' + 'Please change the type of $name.');
  }

  /// Creates a new uniform for the given [type] information, [size], [name], and uniform location.
  Uniform createUniform(int type, int size, String name, webgl.UniformLocation loc) {
    switch (type) {
      case webgl.WebGL.BYTE:
        return this._createUniform1i(size, name, loc);
      case webgl.WebGL.UNSIGNED_BYTE:
        return this._createUniform1i(size, name, loc);
      case webgl.WebGL.SHORT:
        return this._createUniform1i(size, name, loc);
      case webgl.WebGL.UNSIGNED_SHORT:
        return this._createUniform1i(size, name, loc);
      case webgl.WebGL.INT:
        return this._createUniform1i(size, name, loc);
      case webgl.WebGL.UNSIGNED_INT:
        return this._createUniform1i(size, name, loc);
      case webgl.WebGL.FLOAT:
        return Uniform1f._(this._gl, this._program, name, loc);
      case webgl.WebGL.FLOAT_VEC2:
        return Uniform2f._(this._gl, this._program, name, loc);
      case webgl.WebGL.FLOAT_VEC3:
        return Uniform3f._(this._gl, this._program, name, loc);
      case webgl.WebGL.FLOAT_VEC4:
        return Uniform4f._(this._gl, this._program, name, loc);
      case webgl.WebGL.INT_VEC2:
        return Uniform2i._(this._gl, this._program, name, loc);
      case webgl.WebGL.INT_VEC3:
        return Uniform3i._(this._gl, this._program, name, loc);
      case webgl.WebGL.INT_VEC4:
        return Uniform4i._(this._gl, this._program, name, loc);
      case webgl.WebGL.FLOAT_MAT2:
        return UniformMat2._(this._gl, this._program, name, loc);
      case webgl.WebGL.FLOAT_MAT3:
        return UniformMat3._(this._gl, this._program, name, loc);
      case webgl.WebGL.FLOAT_MAT4:
        return UniformMat4._(this._gl, this._program, name, loc);
      case webgl.WebGL.SAMPLER_2D:
        return this._createUniformSampler2D(size, name, loc);
      case webgl.WebGL.SAMPLER_CUBE:
        return this._createUniformSamplerCube(size, name, loc);
      case webgl.WebGL.BOOL:
        throw this._unsupportedException('BOOL', name);
      case webgl.WebGL.BOOL_VEC2:
        throw this._unsupportedException('BOOL_VEC2', name);
      case webgl.WebGL.BOOL_VEC3:
        throw this._unsupportedException('BOOL_VEC3', name);
      case webgl.WebGL.BOOL_VEC4:
        throw this._unsupportedException('BOOL_VEC4', name);
      default:
        throw Exception('Unknown uniform variable type $type for $name.');
    }
  }
}

/// A shader for cover pass skybox rendering.
class Skybox extends Shader {
  /// The name for this shader.
  static const String defaultName = "Skybox";

  /// The vertex shader source code in glsl.
  static const _vertexSource = "uniform mat4 viewMat;                             \n" +
      "uniform float fov;                                \n" +
      "uniform float ratio;                              \n" +
      "                                                  \n" +
      "attribute vec3 posAttr;                           \n" +
      "                                                  \n" +
      "varying vec3 cubeTxt;                             \n" +
      "                                                  \n" +
      "void main()                                       \n" +
      "{                                                 \n" +
      "  float t = 1.0 / (tan(fov * 0.5)*3.0);           \n" +
      "  float x = -t * posAttr.x / ratio;               \n" +
      "  float y = t * posAttr.y;                        \n" +
      "  cubeTxt = (viewMat * vec4(x, y, 1.0, 0.0)).xyz; \n" +
      "  gl_Position = vec4(posAttr, 1.0);               \n" +
      "}                                                 \n";

  /// The fragment shader source code in glsl.
  static const String _fragmentSource = "precision mediump float;                                              \n" +
      "                                                                      \n" +
      "uniform samplerCube boxTxt;                                           \n" +
      "uniform vec3 boxClr;                                                  \n" +
      "                                                                      \n" +
      "varying vec3 cubeTxt;                                                 \n" +
      "                                                                      \n" +
      "void main()                                                           \n" +
      "{                                                                     \n" +
      "   vec3 txtCube = normalize(cubeTxt);                                 \n" +
      "   gl_FragColor = vec4(boxClr*textureCube(boxTxt, txtCube).xyz, 1.0); \n" +
      "}                                                                     \n";

  Attribute? _posAttr;
  Uniform1f? _fov;
  Uniform1f? _ratio;
  Uniform3f? _boxClr;
  UniformSamplerCube? _boxTxt;
  UniformMat4? _viewMat;

  /// Compiles this shader for the given rendering context.
  Skybox(webgl.RenderingContext2 gl) : super(gl, defaultName) {
    this.initialize(_vertexSource, _fragmentSource);
    this._posAttr = this.attributes["posAttr"];
    this._fov = this.uniforms["fov"] as Uniform1f?;
    this._ratio = this.uniforms["ratio"] as Uniform1f?;
    this._boxClr = this.uniforms["boxClr"] as Uniform3f?;
    this._boxTxt = this.uniforms["boxTxt"] as UniformSamplerCube?;
    this._viewMat = this.uniforms["viewMat"] as UniformMat4?;
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory Skybox.cached(RenderState state) {
    Skybox? shader = state.shader(defaultName) as Skybox?;
    if (shader == null) {
      shader = Skybox(state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// Field of view vertically in radians of the camera.
  double get fov => this._fov?.getValue() ?? 1.0;

  set fov(double value) => this._fov?.setValue(value);

  /// The render target's width over height aspect ratio.
  double get ratio => this._ratio?.getValue() ?? 1.0;

  set ratio(double value) => this._ratio?.setValue(value);

  /// The color to scale the sky box texture with..
  Color3 get boxColor => this._boxClr?.getColor3() ?? Color3.white();

  set boxColor(Color3 clr) => this._boxClr?.setColor3(clr);

  /// The sky box texture to cover with.
  set boxTexture(TextureCube txt) => this._boxTxt?.setTextureCube(txt);

  /// The view matrix.
  Matrix4 get viewMatrix => this._viewMat?.getMatrix4() ?? Matrix4.identity;

  set viewMatrix(Matrix4 mat) => this._viewMat?.setMatrix4(mat);
}

/// A shader for very basic solid color rendering.
class SolidColor extends Shader {
  /// The name for this shader.
  static const String defaultName = "SolidColor";

  /// The vertex shader source code in glsl.
  static const String _vertexSource = "uniform mat4 projViewObjMat;                       \n" +
      "                                                   \n" +
      "attribute vec3 posAttr;                            \n" +
      "                                                   \n" +
      "void main()                                        \n" +
      "{                                                  \n" +
      "  gl_Position = projViewObjMat*vec4(posAttr, 1.0); \n" +
      "}                                                  \n";

  /// The fragment shader source code in glsl.
  static const String _fragmentSource = "precision mediump float; \n" +
      "                         \n" +
      "uniform vec4 color;      \n" +
      "                         \n" +
      "void main()              \n" +
      "{                        \n" +
      "   gl_FragColor = color; \n" +
      "}                        \n";

  Attribute? _posAttr;
  Uniform4f? _clr;
  UniformMat4? _projViewObjMat;

  /// Compiles this shader for the given rendering context.
  SolidColor(webgl.RenderingContext2 gl) : super(gl, defaultName) {
    this.initialize(_vertexSource, _fragmentSource);
    this._posAttr = this.attributes["posAttr"];
    this._clr = this.uniforms["color"] as Uniform4f?;
    this._projViewObjMat = this.uniforms["projViewObjMat"] as UniformMat4?;
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory SolidColor.cached(RenderState state) {
    SolidColor? shader = state.shader(defaultName) as SolidColor?;
    if (shader == null) {
      shader = SolidColor(state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// The color to draw the object with.
  Color4 get color => this._clr?.getColor4() ?? Color4.white();

  set color(Color4 clr) => this._clr?.setColor4(clr);

  /// The projection matrix times view matrix times the object matrix.
  Matrix4 get projViewObjectMatrix => this._projViewObjMat?.getMatrix4() ?? Matrix4.identity;

  set projViewObjectMatrix(Matrix4 mat) => this._projViewObjMat?.setMatrix4(mat);
}

/// A shader for cover pass rendering several layed out textures.
class TextureLayout extends Shader {
  /// The name for this shader.
  static String _getName(int maxTxtCount, ColorBlendType blend) =>
      "TextureLayout_${maxTxtCount}_${stringForColorBlendType(blend)}";

  /// The vertex shader source code in glsl.
  static String _vertexSource() {
    final StringBuffer buf = StringBuffer();
    buf.writeln("attribute vec3 posAttr;");
    buf.writeln("");
    buf.writeln("varying vec2 pos;");
    buf.writeln("");
    buf.writeln("void main()");
    buf.writeln("{");
    buf.writeln("  pos = posAttr.xy*0.5 + 0.5;");
    buf.writeln("  gl_Position = vec4(posAttr, 1.0);");
    buf.writeln("}");
    return buf.toString();
  }

  /// The fragment shader source code in glsl.
  static String _fragmentSource(int maxTxtCount, ColorBlendType blend) {
    final StringBuffer buf = StringBuffer();
    buf.writeln("precision mediump float;");
    buf.writeln("");
    buf.writeln("uniform vec4 backClr;");
    buf.writeln("");
    buf.writeln("varying vec2 pos;");
    buf.writeln("");
    buf.writeln("uniform int txtCount;");
    for (int i = 0; i < maxTxtCount; ++i) {
      buf.writeln("uniform sampler2D txt$i;");
      buf.writeln("uniform mat4 clrMat$i;");
      buf.writeln("uniform vec2 srcLoc$i;");
      buf.writeln("uniform vec2 srcSize$i;");
      buf.writeln("uniform vec2 destLoc$i;");
      buf.writeln("uniform vec2 destSize$i;");
      buf.writeln("uniform int flip$i;");
    }
    buf.writeln("");
    buf.writeln("vec4 clrAccum;");
    if ((blend == ColorBlendType.Average) || (blend == ColorBlendType.Overwrite)) {
      buf.writeln("float colorCount;");
    }
    buf.writeln("");
    buf.writeln("void layout(sampler2D txt, mat4 clrMat,");
    buf.writeln("            vec2 srcLoc, vec2 srcSize, vec2 destLoc, vec2 destSize, int flip)");
    buf.writeln("{");
    buf.writeln("   vec2 txtPnt = (pos - destLoc)*srcSize/destSize;");
    buf.writeln("   if((txtPnt.x >= 0.0) && (txtPnt.x <= srcSize.x) &&");
    buf.writeln("      (txtPnt.y >= 0.0) && (txtPnt.y <= srcSize.y))");
    buf.writeln("   {");
    buf.writeln("      if(flip != 0) txtPnt.y = srcSize.y - txtPnt.y;");
    buf.writeln("      vec4 color = clrMat*texture2D(txt, txtPnt + srcLoc);");
    buf.writeln("      color = clamp(color, vec4(0.0), vec4(1.0));");
    if (blend == ColorBlendType.Additive) {
      buf.writeln("      clrAccum += color;");
    } else if (blend == ColorBlendType.AlphaBlend) {
      buf.writeln("      clrAccum = mix(clrAccum, color, color.a);");
    } else if (blend == ColorBlendType.Average) {
      buf.writeln("      clrAccum += color;");
      buf.writeln("      colorCount += 1.0;");
    } else {
      // ColorBlendType.Overwrite
      buf.writeln("      clrAccum = color;");
      buf.writeln("      colorCount = 1.0;");
    }
    buf.writeln("   }");
    buf.writeln("}");
    buf.writeln("");
    buf.writeln("void layoutAll()");
    buf.writeln("{");
    if (blend == ColorBlendType.Overwrite) {
      for (int i = maxTxtCount - 1; i >= 0; --i) {
        buf.writeln("   if(txtCount > $i)");
        buf.writeln("   {");
        buf.writeln("     layout(txt$i, clrMat$i, srcLoc$i, srcSize$i, destLoc$i, destSize$i, flip$i);");
        buf.writeln("     if(colorCount > 0.0) return;");
        buf.writeln("   }");
      }
    } else {
      for (int i = 0; i < maxTxtCount; ++i) {
        buf.writeln("   if(txtCount <= $i) return;");
        buf.writeln("   layout(txt$i, clrMat$i, srcLoc$i, srcSize$i, destLoc$i, destSize$i, flip$i);");
      }
    }
    buf.writeln("}");
    buf.writeln("");
    buf.writeln("void main()");
    buf.writeln("{");
    buf.writeln("   clrAccum = backClr;");
    if (blend == ColorBlendType.Average) {
      buf.writeln("   colorCount = 1.0;");
    } else if (blend == ColorBlendType.Overwrite) {
      buf.writeln("   colorCount = 0.0;");
    }
    buf.writeln("   layoutAll();");
    if (blend == ColorBlendType.Average) {
      buf.writeln("   clrAccum = clrAccum/colorCount;");
    }
    buf.writeln("   if(clrAccum.a <= 0.0) discard;");
    buf.writeln("   gl_FragColor = clrAccum;");
    buf.writeln("}");
    return buf.toString();
  }

  Attribute? _posAttr;
  Uniform1i? _txtCount;
  Uniform4f? _backClr;
  final List<UniformSampler2D?> _txts = [];
  final List<UniformMat4?> _clrMats = [];
  final List<Uniform2f?> _srcLocs = [];
  final List<Uniform2f?> _srcSizes = [];
  final List<Uniform2f?> _destLocs = [];
  final List<Uniform2f?> _destSizes = [];
  final List<Uniform1i?> _flips = [];

  /// Compiles this shader for the given rendering context.
  TextureLayout(int maxTxtCount, ColorBlendType blend, webgl.RenderingContext2 gl)
      : super(gl, _getName(maxTxtCount, blend)) {
    this.initialize(_vertexSource(), _fragmentSource(maxTxtCount, blend));
    this._posAttr = this.attributes["posAttr"];
    this._txtCount = this.uniforms.required("txtCount") as Uniform1i;
    this._backClr = this.uniforms.required("backClr") as Uniform4f;
    for (int i = 0; i < maxTxtCount; ++i) {
      this._txts.add(this.uniforms.required("txt$i") as UniformSampler2D?);
      this._clrMats.add(this.uniforms.required("clrMat$i") as UniformMat4?);
      this._srcLocs.add(this.uniforms.required("srcLoc$i") as Uniform2f?);
      this._srcSizes.add(this.uniforms.required("srcSize$i") as Uniform2f?);
      this._destLocs.add(this.uniforms.required("destLoc$i") as Uniform2f?);
      this._destSizes.add(this.uniforms.required("destSize$i") as Uniform2f?);
      this._flips.add(this.uniforms.required("flip$i") as Uniform1i?);
    }
  }

  /// Checks for the shader in the shader cache in the given [state],
  /// if it is not found then this shader is compiled and added
  /// to the shader cache before being returned.
  factory TextureLayout.cached(int maxTxtCount, ColorBlendType blend, RenderState state) {
    TextureLayout? shader = state.shader(_getName(maxTxtCount, blend)) as TextureLayout?;
    if (shader == null) {
      shader = TextureLayout(maxTxtCount, blend, state.gl);
      state.addShader(shader);
    }
    return shader;
  }

  /// The position vertex shader attribute.
  Attribute? get posAttr => this._posAttr;

  /// The background color to put behind the layout.
  Color4 get backgroundColor => this._backClr?.getColor4() ?? Color4.white();

  set backgroundColor(Color4 value) => this._backClr?.setColor4(value);

  /// The number of textures to layout.
  int get textureCount => this._txtCount?.getValue() ?? 0;

  set textureCount(int value) => this._txtCount?.setValue(value);

  /// Sets the texture at the given [index] to cover with.
  void setTexture(int index, Texture2D txt) => this._txts[index]?.setTexture2D(txt);

  /// Sets the color matrix at the given [index].
  void setColorMatrix(int index, Matrix4? mat) => this._clrMats[index]?.setMatrix4(mat ?? Matrix4.identity);

  /// Sets the source rectangle at the given [index].
  void setSourceRect(int index, Region2? rect) {
    // ignore: parameter_assignments
    rect ??= Region2.unit;
    this._srcLocs[index]?.setValues(rect.x, rect.y);
    this._srcSizes[index]?.setValues(rect.dx, rect.dy);
  }

  /// Sets the destination rectangle at the given [index].
  void setDestinationRect(int index, Region2? rect) {
    // ignore: parameter_assignments
    rect ??= Region2.unit;
    this._destLocs[index]?.setValues(rect.x, rect.y);
    this._destSizes[index]?.setValues(rect.dx, rect.dy);
  }

  /// Sets if the texture should be flipped at the given [index].
  void setFlip(int index, bool flip) => this._flips[index]?.setValue(flip ? 1 : 0);
}

/// The uniform variable for a shader.
abstract class Uniform {
  /// The rendering context for the uniform variable.
  final webgl.RenderingContext2 _gl;

  /// The program for the shader.
  final webgl.Program _program;

  /// The name for the uniform variable in the shader source code.
  final String name;

  /// The location of the uniform variable in the shader.
  final webgl.UniformLocation loc;

  /// Constructs a new uniform shader variable.
  Uniform._(this._gl, this._program, this.name, this.loc);

  /// Gets the raw value of the uniform shader.
  dynamic get rawValue => this._gl.getUniform(this._program, this.loc);
}

/// A container of uniform shader variables.
class UniformContainer {
  /// The list of uniform shader variables.
  final List<Uniform> _uniforms;

  /// Creates a new uniform container for the given list of uniforms.
  UniformContainer._(this._uniforms);

  /// The number of uniform variables in the container.
  int get count => this._uniforms.length;

  /// Gets the uniform variable at the given [i].
  Uniform at(int i) => this._uniforms[i];

  /// Gets the uniform variable by the name.
  Uniform? operator [](String name) {
    for (final Uniform uniform in this._uniforms) {
      if (uniform.name == name) return uniform;
    }
    return null;
  }

  /// Gets the uniform variable by the name.
  /// If the uniform doesn't exist an exception will be thrown.
  Uniform required(String name) {
    final Uniform? uniform = this[name];
    if (uniform == null) {
      throw Exception("Required uniform value, $name, was not defined or used in shader.");
    }
    return uniform;
  }

  /// Gets the index of the uniform variable with the given name.
  int indexOf(String name) {
    for (int i = this._uniforms.length - 1; i >= 0; --i) {
      if (this._uniforms[i].name == name) return i;
    }
    return -1;
  }

  /// Determines if the uniform variable with the given name exists in this list.
  bool contains(String name) {
    for (final Uniform uniform in this._uniforms) {
      if (uniform.name == name) return true;
    }
    return false;
  }

  /// Gets the string for this collection.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this collection.
  String format({String sep = "\n"}) {
    String result = "";
    for (final Uniform uniform in this._uniforms) {
      // ignore: use_string_buffers
      result += "$uniform$sep";
    }
    return result;
  }
}

//=======================================================================

/// The uniform variable for a single integer.
class Uniform1i extends Uniform {
  /// Creates a new single integer uniform variable.
  Uniform1i._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc)
      : super._(
          gl,
          program,
          name,
          loc,
        );

  /// Gets the single integer value.
  int getValue() {
    final List<int> list = this.getList();
    // ignore: prefer_asserts_with_message
    assert(list.length == 1);
    return list[0];
  }

  /// Sets the single integer value of the uniform.
  void setValue(int value) => this._gl.uniform1i(super.loc, value);

  /// Gets the list containing a single integer value.
  List<int> getList() => this.rawValue as List<int>;

  /// Sets the value with the given list.
  /// The list must contain only a single value.
  void setList(List<int> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 1);
    this.setValue(values[0]);
  }

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform1i: ${this.name}";
}

/// The uniform variable for two integers.
class Uniform2i extends Uniform {
  /// Creates a new two integer uniform variable.
  Uniform2i._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc) : super._(gl, program, name, loc);

  /// Sets the two integers value of the uniform.
  void setValues(int x, int y) => this._gl.uniform2i(super.loc, x, y);

  /// Gets the list containing two integer values.
  List<int> getList() => this.rawValue as List<int>;

  /// Sets the values with the given list.
  /// The list must contain two values.
  void setList(List<int> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 2);
    this.setValues(values[0], values[1]);
  }

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform2i: ${this.name}";
}

/// The uniform variable for three integers.
class Uniform3i extends Uniform {
  /// Creates a new three integer uniform variable.
  Uniform3i._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc) : super._(gl, program, name, loc);

  /// Sets the three integers value of the uniform.
  void setValues(int x, int y, int z) => this._gl.uniform3i(super.loc, x, y, z);

  /// Gets the list containing three integer values.
  List<int> getList() => this.rawValue as List<int>;

  /// Sets the values with the given list.
  /// The list must contain three values.
  void setList(List<int> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 3);
    this.setValues(values[0], values[1], values[2]);
  }

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform3i: ${this.name}";
}

/// The uniform variable for four integers.
class Uniform4i extends Uniform {
  /// Creates a new four integer uniform variable.
  Uniform4i._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc) : super._(gl, program, name, loc);

  /// Sets the four integers value of the uniform.
  void setValues(int x, int y, int z, int w) => this._gl.uniform4i(super.loc, x, y, z, w);

  /// Gets the list containing four integer values.
  List<int> getList() => this.rawValue as List<int>;

  /// Sets the values with the given list.
  /// The list must contain four values.
  void setList(List<int> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    this.setValues(values[0], values[1], values[2], values[3]);
  }

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform4i: ${this.name}";
}

/// The uniform variable for a single integer array.
class Uniform1iv extends Uniform {
  List<int> _values = [];

  /// Creates a new single integer array uniform variable.
  Uniform1iv._(
    webgl.RenderingContext2 gl,
    webgl.Program program,
    String name,
    int size,
    webgl.UniformLocation loc,
  ) : super._(
          gl,
          program,
          name,
          loc,
        ) {
    this._size = size;
    this._values = List<int>.filled(this._size, 0);
  }

  /// The size of the array;
  int get size => this._size;
  int _size = 0;

  /// Gets the list containing a single integer array.
  List<int> getList() => this.rawValue as List<int>;

  /// Gets the list containing a single integer array.
  List<int> getCachedList() => this._values;

  /// Sets the array with the given list.
  void setList(List<int> values) {
    this._values = values;
    this._gl.uniform1iv(super.loc, values);
  }

  /// Sets the value nt the list at the given index.
  void setAt(int index, int value) {
    this._values[index] = value;
    this._gl.uniform1iv(super.loc, this._values);
  }

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform1iv: ${this.name}";
}

//=======================================================================

/// The uniform variable for a single float.
class Uniform1f extends Uniform {
  /// Creates a new single float uniform variable.
  Uniform1f._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc)
      : super._(gl, program, name, loc);

  /// Gets the single float value.
  double getValue() {
    final List<double> list = this.getList();
    // ignore: prefer_asserts_with_message
    assert(list.length == 1);
    return list[0];
  }

  /// Sets the single float value of the uniform.
  void setValue(double value) => this._gl.uniform1f(super.loc, value);

  /// Gets the list containing a single float value.
  List<double> getList() => this.rawValue as List<double>;

  /// Sets the values with the given list.
  /// The list must contain a single value.
  void setList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 1);
    this.setValue(values[0]);
  }

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform1f: ${this.name}";
}

/// The uniform variable for two floats.
class Uniform2f extends Uniform {
  /// Creates a new two float uniform variable.
  Uniform2f._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc)
      : super._(gl, program, name, loc);

  /// Sets the two float values of the uniform.
  void setValues(double x, double y) => this._gl.uniform2f(super.loc, x, y);

  /// Gets the list containing two float values.
  List<double> getList() => this.rawValue as List<double>;

  /// Sets the values with the given list.
  /// The list must contain two values.
  void setList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 2);
    this.setValues(values[0], values[1]);
  }

  /// Gets the 2D vector with the value of this uniform.
  Vector2 getVector2() => Vector2.fromList(this.getList());

  /// Sets the uniform with the given 2D vector.
  void setVector2(Vector2 vec) => this.setValues(vec.dx, vec.dy);

  /// Gets the 2D point with the value of this uniform.
  Point2 getPoint2() => Point2.fromList(this.getList());

  /// Sets the uniform with the given 2D point.
  void setPoint2(Point2 pnt) => this.setValues(pnt.x, pnt.y);

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform2f: ${this.name}";
}

/// The uniform variable for three floats.
class Uniform3f extends Uniform {
  /// Creates a new three float uniform variable.
  Uniform3f._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc)
      : super._(gl, program, name, loc);

  /// Sets the three float values of the uniform.
  void setValues(double x, double y, double z) => this._gl.uniform3f(super.loc, x, y, z);

  /// Gets the list containing three float values.
  List<double> getList() => this.rawValue as List<double>;

  /// Sets the values with the given list.
  /// The list must contain three values.
  void setList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 3);
    this.setValues(values[0], values[1], values[2]);
  }

  /// Gets the 3D vector with the value of this uniform.
  Vector3 getVector3() => Vector3.fromList(this.getList());

  /// Sets the uniform with the given 3D vector.
  void setVector3(Vector3 vec) => this.setValues(vec.dx, vec.dy, vec.dz);

  /// Gets the 3D point with the value of this uniform.
  Point3 getPoint3() => Point3.fromList(this.getList());

  /// Sets the uniform with the given 3D point.
  void setPoint3(Point3 pnt) => this.setValues(pnt.x, pnt.y, pnt.z);

  /// Gets the RGB color with the value of this uniform.
  Color3 getColor3() => Color3.fromList(this.getList());

  /// Sets the uniform with the given RGB color.
  void setColor3(Color3 clr) => this.setValues(clr.red, clr.green, clr.blue);

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform3f: ${this.name}";
}

/// The uniform variable for four floats.
class Uniform4f extends Uniform {
  /// Creates a new four float uniform variable.
  Uniform4f._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc)
      : super._(gl, program, name, loc);

  /// Sets the four float values of the uniform.
  void setValues(double x, double y, double z, double w) => this._gl.uniform4f(super.loc, x, y, z, w);

  /// Gets the list containing four float values.
  List<double> getList() => this.rawValue as List<double>;

  /// Sets the values with the given list.
  /// The list must contain four values.
  void setList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    this.setValues(values[0], values[1], values[2], values[3]);
  }

  /// Gets the 4D vector with the value of this uniform.
  Vector4 getVector4() => Vector4.fromList(this.getList());

  /// Sets the uniform with the given 4D vector.
  void setVector4(Vector4 vec) => this.setValues(vec.dx, vec.dy, vec.dz, vec.dw);

  /// Gets the 4D point with the value of this uniform.
  Point4 getPoint4() => Point4.fromList(this.getList());

  /// Sets the uniform with the given 4D point.
  void setPoint4(Point4 pnt) => this.setValues(pnt.x, pnt.y, pnt.z, pnt.w);

  /// Gets the ARGB color with the value of this uniform.
  Color4 getColor4() => Color4.fromList(this.getList());

  /// Sets the uniform with the given ARGB color.
  void setColor4(Color4 clr) => this.setValues(clr.red, clr.green, clr.blue, clr.alpha);

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform4f: ${this.name}";
}

//=======================================================================

/// The uniform variable for a 2x2 matrix.
class UniformMat2 extends Uniform {
  /// Creates a new 2x2 matrix uniform variable.
  UniformMat2._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc) : super._(gl, program, name, loc);

  /// Sets the 2x2 matrix of the uniform.
  void setValues(double m11, double m21, double m12, double m22) {
    this.setList([m11, m21, m12, m22]);
  }

  /// Gets the list containing four float values.
  List<double> getList() => this.rawValue as List<double>;

  /// Sets the matrix with the given list.
  /// The list must contain four values.
  void setList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 4);
    final typed.Float32List list = typed.Float32List.fromList(values);
    this._gl.uniformMatrix2fv(super.loc, false, list);
  }

  /// Gets the 2x2 matrix with the value of this uniform.
  Matrix2 getMatrix2() => Matrix2.fromList(this.getList(), true);

  /// Sets the uniform with the given 2x2 matrix.
  void setMatrix2(Matrix2 mat) => this.setList(mat.toList(true));

  /// Gets the name for this uniform variable.
  @override
  String toString() => "Uniform1Mat2 ${this.name}";
}

/// The uniform variable for a 3x3 matrix.
class UniformMat3 extends Uniform {
  /// Creates a new 3x3 matrix uniform variable.
  UniformMat3._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc) : super._(gl, program, name, loc);

  /// Sets the 3x3 matrix of the uniform.
  void setValues(
      double m11, double m21, double m31, double m12, double m22, double m32, double m13, double m23, double m33) {
    this.setList([m11, m21, m31, m12, m22, m32, m13, m23, m33]);
  }

  /// Gets the list containing nine float values.
  List<double> getList() => this.rawValue as List<double>;

  /// Sets the matrix with the given list.
  /// The list must contain nine values.
  void setList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 9);
    final typed.Float32List list = typed.Float32List.fromList(values);
    this._gl.uniformMatrix3fv(super.loc, false, list);
  }

  /// Gets the 3x3 matrix with the value of this uniform.
  Matrix3 getMatrix3() => Matrix3.fromList(this.getList(), true);

  /// Sets the uniform with the given 3x3 matrix.
  void setMatrix3(Matrix3 mat) => this.setList(mat.toList(true));

  /// Gets the name for this uniform variable.
  @override
  String toString() => "UniformMat3: ${this.name}";
}

/// The uniform variable for a 4x4 matrix.
class UniformMat4 extends Uniform {
  /// Creates a new 4x4 matrix uniform variable.
  UniformMat4._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc) : super._(gl, program, name, loc);

  /// Sets the 4x4 matrix of the uniform.
  void setValues(double m11, double m21, double m31, double m41, double m12, double m22, double m32, double m42,
      double m13, double m23, double m33, double m43, double m14, double m24, double m34, double m44) {
    this.setList([m11, m21, m31, m41, m12, m22, m32, m42, m13, m23, m33, m43, m14, m24, m34, m44]);
  }

  /// Gets the list containing sixteen float values.
  List<double> getList() => this.rawValue as List<double>;

  /// Sets the matrix with the given list.
  /// The list must contain sixteen values.
  void setList(List<double> values) {
    // ignore: prefer_asserts_with_message
    assert(values.length == 16);
    final typed.Float32List list = typed.Float32List.fromList(values);
    this._gl.uniformMatrix4fv(super.loc, false, list);
  }

  /// Gets the 4x4 matrix with the value of this uniform.
  Matrix4 getMatrix4() => Matrix4.fromList(this.getList(), true);

  /// Sets the uniform with the given 4x4 matrix.
  void setMatrix4(Matrix4 mat) => this.setList(mat.toList(true));

  /// Gets the name for this uniform variable.
  @override
  String toString() => "UniformMat4: ${this.name}";
}

//=======================================================================

/// The uniform variable for a 2D texture sampler.
class UniformSampler2D extends Uniform {
  /// Creates a new 2D texture uniform variable.
  UniformSampler2D._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc) : super._(gl, program, name, loc);

  /// Gets the sampler index of this uniform.
  List<double> getIndex() => this.rawValue as List<double>;

  /// Sets the sampler index to this uniform.
  void setIndex(int index) {
    this._gl.uniform1i(this.loc, index);
  }

  /// Sets the uniform with the given texture 2D.
  void setTexture2D(Texture2D tex2D) {
    // ignore: unnecessary_null_comparison
    if ((tex2D == null) || !tex2D.loaded) {
      this.setIndex(0);
    } else {
      this.setIndex(tex2D.index);
    }
  }

  /// Gets the name for this uniform variable.
  @override
  String toString() => "UniformSampler2D: ${this.name}";
}

/// The uniform variable for a cube texture sampler.
class UniformSamplerCube extends Uniform {
  /// Creates a new cube texture uniform variable.
  UniformSamplerCube._(webgl.RenderingContext2 gl, webgl.Program program, String name, webgl.UniformLocation loc) : super._(gl, program, name, loc);

  /// Gets the sampler index of this uniform.
  List<double> getIndex() => this.rawValue as List<double>;

  /// Sets the sampler index to this uniform.
  void setIndex(int index) {
    this._gl.uniform1i(this.loc, index);
  }

  /// Sets the uniform with the given texture cube.
  void setTextureCube(TextureCube texCube) {
    // ignore: unnecessary_null_comparison
    if ((texCube == null) || !texCube.loaded) {
      this.setIndex(0);
    } else {
      this.setIndex(texCube.index);
    }
  }

  /// Gets the name for this uniform variable.
  @override
  String toString() => "UniformSamplerCube: ${this.name}";
}
