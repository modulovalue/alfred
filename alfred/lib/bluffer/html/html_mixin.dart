import 'html.dart';

mixin DivElementMixin<SELF extends DivElementMixin<SELF>> implements DivElement<SELF> {
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

mixin MetaElementMixin<SELF extends MetaElementMixin<SELF>> implements MetaElement<SELF> {
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

mixin BodyElementMixin<SELF extends BodyElementMixin<SELF>> implements BodyElement<SELF> {
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

mixin CustomElementMixin<SELF extends CustomElementMixin<SELF>> implements CustomElement<SELF> {
  @override
  R acceptHtmlElement<R, A>(
    final HtmlElementVisitor<R, A> v,
    final A a,
  ) =>
      v.visitCustomElementBody(
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

mixin StyleElementMixin<SELF extends StyleElementMixin<SELF>> implements StyleElement<SELF> {
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

mixin ScriptElementMixin<SELF extends ScriptElementMixin<SELF>> implements ScriptElement<SELF> {
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

mixin LinkElementMixin<SELF extends LinkElementMixin<SELF>> implements LinkElement<SELF> {
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

mixin TitleElementMixin<SELF extends TitleElementMixin<SELF>> implements TitleElement<SELF> {
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

mixin HtmlHtmlElementMixin<SELF extends HtmlHtmlElementMixin<SELF>> implements HtmlHtmlElement<SELF> {
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

mixin BRElementMixin<SELF extends BRElementMixin<SELF>> implements BRElement<SELF> {
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

mixin ParagraphElementMixin<SELF extends ParagraphElementMixin<SELF>> implements ParagraphElement<SELF> {
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

mixin ImageElementMixin<SELF extends ImageElementMixin<SELF>> implements ImageElement<SELF> {
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

mixin AnchorElementMixin<SELF extends AnchorElementMixin<SELF>> implements AnchorElement<SELF> {
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
