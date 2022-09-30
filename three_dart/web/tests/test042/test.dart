library three_dart.test.test042;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart' as lights;
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart' as scenes;
import 'package:three_dart/shaders.dart' as shaders;
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/views.dart';

import '../../common/common.dart';

void addLightBall(
  final MaterialLight tech,
  final scenes.EntityPass pass,
  final double r,
  final double g,
  final double b,
  final double yaw,
  final double pitch,
  final double roll,
) {
  final clr = Color3(r, g, b);
  final mover = Group()
    ..add(Constant.translate(0.0, 0.0, 2.0))
    ..add(Rotator(deltaYaw: yaw, deltaPitch: pitch, deltaRoll: roll));
  final obj = three_dart.Entity()
    ..mover = (Group()..add(Constant.scale(0.1, 0.1, 0.1))..add(mover))
    ..shape = sphere()
    ..technique = (MaterialLight()..emission.color = clr);
  final point = lights.Point(
    mover: mover,
    color: clr,
    attenuation0: 1.0,
    attenuation1: 0.5,
    attenuation2: 0.15,
  );
  tech.lights.add(point);
  pass.children.add(obj);
}

void main() {
  ShellPage("Test 042")
    ..addLargeCanvas("testCanvas")
    ..add_par(["Test of the Blum effect technique."])
    ..add_par(["«[Back to Tests|../]"]);
  final td = three_dart.ThreeDart.fromId("testCanvas");
  final mover = Group()..add(Rotator(deltaYaw: 0.0, deltaPitch: 0.0, deltaRoll: 0.5))..add(Constant.rotateX(PI_2));
  final bulbObj = three_dart.Entity()
    ..mover = mover
    ..shape = sphere(radius: 0.6)
    ..technique = (MaterialLight()..emission.color = Color3.white());
  final shadeTxt = td.textureLoader.loadCubeFromFiles(
    "../resources/StarsCan.png",
    "../resources/StarsCan.png",
    "../resources/StarsCan.png",
    "../resources/StarsCan.png",
    "../resources/StarsCan.png",
    "../resources/StarsCan.png",
  );
  final shadeObj = three_dart.Entity()
    ..mover = mover
    ..shape = cylinder(topRadius: 1.2, bottomRadius: 1.2, sides: 16)
    ..technique = (MaterialLight()
      ..diffuse.textureCube = shadeTxt
      ..alpha.textureCube = shadeTxt);
  final shadeInsideObj = three_dart.Entity()
    ..mover = mover
    ..shape = (cylinder(topRadius: 1.2, bottomRadius: 1.2, sides: 16)..flip())
    ..technique = (MaterialLight()
      ..ambient.color = Color3.gray(0.6)
      ..diffuse.textureCube = shadeTxt
      ..alpha.textureCube = shadeTxt);
  final lightTxt = td.textureLoader.loadCubeFromFiles("../resources/Stars.png", "../resources/Stars.png",
      "../resources/Stars.png", "../resources/Stars.png", "../resources/Stars.png", "../resources/Stars.png");
  final lightPoint = lights.Point(
    mover: mover,
    texture: lightTxt,
    attenuation0: 0.5,
    attenuation1: 0.05,
    attenuation2: 0.025,
  );
  final room = three_dart.Entity()
    ..mover = Constant.scale(10.0, 10.0, 10.0)
    ..shape = (cube()..flip());
  final camMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(input: td.userInput, ctrl: true))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final colorTech = MaterialLight()
    ..lights.add(lightPoint)
    ..ambient.color = Color3.gray(0.05)
    ..diffuse.color = Color3.gray(0.7);
  final colorTarget = BackTarget(autoResize: true);
  final colorPass = scenes.EntityPass()
    ..technique = colorTech
    ..children.add(room)
    ..children.add(bulbObj)
    ..children.add(shadeInsideObj)
    ..children.add(shadeObj)
    ..camera?.mover = camMover
    ..target = colorTarget;
  final brightTarget = BackTarget(
    autoResize: true,
    clearColor: false,
  );
  final brightTrimTech = TextureLayout()
    ..entries.add(
      TextureLayoutEntry(
        texture: colorTarget.colorTexture,
        colorMatrix: Matrix4(3.0, 3.0, 3.0, -8.0, 3.0, 3.0, 3.0, -8.0, 3.0, 3.0, 3.0, -8.0, 0.0, 0.0, 0.0, 1.0),
      ),
    );
  final brightTrim = scenes.CoverPass()
    ..target = brightTarget
    ..technique = brightTrimTech;
  BackTarget bloomTarget = brightTarget;
  final bloomScene = scenes.Compound();
  for (int i = 0; i < 4; ++i) {
    final blurTarget = BackTarget(
      autoResize: true,
      clearColor: false,
      autoResizeScalarX: 0.25,
      autoResizeScalarY: 0.25,
    );
    final blurPass = scenes.GaussianBlur(
      target: blurTarget,
      blurAdj: Vector4(10.0, 10.0, 10.0, 1.0),
      colorTxt: bloomTarget.colorTexture,
      blurTxt: brightTarget.colorTexture,
    );
    bloomTarget = blurTarget;
    bloomScene.add(blurPass);
  }
  final layoutTech = TextureLayout()
    ..blend = shaders.ColorBlendType.Additive
    ..entries.add(TextureLayoutEntry(texture: colorTarget.colorTexture))
    ..entries.add(TextureLayoutEntry(texture: bloomTarget.colorTexture));
  final layout = scenes.CoverPass()..technique = layoutTech;
  td.scene = scenes.Compound(
    passes: [colorPass, brightTrim, bloomScene, layout],
  );
  show_fps(td);
}
