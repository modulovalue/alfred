class KeyImpl implements Key {
  @override
  final String className;

  const KeyImpl(
    this.className,
  );
}

abstract class Key {
  String get className;
}
