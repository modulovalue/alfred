library three_dart.test.test049;

import 'package:three_dart/collisions.dart';
import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/events.dart';
import 'package:three_dart/input.dart';
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/textures.dart';

import '../../common/common.dart' as common;

class Ball extends three_dart.Entity {
  static Vector3 gravity = Vector3(0.0, -9.8, 0.0);
  static Shape ballShape = sphere(radius: 1.0, widthDiv: 5, heightDiv: 5);
  static const double dampening = 0.8;
  static const double terminalVelocity = 10.0;

  Constant ballMover;
  Point3 position;
  Vector3 velocity;
  bool active;

  Ball()
      : this.ballMover = Constant(),
        this.position = Point3.zero,
        this.velocity = Vector3.zero,
        this.active = true {
    this.shape = ballShape;
    this.mover = ballMover;
  }
}

three_dart.Entity createFloor(three_dart.ThreeDart td) {
  final Texture2D floorTxt =
      td.textureLoader.load2DFromFile("../resources/Grass.png", wrapEdges: true, mipMap: true);

  final Mover floorMover = Constant(Matrix4.translate(0.0, -5.0, 0.0) *
      Matrix4.scale(1000.0, 1.0, 1000.0) *
      Matrix4.rotateX(-PI_2));

  final MaterialLight tech = MaterialLight()
    ..texture2DMatrix = Matrix3.scale(1000.0, 1000.0, 1.0)
    ..lights.add(Directional(mover: Constant.vectorTowards(1.0, -3.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.5, 0.5, 0.5)
    ..diffuse.color = Color3(0.5, 0.5, 0.5)
    ..ambient.texture2D = floorTxt
    ..diffuse.texture2D = floorTxt;

  return three_dart.Entity()
    ..shape = grid(widthDiv: 20, heightDiv: 20)
    ..mover = floorMover
    ..technique = tech;
}

class Collider extends Mover {
  Event? _changed;
  List<Ball> balls;
  Plane plane;

  final List<int> _attempts;
  final List<SpherePlaneResult> _spColResults;
  final List<Ball> _spColBalls;
  final List<TwoSphereResult> _ssColResults;
  final List<Ball> _ssColBalls1;
  final List<Ball> _ssColBalls2;
  final List<int> _ballsHandled;

  Collider()
      : this.balls = [],
        this.plane = Plane(0.0, 1.0, 0.0, -5.0),
        this._attempts = [],
        this._spColResults = [],
        this._spColBalls = [],
        this._ssColResults = [],
        this._ssColBalls1 = [],
        this._ssColBalls2 = [],
        this._ballsHandled = [];

  void clearCollisions() {
    this._spColResults.clear();
    this._spColBalls.clear();
    this._ssColResults.clear();
    this._ssColBalls1.clear();
    this._ssColBalls2.clear();
    this._ballsHandled.clear();
  }

  double closestCollisions(double dt) {
    double minDT = dt;
    this.clearCollisions();
    final int length = this.balls.length;
    final List<Sphere> spheres = [];
    final List<Vector3> vecs = [];
    for (int i = 0; i < length; i++) {
      if (this._attempts[i] <= 0) continue;

      final Ball ballA = this.balls[i];
      final Matrix4 mat = ballA.ballMover.matrix ?? Matrix4.identity;
      final Sphere sphereA = Sphere(mat.m41, mat.m42, mat.m43, 1.0);
      final Vector3 vecA = ballA.velocity * dt;
      spheres.add(sphereA);
      vecs.add(vecA);

      if (ballA.active) {
        final SpherePlaneResult result1 = spherePlane(sphereA, this.plane, vecA);
        if (result1.collided) {
          this._attempts[i]--;
          final double newDT = result1.parametric * dt;
          if (Comparer.lessThanEquals(newDT, minDT)) {
            if (Comparer.notEquals(newDT, minDT)) {
              this.clearCollisions();
              minDT = newDT;
            }
            this._spColResults.add(result1);
            this._spColBalls.add(ballA);
            if (!this._ballsHandled.contains(i)) this._ballsHandled.add(i);
          }
        }
      }

      for (int j = i - 1; j >= 0; j--) {
        final Ball ballB = this.balls[j];
        if (ballA.active || ballB.active) {
          final Sphere sphereB = spheres[j];
          final Vector3 vecB = vecs[j];

          final TwoSphereResult result2 = twoSphere(sphereA, sphereB, vecA, vecB);
          if (result2.collided) {
            this._attempts[i]--;
            this._attempts[j]--;
            final double newDT = result2.parametric * dt;
            if (Comparer.lessThanEquals(newDT, minDT)) {
              if (Comparer.notEquals(newDT, minDT)) {
                this.clearCollisions();
                minDT = newDT;
              }
              this._ssColResults.add(result2);
              this._ssColBalls1.add(ballA);
              this._ssColBalls2.add(ballB);
              if (!this._ballsHandled.contains(i)) this._ballsHandled.add(i);
              if (!this._ballsHandled.contains(j)) this._ballsHandled.add(j);
            }
          }
        }
      }
    }
    return minDT;
  }

  void moveBall(Ball ball, Point3? position, Vector3 velocity) {
    ball.position = position ?? Point3.zero;
    final double len = velocity.length();
    if (Comparer.greaterThan(len, 0.01)) {
      ball.velocity = velocity;
      ball.active = true;
    } else {
      ball.velocity = Vector3.zero;
      ball.active = false;
    }
  }

  void updateForCollision(double dt) {
    final Vector3 pNorm = this.plane.normal.normal();
    for (int i = this._spColResults.length - 1; i >= 0; i--) {
      final SpherePlaneResult col = this._spColResults[i];
      final Ball ball = this._spColBalls[i];
      final double n = pNorm.dot(ball.velocity);
      final Vector3 perp = ball.velocity - pNorm * n;
      final Vector3 vec = (perp - pNorm * n) * Ball.dampening;
      this.moveBall(ball, col.center, vec);
    }

    for (int i = this._ssColResults.length - 1; i >= 0; i--) {
      final TwoSphereResult col = this._ssColResults[i];
      final Ball ballA = this._ssColBalls1[i];
      final Ball ballB = this._ssColBalls2[i];
      final Vector3 bNorm = (col.centerA ?? Point3.zero).vectorTo(col.centerB ?? Point3.zero);
      final double nA = bNorm.dot(ballA.velocity);
      final double nB = bNorm.dot(ballB.velocity);
      final Vector3 perpA = ballA.velocity - pNorm * nA;
      final Vector3 perpB = ballB.velocity - pNorm * nB;
      final Vector3 vecA = (perpA + bNorm * nB) * Ball.dampening;
      final Vector3 vecB = (perpB + bNorm * nA) * Ball.dampening;
      this.moveBall(ballA, col.centerA, vecA);
      this.moveBall(ballB, col.centerB, vecB);
    }

    for (int i = this.balls.length - 1; i >= 0; i--) {
      if (this._attempts[i] <= 0) continue;
      final Ball ball = this.balls[i];
      if (!this._ballsHandled.contains(i)) {
        ball.position = ball.position.offset(ball.velocity * dt);
      }
      if (ball.active) {
        ball.velocity += Ball.gravity * dt;
      }
      if (ball.velocity.length() > Ball.terminalVelocity) {
        ball.velocity = ball.velocity.normal() * Ball.terminalVelocity;
      }
      ball.ballMover.matrix = Matrix4.translate(ball.position.x, ball.position.y, ball.position.z);
    }
  }

  @override
  Matrix4 update(three_dart.RenderState state, Movable? obj) {
    double dt = state.dt;
    this._attempts.clear();
    for (int i = 0; i < this.balls.length; ++i) {
      this._attempts.add(20);
    }
    while (Comparer.greaterThan(dt, 0.0)) {
      final double minDT = this.closestCollisions(dt);
      this.updateForCollision(minDT);
      dt -= minDT;
    }

    // The collider doesn't move so just return the identity.
    return Matrix4.identity;
  }

  /// Emits when the mover has changed.
  @override
  Event get changed => this._changed ??= Event();
}

void main() {
  common.ShellPage("Test 049")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "This is an initial test (still has bugs) of a basic sphere physics collision. ",
      "This has sphere/sphere collision and sphere/plane collision. Some of the bugs is that ",
      "the spheres will still pass through eachother and the plane and there are no rotations yet."
    ])
    ..addControlBoxes(["options"])
    ..add_par(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final three_dart.Entity group = three_dart.Entity()..children.add(createFloor(td));

  final TextureCube color = td.textureLoader.loadCubeFromPath("../resources/earthColor");
  final MaterialLight ballTech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(-1.0, -1.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.5, 0.5, 0.5)
    ..diffuse.color = Color3(0.5, 0.5, 0.5)
    ..ambient.textureCube = color
    ..diffuse.textureCube = color
    ..specular.shininess = 10.0;
  final Collider collider = Collider();
  final three_dart.Entity balls = three_dart.Entity()
    ..mover = collider
    ..technique = ballTech;

  // Setup the First person camera
  final UserTranslator trans = UserTranslator(input: td.userInput);
  final UserRotator rot = UserRotator.flat(input: td.userInput);
  rot.changed.add((EventArgs args) {
    trans.velocityRotation = Matrix3.rotateY(-rot.yaw.location);
  });
  final Group camera = Group([trans, rot]);

  td.scene = EntityPass()
    ..children.add(group)
    ..children.add(balls)
    ..camera?.mover = camera;

  td.userInput.key.down.add((EventArgs args) {
    final KeyEventArgs kargs = args as KeyEventArgs;
    if (kargs.key.code == Key.spacebar) {
      final Ball ball = Ball();
      ball.position = trans.location;
      ball.velocity = Matrix3.rotateY(-rot.yaw.location).transVec3(Vector3(0.0, 0.0, -10.0));

      balls.children.add(ball);
      collider.balls.add(ball);
    }
  });

  common.CheckGroup("options")
    .add("Mouse Locking", (bool enable) {
      td.userInput.lockOnClick = enable;
    }, false);

  common.show_fps(td);
}
