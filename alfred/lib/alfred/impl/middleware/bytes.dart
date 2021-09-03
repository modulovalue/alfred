import 'dart:async';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class BytesMiddleware implements Middleware {
  final List<int> bytes;

  const BytesMiddleware({
    required final this.bytes,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final contentType = c.res.mimeType;
    if (contentType == null) {
      c.res.setContentTypeBinary();
    } else if (contentType == 'text/plain') {
      c.res.setContentTypeBinary();
    }
    c.res.writeBytes(bytes);
    await c.res.close();
  }
}
