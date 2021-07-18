import '../../../bluffer/base/app.dart';
import '../../../bluffer/base/util/single_file.dart';
import '../../../bluffer/widgets/widget/interface/build_context.dart';
import '../../../bluffer/widgets/widget/interface/widget.dart';
import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';
import 'html.dart';

abstract class ServeWidget implements Middleware {
  const factory ServeWidget({
    required final Widget child,
  }) = _ServeWidgetImpl;

  const factory ServeWidget.app({
    required final String title,
    required final Widget child,
  }) = _ServeWidgetAppImpl;
}

class ServeWidgetBuilder implements Middleware {
  final Widget Function(ServeContext c, BuildContext context) builder;

  const ServeWidgetBuilder({
    required final this.builder,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    final html = singlePage(
      builder: (context) => builder(c, context),
    );
    return ServeHtml(html).process(c);
  }
}

class _ServeWidgetImpl implements ServeWidget {
  final Widget child;

  const _ServeWidgetImpl({
    required final this.child,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    final html = singlePage(
      builder: (final context) => child,
    );
    return ServeHtml(html).process(c);
  }
}

class _ServeWidgetAppImpl implements ServeWidget {
  final Widget child;
  final String title;

  const _ServeWidgetAppImpl({
    required final this.title,
    required final this.child,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    final html = singlePage(
      builder: (final context) => AppWidget(
        route: WidgetRouteSimpleImpl(
          title: title,
          child: child,
        ),
      ),
    );
    return ServeHtml(html).process(c);
  }
}
