import '../interface.dart';

class StreamOfBytesMiddleware implements AlfredMiddleware {
  final Stream<List<int>> bytes;

  const StreamOfBytesMiddleware({
    required this.bytes,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final header_content_type = c.res.mime_type;
    if (header_content_type == null) {
      c.res.set_content_type_binary();
    } else if (header_content_type == 'text/plain') {
      c.res.set_content_type_binary();
    }
    await c.res.write_byte_stream(bytes);
    await c.res.close();
  }
}
