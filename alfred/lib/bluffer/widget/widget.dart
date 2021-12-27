import '../base/assets.dart';
import '../base/keys.dart';
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
