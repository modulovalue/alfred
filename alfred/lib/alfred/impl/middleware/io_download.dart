import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';
import 'io_file.dart';

class ServeDownload implements Middleware {
  final String filename;
  final ServeFile child;

  const ServeDownload({
    required final this.filename,
    required final this.child,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    // TODO extract and centralise headers.
    c.res.setHeaderString(
      'Content-Disposition',
      'attachment; filename=' + filename,
    );
    await child.process(c);
  }
}
