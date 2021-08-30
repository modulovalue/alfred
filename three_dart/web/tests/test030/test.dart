library three_dart.test.test030;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 030")
    ..addLargeCanvas("testCanvas")
    ..addPar(["A test of the Normal shader for dynamically rendering normal maps."])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final three_dart.Entity obj = three_dart.Entity()
    ..shape = cube()
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));

  final Normal tech = Normal()
    ..bumpyTextureCube = td.textureLoader.loadCubeFromPath("../resources/diceBumpMap");

  final FrontTarget target = FrontTarget()..color = Color4(0.5, 0.5, 1.0, 1.0);

  final EntityPass pass = EntityPass()
    ..technique = tech
    ..target = target
    ..children.add(obj)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  td.scene = pass;

  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}