import '../../../base/keys.dart';
import '../../../base/media_query_data.dart';
import '../../../css/css.dart';
import '../../../html/html.dart';
import '../interface/build_context.dart';
import '../interface/inherited_widget.dart';
import '../interface/widget.dart';

HtmlElement2 renderWidget(
  final Widget widget,
  final BuildContext context,
) {
  final html = widget.renderHtml(context);
  final k = widget.key;
  if (k != null) {
    html.id = k.className + '-' + MediaQuery.of(context)!.size.index.toString();
  }
  final newClassKey = context.createDefaultKey();
  final currentClasses = html.className;
  html.className = [
    if (currentClasses != null && currentClasses != "") //
      currentClasses,
    newClassKey.className,
  ].join(" ");
  final css = widget.renderCss(context);
  if (css != null) {
    context.setStyle(
      newClassKey.className,
      css,
    );
  }
  return html;
}

mixin InheritedWidgetMixin implements InheritedWidget {
  Widget get child;

  @override
  HtmlElement2 renderHtml(
    final BuildContext context,
  ) =>
      child.renderHtml(context.withInherited(this));

  @override
  HtmlElement2 render(
    final BuildContext context,
  ) =>
      child.render(context.withInherited(this));

  @override
  CssStyleDeclaration2? renderCss(
    final BuildContext context,
  ) =>
      child.renderCss(context.withInherited(this));
}

class MediaQuery with InheritedWidgetMixin {
  final MediaQueryData data;
  @override
  final Key? key;
  @override
  final Widget child;

  const MediaQuery({
    required final this.child,
    required final this.data,
    final this.key,
  });

  static MediaQueryData? of(
    final BuildContext context,
  ) => //
      context.dependOnInheritedWidgetOfExactType<MediaQuery>()?.data;
}
