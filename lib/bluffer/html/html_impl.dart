import '../css/css.dart';
import '../css/empty.dart';
import 'html.dart';

mixin HtmlElementMixin implements HtmlElement2 {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];

  @override
  CssStyleDeclaration2 get style;
}

class BRElement2Impl with HtmlElementMixin implements BRElement2 {
  BRElement2Impl();

  @override
  CssStyleDeclaration2EmptyImpl get style => const CssStyleDeclaration2EmptyImpl();

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

class HtmlHtmlElement2Impl with HtmlElementMixin implements HtmlHtmlElement2 {
  factory HtmlHtmlElement2Impl.make(
    final Iterable<HtmlEntity> nodes,
  ) {
    final node = HtmlHtmlElement2Impl._();
    node.childNodes.addAll(nodes);
    return node;
  }

  HtmlHtmlElement2Impl._();

  @override
  CssStyleDeclaration2EmptyImpl get style => const CssStyleDeclaration2EmptyImpl();

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

class MetaElement2Impl with HtmlElementMixin implements MetaElement2 {
  final Map<String, String> attributes = {};

  MetaElement2Impl();

  @override
  CssStyleDeclaration2EmptyImpl get style => const CssStyleDeclaration2EmptyImpl();

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

class BodyElement2Impl with HtmlElementMixin implements BodyElement2 {
  factory BodyElement2Impl.make(
    final Iterable<HtmlEntity> nodes,
  ) {
    final node = BodyElement2Impl._();
    node.childNodes.addAll(nodes);
    return node;
  }

  BodyElement2Impl._();

  @override
  CssStyleDeclaration2 get style => const CssStyleDeclaration2EmptyImpl();

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

class ScriptElement2Impl with HtmlElementMixin implements ScriptElement2 {
  @override
  bool? async;
  @override
  bool? defer;
  @override
  String? src;

  ScriptElement2Impl();

  @override
  CssStyleDeclaration2 get style => const CssStyleDeclaration2EmptyImpl();

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

class LinkElement2Impl with HtmlElementMixin implements LinkElement2 {
  @override
  String? href;
  @override
  String? rel;

  LinkElement2Impl({
    required final this.href,
    required final this.rel,
  });

  @override
  CssStyleDeclaration2EmptyImpl get style => const CssStyleDeclaration2EmptyImpl();

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

class TitleElement2Impl with HtmlElementMixin implements TitleElement2 {
  @override
  String? text;

  TitleElement2Impl();

  @override
  CssStyleDeclaration2 get style => const CssStyleDeclaration2EmptyImpl();

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

class StyleElement2Impl with HtmlElementMixin implements StyleElement2 {
  factory StyleElement2Impl.make(
    final Iterable<HtmlEntity> nodes,
  ) {
    final node = StyleElement2Impl._();
    node.childNodes.addAll(nodes);
    return node;
  }

  StyleElement2Impl._();

  @override
  CssStyleDeclaration2 get style => const CssStyleDeclaration2EmptyImpl();

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

class ParagraphElement2Impl with HtmlElementMixin implements ParagraphElement2 {
  ParagraphElement2Impl();

  @override
  CssStyleDeclaration2 get style => const CssStyleDeclaration2EmptyImpl();

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

class ImageElement2Impl with HtmlElementMixin implements ImageElement2 {
  @override
  String? alt;
  @override
  String? src;

  ImageElement2Impl();

  @override
  CssStyleDeclaration2 get style => const CssStyleDeclaration2EmptyImpl();

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

class DivElement2Impl with HtmlElementMixin implements DivElement2 {
  @override
  // ignore: overridden_fields
  final CssStyleDeclaration2 style;

  DivElement2Impl() : style = const CssStyleDeclaration2EmptyImpl();

  DivElement2Impl.custom(this.style);

  factory DivElement2Impl.make({
    required String className,
    required Iterable<HtmlEntity> nodes,
  }) {
    final node = DivElement2Impl();
    node.className = className;
    node.childNodes.addAll(nodes);
    return node;
  }

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

class AnchorElement2Impl with HtmlElementMixin implements AnchorElement2 {
  @override
  String? href;
  @override
  String? target;

  AnchorElement2Impl();

  @override
  CssStyleDeclaration2 get style => const CssStyleDeclaration2EmptyImpl();

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

class HeadElement2Impl with HtmlElementMixin implements HeadElement2 {
  factory HeadElement2Impl.make(
    final Iterable<HtmlEntity> children,
  ) {
    final node = HeadElement2Impl._();
    node.childNodes.addAll(children);
    return node;
  }

  HeadElement2Impl._();

  @override
  CssStyleDeclaration2 get style => const CssStyleDeclaration2EmptyImpl();

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
