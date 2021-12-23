import '../base/keys.dart';
import '../base/media_query_data.dart';
import '../html/html.dart';
import 'widget.dart';

HtmlEntityElement renderWidget({
  required final Widget child,
  required final BuildContext context,
}) {
  final renderedChildHtml = child.renderHtml(
    context: context,
  );
  return HtmlEntityElementImpl(
    element: HtmlElementCopyImpl(
      other: renderedChildHtml.element,
      className: () {
        final renderedChildCss = child.renderCss(
          context: context,
        );
        if (renderedChildCss != null) {
          final newClass = context.createDefaultKey().className;
          context.setStyle(
            newClass,
            renderedChildCss,
          );
          final currentClass = renderedChildHtml.element.className;
          if (currentClass != null) {
            return currentClass + " " + newClass;
          } else {
            return newClass;
          }
        } else {
          return null;
        }
      }(),
      id: () {
        final key = child.key;
        if (key != null) {
          final mediaQuerySize = MediaQuery.of(context)!.size;
          final mediaQuerySizeIndex = mediaQuerySize.index.toString();
          return key.className + '-' + mediaQuerySizeIndex;
        } else {
          return null;
        }
      }(),
    ),
  );
}

mixin InheritedWidgetMixin implements InheritedWidget {
  Widget get child;

  @override
  HtmlEntityElement renderHtml({
    required final BuildContext context,
  }) {
    final newContext = context.withInherited(this);
    return child.renderHtml(
      context: newContext,
    );
  }

  @override
  HtmlEntityElement renderElement({
    required final BuildContext context,
  }) {
    final newContext = context.withInherited(this);
    return child.renderElement(
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
