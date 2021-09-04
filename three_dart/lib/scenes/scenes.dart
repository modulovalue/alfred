// Scenes are the base of a render. Each unique part of the render is a pass.
// Scenes contain objects, cameras, targets, and sometimes other information
// used to put together a rendered image.

import 'dart:math' as math;

import '../collections/collections.dart';
import '../core/core.dart';
import '../events/events.dart';
import '../math/math.dart';
import '../movers/movers.dart';
import '../shapes/shapes.dart';
import '../techniques/techniques.dart' as techniques;
import '../textures/textures.dart';
import '../views/views.dart';

/// A scene which is a composite of several other scenes used as passes.
class Compound extends Collection<Scene> implements Scene {
  /// Indicates if the scene is rendered or not.
  bool _enabled;

  /// The control to stop infinite loops by a compound containing itself.
  bool _loopProtection;

  /// Emits when any scene in the list changes.
  Event? _changed;

  /// Creates a new compound scene.
  Compound({bool enabled = true, List<Scene>? passes})
      : this._enabled = enabled,
        this._loopProtection = false,
        this._changed = null {
    this.setHandlers(onAddedHndl: this._onSceneAdded, onRemovedHndl: this._onSceneRemoved);
    if (passes != null) {
      this.addAll(passes);
    }
  }

  /// The event emitted when the scene has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles changes to the scene.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Called when one or more scenes are added.
  void _onSceneAdded(int index, Iterable<Scene> scenes) {
    for (final Scene scene in scenes) {
      scene.changed.add(this._onChanged);
    }
    this._onChanged(ItemsAddedEventArgs(this, index, scenes));
  }

  /// Called when scenes are removed.
  void _onSceneRemoved(int index, Iterable<Scene> scenes) {
    for (final Scene scene in scenes) {
      scene.changed.remove(this._onChanged);
    }
    this._onChanged(ItemsRemovedEventArgs(this, index, scenes));
  }

  /// Indicates if this scene should be rendered or not.
  @override
  bool get enabled => this._enabled;

  @override
  set enabled(bool enable) {
    if (this._enabled != enable) {
      final bool prev = this._enabled;
      this._enabled = enable;
      this._onChanged(ValueChangedEventArgs(this, 'enabled', prev, this._enabled));
    }
  }

  /// Renders the scenes with the given [state].
  @override
  void render(RenderState state) {
    if (!this._enabled) return;
    if (this._loopProtection) return;
    this._loopProtection = true;
    for (final Scene pass in this) {
      pass.render(state);
    }
    this._loopProtection = false;
  }
}

/// The render pass renders a cover over the whole scene.
class CoverPass implements RenderPass {
  /// Indicates if the scene is rendered or not.
  bool _enabled;

  /// The camera describing the view of the scene.
  Camera? _camera;

  /// The target defining the storage to render to.
  Target? _target;

  /// The default technique to render with.
  techniques.Technique? _tech;

  /// The box entity to render.
  Entity _box;

  /// Event emitted on an render for this pass.
  Event? _onRender;

  /// Emits when the cover changes.
  Event? _changed;

  /// Creates a new cover render pass.
  CoverPass({bool enabled = true, Camera? camera, Target? target, techniques.Technique? tech})
      : this._enabled = enabled,
        this._camera = null,
        this._target = null,
        this._tech = null,
        this._box = Entity(),
        this._onRender = null,
        this._changed = null {
    this._box.shape = square();
    this.camera = camera;
    this.target = target;
    this.technique = tech;
  }

  /// Creates a new cover render pass preset with a skybox technique.
  /// The given [boxTexture] is the cube texture of the skybox.
  factory CoverPass.skybox(TextureCube boxTexture) =>
      CoverPass()..technique = techniques.Skybox(boxTexture: boxTexture);

  /// Event emitted on an render for this pass.
  @override
  Event get onRender => this._onRender ??= Event();

  /// The event emitted when the scene has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles changes to the scene.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Indicates if this scene should be rendered or not.
  @override
  bool get enabled => this._enabled;

  @override
  set enabled(bool enable) {
    if (this._enabled != enable) {
      final bool prev = this._enabled;
      this._enabled = enable;
      this._onChanged(ValueChangedEventArgs(this, 'enabled', prev, this._enabled));
    }
  }

  /// The camera describing the view of the scene.
  /// If null is set, the camera is set to an IdentityCamera.
  @override
  Camera? get camera => this._camera;

  @override
  set camera(Camera? camera) {
    // ignore: parameter_assignments
    camera ??= IdentityCamera();
    if (this._camera != camera) {
      this._camera?.changed.remove(this._onChanged);
      final Camera? prev = this._camera;
      this._camera = camera;
      this._camera?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'camera', prev, this._camera));
    }
  }

  /// The target defining the storage to render to.
  /// If null is set, the target is set to an FrontTarget.
  @override
  Target? get target => this._target;

  @override
  set target(Target? target) {
    // ignore: parameter_assignments
    target ??= FrontTarget();
    if (this._target != target) {
      this._target?.changed.remove(this._onChanged);
      final Target? prev = this._target;
      this._target = target;
      this._target?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'target', prev, this._target));
    }
  }

  /// The default technique to render with.
  @override
  techniques.Technique? get technique => this._tech;

  @override
  set technique(techniques.Technique? tech) {
    if (this._tech != tech) {
      this._tech?.changed.remove(this._onChanged);
      final techniques.Technique? prev = this._tech;
      this._tech = tech;
      this._tech?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'technique', prev, this._tech));
    }
  }

  /// Render the scene with the given [state].
  @override
  void render(RenderState state) {
    if (!this._enabled) return;
    state.pushTechnique(this._tech);
    this._target?.bind(state);
    this._camera?.bind(state);
    this._tech?.update(state);
    this._box.update(state);
    this._box.render(state);
    final StateEventArgs args = StateEventArgs(this, state);
    this._onRender?.emit(args);
    this._camera?.unbind(state);
    this._target?.unbind(state);
    state.popTechnique();
  }
}

/// The render pass renders a single scene.
class EntityPass implements RenderPass {
  /// Indicates if the scene is rendered or not.
  bool _enabled;

  /// The camera describing the view of the scene.
  Camera? _camera;

  /// The target defining the storage to render to.
  Target? _target;

  /// The default technique to render with.
  techniques.Technique? _tech;

  /// The children entities to render.
  final Collection<Entity> _children;

  /// Event emitted before an update for this pass.
  Event? _onPreUpdate;

  /// Event emitted after an update for this pass.
  Event? _onPostUpdate;

  /// Event emitted on an render for this pass.
  Event? _onRender;

  /// Event emitted on an render for this pass.
  Event? _changed;

  /// Creates a new render pass.
  /// The given clear color is only used if target is null or a FrontTarget.
  EntityPass(
      {bool enabled = true,
      Camera? camera,
      Target? target,
      techniques.Technique? tech,
      List<Entity>? children,
      Color4? clearColor})
      : this._enabled = true,
        this._camera = null,
        this._target = null,
        this._tech = null,
        this._children = Collection<Entity>(),
        this._onPreUpdate = null,
        this._onPostUpdate = null,
        this._onRender = null,
        this._changed = null {
    this._enabled = enabled;
    this._children.setHandlers(onAddedHndl: this._onChildrenAdded, onRemovedHndl: this._onChildrenRemoved);
    if (target == null) {
      target = FrontTarget(color: clearColor);
    } else if ((target is FrontTarget) && (clearColor != null)) {
      target.color = clearColor;
    }
    this.camera = camera;
    this.target = target;
    this.technique = tech;
    if (children != null) this._children.addAll(children);
  }

  /// Handles a change in this pass.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Called when one or more child is added.
  void _onChildrenAdded(int index, Iterable<Entity> entities) {
    for (final Entity entity in entities) {
      entity.changed.add(this._onChanged);
    }
    this._onChanged(ItemsAddedEventArgs(this, index, entities));
  }

  /// Called when a child is removed.
  void _onChildrenRemoved(int index, Iterable<Entity> entities) {
    for (final Entity entity in entities) {
      entity.changed.remove(this._onChanged);
    }
    this._onChanged(ItemsRemovedEventArgs(this, index, entities));
  }

  /// Indicates if this scene should be rendered or not.
  @override
  bool get enabled => this._enabled;

  @override
  set enabled(bool enable) {
    if (this._enabled != enable) {
      final bool prev = this._enabled;
      this._enabled = enable;
      this._onChanged(ValueChangedEventArgs(this, 'enabled', prev, this._enabled));
    }
  }

  /// The camera describing the view of the scene.
  /// If null is set, the camera is set to a Perspective.
  @override
  Camera? get camera => this._camera;

  @override
  set camera(Camera? camera) {
    // ignore: parameter_assignments
    camera ??= Perspective();
    if (this._camera != camera) {
      this._camera?.changed.remove(this._onChanged);
      final Camera? prev = this._camera;
      this._camera = camera;
      this._camera?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'camera', prev, this._camera));
    }
  }

  /// The target defining the storage to render to.
  /// If null is set, the target is set to an FrontTarget.
  @override
  Target? get target => this._target;

  @override
  set target(Target? target) {
    // ignore: parameter_assignments
    target ??= FrontTarget();
    if (this._target != target) {
      this._target?.changed.remove(this._onChanged);
      final Target? prev = this._target;
      this._target = target;
      this._target?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'target', prev, this._target));
    }
  }

  /// The default technique to render with.
  @override
  techniques.Technique? get technique => this._tech;

  @override
  set technique(techniques.Technique? tech) {
    if (this._tech != tech) {
      this._tech?.changed.remove(this._onChanged);
      final techniques.Technique? prev = this._tech;
      this._tech = tech;
      this._tech?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'technique', prev, this._tech));
    }
  }

  /// The children entities to render.
  Collection<Entity> get children => this._children;

  /// Event emitted before an update for this pass.
  Event get onPreUpdate => this._onPreUpdate ??= Event();

  /// Event emitted after an update for this pass.
  Event get onPostUpdate => this._onPostUpdate ??= Event();

  /// Event emitted on an render for this pass.
  @override
  Event get onRender => this._onRender ??= Event();

  /// Event emitted on a the pass or a child entity has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Render the scene with the given [state].
  @override
  void render(RenderState state) {
    if (!this._enabled) return;
    final StateEventArgs args = StateEventArgs(this, state);
    this._onPreUpdate?.emit(args);
    state.pushTechnique(this._tech);
    this._target?.bind(state);
    this._camera?.bind(state);
    this._tech?.update(state);
    for (final Entity child in this._children) {
      child.update(state);
    }
    this._onPostUpdate?.emit(args);
    for (final Entity child in this._children) {
      child.render(state);
    }
    this._onRender?.emit(args);
    this._camera?.unbind(state);
    this._target?.unbind(state);
    state.popTechnique();
  }
}

/// A scene for applying a vertical and horizontal blur to the given texture.
class GaussianBlur implements Scene {
  /// Indicates if the scene is rendered or not.
  bool _enabled;

  /// Emits when any scene in the list changes.
  Event? _changed;

  /// The target to render the horizontal blur to.
  final BackTarget _horzBlurTarget;

  /// The horizontal blur technique.
  techniques.GaussianBlur? _horzBlurTech;

  /// The horizontal blur pass.
  CoverPass? _horzBlurPass;

  /// The vertical blur technique.
  techniques.GaussianBlur? _vertBlurTech;

  /// The vertical blur pass.
  CoverPass? _vertBlurPass;

  /// Creates a new gaussian blue scene.
  GaussianBlur(
      {bool enabled = true,
      double blurValue = 0.0,
      Texture2D? colorTxt,
      Texture2D? blurTxt,
      Matrix3? txtMatrix,
      Vector4? blurAdj,
      Target? target})
      : this._enabled = enabled,
        this._changed = null,
        this._horzBlurTarget = BackTarget(autoResize: true, clearColor: false),
        this._horzBlurTech = null,
        this._horzBlurPass = null,
        this._vertBlurTech = null,
        this._vertBlurPass = null {
    this._horzBlurTech = techniques.GaussianBlur()..changed.add(this._onChanged);
    this._horzBlurPass = CoverPass(target: this._horzBlurTarget, tech: this._horzBlurTech);
    this._vertBlurTech = techniques.GaussianBlur(colorTxt: this._horzBlurTarget.colorTexture, blurDir: Vector2.posY)
      ..changed.add(this._onChanged);
    this._vertBlurPass = CoverPass(tech: this._vertBlurTech);
    this.blurValue = blurValue;
    this.colorTexture = colorTxt;
    this.blurTexture = blurTxt;
    this.textureMatrix = txtMatrix;
    this.blurAdjust = blurAdj;
    this.target = target;
  }

  /// Gets the vertex source code used for the shader used by the blur technique.
  String get vertexSourceCode => this._horzBlurTech?.vertexSourceCode ?? '';

  /// Gets the fragment source code used for the shader used by the blur technique.
  String get fragmentSourceCode => this._horzBlurTech?.fragmentSourceCode ?? '';

  /// The event emitted when the scene has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles changes to the scene.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// The blur value, this will be overridden by blur texture.
  double get blurValue => this._horzBlurTech?.blurValue ?? 0.0;

  set blurValue(double value) {
    this._horzBlurTech?.blurValue = value;
    this._vertBlurTech?.blurValue = value;
  }

  /// The color texture.
  Texture2D? get colorTexture => this._horzBlurTech?.colorTexture;

  set colorTexture(Texture2D? txt) {
    if (txt != null) {
      this._horzBlurTech?.colorTexture = txt;
    }
  }

  /// The blur texture, this will override the blur value.
  Texture2D? get blurTexture => this._horzBlurTech?.blurTexture;

  set blurTexture(Texture2D? txt) {
    if (txt != null) {
      this._horzBlurTech?.blurTexture = txt;
      this._vertBlurTech?.blurTexture = txt;
    }
  }

  /// The texture modification matrix.
  Matrix3? get textureMatrix => this._horzBlurTech?.textureMatrix;

  set textureMatrix(Matrix3? mat) {
    if (mat != null) {
      this._horzBlurTech?.textureMatrix = mat;
      this._vertBlurTech?.textureMatrix = mat;
    }
  }

  /// The blur value modification vector.
  /// This is the vector to apply to the color from the blur texture
  /// to get the blur value from the blur texture, by default it just uses red.
  Vector4? get blurAdjust => this._horzBlurTech?.blurAdjust;

  set blurAdjust(Vector4? vec) {
    if (vec != null) {
      this._horzBlurTech?.blurAdjust = vec;
      this._vertBlurTech?.blurAdjust = vec;
    }
  }

  /// The target defining the storage to render to.
  /// If null is set, the target is set to an FrontTarget.
  Target? get target => this._vertBlurPass?.target;

  set target(Target? target) => this._vertBlurPass?.target = target;

  /// Indicates if this scene should be rendered or not.
  @override
  bool get enabled => this._enabled;

  @override
  set enabled(bool enable) {
    if (this._enabled != enable) {
      final bool prev = this._enabled;
      this._enabled = enable;
      this._onChanged(ValueChangedEventArgs(this, 'enabled', prev, this._enabled));
    }
  }

  /// Renders the scenes with the given [state].
  @override
  void render(RenderState state) {
    if (!this._enabled) return;
    this._horzBlurPass?.render(state);
    this._vertBlurPass?.render(state);
  }
}

/// The render pass renders a single scene.
abstract class RenderPass extends Scene {
  /// The camera describing the view of the scene.
  abstract Camera? camera;

  /// The target defining the storage to render to.
  abstract Target? target;

  /// The default technique to render with.
  abstract techniques.Technique? technique;

  /// Event emitted on an render for this pass.
  Event get onRender;
}

/// Interface for any class which can be used to generate a scene.
abstract class Scene implements Changeable {
  /// Indicates if this scene should be rendered or not.
  abstract bool enabled;

  /// Render the scene with the given [state].
  void render(
    final RenderState state,
  );
}

/// The render pass renders a single scene.
class Stereoscopic implements Scene {
  /// Indicates if the scene is rendered or not.
  bool _enabled;

  /// The left constant for offsetting the camera.
  final Constant? _leftConstMat;

  /// The right constant for offsetting the camera.
  final Constant? _rightConstMat;

  /// The left camera's main mover group.
  Group? _leftMovGroup;

  /// The right camera's main mover group.
  Group? _rightMovGroup;

  /// The left camera describing the view of the scene.
  Perspective? _leftCamera;

  /// The right camera describing the view of the scene.
  Perspective? _rightCamera;

  /// The left target region.
  final Region2? _leftRegion;

  /// The right target region.
  final Region2? _rightRegion;

  /// The target defining the storage to render to.
  Target? _target;

  /// The set of passes to run on each side.
  final Collection<RenderPass> _passes;

  /// The distance between the left and right eye.
  double _eyeSpacing;

  /// The distance to when the left and right image cross.
  double _focusDistance;

  /// Event emitted on an render for this pass.
  Event? _onRender;

  /// Event emitted when a pass has changed.
  Event? _changed;

  /// Creates a new render pass.
  Stereoscopic(
      {bool enabled = true,
      Mover? mover,
      Target? target,
      List<RenderPass>? passes,
      double eyeSpacing = 0.1,
      double focusDistance = 12.0})
      : this._enabled = enabled,
        this._leftConstMat = Constant(),
        this._rightConstMat = Constant(),
        this._leftMovGroup = null,
        this._rightMovGroup = null,
        this._leftCamera = null,
        this._rightCamera = null,
        this._leftRegion = Region2(0.0, 0.0, 0.5, 1.0),
        this._rightRegion = Region2(0.5, 0.0, 0.5, 1.0),
        this._target = null,
        this._passes = Collection<RenderPass>(),
        this._eyeSpacing = eyeSpacing,
        this._focusDistance = focusDistance,
        this._onRender = null,
        this._changed = null {
    this._leftMovGroup = Group([null, this._leftConstMat]);
    this._rightMovGroup = Group([null, this._rightConstMat]);
    this._leftCamera = Perspective(mover: this._leftMovGroup);
    this._rightCamera = Perspective(mover: this._rightMovGroup);
    this._passes.setHandlers(onAddedHndl: this._onAddedRenderPass, onRemovedHndl: this._onRemovedRenderPass);
    if (passes != null) this._passes.addAll(passes);
    this.cameraMover = mover;
    this.target = target;
    if (passes != null) this._passes.addAll(passes);
    this._updateConstMats();
  }

  /// Event emitted on an render for this pass.
  Event get onRender => this._onRender ??= Event();

  /// The event emitted when the scene has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Handles a change in this pass.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Handles render passes being added.
  void _onAddedRenderPass(int index, Iterable<RenderPass> passes) {
    for (final RenderPass pass in passes) {
      pass.changed.add(this._onChanged);
    }
    this._onChanged(ItemsAddedEventArgs(this, index, passes));
  }

  /// Handles render passes being removed.
  void _onRemovedRenderPass(int index, Iterable<RenderPass> passes) {
    for (final RenderPass pass in passes) {
      pass.changed.remove(this._onChanged);
    }
    this._onChanged(ItemsRemovedEventArgs(this, index, passes));
  }

  /// Indicates if this scene should be rendered or not.
  @override
  bool get enabled => this._enabled;

  @override
  set enabled(bool enable) {
    if (this._enabled != enable) {
      final bool prev = this._enabled;
      this._enabled = enable;
      this._onChanged(ValueChangedEventArgs(this, 'enabled', prev, this._enabled));
    }
  }

  /// The camera mover describing the view of the scene.
  Mover? get cameraMover => this._leftMovGroup?[0];

  set cameraMover(Mover? camMover) {
    if (this._leftMovGroup?[0] != camMover) {
      final Mover? prev = this._leftMovGroup?[0];
      this._leftMovGroup?[0] = camMover;
      this._rightMovGroup?[0] = camMover;
      this._onChanged(ValueChangedEventArgs(this, 'cameraMover', prev, camMover));
    }
  }

  /// The target defining the storage to render to.
  Target? get target => this._target;

  set target(Target? target) {
    // ignore: parameter_assignments
    target ??= FrontTarget();
    if (this._target != target) {
      this._target?.changed.remove(this._onChanged);
      final Target? prev = this._target;
      this._target = target;
      this._target?.changed.add(this._onChanged);
      this._onChanged(ValueChangedEventArgs(this, 'target', prev, this._target));
    }
  }

  /// The passes in the order to render them.
  Collection<RenderPass> get passes => this._passes;

  /// The distance between the left and right eye.
  double get eyeSpacing => this._eyeSpacing;

  set eyeSpacing(double eyeSpacing) {
    if (!Comparer.equals(this._eyeSpacing, eyeSpacing)) {
      final double prev = this._eyeSpacing;
      this._eyeSpacing = eyeSpacing;
      this._updateConstMats();
      this._onChanged(ValueChangedEventArgs(this, 'eyeSpacing', prev, this._eyeSpacing));
    }
  }

  /// The distance to when the left and right image cross.
  double get focusDistance => this._focusDistance;

  set focusDistance(double focusDistance) {
    if (!Comparer.equals(this._focusDistance, focusDistance)) {
      final double prev = this._focusDistance;
      this._focusDistance = focusDistance;
      this._updateConstMats();
      this._onChanged(ValueChangedEventArgs(this, 'focusDistance', prev, this._focusDistance));
    }
  }

  /// Updates the camera offset constant matrices.
  void _updateConstMats() {
    final double tanAngle = math.atan2(this._eyeSpacing, this._focusDistance);
    this._leftConstMat?.matrix = Matrix4.translate(-eyeSpacing, 0.0, 0.0) * Matrix4.rotateY(tanAngle);
    this._rightConstMat?.matrix = Matrix4.translate(eyeSpacing, 0.0, 0.0) * Matrix4.rotateY(-tanAngle);
  }

  /// Render the scene with the given [state].
  @override
  void render(RenderState state) {
    if (!this._enabled) return;
    this.target?.region = this._leftRegion;
    for (final RenderPass pass in this._passes) {
      pass.target = this.target;
      pass.camera = this._leftCamera;
      pass.render(state);
    }
    this.target?.region = this._rightRegion;
    for (final RenderPass pass in this._passes) {
      pass.target = this.target;
      pass.camera = this._rightCamera;
      pass.render(state);
    }
    final StateEventArgs args = StateEventArgs(this, state);
    this._onRender?.emit(args);
  }
}
