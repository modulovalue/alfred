library three_dart.test.test046;

import 'dart:html' as html;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/input.dart';
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/textures.dart';
import 'package:three_dart/views.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 046")
    ..addLargeCanvas("testCanvas")
    ..addControlBoxes(["buttons"])
    ..add_par([
      "Test of the fullscreen function of the three_dart. ",
      "Use the above button and press escape to exit ",
      "or use the spacebar to toggle fullscreen."
    ])
    ..add_par(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final FrontTarget target = FrontTarget()..clearColor = false;

  final three_dart.Entity obj = three_dart.Entity()..shape = sphere();

  final TextureCube environment = td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg");

  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(-1.0, -1.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.1, 0.1, 0.1)
    ..diffuse.color = Color3(0.1, 0.1, 0.1)
    ..specular.color = Color3(1.0, 1.0, 1.0)
    ..specular.shininess = 10.0
    ..environment = environment
    ..refraction.deflection = 0.6
    ..refraction.color = Color3(1.0, 1.0, 1.0)
    ..reflection.color = Color3(0.6, 0.6, 0.6);

  final Group mover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
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

  final html.Element? elem = html.document.getElementById("buttons");
  final html.ButtonElement button = html.ButtonElement()
    ..text = "Fullscreen"
    ..onClick.listen((_) => td.fullscreen = true);
  elem?.children.add(button);

  td.userInput.key.up.add((args) {
    if (args is KeyEventArgs && args.key.code == Key.spacebar) {
      td.fullscreen = !td.fullscreen;
    }
  });

  common.show_fps(td);
}
