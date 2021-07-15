import '../../../bluffer/base/util/single_file.dart';
import '../../../bluffer/widgets/widget/interface/widget.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';
import 'html.dart';

class ServeWidget implements Middleware {
  final Widget child;

  const ServeWidget({
    required final this.child,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    final html = singlePage((final context) => child);
    print(html.length);
    return ServeHtml(html).process(c);
  }
}
