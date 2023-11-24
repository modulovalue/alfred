import '../base/assets.dart';
import '../base/keys.dart';
import '../base/media_query_data.dart';
import '../html/html.dart';

abstract class BuildContext {
  Map<String, CssStyleDeclaration> get styles;

  Assets get assets;

  BuildContext withInherited(
    final InheritedWidget widget,
  );

  Key createDefaultKey();

  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>();

  void setStyle(
    final String className,
    final CssStyleDeclaration css,
  );
}

abstract class InheritedWidget implements Widget {}

abstract class Widget {
  Key? get key;

  HtmlElement renderHtml({
    required final BuildContext context,
  });

  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  });
}

class BuildContextImpl implements BuildContext {
  static int lastKeyIndex = 0;
  final Map<Type, InheritedWidget> _inheritedWidgets = {};
  @override
  final Map<String, CssStyleDeclaration> styles;
  @override
  final Assets assets;

  BuildContextImpl({
    required this.assets,
    required this.styles,
  });

  @override
  BuildContext withInherited(
    final InheritedWidget widget,
  ) =>
      BuildContextImpl(
        styles: styles,
        assets: assets,
      )
        .._inheritedWidgets.addAll(_inheritedWidgets)
        .._inheritedWidgets[widget.runtimeType] = widget;

  @override
  Key createDefaultKey() => KeyImpl('_w' + (lastKeyIndex++).toString());

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() {
    if (_inheritedWidgets.containsKey(T)) {
      final atT = _inheritedWidgets[T];
      if (atT is T?) {
        return atT;
      } else {
        assert(
          false,
          'Invalid type, no inherited widget for $T found but found ' + atT.toString(),
        );
        return null;
      }
    } else {
      assert(
        false,
        'No inherited widget with type $T found in tree',
      );
      return null;
    }
  }

  @override
  void setStyle(
    final String className,
    final CssStyleDeclaration css,
  ) =>
      styles[className] = css;
}

extension WidgetExtension on Widget {
  HtmlElement render({
    required final BuildContext context,
  }) {
    final child = this;
    final rendered_child_html = child.renderHtml(
      context: context,
    );
    if (child is HtmlElementCopy) {
      return rendered_child_html;
    } else {
      return HtmlElementCopyImpl(
        other: rendered_child_html,
        idClass: IdClassImpl(
          className: () {
            final rendered_child_css = child.renderCss(
              context: context,
            );
            final current_class = element_classname(
              element: rendered_child_html,
            );
            return [
              if (current_class != null) current_class,
              if (rendered_child_css != null) ...[
                () {
                  final new_class = context.createDefaultKey().className;
                  context.setStyle(new_class, rendered_child_css);
                  return new_class;
                }(),
              ],
            ].join(" ");
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
  }
}

mixin InheritedWidgetMixin implements InheritedWidget {
  Widget get child;

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    return child.render(
      context: context.withInherited(this),
    );
  }

  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) {
    return child.renderCss(
      context: context.withInherited(this),
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
    required this.child,
    required this.data,
    this.key,
  });

  static MediaQueryData? of(
    final BuildContext context,
  ) =>
      context.dependOnInheritedWidgetOfExactType<MediaQuery>()?.data;
}

String resolveUrl({
  required final BuildContext context,
  required final String url,
  required final String pathSeparator,
}) {
  if (url.startsWith('asset://')) {
    return context.assets.local + pathSeparator + url.replaceAll('asset://', '');
  } else if (url.startsWith('#')) {
    final media = MediaQuery.of(context);
    return url + '-' + media!.size.index.toString();
  } else {
    return url;
  }
}
