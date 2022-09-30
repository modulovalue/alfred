library three_dart.test.test036;

import 'package:three_dart/core.dart';
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shaders.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart' as techniques;
import 'package:three_dart/views.dart';

import '../../common/common.dart';

void main() {
  ShellPage("Test 036")
    ..addLargeCanvas("testCanvas")
    ..add_par(["Test of the texture layout cover technique."])
    ..addControlBoxes(["blends"])
    ..add_par(["«[Back to Tests|../]"]);
  final td = ThreeDart.fromId("testCanvas");
  final secondMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final userCamera = Perspective(mover: secondMover);
  final back = BackTarget(autoResize: true, color: Color4.transparent());
  final obj = Entity()..shape = toroid();
  final tech = techniques.MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(0.0, -1.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.0, 0.0, 1.0)
    ..diffuse.color = Color3(0.0, 1.0, 0.0)
    ..specular.color = Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;
  final pass = EntityPass()
    ..camera = userCamera
    ..technique = tech
    ..target = back
    ..children.add(obj);
  final layout = techniques.TextureLayout(backColor: Color4.black());
  const count = 3;
  final scale = 1.0 / count.toDouble();
  for (int i = 0; i < count; ++i) {
    final xOffset = i.toDouble() * scale;
    for (int j = 0; j < count; ++j) {
      final yOffset = j.toDouble() * scale;
      layout.entries.add(
        techniques.TextureLayoutEntry(
          texture: back.colorTexture,
          destination: Region2(xOffset, yOffset, scale, scale),
        ),
      );
    }
  }
  layout.entries.add(techniques.TextureLayoutEntry()
    ..texture = back.colorTexture
    ..colorMatrix = Matrix4(0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0));
  final front = FrontTarget(color: Color4.black());
  final layoutCover = CoverPass()
    ..technique = layout
    ..target = front;
  td.scene = Compound(passes: [pass, layoutCover]);
  RadioGroup("blends")
    ..add(
      "Additive",
      () => layout.blend = ColorBlendType.Additive,
    )
    ..add(
      "AlphaBlend",
      () => layout.blend = ColorBlendType.AlphaBlend,
      true,
    )
    ..add(
      "Average",
      () => layout.blend = ColorBlendType.Average,
    )
    ..add(
      "Overwrite",
      () => layout.blend = ColorBlendType.Overwrite,
    );
  show_fps(td);
}
