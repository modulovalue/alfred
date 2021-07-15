class RunOnce<T> {
  bool firstTime = true;
  T? last;

  RunOnce();

  /// Runs [every] on every call to [run].
  /// Runs [first] on the first call to [run].
  Future<void> everyFirst({
    required final Future<T> Function(T? last) every,
    required final void Function(T) first,
  }) async {
    final value = await every(last);
    last = value;
    if (firstTime) {
      first(value);
      firstTime = false;
    }
  }
  /// Runs [every] on every call to [run].
  /// Runs [first] on the first call to [run].
  Future<void> every({
    required final Future<T> Function(T? last) every,
  }) async {
    final value = await every(last);
    last = value;
  }
}
