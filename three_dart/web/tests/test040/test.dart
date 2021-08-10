library three_dart.test.test040;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/data/data.dart';
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart' as scenes;
import 'package:three_dart/shaders/shaders.dart';
import 'package:three_dart/shapes/shapes.dart' as shapes;
import 'package:three_dart/techniques/techniques.dart' as techniques;
import 'package:three_dart/textures/textures.dart';
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 040")
    ..addLargeCanvas("testCanvas")
    ..addPar(["A combination of bump mapping with height map and specular map."])
    ..addControlBoxes(["controls"])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final Texture2D colorTxt = td.textureLoader.load2DFromFile("../resources/gravel/colorLarge.png");
  final Texture2D bump = td.textureLoader.load2DFromFile("../resources/gravel/bumpLarge.png");
  final Texture2D spec = td.textureLoader.load2DFromFile("../resources/gravel/specularSmall.png");
  final Texture2D height = td.textureLoader.load2DFromFile("../resources/gravel/heightSmall.png");

  final Group mover = Group(
      [Constant.translate(0.0, 0.0, 2.0), Rotator(deltaYaw: 0.6, deltaPitch: 0.1, deltaRoll: 0.0)]);

  final three_dart.Entity bulb = three_dart.Entity(shape: shapes.sphere(radius: 0.03))
    ..mover = mover
    ..technique = techniques.MaterialLight.glow();
  final Point light =
      Point(color: Color3.white(), mover: mover, attenuation0: 0.5, attenuation1: 0.1, attenuation2: 0.0);
  final shapes.Shape flatShape = shapes.square();
  final three_dart.Entity entity = three_dart.Entity(shape: flatShape);
  shapes.Shape? heightShape;
  height.changed.add((_) {
    final TextureReader heightReader = td.textureLoader.readAll(height);
    heightShape = shapes.grid(widthDiv: 150, heightDiv: 150)
      ..calculateNormals()
      ..applyHeightMap(heightReader, 0.05)
      ..trimVertices(~VertexType.Norm)
      ..trimFaces(norm: false)
      ..calculateNormals();
  });

  final Perspective userCamera = Perspective()
    ..mover = Group([
      UserRotator(input: td.userInput),
      UserZoom(input: td.userInput),
      Constant.translate(0.0, 0.0, 5.0)
    ]);

  final techniques.MaterialLight colorTech = techniques.MaterialLight()
    ..lights.add(light)
    ..ambient.color = Color3.gray(0.3)
    ..diffuse.color = Color3.white()
    ..specular.shininess = 40.0;

  final BackTarget colorTarget = BackTarget(autoResize: true);
  final scenes.EntityPass colorPass = scenes.EntityPass(children: [entity, bulb])
    ..technique = colorTech
    ..camera = userCamera
    ..target = colorTarget;

  final BackTarget depthTarget = BackTarget(autoResize: true, autoResizeScalarX: 0.5, autoResizeScalarY: 0.5);

  final scenes.EntityPass depthPass = scenes.EntityPass(children: [entity, bulb])
    ..camera = userCamera
    ..target = depthTarget
    ..technique = techniques.Depth(start: 0.5, stop: 5.5);

  final scenes.GaussianBlur blurPass = scenes.GaussianBlur(
      blurAdj: Vector4(-1.0, 0.0, 0.0, 1.0),
      colorTxt: colorTarget.colorTexture,
      blurTxt: depthTarget.colorTexture);

  final techniques.TextureLayout layoutTech = techniques.TextureLayout()
    ..blend = ColorBlendType.Overwrite
    ..entries.add(
        techniques.TextureLayoutEntry(texture: depthTarget.colorTexture, destination: Region2(0.0, 0.8, 0.2, 0.2)))
    ..entries.add(techniques.TextureLayoutEntry(
        texture: colorTarget.colorTexture, destination: Region2(0.0, 0.6, 0.2, 0.2)));

  final scenes.CoverPass layout = scenes.CoverPass()
    ..target = FrontTarget(clearColor: false)
    ..technique = layoutTech;

  td.scene = scenes.Compound(passes: [colorPass, depthPass, blurPass, layout]);

  common.CheckGroup("controls")
    ..add("Color", (bool show) {
      colorTech
        ..ambient.texture2D = show ? colorTxt : null
        ..diffuse.texture2D = show ? colorTxt : null;
    }, true)
    ..add("Specular", (bool show) {
      colorTech.specular.texture2D = show ? spec : null;
    })
    ..add("Bump", (bool show) {
      colorTech.bump.texture2D = show ? bump : null;
    })
    ..add("Height", (bool show) {
      entity.shape = show ? heightShape : flatShape;
    })
    ..add("Blur", (bool show) {
      blurPass.blurTexture = show ? depthTarget.colorTexture : null;
    })
    ..add("Passes", (bool show) {
      layout.technique = show ? layoutTech : null;
    });

  common.showFPS(td);
}
