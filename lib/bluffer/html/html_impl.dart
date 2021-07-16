import '../css/css.dart';
import '../css/empty.dart';
import 'html.dart';

mixin HtmlElementMixin2 implements HtmlElement2 {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];

  @override
  CssStyleDeclaration2EmptyImpl get style => const CssStyleDeclaration2EmptyImpl();
}

class BRElement2Impl with HtmlElementMixin2 implements BRElement2 {
  BRElement2Impl();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementBr(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class HtmlHtmlElement2Impl with HtmlElementMixin2 implements HtmlHtmlElement2 {
  factory HtmlHtmlElement2Impl.make(
    final Iterable<HtmlEntity> nodes,
  ) {
    final node = HtmlHtmlElement2Impl._();
    node.childNodes.addAll(nodes);
    return node;
  }

  HtmlHtmlElement2Impl._();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementHtmlHtml(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class MetaElement2Impl with HtmlElementMixin2 implements MetaElement2 {
  final Map<String, String> attributes = {};

  MetaElement2Impl();

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
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementMeta(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class BodyElement2Impl with HtmlElementMixin2 implements BodyElement2 {
  factory BodyElement2Impl.make(
    final Iterable<HtmlEntity> nodes,
  ) {
    final node = BodyElement2Impl._();
    node.childNodes.addAll(nodes);
    return node;
  }

  BodyElement2Impl._();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementBody(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class RawTextElement2Impl implements RawTextElement2 {
  @override
  final String text;

  const RawTextElement2Impl(
    final this.text,
  );

  @override
  R acceptHtmlNodeOneArg<R, A>(
    final HtmlNodeVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitNodeText(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityNode(this, a);
}

class CssTextElement2Impl implements CssTextElement2 {
  @override
  final String key;
  @override
  final CssStyleDeclaration2 css;

  const CssTextElement2Impl(
    final this.key,
    final this.css,
  );

  @override
  R acceptHtmlNodeOneArg<R, A>(
    final HtmlNodeVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitNodeStyle(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityNode(this, a);
}

// Makes this immutable.
class ScriptElement2Impl with HtmlElementMixin2 implements ScriptElement2 {
  @override
  bool? async;
  @override
  bool? defer;
  @override
  String? src;

  ScriptElement2Impl();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementScript(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class LinkElement2Impl with HtmlElementMixin2 implements LinkElement2 {
  @override
  String? href;
  @override
  String? rel;

  LinkElement2Impl({
    required final this.href,
    required final this.rel,
  });

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementLink(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class TitleElement2Impl with HtmlElementMixin2 implements TitleElement2 {
  @override
  String? text;

  TitleElement2Impl();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementTitle(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class StyleElement2Impl with HtmlElementMixin2 implements StyleElement2 {
  factory StyleElement2Impl.make(
    final Iterable<HtmlEntity> nodes,
  ) {
    final node = StyleElement2Impl._();
    node.childNodes.addAll(nodes);
    return node;
  }

  StyleElement2Impl._();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementStyle(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class ParagraphElement2Impl with HtmlElementMixin2 implements ParagraphElement2 {
  ParagraphElement2Impl();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementParagraph(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class ImageElement2Impl with HtmlElementMixin2 implements ImageElement2 {
  @override
  String? alt;
  @override
  String? src;

  ImageElement2Impl();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementImage(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class DivElement2Impl implements DivElement2 {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final CssStyleDeclaration2 style;

  DivElement2Impl.empty()
      : childNodes = [],
        style = const CssStyleDeclaration2EmptyImpl(),
        className = null,
        id = null;

  DivElement2Impl.make({
    required final this.className,
    required final this.id,
    required final this.childNodes,
  }) : style = const CssStyleDeclaration2EmptyImpl();

  DivElement2Impl.custom(
    final this.style,
  )   : className = null,
        id = null,
        childNodes = [];

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementDiv(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class AnchorElement2Impl with HtmlElementMixin2 implements AnchorElement2 {
  @override
  String? href;
  @override
  String? target;

  AnchorElement2Impl();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementAnchor(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}

class HeadElement2Impl with HtmlElementMixin2 implements HeadElement2 {
  factory HeadElement2Impl.make(
    final Iterable<HtmlEntity> children,
  ) {
    final node = HeadElement2Impl._();
    node.childNodes.addAll(children);
    return node;
  }

  HeadElement2Impl._();

  @override
  R acceptHtmlElementOneArg<R, A>(
    final HtmlElementVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitElementHead(this, a);

  @override
  R acceptHtmlEntityOneArg<R, A>(
    final HtmlEntityVisitorOneArg<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(this, a);
}
