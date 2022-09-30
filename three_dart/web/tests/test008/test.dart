library three_dart.test.test008;

import 'dart:web_gl' as webgl;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/data.dart';
import 'package:three_dart/events.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shaders.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/textures.dart';

import '../../common/common.dart' as common;

part 'bumpy_shader.dart';

part 'bumpy_technique.dart';

void main() {
  final common.ShellPage page = common.ShellPage("Test 008")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "A custom shader for testing and fixing the normal distortion ",
      "equation used for bump maps. This displays the normal vectors ",
      "across a surface."
    ])
    ..addControlBoxes(["bumpMaps", "scalars"])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final Shape shape = grid(widthDiv: 50, heightDiv: 50);
  shape.calculateNormals();
  shape.calculateBinormals();
  shape.faces.removeAll();
  for (int i = shape.vertices.length - 1; i >= 0; i--) {
    final Vertex ver1 = shape.vertices[i]..weight = 0.0;
    final Vertex ver2 = ver1.copy()..weight = 1.0;
    shape.vertices.add(ver2);
    shape.lines.add(ver1, ver2);
  }
  final BumpyTechnique tech = BumpyTechnique()..offsetScalar = 0.5;
  final three_dart.Entity objTech = three_dart.Entity()
    ..shape = shape
    ..technique = tech;
  final three_dart.Entity group = three_dart.Entity()
    ..children.add(objTech)
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput, invertY: true))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));
  td.scene = EntityPass()
    ..children.add(group)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  common.Texture2DGroup("bumpMaps", (String fileName) {
    tech.bumpyTexture = td.textureLoader.load2DFromFile(fileName);
  })
    ..add("../resources/BumpMap1.png", true)
    ..add("../resources/BumpMap2.png")
    ..add("../resources/BumpMap3.png")
    ..add("../resources/BumpMap4.png")
    ..add("../resources/BumpMap5.png")
    ..add("../resources/ScrewBumpMap.png")
    ..add("../resources/CtrlPnlBumpMap.png");
  common.RadioGroup("scalars")
    ..add("0.1", () {
      tech.offsetScalar = 0.1;
    })
    ..add("0.2", () {
      tech.offsetScalar = 0.2;
    })
    ..add("0.3", () {
      tech.offsetScalar = 0.3;
    })
    ..add("0.4", () {
      tech.offsetScalar = 0.4;
    })
    ..add("0.5", () {
      tech.offsetScalar = 0.5;
    }, true)
    ..add("0.6", () {
      tech.offsetScalar = 0.6;
    })
    ..add("0.7", () {
      tech.offsetScalar = 0.7;
    })
    ..add("0.8", () {
      tech.offsetScalar = 0.8;
    })
    ..add("0.9", () {
      tech.offsetScalar = 0.9;
    })
    ..add("1.0", () {
      tech.offsetScalar = 1.0;
    });
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.show_fps(td);
}
