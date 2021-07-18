import '../../../base/keys.dart';
import '../../../css/css.dart';
import '../../../html/html.dart';
import 'build_context.dart';

abstract class KeyWidget<KEY extends Key?> {
  KEY get key;
}

abstract class HtmlWidget<HTML extends HtmlElement2> {
  HTML renderHtml(
    final BuildContext context,
  );
}

abstract class CssWidget<CSS extends CssStyleDeclaration?> {
  CSS renderCss(
    final BuildContext context,
  );
}

abstract class HtmlCssWidget<
        HTML extends HtmlElement2,
        CSS extends CssStyleDeclaration? //
        > //
    implements
        HtmlWidget<HTML>,
        CssWidget<CSS> {}

abstract class KeyedHtmlCssWidget<
        HTML extends HtmlElement2,
        CSS extends CssStyleDeclaration?,
        KEY extends Key? //
        > //
    implements
        HtmlCssWidget<HTML, CSS>,
        KeyWidget<KEY> {}

abstract class RenderWidget<RENDER extends HtmlElement2> {
  RENDER render(
    final BuildContext context,
  );
}

abstract class Widget<
        KEY extends Key?,
        HTML extends HtmlElement2,
        CSS extends CssStyleDeclaration?,
        RENDER extends HtmlElement2 //
        > //
    implements
        KeyedHtmlCssWidget<HTML, CSS, KEY>,
        RenderWidget<RENDER> {}
