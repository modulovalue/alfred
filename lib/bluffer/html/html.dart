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

abstract class HtmlElement implements HtmlEntity {
  /// TODO make this just a getter, needs redirecting nodes.
  abstract String? className;

  /// TODO make this just a getter, needs redirecting nodes.
  abstract String? id;

  CssStyleDeclaration? get style;

  List<HtmlEntity> get childNodes;

  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  );
}

abstract class DivElement implements HtmlElement {}

mixin DivElementMixin implements DivElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementDiv(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class HeadElement implements HtmlElement {}

mixin HeadElementMixin implements HeadElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementHead(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class MetaElement implements HtmlElement {
  void forEachAttribute({
    required final void Function(String key, String value) forEach,
  });

  void setAttribute({
    required final String key,
    required final String value,
  });
}

mixin MetaElementMixin implements MetaElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementMeta(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class BodyElement implements HtmlElement {}

mixin BodyElementMixin implements BodyElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementBody(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class StyleElement implements HtmlElement {}

mixin StyleElementMixin implements StyleElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementStyle(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class ScriptElement implements HtmlElement {
  String? get src;

  bool? get async;

  bool? get defer;

  String? get content;
}

mixin ScriptElementMixin implements ScriptElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementScript(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class LinkElement implements HtmlElement {
  String? get href;

  String? get rel;
}

mixin LinkElementMixin implements LinkElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementLink(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class TitleElement implements HtmlElement {
  String? get text;
}

mixin TitleElementMixin implements TitleElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementTitle(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class HtmlHtmlElement implements HtmlElement {}

mixin HtmlHtmlElementMixin implements HtmlHtmlElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementHtmlHtml(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class RawTextElement implements HtmlNode {
  String get text;
}

mixin RawTextElementMixin implements RawTextElement {
  @override
  R acceptHtmlNodeOneArg<R, A>(
    final HtmlNodeVisitor<R, A> v,
    final A a,
  ) =>
      v.visitNodeText(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityNode(this, a);
}

abstract class CssTextElement implements HtmlNode {
  String get key;

  CssStyleDeclaration get css;
}

mixin CssTextElementMixin implements CssTextElement {
  @override
  R acceptHtmlNodeOneArg<R, A>(
    final HtmlNodeVisitor<R, A> v,
    final A a,
  ) =>
      v.visitNodeStyle(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityNode(this, a);
}

abstract class BRElement implements HtmlElement {}

mixin BRElementMixin implements BRElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementBr(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class ParagraphElement implements HtmlElement {}

mixin ParagraphElementMixin implements ParagraphElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementParagraph(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class ImageElement implements HtmlElement {
  String? get src;

  String? get alt;
}

mixin ImageElementMixin implements ImageElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementImage(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

abstract class AnchorElement implements HtmlElement {
  String? get href;

  String? get target;
}

mixin AnchorElementMixin implements AnchorElement {
  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementAnchor(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
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
