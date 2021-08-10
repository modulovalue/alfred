library three_dart.test.test036;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shaders/shaders.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart' as techniques;
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 036")
    ..addLargeCanvas("testCanvas")
    ..addPar(["Test of the texture layout cover technique."])
    ..addControlBoxes(["blends"])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final Group secondMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective userCamera = Perspective(mover: secondMover);

  final BackTarget back = BackTarget(autoResize: true, color: Color4.transparent());

  final three_dart.Entity obj = three_dart.Entity()..shape = toroid();

  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(0.0, -1.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.0, 0.0, 1.0)
    ..diffuse.color = Color3(0.0, 1.0, 0.0)
    ..specular.color = Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;

  final EntityPass pass = EntityPass()
    ..camera = userCamera
    ..technique = tech
    ..target = back
    ..children.add(obj);

  final techniques.TextureLayout layout = techniques.TextureLayout(backColor: Color4.black());
  const int count = 3;
  final double scale = 1.0 / count.toDouble();
  for (int i = 0; i < count; ++i) {
    final double xOffset = i.toDouble() * scale;
    for (int j = 0; j < count; ++j) {
      final double yOffset = j.toDouble() * scale;
      layout.entries.add(techniques.TextureLayoutEntry(
          texture: back.colorTexture, destination: Region2(xOffset, yOffset, scale, scale)));
    }
  }
  layout.entries.add(techniques.TextureLayoutEntry()
    ..texture = back.colorTexture
    ..colorMatrix = Matrix4(0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0));

  final FrontTarget front = FrontTarget(color: Color4.black());
  final CoverPass layoutCover = CoverPass()
    ..technique = layout
    ..target = front;

  td.scene = Compound(passes: [pass, layoutCover]);

  common.RadioGroup("blends")
    ..add("Additive", () {
      layout.blend = ColorBlendType.Additive;
    })
    ..add("AlphaBlend", () {
      layout.blend = ColorBlendType.AlphaBlend;
    }, true)
    ..add("Average", () {
      layout.blend = ColorBlendType.Average;
    })
    ..add("Overwrite", () {
      layout.blend = ColorBlendType.Overwrite;
    });

  common.showFPS(td);
}
