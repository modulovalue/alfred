import '../css/css.dart';

// TODO have mixins with already implemented visitors.
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

abstract class HtmlElement implements HtmlEntity {
  /// TODO make this just a getter, needs redirecting nodes.
  abstract String? className;
  /// TODO make this just a getter, needs redirecting nodes.
  abstract String? id;

  CssStyleDeclaration get style;

  List<HtmlEntity> get childNodes;

  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  );
}

abstract class DivElement implements HtmlElement {}

abstract class HeadElement implements HtmlElement {}

abstract class MetaElement implements HtmlElement {
  void forEachAttribute(
    final void Function(String key, String value) fn,
  );

  void setAttribute(
    final String key,
    final String value,
  );
}

abstract class BodyElement implements HtmlElement {}

abstract class StyleElement implements HtmlElement {}

abstract class ScriptElement implements HtmlElement {
  String? get src;

  bool? get async;

  bool? get defer;

  String? get content;
}

abstract class LinkElement implements HtmlElement {
  String? get href;

  String? get rel;
}

abstract class TitleElement implements HtmlElement {
  String? get text;
}

abstract class HtmlHtmlElement implements HtmlElement {}

abstract class RawTextElement implements HtmlNode {
  String get text;
}

abstract class CssTextElement implements HtmlNode {
  String get key;

  CssStyleDeclaration get css;
}

abstract class BRElement implements HtmlElement {}

abstract class ParagraphElement implements HtmlElement {}

abstract class ImageElement implements HtmlElement {
  String? get src;
  String? get alt;
}

abstract class AnchorElement implements HtmlElement {
  String? get href;
  String? get target;
}

abstract class HtmlElementVisitor<R, A> {
  R visitElementDiv(
    final DivElement node,
    final A arg,
  );

  R visitElementHead(
    final HeadElement node,
    final A arg,
  );

  R visitElementMeta(
    final MetaElement node,
    final A arg,
  );

  R visitElementBody(
    final BodyElement node,
    final A arg,
  );

  R visitElementStyle(
    final StyleElement node,
    final A arg,
  );

  R visitElementScript(
    final ScriptElement node,
    final A arg,
  );

  R visitElementLink(
    final LinkElement node,
    final A arg,
  );

  R visitElementTitle(
    final TitleElement node,
    final A arg,
  );

  R visitElementHtmlHtml(
    final HtmlHtmlElement node,
    final A arg,
  );

  R visitElementBr(
    final BRElement node,
    final A arg,
  );

  R visitElementParagraph(
    final ParagraphElement node,
    final A arg,
  );

  R visitElementImage(
    final ImageElement node,
    final A arg,
  );

  R visitElementAnchor(
    final AnchorElement node,
    final A arg,
  );
}

abstract class HtmlEntityVisitor<R, A> {
  R visitEntityElement(
    final HtmlElement node,
    final A arg,
  );

  R visitEntityNode(
    final HtmlNode node,
    final A arg,
  );
}

abstract class HtmlNodeVisitor<R, A> {
  R visitNodeText(
    final RawTextElement node,
    final A arg,
  );

  R visitNodeStyle(
    final CssTextElement node,
    final A arg,
  );
}
