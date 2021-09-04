library three_dart.test.test039;

import 'dart:async';

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart' as lights;
import 'package:three_dart/math/math.dart' as math;
import 'package:three_dart/movers/movers.dart' as movers;
import 'package:three_dart/scenes/scenes.dart' as scenes;
import 'package:three_dart/shapes/shapes.dart' as shapes;
import 'package:three_dart/techniques/techniques.dart' as techniques;
import 'package:three_dart/textures/textures.dart' as textures;

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 039")
    ..addLargeCanvas("testCanvas")
    ..addPar(["Test of an animated texture on a square."])
    ..addPar(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final three_dart.Entity obj = three_dart.Entity()
    ..shape = (shapes.cube()..adjustNormals())
    ..mover = movers.Rotator();
  final textures.Texture2DChanger color = textures.Texture2DChanger(
    textures: [
      td.textureLoader.load2DFromFile("../resources/diceColor/posx.png"),
      td.textureLoader.load2DFromFile("../resources/diceColor/posz.png"),
      td.textureLoader.load2DFromFile("../resources/diceColor/negx.png"),
      td.textureLoader.load2DFromFile("../resources/diceColor/negy.png"),
      td.textureLoader.load2DFromFile("../resources/diceColor/posy.png"),
      td.textureLoader.load2DFromFile("../resources/diceColor/negz.png"),
    ],
  );
  Timer.periodic(const Duration(milliseconds: 500), (_) => color.nextTexture());
  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..lights.add(lights.Directional(
        mover: movers.Constant.vectorTowards(1.0, -1.0, -3.0), color: math.Color3.white()))
    ..ambient.color = math.Color3(0.2, 0.2, 0.2)
    ..diffuse.color = math.Color3(0.8, 0.8, 0.8)
    ..ambient.texture2D = color
    ..diffuse.texture2D = color;
  td.scene = scenes.EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = movers.Constant.translate(0.0, 0.0, 5.0);
  common.showFPS(td);
}
