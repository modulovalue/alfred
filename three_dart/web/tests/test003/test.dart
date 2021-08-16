library three_dart.test.test003;

import 'package:three_dart/core/core.dart';
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart';

void main() {
  final page = ShellPage("Test 003")
    ..addLargeCanvas("testCanvas")
    ..addPar(["A test of the Material Light Shader with a solid color directional lighting."])
    ..addPar(["«[Back to Tests|../]"]);
  final obj = Entity()
    ..shape = toroid()
    ..mover = Rotator();
  final tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(1.0, 1.0, -3.0), color: Color3.white()))
    ..ambient.color = Color3(0.0, 0.0, 1.0)
    ..diffuse.color = Color3(0.0, 1.0, 0.0)
    ..specular.color = Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;
  final pass = EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  final td = ThreeDart.fromId("testCanvas")..scene = pass;
  td.postrender.once(
    (final _) => page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n")),
  );
  showFPS(td);
}
