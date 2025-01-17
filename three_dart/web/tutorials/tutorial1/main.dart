import 'package:three_dart/core.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';

import '../../common/common.dart';

void main() {
  ShellPage("Tutorial 1")
    ..add_par([
      "This tutorial will walk you through creating the \"Hello World\" ",
      "of 3D graphics, a rotating cube. After this tutorial you should know how ",
      "to create a [3Dart|https://github.com/Grant-Nelson/three_dart] project. ",
      "However, it is recommended you have a basic understanding of [Dart|https://www.dartlang.org] ",
      "and [3D Matrices|http://www.opengl-tutorial.org/beginners-tutorials/tutorial-3-matrices/] ",
      "before starting. You will not need to know [WebGL|https://en.wikipedia.org/wiki/WebGL] ",
      "nor [OpenGL|https://en.wikipedia.org/wiki/OpenGL] until the more advanced ",
      "tutorials."
    ])
    ..addCanvas("tutorial1")
    ..add_header(0, "Getting Started")
    ..add_par([
      "The following is the [HTML|#index.html] and the [Dart|#main.dart] files ",
      "that we will explore in this tutorial. For this first tutorial I will just ",
      "provide the code and then we'll go over code describing how it works."
    ])
    ..addCode("index.html", "html", 0, [
      '<!DOCTYPE html>',
      '<html>',
      '  <head>',
      '  	<meta charset="utf-8">',
      '  	<meta name="viewport" content="width=device-width, initial-scale=1.0">',
      '   <title>Tutorial 1</title>',
      '  </head>',
      '  <body>',
      '    <canvas id="tutorial1" width="800" height="600"></canvas>',
      '    <script defer src="main.dart.js"></script>',
      '  </body>',
      '</html>'
    ])
    ..addCode("main.dart", "dart", 0, [
      "library threeDartTutorial1;",
      "",
      "import 'package:three_dart/Core.dart' as three_dart;",
      "import 'package:three_dart/Shapes.dart' as Shapes;",
      "import 'package:three_dart/Movers.dart' as Movers;",
      "import 'package:three_dart/Techniques.dart' as Techniques;",
      "import 'package:three_dart/Scenes.dart' as Scenes;",
      "",
      "void main() {",
      "  three_dart.Entity obj = new three_dart.Entity()",
      "    ..shape = Shapes.cube()",
      "    ..mover = new Movers.Rotator()",
      "    ..technique = new Techniques.Depth(fogStart: 3.0, fogStop: 6.0);",
      "",
      "  Scenes.EntityPass pass = new Scenes.EntityPass()",
      "    ..children.add(obj)",
      "    ..camera.mover = new Movers.Constant.translate(0.0, 0.0, 5.0);",
      "",
      "  new three_dart.ThreeDart.fromId(\"tutorial1\")",
      "    ..scene = pass;",
      "}"
    ])
    ..add_header(4, "three_dart")
    ..add_par([
      "three_dart must have a ",
      "[HTML canvas element|http://www.w3schools.com/graphics/canvas_intro.asp] to ",
      "render graphics to. In this example the canvas is provided by [index.html|#index.html] ",
      "and labelled `tutorial1`. On line 21 of [main.dart|#main.dart] the main three_dart class ",
      "is created an attached to that canvas using its identifier."
    ])
    ..add_header(4, "Scene")
    ..add_par([
      "To make the image, the rendering has to have something to render. ",
      "A scene is set to three_dart to provide the content to render. A scene ",
      "can be a single rendering pass or a composite of several scenes. In this ",
      "tutorial the scene is only a single pass for rendering entities, the `EntityPass`. "
    ])
    ..add_par([
      "The EntityPass has a default render target, a `Front Target`, which renders ",
      "directly to the canvas. On render the target will first clear its depth buffer ",
      "and color buffer which is why the background is black."
    ])
    ..add_par([
      "The EntityPass also has a default camera, a `Perspective Camera`. ",
      "For this example we moved the camera, using a `Constant Mover`, back so that the ",
      "camera is off the center of the scene and looking at the center of the scene."
    ])
    ..add_header(4, "Entity")
    ..add_par([
      "One or more Entities can be added to the EntityPass. An `Entity` can have ",
      "one or more other Entities added to it too. An Entity describes a shape or group ",
      "of shapes that should be rendered in the scene."
    ])
    ..add_par([
      "In this tutorial we only add one which is what draws the cube to the scene. ",
      "To make it draw a cube we set the shape of the Entity to a cube. The shape ",
      "can be set to many other built-in shapes, such as sphere, toroid, and knot. ",
      "The shape can be loaded from a file or created mathematically or procedurally."
    ])
    ..add_par([
      "To make the Entity rotate a `Mover` is attached to it. For this tutorial ",
      "we used the default `Rotator` to cause it to rotate. Movers can be grouped ",
      "to multiply matrices together thus compounding the movements."
    ])
    ..add_par([
      "The `Technique` attached to the Entity defines how the shape should be ",
      "drawn. In this tutorial we used a very simple technique, `Depth`. Depth ",
      "simply draws the shape with two different colors based on distance from the ",
      "camera. If the background, front target clear color, it the same as the ",
      "far color, it can give the appearance of fog or murky water."
    ])
    ..add_header(4, "Summary")
    ..add_par([
      "Play around with the Rotator, Shape, and Depth to get a feel for " ,
      "how the parts works. The main take away from this tutorial should be ",
      "how to structure a basic render. A render is one or more pass which draws ",
      "entities. The pass has a camera and target. Entities can contain several ",
      "entities and can draw a shape. An entity can be moved with a Mover and ",
      "rendered with a given technique."
    ])
    ..add_par([
      "In the next tutorial we will setup a material light technique ",
      "and dive into creating more interesting scenes."
    ]);
  final Entity obj = Entity()
    ..shape = cube()
    ..mover = Rotator()
    ..technique = Depth(start: 3.0, stop: 6.0, grey: true);
  final EntityPass pass = EntityPass()
    ..children.add(obj)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  ThreeDart.fromId("tutorial1").scene = pass;
}
