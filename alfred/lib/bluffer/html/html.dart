import '../css/css.dart';

abstract class HtmlEntity {
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  );
}

abstract class HtmlNode implements HtmlEntity {
  R acceptHtmlNode<R, A>(
    final HtmlNodeVisitor<R, A> v,
    final A a,
  );
}

abstract class HtmlElement<SELF extends HtmlElement<SELF>> implements HtmlEntity {
  String? get className;

  String? get id;

  CssStyleDeclaration? get style;

  // TODO it would be great if this wouldn't need to depend on List.
  // TODO copy with childNodes?
  List<HtmlEntity> get childNodes;

  SELF copyWith({
    final String? className,
    final String? id,
  });

  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  );
}

abstract class DivElement<SELF extends DivElement<SELF>> implements HtmlElement<SELF> {}

abstract class HeadElement<SELF extends HeadElement<SELF>> implements HtmlElement<SELF> {}

abstract class MetaElement<SELF extends MetaElement<SELF>> implements HtmlElement<SELF> {
  void forEachAttribute({
    required final void Function(
      String key,
      String value,
    )
        forEach,
  });

  void setAttribute({
    required final String key,
    required final String value,
  });
}

abstract class BodyElement<SELF extends BodyElement<SELF>> implements HtmlElement<SELF> {}

abstract class CustomElement<SELF extends CustomElement<SELF>> implements HtmlElement<SELF> {
  String get tag;

  Iterable<String> get additionalAttributes;
}

abstract class StyleElement<SELF extends StyleElement<SELF>> implements HtmlElement<SELF> {}

abstract class ScriptElement<SELF extends ScriptElement<SELF>> implements HtmlElement<SELF> {
  String? get src;

  bool? get async;

  bool? get defer;

  String? get content;
}

abstract class LinkElement<SELF extends LinkElement<SELF>> implements HtmlElement<SELF> {
  String? get href;

  String? get rel;
}

abstract class TitleElement<SELF extends TitleElement<SELF>> implements HtmlElement<SELF> {
  String? get text;
}

abstract class HtmlHtmlElement<SELF extends HtmlHtmlElement<SELF>> implements HtmlElement<SELF> {}

abstract class BRElement<SELF extends BRElement<SELF>> implements HtmlElement<SELF> {}

abstract class ParagraphElement<SELF extends ParagraphElement<SELF>> implements HtmlElement<SELF> {}

abstract class ImageElement<SELF extends ImageElement<SELF>> implements HtmlElement<SELF> {
  String? get src;

  String? get alt;
}

abstract class AnchorElement<SELF extends AnchorElement<SELF>> implements HtmlElement<SELF> {
  String? get href;

  String? get target;
}

abstract class RawTextElement implements HtmlNode {
  String get text;
}

abstract class CssTextElement implements HtmlNode {
  String get key;

  CssStyleDeclaration get css;
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

  R visitCustomElementBody(
    final CustomElement node,
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
