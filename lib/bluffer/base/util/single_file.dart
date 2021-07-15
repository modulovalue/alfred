import '../../widgets/builder/builder.dart';
import '../../widgets/theme/theme.dart';
import '../../widgets/widget/impl/build_context.dart';
import '../../widgets/widget/impl/widget_mixin.dart';
import '../../widgets/widget/interface/build_context.dart';
import '../../widgets/widget/interface/widget.dart';
import '../assets.dart';
import '../media_query_data.dart';
import '../publish/impl/via_manual.dart';

String singlePage(
  final Widget Function(BuildContext) child,
) {
  final finalChild = MediaQuery(
    data: const MediaQueryDataImpl(size: MediaSize.medium),
    child: Builder(
      builder: (final context) => Theme(
        data: ThemeData.base(context),
        child: child(context),
      ),
    ),
  );
  final buildContext = BuildContextImpl(assets: const AssetsDefaultImpl());
  final element = finalChild.render(buildContext);
  return elementToStringViaManual(element);
}
