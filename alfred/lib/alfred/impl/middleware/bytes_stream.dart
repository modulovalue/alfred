import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class StreamOfBytesMiddleware implements Middleware {
  final Stream<List<int>> bytes;

  const StreamOfBytesMiddleware({
    required final this.bytes,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final headerContentType = c.res.mimeType;
    if (headerContentType == null) {
      c.res.setContentTypeBinary();
    } else if (headerContentType == 'text/plain') {
      c.res.setContentTypeBinary();
    }
    await c.res.writeByteStream(bytes);
    await c.res.close();
  }
}
