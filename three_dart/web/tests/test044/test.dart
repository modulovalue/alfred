library three_dart.test.test044;

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
  final common.ShellPage page = common.ShellPage("Test 044")
    ..addLargeCanvas("testCanvas")
    ..addPar(["A test of the Material Lighting shader with fog. ", "This test is similar to test 005 except with fog."])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final three_dart.Entity obj = three_dart.Entity()
    ..shape = (shapes.cube()..adjustNormals())
    ..mover = movers.Rotator();

  final textures.Texture2D color = td.textureLoader.load2DFromFile("../resources/CtrlPnlColor.png");
  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..fog.color = math.Colors.white
    ..fog.start = 4.0
    ..fog.stop = 5.0
    ..lights.add(lights.Directional(mover: movers.Constant.vectorTowards(1.0, -1.0, -3.0), color: math.Color3.white()))
    ..emission.texture2D = td.textureLoader.load2DFromFile("../resources/CtrlPnlEmission.png")
    ..ambient.color = math.Color3(0.2, 0.2, 0.2)
    ..diffuse.color = math.Color3(0.8, 0.8, 0.8)
    ..ambient.texture2D = color
    ..diffuse.texture2D = color
    ..specular.texture2D = td.textureLoader.load2DFromFile("../resources/CtrlPnlSpecular.png")
    ..specular.shininess = 10.0;

  td.scene = scenes.EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = movers.Constant.translate(0.0, 0.0, 5.0);

  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
