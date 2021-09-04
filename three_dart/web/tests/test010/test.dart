library three_dart.test.test010;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart' as lights;
import 'package:three_dart/math/math.dart' as math;
import 'package:three_dart/movers/movers.dart' as movers;
import 'package:three_dart/scenes/scenes.dart' as scenes;
import 'package:three_dart/shapes/shapes.dart' as shapes;
import 'package:three_dart/techniques/techniques.dart' as techniques;

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 010")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "A test of the Material Lighting shader with solid color and ",
      "a directional light with a cube texture bump map."
    ])
    ..addPar(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final three_dart.Entity obj = three_dart.Entity()
    ..shape = shapes.cube()
    ..mover = (movers.Group()
      ..add(movers.UserRotator(input: td.userInput, invertY: true))
      ..add(movers.UserRoller(input: td.userInput, ctrl: true))
      ..add(movers.UserZoom(input: td.userInput)));
  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..lights.add(lights.Directional(mover: movers.Constant.vectorTowards(1.0, 1.0, -3.0), color: math.Color3.white()))
    ..ambient.color = math.Color3(0.0, 0.0, 1.0)
    ..diffuse.color = math.Color3(0.0, 1.0, 0.0)
    ..specular.color = math.Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0
    ..bump.textureCube = td.textureLoader.loadCubeFromPath("../resources/diceBumpMap");
  td.scene = scenes.EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = movers.Constant.translate(0.0, 0.0, 5.0);
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
