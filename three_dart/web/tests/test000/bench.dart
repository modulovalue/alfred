part of three_dart.test.test000;

void addBench(TestManager tests) {
  tests.add("Benchmark Uint8List timing", (TestArgs args) {
    final data.Uint8List temp = data.Uint8List(1000);
    args.bench(1.0, () {
      for (int k = 0; k < 1000; k++) {
        temp[k]=0;
      }
      for (int j = 0; j < 100; j++) {
        for (int k = 0; k < 1000; k++) {
          temp[k]++;
        }
      }
    });
    args.info("\n$temp");
  });
  tests.add("Benchmark List int timing", (TestArgs args) {
    final List<int> temp = List<int>.filled(1000, 0);
    args.bench(1.0, () {
      for (int k = 0; k < 1000; k++) {
        temp[k]=0;
      }
      for (int j = 0; j < 100; j++) {
        for (int k = 0; k < 1000; k++) {
          temp[k]++;
        }
      }
    });
    args.info("\n$temp");
  });
  tests.add("Benchmark cuboid building", (TestArgs args) {
    Shape shape; // ignore: unused_local_variable
    args.bench(1.0, () {
      shape = cuboid();
    });
    //shape.validate(args);
  });
  tests.add("Benchmark cuboid building and getting normals", (TestArgs args) {
    Shape shape;
    args.bench(1.0, () {
      shape = sphere();
      shape.calculateNormals();
    });
    //shape.validate(args);
  });
  tests.add("Benchmark cuboid building and join seams", (TestArgs args) {
    Shape shape;
    args.bench(1.0, () {
      shape = sphere();
      shape.joinSeams(VertexLocationMatcher());
    });
    //shape.validate(args);
  });
  tests.add("Benchmark sphere building", (TestArgs args) {
    Shape shape; // ignore: unused_local_variable
    args.bench(1.0, () {
      shape = sphere();
    });
    //shape.validate(args);
  });
}
