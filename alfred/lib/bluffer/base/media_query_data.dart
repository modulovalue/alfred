abstract class MediaQueryData {
  MediaSize get size;
}

class MediaQueryDataImpl implements MediaQueryData {
  @override
  final MediaSize size;

  const MediaQueryDataImpl({
    required final this.size,
  });
}

// TODO make this an adt.
enum MediaSize {
  xsmall,
  small,
  medium,
  large,
  xlarge,
}
