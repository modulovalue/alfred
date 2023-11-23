import '../../../bluffer/base/app.dart';
import '../../../bluffer/widget/widget.dart';
import '../../bluffer/publish/publish.dart';
import '../interface.dart';
import 'html.dart';

abstract class ServeWidget implements AlfredMiddleware {}

class ServeWidgetBuilder implements AlfredMiddleware {
  final Widget Function(ServeContext c, BuildContext context) builder;

  const ServeWidgetBuilder({
    required this.builder,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    final html = single_page(
      builder: (final context) => builder(c, context),
    );
    return ServeHtml(
      html: html,
    ).process(c);
  }
}

class ServeWidgetImpl implements ServeWidget {
  final Widget child;

  const ServeWidgetImpl({
    required this.child,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    final html = single_page(
      builder: (final context) => child,
    );
    return ServeHtml(
      html: html,
    ).process(c);
  }
}

class ServeWidgetAppImpl implements ServeWidget {
  final Widget child;
  final String title;
  final void Function()? onProcess;

  const ServeWidgetAppImpl({
    required this.title,
    required this.child,
    this.onProcess,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    onProcess?.call();
    final html = single_page(
      builder: (final context) => AppWidget(
        route: WidgetRouteSimpleImpl(
          title: title,
          child: child,
        ),
      ),
    );
    return ServeHtml(
      html: html,
    ).process(c);
  }
}

class ServeWidgetAppBuilderImpl implements ServeWidget {
  final Widget Function(ServeContext, BuildContext) builder;
  final String title;
  final void Function()? on_process;
  final AppIncludes includes;
  final bool enable_css_reset;

  const ServeWidgetAppBuilderImpl({
    required this.title,
    required this.builder,
    this.includes = const AppIncludesEmptyImpl(),
    this.enable_css_reset = true,
    this.on_process,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) {
    on_process?.call();
    final html = single_page(
      builder: (final context) => AppWidget(
        includes: includes,
        enableCssReset: enable_css_reset,
        route: WidgetRouteSimpleImpl(
          title: title,
          child: builder(c, context),
        ),
      ),
    );
    return ServeHtml(
      html: html,
    ).process(c);
  }
}
