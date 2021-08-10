library three_dart.test.test013;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 013")
    ..addLargeCanvas("testCanvas")
    ..addPar(["Test of sky box and cover pass."])
    ..addPar(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final Group secondMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective userCamera = Perspective(mover: secondMover);
  final FrontTarget target = FrontTarget()..clearColor = false;
  final three_dart.Entity obj = three_dart.Entity()..shape = toroid();
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(0.0, -1.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.0, 0.0, 1.0)
    ..diffuse.color = Color3(0.0, 1.0, 0.0)
    ..specular.color = Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;
  final CoverPass skybox =
      CoverPass.skybox(td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"))
        ..target = target
        ..camera = userCamera;
  final EntityPass pass = EntityPass()
    ..camera = userCamera
    ..technique = tech
    ..target = target
    ..children.add(obj);
  td.scene = Compound(passes: [skybox, pass]);
  td.postrender.once((final _) {
    final skyTech = (skybox.technique as Skybox?)!;
    page
      ..addCode("Vertex Shader for Skybox", "glsl", 0, skyTech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader for Skybox", "glsl", 0, skyTech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
