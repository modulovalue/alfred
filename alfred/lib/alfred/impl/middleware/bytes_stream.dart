// TODO centralize this dependency
import 'dart:io';

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
    final headerContentType = c.res.headers.contentType;
    if (headerContentType == null) {
      c.res.headers.contentType = ContentType.binary;
    } else if (headerContentType.value == 'text/plain') {
      c.res.headers.contentType = ContentType.binary;
    }
    await c.res.addStream(bytes);
    await c.res.close();
  }
}
