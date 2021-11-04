import '../css/css.dart';
import 'html.dart';
import 'html_mixin.dart';

class BRElementImpl with BRElementMixin<BRElementImpl> {
  @override
  final String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;

  BRElementImpl({
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  Null get style => null;

  @override
  BRElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      BRElementImpl(
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );
}

class HtmlHtmlElementImpl with HtmlHtmlElementMixin<HtmlHtmlElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  HtmlHtmlElementImpl({
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  Null get style => null;

  @override
  HtmlHtmlElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      HtmlHtmlElementImpl(
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );
}

class MetaElementImpl with MetaElementMixin<MetaElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final Map<String, String> attributes;

  MetaElementImpl({
    required final this.childNodes,
    required final this.attributes,
    final this.className,
    final this.id,
  });

  @override
  Null get style => null;

  @override
  MetaElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      MetaElementImpl(
        childNodes: childNodes,
        attributes: attributes,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  void setAttribute({
    required final String key,
    required final String value,
  }) =>
      attributes[key] = value;

  @override
  void forEachAttribute({
    required final void Function(String key, String value) forEach,
  }) =>
      attributes.forEach(forEach);
}

class BodyElementImpl with BodyElementMixin<BodyElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  BodyElementImpl({
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  BodyElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      BodyElementImpl(
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}

class CustomElementImpl with CustomElementMixin<CustomElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String tag;
  @override
  final Iterable<String> additionalAttributes;

  const CustomElementImpl({
    required final this.tag,
    required final this.additionalAttributes,
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  CustomElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      CustomElementImpl(
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
        tag: tag,
        additionalAttributes: additionalAttributes,
      );

  @override
  Null get style => null;
}

class RawTextElementImpl with RawTextElementMixin {
  @override
  final String text;

  const RawTextElementImpl(
    final this.text,
  );
}

class CssTextElementImpl with CssTextElementMixin {
  @override
  final String key;
  @override
  final CssStyleDeclaration css;

  const CssTextElementImpl(
    final this.key,
    final this.css,
  );
}

// TODO support integrity
// TODO support crossorigin
// TODO support rel
class ScriptElementImpl with ScriptElementMixin<ScriptElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final bool? async;
  @override
  final bool? defer;
  @override
  final String? src;
  @override
  final String? content;

  ScriptElementImpl({
    required final this.childNodes,
    final this.async,
    final this.defer,
    final this.src,
    final this.content,
    final this.className,
    final this.id,
  });

  @override
  ScriptElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      ScriptElementImpl(
        childNodes: childNodes,
        async: async,
        defer: defer,
        src: src,
        content: content,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}

class LinkElementImpl with LinkElementMixin<LinkElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String? href;
  @override
  final String? rel;

  LinkElementImpl({
    required final this.href,
    required final this.rel,
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  LinkElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      LinkElementImpl(
        href: href,
        rel: rel,
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}

class TitleElementImpl with TitleElementMixin<TitleElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String? text;

  TitleElementImpl({
    required final this.childNodes,
    required final this.text,
    final this.className,
    final this.id,
  });

  @override
  TitleElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      TitleElementImpl(
        childNodes: childNodes,
        text: text,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}

class StyleElementImpl with StyleElementMixin<StyleElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  StyleElementImpl({
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  StyleElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      StyleElementImpl(
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}

class ParagraphElementImpl with ParagraphElementMixin<ParagraphElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  ParagraphElementImpl({
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  ParagraphElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      ParagraphElementImpl(
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}

class ImageElementImpl with ImageElementMixin<ImageElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String? alt;
  @override
  final String? src;

  ImageElementImpl({
    required final this.alt,
    required final this.src,
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  ImageElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      ImageElementImpl(
        alt: alt,
        src: src,
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}

class DivElementImpl with DivElementMixin<DivElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  DivElementImpl({
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  DivElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      DivElementImpl(
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}

class AnchorElementImpl with AnchorElementMixin<AnchorElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String? href;
  @override
  final String? target;

  AnchorElementImpl({
    required final this.href,
    required final this.target,
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  AnchorElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      AnchorElementImpl(
        href: href,
        target: target,
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}

class HeadElementImpl with HeadElementMixin<HeadElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  HeadElementImpl({
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  HeadElementImpl copyWith({
    final String? className,
    final String? id,
  }) =>
      HeadElementImpl(
        childNodes: childNodes,
        className: className ?? this.className,
        id: id ?? this.id,
      );

  @override
  Null get style => null;
}
