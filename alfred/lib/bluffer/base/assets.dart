abstract class Assets {
  String get local;
}

class AssetsImpl implements Assets {
  @override
  final String local;

  const AssetsImpl({
    required final this.local,
  });
}

class AssetsDefaultImpl implements Assets {
  static const String dir = 'assets';

  const AssetsDefaultImpl();

  @override
  String get local => dir;
}
