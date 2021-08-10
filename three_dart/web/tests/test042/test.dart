library three_dart.test.test042;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart' as lights;
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart' as scenes;
import 'package:three_dart/shaders/shaders.dart' as shaders;
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/textures/textures.dart';
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void addLightBall(MaterialLight tech, scenes.EntityPass pass, double r, double g, double b, double yaw,
    double pitch, double roll) {
  final Color3 clr = Color3(r, g, b);

  final Group mover = Group()
    ..add(Constant.translate(0.0, 0.0, 2.0))
    ..add(Rotator(deltaYaw: yaw, deltaPitch: pitch, deltaRoll: roll));

  final three_dart.Entity obj = three_dart.Entity()
    ..mover = (Group()..add(Constant.scale(0.1, 0.1, 0.1))..add(mover))
    ..shape = sphere()
    ..technique = (MaterialLight()..emission.color = clr);

  final lights.Point point = lights.Point(mover: mover, color: clr, attenuation0: 1.0, attenuation1: 0.5, attenuation2: 0.15);

  tech.lights.add(point);
  pass.children.add(obj);
}

void main() {
  common.ShellPage("Test 042")
    ..addLargeCanvas("testCanvas")
    ..addPar(["Test of the Blum effect technique."])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final Group mover = Group()
    ..add(Rotator(deltaYaw: 0.0, deltaPitch: 0.0, deltaRoll: 0.5))
    ..add(Constant.rotateX(PI_2));

  final three_dart.Entity bulbObj = three_dart.Entity()
    ..mover = mover
    ..shape = sphere(radius: 0.6)
    ..technique = (MaterialLight()..emission.color = Color3.white());

  final TextureCube shadeTxt = td.textureLoader.loadCubeFromFiles(
      "../resources/StarsCan.png",
      "../resources/StarsCan.png",
      "../resources/StarsCan.png",
      "../resources/StarsCan.png",
      "../resources/StarsCan.png",
      "../resources/StarsCan.png");
  final three_dart.Entity shadeObj = three_dart.Entity()
    ..mover = mover
    ..shape = cylinder(topRadius: 1.2, bottomRadius: 1.2, sides: 16)
    ..technique = (MaterialLight()
      ..diffuse.textureCube = shadeTxt
      ..alpha.textureCube = shadeTxt);
  final three_dart.Entity shadeInsideObj = three_dart.Entity()
    ..mover = mover
    ..shape = (cylinder(topRadius: 1.2, bottomRadius: 1.2, sides: 16)..flip())
    ..technique = (MaterialLight()
      ..ambient.color = Color3.gray(0.6)
      ..diffuse.textureCube = shadeTxt
      ..alpha.textureCube = shadeTxt);

  final TextureCube lightTxt = td.textureLoader.loadCubeFromFiles("../resources/Stars.png", "../resources/Stars.png",
      "../resources/Stars.png", "../resources/Stars.png", "../resources/Stars.png", "../resources/Stars.png");
  final lights.Point lightPoint =
      lights.Point(mover: mover, texture: lightTxt, attenuation0: 0.5, attenuation1: 0.05, attenuation2: 0.025);

  final three_dart.Entity room = three_dart.Entity()
    ..mover = Constant.scale(10.0, 10.0, 10.0)
    ..shape = (cube()..flip());

  final Group camMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(input: td.userInput, ctrl: true))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));

  final MaterialLight colorTech = MaterialLight()
    ..lights.add(lightPoint)
    ..ambient.color = Color3.gray(0.05)
    ..diffuse.color = Color3.gray(0.7);

  final BackTarget colorTarget = BackTarget(autoResize: true);
  final scenes.EntityPass colorPass = scenes.EntityPass()
    ..technique = colorTech
    ..children.add(room)
    ..children.add(bulbObj)
    ..children.add(shadeInsideObj)
    ..children.add(shadeObj)
    ..camera?.mover = camMover
    ..target = colorTarget;

  final BackTarget brightTarget = BackTarget(autoResize: true, clearColor: false);
  final TextureLayout brightTrimTech = TextureLayout()
    ..entries.add(TextureLayoutEntry(
        texture: colorTarget.colorTexture,
        colorMatrix: Matrix4(3.0, 3.0, 3.0, -8.0, 3.0, 3.0, 3.0, -8.0, 3.0, 3.0, 3.0, -8.0, 0.0, 0.0, 0.0, 1.0)));
  final scenes.CoverPass brightTrim = scenes.CoverPass()
    ..target = brightTarget
    ..technique = brightTrimTech;

  BackTarget bloomTarget = brightTarget;
  final scenes.Compound bloomScene = scenes.Compound();

  for (int i = 0; i < 4; ++i) {
    final BackTarget blurTarget =
        BackTarget(autoResize: true, clearColor: false, autoResizeScalarX: 0.25, autoResizeScalarY: 0.25);
    final scenes.GaussianBlur blurPass = scenes.GaussianBlur(
        target: blurTarget,
        blurAdj: Vector4(10.0, 10.0, 10.0, 1.0),
        colorTxt: bloomTarget.colorTexture,
        blurTxt: brightTarget.colorTexture);
    bloomTarget = blurTarget;
    bloomScene.add(blurPass);
  }

  final TextureLayout layoutTech = TextureLayout()
    ..blend = shaders.ColorBlendType.Additive
    ..entries.add(TextureLayoutEntry(texture: colorTarget.colorTexture))
    ..entries.add(TextureLayoutEntry(texture: bloomTarget.colorTexture));
  final scenes.CoverPass layout = scenes.CoverPass()..technique = layoutTech;

  td.scene = scenes.Compound(passes: [colorPass, brightTrim, bloomScene, layout]);

  common.showFPS(td);
}
