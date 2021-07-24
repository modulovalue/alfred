import '../../../base/keys.dart';
import '../../../css/css.dart';
import '../../../html/html.dart';
import 'build_context.dart';

abstract class Widget<
    KEY extends Key?,
    HTML extends HtmlElement,
    CSS extends CssStyleDeclaration?,
    RENDER extends HtmlElement //
    > {
  KEY get key;

  HTML renderHtml({
    required final BuildContext context,
  });

  CSS renderCss({
    required final BuildContext context,
  });

  RENDER render({
    required final BuildContext context,
  });
}
