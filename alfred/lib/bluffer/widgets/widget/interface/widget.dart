import '../../../base/assets.dart';
import '../../../base/keys.dart';
import '../../../css/css.dart';
import '../../../html/html.dart';

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
