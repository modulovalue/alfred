import '../css/css.dart';

abstract class HtmlEntity {
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  );
}

abstract class HtmlNode implements HtmlEntity {
  R acceptHtmlNodeOneArg<R, A>(
    final HtmlNodeVisitor<R, A> v,
    final A a,
  );
}

abstract class HtmlElement2 implements HtmlEntity {
  abstract String? className;
  abstract String? id;

  CssStyleDeclaration get style;

  List<HtmlEntity> get childNodes;

  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  );
}

abstract class DivElement2 implements HtmlElement2 {}

abstract class HeadElement2 implements HtmlElement2 {}

abstract class MetaElement2 implements HtmlElement2 {
  void forEachAttribute(
    final void Function(String key, String value) fn,
  );

  void setAttribute(
    final String key,
    final String value,
  );
}

abstract class BodyElement2 implements HtmlElement2 {}

abstract class StyleElement2 implements HtmlElement2 {}

abstract class ScriptElement2 implements HtmlElement2 {
  abstract String? src;
  abstract bool? async;
  abstract bool? defer;
}

abstract class LinkElement2 implements HtmlElement2 {
  String? get href;

  String? get rel;
}

abstract class TitleElement2 implements HtmlElement2 {
  abstract String? text;
}

abstract class HtmlHtmlElement2 implements HtmlElement2 {}

abstract class RawTextElement2 implements HtmlNode {
  String get text;
}

abstract class CssTextElement2 implements HtmlNode {
  String get key;

  CssStyleDeclaration get css;
}

abstract class BRElement2 implements HtmlElement2 {}

abstract class ParagraphElement2 implements HtmlElement2 {}

abstract class ImageElement2 implements HtmlElement2 {
  abstract String? src;
  abstract String? alt;
}

abstract class AnchorElement2 implements HtmlElement2 {
  abstract String? href;
  abstract String? target;
}

abstract class HtmlElementVisitor<R, A> {
  R visitElementDiv(
    final DivElement2 node,
    final A arg,
  );

  R visitElementHead(
    final HeadElement2 node,
    final A arg,
  );

  R visitElementMeta(
    final MetaElement2 node,
    final A arg,
  );

  R visitElementBody(
    final BodyElement2 node,
    final A arg,
  );

  R visitElementStyle(
    final StyleElement2 node,
    final A arg,
  );

  R visitElementScript(
    final ScriptElement2 node,
    final A arg,
  );

  R visitElementLink(
    final LinkElement2 node,
    final A arg,
  );

  R visitElementTitle(
    final TitleElement2 node,
    final A arg,
  );

  R visitElementHtmlHtml(
    final HtmlHtmlElement2 node,
    final A arg,
  );

  R visitElementBr(
    final BRElement2 node,
    final A arg,
  );

  R visitElementParagraph(
    final ParagraphElement2 node,
    final A arg,
  );

  R visitElementImage(
    final ImageElement2 node,
    final A arg,
  );

  R visitElementAnchor(
    final AnchorElement2 node,
    final A arg,
  );
}

abstract class HtmlEntityVisitor<R, A> {
  R visitEntityElement(
    final HtmlElement2 node,
    final A arg,
  );

  R visitEntityNode(
    final HtmlNode node,
    final A arg,
  );
}

abstract class HtmlNodeVisitor<R, A> {
  R visitNodeText(
    final RawTextElement2 node,
    final A arg,
  );

  R visitNodeStyle(
    final CssTextElement2 node,
    final A arg,
  );
}
