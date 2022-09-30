library three_dart.test.test041;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart' as lights;
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart' as techniques;
import 'package:three_dart/views.dart';

import '../../common/common.dart' as common;

void addLightBall(techniques.MaterialLight tech, EntityPass pass, double r, double g, double b, double yaw,
    double pitch, double roll) {
  final Color3 clr = Color3(r, g, b);
  final Group mover = Group()
    ..add(Constant.translate(0.0, 0.0, 2.0))
    ..add(Rotator(deltaYaw: yaw, deltaPitch: pitch, deltaRoll: roll));
  final three_dart.Entity obj = three_dart.Entity()
    ..mover = (Group()..add(Constant.scale(0.1, 0.1, 0.1))..add(mover))
    ..shape = sphere()
    ..technique = (techniques.MaterialLight()..emission.color = clr);
  final lights.Point point = lights.Point(mover: mover, color: clr, attenuation0: 1.0, attenuation1: 0.5, attenuation2: 0.15);
  tech.lights.add(point);
  pass.children.add(obj);
}

void main() {
  final common.ShellPage page = common.ShellPage("Test 041")
    ..addLargeCanvas("testCanvas")
    ..add_par(["Test of the Gaussian blur technique with a solid blur value for the whole image."])
    ..addControlBoxes(["blurValue"])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final Group mover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective userCamera = Perspective(mover: mover);
  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..ambient.color = Color3.gray(0.3)
    ..diffuse.color = Color3.gray(0.8)
    ..diffuse.texture2D = td.textureLoader.load2DFromFile("../resources/Test.png");
  final BackTarget backTarget = BackTarget(autoResize: true, clearColor: false);
  final EntityPass colorPass = EntityPass()
    ..children.add(three_dart.Entity(shape: cube()))
    ..technique = tech
    ..target = backTarget
    ..camera = userCamera;
  final CoverPass skybox =
      CoverPass.skybox(td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"))
        ..target = backTarget
        ..camera = userCamera;
  final GaussianBlur blurPass = GaussianBlur(colorTxt: backTarget.colorTexture);
  td.scene = Compound(passes: [skybox, colorPass, blurPass]);
  final setBlur = (double blurValue) {
    blurPass.blurValue = blurValue;
  };
  common.RadioGroup("blurValue")
    ..add("0.0", () {
      setBlur(0.0);
    }, true)
    ..add("0.1", () {
      setBlur(0.1);
    })
    ..add("0.2", () {
      setBlur(0.2);
    })
    ..add("0.3", () {
      setBlur(0.3);
    })
    ..add("0.4", () {
      setBlur(0.4);
    })
    ..add("0.5", () {
      setBlur(0.5);
    })
    ..add("0.6", () {
      setBlur(0.6);
    })
    ..add("0.7", () {
      setBlur(0.7);
    })
    ..add("0.8", () {
      setBlur(0.8);
    })
    ..add("0.9", () {
      setBlur(0.9);
    })
    ..add("1.0", () {
      setBlur(1.0);
    });
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, blurPass.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, blurPass.fragmentSourceCode.split("\n"));
  });
  common.show_fps(td);
}
