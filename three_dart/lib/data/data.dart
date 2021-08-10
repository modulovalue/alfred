// Data provides the storage mechanism for shapes components
// which can be rendered with WebGL.
import 'dart:typed_data' as typed;
import 'dart:web_gl' as web_gl;

import '../core/core.dart' as core;
import '../math/math.dart' as math;

/// A buffer is a special type of bindable designed to
/// store cached shape information for rendering.
abstract class Buffer extends core.Bindable {
  // Empty
}

/// Storage for WebGL cached shape information.
class WebGLBuffer implements Buffer {
  /// Indicates the type of buffer, typically ARRAY_BUFFER or ELEMENT_ARRAY_BUFFER.
  int _bufType;

  /// The WebGL packed buffer data.
  web_gl.Buffer _buf;

  /// Creates a new WebGL buffer.
  WebGLBuffer(this._bufType, this._buf);

  /// Creates a new WebGL buffer from a double list of data.
  /// Typically used for creating a vertex buffer, ARRAY_BUFFER.
  factory WebGLBuffer.fromDoubleList(web_gl.RenderingContext2 gl, int bufType, List<double> data) {
    final web_gl.Buffer buffer = gl.createBuffer();
    gl.bindBuffer(bufType, buffer);
    gl.bufferData(bufType, typed.Float32List.fromList(data), web_gl.WebGL.STATIC_DRAW);
    gl.bindBuffer(bufType, null);
    return WebGLBuffer(bufType, buffer);
  }

  /// Creates a new WebGL buffer from a integer list of data.
  /// Typically used for creating an index buffer, ELEMENT_ARRAY_BUFFER.
  factory WebGLBuffer.fromIntList(web_gl.RenderingContext2 gl, int bufType, List<int> data) {
    final web_gl.Buffer buffer = gl.createBuffer();
    gl.bindBuffer(bufType, buffer);
    gl.bufferData(bufType, typed.Int16List.fromList(data), web_gl.WebGL.STATIC_DRAW);
    gl.bindBuffer(bufType, null);
    return WebGLBuffer(bufType, buffer);
  }

  /// Binds the buffer to prepare for rendering.
  @override
  void bind(core.RenderState state) {
    state.gl.bindBuffer(this._bufType, this._buf);
  }

  /// Unbinds the buffer when done rendering.
  @override
  void unbind(core.RenderState state) {
    state.gl.bindBuffer(this._bufType, null);
  }
}

/// Test double buffer used for testing shape creation.
class TestDoubleBuffer implements Buffer {
  /// Indicates the type of buffer, typically ARRAY_BUFFER.
  final int _bufType;

  /// The data stored by this buffer.
  final List<double> _buf;

  /// Creates a new test double buffer.
  TestDoubleBuffer(this._bufType, this._buf);

  /// Throws an error because test buffers may not be binded.
  @override
  void bind(core.RenderState state) {
    throw Exception("May not bind a test double buffer.");
  }

  /// Has no effect for testing.
  @override
  void unbind(core.RenderState state) {
    // Do Nothing
  }

  /// Gets the string for this buffer.
  @override
  String toString() {
    final List<String> parts = [];
    for (int i = 0; i < this._buf.length; ++i) {
      parts.add(math.formatDouble(this._buf[i]));
    }
    return "${this._bufType}:${parts.join(',')}";
  }
}

/// Test integer buffer used for testing shape creation.
class TestIntBuffer implements Buffer {
  /// Indicates the type of buffer, typically ELEMENT_ARRAY_BUFFER.
  final int _bufType;

  /// The data stored by this buffer.
  final List<int> _buf;

  /// Creates a new test integer buffer.
  TestIntBuffer(this._bufType, this._buf);

  /// Throws an error because test buffers may not be binded.
  @override
  void bind(core.RenderState state) {
    throw Exception("May not bind a test int buffer.");
  }

  /// Has no effect for testing.
  @override
  void unbind(core.RenderState state) {
    // Do Nothing
  }

  /// Gets the string for this buffer.
  @override
  String toString() {
    final List<String> parts = [];
    for (int i = 0; i < this._buf.length; ++i) {
      parts.add("${this._buf[i]}");
    }
    return "${this._bufType}: ${parts.join(', ')}";
  }
}

/// An attribute for a buffer to describe the contents in a buffer.
class BufferAttr extends core.Bindable {
  /// The type of vertex being stored.
  final VertexType _type;

  /// The size in bytes of the vertex being stored.
  final int _size;

  /// The offset in bytes from the beginning of vertex to this type.
  final int _offset;

  /// The stride in bytes between this type of elements in the buffer.
  final int _stride;

  /// The shader attribute identifier.
  int attr;

  /// Creates a new buffer attribute.
  ///
  /// [_type] is the type of vertex being stored.
  /// [_size] is the size in bytes of the vertex being stored.
  /// [_offset] is the offset in bytes from the beginning of vertex to this type.
  /// [_stride] is the stride in bytes between this type of elements in the buffer.
  /// [attr] is the initial shader attribute identifier.
  BufferAttr(
    final this._type,
    final this._size,
    final this._offset,
    final this._stride, [
    final this.attr = 0,
  ]);

  /// The type of vertex being stored.
  VertexType get type => _type;

  /// Binds this attribute to the render state so that it may
  /// be used when rendering from it's associated buffer.
  @override
  void bind(
    final core.RenderState state,
  ) {
    try {
      state.gl.enableVertexAttribArray(this.attr);
      state.gl.vertexAttribPointer(this.attr, this._size, web_gl.WebGL.FLOAT, false, this._stride, this._offset);
    } on Object catch (e) {
      throw Exception("Failed to bind buffer attribute \"${this._type.toString()}\": $e");
    }
  }

  /// Unbinds this attribute from the render state.
  @override
  void unbind(core.RenderState state) {
    state.gl.disableVertexAttribArray(this.attr);
  }

  /// Get the string for the buffer attribute.
  @override
  String toString() {
    return "[${this._type.toString()}, Size: ${this._size}, Offset: ${this._offset}, Stride: ${this._stride}, Attr: ${this.attr}]";
  }
}

/// A builder for creating buffers while building a cache for a shape.
abstract class BufferBuilder {
  /// Creates a new buffer from the given double list.
  Buffer fromDoubleList(int bufType, List<double> vertices);

  /// Creates a new buffer from the given integer list.
  Buffer fromIntList(int bufType, List<int> vertices);
}

/// A builder for creating WebGL buffers.
class WebGLBufferBuilder implements BufferBuilder {
  /// The rendering context to create buffers for.
  final web_gl.RenderingContext2 _gl;

  /// Creates a new WebGL buffer builder.
  WebGLBufferBuilder(this._gl);

  /// Creates a new buffer from the given double list.
  @override
  Buffer fromDoubleList(int bufType, List<double> vertices) {
    return WebGLBuffer.fromDoubleList(this._gl, bufType, vertices);
  }

  /// Creates a new buffer from the given integer list.
  @override
  Buffer fromIntList(int bufType, List<int> vertices) {
    return WebGLBuffer.fromIntList(this._gl, bufType, vertices);
  }
}

/// A builder for creating test buffers.
class TestBufferBuilder implements BufferBuilder {
  /// Creates a new test buffer builder.
  TestBufferBuilder();

  /// Creates a new buffer from the given double list.
  @override
  Buffer fromDoubleList(int bufType, List<double> vertices) {
    return TestDoubleBuffer(bufType, vertices);
  }

  /// Creates a new buffer from the given integer list.
  @override
  Buffer fromIntList(int bufType, List<int> vertices) {
    return TestIntBuffer(bufType, vertices);
  }
}

/// A storage for a shapes with the components required for a specific technique.
class BufferStore implements core.Bindable, TechniqueCache {
  /// The buffer storing all the vertex data for the shape.
  final Buffer _vertexBuf;

  /// The list of indices for the order of vertex rendering and type of rasterization.
  final List<IndexObject> _indexObjs;

  /// The list of buffer attributes describing the type of vertices in the buffer.
  final List<BufferAttr> _attrs;

  /// The vertex type stored in these buffers.
  final VertexType _vertexType;

  /// Creates a new buffer store.
  BufferStore(this._vertexBuf, this._attrs, this._vertexType) : this._indexObjs = [];

  /// The list of buffer attributes describing the type of vertices in the buffer.
  List<BufferAttr> get attributes => this._attrs;

  /// The list of indices for the order of vertex rendering and type of rasterization.
  List<IndexObject> get indexObjects => this._indexObjs;

  /// The vertex type stored in these buffers.
  VertexType get vertexType => this._vertexType;

  /// Finds the attribute which has the given type.
  BufferAttr? findAttribute(VertexType type) {
    for (final BufferAttr attr in this._attrs) {
      if (attr._type.has(type)) return attr;
    }
    return null;
  }

  /// Binds the buffer to prepare for rendering.
  @override
  void bind(core.RenderState state) {
    this._vertexBuf.bind(state);
    for (int i = this._attrs.length - 1; i >= 0; i--) {
      this._attrs[i].bind(state);
    }
  }

  /// Unbinds the buffer when done rendering.
  @override
  void unbind(core.RenderState state) {
    for (int i = this._attrs.length - 1; i >= 0; i--) {
      this._attrs[i].unbind(state);
    }
    this._vertexBuf.unbind(state);
  }

  /// Renders the buffer with the current technique.
  ///
  /// The buffer must be bound to the state first.
  void render(core.RenderState state) {
    final int objCount = this._indexObjs.length;
    for (int i = 0; i < objCount; i++) {
      final IndexObject indexObj = this._indexObjs[i];
      indexObj.buffer.bind(state);
      state.gl.drawElements(indexObj.type, indexObj.count, web_gl.WebGL.UNSIGNED_SHORT, 0);
      indexObj.buffer.unbind(state);
    }
  }

  /// Binds the buffers, renders, then unbinds with the given state.
  void oneRender(core.RenderState state) {
    this.bind(state);
    this.render(state);
    this.unbind(state);
  }

  /// Gets the string for this buffer store.
  @override
  String toString() {
    final List<String> indexStr = [];
    for (final IndexObject obj in this._indexObjs) {
      indexStr.add(obj.toString());
    }
    final List<String> attrStr = [];
    for (final BufferAttr attr in this._attrs) {
      attrStr.add(attr.toString());
    }
    return "Buffer:  [${this._vertexBuf}]\nIndices: ${indexStr.join(", ")}\nAttrs:   ${attrStr.join(", ")}";
  }
}

/// A list of buffer stores used as a single cache.
class BufferStoreList implements TechniqueCache {
  /// The list of cached buffer stores.
  final List<BufferStore> _list;

  /// Creates a new buffer store list.
  BufferStoreList() : this._list = [];

  /// The list of cached buffer stores.
  List<BufferStore> get list => this._list;
}

/// A map of strings to buffer stores used as a single cache.
class BufferStoreSet implements TechniqueCache {
  /// The map of cached buffer stores.
  final Map<String, BufferStore> _map;

  /// Creates a new buffer store map.
  BufferStoreSet() : this._map = {};

  /// The map of cached buffer stores.
  Map<String, BufferStore> get map => this._map;
}

/// The indices for the order of vertex rendering and type of rasterization.
class IndexObject {
  /// The type of rasterization to use.
  final int type;

  /// The number of indices in the buffer.
  final int count;

  /// The buffer of indices for a shape.
  final Buffer buffer;

  /// Creates an index object for a shape.
  /// [type] is the type of rasterization to use.
  /// [count] is the number of indices in the buffer.
  /// [buffer] is the buffer of indices for a shape.
  IndexObject(this.type, this.count, this.buffer);

  /// Gets the string for this index Entity.
  @override
  String toString() {
    return "Type: ${this.type}, Count: ${this.count}, [${this.buffer.toString()}]";
  }
}

/// A cache for a shape with the components required for a specific technique.
abstract class TechniqueCache {
  // Empty
}

/// A vertex type or group of types for creating simple shapes.
class VertexType {
  /// [None] indicates no vertex type at all.
  static final VertexType None = VertexType._(0x0000);

  /// [All] indicates all vertex types.
  static final VertexType All = VertexType._(0x01FF);

  /// [Pos] indicates 3D positional data.
  static final VertexType Pos = VertexType._(0x0001);

  /// [Norm] indicates 3D normal data.
  static final VertexType Norm = VertexType._(0x0002);

  /// [Binm] indicates 3D binormal data.
  static final VertexType Binm = VertexType._(0x0004);

  /// [Txt2D] indicates 2D texture data.
  static final VertexType Txt2D = VertexType._(0x0008);

  /// [TxtCube] indicates cube texture data.
  static final VertexType TxtCube = VertexType._(0x0010);

  /// [Clr3] indicates RGB color data.
  static final VertexType Clr3 = VertexType._(0x0020);

  /// [Clr4] indicates RGBA color data.
  static final VertexType Clr4 = VertexType._(0x0040);

  /// [Clr3] indicates RGB or RGBA color data.
  static final VertexType Color = VertexType._(0x0060);

  /// [Weight] indicates an additional single float data.
  static final VertexType Weight = VertexType._(0x0080);

  /// [Bending] indicates float data for bending a shape.
  static final VertexType Bending = VertexType._(0x0100);

  /// The combined vertex type value.
  final int _value;

  /// Creates a new vertex type.
  VertexType._(this._value);

  /// Combines two vertex types into one.
  VertexType operator |(VertexType right) => VertexType._(this._value | right._value);

  /// Unions two vertex types.
  VertexType operator &(VertexType right) => VertexType._(this._value & right._value);

  /// Gets the opposite of this type.
  VertexType operator ~() => VertexType._(All._value & ~this._value);

  /// The internal value of the vertex type.
  int get value => this._value;

  /// Determines if this vertex type contains the given type.
  bool has(VertexType type) => (this._value & type._value) != 0x00;

  /// The number of vertex types combined into this type.
  int get count {
    int result = 0;
    if (this.has(Pos)) result++;
    if (this.has(Norm)) result++;
    if (this.has(Binm)) result++;
    if (this.has(Txt2D)) result++;
    if (this.has(TxtCube)) result++;
    if (this.has(Clr3)) result++;
    if (this.has(Clr4)) result++;
    if (this.has(Weight)) result++;
    if (this.has(Bending)) result++;
    return result;
  }

  /// The total number of floats in the vertex type.
  int get size {
    int result = 0;
    if (this.has(Pos)) result += 3;
    if (this.has(Norm)) result += 3;
    if (this.has(Binm)) result += 3;
    if (this.has(Txt2D)) result += 2;
    if (this.has(TxtCube)) result += 3;
    if (this.has(Clr3)) result += 3;
    if (this.has(Clr4)) result += 4;
    if (this.has(Weight)) result += 1;
    if (this.has(Bending)) result += 4;
    return result;
  }

  /// The vertex type at the given [index].
  VertexType at(int index) {
    int count = 0;
    if (this.has(Pos)) {
      if (count == index) return Pos;
      count++;
    }
    if (this.has(Norm)) {
      if (count == index) return Norm;
      count++;
    }
    if (this.has(Binm)) {
      if (count == index) return Binm;
      count++;
    }
    if (this.has(Txt2D)) {
      if (count == index) return Txt2D;
      count++;
    }
    if (this.has(TxtCube)) {
      if (count == index) return TxtCube;
      count++;
    }
    if (this.has(Clr3)) {
      if (count == index) return Clr3;
      count++;
    }
    if (this.has(Clr4)) {
      if (count == index) return Clr4;
      count++;
    }
    if (this.has(Weight)) {
      if (count == index) return Weight;
      count++;
    }
    if (this.has(Bending)) {
      if (count == index) return Bending;
      count++;
    }
    return None;
  }

  /// The index of the given [type] in this combined type.
  int indexOf(VertexType type) {
    int result = 0;
    if (this.has(Pos)) {
      if (type == Pos) return result;
      result++;
    }
    if (this.has(Norm)) {
      if (type == Norm) return result;
      result++;
    }
    if (this.has(Binm)) {
      if (type == Binm) return result;
      result++;
    }
    if (this.has(Txt2D)) {
      if (type == Txt2D) return result;
      result++;
    }
    if (this.has(TxtCube)) {
      if (type == TxtCube) return result;
      result++;
    }
    if (this.has(Clr3)) {
      if (type == Clr3) return result;
      result++;
    }
    if (this.has(Clr4)) {
      if (type == Clr4) return result;
      result++;
    }
    if (this.has(Weight)) {
      if (type == Weight) return result;
      result++;
    }
    if (this.has(Bending)) {
      if (type == Bending) return result;
      //result++;
    }
    return -1;
  }

  /// The number of floats to the given [type] in this combined type.
  int offset(VertexType type) {
    int result = 0;
    if (this.has(Pos)) {
      if (type == Pos) return result;
      result += 3;
    }
    if (this.has(Norm)) {
      if (type == Norm) return result;
      result += 3;
    }
    if (this.has(Binm)) {
      if (type == Binm) return result;
      result += 3;
    }
    if (this.has(Txt2D)) {
      if (type == Txt2D) return result;
      result += 2;
    }
    if (this.has(TxtCube)) {
      if (type == TxtCube) return result;
      result += 3;
    }
    if (this.has(Clr3)) {
      if (type == Clr3) return result;
      result += 3;
    }
    if (this.has(Clr4)) {
      if (type == Clr4) return result;
      result += 4;
    }
    if (this.has(Weight)) {
      if (type == Weight) return result;
      result += 1;
    }
    if (this.has(Bending)) {
      if (type == Bending) return result;
      result += 4;
    }
    return -1;
  }

  /// Determines if the given [other] variable is a [VertexType] equal to this value.
  @override
  bool operator ==(Object other) {
    if (other is! VertexType) return false;
    return this._value == other._value;
  }

  @override
  int get hashCode => _value.hashCode;

  /// The string for this vertex type.
  @override
  String toString() {
    final List<String> parts = [];
    if (this.has(Pos)) parts.add("Pos");
    if (this.has(Norm)) parts.add("Norm");
    if (this.has(Binm)) parts.add("Binm");
    if (this.has(Txt2D)) parts.add("Txt2D");
    if (this.has(TxtCube)) parts.add("TxtCube");
    if (this.has(Clr3)) parts.add("Clr3");
    if (this.has(Clr4)) parts.add("Clr4");
    if (this.has(Weight)) parts.add("Weight");
    if (this.has(Bending)) parts.add("Bending");
    if (parts.isEmpty) return "None";
    return parts.join("|");
  }
}
