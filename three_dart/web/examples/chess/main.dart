import 'dart:async';

import '../../common/common.dart' as common;
import 'game.dart' as game;
import 'graphics.dart' as graphics;

/// Starts up the 3Dart Chess example
void main() {
  common.ShellPage("3Dart Chess")
    ..add_par(["This example is in development and may still have a few issues and glitches."])
    ..addLargeCanvas("targetCanvas")
    ..addControlBoxes(["buttons"])
    ..add_header(1, "About")
    ..add_par([
      "Click and drag to see the board from different angles. ",
      "Click without dragging to select a piece, unselect a piece, or pick which movement should be made. ",
      "The game will start with white's turn."
    ])
    ..add_par([
      "3Dart Chess is an example of how [3Dart|https://github.com/Grant-Nelson/three_dart] can be used ",
      "to create simple browser driven video games. ",
      "This example has no server backing it so currently there is no networked two player mode. ",
      "It would take very little to turn this into a simple online game."
    ])
    ..add_par(["«[Back to Examples List|../../]"])
    ..add_header(1, "Help wanted")
    ..add_par([
      "There is still much to be done, many cool new features, and several little bugs. ",
      "If you would like to contribute to this example, have an idea, find a bug, or just want ",
      "to learn more about it, check out the ",
      "[source code|https://github.com/Grant-Nelson/three_dart/tree/master/web/examples/chess]."
    ])
    ..add_par([
      "There are tons of ways to contribute. You could even start your own example. ",
      "See the [3Dart Project|https://github.com/Grant-Nelson/three_dart] for more."
    ]);
  final game.Game chess = game.Game();
  // This is deferred so that if loading takes a while the page is at least loaded.
  Timer.run(() => graphics.startGraphics(chess));
}
