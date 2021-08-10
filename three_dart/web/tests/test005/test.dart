library three_dart.test.test005;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/textures/textures.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 005")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "A test of the Material Lighting shader with 2D textures and directional ",
      "lighting. This test has texturing for emission, ambient, diffuse, and ",
      "specular. The same texture is used for ambient and diffuse. ",
      "The emission texture makes the lights on the panel glow. ",
      "The specular texture makes specific parts shiny and other parts not."
    ])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final three_dart.Entity obj = three_dart.Entity()
    ..shape = (cube()..adjustNormals())
    ..mover = Rotator();

  final Texture2D color = td.textureLoader.load2DFromFile("../resources/CtrlPnlColor.png");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(1.0, -1.0, -3.0), color: Color3.white()))
    ..emission.texture2D = td.textureLoader.load2DFromFile("../resources/CtrlPnlEmission.png")
    ..ambient.color = Color3(0.2, 0.2, 0.2)
    ..diffuse.color = Color3(0.8, 0.8, 0.8)
    ..ambient.texture2D = color
    ..diffuse.texture2D = color
    ..specular.texture2D = td.textureLoader.load2DFromFile("../resources/CtrlPnlSpecular.png")
    ..specular.shininess = 10.0;

  td.scene = EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);

  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
