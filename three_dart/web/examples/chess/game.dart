import 'package:three_dart/events/events.dart';

/// This is a handler for returning possible movements for a piece.
typedef MovementCallback = void Function(Movement move);

/// The main controller for a chess game.
class Game {
  /// Indicates if it is (true) white's turn or (false) black's turn.
  bool _whiteTurn;

  /// The condition of the current state of the game.
  int _condition;

  /// The current board state of the game with potentially previous
  /// and future states for undo/redo.
  State _state;

  /// Indicates the game has changed state, condition, and/or turn.
  Event? _changed;

  /// Creates a new chess game.
  Game()
      : this._whiteTurn = true,
        this._condition = State.Normal,
        this._state = State.initial(),
        this._changed = null;

  /// Indicates if it is (true) white's turn or (false) black's turn.
  bool get whiteTurn => this._whiteTurn;

  /// Gets the condition of the current state of the game.
  /// Check, Checkmate, Stalemate, or Normal.
  int get condition => this._condition;

  /// Gets the current board state.
  State get state => this._state;

  /// Indicates if there is any previous board state which can be undone to.
  bool get hasUndo => this._state.prev != null;

  /// Indicates if there is any future board state which can be redone to.
  bool get hasRedo => this._state.next != null;

  /// The event is fired when the game has changed state, condition, and/or turn.
  Event get changed => this._changed ??= Event();

  /// Is called to fire the game changed event.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Gets the tile value indicating the state of the game board at the given location.
  TileValue getValue(Location loc) => this._state.getValue(loc);

  /// Gets the location of the given piece value, or null if the piece is not on the board.
  Location findItem(TileValue item) => this._state.findItem(item);

  /// Gets all the possible movements for the current color's turn.
  List<Movement> getAllMovements() => this._state.getAllMovements(this._whiteTurn);

  /// Gets all the possible movements for the given piece.
  /// The piece must be on the board and a piece for the current color's turn.
  List<Movement> getMovements(TileValue piece) {
    if (piece.outOfBounds) throw Exception("may not get movements for an out-of-bounds piece");
    if (piece.white != this._whiteTurn) throw Exception("may not get movements out-of-turn");
    return this._state.getMovements(this._state.findItem(piece));
  }

  /// Performs a move to this game. Makes a copy of the current state and
  /// applies this move to the state. It switches to the other color's turn.
  /// The movement must be for the current color's turn and must be a valid possible movement.
  void makeMove(Movement move) {
    final TileValue piece = this._state.getValue(move.source);
    if (piece.white != this._whiteTurn) throw Exception("may not make a move movement out-of-turn");
    if (!this._state.isValidMovement(move)) throw Exception("not a valid move: " + move.toString());
    this._state = this._state.pushState();
    this._state.applyMovement(move);
    this._whiteTurn = !this._whiteTurn;
    this._condition = this._state.condition(this.whiteTurn);
    this._onChanged();
  }

  /// Undo will transition to the previous state and color turn,
  /// while putting the current state into the redo.
  /// This can run multiple undoes at the same time by setting the number of `steps` greater than 1.
  /// Will return true if any change was made, false if no undo was possible.
  bool undo([int steps = 1]) {
    bool changed = false;
    for (int i = 0; i < steps; ++i) {
      final State? prev = this._state.prev;
      if (prev == null) break;
      changed = true;
      this._state = prev;
      this._whiteTurn = !this._whiteTurn;
    }
    if (changed) {
      this._condition = this._state.condition(this.whiteTurn);
      this._onChanged();
    }
    return changed;
  }

  /// Redo is the same of undo except that it moves to any future state if there is one.
  /// This can run multiple redoes at the same time by setting the number of `steps` greater than 1.
  bool redo([int steps = 1]) {
    bool changed = false;
    for (int i = 0; i < steps; ++i) {
      final State? next = this._state.next;
      if (next == null) break;
      changed = true;
      this._state = next;
      this._whiteTurn = !this._whiteTurn;
    }
    if (changed) {
      this._condition = this._state.condition(this.whiteTurn);
      this._onChanged();
    }
    return changed;
  }
}

/// Location is the chess board.
class Location {
  /// This is the vertical offset to the horizontal strip of tiles.
  /// The top most is 1 and the bottom most is 8.
  final int row;

  /// This is the horizontal offset to the vertical strip of tiles.
  /// The left most is 1 and the right most is 8.
  final int column;

  /// Constructs a new board location.
  const Location(
    final this.row,
    final this.column,
  );

  /// Constructs a new board location with the index to the chess state data.
  factory Location.fromIndex(int index) {
    if ((index < 0) || (index >= 64)) {
      return const Location(0, 0);
    } else {
      final row = index ~/ 8 + 1;
      final column = index % 8 + 1;
      return Location(row, column);
    }
  }

  /// Gets a new location with the row and column offset with the given deltas.
  Location offset(int deltaRow, int deltaColumn) => Location(this.row + deltaRow, this.column + deltaColumn);

  /// Indicates if this location is on the board (true) or not (false).
  bool get onBoard => (this.row >= 1) && (this.row <= 8) && (this.column >= 1) && (this.column <= 8);

  /// Gets the index into the chess state data which stores the tile data for this location.
  int get index => onBoard ? (this.row - 1) * 8 + (this.column - 1) : -1;

  /// Gets the formal notation for chess location.
  String toNotation() => onBoard ? "${'abcdefgh'[column - 1]}${9 - row}" : "xx";

  /// Gets the string for this location.
  @override
  String toString() => "$row $column";

  /// Determines if the two locations are equal to each other.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Location) return false;
    if (other.row != this.row) return false;
    if (other.column != this.column) return false;
    return true;
  }

  @override
  int get hashCode => row.hashCode ^ column.hashCode;

}

/// Defines a movement which can be performed on a chess board.
class Movement {
  /// A description of the move.
  final String description;

  /// The location of the piece which is about to be moved.
  final Location source;

  /// The location that the piece will be moved into.
  final Location destination;

  /// The location of another piece, typically an opponents but not always,
  /// which will be moved or removed during this movement.
  /// If this is null then no other piece is effected.
  final Location? otherSource;

  /// The location the other piece will be moved into.
  /// If this is null then the other piece is being removed from the board.
  final Location? otherDestination;

  /// Constructs a movement with the given information.
  Movement(this.description, this.source, this.destination, [this.otherSource, this.otherDestination]);

  /// Gets a string for this movement.
  @override
  String toString() {
    String other = '';
    if (this.otherSource != null) other = ', ${this.otherSource} => ${this.otherDestination}';
    return '${this.description}, ${this.source} => ${this.destination}$other';
  }
}

/// This is a chess board at a given state.
class State {
  static const int Normal = 0;

  /// Indicates the game condition is in no special condition.
  static const int Check = 1;

  /// Indicates the game condition is in check for the current player.
  static const int Checkmate = 2;

  /// Indicates the game condition has reached checkmate.
  static const int Stalemate = 3;

  /// Indicates the game condition has reached stalemate.

  /// The tile values for all of the tiles on a chess board.
  List<int> _data;

  /// The next state after this state or null if there is none.
  /// This next state is usually set to be used for redo and
  /// is overwrote when a movement is applied.
  State? next;

  /// The previous state before this state or null if there is none.
  /// This previous state is usually set to be used for undo.
  State? prev;

  /// Creates a new state.
  State()
      : this._data = List<int>.filled(64, TileValue.Empty.value, growable: false),
        this.next = null,
        this.prev = null;

  /// Creates a new state which is set to the initial chess board state.
  factory State.initial() {
    //    1  2  3  4  5  6  7  8  <- Column
    // 1 |R0|H0|B0|K0|Q0|B1|H1|R1| <- Black
    // 2 |P0|P1|P2|P3|P4|P5|P6|P7| <- Black
    // 3 |  |  |  |  |  |  |  |  |
    // 4 |  |  |  |  |  |  |  |  |
    // 5 |  |  |  |  |  |  |  |  |
    // 6 |  |  |  |  |  |  |  |  |
    // 7 |P0|P1|P2|P3|P4|P5|P6|P7| <- White
    // 8 |R0|H0|B0|K0|Q0|B1|H1|R1| <- White
    final State state = State();
    state.setValue(const Location(1, 1), TileValue.rook(false, 1));
    state.setValue(const Location(1, 2), TileValue.knight(false, 1));
    state.setValue(const Location(1, 3), TileValue.bishop(false, 1));
    state.setValue(const Location(1, 4), TileValue.king(false));
    state.setValue(const Location(1, 5), TileValue.queen(false, 1));
    state.setValue(const Location(1, 6), TileValue.bishop(false, 2));
    state.setValue(const Location(1, 7), TileValue.knight(false, 2));
    state.setValue(const Location(1, 8), TileValue.rook(false, 2));
    state.setValue(const Location(2, 1), TileValue.pawn(false, 1));
    state.setValue(const Location(2, 2), TileValue.pawn(false, 2));
    state.setValue(const Location(2, 3), TileValue.pawn(false, 3));
    state.setValue(const Location(2, 4), TileValue.pawn(false, 4));
    state.setValue(const Location(2, 5), TileValue.pawn(false, 5));
    state.setValue(const Location(2, 6), TileValue.pawn(false, 6));
    state.setValue(const Location(2, 7), TileValue.pawn(false, 7));
    state.setValue(const Location(2, 8), TileValue.pawn(false, 8));
    state.setValue(const Location(7, 1), TileValue.pawn(true, 1));
    state.setValue(const Location(7, 2), TileValue.pawn(true, 2));
    state.setValue(const Location(7, 3), TileValue.pawn(true, 3));
    state.setValue(const Location(7, 4), TileValue.pawn(true, 4));
    state.setValue(const Location(7, 5), TileValue.pawn(true, 5));
    state.setValue(const Location(7, 6), TileValue.pawn(true, 6));
    state.setValue(const Location(7, 7), TileValue.pawn(true, 7));
    state.setValue(const Location(7, 8), TileValue.pawn(true, 8));
    state.setValue(const Location(8, 1), TileValue.rook(true, 1));
    state.setValue(const Location(8, 2), TileValue.knight(true, 1));
    state.setValue(const Location(8, 3), TileValue.bishop(true, 1));
    state.setValue(const Location(8, 4), TileValue.king(true));
    state.setValue(const Location(8, 5), TileValue.queen(true, 1));
    state.setValue(const Location(8, 6), TileValue.bishop(true, 2));
    state.setValue(const Location(8, 7), TileValue.knight(true, 2));
    state.setValue(const Location(8, 8), TileValue.rook(true, 2));
    return state;
  }

  /// This will load a state from a string representing the board.
  /// This string is the same as `toString(false)` of a state.
  /// This will return false if there aren't 128 color piece letter pairs.
  static State parse(List<String> data) {
    final State state = State();
    final Map<int, bool> used = <int, bool>{};
    final StringGrid grid = StringGrid.parse(data);
    if ((grid.rows != 8) || (grid.columns != 8)) throw Exception('Must provide an 8x8 board to parse a state.');
    // Parse the cells of the given data into tile values.
    for (int r = 0; r < 8; ++r) {
      for (int c = 0; c < 8; ++c) {
        final String value = grid.getCell(r, c).trim();
        final TileValue tile = TileValue.parse(value);
        if (!tile.empty) {
          if (!tile.count.empty) used[tile.item.value] = true;
          final int index = Location(r + 1, c + 1).index;
          state._data[index] = tile.value;
        }
      }
    }
    // Set any counts which haven't been set yet.
    for (int i = 0; i < 64; ++i) {
      final TileValue tile = TileValue(state._data[i]);
      if ((!tile.empty) && tile.count.empty) {
        for (int count = 1; count < 64; ++count) {
          final TileValue check = tile | TileValue(count);
          if (!(used[check.item.value] ?? false)) {
            used[check.item.value] = true;
            state._data[i] = check.value;
            break;
          }
        }
      }
    }
    return state;
  }

  /// This will copy the current state and return the copy.
  /// This will not modify previous or next states.
  State copy() {
    final State state = State();
    for (int i = 0; i < 64; ++i) {
      state._data[i] = this._data[i];
    }
    return state;
  }

  /// This will copy the current state and return the copy.
  /// This new copy will take the place of the next state in this state.
  /// The copy will have this state as it's previous state.
  State pushState() {
    final State state = this.copy();
    state.prev = this;
    this.next = state;
    return state;
  }

  /// Gets the tile value at the given index.
  TileValue _dataAt(int index) => TileValue(this._data[index]);

  /// Gets the tile value at the given location.
  TileValue getValue(Location loc) {
    if (!loc.onBoard) return TileValue.OOB;
    return this._dataAt(loc.index);
  }

  /// Sets the tile value to the given value at the given location.
  bool setValue(Location loc, TileValue value) {
    if (!loc.onBoard) return false;
    this._data[loc.index] = value.value;
    return true;
  }

  /// Finds the location of the given value on the board.
  /// The movement flag is ignored in the values.
  Location findItem(TileValue value) {
    final TileValue item = value.item;
    for (int i = 0; i < this._data.length; ++i) {
      final TileValue other = this._dataAt(i).item;
      if (other == item) return Location.fromIndex(i);
    }
    return const Location(0, 0);
  }

  /// Applies the given movement to the current state.
  void applyMovement(Movement move) {
    // Get both values before any piece has been moved.
    final TileValue piece = this.getValue(move.source);
    TileValue? other;
    final otherSource = move.otherSource;
    if (otherSource != null) other = this.getValue(otherSource);
    // Clear out both locations.
    this.setValue(move.source, TileValue.Empty);
    if (other != null && otherSource != null) this.setValue(otherSource, TileValue.Empty);
    // Apply value to both locations.
    this.setValue(move.destination, piece | TileValue.Moved);
    final otherDestination = move.otherDestination;
    if ((other != null) && (otherDestination != null)) {
      this.setValue(otherDestination, other | TileValue.Moved);
      // else the that other piece was taken
    }
  }

  /// Determines the board condition for the given color.
  int condition(bool white) {
    // TODO: Determine Stalemate
    if (this.isChecked(white)) {
      if (!hasAnyMovements(white)) {
        return Checkmate;
      }
      return Check;
    }
    return Normal;
  }

  /// Determines if the king of the given color could be taken by the opponent, putting it in check.
  bool isChecked(bool white) {
    final TileValue value = TileValue.king(white);
    final Location loc = this.findItem(value);
    if (!loc.onBoard) return false;
    // Check for pawns
    final int pawnSide = white ? -1 : 1;
    if (this._hasValue(loc.offset(pawnSide, 1), !white, [TileValue.Pawn])) return true;
    if (this._hasValue(loc.offset(pawnSide, -1), !white, [TileValue.Pawn])) return true;
    // Check for knights
    if (this._hasValue(loc.offset(2, 1), !white, [TileValue.Knight])) return true;
    if (this._hasValue(loc.offset(2, -1), !white, [TileValue.Knight])) return true;
    if (this._hasValue(loc.offset(1, 2), !white, [TileValue.Knight])) return true;
    if (this._hasValue(loc.offset(-1, 2), !white, [TileValue.Knight])) return true;
    if (this._hasValue(loc.offset(-2, 1), !white, [TileValue.Knight])) return true;
    if (this._hasValue(loc.offset(-2, -1), !white, [TileValue.Knight])) return true;
    if (this._hasValue(loc.offset(1, -2), !white, [TileValue.Knight])) return true;
    if (this._hasValue(loc.offset(-1, -2), !white, [TileValue.Knight])) return true;
    // Check for queens, rooks, and bishop
    for (int i = 1; i < 8; ++i) {
      final Location checkLoc = loc.offset(0, i);
      if (this._hasValue(checkLoc, !white, [TileValue.Rook, TileValue.Queen])) return true;
      if (this._doneCheckingValues(checkLoc)) break;
    }
    for (int i = 1; i < 8; ++i) {
      final Location checkLoc = loc.offset(0, -i);
      if (this._hasValue(checkLoc, !white, [TileValue.Rook, TileValue.Queen])) return true;
      if (this._doneCheckingValues(checkLoc)) break;
    }
    for (int i = 1; i < 8; ++i) {
      final Location checkLoc = loc.offset(i, 0);
      if (this._hasValue(checkLoc, !white, [TileValue.Rook, TileValue.Queen])) return true;
      if (this._doneCheckingValues(checkLoc)) break;
    }
    for (int i = 1; i < 8; ++i) {
      final Location checkLoc = loc.offset(-i, 0);
      if (this._hasValue(checkLoc, !white, [TileValue.Rook, TileValue.Queen])) return true;
      if (this._doneCheckingValues(checkLoc)) break;
    }
    for (int i = 1; i < 8; ++i) {
      final Location checkLoc = loc.offset(i, i);
      if (this._hasValue(checkLoc, !white, [TileValue.Bishop, TileValue.Queen])) return true;
      if (this._doneCheckingValues(checkLoc)) break;
    }
    for (int i = 1; i < 8; ++i) {
      final Location checkLoc = loc.offset(i, -i);
      if (this._hasValue(checkLoc, !white, [TileValue.Bishop, TileValue.Queen])) return true;
      if (this._doneCheckingValues(checkLoc)) break;
    }
    for (int i = 1; i < 8; ++i) {
      final Location checkLoc = loc.offset(-i, i);
      if (this._hasValue(checkLoc, !white, [TileValue.Bishop, TileValue.Queen])) return true;
      if (this._doneCheckingValues(checkLoc)) break;
    }
    for (int i = 1; i < 8; ++i) {
      final Location checkLoc = loc.offset(-i, -i);
      if (this._hasValue(checkLoc, !white, [TileValue.Bishop, TileValue.Queen])) return true;
      if (this._doneCheckingValues(checkLoc)) break;
    }
    // Check for kings (to check that a king doesn't move into another kings space)
    if (this._hasValue(loc.offset(1, 1), !white, [TileValue.King])) return true;
    if (this._hasValue(loc.offset(1, 0), !white, [TileValue.King])) return true;
    if (this._hasValue(loc.offset(1, -1), !white, [TileValue.King])) return true;
    if (this._hasValue(loc.offset(0, -1), !white, [TileValue.King])) return true;
    if (this._hasValue(loc.offset(-1, -1), !white, [TileValue.King])) return true;
    if (this._hasValue(loc.offset(-1, 0), !white, [TileValue.King])) return true;
    if (this._hasValue(loc.offset(-1, 1), !white, [TileValue.King])) return true;
    if (this._hasValue(loc.offset(0, 1), !white, [TileValue.King])) return true;
    return false;
  }

  /// Determines if the given location has any of the given values in the given color.
  bool _hasValue(Location loc, bool white, List<TileValue> pieces) {
    if (loc.onBoard) {
      final TileValue value = this.getValue(loc);
      if (value.white == white) {
        final TileValue piece = value.piece;
        for (int i = pieces.length - 1; i >= 0; --i) {
          if (piece == pieces[i].piece) return true;
        }
      }
    }
    return false;
  }

  /// Determines if the given location is off the board or not empty.
  bool _doneCheckingValues(Location loc) => !(loc.onBoard && this.getValue(loc).empty);

  /// Gets all the possible movements for the given color.
  /// If a list of movements is provided, that list is added to.
  List<Movement> getAllMovements(bool white, [List<Movement>? movers]) {
    movers ??= [];
    for (int i = 0; i < 64; ++i) {
      final TileValue value = this._dataAt(i);
      if (!value.empty && value.white == white) this.getMovements(Location.fromIndex(i), movers);
    }
    return movers;
  }

  /// Gets the movement for the given location.
  /// If a list of movements is provided, that list is added to.
  List<Movement> getMovements(Location loc, [List<Movement>? movers]) {
    movers ??= [];
    this.forEachMovements(movers.add, loc);
    return movers;
  }

  /// Determines if the given color has any movements.
  bool hasAnyMovements(bool white) {
    for (int i = 0; i < 64; ++i) {
      final TileValue value = this._dataAt(i);
      if (!value.empty && value.white == white) {
        if (this.hasMovements(Location.fromIndex(i))) return true;
      }
    }
    return false;
  }

  /// Determines if the given location has any movements.
  bool hasMovements(Location loc) {
    bool hadMovement = false;
    this.forEachMovements((Movement move) {
      hadMovement = true;
    }, loc);
    return hadMovement;
  }

  /// Determines if the given movement is a valid possible move on this board.
  bool isValidMovement(Movement? move) {
    if (move == null) return false;
    bool movementFound = false;
    this.forEachMovements((Movement other) {
      if (movementFound) return;
      if ((other.source == move.source) &&
          (other.destination == move.destination) &&
          (other.otherSource == move.otherSource) &&
          (other.otherDestination == move.otherDestination)) movementFound = true;
    }, move.source);
    return movementFound;
  }

  /// Calls back any possible movements via the given handler for the given location.
  void forEachMovements(MovementCallback hndl, Location loc) {
    if (!loc.onBoard) return;
    final TileValue value = this.getValue(loc);
    // Prevent any movements from being suggested which will put current player into check.
    final MovementCallback filtered = (Movement move) {
      final State testState = this.copy();
      testState.applyMovement(move);
      if (!testState.isChecked(value.white)) hndl(move);
    };
    final TileValue piece = value.piece;
    if (piece == TileValue.Pawn) {
      this._pawnMovement(filtered, loc);
    } else if (piece == TileValue.Rook) {
      this._rookMovement(filtered, loc);
    } else if (piece == TileValue.Knight) {
      this._knightMovement(filtered, loc);
    } else if (piece == TileValue.Bishop) {
      this._bishopMovement(filtered, loc);
    } else if (piece == TileValue.Queen) {
      this._queenMovement(filtered, loc);
    } else if (piece == TileValue.King) this._kingMovement(filtered, loc);
  }

  /// Checks if the given movement is possible for move or take.
  /// If the movement is possible, it will be returned via the given handler.
  /// The given source is the location of the piece to check and the given
  /// delta row and delta column gets the destination location of the movement.
  /// Returns false if this was a movement, true if off board or a non empty tile.
  bool _movement(MovementCallback hndl, Location source, int deltaRow, int deltaColumn) {
    final Location dest = source.offset(deltaRow, deltaColumn);
    if (!dest.onBoard) return true;
    final TileValue srcValue = this.getValue(source);
    final TileValue destValue = this.getValue(dest);
    if (destValue.empty) {
      final String desc = '${srcValue.pieceName} move to $dest';
      hndl(Movement(desc, source, dest));
      return false;
    }
    if (destValue.opponent(srcValue.white)) {
      final String desc = '${srcValue.pieceName} take ${destValue.pieceName} at $dest';
      hndl(Movement(desc, source, dest, dest));
    }
    return true;
  }

  /// Checks for a given linear path has any possible moves or takes.
  /// If movements are possible, they will be returned via the given handler.
  /// The source is the starting location of the path and the given
  /// delta row and delta column gets the direction of the path.
  void _movementPath(MovementCallback hndl, Location source, int deltaRow, int deltaColumn) {
    for (int i = 1; i < 8; ++i) {
      if (this._movement(hndl, source, deltaRow * i, deltaColumn * i)) return;
    }
  }

  /// Gets the movement for the pawn at the given location.
  /// If movements are possible, they will be returned via the given handler.
  /// Pawns have the following movement constraints:
  /// - Forward is based on color of the pawn
  /// - Move straight forwards one square if vacant
  /// - If first move then can move forwards two squares if both are vacant
  /// - If there is an opponent forward diagonally from the pawn,
  ///   the pawn can capture that opponent
  /// - If there is an opponent pawn vertically from this pawn,
  ///   and on the opponent pawn's last move it moved two tiles as a first move,
  ///   then this pawn can move diagonally while capturing the opponents vertical pawn
  /// - See https://en.wikipedia.org/wiki/Pawn_(chess)
  void _pawnMovement(MovementCallback hndl, Location loc) {
    final TileValue value = this.getValue(loc);
    final bool white = value.white;
    final bool moved = value.moved;
    final int dir = white ? -1 : 1;
    // Check forward movement for vacancies
    Location dest = loc.offset(dir, 0);
    TileValue otherVal = this.getValue(dest);
    if (otherVal.empty) {
      String desc = 'Pawn move to $dest';
      hndl(Movement(desc, loc, dest));
      if (!moved) {
        dest = loc.offset(dir + dir, 0);
        otherVal = this.getValue(dest);
        if (otherVal.empty) {
          desc = 'Pawn move to $dest';
          hndl(Movement(desc, loc, dest));
        }
      }
    }
    // Check for opponents on the diagonally
    dest = loc.offset(dir, -1);
    otherVal = this.getValue(dest);
    if ((!otherVal.outOfBounds) && otherVal.opponent(white)) {
      final String desc = 'Pawn take ${otherVal.pieceName} at $dest';
      hndl(Movement(desc, loc, dest, dest));
    }
    dest = loc.offset(dir, 1);
    otherVal = this.getValue(dest);
    if ((!otherVal.outOfBounds) && otherVal.opponent(white)) {
      final String desc = 'Pawn take ${otherVal.pieceName} at $dest';
      hndl(Movement(desc, loc, dest, dest));
    }
    // Check for en passent condition
    final prev = this.prev;
    if ((prev != null) && (loc.row == (white ? 4 : 5))) {
      dest = loc.offset(dir, -1);
      if (dest.onBoard && this.getValue(dest).empty) {
        final Location oppLoc = loc.offset(0, -1);
        otherVal = this.getValue(oppLoc);
        if (otherVal.opponent(white)) {
          final TileValue lastVal = prev.getValue(oppLoc.offset(dir + dir, 0));
          if ((!lastVal.moved) && lastVal.sameItem(otherVal)) {
            final String desc = 'Pawn en passent ${otherVal.pieceName} at $dest';
            hndl(Movement(desc, loc, dest, oppLoc));
          }
        }
      }
      dest = loc.offset(dir, 1);
      if (dest.onBoard && this.getValue(dest).empty) {
        final Location oppLoc = loc.offset(0, 1);
        otherVal = this.getValue(oppLoc);
        if (otherVal.opponent(white)) {
          final TileValue lastVal = prev.getValue(oppLoc.offset(dir + dir, 0));
          if ((!lastVal.moved) && lastVal.sameItem(otherVal)) {
            final String desc = 'Pawn en passent ${otherVal.pieceName} at $dest';
            hndl(Movement(desc, loc, dest, oppLoc));
          }
        }
      }
    }
  }

  /// Gets the movement for the rook at the given location.
  /// If movements are possible, they will be returned via the given handler.
  /// Rooks have the following movement constraints:
  /// - They move horizontal or vertical any number of tiles until they reach a non-empty tile.
  ///   If that non-empty tile is an opponent that opponent can be taken.
  /// - If the rook hasn't been moved and the king of the same color hasn't been moved,
  ///   then check if there are only empty tiles between them. If the tiles are clear,
  ///   then the king and rook can both move as a castle movement.
  /// - See https://en.wikipedia.org/wiki/Rook_(chess)
  void _rookMovement(MovementCallback hndl, Location loc) {
    final TileValue value = this.getValue(loc);
    final bool white = value.white;
    final bool moved = value.moved;
    this._movementPath(hndl, loc, 0, 1);
    this._movementPath(hndl, loc, 0, -1);
    this._movementPath(hndl, loc, 1, 0);
    this._movementPath(hndl, loc, -1, 0);
    // Check for castle condition
    if (!moved) {
      final Location kingLoc = Location(white ? 8 : 1, 4);
      final TileValue kingVal = this.getValue(kingLoc);
      if ((kingVal.piece == TileValue.King) && !kingVal.moved) {
        bool allEmpty = true;
        final int dir = (loc.column > kingLoc.column) ? -1 : 1;
        for (int c = loc.column + dir; c != kingLoc.column; c += dir) {
          if (!this.getValue(Location(loc.row, c)).empty) {
            allEmpty = false;
            break;
          }
        }
        if (allEmpty) {
          const desc = 'Rook castles with King';
          final Location dest = Location(kingLoc.row, kingLoc.column - dir - dir);
          final Location otherDest = Location(dest.row, dest.column + dir);
          hndl(Movement(desc, loc, otherDest, kingLoc, dest));
        }
      }
    }
  }

  /// Gets the movement for the knight at the given location.
  /// If movements are possible, they will be returned via the given handler.
  /// Knights have the following movement constraints:
  /// - They can move two tiles vertically or horizontally and one tiles perpendicularly.
  ///   If the location is an opponent that opponent can be taken.
  /// - See https://en.wikipedia.org/wiki/Knight_(chess)
  void _knightMovement(MovementCallback hndl, Location loc) {
    this._movement(hndl, loc, 2, 1);
    this._movement(hndl, loc, 2, -1);
    this._movement(hndl, loc, 1, 2);
    this._movement(hndl, loc, -1, 2);
    this._movement(hndl, loc, -2, 1);
    this._movement(hndl, loc, -2, -1);
    this._movement(hndl, loc, 1, -2);
    this._movement(hndl, loc, -1, -2);
  }

  /// Gets the movement for the bishop at the given location.
  /// If movements are possible, they will be returned via the given handler.
  /// Bishops have the following movement constraints:
  /// - They move diagonally any number of tiles until they reach a non-empty tile.
  ///   If that non-empty tile is an opponent that opponent can be taken.
  /// - See https://en.wikipedia.org/wiki/Bishop_(chess)
  void _bishopMovement(MovementCallback hndl, Location loc) {
    this._movementPath(hndl, loc, 1, 1);
    this._movementPath(hndl, loc, 1, -1);
    this._movementPath(hndl, loc, -1, -1);
    this._movementPath(hndl, loc, -1, 1);
  }

  /// Gets the movement for the queen at the given location.
  /// If movements are possible, they will be returned via the given handler.
  /// Queen have the following movement constraints:
  /// - They move diagonally, horizontally, or vertically any number of tiles until they
  ///   reach a non-empty tile. If that non-empty tile is an opponent that opponent can be taken.
  /// - See https://en.wikipedia.org/wiki/Queen_(chess)
  void _queenMovement(MovementCallback hndl, Location loc) {
    this._movementPath(hndl, loc, 1, 1);
    this._movementPath(hndl, loc, 1, 0);
    this._movementPath(hndl, loc, 1, -1);
    this._movementPath(hndl, loc, 0, -1);
    this._movementPath(hndl, loc, -1, -1);
    this._movementPath(hndl, loc, -1, 0);
    this._movementPath(hndl, loc, -1, 1);
    this._movementPath(hndl, loc, 0, 1);
  }

  /// Gets the movement for the king at the given location.
  /// If movements are possible, they will be returned via the given handler.
  /// King have the following movement constraints:
  /// - They move diagonally, horizontally, or vertically only one tile.
  ///   If the tile is an opponent that opponent can be taken.
  /// - If the king hasn't moved and any of the rooks of the same color haven't moved,
  ///   then check if there are only empty tiles between them. If the tiles are clear,
  ///   then the king and rook can both move as a castle movement.
  /// - See https://en.wikipedia.org/wiki/King_(chess)
  void _kingMovement(MovementCallback hndl, Location loc) {
    final TileValue value = this.getValue(loc);
    final bool moved = value.moved;
    this._movement(hndl, loc, 1, 1);
    this._movement(hndl, loc, 1, 0);
    this._movement(hndl, loc, 1, -1);
    this._movement(hndl, loc, 0, -1);
    this._movement(hndl, loc, -1, -1);
    this._movement(hndl, loc, -1, 0);
    this._movement(hndl, loc, -1, 1);
    this._movement(hndl, loc, 0, 1);
    // Check for castle condition
    if (!moved) {
      for (int rookCol = 1; rookCol <= 8; rookCol += 7) {
        final Location rookLoc = Location(loc.row, rookCol);
        final TileValue rookVal = this.getValue(rookLoc);
        if ((rookVal.piece == TileValue.Rook) && !rookVal.moved) {
          bool allEmpty = true;
          final int dir = (loc.column > rookLoc.column) ? -1 : 1;
          for (int i = loc.column + dir; i != rookLoc.column; i += dir) {
            if (!this.getValue(Location(loc.row, i)).empty) {
              allEmpty = false;
              break;
            }
          }
          if (allEmpty) {
            const desc = 'King castles with Rook';
            final Location dest = Location(loc.row, loc.column + dir + dir);
            final Location otherDest = Location(dest.row, dest.column - dir);
            hndl(Movement(desc, loc, dest, rookLoc, otherDest));
          }
        }
      }
    }
  }

  /// Gets the string for this current state.
  /// `showLabels` indicates that the row and column numbers should be outputted.
  /// `showCount` indicates that the pieces should be outputted with the pieces' count.
  @override
  String toString({bool showLabels = true, bool showCount = false}) {
    bool hasMoved = false;
    for (int i = 0; i < 64; ++i) {
      if (this._dataAt(i).moved) {
        hasMoved = true;
        break;
      }
    }
    final StringGrid grid = StringGrid();
    grid.showLabels = showLabels;
    for (int r = 0; r < 8; ++r) {
      for (int c = 0; c < 8; ++c) {
        final int i = Location(r + 1, c + 1).index;
        final TileValue value = this._dataAt(i);
        final String str = value.toString(showMoved: hasMoved, showCount: showCount);
        grid.setCell(r, c, str);
      }
    }
    return grid.toString();
  }
}

/// A tool for building an evenly spaced multi-line string output
/// which is human readable for debugging and unit-testing.
class StringGrid {
  /// The number of rows in the grid.
  final int rows;

  /// The number of columns in the grid.
  final int columns;

  /// The content for each cell of the grid stored by column then row.
  List<String> _content;

  /// A flag to indicate if the row and column numbers should be shown.
  bool showLabels;

  /// Constructs a new empty string grid tool.
  StringGrid([this.rows = 8, this.columns = 8])
      : this._content = List.filled(rows * columns, ''),
        this.showLabels = false;

  /// Parses a set of strings which represents a grid.
  /// The columns in each given row are separated by a pipe character.
  factory StringGrid.parse(List<String> rows) {
    final List<List<String>> cells = [];
    int maxColumns = 0;
    for (int r = 0; r < rows.length; ++r) {
      final List<String> columns = rows[r].split('|');
      if (columns.length > maxColumns) maxColumns = columns.length;
      cells.add(columns);
    }
    final StringGrid grid = StringGrid(rows.length, maxColumns);
    for (int r = 0; r < cells.length; ++r) {
      final List<String> columns = cells[r];
      for (int c = 0; c < columns.length; ++c) {
        grid.setCell(r, c, columns[c]);
      }
    }
    return grid;
  }

  /// Gets the index into the grid data, or -1 if out of bounds.
  int _index(int row, int column) {
    final int index = row * this.rows + column;
    if ((index < 0) || (index >= this.rows * this.columns)) return -1;
    return index;
  }

  /// Sets the cell value in the grid at the given row and column.
  void setCell(int row, int column, String value) {
    final int index = this._index(row, column);
    if (index < 0) return;
    this._content[index] = value;
  }

  /// Gets the value of the grid cell at the given row and column.
  String getCell(int row, int column) {
    final int index = this._index(row, column);
    if (index < 0) return '';
    return this._content[index];
  }

  /// Determines the maximum width of all the cells.
  int _maxContentWidth() {
    final int count = this._content.length;
    if (count <= 0) return 0;
    int maxWidth = (this._content[0]).length;
    for (int i = 1; i < count; ++i) {
      final int width = (this._content[i]).length;
      if (width > maxWidth) maxWidth = width;
    }
    return maxWidth;
  }

  /// Gets the multi-lined grid output.
  @override
  String toString() {
    final List<String> rows = [];
    final int contentWidth = this._maxContentWidth();
    int rowLabelWidth = 0;
    if (this.showLabels) {
      rowLabelWidth = '${this.rows - 1}'.length + 1;
      String row = ''.padRight(rowLabelWidth + (contentWidth - 1) ~/ 2);
      for (int c = 0; c < this.columns; ++c) {
        // ignore: use_string_buffers
        row += ' ${c + 1}'.padRight(contentWidth + 1);
      }
      rows.add(row.trimRight());
    }
    for (int r = 0; r < this.rows; ++r) {
      String row = '';
      if (this.showLabels) row += '${r + 1}'.padRight(rowLabelWidth);
      for (int c = 0; c < this.columns; ++c) {
        if (this.showLabels || c != 0) row += '|';
        final int i = this._index(r, c);
        final String value = this._content[i];
        // ignore: use_string_buffers
        row += value.padRight(contentWidth);
      }
      if (this.showLabels) row += '|';
      rows.add(row);
    }
    return rows.join('\n');
  }
}

/// This is the value stored in a chess board location.
/// This may or no may contain information about a piece.
class TileValue {
  static final TileValue OOB = TileValue(-1);

  /// The value for when a tile location is out-of-bounds.
  static final TileValue Empty = TileValue(0x0000);

  /// The value of an empty tile.
  static final TileValue Moved = TileValue(0x1000);

  /// The mask which indicates a moved flag for a piece.
  static final TileValue Count = TileValue(0x000F);

  /// The mask for the count to differentiates between pieces.
  static final TileValue ItemMask = Color | Piece | Count;

  /// The mask for the values required to identify a piece.

  static final TileValue Black = TileValue(0x0100);

  /// The value for a black piece.
  static final TileValue White = TileValue(0x0200);

  /// The value for a white piece.
  static final TileValue Color = TileValue(0x0300);

  /// The mask for the values which indicate if the piece is black or white.

  static final TileValue Pawn = TileValue(0x0010);

  /// The value for a pawn.
  static final TileValue Rook = TileValue(0x0020);

  /// The value for a rook.
  static final TileValue Knight = TileValue(0x0030);

  /// The value for a knight.
  static final TileValue Bishop = TileValue(0x0040);

  /// The value for a bishop.
  static final TileValue Queen = TileValue(0x0050);

  /// The value for a queen.
  static final TileValue King = TileValue(0x0060);

  /// The value for a king.
  static final TileValue Piece = TileValue(0x00F0);

  /// The mask for the values which indicates the kind of piece.

  /// The raw value for the tile.
  final int value;

  /// Constructs a new tile value.
  TileValue(this.value);

  /// Constructs a value from a given color letter.
  /// 'W' for a white value, 'B' for a black value, otherwise empty.
  factory TileValue.colorFromLetter(String value) {
    switch (value) {
      case 'W':
        return White;
      case 'B':
        return Black;
      default:
        return Empty;
    }
  }

  /// Constructs a value from a given piece kind letter.
  /// 'P' for a pawn value, 'R' for a rook value, 'H' for a knight value,
  /// 'B' for a bishop value, 'Q' for a queen value, 'K' for a king value,
  /// otherwise empty.
  factory TileValue.pieceFromLetter(String value) {
    switch (value) {
      case 'P':
        return Pawn;
      case 'R':
        return Rook;
      case 'H':
        return Knight;
      case 'B':
        return Bishop;
      case 'Q':
        return Queen;
      case 'K':
        return King;
      default:
        return Empty;
    }
  }

  /// Constructs a tile value from the given string.
  /// If it starts with a plus sign, then the piece has moved. If there are piece values, it will
  /// be two characters, the first is the color and the second is the piece kind.
  /// An optional since digit number may be added to set the piece's count.
  factory TileValue.parse(String str) {
    if (str.isEmpty) return Empty;
    TileValue value = Empty;
    if (str[0] == '+') {
      value |= Moved;
      str = str.substring(1);
    }
    if (str.length < 2) return Empty;
    value |= TileValue.colorFromLetter(str[0]) | TileValue.pieceFromLetter(str[1]);
    if (str.length > 2) value |= TileValue(int.parse(str[2])).count;
    return value;
  }

  /// Constructs a non-moved piece with the given conditions.
  factory TileValue._piece(TileValue piece, bool white, int count) =>
      piece | (white ? White : Black) | (TileValue(count) & Count);

  factory TileValue.pawn(bool white, int count) => TileValue._piece(Pawn, white, count);

  /// Constructs a pawn value.
  factory TileValue.rook(bool white, int count) => TileValue._piece(Rook, white, count);

  /// Constructs a rook value.
  factory TileValue.knight(bool white, int count) => TileValue._piece(Knight, white, count);

  /// Constructs a knight value.
  factory TileValue.bishop(bool white, int count) => TileValue._piece(Bishop, white, count);

  /// Constructs a bishop value.
  factory TileValue.queen(bool white, [int count = 1]) => TileValue._piece(Queen, white, count);

  /// Constructs a queen value.
  factory TileValue.king(bool white) => TileValue._piece(King, white, 1);

  /// Constructs a king value.

  /// Creates a new tile value with is the OR of the two raw values.
  /// This is mainly used for adding conditions onto a tile value.
  TileValue operator |(TileValue other) => TileValue(this.value | other.value);

  /// Creates a new tile value with is the AND of the two raw values.
  /// This is mainly used to examine some condition of a tile value.
  TileValue operator &(TileValue other) => TileValue(this.value & other.value);

  /// Checks if the given value is a subset or equal to this value.
  /// It is used to determine if a specific value or set of values has been set to this value.
  bool has(TileValue value) => (this.value & value.value) == value.value;

  TileValue get color => TileValue(this.value & Color.value);

  /// Gets the color for this tile value.
  TileValue get piece => TileValue(this.value & Piece.value);

  /// Gets the piece kind from this tile value.
  TileValue get count => TileValue(this.value & Count.value);

  /// Gets the count value from this tile value.
  TileValue get item => TileValue(this.value & ItemMask.value);

  /// Gets the values required to identify a piece.

  bool get outOfBounds => this.value == OOB.value;

  /// Indicates if this value is out of bounds.
  bool get empty => this.value == Empty.value;

  /// Indicates if this value is empty.
  bool get moved => this.has(Moved);

  /// Indicates if this piece has been moved.
  bool get white => this.has(White);

  /// Indicates if this piece is white.
  bool get black => this.has(Black);

  /// Indicates if this piece is black.

  /// Indicates if this piece is an opponent of the given color.
  bool opponent(bool white) => (!this.empty) && (this.white != white);

  /// Indicates if these to values has the same color, piece kind, and count.
  bool sameItem(TileValue other) => (this.value & ItemMask.value) == (other.value & ItemMask.value);

  /// Indicates if these two tile values are equal.
  @override
  bool operator ==(Object other) {
    if (other is! TileValue) return false;
    return this.value == other.value;
  }

  /// Gets the letter for the given color.
  String get colorLetter {
    final TileValue color = this.color;
    if (color == Black) return 'B';
    if (color == White) return 'W';
    return ' ';
  }

  /// Gets the letter for the piece kind.
  String get pieceLetter {
    final TileValue piece = this.piece;
    if (piece == Pawn) return 'P';
    if (piece == Rook) return 'R';
    if (piece == Knight) return 'H';
    if (piece == Bishop) return 'B';
    if (piece == Queen) return 'Q';
    if (piece == King) return 'K';
    return ' ';
  }

  /// Gets the letter for the number of the piece.
  String get numberLetter {
    final TileValue count = this.count;
    if (count.empty) return ' ';
    return '${count.value}';
  }

  /// Gets the long name of this piece kind.
  String get pieceName {
    final TileValue piece = this.piece;
    if (piece == Pawn) return 'Pawn';
    if (piece == Rook) return 'Rook';
    if (piece == Knight) return 'Knight';
    if (piece == Bishop) return 'Bishop';
    if (piece == Queen) return 'Queen';
    if (piece == King) return 'King';
    return 'Empty';
  }

  /// Gets the short name for this whole value.
  @override
  String toString({
    bool showMoved = true,
    bool showCount = true,
  }) {
    if (this.empty) {
      return '';
    } else {
      String result = '';
      if (showMoved) {
        result += this.moved ? '+' : ' ';
      }
      result += this.colorLetter;
      result += this.pieceLetter;
      if (showCount) {
        result += this.numberLetter;
      }
      return result;
    }
  }

  @override
  int get hashCode => value.hashCode;
}
