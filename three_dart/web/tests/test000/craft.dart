part of three_dart.test.test000;

void addCraftTests(TestManager tests) {

  tests.add("Test of craft example world getBlock", (TestArgs args) {
    final craft.World world = craft.World(null, craft.CheckersGenerator());

    //                            start location         exp chunk   exp block
    //                           z       y       z         x    z    x   y   z
    _checkGetBlock(args, world,  0.0,    0.0,    0.0,      0,   0,   0,  0,  0);
    _checkGetBlock(args, world,  0.001,  0.0,    0.0,      0,   0,   0,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.001,  0.0,      0,   0,   0,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.0,    0.001,    0,   0,   0,  0,  0);
    _checkGetBlock(args, world,  0.999,  0.0,    0.0,      0,   0,   0,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.999,  0.0,      0,   0,   0,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.0,    0.999,    0,   0,   0,  0,  0);
    _checkGetBlock(args, world,  0.999,  0.999,  0.999,    0,   0,   0,  0,  0);

    _checkGetBlock(args, world, -0.001,  0.0,    0.0,    -16,   0,  15,  0,  0);
    _checkGetBlock(args, world, -0.999,  0.0,    0.0,    -16,   0,  15,  0,  0);
    _checkGetBlock(args, world, -0.001,  0.0,    0.0,    -16,   0,  15,  0,  0);
    _checkGetBlock(args, world, -0.001,  0.0,    0.001,  -16,   0,  15,  0,  0);
    _checkGetBlock(args, world, -0.999,  0.0,    0.999,  -16,   0,  15,  0,  0);

    _checkGetBlock(args, world,  0.0,    0.0,   -0.001,    0, -16,   0,  0, 15);
    _checkGetBlock(args, world,  0.001,  0.0,   -0.001,    0, -16,   0,  0, 15);
    _checkGetBlock(args, world,  0.0,    0.0,   -0.999,    0, -16,   0,  0, 15);
    _checkGetBlock(args, world,  0.999,  0.0,   -0.999,    0, -16,   0,  0, 15);

    _checkGetBlock(args, world, -0.001,  0.0,   -0.001,  -16, -16,  15,  0, 15);
    _checkGetBlock(args, world, -0.999,  0.0,   -0.999,  -16, -16,  15,  0, 15);
    _checkGetBlock(args, world, -0.999,  0.0,   -0.001,  -16, -16,  15,  0, 15);
    _checkGetBlock(args, world, -0.001,  0.0,   -0.999,  -16, -16,  15,  0, 15);

    _checkGetBlock(args, world,  1.0,    0.0,    0.0,      0,   0,   1,  0,  0);
    _checkGetBlock(args, world,  0.0,    1.0,    0.0,      0,   0,   0,  1,  0);
    _checkGetBlock(args, world,  0.0,    0.0,    1.0,      0,   0,   0,  0,  1);
    _checkGetBlock(args, world,  1.001,  0.0,    0.0,      0,   0,   1,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.0,    1.001,    0,   0,   0,  0,  1);

    _checkGetBlock(args, world, -1.0,    0.0,    0.0,    -16,   0,  15,  0,  0);
    _checkGetBlock(args, world,  0.0,   -1.0,    0.0,      0,   0,   0, -1,  0);
    _checkGetBlock(args, world,  0.0,    0.0,   -1.0,      0, -16,   0,  0, 15);
    _checkGetBlock(args, world, -1.001,  0.0,    0.0,    -16,   0,  14,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.0,   -1.001,    0, -16,   0,  0, 14);

    _checkGetBlock(args, world,  0.0,    0.0,  -14.157,    0, -16,   0,  0,  1);
    _checkGetBlock(args, world,  0.0,    0.0,  -15.157,    0, -16,   0,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.0,  -16.157,    0, -32,   0,  0, 15);

    _checkGetBlock(args, world,  0.0,    0.0,   18.0,      0,  16,   0,  0,  2);
    _checkGetBlock(args, world,  0.0,    0.0,   17.0,      0,  16,   0,  0,  1);
    _checkGetBlock(args, world,  0.0,    0.0,   16.0,      0,  16,   0,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.0,   15.0,      0,   0,   0,  0, 15);
    _checkGetBlock(args, world,  0.0,    0.0,   14.0,      0,   0,   0,  0, 14);
    _checkGetBlock(args, world,  0.0,    0.0,   13.0,      0,   0,   0,  0, 13);
    _checkGetBlock(args, world,  0.0,    0.0,   12.0,      0,   0,   0,  0, 12);
    _checkGetBlock(args, world,  0.0,    0.0,   11.0,      0,   0,   0,  0, 11);
    _checkGetBlock(args, world,  0.0,    0.0,   10.0,      0,   0,   0,  0, 10);
    _checkGetBlock(args, world,  0.0,    0.0,    9.0,      0,   0,   0,  0,  9);
    _checkGetBlock(args, world,  0.0,    0.0,    8.0,      0,   0,   0,  0,  8);
    _checkGetBlock(args, world,  0.0,    0.0,    7.0,      0,   0,   0,  0,  7);
    _checkGetBlock(args, world,  0.0,    0.0,    6.0,      0,   0,   0,  0,  6);
    _checkGetBlock(args, world,  0.0,    0.0,    5.0,      0,   0,   0,  0,  5);
    _checkGetBlock(args, world,  0.0,    0.0,    4.0,      0,   0,   0,  0,  4);
    _checkGetBlock(args, world,  0.0,    0.0,    3.0,      0,   0,   0,  0,  3);
    _checkGetBlock(args, world,  0.0,    0.0,    2.0,      0,   0,   0,  0,  2);
    _checkGetBlock(args, world,  0.0,    0.0,    1.0,      0,   0,   0,  0,  1);
    _checkGetBlock(args, world,  0.0,    0.0,    0.0,      0,   0,   0,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.0,   -1.0,      0, -16,   0,  0, 15);
    _checkGetBlock(args, world,  0.0,    0.0,   -2.0,      0, -16,   0,  0, 14);
    _checkGetBlock(args, world,  0.0,    0.0,   -3.0,      0, -16,   0,  0, 13);
    _checkGetBlock(args, world,  0.0,    0.0,   -4.0,      0, -16,   0,  0, 12);
    _checkGetBlock(args, world,  0.0,    0.0,   -5.0,      0, -16,   0,  0, 11);
    _checkGetBlock(args, world,  0.0,    0.0,   -6.0,      0, -16,   0,  0, 10);
    _checkGetBlock(args, world,  0.0,    0.0,   -7.0,      0, -16,   0,  0,  9);
    _checkGetBlock(args, world,  0.0,    0.0,   -8.0,      0, -16,   0,  0,  8);
    _checkGetBlock(args, world,  0.0,    0.0,   -9.0,      0, -16,   0,  0,  7);
    _checkGetBlock(args, world,  0.0,    0.0,  -10.0,      0, -16,   0,  0,  6);
    _checkGetBlock(args, world,  0.0,    0.0,  -11.0,      0, -16,   0,  0,  5);
    _checkGetBlock(args, world,  0.0,    0.0,  -12.0,      0, -16,   0,  0,  4);
    _checkGetBlock(args, world,  0.0,    0.0,  -13.0,      0, -16,   0,  0,  3);
    _checkGetBlock(args, world,  0.0,    0.0,  -14.0,      0, -16,   0,  0,  2);
    _checkGetBlock(args, world,  0.0,    0.0,  -15.0,      0, -16,   0,  0,  1);
    _checkGetBlock(args, world,  0.0,    0.0,  -16.0,      0, -16,   0,  0,  0);
    _checkGetBlock(args, world,  0.0,    0.0,  -17.0,      0, -32,   0,  0, 15);
    _checkGetBlock(args, world,  0.0,    0.0,  -18.0,      0, -32,   0,  0, 14);
    _checkGetBlock(args, world,  0.0,    0.0,  -19.0,      0, -32,   0,  0, 13);
  });

  tests.add("Test of craft example world collide with floor", (TestArgs args) {
    final craft.World world = craft.World(null, craft.FlatGenerator(8, 9));
    world.prepareChunk(0, 0);

    // Falling straight down to the ground and standing on ground.
    _checkCollide(args, world,   0.5, 12.0, 0.5,   0.0, -5.0, 0.0,   0.5, 11.5, 0.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 14.0, 0.5,   0.0, -5.0, 0.0,   0.5, 11.5, 0.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 14.0, 0.5,   0.0, -1.0, 0.0,   0.5, 13.0, 0.5,  math.HitRegion.None);
    _checkCollide(args, world,   0.5, 11.5, 0.5,   0.0, -5.0, 0.0,   0.5, 11.5, 0.5,  math.HitRegion.YPos);

    // Falling at an angle and moving on the ground.
    _checkCollide(args, world,   0.5, 12.0, 0.5,   1.0, -5.0,  1.0,    1.5, 11.5,  1.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 11.5, 0.5,   1.0, -5.0,  1.0,    1.5, 11.5,  1.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 12.0, 0.5,   1.0, -5.0, -1.0,    1.5, 11.5, -0.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 11.5, 0.5,   1.0, -5.0, -1.0,    1.5, 11.5, -0.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 12.0, 0.5,  -1.0, -5.0,  1.0,   -0.5, 11.5,  1.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 11.5, 0.5,  -1.0, -5.0,  1.0,   -0.5, 11.5,  1.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 12.0, 0.5,  -1.0, -5.0, -1.0,   -0.5, 11.5, -0.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 11.5, 0.5,  -1.0, -5.0, -1.0,   -0.5, 11.5, -0.5,  math.HitRegion.YPos);

    // Falling onto a block and falling beside a block.
    world.getBlock(0.0, 10.0, 0.0)?.value = craft.BlockType.Turf;
    _checkCollide(args, world,   0.5, 14.0,  0.5,   0.0, -5.0, 0.0,   0.5, 12.5, 0.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 14.0,  1.5,   0.0, -5.0, 0.0,   0.5, 11.5, 1.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   0.5, 14.0, -0.5,   0.0, -5.0, 0.0,   0.5, 11.5,-0.5,  math.HitRegion.YPos);
    _checkCollide(args, world,   1.5, 14.0,  0.5,   0.0, -5.0, 0.0,   1.5, 11.5, 0.5,  math.HitRegion.YPos);
    _checkCollide(args, world,  -0.5, 14.0,  0.5,   0.0, -5.0, 0.0,  -0.5, 11.5, 0.5,  math.HitRegion.YPos);

    // Running into a block.
    _checkCollide(args, world,   2.5, 11.5,  0.5,  -5.0,  0.0,  0.0,   1.25, 11.5,  0.5,   math.HitRegion.XPos);
    _checkCollide(args, world,   2.5, 11.5,  0.5,  -5.0, -5.0,  0.0,   1.25, 11.5,  0.5,   math.HitRegion.XPos|math.HitRegion.YPos);
    _checkCollide(args, world,  -1.5, 11.5,  0.5,   5.0,  0.0,  0.0,  -0.25, 11.5,  0.5,   math.HitRegion.XNeg);
    _checkCollide(args, world,   0.5, 11.5,  2.5,   0.0,  0.0, -5.0,   0.5,  11.5,  1.25,  math.HitRegion.ZPos);
    _checkCollide(args, world,   0.5, 11.5, -1.5,   0.0,  0.0,  5.0,   0.5,  11.5, -0.25,  math.HitRegion.ZNeg);
  });
}

void _checkGetBlock(TestArgs args, craft.World world, double x, double y, double z,
  int expChunkX, int expChunkZ, int expBlockX, int expBlockY, int expBlockZ) {
  final craft.BlockInfo? block = world.getBlock(x, y, z);
  if (block == null) {
    args.error("Testing getBlock($x, $y, $z): Failed\n");
    args.notice("  Block was null\n");
    args.info("\n");
    return;
  }

  if (block.chunkX != expChunkX || block.chunkZ != expChunkZ ||
      block.x != expBlockX || block.y != expBlockY || block.z != expBlockZ) {
    args.error("Testing getBlock($x, $y, $z): Failed\n");
    args.notice("  Expected: $expChunkX, $expChunkZ, $expBlockX, $expBlockY, $expBlockZ\n");
    args.notice("  Gotten:   ${block.chunkX}, ${block.chunkZ}, ${block.x}, ${block.y}, ${block.z}\n");
    if (block.chunkX != expChunkX) args.error("  Chunk X value ${block.chunkX} should be $expChunkX.\n");
    if (block.chunkZ != expChunkZ) args.error("  Chunk Z value ${block.chunkZ} should be $expChunkZ.\n");
    if (block.x != expBlockX) args.error("  Block X value ${block.x} should be $expBlockX.\n");
    if (block.y != expBlockY) args.error("  Block Y value ${block.y} should be $expBlockY.\n");
    if (block.z != expBlockZ) args.error("  Block Z value ${block.z} should be $expBlockZ.\n");
    args.info("\n");
    return;
  }

  args.info("Testing getBlock($x, $y, $z): Passed\n");
}

void _checkCollide(TestArgs args, craft.World world, double locX, double locY, double locZ,
  double vecX, double vecY, double vecZ, double expX, double expY, double expZ, math.HitRegion expTouching) {
  final craft.Collider collider = craft.Collider(world);
  final math.Region3 region = math.Region3(-0.25, -1.5, -0.25, 0.5, 2.0, 0.5);
  final math.Point3 loc = math.Point3(locX, locY, locZ);
  final math.Vector3 vector = math.Vector3(vecX, vecY, vecZ);
  final math.Point3 expLocation = math.Point3(expX, expY, expZ);
  collider.collide(region, loc, vector);

  if ((collider.location != expLocation) || (collider.touching != expTouching)) {
    args.error("Testing collide: Failed\n");
    args.error("  Region:   $region\n");
    args.error("  Start:    $loc\n");
    args.error("  Vector:   $vector\n");
    args.error("  Expected: Collider($expLocation, $expTouching)\n");
    args.error("  Gotten:   $collider\n");
    args.info("\n");
  } else {
    args.info("Testing collide: Passed\n");
    args.info("  Region:   $region\n");
    args.info("  Start:    $loc\n");
    args.info("  Vector:   $vector\n");
    args.info("  Gotten:   $collider\n");
    args.info("\n");
  }
}
