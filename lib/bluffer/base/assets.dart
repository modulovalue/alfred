import 'dart:io';

abstract class Assets {
  Directory get local;
}

class AssetsImpl implements Assets {
  @override
  final Directory local;

  const AssetsImpl(this.local);
}

class AssetsDefaultImpl implements Assets {
  static final Directory dir = Directory('assets');

  @override
  Directory get local => dir;

  const AssetsDefaultImpl();
}
