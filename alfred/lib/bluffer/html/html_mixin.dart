import '../css/css.dart';
import 'html.dart';

mixin HtmlElementMixin<SELF extends HtmlElementMixin<SELF>> implements HtmlElement<SELF> {
  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );

  @override
  HtmlElement<SELF> append(
    final Iterable<HtmlElement> other,
  ) =>
      HtmlElementAppended(
        this,
        other,
      );

  @override
  HtmlElement<SELF> overwrite({
    final String? className,
    final String? id,
  }) =>
      HtmlElementCopy(
        other: this,
        className: className ?? this.className,
        id: id ?? this.id,
      );
}

class HtmlElementAppended<T extends HtmlElement<T>> implements HtmlElement<T> {
  final HtmlElement other;
  final Iterable<HtmlElement> additional;

  const HtmlElementAppended(
    final this.other,
    final this.additional,
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

  @override
  Iterable<String> get additionalAttributes => other.additionalAttributes;

  @override
  Iterable<HtmlEntity> get childNodes sync* {
    yield* other.childNodes;
    yield* additional;
  }

  @override
  String? get className => other.className;

  @override
  String? get id => other.id;

  @override
  CssStyleDeclaration? get style => other.style;

  @override
  String get tag => other.tag;

  @override
  HtmlElement<T> append(
    final Iterable<HtmlElement> other,
  ) =>
      HtmlElementAppended(
        this,
        other,
      );

  @override
  HtmlElement<T> overwrite({
    final String? className,
    final String? id,
  }) =>
      HtmlElementCopy(
        other: this,
        className: className ?? this.className,
        id: id ?? this.id,
      );
}

class HtmlElementCopy<T extends HtmlElement<T>> implements HtmlElement<T> {
  final HtmlElement<T> other;
  @override
  final String? className;
  @override
  final String? id;

  const HtmlElementCopy({
    required final this.other,
    required final this.className,
    required final this.id,
  });

  @override
  R acceptHtmlEntity<R, A>(
    final HtmlEntityVisitor<R, A> v,
    final A a,
  ) =>
      v.visitEntityElement(
        this,
        a,
      );

  @override
  CssStyleDeclaration? get style => other.style;

  @override
  Iterable<HtmlEntity> get childNodes => other.childNodes;

  @override
  String get tag => other.tag;

  @override
  Iterable<String> get additionalAttributes => other.additionalAttributes;

  @override
  HtmlElement<T> append(
    final Iterable<HtmlElement> other,
  ) =>
      HtmlElementAppended(
        this,
        other,
      );

  @override
  HtmlElement<T> overwrite({
    final String? className,
    final String? id,
  }) =>
      HtmlElementCopy(
        other: this,
        className: className ?? this.className,
        id: id ?? this.id,
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
