import '../../widgets/builder/builder.dart';
import '../../widgets/theme/theme.dart';
import '../../widgets/widget/impl/build_context.dart';
import '../../widgets/widget/impl/widget_mixin.dart';
import '../../widgets/widget/interface/build_context.dart';
import '../../widgets/widget/interface/widget.dart';
import '../assets.dart';
import '../media_query_data.dart';
import '../publish/serialize.dart';

String singlePage({
  required final Widget Function(BuildContext) builder,
}) =>
    constructSinglePageWithMediaQuery(
      child: Builder(
        builder: (final context) => Theme(
          data: ThemeData.base(context),
          child: builder(context),
        ),
      ),
    );

String constructSinglePageWithMediaQuery({
  required final Widget child,
}) =>
    constructSinglePage(
      child: MediaQuery(
        data: const MediaQueryDataImpl(
          size: MediaSize.medium,
        ),
        child: child,
      ),
    );

String constructSinglePage({
  required final Widget child,
}) {
  const assets = AssetsDefaultImpl();
  final buildContext = BuildContextImpl(
    assets: assets,
    styles: {},
  );
  final element = child.render(
    context: buildContext,
  );
  return serializeHtml(
    html: element,
  );
}
