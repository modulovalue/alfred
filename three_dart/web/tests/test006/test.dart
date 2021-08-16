import 'package:three_dart/core/core.dart';
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart';

void main() {
  final page = ShellPage("Test 006")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "A test of the Material Lighting shader with a bumpy 2D texture and ",
      "a directional light. Select different bump maps for the test. ",
      "The additional lines are part of shape inspection."
    ])
    ..addControlBoxes(["bumpMaps"])
    ..addPar(["«[Back to Tests|../]"]);
  final td = ThreeDart.fromId("testCanvas");
  final shape = cube();
  final tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(0.0, 0.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.0, 0.0, 1.0)
    ..diffuse.color = Color3(0.0, 1.0, 0.0)
    ..specular.color = Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;
  final objTech = Entity()
    ..shape = shape
    ..technique = tech;
  final objInspecTech = Entity()
    ..shape = shape
    ..technique = (Inspection()
      ..vectorScale = 0.4
      ..showWireFrame = true
      ..showAxis = true
      ..showNormals = true
      ..showBinormals = true);
  final group = Entity()
    ..children.add(objInspecTech)
    ..children.add(objTech)
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput, invertY: true))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));
  td.scene = EntityPass()
    ..children.add(group)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  Texture2DGroup(
    "bumpMaps",
    (final fileName) => tech.bump.texture2D = td.textureLoader.load2DFromFile(fileName),
  )
    ..add("../resources/BumpMap1.png", true)
    ..add("../resources/BumpMap2.png")
    ..add("../resources/BumpMap3.png")
    ..add("../resources/BumpMap4.png")
    ..add("../resources/BumpMap5.png")
    ..add("../resources/ScrewBumpMap.png")
    ..add("../resources/CtrlPnlBumpMap.png");
  td.postrender.once(
    (final _) => page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n")),
  );
  showFPS(td);
}
