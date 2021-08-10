// Textures defines how to load and store images for rendering.
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data' as typed;
import 'dart:web_gl' as webgl;

import '../core/core.dart';
import '../events/events.dart';
import '../input/input.dart';
import '../math/math.dart';

/// A roller which rotates an object in response to user input.
class ColorPicker implements Interactable, Changeable {
  /// Texture loader used to read the colors from the given texture.
  final TextureLoader _loader;

  /// The user input this roller is attached to.
  UserInput? _input;

  /// Indicates if the modifier keys which must be pressed or released.
  Modifiers? _modPressed;

  /// The texture to pick colors from.
  Texture2D? _txt;

  /// Event for handling changes to this picker.
  Event? _changed;

  /// Event emitted before an update for this picker.
  Event? _preUpdate;

  /// Event emitted after an update for this picker.
  Event? _postUpdate;

  /// Event for handling when a color has been picked.
  Event? _colorPicked;

  /// The range, in pixels, of the dead band.
  double _deadBand;

  /// The dead band squared.
  double _deadBand2;

  /// True indicating the mouse is pressed, false for released.
  bool _pressed;

  /// Indicates if the mouse has left the dead band area yet.
  bool _inDeadBand;

  /// Creates a new user rotator instance.
  /// If [mod] is provided it will override any value given to [ctrl], [alt], and [shift].
  ColorPicker(this._loader,
      {bool ctrl = false,
      bool alt = false,
      bool shift = false,
      Texture2D? txt,
      Modifiers? mod,
      UserInput? input})
      : this._input = null,
        this._modPressed = null,
        this._txt = null,
        this._changed = null,
        this._preUpdate = null,
        this._postUpdate = null,
        this._colorPicked = null,
        this._deadBand = 2.0,
        this._deadBand2 = 4.0,
        this._pressed = false,
        this._inDeadBand = false {
    this.modifiers = mod ?? Modifiers(ctrl, alt, shift);
    this.texture = txt;
    this.attach(input);
  }

  /// Emits when the picker has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a child picker being changed.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Event emitted before an update for this picker.
  Event get onPreUpdate => this._preUpdate ??= Event();

  /// Event emitted after an update for this picker.
  Event get onPostUpdate => this._postUpdate ??= Event();

  /// Emits when the picker has changed.
  Event get colorPicked => this._colorPicked ??= Event();

  /// Handles prior to a color being picked.
  void _onPreUpdate([EventArgs? args]) => this._preUpdate?.emit(args);

  /// Handles after a color being picked.
  void _onPostUpdate([EventArgs? args]) => this._postUpdate?.emit(args);

  /// Handles a color being picked.
  void _onColorPicked([EventArgs? args]) => this._colorPicked?.emit(args);

  /// The texture to pick color from.
  Texture2D? get texture => this._txt;

  set texture(Texture2D? txt) {
    if (this._txt != txt) {
      this._txt?.changed.remove(this._onChanged);
      final Texture2D? prev = this._txt;
      this._txt = txt;
      this._txt?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, "texture", prev, this._txt));
    }
  }

  /// Indicates if the modifiers keys must be pressed or released.
  Modifiers? get modifiers => this._modPressed;

  set modifiers(Modifiers? mods) {
    // ignore: parameter_assignments
    mods ??= Modifiers.none();
    if (this._modPressed != mods) {
      final Modifiers? prev = this._modPressed;
      this._modPressed = mods;
      this._onChanged(ValueChangedEventArgs(this, "modifiers", prev, mods));
    }
  }

  /// The dead-band, in pixels, before any movement is made.
  /// This does not apply when the mouse is locked.
  double get deadBand => this._deadBand;

  set deadBand(double value) {
    if (!Comparer.equals(this._deadBand, value)) {
      final double prev = this._deadBand;
      this._deadBand = value;
      this._deadBand2 = this._deadBand * this._deadBand;
      this._onChanged(ValueChangedEventArgs(this, "deadBand", prev, this._deadBand));
    }
  }

  /// Attaches this picker to the user input.
  @override
  bool attach(UserInput? input) {
    if (input == null) return false;
    if (this._input != null) return false;
    this._input = input;
    input.mouse.down.add(this._mouseDownHandle);
    input.mouse.move.add(this._mouseMoveHandle);
    input.mouse.up.add(this._mouseUpHandle);
    input.touch.start.add(this._touchStartHandle);
    input.touch.move.add(this._touchMoveHandle);
    input.touch.end.add(this._touchEndHandle);
    return true;
  }

  /// Detaches this picker from the user input.
  @override
  void detach() {
    final input = this._input;
    if (input != null) {
      input.mouse.down.remove(this._mouseDownHandle);
      input.mouse.move.remove(this._mouseMoveHandle);
      input.mouse.up.remove(this._mouseUpHandle);
      input.touch.start.remove(this._touchStartHandle);
      input.touch.move.remove(this._touchMoveHandle);
      input.touch.end.remove(this._touchEndHandle);
      this._input = null;
    }
  }

  /// Handles the mouse down event.
  void _mouseDownHandle(EventArgs args) {
    final MouseEventArgs margs = args as MouseEventArgs;
    if (margs.button.modifiers != this._modPressed) return;
    this._pressed = true;
    this._inDeadBand = true;
  }

  /// Handles the mouse move event.
  void _mouseMoveHandle(EventArgs args) {
    if (!this._pressed) return;
    if (this._inDeadBand) {
      final MouseEventArgs margs = args as MouseEventArgs;
      if (margs.rawOffset.length2() < this._deadBand2) return;
      this._inDeadBand = false;
    }
  }

  /// Handle the mouse up event.
  void _mouseUpHandle(EventArgs args) {
    if (!this._pressed) return;
    this._pressed = false;
    if (!this._inDeadBand) return;
    this._pickColor(args);
  }

  /// Handle the touch screen touch start.
  void _touchStartHandle(EventArgs args) {
    this._pressed = true;
    this._inDeadBand = true;
  }

  /// Handle the touch screen move.
  void _touchMoveHandle(EventArgs args) {
    if (!this._pressed) return;
    if (this._inDeadBand) {
      final TouchEventArgs targs = args as TouchEventArgs;
      if (targs.rawOffset.length2() < this._deadBand2) return;
      this._inDeadBand = false;
    }
  }

  /// Handle the touch screen end.
  void _touchEndHandle(EventArgs args) {
    if (!this._pressed) return;
    this._pressed = false;
    if (!this._inDeadBand) return;
    this._pickColor(args);
  }

  /// This handles determining the color for the location and
  /// emitting a color picker event arguments.
  void _pickColor(EventArgs args) {
    final txt = this._txt;
    if (txt == null) return;
    final MouseEventArgs margs = args as MouseEventArgs;
    this._onPreUpdate(EventArgs(this));
    final double dx = margs.rawPoint.x / margs.size.dx;
    final double dy = margs.rawPoint.y / margs.size.dy;
    final Vector2 loc = Vector2(dx, dy);
    final Color4 clr = this._loader.pickColor(txt, loc);
    this._onColorPicked(ColorPickerEventArgs(this, loc, clr));
    this._onPostUpdate(EventArgs(this));
  }
}

/// The event argument for event's with information about entities changing.
class ColorPickerEventArgs extends EventArgs {
  /// The location the color was picked from.
  final Vector2 location;

  /// The color which was picked.
  final Color4 color;

  /// Creates an entity event argument.
  ColorPickerEventArgs(Object sender, this.location, this.color) : super(sender);

  /// The string for this event argument.
  @override
  String toString() => "ColorPicker: $location => $color";
}

/// The base for all texture and surface types.
abstract class Texture extends Bindable implements Changeable {
  /// The index of the texture when bound to the rendering context.
  int get index;

  set index(int index);
}

/// An interface for 2D texture.
abstract class Texture2D extends Texture {
  /// The internal texture instance.
  webgl.Texture? get texture;

  /// The loaded state of the texture.
  bool get loaded;

  /// Ths width of the image in pixels as requested or loaded from file.
  int get width;

  /// Ths height of the image in pixels as requested or loaded from file.
  int get height;

  /// The width of the image in pixels allowed by this machine's architecture.
  int get actualWidth;

  /// The height of the image in pixels allowed by this machine's architecture.
  int get actualHeight;
}

/// A 2D texture changer for cycling between images.
class Texture2DChanger extends Texture2D {
  int _index;
  int _listIndex;
  Texture2D? _current;
  Texture2D? _bound;
  final List<Texture2D> _textures;
  Event? _changed;

  /// Creates a new 2D texture.
  Texture2DChanger({int index = 0, List<Texture2D>? textures})
      : this._index = index,
        this._listIndex = 0,
        this._current = null,
        this._bound = null,
        this._textures = textures ?? [],
        this._changed = null;

  /// The index of the texture when bound to the rendering context.
  @override
  int get index => this._index;

  @override
  set index(int index) => this._index = index;

  /// This is the bound texture being used or the current texture assigned
  /// which will be bound during the next render.
  Texture2D? get _active => this._bound ?? this._current;

  /// The internal texture instance.
  @override
  webgl.Texture? get texture => this._active?.texture;

  /// The loaded state of the texture.
  @override
  bool get loaded => this._active?.loaded ?? false;

  /// Ths width of the image in pixels as requested or loaded from file.
  @override
  int get width => this._active?.width ?? 0;

  /// Ths height of the image in pixels as requested or loaded from file.
  @override
  int get height => this._active?.height ?? 0;

  /// The width of the image in pixels allowed by this machine's architecture.
  @override
  int get actualWidth => this._active?.actualWidth ?? 0;

  /// The height of the image in pixels allowed by this machine's architecture.
  @override
  int get actualHeight => this._active?.actualHeight ?? 0;

  /// Emitted when the texture has finished being loaded or replaced.
  ///
  /// On change typically indicates a new render is needed.
  @override
  Event get changed => this._changed ??= Event();

  /// The index of the texture when bound to the rendering context.
  int get currentIndex => this._listIndex;

  set currentIndex(int index) {
    if ((index >= 0) && (index < this._textures.length)) {
      this._listIndex = index;
      this._current = this._textures[index];
      this._changed?.emit();
    }
  }

  /// Selects the next texture or cycles back to the first texture.
  void nextTexture() {
    this.currentIndex = (this._listIndex + 1) % this._textures.length;
  }

  /// Selects the previous texture or cycles back to the last texture.
  void previousTexture() {
    final int count = this._textures.length;
    this.currentIndex = (this._listIndex + count - 1) % count;
  }

  // The list of textures to cycle through.
  List<Texture2D> get textures => this._textures;

  /// Binds some data to the given [state].
  @override
  void bind(RenderState state) {
    if (this._bound == null) {
      this._bound = this._current;
      this._bound?.bind(state);
    }
  }

  /// Unbinds the bound data from the given [state].
  @override
  void unbind(RenderState state) {
    if (this._bound != null) {
      this._bound?.unbind(state);
      this._bound = null;
    }
  }
}

/// A 2D texture.
class Texture2DSolid extends Texture2D {
  int _index;
  webgl.Texture? _texture;
  bool _bound;
  bool _loaded;
  int _width;
  int _height;
  int _actualWidth;
  int _actualHeight;
  Event? _changed;

  /// Creates a new 2D texture.
  Texture2DSolid({int index = 0, webgl.Texture? texture})
      : this._index = index,
        this._texture = texture,
        this._bound = false,
        this._loaded = false,
        this._width = 0,
        this._height = 0,
        this._actualWidth = 0,
        this._actualHeight = 0,
        this._changed = null;

  /// Creates a new 2D image from the given [width] and [height].
  factory Texture2DSolid.fromSize(webgl.RenderingContext2 gl, int width, int height, {bool wrapEdges = false}) {
    int maxSize = (gl.getParameter(webgl.WebGL.MAX_TEXTURE_SIZE) as int?)!;
    int aWidth = nearestPower(width);
    int aHeight = nearestPower(height);
    maxSize = nearestPower(maxSize);
    aWidth = math.min(aWidth, maxSize);
    aHeight = math.min(aHeight, maxSize);

    final webgl.Texture texture = gl.createTexture();
    gl.bindTexture(webgl.WebGL.TEXTURE_2D, texture);
    if (wrapEdges) {
      gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_WRAP_S, webgl.WebGL.REPEAT);
      gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_WRAP_T, webgl.WebGL.REPEAT);
    } else {
      gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_WRAP_S, webgl.WebGL.CLAMP_TO_EDGE);
      gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_WRAP_T, webgl.WebGL.CLAMP_TO_EDGE);
    }
    gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_MIN_FILTER, webgl.WebGL.LINEAR);
    gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_MAG_FILTER, webgl.WebGL.LINEAR);
    gl.texImage2D(webgl.WebGL.TEXTURE_2D, 0, webgl.WebGL.RGBA, aWidth, aHeight, 0, webgl.WebGL.RGBA,
        webgl.WebGL.UNSIGNED_BYTE, null);
    gl.bindTexture(webgl.WebGL.TEXTURE_2D, null);

    final Texture2DSolid result = Texture2DSolid(texture: texture);
    result._width = width;
    result._height = height;
    result._actualWidth = aWidth;
    result._actualHeight = aHeight;
    result._setLoaded();
    return result;
  }

  /// Sets the loaded state for this texture.
  void _setLoaded() {
    if (!this._loaded) {
      this._loaded = true;
      this._changed?.emit();
    }
  }

  /// The index of the texture when bound to the rendering context.
  @override
  int get index => this._index;

  @override
  set index(int index) => this._index = index;

  /// The internal texture instance.
  @override
  webgl.Texture? get texture => this._texture;

  /// The loaded state of the texture.
  @override
  bool get loaded => this._loaded;

  /// Ths width of the image in pixels as requested or loaded from file.
  @override
  int get width => this._width;

  /// Ths height of the image in pixels as requested or loaded from file.
  @override
  int get height => this._height;

  /// The width of the image in pixels allowed by this machine's architecture.
  @override
  int get actualWidth => this._actualWidth;

  /// The height of the image in pixels allowed by this machine's architecture.
  @override
  int get actualHeight => this._actualHeight;

  /// Emitted when the texture has finished being loaded or replaced.
  ///
  /// On change typically indicates a new render is needed.
  @override
  Event get changed => this._changed ??= Event();

  /// This replaces the internals of this texture with the given [txt].
  void replace(Texture2DSolid? txt) {
    if (txt == null) {
      this._texture = null;
      this._loaded = false;
      this._width = 0;
      this._height = 0;
      this._actualWidth = 0;
      this._actualHeight = 0;
      this._changed?.emit();
    } else {
      this._texture = txt._texture;
      this._bound = txt._bound;
      this._loaded = txt._loaded;
      this._width = txt._width;
      this._height = txt._height;
      this._actualWidth = txt._actualWidth;
      this._actualHeight = txt._actualHeight;
      this._changed?.emit();
    }
  }

  /// Binds some data to the given [state].
  @override
  void bind(RenderState state) {
    if (!this._bound && this._loaded) {
      this._bound = true;
      state.gl.activeTexture(webgl.WebGL.TEXTURE0 + this.index);
      state.gl.bindTexture(webgl.WebGL.TEXTURE_2D, this._texture);
    }
  }

  /// Unbinds the bound data from the given [state].
  @override
  void unbind(RenderState state) {
    if (this._bound) {
      this._bound = false;
      state.gl.activeTexture(webgl.WebGL.TEXTURE0 + this.index);
      state.gl.bindTexture(webgl.WebGL.TEXTURE_2D, null);
    }
  }
}

/// A cube map texture.
///
/// Cube map textures are good for rendering reflections,
/// refractions, and sky boxes.
class TextureCube extends Texture {
  int _index;
  final webgl.Texture? _texture;
  bool _bound;
  int _loaded;
  Event? _changed;

  /// Creates a new cube map texture.
  TextureCube({int index = 0, webgl.Texture? texture})
      : this._index = index,
        this._texture = texture,
        this._bound = false,
        this._loaded = 0,
        this._changed = null;

  /// Increments the loaded value of the images.
  void _incLoaded() {
    this._loaded++;
    if (this.loaded) this._changed?.emit();
  }

  /// The index of the texture when bound to the rendering context.
  @override
  int get index => this._index;

  @override
  set index(int index) => this._index = index;

  /// The loaded state of the texture.
  bool get loaded => this._loaded >= 6;

  /// Emitted when the texture has finished being loaded.
  @override
  Event get changed => this._changed ??= Event();

  /// Binds some data to the given [state].
  @override
  void bind(RenderState state) {
    if (!this._bound && this.loaded) {
      this._bound = true;
      state.gl.activeTexture(webgl.WebGL.TEXTURE0 + this.index);
      state.gl.bindTexture(webgl.WebGL.TEXTURE_CUBE_MAP, this._texture);
    }
  }

  /// Unbinds the bound data from the given [state].
  @override
  void unbind(RenderState state) {
    if (this._bound) {
      this._bound = false;
      state.gl.activeTexture(webgl.WebGL.TEXTURE0 + this.index);
      state.gl.bindTexture(webgl.WebGL.TEXTURE_CUBE_MAP, null);
    }
  }
}

/// A loader for loading textures.
class TextureLoader {
  final webgl.RenderingContext2 _gl;
  final int _max2DSize;
  final int _maxCubeSize;
  int _imageCount;
  int _loadedCount;

  /// Creates a new texture loader.
  TextureLoader(
    final webgl.RenderingContext2 gl,
  )   : this._gl = gl,
        this._max2DSize = (gl.getParameter(webgl.WebGL.MAX_TEXTURE_SIZE) as int?)!,
        this._maxCubeSize = (gl.getParameter(webgl.WebGL.MAX_CUBE_MAP_TEXTURE_SIZE) as int?)!,
        this._imageCount = 0,
        this._loadedCount = 0;

  /// The number of textures being loaded.
  int get loading => this._imageCount - this._loadedCount;

  /// The percentage of textures loaded.
  double get percentage => (this._imageCount == 0) ? 100.0 : this._loadedCount * 100.0 / this._imageCount;

  /// Resets the loading counters.
  void resetCounter() {
    this._imageCount = 0;
    this._loadedCount = 0;
  }

  /// Loads a file from the given [path].
  /// The image will load asynchronously.
  Texture2D load2DFromFile(String path,
      {bool flipY = false, bool wrapEdges = false, bool mipMap = false, bool nearest = false}) {
    final webgl.Texture texture = this._gl.createTexture();
    this._gl.bindTexture(webgl.WebGL.TEXTURE_2D, texture);
    if (wrapEdges) {
      this._gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_WRAP_S, webgl.WebGL.REPEAT);
      this._gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_WRAP_T, webgl.WebGL.REPEAT);
    } else {
      this._gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_WRAP_S, webgl.WebGL.CLAMP_TO_EDGE);
      this._gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_WRAP_T, webgl.WebGL.CLAMP_TO_EDGE);
    }
    final int min = nearest
        ? (mipMap ? webgl.WebGL.NEAREST_MIPMAP_NEAREST : webgl.WebGL.NEAREST)
        : (mipMap ? webgl.WebGL.LINEAR_MIPMAP_LINEAR : webgl.WebGL.LINEAR);
    this._gl.texParameteri(webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_MIN_FILTER, min);
    this._gl.texParameteri(
        webgl.WebGL.TEXTURE_2D, webgl.WebGL.TEXTURE_MAG_FILTER, nearest ? webgl.WebGL.NEAREST : webgl.WebGL.LINEAR);
    this._gl.bindTexture(webgl.WebGL.TEXTURE_2D, null);

    this._incLoading();
    final html.ImageElement image = html.ImageElement(src: path);
    final Texture2DSolid result = Texture2DSolid(texture: texture);
    image.onLoad.listen((_) {
      result._width = image.width ?? 512;
      result._height = image.height ?? 512;
      final dynamic data = this._resizeImage(image, this._max2DSize, nearest);
      result._actualWidth = image.width ?? 512;
      result._actualHeight = image.height ?? 512;

      this._gl.bindTexture(webgl.WebGL.TEXTURE_2D, texture);
      this._gl.pixelStorei(webgl.WebGL.UNPACK_FLIP_Y_WEBGL, flipY ? 1 : 0);
      this
          ._gl
          .texImage2D(webgl.WebGL.TEXTURE_2D, 0, webgl.WebGL.RGBA, webgl.WebGL.RGBA, webgl.WebGL.UNSIGNED_BYTE, data);
      if (mipMap) this._gl.generateMipmap(webgl.WebGL.TEXTURE_2D);
      this._gl.bindTexture(webgl.WebGL.TEXTURE_2D, null);
      result._setLoaded();
      this._decLoading();
    });
    return result;
  }

  /// Loads files from the given path.
  /// The images will load asynchronously.
  /// The files must be named: 'posx.png', 'negx.png', 'posy.png', etc.
  TextureCube loadCubeFromPath(String path, {String pre = '', String ext = '.png', bool flipY = false}) {
    return this.loadCubeFromFiles('$path/${pre}posx${ext}', '$path/${pre}posy${ext}', '$path/${pre}posz${ext}',
        '$path/${pre}negx${ext}', '$path/${pre}negy${ext}', '$path/${pre}negz${ext}',
        flipY: flipY);
  }

  /// Loads files from the given paths.
  /// The images will load asynchronously.
  TextureCube loadCubeFromFiles(
      String posXPath, String posYPath, String posZPath, String negXPath, String negYPath, String negZPath,
      {bool flipY = false}) {
    final webgl.Texture texture = this._gl.createTexture();
    this._gl.bindTexture(webgl.WebGL.TEXTURE_CUBE_MAP, texture);
    this._gl.texParameteri(webgl.WebGL.TEXTURE_CUBE_MAP, webgl.WebGL.TEXTURE_WRAP_S, webgl.WebGL.REPEAT);
    this._gl.texParameteri(webgl.WebGL.TEXTURE_CUBE_MAP, webgl.WebGL.TEXTURE_WRAP_T, webgl.WebGL.REPEAT);
    this._gl.texParameteri(webgl.WebGL.TEXTURE_CUBE_MAP, webgl.WebGL.TEXTURE_MIN_FILTER, webgl.WebGL.LINEAR);
    this._gl.texParameteri(webgl.WebGL.TEXTURE_CUBE_MAP, webgl.WebGL.TEXTURE_MAG_FILTER, webgl.WebGL.LINEAR);
    this._gl.bindTexture(webgl.WebGL.TEXTURE_CUBE_MAP, null);

    final TextureCube result = TextureCube(texture: texture);
    this._loadCubeFace(result, texture, posXPath, webgl.WebGL.TEXTURE_CUBE_MAP_POSITIVE_X, flipY, false);
    this._loadCubeFace(result, texture, negXPath, webgl.WebGL.TEXTURE_CUBE_MAP_NEGATIVE_X, flipY, false);
    this._loadCubeFace(result, texture, posYPath, webgl.WebGL.TEXTURE_CUBE_MAP_POSITIVE_Y, flipY, false);
    this._loadCubeFace(result, texture, negYPath, webgl.WebGL.TEXTURE_CUBE_MAP_NEGATIVE_Y, flipY, false);
    this._loadCubeFace(result, texture, posZPath, webgl.WebGL.TEXTURE_CUBE_MAP_POSITIVE_Z, flipY, false);
    this._loadCubeFace(result, texture, negZPath, webgl.WebGL.TEXTURE_CUBE_MAP_NEGATIVE_Z, flipY, false);
    return result;
  }

  /// Reads the entire given [texture] into the reader buffer.
  TextureReader readAll(Texture2D texture, [bool flipY = true]) => TextureReader._read(this._gl, texture, flipY: flipY);

  /// Reads the given range of the given [texture] into the reader buffer.
  /// The x, y, width, and height are based on actual buffer size.
  TextureReader read(Texture2D texture, int x, int y, int width, int height, [bool flipY = true]) =>
      TextureReader._read(this._gl, texture, x: x, y: y, width: width, height: height, flipY: flipY);

  /// Reads a color out of the given texture.
  Color4 pickColor(Texture2D texture, Vector2 loc, [bool flipY = true]) {
    final int adjX = (loc.dx * (texture.actualWidth - 1)).floor();
    final int adjY = (loc.dy * (texture.actualHeight - 1)).floor();
    final TextureReader reader = this.read(texture, adjX, adjY, 1, 1, flipY);
    return reader.at(0, 0);
  }

  /// Loads a face from the given path.
  /// The image will load asynchronously.
  void _loadCubeFace(TextureCube result, webgl.Texture texture, String path, int face, bool flipY, bool nearest) {
    final html.ImageElement image = html.ImageElement(src: path);
    this._incLoading();
    image.onLoad.listen((_) {
      final dynamic data = this._resizeImage(image, this._maxCubeSize, nearest);
      this._gl.bindTexture(webgl.WebGL.TEXTURE_CUBE_MAP, texture);
      this._gl.pixelStorei(webgl.WebGL.UNPACK_FLIP_Y_WEBGL, flipY ? 1 : 0);
      this._gl.texImage2D(face, 0, webgl.WebGL.RGBA, webgl.WebGL.RGBA, webgl.WebGL.UNSIGNED_BYTE, data);
      this._gl.bindTexture(webgl.WebGL.TEXTURE_CUBE_MAP, null);
      result._incLoaded();
      this._decLoading();
    });
  }

  /// Resizes the given image to the maximum size proportional to the power of 2.
  dynamic _resizeImage(html.ImageElement image, int maxSize, bool nearest) {
    // ignore: parameter_assignments
    maxSize = nearestPower(maxSize);
    int width = nearestPower(image.width ?? 512);
    int height = nearestPower(image.height ?? 512);
    width = math.min(width, maxSize);
    height = math.min(height, maxSize);
    if ((image.width == width) && (image.height == height)) {
      return image;
    } else {
      final  canvas = html.CanvasElement()
        ..width = width
        ..height = height;
      final ctx = (canvas.getContext('2d') as html.CanvasRenderingContext2D?)!;
      ctx.imageSmoothingEnabled = nearest;
      ctx.drawImageScaled(image, 0, 0, canvas.width ?? 512, canvas.height ?? 512);
      return ctx.getImageData(0, 0, canvas.width ?? 512, canvas.height ?? 512);
    }
  }

  /// Increments the loading count.
  void _incLoading() => this._imageCount++;

  /// Decrement the loading count.
  void _decLoading() => this._loadedCount++;
}

/// A 2D texture reader for getting the color from a texture.
class TextureReader {
  typed.Uint8List _data;
  final int _width;
  final int _height;

  /// Reads the given range of the given [texture] into the reader buffer.
  /// The x, y, width, and height are based on actual buffer size.
  factory TextureReader._read(webgl.RenderingContext2 gl, Texture2D texture,
      {int x = 0, int y = 0, int? width, int? height, bool flipY = false}) {
    width ??= texture.actualWidth;
    height ??= texture.actualHeight;

    if (flipY) y = texture.actualHeight - height - y;

    final webgl.Framebuffer fb = gl.createFramebuffer();
    gl.bindFramebuffer(webgl.WebGL.FRAMEBUFFER, fb);
    gl.readBuffer(webgl.WebGL.COLOR_ATTACHMENT0);
    gl.framebufferTexture2D(
        webgl.WebGL.FRAMEBUFFER, webgl.WebGL.COLOR_ATTACHMENT0, webgl.WebGL.TEXTURE_2D, texture.texture, 0);

    final typed.Uint8List data = typed.Uint8List(width * height * 4);
    gl.readPixels(x, y, width, height, webgl.WebGL.RGBA, webgl.WebGL.UNSIGNED_BYTE, data);
    gl.bindFramebuffer(webgl.WebGL.FRAMEBUFFER, null);
    final TextureReader reader = TextureReader._(data, width, height);

    // Update once WebGL allows a readPixels flag setting similar to "UNPACK_FLIP_Y_WEBGL".
    if (flipY) reader._flipYInternal();
    return reader;
  }

  /// Creates a new 2D texture reader.
  TextureReader._(this._data, this._width, this._height);

  /// Gets the buffer for the reader.
  typed.Uint8List get data => this._data;

  /// Gets the width of the read section.
  int get width => this._width;

  /// Gets the height of the read section.
  int get height => this._height;

  /// Gets the color at the given texture 2D location.
  Color4 atLoc(Point2 txt2D) {
    final int x = (txt2D.x * (this._width - 1)).floor();
    final int y = (txt2D.y * (this._height - 1)).floor();
    return this.at(x, y);
  }

  /// Gets the color at the given location.
  Color4 at(int x, int y) {
    if (x >= 0) {
      // ignore: parameter_assignments
      x %= this._width;
    } else {
      // ignore: parameter_assignments
      x = this._width + (x % this._width);
    }
    if (y >= 0) {
      // ignore: parameter_assignments
      y %= this._height;
    } else {
      // ignore: parameter_assignments
      y = this._height + (y % this._height);
    }
    final int offset = (x + y * this._width) * 4;
    return Color4.fromBytes(
        this._data[offset], this._data[offset + 1], this._data[offset + 2], this._data[offset + 3]);
  }

  /// Creates a copy of this texture data.
  TextureReader copy() {
    final typed.Uint8List data = typed.Uint8List(this._data.length);
    data.setAll(0, this._data);
    return TextureReader._(data, this._width, this._height);
  }

  /// Flips the image's Y axis within this own reader.
  void _flipYInternal() {
    for (int y = this._height ~/ 2; y >= 0; --y) {
      final int y1 = this._width * 4 * y;
      final int y2 = this._width * 4 * (this._height - 1 - y);
      for (int x = 0; x < this._width; ++x) {
        final int x1 = y1 + 4 * x;
        final int x2 = y2 + 4 * x;
        for (int b = 0; b < 4; ++b) {
          final int b1 = x1 + b;
          final int b2 = x2 + b;
          final int val = this._data[b1];
          this._data[b1] = this._data[b2];
          this._data[b2] = val;
        }
      }
    }
  }

  /// Gets the data for the given mime type as a base64 string.
  String toDataUrl({String type = 'image/png', double quality = 100.0}) {
    final html.CanvasElement canvas = html.CanvasElement()
      ..width = this._width
      ..height = this._height;
    final ctx = (canvas.getContext('2d') as html.CanvasRenderingContext2D?)!;
    final  img = ctx.createImageData(this._width, this._height);
    img.data.setAll(0, this._data);
    ctx.putImageData(img, 0, 0);
    return canvas.toDataUrl(type, quality);
  }

  /// Save this texture information to the given PNG file.
  void savePng(String fileName, {double quality = 100.0}) {
    final String data = this.toDataUrl(quality: quality).replaceFirst("image/png", "image/octet-stream");

    final html.AnchorElement link = html.AnchorElement();
    link.setAttribute("download", fileName);
    link.setAttribute("href", data);
    link.click();
  }
}
