import '../../../base/keys.dart';
import '../../../base/media_query_data.dart';
import '../../../css/css.dart';
import '../../../html/html.dart';
import '../interface/build_context.dart';
import '../interface/inherited_widget.dart';
import '../interface/widget.dart';

HtmlElement renderWidget({
  required final Widget child,
  required final BuildContext context,
}) {
  final html = child.renderHtml(
    context: context,
  );
  final key = child.key;
  if (key != null) {
    final mediaQuerySize = MediaQuery.of(context)!.size;
    final mediaQuerySizeIndex = mediaQuerySize.index.toString();
    // TODO need a redirecting node that can mutate the id but redirect the rest.
    html.id = key.className + '-' + mediaQuerySizeIndex;
  }
  final newClassKey = context.createDefaultKey();
  final currentClasses = html.className;
  // TODO need a redirecting node that can mutate the classname but redirect the rest.
  html.className = [
    if (currentClasses != null)
      if (currentClasses != "") //
        currentClasses,
    newClassKey.className,
  ].join(" ");
  final css = child.renderCss(
    context: context,
  );
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
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final newContext = context.withInherited(this);
    return child.renderHtml(
      context: newContext,
    );
  }

  @override
  HtmlElement render({
    required final BuildContext context,
  }) {
    final newContext = context.withInherited(this);
    return child.render(
      context: newContext,
    );
  }

  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) {
    final newContext = context.withInherited(this);
    return child.renderCss(
      context: newContext,
    );
  }
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
  ) =>
      context.dependOnInheritedWidgetOfExactType<MediaQuery>()?.data;
}
