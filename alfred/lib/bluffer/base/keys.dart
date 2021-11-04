class KeyImpl implements Key {
  @override
  final String className;

  const KeyImpl(
    final this.className,
  );
}

abstract class Key {
  String get className;
}
