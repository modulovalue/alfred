library three_dart.test.test012;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/textures.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 012")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "A test of the Material Lighting shader with cube textures and ",
      "a directional light with a cube texture bump map."
    ])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final three_dart.Entity obj = three_dart.Entity()
    ..shape = cube()
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput, invertY: true))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));
  final TextureCube color = td.textureLoader.loadCubeFromPath("../resources/diceColor");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(1.0, 1.0, -3.0), color: Color3.white()))
    ..ambient.color = Color3(0.2, 0.2, 0.2)
    ..diffuse.color = Color3(0.8, 0.8, 0.8)
    ..specular.color = Color3(0.7, 0.7, 0.7)
    ..ambient.textureCube = color
    ..diffuse.textureCube = color
    ..specular.textureCube = td.textureLoader.loadCubeFromPath("../resources/diceSpecular")
    ..specular.shininess = 10.0
    ..bump.textureCube = td.textureLoader.loadCubeFromPath("../resources/diceBumpMap");
  td.scene = EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.show_fps(td);
}
