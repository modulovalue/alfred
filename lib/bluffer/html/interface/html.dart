import '../../css/interface/css.dart';

/// TODO split into immutable, mutable and builder parts.
/// TODO Html node should be a child of a HtmlEntity that has elements and nodes as children.
abstract class HtmlEntity {
  R acceptHtmlEntityOneArg<R, A>(HtmlEntityVisitorOneArg<R, A> v, A a);
}

abstract class HtmlNode implements HtmlEntity {
  R acceptHtmlNodeOneArg<R, A>(HtmlNodeVisitorOneArg<R, A> v, A a);
}

abstract class HtmlElement2 implements HtmlEntity {
  abstract String? className;
  abstract String? id;

  CssStyleDeclaration2 get style;

  List<HtmlEntity> get childNodes;

  R acceptHtmlElementOneArg<R, A>(HtmlElementVisitorOneArg<R, A> v, A a);
}

abstract class DivElement2 implements HtmlElement2 {}

abstract class HeadElement2 implements HtmlElement2 {}

abstract class MetaElement2 implements HtmlElement2 {
  void forEachAttribute(void Function(String key, String value) fn);

  void setAttribute(String key, String value);
}

abstract class BodyElement2 implements HtmlElement2 {}

abstract class StyleElement2 implements HtmlElement2 {}

abstract class ScriptElement2 implements HtmlElement2 {
  abstract String? src;
  abstract bool? async;
  abstract bool? defer;
}

abstract class LinkElement2 implements HtmlElement2 {
  abstract String? href;
  abstract String? rel;
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

  CssStyleDeclaration2 get css;
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

abstract class HtmlElementVisitorOneArg<R, A> {
  R visitElementDiv(DivElement2 node, A arg); //
  R visitElementHead(HeadElement2 node, A arg); //
  R visitElementMeta(MetaElement2 node, A arg); //
  R visitElementBody(BodyElement2 node, A arg); //
  R visitElementStyle(StyleElement2 node, A arg); //
  R visitElementScript(ScriptElement2 node, A arg); //
  R visitElementLink(LinkElement2 node, A arg); //
  R visitElementTitle(TitleElement2 node, A arg); //
  R visitElementHtmlHtml(HtmlHtmlElement2 node, A arg); //
  R visitElementBr(BRElement2 node, A arg); //
  R visitElementParagraph(ParagraphElement2 node, A arg); //
  R visitElementImage(ImageElement2 node, A arg); //
  R visitElementAnchor(AnchorElement2 node, A arg); //
}

abstract class HtmlEntityVisitorOneArg<R, A> {
  R visitEntityElement(HtmlElement2 node, A arg); //
  R visitEntityNode(HtmlNode node, A arg); //
}

abstract class HtmlNodeVisitorOneArg<R, A> {
  R visitNodeText(RawTextElement2 node, A arg); //
  R visitNodeStyle(CssTextElement2 node, A arg); //
}
