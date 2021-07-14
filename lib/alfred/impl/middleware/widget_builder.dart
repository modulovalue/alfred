import '../../../bluffer/base/util/single_file.dart';
import '../../../bluffer/widgets/widget/interface/build_context.dart';
import '../../../bluffer/widgets/widget/interface/widget.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';
import 'html.dart';

class ServeWidgetBuilder implements Middleware {
  final Widget Function(BuildContext) child;

  const ServeWidgetBuilder({
    required final this.child,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    final html = singlePage(child);
    return ServeHtml(html).process(c);
  }
}
