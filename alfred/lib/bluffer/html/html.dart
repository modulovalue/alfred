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

  Iterable<HtmlEntity> get childNodes;

  String get tag;

  Iterable<String> get additionalAttributes;

  HtmlElement<SELF> append(
    final Iterable<HtmlElement> other,
  );

  HtmlElement<SELF> overwrite({
    final String? className,
    final String? id,
  });
}

abstract class RawTextElement implements HtmlNode {
  String get text;
}

abstract class CssTextElement implements HtmlNode {
  String get key;

  CssStyleDeclaration get css;
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
