library three_dart.test.test014;

import 'dart:math';

import 'package:three_dart/core.dart';
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/textures.dart';
import 'package:three_dart/views.dart';

import '../../common/common.dart';

void main() {
  final page = ShellPage(
    "Test 014",
  )
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "Test of Material Lighting shader with different reflections and refractions. " +
          "No alpha is being used. The background cube map is being painted onto the object."
    ])
    ..addControlBoxes(["controls", "shapes"])
    ..add_par(["«[Back to Tests|../]"]);
  final ThreeDart td = ThreeDart.fromId("testCanvas");
  final FrontTarget target = FrontTarget()..clearColor = false;
  final Entity obj = Entity()..shape = toroid();
  final TextureCube environment = td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(-1.0, -1.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.1, 0.1, 0.1)
    ..diffuse.color = Color3(0.1, 0.1, 0.1)
    ..specular.color = Color3(1.0, 1.0, 1.0)
    ..specular.shininess = 10.0
    ..environment = environment
    ..refraction.deflection = 0.6
    ..refraction.color = Color3(0.2, 0.3, 1.0)
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
  RadioGroup("controls")
    ..add("Silver", () {
      tech
        ..ambient.color = Color3(0.1, 0.1, 0.1)
        ..diffuse.color = Color3(0.2, 0.2, 0.2)
        ..specular.color = Color3(1.0, 1.0, 1.0)
        ..refraction.color = Color3.black()
        ..reflection.color = Color3(1.0, 1.0, 1.0);
    }, true)
    ..add("Gold", () {
      tech
        ..ambient.color = Color3(0.11, 0.11, 0.1)
        ..diffuse.color = Color3(0.21, 0.21, 0.2)
        ..specular.color = Color3(1.0, 1.0, 1.0)
        ..refraction.color = Color3.black()
        ..reflection.color = Color3(1.0, 0.9, 0.5);
    })
    ..add("Glass", () {
      tech
        ..ambient.color = Color3(0.1, 0.1, 0.1)
        ..diffuse.color = Color3(0.1, 0.1, 0.1)
        ..specular.color = Color3(1.0, 1.0, 1.0)
        ..refraction.deflection = 0.4
        ..refraction.color = Color3(0.6, 0.6, 0.6)
        ..reflection.color = Color3(0.4, 0.4, 0.4);
    })
    ..add("Blue Glass", () {
      tech
        ..ambient.color = Color3(0.1, 0.1, 0.1)
        ..diffuse.color = Color3(0.1, 0.1, 0.1)
        ..specular.color = Color3(1.0, 1.0, 1.0)
        ..refraction.deflection = 0.4
        ..refraction.color = Color3(0.2, 0.3, 1.0)
        ..reflection.color = Color3(0.3, 0.3, 0.3);
    })
    ..add("Water Bubble", () {
      tech
        ..ambient.color = Color3(0.1, 0.1, 0.1)
        ..diffuse.color = Color3(0.1, 0.1, 0.1)
        ..specular.color = Color3(1.0, 1.0, 1.0)
        ..refraction.deflection = 0.6
        ..refraction.color = Color3(0.8, 0.8, 0.8)
        ..reflection.color = Color3(0.2, 0.2, 0.2);
    })
    ..add("No Reflection", () {
      tech
        ..ambient.color = Color3(0.1, 0.1, 0.1)
        ..diffuse.color = Color3(0.1, 0.1, 0.1)
        ..specular.color = Color3(1.0, 1.0, 1.0)
        ..refraction.deflection = 0.6
        ..refraction.color = Color3(1.0, 1.0, 1.0)
        ..reflection.color = Color3.black();
    })
    ..add("Pink Distort", () {
      tech
        ..ambient.color = Color3(0.1, 0.1, 0.1)
        ..diffuse.color = Color3(0.1, 0.1, 0.1)
        ..specular.color = Color3(1.0, 1.0, 1.0)
        ..refraction.deflection = 0.9
        ..refraction.color = Color3(1.0, 0.8, 0.8)
        ..reflection.color = Color3.black();
    })
    ..add("Cloak", () {
      tech
        ..ambient.color = Color3(0.0, 0.0, 0.0)
        ..diffuse.color = Color3(0.1, 0.1, 0.1)
        ..specular.color = Color3(0.1, 0.1, 0.1)
        ..refraction.deflection = 0.99
        ..refraction.color = Color3(0.95, 0.95, 0.95)
        ..reflection.color = Color3.black();
    })
    ..add("White and Shiny", () {
      tech
        ..ambient.color = Color3(0.3, 0.3, 0.3)
        ..diffuse.color = Color3(0.5, 0.5, 0.5)
        ..specular.color = Color3(1.0, 1.0, 1.0)
        ..refraction.color = Color3.black()
        ..reflection.color = Color3(0.3, 0.3, 0.3);
    });
  RadioGroup("shapes")
    ..add("Cube", () {
      obj.shape = cube();
    })
    ..add("Cuboid", () {
      obj.shape = cuboid(
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
      obj.shape = cylinder(sides: 30);
    })
    ..add("Cone", () {
      obj.shape = cylinder(topRadius: 0.0, sides: 30, capTop: false);
    })
    ..add("Cylindrical", () {
      obj.shape = cylindrical(
          sides: 50,
          div: 25,
          radiusHndl: (double u, double v) => cos(v * 4.0 * PI + PI) * 0.2 + cos(u * 6.0 * PI) * 0.3 + 0.8);
    })
    ..add("Sphere", () {
      obj.shape = sphere(widthDiv: 6, heightDiv: 6);
    })
    ..add("Spherical", () {
      obj.shape = sphere(
          widthDiv: 10,
          heightDiv: 10,
          heightHndl: (double u, double v) => cos(sqrt((u - 0.5) * (u - 0.5) + (v - 0.5) * (v - 0.5)) * PI) * 0.3);
    })
    ..add("Toroid", () {
      obj.shape = toroid();
    }, true)
    ..add("Knot", () {
      obj.shape = knot();
    });
  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  show_fps(td);
}
