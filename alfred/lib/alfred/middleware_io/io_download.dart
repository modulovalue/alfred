import '../interface.dart';
import 'io_file.dart';

class ServeDownload implements AlfredMiddleware {
  final String filename;
  final ServeFile child;

  const ServeDownload({
    required this.filename,
    required this.child,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    // TODO extract and centralise headers.
    c.res.set_header_string(
      'Content-Disposition',
      'attachment; filename=' + filename,
    );
    await child.process(c);
  }
}
