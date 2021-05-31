import 'media_query_data.dart';

class Breakpoint {
  final int minSize;
  final MediaSize size;

  const Breakpoint(this.size, this.minSize);

  static int defaultBreakpointSize(MediaSize size) {
    switch (size) {
      case MediaSize.xsmall:
        return 0;
      case MediaSize.small:
        return 600;
      case MediaSize.medium:
        return 1024;
      case MediaSize.large:
        return 1440;
      case MediaSize.xlarge:
        return 1920;
    }
  }
}
