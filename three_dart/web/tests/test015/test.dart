library three_dart.test.test015;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/textures/textures.dart';
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 015")
    ..addLargeCanvas("testCanvas")
    ..addPar(["Test of Material Lighting shader with bump mapping, reflections, refractions."])
    ..addControlBoxes(["bumpMaps", "controls"])
    ..addPar(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final FrontTarget target = FrontTarget()..clearColor = false;
  final three_dart.Entity obj = three_dart.Entity()..shape = cube();
  final TextureCube environment = td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(-1.0, -1.0, -1.0)))
    ..ambient.color = Color3(0.1, 0.1, 0.1)
    ..diffuse.color = Color3(0.1, 0.1, 0.1)
    ..specular.color = Color3.black()
    ..specular.shininess = 10.0
    ..environment = environment
    ..refraction.deflection = 0.6
    ..refraction.color = Color3(0.2, 0.3, 1.0)
    ..reflection.color = Color3(0.6, 0.6, 0.6);
  final Group mover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(input: td.userInput, ctrl: true))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective camera = Perspective(mover: mover);
  final CoverPass skybox = CoverPass.skybox(environment)
    ..target = target
    ..camera = camera;
  final EntityPass pass = EntityPass()
    ..camera = camera
    ..technique = tech
    ..target = target
    ..children.add(obj);
  (pass.target as FrontTarget?)!.clearColor = false;
  td.scene = Compound(passes: [skybox, pass]);
  common.RadioGroup("controls")
    ..add("Silver", () {
      tech
        ..ambient.color = Color3.gray(0.1)
        ..diffuse.color = Color3.gray(0.2)
        ..refraction.color = Color3.black()
        ..reflection.color = Color3.white();
    }, true)
    ..add("Gold", () {
      tech
        ..ambient.color = Color3(0.11, 0.11, 0.1)
        ..diffuse.color = Color3(0.21, 0.21, 0.2)
        ..refraction.color = Color3.black()
        ..reflection.color = Color3(1.0, 0.9, 0.5);
    })
    ..add("Glass", () {
      tech
        ..ambient.color = Color3.gray(0.1)
        ..diffuse.color = Color3.gray(0.1)
        ..refraction.deflection = 0.4
        ..refraction.color = Color3.gray(0.6)
        ..reflection.color = Color3.gray(0.4);
    })
    ..add("Blue Glass", () {
      tech
        ..ambient.color = Color3.gray(0.1)
        ..diffuse.color = Color3.gray(0.1)
        ..refraction.deflection = 0.4
        ..refraction.color = Color3(0.2, 0.3, 1.0)
        ..reflection.color = Color3.gray(0.3);
    })
    ..add("Water Bubble", () {
      tech
        ..ambient.color = Color3.gray(0.1)
        ..diffuse.color = Color3.gray(0.1)
        ..refraction.deflection = 0.6
        ..refraction.color = Color3.gray(0.8)
        ..reflection.color = Color3.gray(0.2);
    })
    ..add("No Reflection", () {
      tech
        ..ambient.color = Color3.gray(0.1)
        ..diffuse.color = Color3.gray(0.1)
        ..refraction.deflection = 0.6
        ..refraction.color = Color3.white()
        ..reflection.color = Color3.black();
    })
    ..add("Pink Distort", () {
      tech
        ..ambient.color = Color3.gray(0.1)
        ..diffuse.color = Color3.gray(0.1)
        ..refraction.deflection = 0.9
        ..refraction.color = Color3(1.0, 0.8, 0.8)
        ..reflection.color = Color3.black();
    })
    ..add("Cloak", () {
      tech
        ..ambient.color = Color3.black()
        ..diffuse.color = Color3.gray(0.1)
        ..refraction.deflection = 0.99
        ..refraction.color = Color3.gray(0.95)
        ..reflection.color = Color3.black();
    })
    ..add("White and Shiny", () {
      tech
        ..ambient.color = Color3.gray(0.3)
        ..diffuse.color = Color3.gray(0.5)
        ..refraction.color = Color3.black()
        ..reflection.color = Color3.gray(0.3);
    });
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
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
