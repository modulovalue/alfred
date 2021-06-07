import '../../../base/keys.dart';
import '../../../css/interface/css.dart';
import '../../../html/interface/html.dart';
import 'build_context.dart';

abstract class KeyWidget<KEY extends Key?> {
  KEY get key;
}

abstract class HtmlWidget<HTML extends HtmlElement2> {
  HTML renderHtml(BuildContext context);
}

abstract class CssWidget<CSS extends CssStyleDeclaration2?> {
  CSS renderCss(BuildContext context);
}

abstract class HtmlCssWidget<
        HTML extends HtmlElement2,
        CSS extends CssStyleDeclaration2? //
        > //
    implements
        HtmlWidget<HTML>,
        CssWidget<CSS> {}

abstract class KeyedHtmlCssWidget<
        HTML extends HtmlElement2,
        CSS extends CssStyleDeclaration2?,
        KEY extends Key? //
        > //
    implements
        HtmlCssWidget<HTML, CSS>,
        KeyWidget<KEY> {}

abstract class RenderWidget<RENDER extends HtmlElement2> {
  RENDER render(BuildContext context);
}

abstract class Widget<
        KEY extends Key?,
        HTML extends HtmlElement2,
        CSS extends CssStyleDeclaration2?,
        RENDER extends HtmlElement2 //
        > //
    implements
        KeyedHtmlCssWidget<HTML, CSS, KEY>,
        RenderWidget<RENDER> {}
