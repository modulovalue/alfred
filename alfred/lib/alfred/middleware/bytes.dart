import 'dart:async';

import '../interface.dart';

class BytesMiddleware implements AlfredMiddleware {
  final List<int> bytes;

  const BytesMiddleware({
    required this.bytes,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final content_type = c.res.mime_type;
    if (content_type == null) {
      c.res.set_content_type_binary();
    } else if (content_type == 'text/plain') {
      c.res.set_content_type_binary();
    }
    c.res.write_bytes(bytes);
    await c.res.close();
  }
}
