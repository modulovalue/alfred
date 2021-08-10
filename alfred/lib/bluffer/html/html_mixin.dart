import 'html.dart';

// TODO thread SELF through all mixins.
mixin DivElementMixin implements DivElement<DivElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementDiv(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin HeadElementMixin<SELF extends HeadElement<SELF>> implements HeadElement<SELF> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementHead(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin MetaElementMixin implements MetaElement<MetaElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementMeta(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin BodyElementMixin implements BodyElement<BodyElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementBody(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin StyleElementMixin implements StyleElement<StyleElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementStyle(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin ScriptElementMixin implements ScriptElement<ScriptElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementScript(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin LinkElementMixin implements LinkElement<LinkElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementLink(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin TitleElementMixin implements TitleElement<TitleElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementTitle(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin HtmlHtmlElementMixin implements HtmlHtmlElement<HtmlHtmlElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementHtmlHtml(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin BRElementMixin implements BRElement<BRElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementBr(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin ParagraphElementMixin implements ParagraphElement<ParagraphElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementParagraph(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin ImageElementMixin implements ImageElement<ImageElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementImage(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin AnchorElementMixin implements AnchorElement<AnchorElementMixin> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitElementAnchor(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );
}

mixin RawTextElementMixin implements RawTextElement {
  @override
  R acceptHtmlNode<R, A>(
    final HtmlNodeVisitor<R, A> v,
    final A a,
  ) =>
      v.visitNodeText(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityNode(
        this,
        a,
      );
}

mixin CssTextElementMixin implements CssTextElement {
  @override
  R acceptHtmlNode<R, A>(
    final HtmlNodeVisitor<R, A> v,
    final A a,
  ) =>
      v.visitNodeStyle(
        this,
        a,
      );

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityNode(
        this,
        a,
      );
}
