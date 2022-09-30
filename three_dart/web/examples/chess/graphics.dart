library graphics;

import 'dart:html' as html;

import 'package:three_dart/core.dart';
import 'package:three_dart/events.dart';
import 'package:three_dart/io.dart';
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/textures.dart';
import 'package:three_dart/views.dart';

import '../../common/common.dart';
import 'game.dart';

/// Starts the graphics for the chess game.
void startGraphics(
  final Game game,
) {
  final td = ThreeDart.fromId('targetCanvas');
  final camera = Perspective(
    mover: Group(
      [
        UserRotator(input: td.userInput)
          ..pitch.minimumLocation = -PI_2
          ..pitch.maximumLocation = 0.0
          ..pitch.location = -0.5
          ..pitch.wrap = false,
        Constant.scale(1.75, 1.75, 1.75),
        Constant.translate(0.0, 0.0, 15.0)
      ],
    ),
  );
  final frontTarget = FrontTarget()..clearColor = false;
  final board = Board(td, game);
  final skybox = CoverPass.skybox(board.materials.environment)
    ..target = frontTarget
    ..camera = camera;
  final mainScene = EntityPass()
    ..target = frontTarget
    ..camera = camera
    ..children.add(board);
  final pickTarget = BackTarget(
    autoResize: true,
    autoResizeScalarX: 0.5,
    autoResizeScalarY: 0.5,
  );
  final pickScene = EntityPass()
    ..target = pickTarget
    ..camera = camera
    ..children.add(board);
  ColorPicker(td.textureLoader, input: td.userInput, txt: pickTarget.colorTexture)
    ..onPreUpdate.add((_) {
      board.showPick = true;
      td.render(pickScene);
      board.showPick = false;
      td.requestRender();
    })
    ..colorPicked.add((final args) {
      final pickArgs = args as ColorPickerEventArgs;
      board.pick(pickArgs.color.trim32());
    });
  td.scene = Compound(
    passes: [
      skybox,
      mainScene,
    ],
  );
  final elem = html.document.getElementById('buttons');
  final button = html.ButtonElement()
    ..text = 'Fullscreen'
    ..onClick.listen(
      (final _) => td.fullscreen = true,
    );
  elem?.children.add(button);
  show_fps(td);
}

/// Bishop is a piece which the player starts with two of.
/// Bishops move diagonally with no restriction to the distance.
/// https://en.wikipedia.org/wiki/Bishop_(chess)
class Bishop extends Piece {
  /// The singleton for the shape of the bishop with the render cache for the color shader.
  /// Used for rendering to the screen.
  static Entity? _colorShapeEntity;

  /// The singleton for the shape of the bishop with the render cache for the picker shader.
  /// Used for determining which piece or tile was clicked on.
  static Entity? _pickShapeEntity;

  /// Creates a new bishop entity.
  Bishop(ThreeDart td, Board board, bool white, int index, double angle, double scalar)
      : super._(board, white, angle, scalar) {
    var colorEntity = _colorShapeEntity;
    var pickEntity = _pickShapeEntity;
    if (colorEntity == null || pickEntity == null) {
      _colorShapeEntity = colorEntity = Entity(name: 'color bishop shape');
      _pickShapeEntity = pickEntity = Entity(name: 'pick bishop shape');
      ObjType.fromFile('./resources/bishop.obj', td.textureLoader).then((Entity loadedEntity) {
        colorEntity?.shape = loadedEntity.shape;
        pickEntity?.shape = loadedEntity.shape;
      });
    }
    final name = (() {
          if (this._white) {
            return 'white';
          } else {
            return 'black';
          }
        }()) +
        ' bishop $index';
    final value = bishopTileValue(this._white, index);
    this._initialize(name, value, colorEntity, pickEntity);
  }
}

/// The board entity which contains tiles, pieces, and edges.
class Board extends Entity {
  final Game _game;
  final List<Piece> _pieces;
  final List<Tile> _tiles;
  List<Movement> _moves;
  Entity? _table;
  Entity? _edges;
  final Materials _mats;
  bool _showPick;

  /// Creates a board for the given game.
  Board(ThreeDart td, this._game)
      : this._pieces = [],
        this._tiles = [],
        this._moves = [],
        this._table = null,
        this._edges = null,
        this._mats = Materials(td),
        this._showPick = false {
    this.name = "board";
    for (int i = 1; i <= 8; i++) {
      for (int j = 1; j <= 8; j++) {
        final Tile tile = Tile(td, this, ((i + j) % 2) == 0, Location(i, j));
        this._tiles.add(tile);
        this.children.add(tile);
      }
    }
    for (int i = 1; i <= 8; i++) {
      this._add(Pawn(td, this, true, i, 0.0, 0.7));
      this._add(Pawn(td, this, false, i, 0.0, 0.7));
    }
    this._add(Rook(td, this, true, 1, 0.0, 0.7));
    this._add(Rook(td, this, true, 2, 0.0, 0.7));
    this._add(Rook(td, this, false, 1, 0.0, 0.7));
    this._add(Rook(td, this, false, 2, 0.0, 0.7));
    this._add(Knight(td, this, true, 1, 0.0, 0.7));
    this._add(Knight(td, this, true, 2, PI, 0.7));
    this._add(Knight(td, this, false, 1, 0.0, 0.7));
    this._add(Knight(td, this, false, 2, PI, 0.7));
    this._add(Bishop(td, this, true, 1, -PI_2, 0.8));
    this._add(Bishop(td, this, true, 2, PI_2, 0.8));
    this._add(Bishop(td, this, false, 1, -PI_2, 0.8));
    this._add(Bishop(td, this, false, 2, PI_2, 0.8));
    this._add(Queen(td, this, true, 1, 0.0, 1.0));
    this._add(Queen(td, this, false, 1, 0.0, 1.0));
    this._add(King(td, this, true, PI_2, 0.9));
    this._add(King(td, this, false, PI_2, 0.9));
    final Entity edges = this._edges = Entity();
    this.children.add(edges);
    edges.children.add(Edge(td, this, 0.0, 0.0, 0.0, 0));
    edges.children.add(Edge(td, this, 8.0, 0.0, PI_2, 1));
    edges.children.add(Edge(td, this, 8.0, 8.0, PI, 2));
    edges.children.add(Edge(td, this, 0.0, 8.0, PI3_2, 3));
    final Entity table = this._table = Entity(
        shape: disk(sides: 30),
        tech: this._mats.tableTech,
        mover: Constant(Matrix4.translate(0.0, -0.5, 0.0) * Matrix4.rotateX(-PI_2) * Matrix4.scale(12.0, 12.0, 12.0)));
    this.children.add(table);
    this._game.changed.add(_onGameChange);
    this.setLocations(this._game.state);
  }

  /// The collection of material techniques to use for this game.
  Materials get materials => this._mats;

  /// Gets the next unique pick color material technique.
  SolidColor nextPickTech() => this._mats.nextPickTech(this.children.length);

  /// Adds the given piece to the board.
  void _add(Piece piece) {
    this._pieces.add(piece);
    this.children.add(piece);
  }

  /// Handles a picked color being clicked on causing either
  /// a selection of a piece, performs a movement, or has no effect
  /// based on what is piece or tile was clicked on.
  void pick(Color4 color) {
    for (final Piece piece in this._pieces) {
      if (piece.isPick(color)) {
        this._pickLoc(piece.location);
        return;
      }
    }
    for (final Tile tile in this._tiles) {
      if (tile.isPick(color)) {
        this._pickLoc(tile.location);
        return;
      }
    }
  }

  /// Handles a location being clicked on.
  void _pickLoc(Location loc) {
    // Check if a movement location was picked
    for (final Movement move in this._moves) {
      if ((move.destination == loc) || (move.otherSource == loc)) {
        this._game.makeMove(move);
        this._moves.clear();
        return;
      }
    }
    // Check if a piece was picked.
    final TileValue stateItem = this._game.getValue(loc);
    if (stateItem.empty || stateItem.white != this._game.whiteTurn) {
      return;
    } else {
      final selected = this.isSelected(stateItem);
      this.clearHighlights();
      this.clearSelections();
      if (!selected) {
        this.setSelection(stateItem);
        this._moves = this._game.getMovements(stateItem);
        this.setHighlights(this._moves);
      }
    }
  }

  /// Handles when a state changes has occurred in the game.
  void _onGameChange(EventArgs args) {
    this.clearHighlights();
    this.clearSelections();
    this.setLocations(this._game.state);
    // TODO: Update condition information
    // TODO: Update whose turn indication
    // TODO: Update undo/redo buttons
  }

  /// Finds the piece entity with the given piece value or null if not found.
  Piece? findPiece(TileValue stateValue) {
    final item = stateValue.item;
    for (final piece in this._pieces) {
      if (piece.stateItem.item == item) {
        return piece;
      }
    }
    return null;
  }

  /// Gets the piece entity at the given location or null if that location is empty.
  Piece? pieceAt(Location loc) {
    for (final piece in this._pieces) {
      if (piece.location == loc) {
        return piece;
      }
    }
    return null;
  }

  /// Gets the tile entity at the given location or null if out of bounds.
  Tile? tileAt(Location loc) {
    for (final tile in this._tiles) {
      if (tile.location == loc) {
        return tile;
      }
    }
    return null;
  }

  /// Clears all highlights from pieces and tiles.
  void clearHighlights() {
    for (final piece in this._pieces) {
      piece.highlighted = false;
    }
    for (final tile in this._tiles) {
      tile.highlighted = false;
    }
  }

  /// Clears all selection from pieces and tiles.
  void clearSelections() {
    for (final Piece piece in this._pieces) {
      piece.selected = false;
    }
    for (final Tile tile in this._tiles) {
      tile.selected = false;
    }
  }

  /// Gets or sets if the board should render the pick colors.
  /// Typically this is set so the board's pick colors can be rendered to a back buffer
  /// to determine which piece or tile was picked before resetting to normal color rendering.
  bool get showPick => this._showPick;

  set showPick(bool show) {
    if (show != this._showPick) {
      this._showPick = show;
      this._table?.enabled = !show;
      this._edges?.enabled = !show;
      for (final Piece piece in this._pieces) {
        piece.showPick = show;
      }
      for (final Tile tile in this._tiles) {
        tile.showPick = show;
      }
    }
  }

  /// Determines if the piece with the given game piece value is currently selected.
  bool isSelected(TileValue stateItem) {
    final Piece? piece = this.findPiece(stateItem);
    return (piece != null) && piece.selected;
  }

  /// Sets the piece with the given game piece value and the tile it is on as selected.
  void setSelection(TileValue stateItem) {
    final Piece? piece = this.findPiece(stateItem);
    if (piece != null) {
      piece.selected = true;
      final Tile? tile = this.tileAt(piece.location);
      tile?.selected = true;
    }
  }

  /// Sets the location of the pieces based on the current board state.
  void setLocations(State state) {
    for (final Piece piece in this._pieces) {
      final Location loc = state.findItem(piece.stateItem);
      piece.location = loc;
      piece.enabled = loc.onBoard;
    }
  }

  /// Sets the highlights for all the given movements.
  void setHighlights(List<Movement> movements) {
    for (final Movement movement in movements) {
      final Tile? tile = this.tileAt(movement.destination);
      tile?.highlighted = true;
      final otherSource = movement.otherSource;
      if (otherSource != null) {
        final Piece? piece = this.pieceAt(otherSource);
        piece?.highlighted = true;
      }
    }
  }
}

/// An entity for rendering the edge of the chess board.
class Edge extends Entity {
  /// The singleton for the shape of the edge with the render cache for the color shader.
  /// Used for rendering to the screen.
  static Entity? _shapeEntity;

  /// Creates a new edge entity.
  Edge(ThreeDart td, Board board, double dx, double dz, double angle, int textureIndex) {
    var shapeEntity = _shapeEntity;
    if (shapeEntity == null) {
      _shapeEntity = shapeEntity = Entity(name: "edge shape");
      ObjType.fromFile("./resources/edge.obj", td.textureLoader).then((Entity loadedEntity) {
        _shapeEntity?.shape = loadedEntity.shape;
      });
    }
    this.mover = Constant(Matrix4.translate(dx - 4.0, 0.0, dz - 4.0) * Matrix4.rotateY(angle));
    this.name = "edge";
    this.children.add(shapeEntity);
    this.technique = board.materials.edgeTechs[textureIndex];
  }
}

/// King is a piece which the player only has one of.
/// Kings move diagonally, vertically, and horizontally only one tile.
/// https://en.wikipedia.org/wiki/King_(chess)
class King extends Piece {
  /// The singleton for the shape of the king with the render cache for the color shader.
  /// Used for rendering to the screen.
  static Entity? _colorShapeEntity;

  /// The singleton for the shape of the king with the render cache for the picker shader.
  /// Used for determining which piece or tile was clicked on.
  static Entity? _pickShapeEntity;

  /// Creates a new king entity.
  King(ThreeDart td, Board board, bool white, double angle, double scalar) : super._(board, white, angle, scalar) {
    var colorEntity = _colorShapeEntity;
    var pickEntity = _pickShapeEntity;
    if (colorEntity == null || pickEntity == null) {
      _colorShapeEntity = colorEntity = Entity(name: "color king shape");
      _pickShapeEntity = pickEntity = Entity(name: "pick king shape");
      ObjType.fromFile("./resources/king.obj", td.textureLoader).then((Entity loadedEntity) {
        colorEntity?.shape = loadedEntity.shape;
        pickEntity?.shape = loadedEntity.shape;
      });
    }
    final name = (() {
          if (this._white) {
            return "white";
          } else {
            return "black";
          }
        }()) +
        " king";
    final value = kingTileValue(this._white);
    this._initialize(name, value, colorEntity, pickEntity);
  }
}

/// Knight is a piece which the player starts with two of.
/// Knights move in an "L" shape of 2 by 1 tiles.
/// https://en.wikipedia.org/wiki/Knight_(chess)
class Knight extends Piece {
  /// The singleton for the shape of the knight with the render cache for the color shader.
  /// Used for rendering to the screen.
  static Entity? _colorShapeEntity;

  /// The singleton for the shape of the knight with the render cache for the picker shader.
  /// Used for determining which piece or tile was clicked on.
  static Entity? _pickShapeEntity;

  /// Creates a new knight entity.
  Knight(ThreeDart td, Board board, bool white, int index, double angle, double scalar)
      : super._(board, white, angle, scalar) {
    var colorEntity = _colorShapeEntity;
    var pickEntity = _pickShapeEntity;
    if (colorEntity == null || pickEntity == null) {
      _colorShapeEntity = colorEntity = Entity(name: "color knight shape");
      _pickShapeEntity = pickEntity = Entity(name: "pick knight shape");
      ObjType.fromFile("./resources/knight.obj", td.textureLoader).then((Entity loadedEntity) {
        colorEntity?.shape = loadedEntity.shape;
        pickEntity?.shape = loadedEntity.shape;
      });
    }
    final name = (() {
          if (this._white) {
            return "white";
          } else {
            return "black";
          }
        }()) +
        " knight $index";
    final value = knightTileValue(this._white, index);
    this._initialize(name, value, colorEntity, pickEntity);
  }
}

/// The collection of material techniques used for chess.
class Materials {
  final ThreeDart _td;

  /// Creates a new collection of materials techniques.
  Materials(this._td);

  /// Creates a new pick color technique using the given index.
  SolidColor nextPickTech(int index) {
    const int max = 96;
    final Color4 color = Color4.fromHVS(index / max, 1.0, 1.0);
    return SolidColor(color: color.trim32());
  }

  /// Gets the enviroment texture cube used for background and reflections.
  TextureCube get environment => this._environment ??= this._td.textureLoader.loadCubeFromPath('resources');
  TextureCube? _environment;

  Directional get topLight => this._topLight ??= Directional()
    ..color = Color3(1.0, 0.9, 0.8)
    ..direction = Vector3(0.0, -1.0, -0.25);
  Directional? _topLight;

  Directional get bottomLight => this._bottomLight ??= Directional()
    ..color = Color3(0.0, 0.1, 0.3)
    ..direction = Vector3(0.0, 1.0, 0.25);
  Directional? _bottomLight;

  Color3 get pieceReflection => this._pieceReflection ??= Color3.gray(0.15);
  Color3? _pieceReflection;

  Color3 get tileReflection => this._tileReflection ??= Color3.gray(0.075);
  Color3? _tileReflection;

  MaterialLight get whitePieceTech => this._whitePieceTech ??= MaterialLight()
    ..diffuse.color = Color3.gray(0.6)
    ..ambient.color = Color3.gray(0.4)
    ..specular.color = Color3.white()
    ..specular.shininess = 60.0
    ..environment = this.environment
    ..reflection.color = pieceReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _whitePieceTech;

  MaterialLight get blackPieceTech => this._blackPieceTech ??= MaterialLight()
    ..diffuse.color = Color3.gray(0.2)
    ..ambient.color = Color3.gray(0.1)
    ..specular.color = Color3.white()
    ..specular.shininess = 60.0
    ..environment = this.environment
    ..reflection.color = pieceReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _blackPieceTech;

  MaterialLight get selectedWhitePieceTech => this._selectedWhitePieceTech ??= MaterialLight()
    ..diffuse.color = Color3(0.6, 0.0, 0.0)
    ..ambient.color = Color3(0.8, 0.0, 0.0)
    ..specular.color = Color3.white()
    ..specular.shininess = 100.0
    ..environment = this.environment
    ..reflection.color = pieceReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _selectedWhitePieceTech;

  MaterialLight get selectedBlackPieceTech => this._selectedBlackPieceTech ??= MaterialLight()
    ..diffuse.color = Color3(0.2, 0.0, 0.0)
    ..ambient.color = Color3(0.6, 0.0, 0.0)
    ..specular.color = Color3.white()
    ..specular.shininess = 100.0
    ..environment = this.environment
    ..reflection.color = pieceReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _selectedBlackPieceTech;

  MaterialLight get highlightedWhitePieceTech => this._highlightedWhitePieceTech ??= MaterialLight()
    ..diffuse.color = Color3(0.5, 0.5, 0.0)
    ..ambient.color = Color3(0.7, 0.7, 0.0)
    ..specular.color = Color3.white()
    ..specular.shininess = 100.0
    ..environment = this.environment
    ..reflection.color = pieceReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _highlightedWhitePieceTech;

  MaterialLight get highlightedBlackPieceTech => this._highlightedBlackPieceTech ??= MaterialLight()
    ..diffuse.color = Color3(0.1, 0.1, 0.0)
    ..ambient.color = Color3(0.5, 0.5, 0.0)
    ..specular.color = Color3.white()
    ..specular.shininess = 100.0
    ..environment = this.environment
    ..reflection.color = pieceReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _highlightedBlackPieceTech;

  MaterialLight get whiteTileTech => this._whiteTileTech ??= MaterialLight()
    ..diffuse.color = Color3.gray(0.6)
    ..ambient.color = Color3.gray(0.4)
    ..specular.color = Color3.white()
    ..specular.shininess = 60.0
    ..environment = this.environment
    ..reflection.color = tileReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _whiteTileTech;

  MaterialLight get blackTileTech => this._blackTileTech ??= MaterialLight()
    ..diffuse.color = Color3.gray(0.2)
    ..ambient.color = Color3.gray(0.1)
    ..specular.color = Color3.white()
    ..specular.shininess = 60.0
    ..environment = this.environment
    ..reflection.color = tileReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _blackTileTech;

  MaterialLight get selectedWhiteTileTech => this._selectedWhiteTileTech ??= MaterialLight()
    ..diffuse.color = Color3(0.6, 0.0, 0.0)
    ..ambient.color = Color3(0.8, 0.0, 0.0)
    ..specular.color = Color3.white()
    ..specular.shininess = 100.0
    ..environment = this.environment
    ..reflection.color = tileReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _selectedWhiteTileTech;

  MaterialLight get selectedBlackTileTech => this._selectedBlackTileTech ??= MaterialLight()
    ..diffuse.color = Color3(0.2, 0.0, 0.0)
    ..ambient.color = Color3(0.6, 0.0, 0.0)
    ..specular.color = Color3.white()
    ..specular.shininess = 100.0
    ..environment = this.environment
    ..reflection.color = tileReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _selectedBlackTileTech;

  MaterialLight get highlightedWhiteTileTech => this._highlightedWhiteTileTech ??= MaterialLight()
    ..diffuse.color = Color3(0.5, 0.5, 0.0)
    ..ambient.color = Color3(0.7, 0.7, 0.0)
    ..specular.color = Color3.white()
    ..specular.shininess = 100.0
    ..environment = this.environment
    ..reflection.color = tileReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _highlightedWhiteTileTech;

  MaterialLight get highlightedBlackTileTech => this._highlightedBlackTileTech ??= MaterialLight()
    ..diffuse.color = Color3(0.1, 0.1, 0.0)
    ..ambient.color = Color3(0.5, 0.5, 0.0)
    ..specular.color = Color3.white()
    ..specular.shininess = 100.0
    ..environment = this.environment
    ..reflection.color = tileReflection
    ..lights.add(topLight)
    ..lights.add(bottomLight);
  MaterialLight? _highlightedBlackTileTech;

  List<MaterialLight> get edgeTechs =>
      this._edgeTechs ??
      List.generate(4, (int i) {
        final edgeTxt = this._td.textureLoader.load2DFromFile('resources/edge$i.png');
        final edgeNorm = this._td.textureLoader.load2DFromFile('resources/edge${i}Normal.png');
        return MaterialLight()
          ..bump.texture2D = edgeNorm
          ..diffuse.color = Color3.gray(0.6)
          ..diffuse.texture2D = edgeTxt
          ..ambient.color = Color3.gray(0.4)
          ..ambient.texture2D = edgeTxt
          ..specular.color = Color3.white()
          ..specular.shininess = 80.0
          ..environment = this.environment
          ..reflection.color = Color3.gray(0.1)
          ..lights.add(topLight)
          ..lights.add(bottomLight);
      });
  List<MaterialLight>? _edgeTechs;

  MaterialLight get tableTech => this._tableTech ??= () {
        final tableColor = this._td.textureLoader.load2DFromFile('resources/tableColor.png');
        final tableSpec = this._td.textureLoader.load2DFromFile('resources/tableSpec.png');
        return MaterialLight()
          ..diffuse.color = Color3.gray(0.6)
          ..diffuse.texture2D = tableColor
          ..ambient.color = Color3.gray(0.4)
          ..ambient.texture2D = tableColor
          ..specular.color = Color3.white()
          ..specular.shininess = 80.0
          ..specular.texture2D = tableSpec
          ..environment = this.environment
          ..reflection.texture2D = tableSpec
          ..bump.texture2D = this._td.textureLoader.load2DFromFile('resources/tableNormal.png')
          ..lights.add(topLight)
          ..lights.add(bottomLight);
      }();
  MaterialLight? _tableTech;
}

/// Pawn is a piece which the player starts with eight of.
/// Pawns move forward only one space.
/// https://en.wikipedia.org/wiki/Pawn_(chess)
class Pawn extends Piece {
  /// The singleton for the shape of the pawn with the render cache for the color shader.
  /// Used for rendering to the screen.
  static Entity? _colorShapeEntity;

  /// The singleton for the shape of the pawn with the render cache for the picker shader.
  /// Used for determining which piece or tile was clicked on.
  static Entity? _pickShapeEntity;

  /// Creates a new pawn entity.
  Pawn(ThreeDart td, Board board, bool white, int index, double angle, double scalar)
      : super._(board, white, angle, scalar) {
    Entity? colorEntity = _colorShapeEntity;
    Entity? pickEntity = _pickShapeEntity;
    if (colorEntity == null || pickEntity == null) {
      _colorShapeEntity = colorEntity = Entity(name: 'color pawn shape');
      _pickShapeEntity = pickEntity = Entity(name: 'pick pawn shape');
      ObjType.fromFile('./resources/pawn.obj', td.textureLoader).then((Entity loadedEntity) {
        colorEntity?.shape = loadedEntity.shape;
        pickEntity?.shape = loadedEntity.shape;
      });
    }
    final String name = (() {
          if (this._white) {
            return 'white';
          } else {
            return 'black';
          }
        }()) +
        ' pawn $index';
    final value = pawnTileValue(this._white, index);
    this._initialize(name, value, colorEntity, pickEntity);
  }
}

/// The abstract base entity for all chess pieces.
abstract class Piece extends Entity {
  final Board _board;
  final bool _white;
  final double _angle;
  final double _scalar;

  Location _loc;
  final Constant _mover;
  TileValue _stateItem;
  bool _selected;
  bool _highlighted;
  bool _showPick;

  SolidColor? _pickTech;
  Entity? _colorEntity;
  Entity? _pickEntity;

  /// Creates a new piece.
  Piece._(this._board, this._white, this._angle, this._scalar)
      : this._loc = const Location(0, 0),
        this._mover = Constant(),
        this._stateItem = TileValue.Empty,
        this._selected = false,
        this._highlighted = false,
        this._showPick = false,
        this._pickTech = null,
        this._colorEntity = null,
        this._pickEntity = null;

  /// Must be called by the inheriting piece kind to finish initialize the piece.
  void _initialize(String name, TileValue stateItem, Entity colorShapeEntity, Entity pickShapeEntity) {
    this._pickTech = this._board.nextPickTech();
    this._stateItem = stateItem;
    final Entity colorEntity = this._colorEntity = Entity(children: [colorShapeEntity], name: "color " + name);
    final Entity pickEntity = this._pickEntity =
        Entity(children: [pickShapeEntity], name: "pick " + name, tech: this._pickTech, enabled: false);
    this.mover = this._mover;
    this.name = name;
    this.children.add(colorEntity);
    this.children.add(pickEntity);
    this._updateLocation();
    this._updateColorTech();
  }

  /// Indicates if this piece is white or black.
  bool get white => this._white;

  /// Get the value which represents this piece in the game.
  TileValue get stateItem => this._stateItem;

  /// Gets or sets if the pick color should be rendered.
  bool get showPick => this._showPick;

  set showPick(bool show) {
    if (show != this._showPick) {
      this._showPick = show;
      this._colorEntity?.enabled = !show;
      this._pickEntity?.enabled = show;
    }
  }

  /// Gets or sets if the piece should be selected.
  bool get selected => this._selected;

  set selected(bool selected) {
    if (selected != this._selected) {
      this._selected = selected;
      this._highlighted = false;
      this._updateColorTech();
    }
  }

  /// Gets or sets if the piece should be highlighted.
  bool get highlighted => this._highlighted;

  set highlighted(bool highlighted) {
    if (highlighted != this._highlighted) {
      this._highlighted = highlighted;
      this._selected = false;
      this._updateColorTech();
    }
  }

  /// Checks if the given color is this piece's pick color.
  bool isPick(Color4 pick) => this._pickTech?.color == pick;

  /// Gets or sets the location of this piece.
  Location get location => this._loc;

  set location(Location loc) {
    if (this._loc != loc) {
      this._loc = loc;
      this._updateLocation();
    }
  }

  /// Updates the movement matrix to place the piece.
  void _updateLocation() =>
      this._mover.matrix = Matrix4.translate(this._loc.row.toDouble() - 4.5, 0.0, this._loc.column.toDouble() - 4.5) *
          Matrix4.rotateY(this._angle) *
          Matrix4.scale(this._scalar, this._scalar, this._scalar);

  /// Updates the technique used for the shown color of the piece.
  void _updateColorTech() {
    if (this._white) {
      if (this._selected) {
        this.technique = this._board.materials.selectedWhitePieceTech;
      } else if (this._highlighted) {
        this.technique = this._board.materials.highlightedWhitePieceTech;
      } else {
        this.technique = this._board.materials.whitePieceTech;
      }
    } else {
      if (this._selected) {
        this.technique = this._board.materials.selectedBlackPieceTech;
      } else if (this._highlighted) {
        this.technique = this._board.materials.highlightedBlackPieceTech;
      } else {
        this.technique = this._board.materials.blackPieceTech;
      }
    }
  }
}

/// Queen is a piece which the player starts with two of.
/// Queens move diagonally, horizontally, and vertically with no restriction to the distance.
/// https://en.wikipedia.org/wiki/Queen_(chess)
class Queen extends Piece {
  /// The singleton for the shape of the queen with the render cache for the color shader.
  /// Used for rendering to the screen.
  static Entity? _colorShapeEntity;

  /// The singleton for the shape of the queen with the render cache for the picker shader.
  /// Used for determining which piece or tile was clicked on.
  static Entity? _pickShapeEntity;

  /// Creates a new queen entity.
  Queen(ThreeDart td, Board board, bool white, int index, double angle, double scalar)
      : super._(board, white, angle, scalar) {
    Entity? colorEntity = _colorShapeEntity;
    Entity? pickEntity = _pickShapeEntity;
    if (colorEntity == null || pickEntity == null) {
      _colorShapeEntity = colorEntity = Entity(name: 'color queen shape');
      _pickShapeEntity = pickEntity = Entity(name: 'pick queen shape');
      ObjType.fromFile('./resources/queen.obj', td.textureLoader).then((Entity loadedEntity) {
        colorEntity?.shape = loadedEntity.shape;
        pickEntity?.shape = loadedEntity.shape;
      });
    }
    final name = (() {
          if (this._white) {
            return 'white';
          } else {
            return 'black';
          }
        }()) +
        ' queen $index';
    final value = queenTileValue(this._white, index);
    this._initialize(name, value, colorEntity, pickEntity);
  }
}

/// Rook is a piece which the player starts with two of.
/// Rooks move horizontally and vertically with no restriction to the distance.
/// https://en.wikipedia.org/wiki/Rook_(chess)
class Rook extends Piece {
  /// The singleton for the shape of the rook with the render cache for the color shader.
  /// Used for rendering to the screen.
  static Entity? _colorShapeEntity;

  /// The singleton for the shape of the rook with the render cache for the picker shader.
  /// Used for determining which piece or tile was clicked on.
  static Entity? _pickShapeEntity;

  /// Creates a new rook entity.
  Rook(ThreeDart td, Board board, bool white, int index, double angle, double scalar)
      : super._(board, white, angle, scalar) {
    Entity? colorEntity = _colorShapeEntity;
    Entity? pickEntity = _pickShapeEntity;
    if (colorEntity == null || pickEntity == null) {
      _colorShapeEntity = colorEntity = Entity(name: 'rook shape');
      _pickShapeEntity = pickEntity = Entity(name: 'rook shape');
      ObjType.fromFile('./resources/rook.obj', td.textureLoader).then((Entity loadedEntity) {
        colorEntity?.shape = loadedEntity.shape;
        pickEntity?.shape = loadedEntity.shape;
      });
    }
    final name = (() {
          if (this._white) {
            return 'white';
          } else {
            return 'black';
          }
        }()) +
        ' rook $index';
    final value = rookTileValue(this._white, index);
    this._initialize(name, value, colorEntity, pickEntity);
  }
}

/// A tile is the entity on the board which can be clicked on and highlighted.
class Tile extends Entity {
  /// The singleton for the shape of the tile with the render cache for the color shader.
  /// Used for rendering to the screen.
  static Entity? _colorShapeEntity;

  /// The singleton for the shape of the tile with the render cache for the picker shader.
  /// Used for determining which piece or tile was clicked on.
  static Entity? _pickShapeEntity;

  /// The location for this tile on the board.
  final Location _loc;

  /// The board which this tile belongs to.
  final Board _board;

  /// Indicates if this is a white tile or black tile.
  final bool _white;

  /// Indicates if this tile is selected.
  bool _selected;

  /// Indicates if this tile is highlighted.
  bool _highlighted;

  /// Indicates that the pick color should be rendered.
  bool _showPick;

  /// The technique for drawing the pick color for this tile.
  SolidColor? _pickTech;

  /// The child entity for the shown color of this tile.
  Entity? _colorEntity;

  /// The child entity for the pick color of this tile.
  Entity? _pickEntity;

  /// Creates a new tile entity.
  Tile(ThreeDart td, this._board, this._white, this._loc)
      : this._selected = false,
        this._highlighted = false,
        this._showPick = false,
        this._pickTech = null,
        this._colorEntity = null,
        this._pickEntity = null {
    Entity? colorShapeEntity = _colorShapeEntity;
    Entity? pickShapeEntity = _pickShapeEntity;
    if (colorShapeEntity == null || pickShapeEntity == null) {
      _colorShapeEntity = colorShapeEntity = Entity(name: 'color tile shape');
      _pickShapeEntity = pickShapeEntity = Entity(name: 'pick tile shape');
      ObjType.fromFile('./resources/tile.obj', td.textureLoader).then((Entity loadedEntity) {
        colorShapeEntity?.shape = loadedEntity.shape;
        pickShapeEntity?.shape = loadedEntity.shape;
      });
    }
    final name = (() {
          if (this._white) {
            return 'white';
          } else {
            return 'black';
          }
        }()) +
        ' tile ${this._loc.row} ${this._loc.column}';
    this._pickTech = this._board.nextPickTech();
    final Entity colorEntity = this._colorEntity = Entity(children: [colorShapeEntity], name: 'color ' + name);
    final Entity pickEntity = this._pickEntity =
        Entity(children: [pickShapeEntity], name: 'pick ' + name, tech: this._pickTech, enabled: false);
    this.mover = Constant.translate(this._loc.row.toDouble() - 4.5, 0.0, this._loc.column.toDouble() - 4.5);
    this.name = name;
    this.children.add(colorEntity);
    this.children.add(pickEntity);
    this._updateColorTech();
  }

  /// Gets the location of this tile.
  Location get location => this._loc;

  /// Gets or sets if the pick color should be rendered.
  bool get showPick => this._showPick;

  set showPick(bool show) {
    if (show != this._showPick) {
      this._showPick = show;
      this._colorEntity?.enabled = !show;
      this._pickEntity?.enabled = show;
    }
  }

  /// Gets or sets if the tile should be selected.
  bool get selected => this._selected;

  set selected(bool selected) {
    if (selected != this.selected) {
      this._selected = selected;
      this._highlighted = false;
      this._updateColorTech();
    }
  }

  /// Gets or sets if the tile should be highlighted.
  bool get highlighted => this._highlighted;

  set highlighted(bool highlighted) {
    if (highlighted != this._highlighted) {
      this._highlighted = highlighted;
      this._selected = false;
      this._updateColorTech();
    }
  }

  /// Checks if the given color is this tile's pick color.
  bool isPick(Color4 pick) => this._pickTech?.color == pick;

  /// Updates the technique used for the shown color of the tile.
  void _updateColorTech() {
    if (this._white) {
      if (this._selected) {
        this.technique = this._board.materials.selectedWhiteTileTech;
      } else if (this._highlighted) {
        this.technique = this._board.materials.highlightedWhiteTileTech;
      } else {
        this.technique = this._board.materials.whiteTileTech;
      }
    } else {
      if (this._selected) {
        this.technique = this._board.materials.selectedBlackTileTech;
      } else if (this._highlighted) {
        this.technique = this._board.materials.highlightedBlackTileTech;
      } else {
        this.technique = this._board.materials.blackTileTech;
      }
    }
  }
}
