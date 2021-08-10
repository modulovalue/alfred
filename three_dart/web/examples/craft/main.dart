library craft;

import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data' as data;

import 'package:three_dart/audio/audio.dart';
import 'package:three_dart/collisions/collisions.dart';
import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/data/data.dart';
import 'package:three_dart/events/events.dart';
import 'package:three_dart/input/input.dart';
import 'package:three_dart/intersections/intersections.dart';
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/math/open_simplex_noise.dart' as simplex;
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/textures/textures.dart';

import '../../common/common.dart' as common;

/// Starts up the 3Dart Craft example
void main() {
  common.ShellPage('3Dart Craft')
    ..addPar(['This example is in development and may still have a few issues and glitches.'])
    ..addLargeCanvas('targetCanvas')
    ..addControlBoxes(['buttons'])
    ..addHeader(1, 'About')
    ..addPar([
      '3Dart Craft is an example of how [3Dart|https://github.com/Grant-Nelson/three_dart] can be used ',
      'to create a [voxel|https://en.wikipedia.org/wiki/Voxel] environment for browser driven video games. ',
      'This example has no server backing it so none of the changes are persisted. It would take very little ',
      'to turn this into a simple online game.'
    ])
    ..addPar(['«[Back to Examples List|../../]'])
    ..addHeader(1, 'Controls')
    ..addPar(['• _Currently there are no controls for mobile browsers_'])
    ..addPar(['• *Esc* to release the mouse capture'])
    ..addPar(['• *W* or *Up arrow* to move forward'])
    ..addPar(['• *S* or *Down arrow* to move backward'])
    ..addPar(['• *A* or *Left arrow* to strife left'])
    ..addPar(['• *D* or *Right arrow* to strife right'])
    ..addPar(['• *Space bar* to jump'])
    ..addPar(['• *Tab* cycles the block selected which can be placed'])
    ..addPar(['• *Shift-Tab* cycles the selection in the reverse direction'])
    ..addPar(['• *Left click* or *Q* removes the currently highlighted block'])
    ..addPar(['• *Right click* or *E* places the selected block on the highlighted block'])
    ..addPar(['• *O* to return the starting location'])
    ..addHeader(1, 'Help wanted')
    ..addPar([
      'There is still much to be done, many cool new features, and several little bugs. ',
      'If you would like to contribute to this example, have an idea, find a bug, or just want to learn more about it, ',
      'check out the [project page|https://github.com/Grant-Nelson/three_dart/projects/1] or ',
      '[source code|https://github.com/Grant-Nelson/three_dart/tree/master/web/examples/craft].'
    ])
    ..addPar([
      'There are tons of ways to contribute. You could even start your own example. ',
      'See the [3Dart Project|https://github.com/Grant-Nelson/three_dart] for more.'
    ]);
  Timer.run(startCraft);
}

/// Start the craft game.
/// This is deferred so that if loading takes a while the page is at least loaded.
void startCraft() {
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId('targetCanvas');
  final Materials mats = Materials(td);
  final Generator gen = _getGenerator();
  final World world = World(mats, gen);
  final Sounds sounds = Sounds(td.audioLoader);
  final Player player = Player(td.userInput, world, sounds);
  final EntityPass scene = EntityPass(clearColor: Color4(0.576, 0.784, 0.929))
    ..onPreUpdate.add(world.update)
    ..camera?.mover = player.camera;
  // ignore: prefer_foreach
  for (final three_dart.Entity entity in world.entities) {
    scene.children.add(entity);
  }
  scene.children.add(player.entity);
  world.player = player;
  td.scene = scene;
  player.goHome();
  // Start timer for periodically generating chunks and animate.
  Timer.periodic(const Duration(milliseconds: Constants.worldTickMs), world.worldTick);
  Timer.periodic(const Duration(milliseconds: Constants.generateTickMs), world.generateTick);
  Timer.periodic(const Duration(milliseconds: Constants.animationTickMs), world.animationTick);
  final html.Element? elem = html.document.getElementById('buttons');
  final html.ButtonElement button = html.ButtonElement()
    ..text = 'Fullscreen'
    ..onClick.listen((_) => td.fullscreen = true);
  elem?.children.add(button);
  // Start debug output
  Timer.periodic(const Duration(milliseconds: Constants.debugPrintTickMs), (Timer time) {
    final String fps = td.fps.toStringAsFixed(2);
    print('$fps fps, ' + world.debugString());
  });
}

/// Gets the generator provided by the URL's query parameters.
/// If no seed was given or it is invalid then a new seed is randomly picked.
Generator _getGenerator() {
  int seed = -1;
  final String? seedQueryParam = Uri.base.queryParameters['seed'];
  if (seedQueryParam != null) {
    if (seedQueryParam == 'test') return TestGenerator();
    if (seedQueryParam == 'checkers') return CheckersGenerator();
    seed = int.tryParse(seedQueryParam) ?? -1;
  }
  if (seed <= 0) {
    seed = math.Random().nextInt(Constants.maxSeed);
    final Uri newUri = Uri.base.replace(queryParameters: <String, dynamic>{'seed': '$seed'});
    html.window.history.pushState(null, '3Dart Craft', newUri.toString());
  }
  return RandomGenerator(seed);
}

/// Information about a single block of information.
class BlockInfo {
  /// The block's x offset local to the chunk.
  /// This value is [0..chunkSideSize).
  final int x;

  /// The block's y offset local to the chunk.
  /// This value is [0..chunkSideSize).
  final int y;

  /// The block's z offset local to the chunk.
  /// This value is [0..chunkSideSize).
  final int z;

  /// The x location this chunk is at in the world.
  /// This is given even if [chunk] is null.
  final int chunkX;

  /// The y location this chunk is at in the world.
  /// This is given even if [chunk] is null.
  final int chunkZ;

  /// The chunk this block belongs to or null if the chunk doesn't exist.
  final Chunk? chunk;

  /// Creates a new block info.
  BlockInfo(this.x, this.y, this.z, this.chunkX, this.chunkZ, this.chunk);

  /// Gets the x offset for this block in the world coordinates.
  int get worldX => this.x + this.chunkX;

  /// Gets the z offset for this block in the world coordinates.
  int get worldZ => this.z + this.chunkZ;

  /// Creates a new block info for the one above this info.
  BlockInfo? get above => BlockInfo(this.x, this.y + 1, this.z, this.chunkX, this.chunkZ, this.chunk);

  /// Creates a new block info for the one below this info.
  BlockInfo? get below => BlockInfo(this.x, this.y - 1, this.z, this.chunkX, this.chunkZ, this.chunk);

  /// Creates a new block info for the one to the right of this info.
  BlockInfo? get right {
    int x = this.x + 1;
    int chunkX = this.chunkX;
    Chunk? chunk = this.chunk;
    if (x >= Constants.chunkSideSize) {
      x = 0;
      chunkX += Constants.chunkSideSize;
      chunk = chunk?.right;
    }
    return BlockInfo(x, this.y, this.z, chunkX, this.chunkZ, chunk);
  }

  /// Creates a new block info for the one to the left of this info.
  BlockInfo? get left {
    int x = this.x - 1;
    int chunkX = this.chunkX;
    Chunk? chunk = this.chunk;
    if (x < 0) {
      x = Constants.chunkSideSize - 1;
      chunkX -= Constants.chunkSideSize;
      chunk = chunk?.left;
    }
    return BlockInfo(x, this.y, this.z, chunkX, this.chunkZ, chunk);
  }

  /// Creates a new block info for the one to the front of this info.
  BlockInfo? get front {
    int z = this.z + 1;
    int chunkZ = this.chunkZ;
    Chunk? chunk = this.chunk;
    if (z >= Constants.chunkSideSize) {
      z = 0;
      chunkZ += Constants.chunkSideSize;
      chunk = chunk?.front;
    }
    return BlockInfo(this.x, this.y, z, this.chunkX, chunkZ, chunk);
  }

  /// Creates a new block info for the one to the back of this info.
  BlockInfo? get back {
    int z = this.z - 1;
    int chunkZ = this.chunkZ;
    Chunk? chunk = this.chunk;
    if (z < 0) {
      z = Constants.chunkSideSize - 1;
      chunkZ -= Constants.chunkSideSize;
      chunk = chunk?.back;
    }
    return BlockInfo(this.x, this.y, z, this.chunkX, chunkZ, chunk);
  }

  /// Creates a new block info for the one to the given region direction from this info.
  /// This only works for single direction component, no diagonals.
  BlockInfo? neighbor(HitRegion region) {
    if (region == HitRegion.XNeg) {
      return this.left;
    } else if (region == HitRegion.XPos) {
      return this.right;
    } else if (region == HitRegion.YNeg) {
      return this.below;
    } else if (region == HitRegion.YPos) {
      return this.above;
    } else if (region == HitRegion.ZNeg) {
      return this.back;
    } else if (region == HitRegion.ZPos) {
      return this.front;
    } else {
      return null;
    }
  }

  /// Gets the region for this info block.
  Region3 get blockRegion => Region3(this.x.toDouble() + this.chunkX.toDouble(), this.y.toDouble(),
      this.z.toDouble() + this.chunkZ.toDouble(), 1.0, 1.0, 1.0);

  /// Gets the neighbors which are solid.
  HitRegion solidNeighbors() {
    HitRegion neighbors = HitRegion.None;
    BlockInfo? info = this.left;
    if ((info != null) && BlockType.solid(info.value)) neighbors |= HitRegion.XNeg;
    info = this.right;
    if ((info != null) && BlockType.solid(info.value)) neighbors |= HitRegion.XPos;
    info = this.below;
    if ((info != null) && BlockType.solid(info.value)) neighbors |= HitRegion.YNeg;
    info = this.above;
    if ((info != null) && BlockType.solid(info.value)) neighbors |= HitRegion.YPos;
    info = this.back;
    if ((info != null) && BlockType.solid(info.value)) neighbors |= HitRegion.ZNeg;
    info = this.front;
    if ((info != null) && BlockType.solid(info.value)) neighbors |= HitRegion.ZPos;
    return neighbors;
  }

  /// Gets the block info string for debugging.
  @override
  String toString() => '$chunk.block($x, $y, $z, ($chunkX, $chunkZ), ${BlockType.string(value)})';

  /// Gets or sets the block value for this block.
  int get value => this.chunk?.getBlock(x, y, z) ?? ((y < 0) ? BlockType.Boundary : BlockType.Air);

  set value(int value) {
    this.chunk?.setBlock(x, y, z, value);
  }
}

/// BlockType is the enums for all the voxel block types
class BlockType {
  BlockType._();

  //====================================
  // Special blocks
  //====================================

  /// Default nothing block, works as air
  static const int Air = 0;

  /// Transparent water block
  static const int Water = 1;

  //====================================
  // Solid blocks
  //====================================

  /// Unbreakable floor used for below the chunks.
  static const int Boundary = 100;

  /// Brown on all sides dirt block
  static const int Dirt = 101;

  /// Turf block has grass turf on the top of dirt
  static const int Turf = 102;

  /// Basic grey rock block
  static const int Rock = 103;

  /// Off-white sand block beside water
  static const int Sand = 104;

  /// Dry leaves is turf with some leaves on it
  static const int DryLeaves = 105;

  /// Trunk block of a tree placed up right (up/down)
  static const int TrunkUD = 106;

  /// Trunk block of a tree placed on its side, facing north/south
  static const int TrunkNS = 107;

  /// Trunk block of a tree placed on its side, facing east/west
  static const int TrunkEW = 108;

  /// Block of grey bricks
  static const int Brick = 109;

  /// Red reflective solid block, like ruby
  static const int RedShine = 110;

  /// White reflective solid block, like silver
  static const int WhiteShine = 111;

  /// Yellow reflective solid block, like gold
  static const int YellowShine = 112;

  /// Black reflective solid block, like obsidian
  static const int BlackShine = 113;

  /// A block of leaves on the top of the tree
  static const int Leaves = 114;

  /// Wood block of a wooden planks placed up right (up/down)
  static const int WoodUD = 115;

  /// Wood block of a wooden planks placed on its side, facing north/south
  static const int WoodNS = 116;

  /// Wood block of a wooden planks placed on its side, facing east/west
  static const int WoodEW = 117;

  //====================================
  // Open blocks
  //====================================

  /// Grass is an alpha textured plant for grass
  static const int Grass = 200;

  /// Fern is an alpha textured plant for a fern
  static const int Fern = 201;

  /// Flowers is an alpha textured plant the small white flower
  static const int WhiteFlower = 202;

  /// Flowers is an alpha textured plant the blue tuffs flower
  static const int BlueFlower = 203;

  /// Flowers is an alpha textured plant the red flower
  static const int RedFlower = 204;

  /// Mushroom is a special model for the mushrooms
  static const int Mushroom = 205;

  //====================================

  /// Placeable blocks in the order to show in the hand.
  static final List<int> PlaceableBlocks = [
    Dirt,
    Turf,
    Rock,
    Sand,
    DryLeaves,
    TrunkUD,
    WoodUD,
    Brick,
    RedShine,
    WhiteShine,
    YellowShine,
    BlackShine,
    Water,
    Leaves,
    Grass,
    Fern,
    WhiteFlower,
    BlueFlower,
    RedFlower,
    Mushroom
  ];

  /// string gets the string for the given block type value.
  static String string(int value) {
    switch (value) {
      case Air:
        return "air";
      case Water:
        return "water";
      case Boundary:
        return "boundary";
      case Dirt:
        return "dirt";
      case Turf:
        return "turf";
      case Rock:
        return "rock";
      case Sand:
        return "sand";
      case DryLeaves:
        return "dryLeaves";
      case TrunkUD:
        return "trunk-ud";
      case TrunkNS:
        return "trunk-ns";
      case TrunkEW:
        return "trunk-ew";
      case Brick:
        return "brick";
      case RedShine:
        return "redShine";
      case WhiteShine:
        return "whiteShine";
      case YellowShine:
        return "yellowShine";
      case BlackShine:
        return "blackShine";
      case Leaves:
        return "leaves";
      case WoodUD:
        return "wood-ud";
      case WoodNS:
        return "wood-ns";
      case WoodEW:
        return "wood-ew";
      case Grass:
        return "grass";
      case Fern:
        return "fern";
      case WhiteFlower:
        return "whiteFlower";
      case BlueFlower:
        return "blueFlower";
      case RedFlower:
        return "redFlower";
      case Mushroom:
        return "mushroom";
    }
    return "undefined";
  }

  /// hard determines if the given block type can not be walked through.
  static bool hard(int value) {
    return (value >= Boundary) && (value <= WoodEW);
  }

  /// solid determines if the given block type can not be seen through.
  static bool solid(int value) {
    return (value >= Boundary) && (value <= WoodEW);
  }

  /// plant determines if the given block type is a plant.
  static bool plant(int value) {
    return (value >= Grass) && (value <= Mushroom);
  }

  /// open determines if the given block type can be seen through.
  static bool open(int value) {
    return (value >= Grass) && (value <= Mushroom);
  }

  /// Determines if the side of the block should be drawn.
  static bool drawSide(int value, int neighbor) {
    if (value == neighbor) return false;
    if (neighbor == Air) return true;
    if (value == Water) return open(neighbor);
    if (neighbor == Water) return !open(value);
    return !open(value) && open(neighbor);
  }
}

/// The generator will initialize chunks to create a world flat test world covered
/// with a checkered pattern. The edges of the chunks can be highlighted.
class CheckersGenerator implements Generator {
  /// Indicates the edges of chunks should be highlighted with red.
  final bool _highlightChunkEdges;

  /// The height to build the chunks up to.
  final int _height;

  /// Creates a new generator for the given world.
  CheckersGenerator({bool highlightChunkEdges = true, int height = 10})
      : this._highlightChunkEdges = highlightChunkEdges,
        this._height = height;

  /// Fills the given chunk with data.
  @override
  void fillChunk(Chunk? chunk) {
    if (chunk == null) return;
    for (int x = 0; x < Constants.chunkSideSize; x++) {
      for (int z = 0; z < Constants.chunkSideSize; z++) {
        for (int y = 0; y < this._height; y++) {
          chunk.setBlock(x, y, z, this._getValue(x, y, z));
        }
      }
    }
    chunk.finishGenerate();
  }

  /// Determines the value to put into the given x, y, and z.
  int _getValue(int x, int y, int z) {
    if (this._highlightChunkEdges) {
      // Highlight the x and z is zero edge.
      if (x == 0 || z == 0) return (x == 0 && z == 0) ? BlockType.YellowShine : BlockType.RedShine;
      // Indicate which side of the chunk the highlight is on.
      if (x == 1 && z == 1) return BlockType.RedShine;
    }
    return (x + y + z).isEven ? BlockType.BlackShine : BlockType.WhiteShine;
  }
}

/// A chunk represents the voxel information for a large number of blocks.
/// This makes up one of the many square areas of the world.
class Chunk {
  /// The offset to the left edge of the chunk.
  int _x;

  /// The offset to the front edge of the chunk.
  int _z;

  /// This is the world this chunk belongs to.
  final World _world;

  /// The list of block information for this chunk.
  final data.Uint8List _data;

  /// The entities for rendering all the different types of block textures.
  final List<three_dart.Entity> _entities;

  /// Indicates if the chunk eventually needs updating but not right away.
  bool _dirty;

  /// Indicates if the chunk's entities need to be updated to reflect the chunk's data.
  bool _needUpdate;

  /// Indicates if the chunk hasn't been generated yet.
  bool _needGen;

  /// Creates a new chunk for the given [_world].
  Chunk(this._world)
      : this._data = data.Uint8List(Constants.chunkDataLength),
        this._entities = [],
        this._x = 0,
        this._z = 0,
        this._dirty = false,
        this._needUpdate = true,
        this._needGen = true {
    for (final three_dart.Entity parent in this._world.entities) {
      final three_dart.Entity entity = three_dart.Entity();
      parent.children.add(entity);
      this._entities.add(entity);
    }
  }

  /// Prepares this chunk for uses.
  void prepare(int x, int z) {
    this._x = x;
    this._z = z;
    this._dirty = true;
    this._needGen = true;
    this._enabled = false;
  }

  /// Makes this chunk available to be reused.
  void freeup() {
    this._dirty = false;
    this._enabled = false;
    this._needGen = true;
    this._needUpdate = false;
  }

  /// The offset to the left edge of the chunk.
  int get x => this._x;

  /// The offset to the front edge of the chunk.
  int get z => this._z;

  /// Gets the string for this chunk for debugging.
  @override
  String toString() => "chunk(${this._x}, ${this._z})";

  /// Gets the entities used for rendering this chunk.
  List<three_dart.Entity> get entities => this._entities;

  /// Gets or sets if this chunk eventually needs an update.
  bool get dirty => this._dirty && !this._needGen;

  set dirty(bool dirty) => this._dirty = dirty;

  /// Gets or sets if this chunk needs an update.
  bool get needUpdate => this._needUpdate;

  set needUpdate(bool update) => this._needUpdate = update;

  /// Gets if this chunk needs to be generated.
  bool get needToGenerate => this._needGen;

  /// Indicates that the chunk is finished being generated.
  void finishGenerate() {
    this._needGen = false;
    this._dirty = true;
    this._enabled = false;
    this.left?.dirty = true;
    this.right?.dirty = true;
    this.front?.dirty = true;
    this.back?.dirty = true;
  }

  /// Calculates the chunk's data offset for the given x, y, and z location.
  int _index(int x, int y, int z) => (x * Constants.chunkYSize + y) * Constants.chunkSideSize + z;

  /// Gets the value of the block at the given location.
  /// This will not check neighbors if the coordinates are outside this chunk.
  int getBlock(int x, int y, int z) {
    if (y < 0) return BlockType.Boundary;
    if (y >= Constants.chunkYSize) return BlockType.Air;
    if (x < 0) return BlockType.Air;
    if (x >= Constants.chunkSideSize) return BlockType.Air;
    if (z < 0) return BlockType.Air;
    if (z >= Constants.chunkSideSize) return BlockType.Air;
    return this._data[this._index(x, y, z)];
  }

  /// Gets the block from the given neighbor, if the neighbor is null air is returned.
  int _neighborBlock(Chunk? neighbor, int x, int y, int z) => neighbor?.getWorldBlock(x, y, z) ?? BlockType.Air;

  /// Gets the value of the block at the given location.
  /// If the coordinates are outside this chunk the neighboring chunk will checked.
  int getWorldBlock(int x, int y, int z) {
    if (y < 0) return BlockType.Boundary;
    if (y >= Constants.chunkYSize) return BlockType.Air;
    if (x < 0) return this._neighborBlock(left, x + Constants.chunkSideSize, y, z);
    if (x >= Constants.chunkSideSize) return this._neighborBlock(right, x - Constants.chunkSideSize, y, z);
    if (z < 0) return this._neighborBlock(back, x, y, z + Constants.chunkSideSize);
    if (z >= Constants.chunkSideSize) return this._neighborBlock(front, x, y, z - Constants.chunkSideSize);
    return this._data[this._index(x, y, z)];
  }

  /// Sets the value of the block at the given location.
  /// This will not set neighbors if the coordinates are outside this chunk.
  /// Returns true if block set, false if not.
  bool setBlock(int x, int y, int z, int value) {
    if (y < 0) return false;
    if (y >= Constants.chunkYSize) return false;
    if (x < 0) return false;
    if (x >= Constants.chunkSideSize) return false;
    if (z < 0) return false;
    if (z >= Constants.chunkSideSize) return false;
    this._data[this._index(x, y, z)] = value;
    return true;
  }

  /// Gets the chunk to the left (XNeg) of this chunk.
  Chunk? get left => this._world.findChunk(this.x - Constants.chunkSideSize, this.z);

  /// Gets the chunk to the front (ZPos) of this chunk.
  Chunk? get front => this._world.findChunk(this.x, this.z + Constants.chunkSideSize);

  /// Gets the chunk to the right (XPos) of this chunk.
  Chunk? get right => this._world.findChunk(this.x + Constants.chunkSideSize, this.z);

  /// Gets the chunk to the back (ZNeg) of this chunk.
  Chunk? get back => this._world.findChunk(this.x, this.z - Constants.chunkSideSize);

  /// Determines the highest non-air block in the given [x] and [z] column.
  /// If no ground is found then the given [defaultY] is returned.
  int topHit(int x, int z, [int defaultY = Constants.chunkYSize]) {
    for (int y = Constants.chunkYSize - 1; y >= 0; y--) {
      if (BlockType.solid(this.getBlock(x, y, z))) return y;
    }
    return defaultY;
  }

  /// Updates the shapes in the entities for rendering this chunk.
  void updateShape() {
    if (this._needGen || !this._needUpdate) return;
    this._needUpdate = false;
    this._dirty = false;
    final Shaper shape = Shaper(this._world.materials);
    shape.buildChunkShapes(this);
    shape.finish(this.entities);
  }

  /// Sets all of the entities to either enabled or disabled.
  set _enabled(bool enabled) {
    for (final three_dart.Entity entity in this._entities) {
      entity.enabled = enabled;
    }
  }

  /// Updates the visibility of this chunk.
  void updateVisibility(Point2 loc, Point2 front) {
    if (this._needGen || this._needUpdate) {
      this._enabled = false;
      return;
    }
    final Region2 aabb = Region2(
        this.x.toDouble(), this.z.toDouble(), Constants.chunkSideSize.toDouble(), Constants.chunkSideSize.toDouble());
    final Point2 nearLoc = aabb.nearestPoint(loc);
    if (nearLoc.distance2(loc) < Constants.minDrawDist2) {
      this._enabled = true;
      return;
    }
    final Point2 nearFront = aabb.nearestPoint(front);
    final Vector2 forward = Vector2(front.x - loc.x, front.y - loc.y).normal();
    Vector2 toNear = Vector2(nearFront.x - loc.x, nearFront.y - loc.y);
    final double length = toNear.length2();
    if (length > Constants.maxDrawDist2) {
      this._enabled = false;
      return;
    }
    toNear = toNear / length;
    final double dot = forward.dot(toNear);
    final bool enabled = dot > 0.0;
    this._enabled = enabled;
  }
}

/// A collider for determining a region colliding with the world.
class Collider {
  final World _world;
  Point3 _loc;
  Region3 _region;
  Vector3 _vector;
  HitRegion _touching;
  final List<Region3> _blocks;
  final List<HitRegion> _blockSides;
  final List<bool> _hasHit;

  /// Creates a new collider object.
  Collider(this._world)
      : this._loc = Point3.zero,
        this._region = Region3.zero,
        this._vector = Vector3.zero,
        this._touching = HitRegion.None,
        this._blocks = [],
        this._blockSides = [],
        this._hasHit = [];

  /// Performs a collision between the given region at the given location
  /// moving at the given vector and the solid blocks in the world.
  bool collide(Region3 region, Point3 loc, Vector3 vector) {
    this._loc = loc;
    this._region = region;
    this._vector = vector;
    this._touching = HitRegion.None;
    this._collectBlocks();
    while (this._singleCollide()) {}
    this._loc += Point3.fromVector3(this._vector);
    return true;
  }

  /// Gets the location after the collision.
  Point3? get location => this._loc;

  /// Gets the resulting touching sides of the collisions.
  HitRegion get touching => this._touching;

  /// Handles collecting the blocks from the world for the collision.
  void _collectBlocks() {
    final Region3 region = this._region.translate(Vector3.fromPoint3(this._loc));
    final Region3 aabb = region.expandWithRegion(region.translate(this._vector));
    final BlockInfo? minXYZ = this._world.getBlock(aabb.x, aabb.y, aabb.z);
    final BlockInfo? maxXYZ = this._world.getBlock(aabb.x + aabb.dx, aabb.y + aabb.dy, aabb.z + aabb.dz);
    if (minXYZ == null || maxXYZ == null) return;
    final maxWorldX = maxXYZ.worldX, maxWorldZ = maxXYZ.worldZ;
    this._blocks.clear();
    this._blockSides.clear();
    this._hasHit.clear();
    for (BlockInfo? x = minXYZ; (x != null) && (x.worldX <= maxWorldX); x = x.right) {
      for (BlockInfo? y = x; (y != null) && (y.y <= maxXYZ.y); y = y.above) {
        for (BlockInfo? z = y; (z != null) && (z.worldZ <= maxWorldZ); z = z.front) {
          if (BlockType.hard(z.value)) {
            final HitRegion sides = z.solidNeighbors();
            if (sides != HitRegion.Cardinals) {
              this._blocks.add(z.blockRegion);
              this._blockSides.add(HitRegion.Cardinals & ~sides);
              this._hasHit.add(false);
            }
          }
        }
      }
    }
  }

  /// Handles a collision of a single edge.
  bool _singleCollide() {
    if (this._vector.isZero()) return false;
    final Region3 region = this._region.translate(Vector3.fromPoint3(this._loc));
    double parametric = 0.0;
    HitRegion hitRegion = HitRegion.None;
    int hitIndex = -1;
    for (int i = 0; i < this._blocks.length; i++) {
      if (!this._hasHit[i]) {
        final Region3 block = this._blocks[i];
        final HitRegion sides = this._blockSides[i];
        final TwoAABB3Result cur =
            twoAABB3(region, block, this._vector, Vector3.zero, HitRegion.All, sides);
        if (cur.collided) {
          if ((hitRegion == HitRegion.None) || (parametric > cur.parametric)) {
            hitRegion = cur.region;
            parametric = cur.parametric;
            hitIndex = i;
          }
        }
      }
    }
    if (hitRegion == HitRegion.None) return false;
    this._hasHit[hitIndex] = true;
    final Vector3 shift = this._vector * parametric;
    final Vector3 remainder = this._vector * (1.0 - parametric);
    if ((hitRegion == HitRegion.XPos) || (hitRegion == HitRegion.XNeg)) {
      final double x = this._loc.x + shift.dx;
      this._loc = Point3(x, this._loc.y + shift.dy, this._loc.z + shift.dz);
      this._vector = Vector3(0.0, remainder.dy, remainder.dz);
    } else if ((hitRegion == HitRegion.YPos) || (hitRegion == HitRegion.YNeg)) {
      final double y = this._loc.y + shift.dy;
      this._loc = Point3(this._loc.x + shift.dx, y, this._loc.z + shift.dz);
      this._vector = Vector3(remainder.dx, 0.0, remainder.dz);
    } else if ((hitRegion == HitRegion.ZPos) || (hitRegion == HitRegion.ZNeg)) {
      final double z = this._loc.z + shift.dz;
      this._loc = Point3(this._loc.x + shift.dx, this._loc.y + shift.dy, z);
      this._vector = Vector3(remainder.dx, remainder.dy, 0.0);
    }
    this._touching |= hitRegion;
    return true;
  }

  /// Gets the string for this collision result.
  @override
  String toString() => 'Collider($_loc, $_touching)';
}

/// Set of constants for Craft.
class Constants {
  /// The maximum number, 1<<32 (limited by nextInt), allowed for the seed.
  static const int maxSeed = 4294967296;

  /// The time in milliseconds between world chunk updates.
  static const int worldTickMs = 750;

  /// The time in milliseconds between picking up new chunks to generate.
  static const int generateTickMs = 70;

  /// The time in milliseconds between switching images.
  static const int animationTickMs = 250;

  /// The time in milliseconds between debug output prints.
  static const int debugPrintTickMs = 5000;

  /// The path to the textures.
  static const String imgFolder = "./textures/";

  /// The file extension for all textures.
  static const String fileExt = ".png";

  //----------------------------------------------
  // World Generation Constants
  //----------------------------------------------

  /// The number of chunks to preallocate.
  static const int initialGraveyardSize = 140;

  /// The number of blocks wide and deep of every chunk.
  /// WARNING: unit-tests expect 16, if you change this update the tests.
  static const int chunkSideSize = 16;

  /// The number of blocks tall of every chunk.
  static const int chunkYSize = 48;

  /// The total number of blocks per chunk.
  static const int chunkDataLength = chunkSideSize * chunkYSize * chunkSideSize;

  /// The height of the water.
  static const int waterDepth = 8;

  /// The maximum edge for additional sand around water.
  static const int maxEdgeSand = waterDepth + 2;

  /// The minimum edge for additional sand around water.
  static const int minEdgeSand = waterDepth - 2;

  /// The number of dirt blocks under the turf.
  static const int dirtDepth = 2;

  /// The number of sand blocks directly underwater.
  static const int sandDepth = 2;

  /// The size (height) of the start pyramid.
  static const int pyramidSize = 30;

  /// The minimum height before no trees may be added.
  static const int treeMin = 10;

  /// The height of a tree.
  static const int treeHeight = 8;

  /// The radius (scan area) of the leaves on a tree.
  static const int leavesRadius = 3;

  /// The radius squared (curve) of the leaves on the tree.
  static const int leavesRadius2 = 12;

  /// The dead leaves radius (scan area) below a tree.
  static const int deadLeavesRadius = 3;

  /// The dead leaves radius squared (curve) below a tree.
  static const int deadLeavesRadius2 = 10;

  /// The size of the X and Z border around the terrain required for trees.
  static const int borderSize = 3;

  /// The minimum X and Z including the border, value is inclusive to the range.
  static const int paddedMin = -borderSize;

  /// The maximum X and Z including the border, value is exclusive to the range.
  static const int paddedMax = chunkSideSize + borderSize;

  /// The total X and Z size including borders.
  static const int paddedSize = paddedMax - paddedMin;

  /// The number of values in the height cache of the generator.
  static const int heightCacheLength = paddedSize * paddedSize;

  //----------------------------------------------
  // World Rendering & Chunk Loading Constants
  //----------------------------------------------

  /// The minimum number of blocks away from the player to always render a chunk.
  static const double minDrawDist2 = 10.0 * 10.0;

  /// The maximum number of blocks away from the player to render before not drawing a chunk.
  static const double maxDrawDist2 = 80.0 * 80.0;

  /// The maximum chunk X and Z distance from the player to keep chunks.
  static const int maxChunkDist = chunkSideSize * 8;

  /// The minimum chunk X and Z distance from the player that chunks should be loaded.
  static const int minChunkDist = chunkSideSize * 4;

  /// The initial chunk distance to preload before starting the player.
  static const int initChunkDist = chunkSideSize * 2;

  //----------------------------------------------
  // Player Constants
  //----------------------------------------------

  /// The X starting location of the player.
  static const double playerStartX = 0.5;

  /// The Y starting location offset from the highest solid block of the player.
  static const double playerStartYOffset = 10.0;

  /// The Z starting location of the player.
  static const double playerStartZ = 0.5;

  /// The gravity force to apply onto the player.
  static const double gravity = -100.0;

  /// The speed at which the player walks.
  static const double walkSpeed = 6.0;

  /// The maximum speed the player can fall at, terminal velocity.
  static const double maxFallSpeed = 60.0;

  /// The velocity to apply when the player jumps.
  static const double jumpSpeed = 30.0;

  /// The maximum distance to set a highlight selection from the player.
  static const double highlightDistance = 6.0;

  /// The sensitivity of the locked pointer mouse.
  static const double mouseSensitivity = 0.4;

  /// The region of the player's bounding box around the camera.
  /// This is used for collision detection.
  static final Region3 playerRegion = Region3(-0.25, -1.5, -0.25, 0.5, 1.9, 0.5);

  /// The maximum velocity in which collision detection is ignored.
  static const double maxCollisionSpeedSquared = 100.0;

  //----------------------------------------------
  // Mathematical Constants
  //----------------------------------------------

  static final Vector3 topNorm = Vector3.posY;
  static final Vector3 bottomNorm = Vector3.negY;
  static final Vector3 leftNorm = Vector3.posX;
  static final Vector3 rightNorm = Vector3.negX;
  static final Vector3 frontNorm = Vector3.posZ;
  static final Vector3 backNorm = Vector3.negZ;

  static final Point3 frontTopLeft = Point3(-0.5, 0.5, 0.5);
  static final Point3 frontTopRight = Point3(0.5, 0.5, 0.5);
  static final Point3 frontBottomLeft = Point3(-0.5, -0.5, 0.5);
  static final Point3 frontBottomRight = Point3(0.5, -0.5, 0.5);
  static final Point3 backTopLeft = Point3(-0.5, 0.5, -0.5);
  static final Point3 backTopRight = Point3(0.5, 0.5, -0.5);
  static final Point3 backBottomLeft = Point3(-0.5, -0.5, -0.5);
  static final Point3 backBottomRight = Point3(0.5, -0.5, -0.5);

  Constants._();
}

/// The generator will initialize chunks to create a world flat grass world.
class FlatGenerator implements Generator {
  /// The height to build the rock up to.
  final int _rockHeight;

  /// The height to build the dirt up to.
  /// If this is less than the rock height no dirt will be added.
  final int _dirtHeight;

  /// Creates a new generator for the given world.
  FlatGenerator([int rockHeight = 8, int dirtHeight = 9])
      : this._rockHeight = rockHeight,
        this._dirtHeight = dirtHeight;

  /// Fills the given chunk with data.
  @override
  void fillChunk(Chunk? chunk) {
    if (chunk == null) return;
    final int turfY = math.max(this._rockHeight, this._dirtHeight);
    for (int x = 0; x < Constants.chunkSideSize; x++) {
      for (int z = 0; z < Constants.chunkSideSize; z++) {
        for (int y = 0; y < this._rockHeight; y++) {
          chunk.setBlock(x, y, z, BlockType.Rock);
        }
        for (int y = this._rockHeight; y < this._dirtHeight; y++) {
          chunk.setBlock(x, y, z, BlockType.Dirt);
        }
        chunk.setBlock(x, turfY, z, BlockType.Turf);
      }
    }
    chunk.finishGenerate();
  }
}

/// The generator for initializing chunks to create the world.
abstract class Generator {
  /// Fills the given chunk with data.
  void fillChunk(Chunk chunk);
}

/// This defines which materials to use on which side of a block.
/// This will be associated with a block value in a map so that the chunk can pick
/// the correct materials when rendering.
class CubeData {
  /// The index of the material to apply to the top of the block.
  final int topIndex;

  /// The index of the material to apply to the bottom of the block.
  final int bottomIndex;

  /// The index of the material to apply to the left of the block.
  final int leftIndex;

  /// The index of the material to apply to the right of the block.
  final int rightIndex;

  /// The index of the material to apply to the front of the block.
  final int frontIndex;

  /// The index of the material to apply to the back of the block.
  final int backIndex;

  /// Creates a new cube data with the given values.
  CubeData(this.topIndex, this.bottomIndex, this.leftIndex, this.rightIndex, this.frontIndex,
      this.backIndex);
}

/// This loads and prepares all the materials (colors and textures) used for rendering.
class Materials {
  final three_dart.ThreeDart _td;
  final Map<int, CubeData> _cubeData;
  final Map<int, List<int>> _matData;
  final List<MaterialLight> _mats;
  Directional? _light;
  MaterialLight? _selection;
  MaterialLight? _crosshair;
  Texture2DChanger? _waterChanger;

  /// Creates a new material collection and starts loading the materials.
  Materials(this._td)
      : this._cubeData = {},
        this._matData = {},
        this._mats = [],
        this._light = null,
        this._selection = null,
        this._crosshair = null,
        this._waterChanger = null {
    // Create the light source attached to most of the textures a used for the world being created.
    this._light = Directional(
        color: Color3.white(),
        mover: Constant.lookAtTarget(Point3.zero, Vector3.posZ, Point3(0.5, -1.0, 0.2)));
    final int boundary = this._addMat("boundary");
    final int brick = this._addMat("brick");
    final int dirt = this._addMat("dirt");
    final int dryLeavesSide = this._addMat("dryLeavesSide");
    final int dryLeavesTop = this._addMat("dryLeavesTop");
    final int leaves = this._addMat("leaves");
    final int rock = this._addMat("rock");
    final int sand = this._addMat("sand");
    final int trunkEnd = this._addMat("trunkEnd");
    final int trunkSide = this._addMat("trunkSide");
    final int trunkTilted = this._addMat("trunkTilted");
    final int turfSide = this._addMat("turfSide");
    final int turfTop = this._addMat("turfTop");
    final int woodEnd = this._addMat("woodEnd");
    final int woodSide = this._addMat("woodSide");
    final int woodTilted = this._addMat("woodTilted");
    final int blackShine = this._addMat("blackShine", true);
    final int redShine = this._addMat("redShine", true);
    final int yellowShine = this._addMat("yellowShine", true);
    final int whiteShine = this._addMat("whiteShine", true);
    final int mushroomBottom = this._addMat("mushroomBottom");
    final int mushroomSide = this._addMat("mushroomSide");
    final int mushroomTop = this._addMat("mushroomTop");
    // Load alpha materials (done later so that the entities made in shaper are drawn later)
    final int grass = this._addMat("grass");
    final int fern = this._addMat("fern");
    final int blueFlowers = this._addMat("blueFlowers");
    final int redFlowers = this._addMat("redFlowers");
    final int whiteFlowers = this._addMat("whiteFlowers");
    waterChanger.textures.addAll([
      this._loadText("water1"),
      this._loadText("water2"),
      this._loadText("water3"),
    ]);
    final int water = this._addMatTxt(waterChanger, true);
    //                value,                 top,           bottom,        left,          right,         front,         back
    this._addCubeData(BlockType.Boundary, boundary, boundary, boundary, boundary, boundary, boundary);
    this._addCubeData(BlockType.Dirt, dirt, dirt, dirt, dirt, dirt, dirt);
    this._addCubeData(BlockType.Turf, turfTop, dirt, turfSide, turfSide, turfSide, turfSide);
    this._addCubeData(BlockType.Rock, rock, rock, rock, rock, rock, rock);
    this._addCubeData(BlockType.Sand, sand, sand, sand, sand, sand, sand);
    this._addCubeData(
        BlockType.DryLeaves, dryLeavesTop, dirt, dryLeavesSide, dryLeavesSide, dryLeavesSide, dryLeavesSide);
    this._addCubeData(BlockType.TrunkUD, trunkEnd, trunkEnd, trunkSide, trunkSide, trunkSide, trunkSide);
    this._addCubeData(BlockType.TrunkNS, trunkSide, trunkSide, trunkTilted, trunkTilted, trunkEnd, trunkEnd);
    this._addCubeData(BlockType.TrunkEW, trunkTilted, trunkTilted, trunkEnd, trunkEnd, trunkTilted, trunkTilted);
    this._addCubeData(BlockType.Brick, brick, brick, brick, brick, brick, brick);
    this._addCubeData(BlockType.RedShine, redShine, redShine, redShine, redShine, redShine, redShine);
    this._addCubeData(BlockType.WhiteShine, whiteShine, whiteShine, whiteShine, whiteShine, whiteShine, whiteShine);
    this._addCubeData(
        BlockType.YellowShine, yellowShine, yellowShine, yellowShine, yellowShine, yellowShine, yellowShine);
    this._addCubeData(BlockType.BlackShine, blackShine, blackShine, blackShine, blackShine, blackShine, blackShine);
    this._addCubeData(BlockType.Leaves, leaves, leaves, leaves, leaves, leaves, leaves);
    this._addCubeData(BlockType.WoodUD, woodEnd, woodEnd, woodSide, woodSide, woodSide, woodSide);
    this._addCubeData(BlockType.WoodNS, woodSide, woodSide, woodTilted, woodTilted, woodEnd, woodEnd);
    this._addCubeData(BlockType.WoodEW, woodTilted, woodTilted, woodEnd, woodEnd, woodTilted, woodTilted);
    this._addCubeData(BlockType.Water, water, water, water, water, water, water);
    this._addMatData(BlockType.Grass, [grass]);
    this._addMatData(BlockType.Fern, [fern]);
    this._addMatData(BlockType.WhiteFlower, [whiteFlowers]);
    this._addMatData(BlockType.BlueFlower, [blueFlowers]);
    this._addMatData(BlockType.RedFlower, [redFlowers]);
    this._addMatData(BlockType.Mushroom, [mushroomTop, mushroomBottom, mushroomSide]);
  }

  /// The block value to cube data map to define which materials to apply to which sides.
  CubeData? cubeData(int value) => this._cubeData[value];

  /// The materials to use for non-cube block values such as flowers.
  List<int>? matData(int value) => this._matData[value];

  /// This full set of all the materials used by craft.
  List<MaterialLight> get materials => this._mats;

  /// The changer to animate the water.
  Texture2DChanger get waterChanger => this._waterChanger ??= Texture2DChanger();

  /// The material used for all the sides of the selection box.
  MaterialLight get selection => this._selection ??= this._addEmissionMat("selection");

  /// The material used for the cross hair in the center of the screen.
  MaterialLight get crosshair => this._crosshair ??= this._addEmissionMat("crosshair");

  /// Loads a texture with the given file name.
  Texture2D _loadText(String fileName) {
    final String path = Constants.imgFolder + fileName + Constants.fileExt;
    return this._td.textureLoader.load2DFromFile(path, wrapEdges: false, nearest: false, mipMap: true);
  }

  /// Loads a material with lighting information and adds it to the material list.
  /// Returns the index for the new material.
  int _addMat(String fileName, [bool shiny = false]) => this._addMatTxt(this._loadText(fileName), shiny);

  /// Creates a material with lighting information and adds
  /// it to the material list with the given texture.
  /// Returns the index for the new material.
  int _addMatTxt(Texture2D blockTxt, [bool shiny = false]) {
    final MaterialLight tech = MaterialLight()
      ..ambient.color = Color3.gray(0.8)
      ..diffuse.color = Color3.gray(0.4)
      ..ambient.texture2D = blockTxt
      ..diffuse.texture2D = blockTxt
      ..alpha.texture2D = blockTxt;
    final light = this._light;
    if (light != null) tech.lights.add(light);
    if (shiny) {
      tech.specular
        ..color = Color3.gray(0.5)
        ..shininess = 3.0;
    }
    this._mats.add(tech);
    return this._mats.length - 1;
  }

  /// Loads a material with no lighting information and adds it to the material list.
  /// Returns the material which was loaded.
  MaterialLight _addEmissionMat(String fileName) {
    final Texture2D blockTxt = this._loadText(fileName);
    final MaterialLight tech = MaterialLight()
      ..emission.texture2D = blockTxt
      ..alpha.texture2D = blockTxt;
    return tech;
  }

  /// Adds a cube data entry for the given block value.
  void _addCubeData(
          int value, int topIndex, int bottomIndex, int leftIndex, int rightIndex, int frontIndex, int backIndex) =>
      this._cubeData[value] = CubeData(topIndex, bottomIndex, leftIndex, rightIndex, frontIndex, backIndex);

  /// Adds the materials for non-cube values.
  void _addMatData(int value, List<int> indices) => this._matData[value] = indices;
}

/// A callback for handling the block information while traversing neighbors.
/// Return true to stop and return this info, false to continue.
typedef HandleTraverseNeighbor = bool Function(NeighborBlockInfo info);

/// Block information result from finding a neighboring block info.
class NeighborBlockInfo {
  /// The neighboring block information.
  final BlockInfo? info;

  /// The direction this neighbor was from the other block.
  /// Will be only XNeg, XPos, YNeg, YPos, ZNeg, or ZPos.
  final HitRegion region;

  /// The vector that is being traversed neighbor by neighbor.
  final Ray3 ray;

  /// The count for the number of neighbors which have been traversed.
  final int depth;

  /// Creates a new neighbor block info result.
  NeighborBlockInfo(this.info, this.region, this.ray, this.depth);

  /// Gets the string for this neighbor block info.
  @override
  String toString() => "NeighborBlockInfo($info, $region, $ray, $depth)";
}

/// The generator will initialize chunks to create a world with randomly generated terrain.
/// This is the main generator for this game.
class RandomGenerator implements Generator {
  /// The noise generator for the world.
  final simplex.OpenSimplexNoise _simplex;

  /// The temporary terrain height so that noise doesn't have to be calculated as much.
  final data.Uint8List _tempCache;

  /// The current chunk that is being worked on.
  Chunk? _curChunk;

  /// Creates a new generator for the given world.
  RandomGenerator([int seed = 0])
      : this._simplex = simplex.OpenSimplexNoise(seed),
        this._tempCache = data.Uint8List(Constants.heightCacheLength),
        this._curChunk = null;

  /// Fills the given chunk with data.
  @override
  void fillChunk(Chunk? chunk) {
    if (chunk == null) return;
    this._curChunk = chunk;
    this._prepareHeightCache();
    this._clearChunk();
    this._terrain();
    this._applyWater();
    this._applySand();
    this._trees();
    this._addPyramid();
    this._plants();
    this._add3Dart();
    this._towerOfPimps();
    chunk.finishGenerate();
  }

  /// Get the scaled 2D noise offset for the given chunk.
  double _noise(int x, int z, double scale) {
    final chunk = this._curChunk;
    if (chunk == null) return 0.0;
    return this._simplex.eval2D((x + chunk.x) * scale, (z + chunk.z) * scale) * 0.5 + 0.5;
  }

  /// Gets the height of the terrain from the prepared height cache.
  int _terrainHeight(int x, int z) =>
      this._tempCache[(x + Constants.borderSize) * Constants.paddedSize + (z + Constants.borderSize)];

  /// Prepares the temporary cached terrain height.
  void _prepareHeightCache() {
    int offset = 0;
    for (int x = Constants.paddedMin; x < Constants.paddedMax; x++) {
      for (int z = Constants.paddedMin; z < Constants.paddedMax; z++) {
        final double terrain = 0.6 * this._noise(x, z, 0.001) + 0.3 * this._noise(x, z, 0.01) + 0.1 * this._noise(x, z, 0.1);
        int maxy = (math.pow(terrain, 2.0) * Constants.chunkYSize).toInt();
        maxy = (maxy >= Constants.chunkYSize) ? Constants.chunkYSize - 1 : maxy;
        this._tempCache[offset] = maxy;
        offset++;
      }
    }
  }

  /// Clears the chunk of all block data.
  void _clearChunk() => this._curChunk?._data.fillRange(0, Constants.chunkDataLength, BlockType.Air);

  /// Applies the terrain (turf, dirt, and rock) to the current chunk.
  void _terrain() {
    for (int x = 0; x < Constants.chunkSideSize; x++) {
      for (int z = 0; z < Constants.chunkSideSize; z++) {
        this._terrainBlock(x, z);
      }
    }
  }

  /// Determines the terrain blocks for the column in the current chunk.
  void _terrainBlock(int x, int z) {
    final chunk = this._curChunk;
    if (chunk == null) return;
    final int maxy = this._terrainHeight(x, z);
    for (int y = 0; y <= maxy; y++) {
      int block = BlockType.Rock;
      if (maxy < Constants.waterDepth) {
        if (maxy - Constants.sandDepth <= y) {
          block = BlockType.Sand;
        }
      } else {
        if (maxy == y) {
          block = BlockType.Turf;
        } else if (maxy - Constants.dirtDepth <= y) {
          block = BlockType.Dirt;
        }
      }
      chunk.setBlock(x, y, z, block);
    }
  }

  /// Applies the water for the given chunk.
  void _applyWater() {
    for (int x = 0; x < Constants.chunkSideSize; x++) {
      for (int z = 0; z < Constants.chunkSideSize; z++) {
        this._applyWaterBlock(x, z);
      }
    }
  }

  /// Determines the water blocks for a column.
  void _applyWaterBlock(int x, int z) {
    final chunk = this._curChunk;
    if (chunk == null) return;
    final int maxy = chunk.topHit(x, z, 0);
    if (maxy < Constants.waterDepth) {
      for (int y = Constants.waterDepth; y > maxy; y--) {
        chunk.setBlock(x, y, z, BlockType.Water);
      }
    }
  }

  /// Determines the water blocks and adds surrounding sand blocks.
  void _applySand() {
    for (int x = -1; x <= Constants.chunkSideSize; x++) {
      for (int z = -1; z <= Constants.chunkSideSize; z++) {
        this._applySandBlock(x, z);
      }
    }
  }

  /// Determines the water blocks and adds surrounding sand blocks.
  void _applySandBlock(int x, int z) {
    final chunk = this._curChunk;
    if (chunk == null) return;
    final int maxy = this._terrainHeight(x, z);
    if (maxy < Constants.waterDepth) {
      for (int y = Constants.maxEdgeSand; y > Constants.minEdgeSand; y--) {
        for (int dx = -1; dx <= 1; dx++) {
          for (int dz = -1; dz <= 1; dz++) {
            final int value = chunk.getBlock(x + dx, y, z + dz);
            if (value == BlockType.Turf || value == BlockType.DryLeaves) {
              chunk.setBlock(x + dx, y, z + dz, BlockType.Sand);
            }
          }
        }
      }
    }
  }

  /// Determines the trees for the given chunk.
  /// The leaves will hang over into neighbor chunks.
  void _trees() {
    for (int x = Constants.paddedMin; x < Constants.paddedMax; x++) {
      for (int z = Constants.paddedMin; z < Constants.paddedMax; z++) {
        if (this._noise(x, z, 1.5) < 0.1) this._addTree(x, z);
      }
    }
  }

  /// Adds a tree at the given [x] and [z] to this chunk.
  void _addTree(int x, int z) {
    final chunk = this._curChunk;
    if (chunk == null) return;
    // Don't place a tree too close to the pyramid
    if ((x + chunk.x >= -Constants.pyramidSize) &&
        (x + chunk.x < Constants.pyramidSize) &&
        (z + chunk.z >= -Constants.pyramidSize) &&
        (z + chunk.z < Constants.pyramidSize)) return;
    final int maxy = this._terrainHeight(x, z);
    if (maxy < Constants.treeMin) return;
    for (int y = 1; y < Constants.treeHeight; y++) {
      chunk.setBlock(x, maxy + y, z, BlockType.TrunkUD);
    }
    _addTreeBase(x, z);
    _addTreeLeaves(x, maxy + Constants.treeHeight, z);
  }

  /// Adds the base of a tree to the given [x] and [z] to this chunk.
  void _addTreeBase(int x, int z) {
    final chunk = this._curChunk;
    if (chunk == null) return;
    for (int px = -Constants.deadLeavesRadius; px <= Constants.deadLeavesRadius; px++) {
      for (int pz = -Constants.deadLeavesRadius; pz <= Constants.deadLeavesRadius; pz++) {
        if ((px * px + pz * pz) <= Constants.deadLeavesRadius2) {
          for (int y = Constants.chunkYSize - 1; y >= 0; y--) {
            if (chunk.getBlock(x + px, y, z + pz) == BlockType.Turf) {
              chunk.setBlock(x + px, y, z + pz, BlockType.DryLeaves);
              break;
            }
          }
        }
      }
    }
  }

  /// Adds the leaves of a tree to the given [x] and [z] to this chunk.
  void _addTreeLeaves(int x, int y, int z) {
    final chunk = this._curChunk;
    if (chunk == null) return;
    for (int px = -Constants.leavesRadius; px <= Constants.leavesRadius; px++) {
      for (int py = -Constants.leavesRadius; py <= Constants.leavesRadius; py++) {
        for (int pz = -Constants.leavesRadius; pz <= Constants.leavesRadius; pz++) {
          if ((px * px + py * py + pz * pz) <= Constants.leavesRadius2) {
            if (chunk.getBlock(x + px, y + py, z + pz) == BlockType.Air) {
              chunk.setBlock(x + px, y + py, z + pz, BlockType.Leaves);
            }
          }
        }
      }
    }
  }

  /// Adds plants to the given chunk.
  void _plants() {
    for (int x = 0; x < Constants.chunkSideSize; x++) {
      for (int z = 0; z < Constants.chunkSideSize; z++) {
        if (this._noise(x, z, 12.5) < 0.1) {
          this._addPlant(x, z, BlockType.RedFlower);
        } else if (this._noise(x + 400, z, 12.5) < 0.1) {
          this._addPlant(x, z, BlockType.BlueFlower);
        } else if (this._noise(x, z + 400, 12.5) < 0.1) {
          this._addPlant(x, z, BlockType.WhiteFlower);
        } else if (this._noise(x + 400, z + 400, 12.5) < 0.15) {
          this._addPlant(x, z, BlockType.Grass);
        } else if (this._noise(x - 400, z, 12.5) < 0.1) {
          this._addPlant(x, z, BlockType.Fern);
        } else if (this._noise(x, z - 400, 12.5) < 0.08) this._addPlant(x, z, BlockType.Mushroom);
      }
    }
  }

  /// Adds a plant to the given chain.
  void _addPlant(int x, int z, int value) {
    final chunk = this._curChunk;
    if (chunk == null) return;
    final int maxy = chunk.topHit(x, z, 0);
    final int oldValue = chunk.getBlock(x, maxy, z);
    if (oldValue != BlockType.Turf && oldValue != BlockType.DryLeaves) return;
    chunk.setBlock(x, maxy + 1, z, value);
  }

  /// Adds the pyramid to the center of the world.
  void _addPyramid() {
    final chunk = this._curChunk;
    if (chunk == null) return;
    if ((chunk.x + Constants.chunkSideSize < -Constants.pyramidSize) ||
        (chunk.x > Constants.pyramidSize) ||
        (chunk.z + Constants.chunkSideSize < -Constants.pyramidSize) ||
        (chunk.z > Constants.pyramidSize)) return;
    final put = (int dx, int dy, int dz, int value) => chunk.setBlock(dx - chunk.x, dy, dz - chunk.z, value);
    for (int py = Constants.pyramidSize; py >= 0; py -= 2) {
      final int width = (Constants.pyramidSize - py) + 3;
      for (int px = -width; px <= width; px++) {
        for (int pz = -width; pz <= width; pz++) {
          put(px, py, pz, BlockType.WhiteShine);
          put(px, py - 1, pz, BlockType.WhiteShine);
        }
      }
      for (int pw = -2; pw <= 2; pw++) {
        put(-width - 1, py, pw, BlockType.Brick);
        put(-width - 1, py - 1, pw, BlockType.Brick);
        put(-width - 2, py - 1, pw, BlockType.Brick);
        put(width + 1, py, pw, BlockType.Brick);
        put(width + 1, py - 1, pw, BlockType.Brick);
        put(width + 2, py - 1, pw, BlockType.Brick);
        put(pw, py, -width - 1, BlockType.Brick);
        put(pw, py - 1, -width - 1, BlockType.Brick);
        put(pw, py - 1, -width - 2, BlockType.Brick);
        put(pw, py, width + 1, BlockType.Brick);
        put(pw, py - 1, width + 1, BlockType.Brick);
        put(pw, py - 1, width + 2, BlockType.Brick);
      }
      put(-width - 1, py + 1, 2, BlockType.Brick);
      put(-width - 2, py, 2, BlockType.Brick);
      put(-width - 1, py + 1, -2, BlockType.Brick);
      put(-width - 2, py, -2, BlockType.Brick);
      put(width + 1, py + 1, 2, BlockType.Brick);
      put(width + 2, py, 2, BlockType.Brick);
      put(width + 1, py + 1, -2, BlockType.Brick);
      put(width + 2, py, -2, BlockType.Brick);
      put(2, py + 1, -width - 1, BlockType.Brick);
      put(2, py, -width - 2, BlockType.Brick);
      put(-2, py + 1, -width - 1, BlockType.Brick);
      put(-2, py, -width - 2, BlockType.Brick);
      put(2, py + 1, width + 1, BlockType.Brick);
      put(2, py, width + 2, BlockType.Brick);
      put(-2, py + 1, width + 1, BlockType.Brick);
      put(-2, py, width + 2, BlockType.Brick);
    }
  }

  /// Adds the 3Dart text to the world.
  void _add3Dart() {
    final chunk = this._curChunk;
    if (chunk == null) return;
    const int x = -12, y = 40, z = -25;
    const int xWidth = 24, zWidth = 3;
    if ((chunk.x + Constants.chunkSideSize < x - xWidth) ||
        (chunk.x > x + xWidth) ||
        (chunk.z + Constants.chunkSideSize < z - zWidth) ||
        (chunk.z > z + zWidth)) return;
    final put = (int value, int dx, int dy, List<int> px, List<int> py) {
      for (int i = px.length - 1; i >= 0; i--) {
        chunk.setBlock(x + dx + px[i] - chunk.x, y + dy - py[i], z - chunk.z, value);
      }
    };
    put(BlockType.RedShine, 0, 0, // 3
        [0, 1, 2, 3, 4, 4, 3, 2, 4, 4, 3, 2, 1, 0], [1, 0, 0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 6, 5]);
    put(BlockType.RedShine, 6, 0, // D
        [0, 1, 2, 3, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 2, 3, 4, 5, 6, 6, 6, 5, 4, 3, 2, 1]);
    put(BlockType.BlackShine, 12, 0, // A
        [0, 0, 0, 0, 0, 1, 2, 1, 2, 3, 3, 3, 3, 3], [2, 3, 4, 5, 6, 1, 1, 4, 4, 2, 3, 4, 5, 6]);
    put(BlockType.BlackShine, 17, 0, // R
        [0, 0, 0, 0, 0, 0, 1, 2, 1, 2, 3, 3, 3, 3], [1, 2, 3, 4, 5, 6, 1, 1, 4, 4, 2, 3, 5, 6]);
    put(BlockType.BlackShine, 22, 0, // T
        [0, 2, 1, 1, 1, 1, 1, 1], [1, 1, 1, 2, 3, 4, 5, 6]);
  }

  /// Adds the RT tribute, "the tower of pimps", to the world.
  void _towerOfPimps() {
    final chunk = this._curChunk;
    if (chunk == null) return;
    const int x = 0, y = 2, z = 0;
    const int xWidth = 3, zWidth = 3, height = 7;
    if ((chunk.x + Constants.chunkSideSize < x - xWidth) ||
        (chunk.x > x + xWidth) ||
        (chunk.z + Constants.chunkSideSize < z - zWidth) ||
        (chunk.z > z + zWidth)) return;
    final put = (int dx, int dy, int dz, int value) => chunk.setBlock(dx - chunk.x, dy, dz - chunk.z, value);
    for (int px = -xWidth; px <= xWidth; px++) {
      for (int py = 0; py <= height; py++) {
        for (int pz = -zWidth; pz <= zWidth; pz++) {
          put(x + px, y + py, z + pz, BlockType.Air);
        }
      }
    }
    put(x, y, z, BlockType.BlackShine);
    put(x, y + 1, z, BlockType.YellowShine);
    put(x, y + 2, z, BlockType.YellowShine);
    put(x, y + 3, z, BlockType.YellowShine);
    put(x, y + 4, z, BlockType.YellowShine);
  }
}

/// The object defining the player and view of the game.
class Player {
  UserTranslator _trans;
  UserRotator _rot;
  World _world;
  Sounds _sounds;
  bool _touchingGround;
  int _selectedBlockIndex;
  NeighborBlockInfo? _highlight;
  Collider _collider;

  Group _camera;
  Group _playerLoc;
  Group _handLoc; // ignore: unused_field
  Group _crossHairLoc; // ignore: unused_field

  three_dart.Entity _crossHairs; // ignore: unused_field
  three_dart.Entity _blockHand; // ignore: unused_field
  three_dart.Entity _blockHighlight;
  three_dart.Entity _entity;
  List<three_dart.Entity> _blockHandEntities;

  /// Creates a new player for the world.
  factory Player(UserInput userInput, World world, Sounds sounds) {
    // Sets up how the player will move around.
    final trans = UserTranslator(input: userInput)
      ..offsetX.maximumVelocity = Constants.walkSpeed
      ..offsetY.maximumVelocity = Constants.maxFallSpeed
      ..offsetY.acceleration = Constants.gravity
      ..offsetZ.maximumVelocity = Constants.walkSpeed;
    // Sets up how the player will look around.
    final rot = UserRotator.flat(input: userInput);
    rot.changed.add((EventArgs args) {
      trans.velocityRotation = Matrix3.rotateY(-rot.yaw.location);
    });
    // Sets up the camera and player locations.
    final camera = Group([trans, rot]);
    final playerLoc = Group([Invert(rot), trans, Constant.scale(1.0, -1.0, 1.0)]);
    // Sets up the location for the player's hand to show the selected block value to place.
    final handLoc = Group([
      Constant.translate(-0.5, -0.5, -0.5),
      Rotator(yaw: -0.1, deltaYaw: 0.0, deltaPitch: 0.1, deltaRoll: 0.0),
      Constant.translate(0.5, 0.5, 0.5),
      Constant.scale(0.04, -0.04, 0.04),
      Constant.translate(-0.15, 0.06, -0.2),
      playerLoc
    ]);
    // Sets up the location for the player's cross hairs.
    final crossHairLoc = Group(
        [Constant.scale(0.005, -0.005, 0.005), Constant.translate(0.0, 0.0, -0.2), playerLoc]);
    // Creates the cross hair entity for drawing the cross hairs.
    final crossHairs = three_dart.Entity(
        mover: crossHairLoc,
        shape: square(type: VertexType.Pos | VertexType.Txt2D),
        tech: world.materials?.crosshair);
    // Creates the hand entity for showing the selected block type that will be added.
    final blockHand = three_dart.Entity(mover: handLoc);
    final List<three_dart.Entity> blockHandEntities = [];
    for (final MaterialLight mat in world.materials?.materials ?? []) {
      final three_dart.Entity entity = three_dart.Entity(tech: mat);
      blockHand.children.add(entity);
      blockHandEntities.add(entity);
    }
    // Setup collider for handling collision detection for player.
    final collider = Collider(world);
    // Creates the selection highlight to show which
    final blockHighlight = three_dart.Entity(tech: world.materials?.selection);
    // Puts all the entities under one for the whole player.
    final entity = three_dart.Entity(children: [crossHairs, blockHand, blockHighlight]);
    return Player._(userInput, trans, rot, world, sounds, collider, camera, playerLoc, handLoc, crossHairLoc,
        crossHairs, blockHand, blockHighlight, entity, blockHandEntities);
  }

  /// Creates a new player for the world.
  Player._(
      UserInput userInput,
      this._trans,
      this._rot,
      this._world,
      this._sounds,
      this._collider,
      this._camera,
      this._playerLoc,
      this._handLoc,
      this._crossHairLoc,
      this._crossHairs,
      this._blockHand,
      this._blockHighlight,
      this._entity,
      this._blockHandEntities)
      : _touchingGround = true,
        _selectedBlockIndex = 0,
        _highlight = null {
    this._trans
      ..collisionHandle = this._handleCollide
      ..changed.add(this._onPlayerMove);
    this._camera.changed.add(this._updateHighlight);
    this._initUserInput(userInput);
    this._updateHand();
  }

  void _initUserInput(UserInput userInput) {
    userInput.lockOnClick = true;
    userInput.locked
      ..horizontalSensitivity = Constants.mouseSensitivity
      ..verticalSensitivity = Constants.mouseSensitivity;
    // Sets up the key watcher for jumping.
    KeyGroup()
      ..addKey(Key.spacebar)
      ..attach(userInput)
      ..keyDown.add(this._onJump);
    // Sets up the key watcher for changing the selected block value.
    KeyGroup()
      ..addKey(Key.tab)
      ..addKey(Key.tab, shift: true)
      ..attach(userInput)
      ..keyDown.add(this._onBlockCycle);
    // Sets up the watchers for modifying the voxel data of a chunk.
    KeyGroup()
      ..addKey(Key.keyE)
      ..addKey(Key.keyQ)
      ..attach(userInput)
      ..keyDown.add(this._onBlockChange);
    userInput.locked.down.add(this._onClickBlockChange);
    // Sets up the watcher for returning to the origin.
    KeyGroup()
      ..addKey(Key.keyO)
      ..attach(userInput)
      ..keyDown.add(this._onReturnToOrigin);
    // Sets up how the player will move around.
    this._trans
      ..offsetX.maximumVelocity = Constants.walkSpeed
      ..offsetY.maximumVelocity = Constants.maxFallSpeed
      ..offsetY.acceleration = Constants.gravity
      ..offsetZ.maximumVelocity = Constants.walkSpeed
      ..collisionHandle = this._handleCollide
      ..changed.add(this._onPlayerMove)
      ..attach(userInput);
    // Sets up how the player will look around.
    this._rot
      ..attach(userInput)
      ..changed.add((EventArgs args) {
        this._trans.velocityRotation = Matrix3.rotateY(-this._rot.yaw.location);
      });
  }

  /// The camera mover used to position the view of the world.
  Group get camera => this._camera;

  /// The mover to the location of the player.
  Group get location => this._playerLoc;

  /// Gets the specific point location of the player in the world.
  Point3 get point => this._playerLoc.matrix.transPnt3(Point3.zero);

  /// The base entity for the player.
  three_dart.Entity get entity => this._entity;

  /// Sets the player's coordinates to the starting position at the top most location.
  void goHome() {
    final Chunk? chunk = this._world.findChunk(Constants.playerStartX.toInt(), Constants.playerStartZ.toInt());
    final int y = chunk?.topHit(Constants.playerStartX.toInt(), Constants.playerStartZ.toInt()) ?? 0;
    this._trans.location =
        Point3(Constants.playerStartX, y.toDouble() + Constants.playerStartYOffset, Constants.playerStartZ);
    this._trans.velocity = Vector3.zero;
  }

  /// Handles then the player presses the return to origin button.
  void _onReturnToOrigin(EventArgs args) {
    this.goHome();
  }

  /// Handles when the player presses the jump key.
  void _onJump(EventArgs args) {
    if (this._touchingGround) this._trans.offsetY.velocity = Constants.jumpSpeed;
  }

  /// Handles when the player presses the button(s) to cycle the selected block value in the hand.
  void _onBlockCycle(EventArgs args) {
    final KeyEventArgs keyArgs = args as KeyEventArgs;
    final int length = BlockType.PlaceableBlocks.length;
    if (keyArgs.key.shift) {
      this._selectedBlockIndex--;
      if (this._selectedBlockIndex < 0) this._selectedBlockIndex = length - 1;
    } else {
      this._selectedBlockIndex++;
      if (this._selectedBlockIndex >= length) this._selectedBlockIndex = 0;
    }
    this._updateHand();
  }

  /// Handles when the player presses the button(s) to modify the voxel values of a chunk.
  void _onBlockChange(EventArgs args) {
    final Key key = (args as KeyEventArgs).key;
    this._changeBlock(key.code == Key.keyE);
  }

  /// Handles when the player clicks a mouse button to modify the voxel values of a chunk.
  void _onClickBlockChange(EventArgs args) {
    final Button button = (args as MouseEventArgs).button;
    this._changeBlock(button.code == Button.right);
  }

  /// Modify the voxel values of a chunk.
  /// If [setBlock] is true then the current block in the hand is set on a neighboring side to the
  /// highlight, if false then the highlighted block is set to air.
  void _changeBlock(bool setBlock) {
    final highlight = this._highlight;
    if (highlight == null) return;
    BlockInfo? info = highlight.info;
    int blockType = BlockType.Air;
    if (setBlock) {
      blockType = BlockType.PlaceableBlocks[this._selectedBlockIndex];
      final int oldValue = info?.value ?? BlockType.Air;
      final HitRegion region = highlight.region;
      // Keep a block from being put on the top of a plant.
      if (region.overlaps(HitRegion.YPos)) {
        if (BlockType.plant(oldValue)) return;
      }
      // Keep a plant from being put on water or air.
      if (BlockType.plant(blockType)) {
        if (!BlockType.solid(info?.below?.value ?? BlockType.Air)) return;
      }
      // Change the block type based on the side the block is being added to.
      if (blockType == BlockType.TrunkUD) {
        if (region.overlaps(HitRegion.XPos | HitRegion.XNeg)) {
          blockType = BlockType.TrunkEW;
        } else if (region.overlaps(HitRegion.ZPos | HitRegion.ZNeg)) {
          blockType = BlockType.TrunkNS;
        }
      } else if (blockType == BlockType.WoodUD) {
        if (region.overlaps(HitRegion.XPos | HitRegion.XNeg)) {
          blockType = BlockType.WoodEW;
        } else if (region.overlaps(HitRegion.ZPos | HitRegion.ZNeg)) {
          blockType = BlockType.WoodNS;
        }
      }
      // Move to the neighbor location.
      info = info?.neighbor(region.inverse());
      // Check the block won't be in the player's region.
      final Vector3 playerLoc = Vector3.fromPoint3(this._trans.location);
      final Region3 playerRect = Constants.playerRegion.translate(playerLoc);
      if (info?.blockRegion.overlaps(playerRect) ?? true) return;
    }
    if (info != null) {
      final Chunk? chunk = info.chunk;
      if (chunk != null) {
        // Play noise for block change.
        if (setBlock) {
          this._sounds.playBlockSound(blockType);
        } else {
          this._sounds.playBlockSound(info.value);
        }
        // Apply the new block type.
        info.value = blockType;
        // Remove plant if a plant was above a removed block.
        if (blockType == BlockType.Air) {
          final BlockInfo? aboveInfo = info.above;
          if (aboveInfo != null && BlockType.plant(aboveInfo.value)) aboveInfo.value = BlockType.Air;
        }
        // Indicate which chunks need to be updated.
        chunk.needUpdate = true;
        if (info.x <= 0) chunk.left?.needUpdate = true;
        if (info.z <= 0) chunk.back?.needUpdate = true;
        if (info.x >= Constants.chunkSideSize - 1) chunk.right?.needUpdate = true;
        if (info.z >= Constants.chunkSideSize - 1) chunk.front?.needUpdate = true;
      }
    }
  }

  /// Handles a player moving around in the world.
  void _onPlayerMove(EventArgs args) {
    if (this._touchingGround) {
      // TODO [Issues #127]: Implement walking sounds
    }
  }

  /// Handles checking for collision while the player is moving, falling, or jumping.
  Point3 _handleCollide(Point3 prev, Point3 loc) {
    // Traverse the neighboring blocks using player's movement to find first
    // hard block checking both head and foot.
    final Vector3 vector = prev.vectorTo(loc);
    if (vector.length2() < Constants.maxCollisionSpeedSquared) {
      this._collider.collide(Constants.playerRegion, prev, vector);
      this._touchingGround = this._collider.touching.has(HitRegion.YPos);
      if (this._touchingGround) this._trans.offsetY.velocity = 0.0;
    }
    return this._collider.location ?? loc;
  }

  /// The handler used in update highlight for traversing neighboring blocks.
  bool _updateHighlightHandler(NeighborBlockInfo? neighbor) {
    // Check if the neighbor is not air or is null.
    if (neighbor != null && neighbor.info?.value == BlockType.Air) return false;
    // Check if found block is valid and selectable, if not set to null.
    final BlockInfo? info = neighbor?.info;
    if ((info != null) &&
        (((neighbor?.depth ?? 0) < 0) || (info.value == BlockType.Air) || (info.value == BlockType.Boundary))) {
      // ignore: parameter_assignments
      neighbor = null;
    }
    this._highlight = neighbor;
    // Either remove or create highlight for the new selection.
    if (this._highlight == null) {
      this._blockHighlight.enabled = false;
    } else if (info != null) {
      final Shaper shaper = Shaper(null, VertexType.Pos | VertexType.Txt2D);
      shaper.addCubeToOneShape(info.chunkX + info.x, info.y, info.chunkZ + info.z, true, 1.1);
      shaper.finish([this._blockHighlight]);
      this._blockHighlight.enabled = true;
    }
    return true;
  }

  /// Updates the selection for the highlighted block that can be modified.
  void _updateHighlight(EventArgs _) {
    // Calculates the view vector down the center of the screen out away from the player.
    // The ray is scaled to have the maximum highlight length.
    final Matrix4 mat = this._playerLoc.matrix;
    final Ray3 playerViewTarget = Ray3.fromVector(
        mat.transPnt3(Point3.zero), mat.transVec3(Vector3(0.0, 0.0, -Constants.highlightDistance)));
    final Ray3 back = playerViewTarget.reverse;
    final BlockInfo? info = this._world.getBlock(playerViewTarget.x, playerViewTarget.y, playerViewTarget.z);
    NeighborBlockInfo? neighbor = NeighborBlockInfo(info, HitRegion.Inside, playerViewTarget, 0);
    // Traverse the neighboring blocks using player's view to find first non-air block.
    int depth = 0;
    while (!this._updateHighlightHandler(neighbor)) {
      neighbor = this._world.getNeighborBlock(neighbor?.info, playerViewTarget, back, depth);
      depth++;
    }
  }

  /// Updates the block rendered into the hand.
  void _updateHand() {
    final Shaper shaper = Shaper(this._world.materials);
    shaper.buildSingleBlock(BlockType.PlaceableBlocks[this._selectedBlockIndex]);
    shaper.finish(this._blockHandEntities);
  }
}

// This shows a pseudo wireframe instead of filled shapes.
// Anything with special shape logic, like mushrooms, might not become wireframe.
// This is useful to check that only the visible sides of the vocals are being drawn.
const bool _showWireFrame = false;

/// The shaper creates the shapes for all the items in the world.
class Shaper {
  final Materials? _mats;
  final VertexType _vertexType;
  List<ReducedShape?> _shapes;

  /// Create a new shaper for building shapes for this world.
  /// This will create a temporary place holder for one shape per material in the materials list.
  /// Pass in a null material to produce only one placeholder to be used with [addCubeToOneShape].
  /// Optionally pass in a vertex type, otherwise it is Pos|Txt2D|Norm.
  Shaper(this._mats, [VertexType? vertexType])
      : this._vertexType = vertexType ?? VertexType.Pos | VertexType.Txt2D | VertexType.Norm,
        this._shapes = List<ReducedShape?>.filled(_mats?.materials.length ?? 1, null);

  /// Builds all the shames for a whole given [chunk].
  /// Use [finish] to apply the shapes to the chunks entities.
  void buildChunkShapes(Chunk chunk) {
    for (int x = Constants.chunkSideSize - 1; x >= 0; x--) {
      for (int y = Constants.chunkYSize - 1; y >= -1; y--) {
        for (int z = Constants.chunkSideSize - 1; z >= 0; z--) {
          final int value = chunk.getWorldBlock(x, y, z);
          this._addBlockToShapes(chunk, x, y, z, value, false, 1.0);
        }
      }
    }
  }

  /// Builds a single block with the given value.
  /// This is used for building what is in the hand.
  /// Use [finish] to apply the shapes to the player's entities.
  void buildSingleBlock(int value) => this._addBlockToShapes(null, 0, 0, 0, value, false, 1.0);

  /// Builds a single block to the first shape storage.
  /// This is used for building the selection highlight.
  /// This should be used when the a null materials was used when creating the [Shaper].
  void addCubeToOneShape(int x, int y, int z, bool twoSided, double scalar) {
    final Point3 loc = Point3(x.toDouble() + 0.5, y.toDouble() + 0.5, z.toDouble() + 0.5);
    final ReducedShape shape = this._getShape(0);
    this._addTopToShape(shape, loc, twoSided, scalar);
    this._addBottomToShape(shape, loc, twoSided, scalar);
    this._addLeftToShape(shape, loc, twoSided, scalar);
    this._addRightToShape(shape, loc, twoSided, scalar);
    this._addFrontToShape(shape, loc, twoSided, scalar);
    this._addBackToShape(shape, loc, twoSided, scalar);
  }

  /// This applies the shapes to the given entities.
  /// The entities given should match up to the materials in the material list used when creating the [Shaper].
  /// If a null materials was used when creating the [Shaper] then only one entity should be passed in.
  void finish(List<three_dart.Entity> entities) {
    for (int i = entities.length - 1; i >= 0; i--) {
      final three_dart.Entity entity = entities[i];
      final ReducedShape? shape = this._shapes[i];
      if (shape != null) {
        entity.shapeBuilder = shape;
        entity.enabled = shape.vertices.isNotEmpty;
      } else {
        entity.shapeBuilder = null;
        entity.enabled = false;
      }
    }
    this._shapes = [];
  }

  /// Gets the shape with the given [index] from the set, if no shape is created
  /// for that index yet a new shape will be created and set to that index.
  ReducedShape _getShape(int index) {
    ReducedShape? shape = this._shapes[index];
    if (shape == null) {
      shape = ReducedShape(this._vertexType);
      this._shapes[index] = shape;
    }
    return shape;
  }

  /// Adds a block from the given chunk to the correct shapes based on the materials' cube indices.
  void _addBlockToShapes(Chunk? chunk, int x, int y, int z, int value, bool twoSided, double scalar) {
    final Point3 chunkLoc = Point3(x.toDouble(), y.toDouble(), z.toDouble());
    if (chunk != null) {
      // ignore: parameter_assignments
      x += chunk.x;
      // ignore: parameter_assignments
      z += chunk.z;
    }
    final Point3 loc = Point3(x.toDouble() + 0.5, y.toDouble() + 0.5, z.toDouble() + 0.5);
    if (value == BlockType.Air) {
      return;
    } else if (value == BlockType.Water) {
      this._addCubeToShapes(chunk, loc, chunkLoc, value, twoSided, scalar);
    } else if (BlockType.open(value)) {
      if (value == BlockType.Fern) {
        this._addFernToShapes(loc);
      } else if (value == BlockType.Mushroom) {
        this._addMushroomToShapes(loc);
      } else {
        this._addPlantToShapes(loc, value);
      }
    } else if (BlockType.solid(value)) this._addCubeToShapes(chunk, loc, chunkLoc, value, twoSided, scalar);
  }

  /// Creates a new vertex object with the given position, normal vector, and texture coordinates.
  Vertex _getVertex(Point3 loc, Vector3? norm, double tu, double tv) {
    return Vertex(
        type: VertexType.Pos | VertexType.Txt2D | VertexType.Norm,
        loc: loc,
        norm: norm,
        txt2D: Point2(tu, tv));
  }

  /// Adds a quad to the given [shape]. The given [loc] is the center point of a block
  /// and the offset to the corners of the quad.
  void _addQuad(ReducedShape shape, Point3 loc, Point3 off1, Point3 off2, Point3 off3,
      Point3 off4, Vector3 norm, bool twoSided, double scalar) {
    final Vertex ver1 = this._getVertex(loc + off1 * scalar, norm, 0.0, 0.0);
    final Vertex ver2 = this._getVertex(loc + off2 * scalar, norm, 0.0, 1.0);
    final Vertex ver3 = this._getVertex(loc + off3 * scalar, norm, 1.0, 1.0);
    final Vertex ver4 = this._getVertex(loc + off4 * scalar, norm, 1.0, 0.0);
    final int i = shape.addVertices([ver1, ver2, ver3, ver4]);
    if (_showWireFrame) {
      shape.addLines([i, i + 1, i + 1, i + 2, i + 2, i + 3, i + 3, i, i, i + 2]);
    } else {
      shape.addTriangleFan([i, i + 1, i + 2, i + 3]);
      if (twoSided) shape.addTriangleFan([i + 2, i + 1, i, i + 3]);
    }
  }

  /// Adds the top square of a block to the given [shape].
  void _addTopToShape(ReducedShape shape, Point3 loc, bool twoSided, double scalar) => _addQuad(
      shape,
      loc,
      Constants.backTopLeft,
      Constants.frontTopLeft,
      Constants.frontTopRight,
      Constants.backTopRight,
      Constants.topNorm,
      twoSided,
      scalar);

  /// Adds the bottom square of a block to the given [shape].
  void _addBottomToShape(ReducedShape shape, Point3 loc, bool twoSided, double scalar) => _addQuad(
      shape,
      loc,
      Constants.frontBottomLeft,
      Constants.backBottomLeft,
      Constants.backBottomRight,
      Constants.frontBottomRight,
      Constants.bottomNorm,
      twoSided,
      scalar);

  /// Adds the left square of a block to the given [shape].
  void _addLeftToShape(ReducedShape shape, Point3 loc, bool twoSided, double scalar) => _addQuad(
      shape,
      loc,
      Constants.backTopLeft,
      Constants.backBottomLeft,
      Constants.frontBottomLeft,
      Constants.frontTopLeft,
      Constants.leftNorm,
      twoSided,
      scalar);

  /// Adds the right square of a block to the given [shape].
  void _addRightToShape(ReducedShape shape, Point3 loc, bool twoSided, double scalar) => _addQuad(
      shape,
      loc,
      Constants.frontTopRight,
      Constants.frontBottomRight,
      Constants.backBottomRight,
      Constants.backTopRight,
      Constants.rightNorm,
      twoSided,
      scalar);

  /// Adds the front square of a block to the given [shape].
  void _addFrontToShape(ReducedShape shape, Point3 loc, bool twoSided, double scalar) => _addQuad(
      shape,
      loc,
      Constants.frontTopLeft,
      Constants.frontBottomLeft,
      Constants.frontBottomRight,
      Constants.frontTopRight,
      Constants.frontNorm,
      twoSided,
      scalar);

  /// Adds the back square of a block to the given [shape].
  void _addBackToShape(ReducedShape shape, Point3 loc, bool twoSided, double scalar) => _addQuad(
      shape,
      loc,
      Constants.backTopRight,
      Constants.backBottomRight,
      Constants.backBottomLeft,
      Constants.backTopLeft,
      Constants.backNorm,
      twoSided,
      scalar);

  /// Adds a cube to the shapes defined by the materials cube data for the given block [value].
  /// Only the sides of the cube which are visible are added, the rest are skipped.
  void _addCubeToShapes(Chunk? chunk, Point3 loc, Point3 chunkLoc, int value, bool twoSided, double scalar) {
    final CubeData? data = this._mats?.cubeData(value);
    if (data == null) return;
    if (this._addFace(chunk, value, chunkLoc, 0, 1, 0)) {
      this._addTopToShape(this._getShape(data.topIndex), loc, twoSided, scalar);
    }
    if (this._addFace(chunk, value, chunkLoc, 0, -1, 0)) {
      this._addBottomToShape(this._getShape(data.bottomIndex), loc, twoSided, scalar);
    }
    if (this._addFace(chunk, value, chunkLoc, -1, 0, 0)) {
      this._addLeftToShape(this._getShape(data.leftIndex), loc, twoSided, scalar);
    }
    if (this._addFace(chunk, value, chunkLoc, 1, 0, 0)) {
      this._addRightToShape(this._getShape(data.rightIndex), loc, twoSided, scalar);
    }
    if (this._addFace(chunk, value, chunkLoc, 0, 0, 1)) {
      this._addFrontToShape(this._getShape(data.frontIndex), loc, twoSided, scalar);
    }
    if (this._addFace(chunk, value, chunkLoc, 0, 0, -1)) {
      this._addBackToShape(this._getShape(data.backIndex), loc, twoSided, scalar);
    }
  }

  /// Determines if a face should be added to because it is visible in the world.
  bool _addFace(Chunk? chunk, int value, Point3 chunkLoc, int x, int y, int z) {
    if (chunk == null) return true;
    // ignore: parameter_assignments
    y += chunkLoc.y.toInt();
    if (y < 0) return false;
    if (y >= Constants.chunkYSize) return true;
    // ignore: parameter_assignments
    x += chunkLoc.x.toInt();
    // ignore: parameter_assignments
    z += chunkLoc.z.toInt();
    final int neighbor = chunk.getWorldBlock(x, y, z);
    return BlockType.drawSide(value, neighbor);
  }

  /// Adds a rotated quad to the shape. This is for adding flowers and grass.
  /// The given [angle] is in radians.
  void _addQuadRotToShape(ReducedShape shape, Point3 loc, double angle, [bool twoSided = false]) {
    final c = math.cos(angle) * 0.5, s = math.sin(angle) * 0.5;
    _addQuad(shape, loc, Point3(c, 0.0, -s), Point3(c, -0.5, -s), Point3(-c, -0.5, s),
        Point3(-c, 0.0, s), Vector3(s, 0.0, c), twoSided, 1.0);
  }

  /// Adds a plant to the shapes.
  /// It selects the correct shape to add to from the materials and given block [value].
  void _addPlantToShapes(Point3 loc, int value) {
    final List<int>? offset = this._mats?.matData(value);
    if (offset == null) return;
    this._addQuadRotToShape(this._getShape(offset[0]), loc, PI * 0.5 / 4.0, true);
    this._addQuadRotToShape(this._getShape(offset[0]), loc, PI * 2.5 / 4.0, true);
  }

  /// Adds a single fern leaf to the given [shape] at the given [angle] in radians.
  void _addFernLeaf(ReducedShape shape, Point3 loc, double angle) {
    final Matrix3 mat = Matrix3.rotateY(angle);
    _addQuad(
        shape,
        loc,
        mat.transPnt3(Point3(0.4, -0.1, -0.4)),
        mat.transPnt3(Point3(0.0, -0.5, 0.0)),
        mat.transPnt3(Point3(0.4, -0.1, 0.4)),
        mat.transPnt3(Point3(0.8, 0.0, 0.0)),
        Constants.topNorm,
        true,
        1.0);
  }

  /// Adds a fern to the shapes at the given [loc].
  void _addFernToShapes(Point3 loc) {
    final List<int>? offset = this._mats?.matData(BlockType.Fern);
    if (offset == null) return;
    _addFernLeaf(this._getShape(offset[0]), loc, PI * 0.2 / 2.0);
    _addFernLeaf(this._getShape(offset[0]), loc, PI * 1.1 / 2.0);
    _addFernLeaf(this._getShape(offset[0]), loc, PI * 2.3 / 2.0);
    _addFernLeaf(this._getShape(offset[0]), loc, PI * 3.2 / 2.0);
  }

  /// Adds a mushroom to the shapes at the given [loc].
  void _addMushroomToShapes(Point3 loc) {
    final List<int>? offset = this._mats?.matData(BlockType.Mushroom);
    if (offset == null) return;
    final ReducedShape topShape = this._getShape(offset[0]);
    final ReducedShape bottomShape = this._getShape(offset[1]);
    final ReducedShape sideShape = this._getShape(offset[2]);
    final List<Vertex> side = [];
    final List<Vertex> botcap = [];
    for (double d = 0.0; d <= 2.0; d += 0.25) {
      final Matrix3 mat = Matrix3.rotateY(PI * d);
      side.add(this._getVertex(loc + mat.transPnt3(Point3(0.07, -0.1, 0.0)),
          mat.transVec3(Constants.frontNorm), (d - 1.0).abs(), 0.0));
      side.add(this._getVertex(loc + mat.transPnt3(Point3(0.1, -0.5, 0.0)), mat.transVec3(Constants.frontNorm),
          (d - 1.0).abs(), 1.0));
      final Point3 topLoc = mat.transPnt3(Point3(0.1, -0.5, 0.0));
      final Point3 topTxt = mat.transPnt3(Point3(0.1, 0.0, 0.0));
      botcap.add(this._getVertex(loc + topLoc, Constants.bottomNorm, topTxt.x + 0.5, topTxt.z + 0.5));
    }
    final int side1Index = sideShape.addVertices(side);
    final int botcapIndex = bottomShape.addVertices(botcap);
    sideShape.addTriangleStrip(List<int>.generate(side.length, (int i) => side1Index + i));
    bottomShape.addTriangleFan(List<int>.generate(botcap.length, (int i) => botcapIndex + i));
    final List<Vertex> top = [];
    final List<Vertex> bottom = [];
    top.add(this._getVertex(loc + Point3(0.0, 0.05, 0.0), Constants.topNorm, 0.5, 0.5));
    bottom.add(this._getVertex(loc + Point3(0.0, -0.1, 0.0), Constants.bottomNorm, 0.5, 0.5));
    for (double d = 0.0; d <= 1.0; d += 0.1) {
      final Matrix3 topMat = Matrix3.rotateY(-PI * 2.0 * d);
      final Point3 topLoc = topMat.transPnt3(Point3(0.4, -0.15, 0.0));
      final Point3 topTxt = topMat.transPnt3(Point3(0.5, 0.0, 0.0));
      top.add(this._getVertex(loc + topLoc, null, topTxt.x + 0.5, topTxt.z + 0.5));
      final Matrix3 botMat = Matrix3.rotateY(PI * 2.0 * d);
      final Point3 botLoc = botMat.transPnt3(Point3(0.4, -0.15, 0.0));
      final Point3 botTxt = botMat.transPnt3(Point3(0.5, 0.0, 0.0));
      bottom.add(this._getVertex(loc + botLoc, null, botTxt.x + 0.5, botTxt.z + 0.5));
    }
    final int topIndex = topShape.addVertices(top);
    final int bottomIndex = bottomShape.addVertices(bottom);
    topShape.addTriangleFan(List<int>.generate(top.length, (int i) => topIndex + i));
    bottomShape.addTriangleFan(List<int>.generate(bottom.length, (int i) => bottomIndex + i));
  }
}

/// The sounds object helps make sounds easy to play.
class Sounds {
  final Map<int, MultiPlayer> _blockSound = {};

  /// Creates and starts loading the sounds for the game.
  Sounds(AudioLoader loader) {
    this._addBlockSound(loader, './sounds/sandHit.mp3', [BlockType.Sand]);
    this._addBlockSound(loader, './sounds/grassHit.mp3', [
      BlockType.Dirt,
      BlockType.Turf,
      BlockType.Grass,
      BlockType.Fern,
      BlockType.WhiteFlower,
      BlockType.BlueFlower,
      BlockType.RedFlower,
      BlockType.Mushroom
    ]);
    this._addBlockSound(loader, './sounds/woodHit.mp3', [
      BlockType.TrunkUD,
      BlockType.TrunkNS,
      BlockType.TrunkEW,
      BlockType.WoodUD,
      BlockType.WoodNS,
      BlockType.WoodEW
    ]);
    this._addBlockSound(loader, './sounds/stoneHit.mp3', [
      BlockType.Boundary,
      BlockType.Rock,
      BlockType.Brick,
      BlockType.RedShine,
      BlockType.WhiteShine,
      BlockType.YellowShine,
      BlockType.BlackShine
    ]);
    this._addBlockSound(loader, './sounds/waterHit.mp3', [BlockType.Water]);
    this._addBlockSound(loader, './sounds/leavesHit.mp3', [BlockType.DryLeaves, BlockType.Leaves]);
    // No sound: BlockType.Air
  }

  /// Adds a sounds and the set of blocks which would make that sound.
  void _addBlockSound(AudioLoader loader, String path, List<int> blocks) {
    final MultiPlayer player = MultiPlayer(loader.loadFromFile(path));
    for (final int block in blocks) {
      this._blockSound[block] = player;
    }
  }

  /// Plays a sounds based on one of the block types.
  void playBlockSound(int block, [double volume = 1.0]) {
    final MultiPlayer? player = this._blockSound[block];
    if (player != null) player.play(volume: volume);
  }
}

/// The generator will initialize chunks to create a world test world,
/// for checking collision detection, block selection and replacement, and more.
class TestGenerator implements Generator {
  /// The current chunk that is being worked on.
  Chunk? _curChunk;

  /// Creates a new generator for the given world.
  TestGenerator();

  /// Fills the given chunk with data.
  @override
  void fillChunk(Chunk? chunk) {
    if (chunk == null) return;
    this._curChunk = chunk;
    this._default();
    // +----+----+----+----+
    // |    |    |    |    |  1
    // +----+----+----+----+
    // |    |    |    |    |  0
    // +----+----o----+----+----
    // |    |    |    |    | -1
    // +----+----+----+----+
    // |    |    |    |    | -2
    // +----+----+----+----+
    //   -2   -1 |  0    1
    if (this._isChunk(-2, 1)) this._sphere();
    if (this._isChunk(-1, 1)) this._pool();
    if (this._isChunk(0, 1)) this._walls();
    if (this._isChunk(1, 1)) this._platforms();
    if (this._isChunk(1, 0)) this._posts();
    if (this._isChunk(1, -1)) this._pillars();
    if (this._isChunk(-2, 0)) this._tunnels();
    if (this._isChunk(-2, -1)) this._narrows();
    if (this._isChunk(-2, -2)) this._pyramid();
    chunk.finishGenerate();
  }

  void _default() {
    final chunk = this._curChunk;
    if (chunk == null) return;
    const int rockHeight = 8;
    const int dirtHeight = 9;
    const int turfY = 9;
    for (int x = 0; x < Constants.chunkSideSize; x++) {
      for (int z = 0; z < Constants.chunkSideSize; z++) {
        for (int y = 0; y < rockHeight; y++) {
          chunk.setBlock(x, y, z, BlockType.Rock);
        }
        for (int y = rockHeight; y < dirtHeight; y++) {
          chunk.setBlock(x, y, z, BlockType.Dirt);
        }
        if (x == 0 || z == 0) {
          chunk.setBlock(x, turfY, z, BlockType.BlackShine);
        } else if (x == 1 && z == 1) {
          chunk.setBlock(x, turfY, z, BlockType.RedShine);
        } else {
          chunk.setBlock(x, turfY, z, BlockType.Turf);
        }
      }
    }
  }

  void _sphere() {
    final chunk = this._curChunk;
    if (chunk == null) return;
    final center = 8, size = 6, height = 17, size2 = size * size + 1;
    for (int x = -size; x <= size; x++) {
      for (int y = -size; y <= size; y++) {
        for (int z = -size; z <= size; z++) {
          if ((x * x + y * y + z * z) <= size2) chunk.setBlock(center + x, height + y, center + z, BlockType.Sand);
        }
      }
    }
  }

  void _pool() {
    const int lowest = 9;
    this._block(5, lowest, 3, 7, 2, 11);
    this._block(6, lowest + 1, 4, 5, 1, 9, BlockType.Water);
  }

  void _walls() {
    const int offset = 2, length = 12, separation = 4, height = 10, lowest = 10;
    this._block(offset, lowest, offset + separation, length, height, 1);
    this._block(offset + separation, lowest, offset, 1, height, length);
    this._block(offset, lowest, offset + separation * 2, length, height, 1);
    this._block(offset + separation * 2, lowest, offset, 1, height, length);
  }

  void _platforms() {
    const int offset = 2, size = 4, lowest = 10;
    void platform(int xScale, int zScale, int height) =>
        this._block(offset + size * xScale, lowest + height, offset + size * zScale, size, 1, size);
    platform(0, 0, 0);
    platform(0, 1, 1);
    platform(0, 2, 2);
    platform(1, 2, 3);
    platform(1, 1, 4);
    platform(1, 0, 5);
    platform(2, 0, 0);
    platform(2, 0, 2);
    platform(2, 1, 1);
    platform(2, 1, 3);
    platform(2, 2, 2);
    platform(2, 2, 4);
  }

  void _posts() {
    const int offset = 2, size = 4, lowest = 10;
    void pillar(int xScale, int zScale, int height) =>
        this._block(offset + size * xScale, lowest, offset + size * zScale, 1, height, 1);
    pillar(0, 0, 1);
    pillar(0, 1, 2);
    pillar(0, 2, 3);
    pillar(0, 3, 4);
    pillar(1, 0, 2);
    pillar(1, 1, 3);
    pillar(1, 2, 4);
    pillar(1, 3, 5);
    pillar(2, 0, 5);
    pillar(2, 1, 4);
    pillar(2, 2, 3);
    pillar(2, 3, 2);
    pillar(3, 0, 4);
    pillar(3, 1, 3);
    pillar(3, 2, 2);
    pillar(3, 3, 1);
  }

  void _pillars() {
    const int offset = 2, lowest = 10, width = 20, height = 8;
    for (int i = 0; i < width; i += 2) {
      for (int j = 0; j < width; j += 2) {
        this._block(offset + i, lowest, offset + j, 1, height, 1);
      }
    }
  }

  void _pyramid() {
    const int offset = 2, lowest = 10, height = 6;
    for (int i = 0; i < height; i++) {
      final int size = Constants.chunkSideSize - (offset + i) * 2 + 1;
      this._block(offset + i, lowest + i, offset + i, size, 1, size);
    }
  }

  void _tunnels() {
    const int offset = 2, height = 10, length = 12;
    for (int i = 0; i < 4; i++) {
      this._block(offset + 1, height, offset + i * 3, length, i + 2, 1);
      this._block(offset + 1, height + i + 1, offset + i * 3 + 1, length, 1, 2);
      this._block(offset + 1, height, offset + i * 3 + 3, length, i + 2, 1);
    }
  }

  void _narrows() {
    const int offset = 2, height = 10, length = 12;
    for (int i = 0; i < 6; i++) {
      this._block(offset + 1, height, offset + i * 2, length, i + 2, 1);
      this._block(offset + 1, height + i + 1, offset + i * 2 + 1, length, 1, 1);
      this._block(offset + 1, height, offset + i * 2 + 2, length, i + 2, 1);
    }
  }

  /// Determines if this chunk is the specified chunk with x and z scalars.
  bool _isChunk(int x, int z) =>
      (this._curChunk?.x == x * Constants.chunkSideSize) && (this._curChunk?.z == z * Constants.chunkSideSize);

  /// Adds a platform to the current chunk in the current location.
  void _block(int offsetX, int offsetY, int offsetZ, int xSize, int ySize, int zSize, [int type = BlockType.Brick]) {
    final chunk = this._curChunk;
    if (chunk == null) return;
    for (int x = 0; x < xSize; x++) {
      for (int y = 0; y < ySize; y++) {
        for (int z = 0; z < zSize; z++) {
          chunk.setBlock(offsetX + x, offsetY + y, offsetZ + z, type);
        }
      }
    }
  }
}

/// Defines the world shown in 3Dart craft.
class World {
  final Materials? _mats;
  final Generator _gen;
  final List<Chunk> _graveyard;
  final List<Chunk> _chunks;
  final List<three_dart.Entity> _entities;
  Player? _player;
  Chunk? _lastChunk;

  /// Creates a new world with the given materials.
  World(this._mats, this._gen)
      : this._graveyard = [],
        this._chunks = [],
        this._entities = [],
        this._lastChunk = null {
    for (final MaterialLight tech in this._mats?.materials ?? []) {
      this.entities.add(three_dart.Entity(tech: tech));
    }
    // Pre-allocate several chunks into the graveyard.
    for (int i = 0; i < Constants.initialGraveyardSize; i++) {
      this._graveyard.add(Chunk(this));
    }
    // Preinitialize the starting part of the world.
    for (int x = -Constants.initChunkDist; x < Constants.initChunkDist; x += Constants.chunkSideSize) {
      for (int z = -Constants.initChunkDist; z < Constants.initChunkDist; z += Constants.chunkSideSize) {
        this._gen.fillChunk(this.prepareChunk(x, z));
      }
    }
  }

  /// Gets the random noise generator for this world.
  Generator get generator => this._gen;

  /// Gets the materials for this world.
  Materials? get materials => this._mats;

  /// Gets all the entities for the world.
  /// These is an entity for each material in the world.
  List<three_dart.Entity> get entities => this._entities;

  /// Gets or sets the player which is playing in this world.
  Player? get player => this._player;

  set player(Player? player) => this._player = player;

  /// Finds a chunk with the specific given [x] and [z].
  /// Returns null if no chunk for that location is found.
  Chunk? findChunk(int x, int z) {
    for (final Chunk chunk in this._chunks) {
      if ((chunk.x == x) && (chunk.z == z)) return chunk;
    }
    return null;
  }

  /// Gets the block closest to this given location.
  BlockInfo? getBlock(double x, double y, double z) {
    final int tx = x.floor();
    final int ty = y.floor();
    final int tz = z.floor();
    int cx = (tx < 0) ? tx - Constants.chunkSideSize + 1 : tx;
    int cz = (tz < 0) ? tz - Constants.chunkSideSize + 1 : tz;
    cx = (cx ~/ Constants.chunkSideSize) * Constants.chunkSideSize;
    cz = (cz ~/ Constants.chunkSideSize) * Constants.chunkSideSize;
    final Chunk? chunk = this.findChunk(cx, cz);
    if (chunk == null) return null;
    int bx = tx - cx;
    final int by = ty;
    int bz = tz - cz;
    if (bx < 0) bx += Constants.chunkSideSize;
    if (bz < 0) bz += Constants.chunkSideSize;
    return BlockInfo(bx, by, bz, cx, cz, chunk);
  }

  /// The location of the player in the world.
  Point3 get _playerPoint => this._player?.point ?? Point3.zero;

  /// Adds and removes chunks as needed.
  void worldTick(Object _) {
    final Point3 player = this._playerPoint;
    this._updateLoadedChunks(player);
  }

  /// Generates one chunk which is still pending to be loaded.
  void generateTick(Object _) {
    final Point3 player = this._playerPoint;
    this._generateChunk(player);
    this._refreshDirty(player);
  }

  // Animates the water texture.
  void animationTick(Object _) => this._mats?.waterChanger.nextTexture();

  /// Gets a chunk from the graveyard or creates a new one.
  /// This will prepare the chunk for the given [x] and [z] world location.
  Chunk prepareChunk(int x, int z) {
    final Chunk chunk = (this._graveyard.isNotEmpty ? this._graveyard.removeLast() : null) ?? Chunk(this);
    chunk.prepare(x, z);
    this._chunks.add(chunk);
    return chunk;
  }

  /// Frees the given chunk and puts it in the graveyard
  /// if the chunk is non-null and currently in use.
  /// Returns true if disposed, false if not.
  bool disposeChunk(Chunk? chunk) {
    if ((chunk != null) && this._chunks.remove(chunk)) {
      chunk.freeup();
      this._graveyard.add(chunk);
      return true;
    }
    return false;
  }

  /// Updates chunks which are loaded and removes any loaded chunks
  /// which aren't needed anymore.
  void _updateLoadedChunks(Point3 player) {
    final BlockInfo? pBlock = this.getBlock(player.x, player.y, player.z);
    if (pBlock == null) return;
    // Check if the last chunk
    if (this._lastChunk != pBlock.chunk) {
      this._lastChunk = pBlock.chunk;
      // Remove any out of bounds chunks.
      final minXOut = pBlock.chunkX - Constants.maxChunkDist, maxXOut = pBlock.chunkX + Constants.maxChunkDist;
      final minZOut = pBlock.chunkZ - Constants.maxChunkDist, maxZOut = pBlock.chunkZ + Constants.maxChunkDist;
      for (int i = this._chunks.length - 1; i >= 0; i--) {
        final Chunk chunk = this._chunks[i];
        if ((minXOut > chunk.x) || (maxXOut <= chunk.x) || (minZOut > chunk.z) || (maxZOut <= chunk.z)) {
          this.disposeChunk(this._chunks[i]);
        }
      }
      // Add in any missing chunks.
      final minXIn = pBlock.chunkX - Constants.minChunkDist, maxXIn = pBlock.chunkX + Constants.minChunkDist;
      final minZIn = pBlock.chunkZ - Constants.minChunkDist, maxZIn = pBlock.chunkZ + Constants.minChunkDist;
      for (int x = minXIn; x < maxXIn; x += Constants.chunkSideSize) {
        for (int z = minZIn; z < maxZIn; z += Constants.chunkSideSize) {
          final Chunk? oldChunk = this.findChunk(x, z);
          if (oldChunk == null) this.prepareChunk(x, z);
        }
      }
    }
  }

  /// This picks the nearest non-generated chunk to generate.
  void _generateChunk(Point3 player) {
    final double edgeX = player.x - Constants.chunkSideSize * 0.5;
    final double edgeZ = player.z - Constants.chunkSideSize * 0.5;
    Chunk? nearest;
    double minDist2 = 1.0e-9;
    for (final Chunk chunk in this._chunks) {
      if (chunk.needToGenerate) {
        final double dx = chunk.x - edgeX;
        final double dz = chunk.z - edgeZ;
        final double dist2 = dx * dx + dz * dz;
        if ((nearest == null) || (minDist2 > dist2)) {
          nearest = chunk;
          minDist2 = dist2;
        }
      }
    }
    if (nearest != null) {
      this._gen.fillChunk(nearest);
    }
  }

  /// This picks the nearest dirty chunk to refresh.
  void _refreshDirty(Point3 player) {
    final double edgeX = player.x - Constants.chunkSideSize * 0.5;
    final double edgeZ = player.z - Constants.chunkSideSize * 0.5;
    Chunk? nearest;
    double minDist2 = 1.0e-9;
    for (final Chunk chunk in this._chunks) {
      if (chunk.dirty) {
        final double dx = chunk.x - edgeX;
        final double dz = chunk.z - edgeZ;
        final double dist2 = dx * dx + dz * dz;
        if ((nearest == null) || (minDist2 > dist2)) {
          nearest = chunk;
          minDist2 = dist2;
        }
      }
    }
    if (nearest != null) {
      nearest.dirty = false;
      nearest.needUpdate = true;
    }
  }

  /// Gets the neighboring block to the given block with the
  /// given [ray] pointing at the side to get the neighbor for.
  NeighborBlockInfo? getNeighborBlock(BlockInfo? info, Ray3 ray, Ray3 back, int depth) {
    if (info == null) return null;
    final Region3 region = info.blockRegion;
    final RayRegion3Result inter = rayRegion3(back, region);
    if (!inter.intesects) {
      return null;
    } else {
      // ignore: parameter_assignments
      info = info.neighbor(inter.region);
    }
    if (info == null) return null;
    return NeighborBlockInfo(info, inter.region, ray, depth);
  }

  /// Gets the string for debug information to be printed to the console.
  String debugString() =>
      "chunks: ${this._chunks.length}, graveyard: ${this._graveyard.length}, player: ${this._playerPoint}";

  /// Updates the world to the player's view.
  void update(EventArgs args) {
    final Matrix4 mat = this.player?.location.matrix ?? Matrix4.identity;
    final Point3 loc3 = mat.transPnt3(Point3.zero);
    final Point3 front3 = mat.transPnt3(Point3(0.0, 0.0, -Constants.chunkSideSize.toDouble()));
    final Point2 loc = Point2(loc3.x, loc3.z);
    final Point2 front = Point2(front3.x, front3.z);
    for (final Chunk chunk in this._chunks) {
      chunk.updateShape();
      chunk.updateVisibility(loc, front);
    }
  }
}
