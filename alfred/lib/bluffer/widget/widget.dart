import '../base/assets.dart';
import '../base/keys.dart';
import '../base/media_query_data.dart';
import '../html/html.dart';

mixin WidgetSelfCSS implements Widget, CssStyleDeclaration {
  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      this;
}

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

  HtmlElement renderElement({
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
    required final this.assets,
    required final this.styles,
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

HtmlElement renderWidget({
  required final Widget child,
  required final BuildContext context,
}) {
  final renderedChildHtml = child.renderHtml(
    context: context,
  );
  return HtmlElementCopyImpl(
    other: renderedChildHtml,
    idClass: IdClassImpl(
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
          final currentClass = elementClassname(
            element: renderedChildHtml,
          );
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
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final newContext = context.withInherited(this);
    return child.renderHtml(
      context: newContext,
    );
  }

  @override
  HtmlElement renderElement({
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
