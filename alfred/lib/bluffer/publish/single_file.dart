import '../base/assets.dart';
import '../base/media_query_data.dart';
import '../widget/build_context.dart';
import '../widget/widget.dart';
import '../widget/widget_mixin.dart';
import '../widgets/builder.dart';
import '../widgets/theme.dart';
import 'serialize.dart';

String singlePage({
  required final Widget Function(BuildContext) builder,
  final Assets assets = const AssetsDefaultSinglePageImpl(),
}) =>
    constructSinglePageWithMediaQuery(
      child: Builder(
        builder: (final context) => Theme(
          data: ThemeData.base(context),
          child: builder(context),
        ),
      ),
      assets: assets,
    );

String constructSinglePageWithMediaQuery({
  required final Widget child,
  required final Assets assets,
}) =>
    constructSinglePage(
      child: MediaQuery(
        data: const MediaQueryDataImpl(
          size: MediaSize.medium,
        ),
        child: child,
      ),
      assets: assets,
    );

String constructSinglePage({
  required final Widget child,
  required final Assets assets,
}) {
  final buildContext = BuildContextImpl(
    assets: assets,
    styles: {},
  );
  final element = child.renderElement(
    context: buildContext,
  );
  return serializeHtmlElement(
    element: element,
  );
}

class AssetsDefaultSinglePageImpl implements Assets {
  static const String dir = 'assets';

  const AssetsDefaultSinglePageImpl();

  @override
  String get local => dir;
}
