import '../../../bluffer/base/util/single_file.dart';
import '../../../bluffer/widgets/widget/interface/build_context.dart';
import '../../../bluffer/widgets/widget/interface/widget.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';
import 'html.dart';

class ServeWidgetBuilder implements Middleware {
  final Widget Function(ServeContext c, BuildContext context) builder;

  const ServeWidgetBuilder({
    required final this.builder,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    final html = singlePage((context) => builder(c, context));
    return ServeHtml(html).process(c);
  }
}
