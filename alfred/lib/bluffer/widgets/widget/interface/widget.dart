import '../../../base/keys.dart';
import '../../../css/css.dart';
import '../../../html/html.dart';
import 'build_context.dart';

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
