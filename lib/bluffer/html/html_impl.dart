import '../css/css.dart';
import '../css/empty.dart';
import 'html.dart';

mixin HtmlElementMixin implements HtmlElement {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];

  @override
  CssStyleDeclaration2EmptyImpl get style => const CssStyleDeclaration2EmptyImpl();
}

class BRElementImpl with HtmlElementMixin implements BRElement {
  BRElementImpl();

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

class HtmlHtmlElementImpl with HtmlElementMixin implements HtmlHtmlElement {
  factory HtmlHtmlElementImpl.make(
    final Iterable<HtmlEntity> nodes,
  ) {
    final node = HtmlHtmlElementImpl._();
    node.childNodes.addAll(nodes);
    return node;
  }

  HtmlHtmlElementImpl._();

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

class MetaElementImpl with HtmlElementMixin implements MetaElement {
  final Map<String, String> attributes = {};

  MetaElementImpl();

  @override
  void setAttribute(
    final String key,
    final String value,
  ) =>
      attributes[key] = value;

  @override
  void forEachAttribute(
    final void Function(String key, String value) fn,
  ) =>
      attributes.forEach(fn);

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

class BodyElementImpl with HtmlElementMixin implements BodyElement {
  factory BodyElementImpl.make(
    final Iterable<HtmlEntity> nodes,
  ) {
    final node = BodyElementImpl._();
    node.childNodes.addAll(nodes);
    return node;
  }

  BodyElementImpl._();

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

class RawTextElementImpl implements RawTextElement {
  @override
  final String text;

  const RawTextElementImpl(
    final this.text,
  );

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

class CssTextElementImpl implements CssTextElement {
  @override
  final String key;
  @override
  final CssStyleDeclaration css;

  const CssTextElementImpl(
    final this.key,
    final this.css,
  );

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

class ScriptElementImpl with HtmlElementMixin implements ScriptElement {
  @override
  final bool? async;
  @override
  final bool? defer;
  @override
  final String? src;
  @override
  final String? content;

  ScriptElementImpl({
    final this.async,
    final this.defer,
    final this.src,
    final this.content,
  });

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

class LinkElementImpl with HtmlElementMixin implements LinkElement {
  @override
  final String? href;
  @override
  final String? rel;

  LinkElementImpl({
    required final this.href,
    required final this.rel,
  });

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

class TitleElementImpl with HtmlElementMixin implements TitleElement {
  @override
  final String? text;

  TitleElementImpl({
    required final this.text,
  });

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

class StyleElementImpl with HtmlElementMixin implements StyleElement {
  factory StyleElementImpl.make(
    final Iterable<HtmlEntity> nodes,
  ) {
    final node = StyleElementImpl._();
    node.childNodes.addAll(nodes);
    return node;
  }

  StyleElementImpl._();

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

class ParagraphElementImpl with HtmlElementMixin implements ParagraphElement {
  ParagraphElementImpl();

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

class ImageElementImpl with HtmlElementMixin implements ImageElement {
  @override
  final String? alt;
  @override
  final String? src;

  ImageElementImpl({
    required final this.alt,
    required final this.src,
  });

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

class DivElementImpl implements DivElement {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final CssStyleDeclaration style;

  DivElementImpl.empty()
      : childNodes = [],
        style = const CssStyleDeclaration2EmptyImpl(),
        className = null,
        id = null;

  DivElementImpl.make({
    required final this.className,
    required final this.id,
    required final this.childNodes,
  }) : style = const CssStyleDeclaration2EmptyImpl();

  DivElementImpl.custom(
    final this.style,
  )   : className = null,
        id = null,
        childNodes = [];

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

class AnchorElementImpl with HtmlElementMixin implements AnchorElement {
  @override
  final String? href;
  @override
  final String? target;

  AnchorElementImpl({
    required final this.href,
    required final this.target,
  });

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

class HeadElementImpl with HtmlElementMixin implements HeadElement {
  factory HeadElementImpl.make(
    final Iterable<HtmlEntity> children,
  ) {
    // TODO pass children directly to the element.
    final node = HeadElementImpl._();
    node.childNodes.addAll(children);
    return node;
  }

  HeadElementImpl._();

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
