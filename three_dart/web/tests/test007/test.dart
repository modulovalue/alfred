library three_dart.test.test007;

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
  final common.ShellPage page = common.ShellPage("Test 007")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "A test of the Material Lighting shader with bumpy 2D textures and ",
      "a directional light. The lighting and bump is being applied to ",
      "ambient, diffuse, and specular 2D texturing."
    ])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final three_dart.Entity obj = three_dart.Entity()
    ..shape = cube()
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput, invertY: true))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));

  final Texture2D color = td.textureLoader.load2DFromFile("../resources/ScrewColor.png");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(0.0, 0.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.2, 0.2, 0.2)
    ..diffuse.color = Color3(0.8, 0.8, 0.8)
    ..ambient.texture2D = color
    ..diffuse.texture2D = color
    ..bump.texture2D = td.textureLoader.load2DFromFile("../resources/ScrewBumpMap.png")
    ..specular.color = Color3.white()
    ..specular.texture2D = td.textureLoader.load2DFromFile("../resources/ScrewSpecular.png")
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
