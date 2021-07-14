import 'dart:async';
import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class BytesMiddleware implements Middleware {
  final List<int> bytes;

  const BytesMiddleware(
    final this.bytes,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final contentType = c.res.headers.contentType;
    if (contentType == null) {
      c.res.headers.contentType = ContentType.binary;
    } else if (contentType.value == 'text/plain') {
      c.res.headers.contentType = ContentType.binary;
    }
    c.res.add(bytes);
    await c.res.close();
  }
}
