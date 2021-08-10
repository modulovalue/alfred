library three_dart.test.test027;

import 'dart:math';

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 027")
    ..addLargeCanvas("testCanvas")
    ..addPar(
        ["Test of a back buffer target for rendering to a texture. ", "That back buffer texture is applied to a box."])
    ..addControlBoxes(["shapes"])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final Group firstMover = Group()..add(Rotator())..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective rotatorCamera = Perspective(mover: firstMover);

  final BackTarget backTarget = BackTarget(width: 512, height: 512, clearColor: false);

  final CoverPass skybox =
      CoverPass.skybox(td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"))
        ..target = backTarget
        ..camera = rotatorCamera;

  final three_dart.Entity firstObj = three_dart.Entity()..shape = toroid();

  final MaterialLight firstTech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(0.0, -1.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.0, 0.0, 1.0)
    ..diffuse.color = Color3(0.0, 1.0, 0.0)
    ..specular.color = Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;

  final EntityPass firstPass = EntityPass()
    ..camera = rotatorCamera
    ..technique = firstTech
    ..target = backTarget
    ..children.add(firstObj);

  final Group secondMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective userCamera = Perspective(mover: secondMover);

  final three_dart.Entity secondObj = three_dart.Entity()..shape = cube();

  final MaterialLight secondTech = MaterialLight()..emission.texture2D = backTarget.colorTexture;

  final EntityPass secondPass = EntityPass()
    ..camera = userCamera
    ..technique = secondTech
    ..children.add(secondObj);

  td.scene = Compound(passes: [skybox, firstPass, secondPass]);

  common.RadioGroup("shapes")
    ..add("Cube", () {
      secondObj.shape = cube();
    }, true)
    ..add("Cuboid", () {
      secondObj.shape = cuboid(
          widthDiv: 15,
          heightDiv: 15,
          vertexHndl: (Vertex ver, double u, double v) {
            final double height = cos(v * 4.0 * PI + PI) * 0.1 + cos(u * 4.0 * PI + PI) * 0.1;
            final loc = ver.location ?? Point3.zero;
            final Vector3 vec = Vector3.fromPoint3(loc).normal();
            ver.location = loc + Point3.fromVector3(vec * height);
          });
    })
    ..add("Cylinder", () {
      secondObj.shape = cylinder(sides: 30);
    })
    ..add("Cone", () {
      secondObj.shape = cylinder(topRadius: 0.0, sides: 30, div: 5, capTop: false);
    })
    ..add("Cylindrical", () {
      secondObj.shape = cylindrical(
          sides: 50,
          div: 25,
          radiusHndl: (double u, double v) =>
              cos(v * 4.0 * PI + PI) * 0.2 + cos(u * 6.0 * PI) * 0.3 + 0.8);
    })
    ..add("Sphere", () {
      secondObj.shape = sphere(widthDiv: 6, heightDiv: 6);
    })
    ..add("Spherical", () {
      secondObj.shape = sphere(
          widthDiv: 10,
          heightDiv: 10,
          heightHndl: (double u, double v) => cos(sqrt((u - 0.5) * (u - 0.5) + (v - 0.5) * (v - 0.5)) * PI) * 0.3);
    })
    ..add("Toroid", () {
      secondObj.shape = toroid();
    })
    ..add("Knot", () {
      secondObj.shape = knot();
    });

  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, secondTech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, secondTech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
