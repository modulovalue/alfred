import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:web_gl';

import 'audio.dart';
import 'collections.dart';
import 'data.dart';
import 'debug.dart';
import 'events.dart';
import 'input.dart';
import 'math.dart';
import 'movers.dart';
import 'scenes.dart';
import 'shaders.dart';
import 'shapes.dart';
import 'techniques.dart';
import 'textures.dart';

/// The interface for a class which can bind and unbind state while rendering.
///
/// Classes which inherit [Bindable] can be bound to the [RenderState]
/// during a portion of the render until unbind is called or another
/// similar [Bindable] is bound to the [RenderState] overriding the first.
abstract class Bindable {
  /// Binds some data to the given [state].
  void bind(
    final RenderState state,
  );

  /// Unbinds the bound data from the given [state].
  void unbind(
    final RenderState state,
  );
}

/// A renderable entity in a tree of entities for a scene.
///
/// An [Entity] is a [Shape], [Technique], and a [Mover]
/// to create an output when rendered.
class Entity implements Movable, Changeable {
  /// The name for this entity.
  String name;

  /// Indicates if this entity and its children
  /// will be rendered or not.
  bool enabled;

  /// The shape to render.
  /// May be null to not render this Entity which is useful
  /// when grouping other Entities.
  Shape? _shape;

  /// The shape builder used to build the rendering data.
  /// When using a shape this will be a shape.
  /// May be null to not when not rendering.
  ShapeBuilder? _shapeBuilder;

  /// The cache of the shape transformed into the buffers required
  /// by the shader in the currently set technique.
  /// TODO: Need to make the cache work for two techniques when there are parents.
  TechniqueCache? _cache;

  /// The technique to render with or null to inherit from it's parent.
  Technique? _tech;

  /// The mover to position, rotate, and scale this Entity and children.
  /// May be null to not move the Entity.
  Mover? _mover;

  /// The location and rotation of this entity.
  Matrix4? _matrix;

  /// The list of children entities to this entity.
  final Collection<Entity> _children;

  /// The event emitted when any part of the entity is changed.
  Event? _changed;

  /// The event emitted when the shape has been changed.
  Event? _shapeChanged;

  /// The event emitted when the shape builder has been changed.
  final Event? _shapeBuilderChanged;

  /// The event emitted when the technique has been changed.
  Event? _techChanged;

  /// The event emitted when the mover has been changed.
  Event? _moverChanged;

  /// The event emitted when the matrix has been changed.
  Event? _matrixChanged;

  /// The event emitted when one or more children is added.
  Event? _childrenAdded;

  /// The event emitted when one or more children is removed.
  Event? _childrenRemoved;

  /// The event emitted when an extension is added.
  Event? _extensionAdded;

  /// The event emitted when an extension is removed.
  Event? _extensionRemoved;

  /// Creates a new Entity.
  Entity({
    this.name = '',
    this.enabled = true,
    final Shape? shape,
    final Technique? tech,
    final Mover? mover,
    final List<Entity>? children,
  })  : this._shape = null,
        this._shapeBuilder = null,
        this._cache = null,
        this._tech = null,
        this._mover = null,
        this._matrix = null,
        this._children = Collection<Entity>(),
        this._changed = null,
        this._shapeChanged = null,
        this._shapeBuilderChanged = null,
        this._techChanged = null,
        this._moverChanged = null,
        this._matrixChanged = null,
        this._childrenAdded = null,
        this._childrenRemoved = null,
        this._extensionAdded = null,
        this._extensionRemoved = null {
    this._children.setHandlers(
          onAddedHndl: this.onChildrenAdded,
          onRemovedHndl: this.onChildrenRemoved,
        );
    this.shape = shape;
    this.technique = tech;
    this.mover = mover;
    if (children != null) this._children.addAll(children);
  }

  /// Indicates if the shape cache needs to be updated.
  bool get cacheNeedsUpdate => this._cache == null;

  /// Requests that the shape cache is updated.
  ///
  /// If the shape is changed internally without being removed and reset or the requirements
  /// of the technique has changed without being removed then calling this will update the cache.
  /// Typically this should not have to be called.
  void clearCache() => this._cache = null;

  /// Requests that this and child shape caches are updated.
  ///
  /// This will clear the caches for updating when the technique changes.
  /// Since techniques are shared to children which don't provide their
  /// own technique this will clear all children and descendants which
  /// currently use this technique.
  void _cacheUpdateForTech() {
    this.clearCache();
    for (final child in this._children) {
      if (child._tech == null) {
        child._cacheUpdateForTech();
      }
    }
  }

  /// The cache of the current shape in buffers for the current technique.
  TechniqueCache? get cache => this._cache;

  set cache(
    final TechniqueCache? cache,
  ) =>
      this._cache = cache;

  /// The children Entities of this Entity.
  Collection<Entity> get children => this._children;

  /// The shape to draw at this Entity.
  /// May be null to not draw anything, useful if this Entity
  /// is just a container for child Entities.
  Shape? get shape => this._shape;

  set shape(
    final Shape? shape,
  ) {
    if (this._shape != shape) {
      final oldShape = this._shape;
      this._shape = shape;
      this._shapeBuilder = shape;
      this.clearCache();
      oldShape?.changed.remove(this.onShapeModified);
      shape?.changed.add(this.onShapeModified);
      this.onShapeChanged(oldShape, shape);
    }
  }

  /// The shape builder to draw at this Entity.
  /// A shape builder is a predetermined shape drawing instructions.
  /// Typically this is set through [shape] but is exposed so that
  /// renders with higher requirements can precalculate shapes or provide
  /// custom shapes to the entity.
  ShapeBuilder? get shapeBuilder => this._shapeBuilder;

  set shapeBuilder(
    final ShapeBuilder? builder,
  ) {
    if (this._shapeBuilder != builder) {
      final oldBuilder = this._shapeBuilder;
      this._shape = null;
      this._shapeBuilder = builder;
      this.clearCache();
      oldBuilder?.changed.remove(this.onShapeModified);
      builder?.changed.add(this.onShapeModified);
      this.onShapeBuilderChanged(oldBuilder, builder);
    }
  }

  /// The technique to render this Entity and/or it's children with.
  /// May be null to inherit the technique from this Entities parent.
  Technique? get technique => this._tech;

  set technique(
    final Technique? technique,
  ) {
    if (this._tech != technique) {
      final oldTech = this._tech;
      this._tech = technique;
      oldTech?.changed.remove(this.onTechModified);
      technique?.changed.add(this.onTechModified);
      this._cacheUpdateForTech();
      this.onTechChanged(oldTech, technique);
    }
  }

  /// The mover which moves this Entity.
  /// May be null to not move the Entity.
  @override
  Mover? get mover => this._mover;

  @override
  set mover(
    final Mover? mover,
  ) {
    if (this._mover != mover) {
      final oldMover = this._mover;
      this._mover = mover;
      oldMover?.changed.remove(this.onMoverModified);
      mover?.changed.add(this.onMoverModified);
      this.onMoverChanged(oldMover, this._mover);
    }
  }

  /// The matrix for the location and rotation of the entity.
  Matrix4? get matrix => this._matrix;

  /// Finds this or the first child entity with the given name.
  /// Null is returned if none was found.
  Entity? findFirstByName(
    final String name,
  ) {
    if (this.name == name) {
      // ignore: avoid_returning_this
      return this;
    }
    for (final child in this._children) {
      final result = child.findFirstByName(name);
      if (result != null) return result;
    }
    return null;
  }

  /// Finds this and all a children entities with the given name.
  /// If the optional given entity list is not null,
  /// then the found entities are added to that list.
  List<Entity> findAllByName(
    final String name, [
    List<Entity>? entities,
  ]) {
    entities ??= [];
    if (this.name == name) {
      entities.add(this);
    }
    for (final child in this._children) {
      child.findAllByName(name, entities);
    }
    return entities;
  }

  /// Calculates the axial aligned bounding box of this entity and its children.
  Region3? calculateAABB() {
    Region3? region;
    if (this._shapeBuilder != null) {
      region = Region3.union(region, this._shapeBuilder?.calculateAABB());
    }
    for (final child in this._children) {
      region = Region3.union(region, child.calculateAABB());
    }
    return region;
  }

  /// Scales the AABB so that the longest size the given [size],
  /// and the shape is centered then offset by the given [offset].
  void resizeCenter([
    final double size = 2.0,
    Point3? offset,
  ]) {
    final aabb = this.calculateAABB();
    if (aabb == null) return;
    offset ??= Point3.zero;
    // ignore: parameter_assignments
    offset -= aabb.center;
    double maxSize = aabb.dx;
    if (aabb.dy > maxSize) maxSize = aabb.dy;
    if (aabb.dz > maxSize) maxSize = aabb.dz;
    if (maxSize == 0.0) return;
    final invSize = size / maxSize;
    this.applyPositionMatrix(
        Matrix4.scale(invSize, invSize, invSize) * Matrix4.translate(offset.x, offset.y, offset.z));
  }

  /// Modifies the position, normal, and binormal
  /// by translating it with the given [mat]
  /// for this entity's shape and children shapes.
  void applyPositionMatrix(
    final Matrix4 mat,
  ) {
    this.shape?.applyPositionMatrix(mat);
    for (final child in this._children) {
      child.applyPositionMatrix(mat);
    }
  }

  /// Modifies the color by translating it with the given [mat]
  /// for this entity's shape and children shapes.
  void applyColorMatrix(
    final Matrix3 mat,
  ) {
    this.shape?.applyColorMatrix(mat);
    for (final child in this._children) {
      child.applyColorMatrix(mat);
    }
  }

  /// Modifies the 2D texture by translating it with the given [mat]
  /// for this entity's shape and children shapes.
  void applyTexture2DMatrix(
    final Matrix3 mat,
  ) {
    this.shape?.applyTexture2DMatrix(mat);
    for (final child in this._children) {
      child.applyTexture2DMatrix(mat);
    }
  }

  /// Modifies the cube texture by translating it with the given [mat]
  /// for this entity's shape and children shapes.
  void applyTextureCubeMatrix(
    final Matrix4 mat,
  ) {
    this.shape?.applyTextureCubeMatrix(mat);
    for (final child in this._children) {
      child.applyTextureCubeMatrix(mat);
    }
  }

  /// Updates the Entity with the given [state].
  void update(
    final RenderState state,
  ) {
    final mat = this._mover?.update(state, this);
    if (mat != this._matrix) {
      final oldMat = this._matrix;
      this._matrix = mat;
      this.onMatrixChanged(oldMat, this._matrix);
    }

    // Updated the technique.
    this._tech?.update(state);

    // Update all children.
    for (final child in this._children) {
      child.update(state);
    }
  }

  /// Renders the Entity with the given [RenderState].
  void render(
    final RenderState state,
  ) {
    if (!this.enabled) return;
    // Push state onto the render state.
    state.object.pushMul(this._matrix);
    state.pushTechnique(this._tech);
    // Render this entity.
    final tech = state.technique;
    if (this._shapeBuilder != null) {
      tech?.render(state, this);
    }
    // Render all children.
    for (final child in this._children) {
      child.render(state);
    }
    // Pop state from update.
    state.popTechnique();
    state.object.pop();
  }

  /// The event emitted when any part of the entity is changed.
  @override
  Event get changed => this._changed ??= Event();

  /// The event emitted when the shape has been changed.
  Event get shapeChanged => this._shapeChanged ??= Event();

  /// The event emitted when the technique has been changed.
  Event get techChanged => this._techChanged ??= Event();

  /// The event emitted when the mover has been changed.
  Event get moverChanged => this._moverChanged ??= Event();

  /// The event emitted when the matrix has been changed.
  Event get matrixChanged => this._matrixChanged ??= Event();

  /// The event emitted when one or more child is added.
  Event get childrenAdded => this._childrenAdded ??= Event();

  /// The event emitted when one or more child is removed.
  Event get childrenRemoved => this._childrenRemoved ??= Event();

  /// The event emitted when an extension is added.
  Event get extensionAdded => this._extensionAdded ??= Event();

  /// The event emitted when an extension is removed.
  Event get extensionRemoved => this._extensionRemoved ??= Event();

  /// Called when any change has occurred.
  ///
  /// This emits the [changed] event.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onChanged([
    final EventArgs? args,
  ]) =>
      this._changed?.emit(args);

  /// Called when the shape or shape builder is modified.
  ///
  /// This will clear the shape cache.
  /// The [args] are the arguments of the change.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onShapeModified([
    final EventArgs? args,
  ]) {
    this.clearCache();
    this.onChanged(args);
  }

  /// Called when the shape is added or removed.
  ///
  /// This emits the [_shapeChanged] event, the [_shapeBuilderChanged] event, and calls [onChanged].
  /// The [oldShape] that was removed (may be null), and the [newShape] that was added (may be null).
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onShapeChanged(
    final Shape? oldShape,
    final Shape? newShape,
  ) {
    final args = ValueChangedEventArgs(this, 'shape', oldShape, newShape);
    this._shapeChanged?.emit(args);
    this._shapeBuilderChanged?.emit(args);
    this.onChanged(args);
  }

  /// Called when the shape builder is added or removed.
  ///
  /// This emits the [_shapeBuilderChanged] event and calls [onChanged].
  /// The [oldShape] that was removed (may be null), and the [newShape] that was added (may be null).
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onShapeBuilderChanged(
    final ShapeBuilder? oldShape,
    final ShapeBuilder? newShape,
  ) {
    final args = ValueChangedEventArgs(this, 'shapeBuilder', oldShape, newShape);
    this._shapeBuilderChanged?.emit(args);
    this.onChanged(args);
  }

  /// Handles a change in the technique.
  ///
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onTechModified([
    final EventArgs? args,
  ]) =>
      this.onChanged(args);

  /// Called when the technique is added or removed.
  ///
  /// This emits the [techChanged] event and calls [onChanged].
  /// The [oldTech] that was removed (may be null), and the [newTech] that was added (may be null).
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onTechChanged(
    final Technique? oldTech,
    final Technique? newTech,
  ) {
    final args = ValueChangedEventArgs(this, 'technique', oldTech, newTech);
    this._techChanged?.emit(args);
    this.onChanged(args);
  }

  /// Handles a change in the mover.
  ///
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onMoverModified([
    final EventArgs? args,
  ]) =>
      this.onChanged(args);

  /// Called when the mover is added or removed is removed.
  ///
  /// This emits the [moverChanged] event and calls [onChanged].
  /// The [oldMover] that was removed (may be null), and the [newMover] that was added (may be null).
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onMoverChanged(
    final Mover? oldMover,
    final Mover? newMover,
  ) {
    final args = ValueChangedEventArgs(this, 'mover', oldMover, newMover);
    this._moverChanged?.emit(args);
    this.onChanged(args);
  }

  /// Called when the matrix is added or removed is removed.
  ///
  /// This emits the [matrixChanged] event and calls [onChanged].
  /// The [oldMatrix] that was removed (may be null), and the [newMatrix] that was added (may be null).
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onMatrixChanged(
    final Matrix4? oldMatrix,
    final Matrix4? newMatrix,
  ) {
    final args = ValueChangedEventArgs(this, 'matrix', oldMatrix, newMatrix);
    this._matrixChanged?.emit(args);
    this.onChanged(args);
  }

  /// Handles a change in the child.
  ///
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onChildrenModified([
    final EventArgs? args,
  ]) =>
      this.onChanged(args);

  /// Called when one or more child is added.
  ///
  /// This emits the [onChildrenAdded] event and calls [onChanged].
  /// The [entities] are the newly added children.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onChildrenAdded(
    final int index,
    final Iterable<Entity> entities,
  ) {
    this._childrenAdded?.emit(EntityEventArgs(this, entities.toList()));
    for (final entity in entities) {
      entity.changed.add(this.onChildrenModified);
    }
    this.onChanged();
  }

  /// Called when a child is removed.
  ///
  /// This emits the [onChildrenRemoved] event and calls [onChanged].
  /// The [entities] are the children which were removed.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the entity is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onChildrenRemoved(
    final int index,
    final Iterable<Entity> entities,
  ) {
    this._childrenRemoved?.emit(
          EntityEventArgs(this, entities.toList()),
        );
    for (final entity in entities) {
      entity.changed.remove(this.onChildrenModified);
    }
    this.onChanged();
  }

  /// Gets a string for this entity, the name if it has one.
  @override
  String toString() {
    if (name.isEmpty) {
      return 'Unnamed entity';
    } else {
      return name;
    }
  }

  /// Gets the string tree for these entity tree.
  StringTree _stringTree() {
    final tree = StringTree(this.toString());
    for (final child in this.children) {
      tree.append(child._stringTree());
    }
    return tree;
  }

  /// Gets a string for the branch of entities from this entity.
  String outlineString([
    final String indent = '',
  ]) =>
      this._stringTree().toString(indent);
}

/// The event argument for event's with information about entities changing.
class EntityEventArgs extends EventArgs {
  /// The list of entities which have been changed.
  /// Typically this will be entities added or removed.
  final List<Entity> entities;

  /// Creates an entity event argument.
  EntityEventArgs(
    final Object sender,
    this.entities,
  ) : super(sender);
}

/// This is the type of the browser this code is running on.
enum Browser {
  /// This indicates the browser type is Google's Chrome.
  chrome,

  /// This indicates the browser is Mozilla's Firefox.
  firefox,

  /// This indicates the browser is Microsoft's Edge or IE.
  edge,

  /// This indicates the browser is some other browser.
  other
}

/// This is the type of the operating system this code is running on.
enum OperatingSystem {
  /// This indicates the operating system is Windows.
  windows,

  /// This indicates the operating system is MacOS.
  mac,

  /// This indicates the operating system is Linux.
  linux,

  /// This indicates the operating system is some other OS.
  other
}

/// A static class for getting information about the environment this code is running in.
/// Try to limit usage of the Environment so that all features work the same in all
/// scenarios. This is designed to be used to adjust for problems in the environment
/// which makes the code function differently.
class Environment {
  static _EnvironmentData? _singleton;

  Environment._();

  /// Gets the lazy created singleton with the environment data.
  static _EnvironmentData get _env => _singleton ??= _EnvironmentData();

  /// Gets the browser that this code is running on.
  static Browser get browser => _env.browser;

  /// Gets the operating system that this code is running on.
  static OperatingSystem get os => _env.os;

  /// This will call the first method in the given method names which exists on the given object.
  /// Returns true if the method was called, false if none of those methods were found.
  static bool callMethod(
    final Object browserObject,
    final List<String> methods, [
    final List<Object>? args,
  ]) {
    final jsElem = JsObject.fromBrowserObject(browserObject);
    for (final methodName in methods) {
      if (jsElem.hasProperty(methodName)) {
        jsElem.callMethod(methodName, args);
        return true;
      }
    }
    return false;
  }

  /// This will call the first property and return the value cast as given [T] type.
  /// Returns null if methods were found.
  static T? getProperty<T>(
    final Object browserObject,
    final List<String> properties,
  ) {
    final jsElem = JsObject.fromBrowserObject(browserObject);
    for (final propertyName in properties) {
      if (jsElem.hasProperty(propertyName)) return jsElem[propertyName] as T?;
    }
    return null;
  }
}

/// This is storage for environment information.
/// This is part of a singleton so it is only created once.
class _EnvironmentData {
  final Browser browser;
  final OperatingSystem os;

  /// Determines the environment which this code is running in.
  factory _EnvironmentData() {
    final browser = _determineBrowser();
    final os = _determineOS();
    return _EnvironmentData._(browser, os);
  }

  /// Creates a new environment with the given data.
  _EnvironmentData._(
    this.browser,
    this.os,
  );

  /// Determines which kind of browser is being used.
  static Browser _determineBrowser() {
    final vendor = window.navigator.vendor;
    if (vendor.contains('Google')) {
      return Browser.chrome;
    }
    final userAgent = window.navigator.userAgent;
    if (userAgent.contains('Firefox')) {
      return Browser.firefox;
    }
    final appVersion = window.navigator.appVersion;
    if (appVersion.contains('Trident') || appVersion.contains('Edge')) {
      return Browser.edge;
    }
    final appName = window.navigator.appName;
    if (appName.contains('Microsoft')) {
      return Browser.edge;
    }
    return Browser.other;
  }

  /// Determines which kind of operating system is being used.
  /// This doesn't use `dart:io` so it can run on a browser.
  static OperatingSystem _determineOS() {
    final appVersion = window.navigator.appVersion;
    if (appVersion.contains('Win')) {
      return OperatingSystem.windows;
    } else if (appVersion.contains('Mac')) {
      return OperatingSystem.mac;
    } else if (appVersion.contains('Linux')) {
      return OperatingSystem.linux;
    } else {
      return OperatingSystem.other;
    }
  }
}

/// The state of a render in progress.
class RenderState {
  /// The rendering context for this render.
  final RenderingContext2 _gl;

  /// The canvas being rendered to.
  final CanvasElement _canvas;

  /// The width of the render viewport in pixels.
  int width;

  /// The height of the render viewport in pixels.
  int height;

  /// The number of this frame.
  int _frameNum;

  /// The time that the graphics were created.
  final DateTime _startTime;

  /// The time the last render was started at.
  DateTime _lastTime;

  /// The time the current render was started at.
  DateTime _curTime;

  /// The seconds which have passed since the previous render.
  double _dt;

  /// The projection matrix multiplied by the view matrix.
  /// This is the cache, it is reset to null when either component is changed.
  /// Null indicated the value must be recalculated.
  Matrix4? _projViewMat;

  /// The inverse of the view matrix.
  /// This is the cache, it is reset to null when the view is changed.
  /// Null indicated the value must be recalculated.
  Matrix4? _invViewMat;

  /// The product of the projection matrix, the view matrix, and the object matrix.
  /// This is the cache, it is reset to null when either component is changed.
  /// Null indicated the value must be recalculated.
  Matrix4? _projViewObjMat;

  /// The view matrix multiplied by the object matrix.
  /// This is the cache, it is reset to null when either component is changed.
  /// Null indicated the value must be recalculated.
  Matrix4? _viewObjMat;

  /// The stack of projection matrices.
  final Matrix4Stack _projStack;

  /// The stack of the view matrices.
  final Matrix4Stack _viewStack;

  /// The stack of Entity matrices.
  final Matrix4Stack _objStack;

  /// The stack of techniques.
  final List<Technique?> _tech;

  /// The cache of compiled shaders.
  final Map<String, Shader> _shaderCache;

  /// Constructs a new render state with the given context and canvas.
  RenderState(
    this._gl,
    this._canvas,
  )   : this.width = 512,
        this.height = 512,
        this._frameNum = 0,
        this._startTime = DateTime.now(),
        this._lastTime = DateTime.now(),
        this._curTime = DateTime.now(),
        this._dt = 0.0,
        this._projViewMat = null,
        this._invViewMat = null,
        this._projViewObjMat = null,
        this._viewObjMat = null,
        this._projStack = Matrix4Stack(),
        this._viewStack = Matrix4Stack(),
        this._objStack = Matrix4Stack(),
        this._tech = [null],
        this._shaderCache = {} {
    this._projStack.changed.add((final e) {
      this._projViewMat = null;
      this._projViewObjMat = null;
    });
    this._viewStack.changed.add((final e) {
      this._projViewMat = null;
      this._invViewMat = null;
      this._projViewObjMat = null;
      this._viewObjMat = null;
    });
    this._objStack.changed.add((final e) {
      this._projViewObjMat = null;
      this._viewObjMat = null;
    });
  }

  /// Resets the state to start another render.
  /// This should only be called by [ThreeDart] before starting a new render.
  void reset() {
    this._frameNum++;
    this._lastTime = this._curTime;
    this._curTime = DateTime.now();
    this._dt = diffInSecs(
      this._lastTime,
      this._curTime,
    );
    this._projStack.clear();
    this._viewStack.clear();
    this._objStack.clear();
    this._tech.clear();
    this._tech.add(null);
  }

  /// The rendering context for the render.
  RenderingContext2 get gl => this._gl;

  /// The canvas being rendered onto.
  CanvasElement get canvas => this._canvas;

  /// The number of this frame.
  int get frameNumber => this._frameNum;

  /// The time that the graphics were created.
  DateTime get startTime => this._startTime;

  /// The time the last render was started at.
  DateTime get lastTime => this._lastTime;

  /// The time the current render was started at.
  DateTime get currentTime => this._curTime;

  /// The seconds which have passed since the previous render.
  double get dt => this._dt;

  /// The projection matrix multiplied by the view matrix.
  Matrix4 get projectionViewMatrix => this._projViewMat ??= this.projection.matrix * this.view.matrix;

  /// The inverse of the view matrix.
  Matrix4 get inverseViewMatrix => this._invViewMat ??= this.view.matrix.inverse();

  /// The product of the projection matrix, the view matrix, and the object matrix.
  Matrix4 get projectionViewObjectMatrix => this._projViewObjMat ??= this.projectionViewMatrix * this.object.matrix;

  /// The view matrix multiplied by the object matrix.
  Matrix4 get viewObjectMatrix => this._viewObjMat ??= this.view.matrix * this.object.matrix;

  /// The stack of projection matrices.
  Matrix4Stack get projection => this._projStack;

  /// The stack of the view matrices.
  Matrix4Stack get view => this._viewStack;

  /// The stack of object matrices.
  Matrix4Stack get object => this._objStack;

  /// The current technique to render with.
  /// May return null if the technique stack is empty.
  Technique? get technique => this._tech.last;

  /// Pushes a new technique onto the stack of techniques.
  /// Pushing null will put the current technique onto the top of the stack.
  void pushTechnique(
    final Technique? tech,
  ) =>
      this._tech.add(tech ?? this.technique);

  /// Pops the current technique off of the top of the stack.
  /// This will not remove the last technique on the stack.
  void popTechnique() {
    if (this._tech.length > 1) {
      this._tech.removeLast();
    }
  }

  /// Gets the cached shader by the given [name].
  Shader? shader(
    final String name,
  ) =>
      this._shaderCache[name];

  /// Adds the given [shader] to the shader cache.
  void addShader(
    final Shader shader,
  ) {
    final name = shader.name;
    if (name.isEmpty) {
      throw Exception('May not cache a shader with no name.');
    }
    if (this._shaderCache.containsKey(name)) {
      throw Exception('Shader cache already contains a shader by the name "$name".');
    }
    this._shaderCache[name] = shader;
  }
}

/// The state event arguments for update and render events.
class StateEventArgs extends EventArgs {
  /// The render state for an update or render.
  final RenderState state;

  /// Creates a new state event argument.
  StateEventArgs(
    final Object sender,
    this.state,
  ) : super(sender);
}

/// [ThreeDart] (3Dart) is the a tool for rendering WebGL with Dart.
class ThreeDart implements Changeable {
  /// The element the canvas was added to or the canvas being drawn to.
  Element _elem;

  /// The given or added canvas being drawn to.
  CanvasElement _canvas;

  /// The rendering context to draw with.
  RenderingContext2 _gl;

  /// The current scene to draw.
  Scene? _scene;

  /// The rendering state.
  RenderState _state;

  /// The loader for creating textures.
  TextureLoader _txtLoader;

  /// The loader for creating audio.
  AudioLoader _audioLoader;

  /// The user input listener.
  UserInput _input;

  /// Event to indicate something attached to this instance has changed.
  Event? _changed;

  /// Event to indicate a render is about to occur.
  Event? _prerender;

  /// Event to indicate a render has just finished.
  Event? _postrender;

  /// Indicates the refresh should be automatically.
  bool _autoRefresh;

  /// Indicates that a refresh is pending.
  bool _pendingRender;

  /// The last time that a frames per second were updated.
  DateTime _frameTime;

  /// The number of times render has been called in the last sec or more.
  int _frameCount;

  /// Creates a new 3Dart rendering on an element with the given [elementId].
  ///
  /// [alpha] indicates if the back color target will have an alpha channel or not.
  /// [depth] indicates if the target will have a back buffer or not.
  /// [stencil] indicates if the target will have a stencil buffer or not.
  /// [antialias] indicates if the target is antialiased or not.
  factory ThreeDart.fromId(
    final String elementId, {
    final bool alpha = true,
    final bool depth = true,
    final bool stencil = false,
    final bool antialias = true,
  }) {
    final elem = document.getElementById(elementId);
    if (elem == null) {
      throw Exception('Failed to find an element with the identifier, ${elementId}.');
    } else {
      return ThreeDart.fromElem(elem, alpha: alpha, depth: depth, stencil: stencil, antialias: antialias);
    }
  }

  /// Creates a new 3Dart rendering on the given element.
  ///
  /// [alpha] indicates if the back color target will have an alpha channel or not.
  /// [depth] indicates if the target will have a back buffer or not.
  /// [stencil] indicates if the target will have a stencil buffer or not.
  /// [antialias] indicates if the target is antialiased or not.
  factory ThreeDart.fromElem(
    final Element? elem, {
    final bool alpha = true,
    final bool depth = true,
    final bool stencil = false,
    final bool antialias = true,
  }) {
    if (elem == null) {
      throw Exception('May not create a manager from a null element.');
    } else if (elem is CanvasElement) {
      return ThreeDart.fromCanvas(elem, alpha: alpha, depth: depth, stencil: stencil, antialias: antialias);
    } else {
      final canvas = CanvasElement();
      canvas.style
        ..width = '100%'
        ..height = '100%';
      elem.children.add(canvas);
      final td = ThreeDart.fromCanvas(canvas, alpha: alpha, depth: depth, stencil: stencil, antialias: antialias);
      td._elem = elem;
      return td;
    }
  }

  /// Creates a new 3Dart rendering on the given canvas.
  ///
  /// [alpha] indicates if the back color target will have an alpha channel or not.
  /// [depth] indicates if the target will have a back buffer or not.
  /// [stencil] indicates if the target will have a stencil buffer or not.
  /// [antialias] indicates if the target is antialiased or not.
  factory ThreeDart.fromCanvas(
    final CanvasElement? canvas, {
    final bool alpha = true,
    final bool depth = true,
    final bool stencil = false,
    final bool antialias = true,
  }) {
    if (canvas == null) {
      throw Exception('May not create a manager from a null canvas.');
    } else {
      // Create a WebGL 2.0 render target
      // https://www.khronos.org/registry/webgl/specs/latest/2.0/
      final gl = canvas.getContext(
        'webgl2',
        <String, dynamic>{'alpha': alpha, 'depth': depth, 'stencil': stencil, 'antialias': antialias},
      ) as RenderingContext2?;
      if (gl == null) {
        throw Exception('Failed to get the rendering context for WebGL.');
      } else {
        final state = RenderState(gl, canvas);
        final txtLoader = TextureLoader(gl);
        final audioLoader = AudioLoader();
        final input = UserInput(canvas);
        return ThreeDart._(canvas, canvas, gl, state, txtLoader, audioLoader, input);
      }
    }
  }

  /// Creates a new 3Dart instance with the given values.
  ThreeDart._(
    this._elem,
    this._canvas,
    this._gl,
    this._state,
    this._txtLoader,
    this._audioLoader,
    this._input,
  )   : this._scene = null,
        this._changed = null,
        this._prerender = null,
        this._postrender = null,
        this._autoRefresh = true,
        this._pendingRender = false,
        this._frameTime = DateTime.now(),
        this._frameCount = 0 {
    this._resize();
  }

  /// The rendering context to draw with.
  RenderingContext2 get glContext => this._gl;

  /// The width of the canvas in pixels.
  int get width => this._canvas.width ?? 100;

  /// The height of the canvas in pixels.
  int get height => this._canvas.height ?? 100;

  /// The canvas being written to.
  CanvasElement get canvas => this._canvas;

  /// The user input listener.
  UserInput get userInput => this._input;

  /// The state used for rendering.
  RenderState get state => this._state;

  /// The loader to create textures with.
  TextureLoader get textureLoader => this._txtLoader;

  /// The loader to create audio players with.
  AudioLoader get audioLoader => this._audioLoader;

  /// Indicates if a refresh is automatically called
  /// when something internally is changed.
  bool get autoRefresh => this._autoRefresh;

  set autoRefresh(
    final bool autoRefresh,
  ) {
    if (this._autoRefresh == autoRefresh) {
      this._autoRefresh = autoRefresh;
      this._onChanged();
    }
  }

  /// Indicates a rendering will be started on the next render frame.
  bool get pendingRender => this._pendingRender;

  /// Indicates that this instance or something attached to is has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a change in this instance.
  void _onChanged([
    final EventArgs? args,
  ]) {
    this._changed?.emit(args);
    if (this._autoRefresh) this.requestRender();
  }

  /// Indicates that a render is about to occur.
  Event get prerender => this._prerender ??= Event();

  /// Handles an event to fire prior to rendering.
  void _onPrerender([
    final EventArgs? args,
  ]) =>
      this._prerender?.emit(args);

  /// Indicates that a render has just occurred.
  Event get postrender => this._postrender ??= Event();

  /// Handles an event to fire after a render.
  void _onPostrender([
    final EventArgs? args,
  ]) =>
      this._postrender?.emit(args);

  /// The scene to render to the canvas.
  Scene? get scene => this._scene;

  set scene(
    final Scene? scene,
  ) {
    if (this._scene != scene) {
      this._scene?.changed.remove(this._onChanged);
      this._scene = scene;
      this._scene?.changed.add(this._onChanged);
      this._onChanged();
    }
  }

  /// The frames per second since the last time this getter is called.
  double get fps {
    final time = DateTime.now();
    final secs = time.difference(this._frameTime).inMilliseconds / 1000.0;
    if (secs <= 0.0) return 0.0;
    final fps = this._frameCount / secs;
    this._frameCount = 0;
    this._frameTime = time;
    return fps;
  }

  /// Makes sure the size of the canvas is correctly set.
  void _resize() {
    // Lookup the size the browser is displaying the canvas in CSS pixels and
    // compute a size needed to make our drawing buffer match it in device pixels.
    final ratio = window.devicePixelRatio;
    final displayWidth = (this._canvas.clientWidth * ratio).floor();
    final displayHeight = (this._canvas.clientHeight * ratio).floor();
    // Check if the canvas is not the same size.
    if ((this._canvas.width != displayWidth) || (this._canvas.height != displayHeight)) {
      // Make the canvas the same size
      this._canvas.width = displayWidth;
      this._canvas.height = displayHeight;
      Timer.run(this.requestRender);
    }
  }

  /// Determines if this page can be fullscreened or not.
  bool get fullscreenAvailable {
    //return html.document.fullscreenEnabled ?? false;
    return Environment.getProperty<bool>(document, [
          'webkitFullscreenEnabled',
          'mozFullScreenEnabled',
          'msFullscreenEnabled',
          'oFullscreenEnabled',
          'fullscreenEnabled'
        ]) ??
        false;
  }

  /// Gets or sets if the ThreeDart cancas is full screen or not.
  /// Note: This should be called within a user interaction with the pages since
  ///       some browsers will deny full screen any other time.
  ///
  /// TODO: There is a bug which causes the built-in methods to sometimes be undefined so use JS
  ///       to find the correct method instead. Periodically check if this issue has been fixed.
  /// Errors "Uncaught TypeError: this.webkitRequestFullscreen is undefined in dartx.requestFullscreen"
  /// and "Uncaught TypeError: this.webkitExitFullscreen is undefined"
  /// This fix si from https://stackoverflow.com/a/29751708
  bool get fullscreen {
    return Environment.getProperty<Object>(document, [
          'webkitFullscreenElement',
          'mozFullScreenElement',
          'msFullscreenElement',
          'oFullscreenElement',
          'fullscreenElement'
        ]) !=
        null;
  }

  set fullscreen(
    final bool enable,
  ) {
    if (enable) {
      //this._canvas.requestFullscreen();
      Environment.callMethod(this._canvas, [
        'webkitRequestFullscreen',
        'mozRequestFullScreen',
        'msRequestFullscreen',
        'oRequestFullscreen',
        'requestFullscreen'
      ]);
    } else {
      // html.document.exitFullscreen();
      Environment.callMethod(document,
          ['webkitExitFullscreen', 'mozCancelFullScreen', 'msExitFullscreen', 'oExitFullscreen', 'exitFullscreen']);
    }
  }

  /// Requests a render to start the next time the main message loop
  /// is returned to. This is debounced so that it can be called many times
  /// but will only be run once
  void requestRender() {
    if (!this._pendingRender) {
      this._pendingRender = true;
      window.requestAnimationFrame((final t) {
        if (this._pendingRender) {
          this._pendingRender = false;
          this.render();
        }
      });
    }
  }

  /// Renders the scene to the canvas.
  /// An optional different scene can be provided but
  /// typically the scene attached to this object should be used.
  /// If the scene parameter isn't set, the attached scene is used.
  void render([
    Scene? scene,
  ]) {
    try {
      this._frameCount++;
      this._pendingRender = false;
      this._resize();
      this._onPrerender();
      scene ??= this._scene;
      if (scene != null) {
        this._state.reset();
        scene.render(this._state);
      }
      this._onPostrender();
    } on Object catch (exception, stackTrace) {
      print('Error: $exception');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  /// Disposes this instance of 3Dart.
  void dispose() {
    if (this._elem != this._canvas) {
      this._elem.children.remove(this._canvas);
    }
    this._scene = null;
  }
}
