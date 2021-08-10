library three_dart.test.test000;

import 'dart:async' as asy;
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:typed_data' as data;

import 'package:three_dart/collisions/collisions.dart';
import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/data/data.dart';
import 'package:three_dart/debug/debug.dart';
import 'package:three_dart/math/math.dart' as math;
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart' as common;
import '../../examples/chess/game.dart' as chess;
import '../../examples/craft/main.dart' as craft;

part 'bench.dart';

part 'chess.dart';

part 'collisions.dart';

part 'craft.dart';

part 'matrix2.dart';

part 'matrix3.dart';

part 'matrix4.dart';

part 'region2.dart';

part 'region3.dart';

part 'technique.dart';

part 'test_tools.dart';

part 'vertex_type.dart';

void main() {
  final html.DivElement elem = html.DivElement();
  final TestManager tests = TestManager(elem);
  addBench(tests);
  addVertexTypeTests(tests);
  addMatrix2Tests(tests);
  addMatrix3Tests(tests);
  addMatrix4Tests(tests);
  addRegion2Tests(tests);
  addRegion3Tests(tests);
  addCollisionTests(tests);
  addTechniqueTests(tests);
  addCraftTests(tests);
  addChessTests(tests);
  common.ShellPage("Unit-tests", false)
    ..addElem(elem)
    ..addPar(["«[Back to Tests|../]"]);
}
