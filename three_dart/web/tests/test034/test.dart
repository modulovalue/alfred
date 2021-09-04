library three_dart.test.test034;

import 'dart:html';

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 034")
    ..addLargeCanvas("testCanvas")
    ..addPar(["Test of resizing the render target. ", "Resizing the canvas works better in Chrome."])
    ..addPar(["«[Back to Tests|../]"]);
  final Element? canvas = document.getElementById("testCanvas");
  if (canvas == null) {
    throw Exception('Failed to find test canvas');
  }
  canvas.style
    ..width = "100%"
    ..height = "100%"
    ..margin = "-4px";
  final Element div = DivElement();
  div.style
    ..border = "2px solid"
    ..padding = "10px"
    ..resize = "both"
    ..overflow = "auto";
  canvas.replaceWith(div);
  div.children.add(canvas);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final Group mover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective userCamera = Perspective(mover: mover);
  final MaterialLight tech = MaterialLight()
    ..ambient.color = Color3.gray(0.3)
    ..diffuse.color = Color3.gray(0.8)
    ..diffuse.texture2D = td.textureLoader.load2DFromFile("../resources/Test.png");
  final FrontTarget target = FrontTarget()..clearColor = false;
  final three_dart.Entity obj = three_dart.Entity()..shape = cube();
  final EntityPass pass = EntityPass()
    ..children.add(obj)
    ..technique = tech
    ..target = target
    ..camera = userCamera;
  final CoverPass skybox =
      CoverPass.skybox(td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"))
        ..target = target
        ..camera = userCamera;
  td.scene = Compound(passes: [skybox, pass]);
  common.showFPS(td);
}
