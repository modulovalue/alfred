library three_dart.test.test006;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart' as lights;
import 'package:three_dart/math/math.dart' as math;
import 'package:three_dart/movers/movers.dart' as movers;
import 'package:three_dart/scenes/scenes.dart' as scenes;
import 'package:three_dart/shapes/shapes.dart' as shapes;
import 'package:three_dart/techniques/techniques.dart' as techniques;

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 006")
    ..addLargeCanvas("testCanvas")
    ..addPar(["A test of the Material Lighting shader with a bumpy 2D texture and ",
      "a directional light. Select different bump maps for the test. ",
      "The additional lines are part of shape inspection."])
    ..addControlBoxes(["bumpMaps"])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final shapes.Shape shape = shapes.cube();

  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..lights.add(lights.Directional(
        mover: movers.Constant.vectorTowards(0.0, 0.0, -1.0),
        color: math.Color3.white()))
    ..ambient.color = math.Color3(0.0, 0.0, 1.0)
    ..diffuse.color = math.Color3(0.0, 1.0, 0.0)
    ..specular.color = math.Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;

  final three_dart.Entity objTech = three_dart.Entity()
    ..shape = shape
    ..technique = tech;

  final three_dart.Entity objInspecTech = three_dart.Entity()
    ..shape = shape
    ..technique = (techniques.Inspection()
        ..vectorScale = 0.4
        ..showWireFrame = true
        ..showAxis = true
        ..showNormals = true
        ..showBinormals = true);

  final three_dart.Entity group = three_dart.Entity()
    ..children.add(objInspecTech)
    ..children.add(objTech)
    ..mover = (movers.Group()
      ..add(movers.UserRotator(input: td.userInput, invertY: true))
      ..add(movers.UserRoller(input: td.userInput, ctrl: true))
      ..add(movers.UserZoom(input: td.userInput)));

  td.scene = scenes.EntityPass()
    ..children.add(group)
    ..camera?.mover = movers.Constant.translate(0.0, 0.0, 5.0);

  common.Texture2DGroup("bumpMaps", (String fileName) {
    tech.bump.texture2D = td.textureLoader.load2DFromFile(fileName);
  })
    ..add("../resources/BumpMap1.png", true)
    ..add("../resources/BumpMap2.png")
    ..add("../resources/BumpMap3.png")
    ..add("../resources/BumpMap4.png")
    ..add("../resources/BumpMap5.png")
    ..add("../resources/ScrewBumpMap.png")
    ..add("../resources/CtrlPnlBumpMap.png");

  td.postrender.once((_){
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
