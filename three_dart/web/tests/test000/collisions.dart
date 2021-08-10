part of three_dart.test.test000;

void addCollisionTests(TestManager tests) {
  tests.add("Collision Between Two AABB Test", (TestArgs args) {
    _aabb3Collision1(args, "Not moving, not touching",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0),
      math.Vector3(0.0, 0.0, 0.0),
      Type.NoCollision, 0.0, math.HitRegion.None);
    _aabb3Collision1(args, "Moving right but not enough to touch",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Vector3(0.5, 0.0, 0.0),
      Type.NoCollision, 0.0, math.HitRegion.None);
    _aabb3Collision1(args, "Moving right until they just touch on edge",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Vector3(1.0, 0.0, 0.0),
      Type.Collision, 1.0, math.HitRegion.XNeg);
    _aabb3Collision1(args, "Moving to pass eachother and hit early",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Vector3(4.0, 0.0, 0.0),
      Type.Collision, 0.25, math.HitRegion.XNeg);
    _aabb3Collision1(args, "Moving away from eachother backwards",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Vector3(-4.0, 0.0, 0.0),
      Type.NoCollision, 0.0, math.HitRegion.None);
    _aabb3Collision1(args, "Moving away from eachother already passed",
      math.Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Vector3(4.0, 0.0, 0.0),
      Type.NoCollision, 0.0, math.HitRegion.None);
    _aabb3Collision1(args, "Moving backwards past eachother and hit early",
      math.Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Vector3(-4.0, 0.0, 0.0),
      Type.Collision, 0.25, math.HitRegion.XPos);
    _aabb3Collision1(args, "Moving right but offset to pass eachother",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0),
      math.Vector3(4.0, 0.0, 0.0),
      Type.NoCollision, 0.0, math.HitRegion.None);
    _aabb3Collision1(args, "Moving almost diagnally at an angle to collide",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0),
      math.Vector3(2.0, 2.4, 2.8),
      Type.Collision, 0.5, math.HitRegion.XNeg);
    _aabb3Collision1(args, "Moving almost diagnally at a different angle to collide",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0),
      math.Vector3(2.8, 2.0, 2.4),
      Type.Collision, 0.5, math.HitRegion.YNeg);
    _aabb3Collision1(args, "Moving almost diagnally at another different angle to collide",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0),
      math.Vector3(2.4, 2.8, 2.0),
      Type.Collision, 0.5, math.HitRegion.ZNeg);
    _aabb3Collision1(args, "Moving diagnally to collide",
      math.Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
      math.Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0),
      math.Vector3(2.0, 2.0, 2.0),
      Type.Collision, 0.5, math.HitRegion.XNeg);
    _aabb3Collision1(args, "Moving down and colliding",
      math.Region3(0.0, 11.13, 0.0, 0.0, 1.5, 0.0),
      math.Region3(0.0,  8.0,  0.0, 0.0, 1.0, 0.0),
      math.Vector3(0.0, -2.45, 0.0),
      Type.Collision, 0.869387755102041, math.HitRegion.YPos);
    _aabb3Collision1(args, "Moving up at an agle and already touching on edge",
      math.Region3(0.25, 10.0, 0.1, 0.25, 2.0, 0.25),
      math.Region3(0.0, 9.0, 0.0, 1.0, 1.0, 1.0),
      math.Vector3(0.0, -1.0, -0.3),
      Type.Collision, 0.0, math.HitRegion.YPos);
    _aabb3Collision1(args, "One already contains the other",
      math.Region3(-2.0, -2.0, -2.0, 4.0, 4.0, 4.0),
      math.Region3(-1.0, -1.0, -1.0, 2.0, 2.0, 2.0),
      math.Vector3(2.0, 2.0, 2.0),
      Type.Intesected, 0.0, math.HitRegion.None);
    _aabb3Collision1(args, "Partually overlapping",
      math.Region3(-2.0, -2.0, -2.0, 2.0, 2.0, 2.0),
      math.Region3(-1.0, -1.0, -1.0, 2.0, 2.0, 2.0),
      math.Vector3(2.0, 2.0, 2.0),
      Type.Intesected, 0.0, math.HitRegion.None);
  });

  tests.add("Collision Between Two Spheres Test", (TestArgs args) {
    _twoSphereCollision(args, "Same sized spheres colliding after B moves left",
      math.Sphere(0.0, 0.0, 0.0, 1.0),
      math.Sphere(3.0, 0.0, 0.0, 1.0),
      math.Vector3.zero,
      math.Vector3(-1.0, 0.0, 0.0),
      Type.Collision, 1.0);
    _twoSphereCollision(args, "Same sized spheres colliding after A moves left",
      math.Sphere(3.0, 0.0, 0.0, 1.0),
      math.Sphere(0.0, 0.0, 0.0, 1.0),
      math.Vector3(-1.0, 0.0, 0.0),
      math.Vector3.zero,
      Type.Collision, 1.0);
    _twoSphereCollision(args, "Same sized spheres already touching and A moves left",
      math.Sphere(0.0, 0.0, 0.0, 1.0),
      math.Sphere(2.0, 0.0, 0.0, 1.0),
      math.Vector3(-1.0, 0.0, 0.0),
      math.Vector3.zero,
      Type.NoCollision, 0.0);
    _twoSphereCollision(args, "Same sized spheres already touching and A moves right",
      math.Sphere(0.0, 0.0, 0.0, 1.0),
      math.Sphere(2.0, 0.0, 0.0, 1.0),
      math.Vector3.zero,
      math.Vector3(-1.0, 0.0, 0.0),
      Type.Collision, 0.0);
  });
}

void _aabb3Collision1(TestArgs args, String msg, math.Region3 reg, math.Region3 target,
  math.Vector3 vec, Type expType, double expParametric, math.HitRegion expHit) {
  final TwoAABB3Result result = twoAABB3(reg, target, vec, math.Vector3.zero);
  if ((result.type != expType) ||
    !math.Comparer.equals(result.parametric, expParametric) ||
    (result.region != expHit)) {
    args.error("Unexpected result from twoAABB3 collision:\n"+
      "   Message:  $msg\n"+
      "   Original: $reg\n"+
      "   Target:   $target\n"+
      "   Vector:   $vec\n"+
      "   Expected: $expType $expParametric $expHit\n"+
      "   Result:   $result\n");
  } else {
    args.info("Results from twoAABB3 collision:\n"+
      "   Message:  $msg\n"+
      "   Original: $reg\n"+
      "   Target:   $target\n"+
      "   Vector:   $vec\n"+
      "   Result:   $result\n");
  }
}

void _twoSphereCollision(TestArgs args, String msg, math.Sphere sphereA, math.Sphere sphereB,
  math.Vector3 vecA, math.Vector3 vecB, Type expType, double expParametric) {
  final TwoSphereResult result = twoSphere(sphereA, sphereB, vecA, vecB);
  if ((result.type != expType) ||
    !math.Comparer.equals(result.parametric, expParametric)) {
    args.error("Unexpected result from twoSphere collision:\n"+
      "   Message:  $msg\n"+
      "   Sphere A: $sphereA\n"+
      "   Sphere B: $sphereB\n"+
      "   Vector A: $vecA\n"+
      "   Vector B: $vecB\n"+
      "   Expected: $expType $expParametric\n"+
      "   Result:   ${result.type} ${result.parametric}\n"+
      "   ResultOb: $result\n");
  } else {
    args.info("Results from twoSphere collision:\n"+
      "   Message:  $msg\n"+
      "   Sphere A: $sphereA\n"+
      "   Sphere B: $sphereB\n"+
      "   Vector A: $vecA\n"+
      "   Vector B: $vecB\n"+
      "   Result:   $result\n");
  }
}
