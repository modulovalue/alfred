import '../css/css.dart';
import 'html.dart';

class BRElementImpl with BRElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];

  BRElementImpl();

  @override
  Null get style => null;
}

class HtmlHtmlElementImpl with HtmlHtmlElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;

  HtmlHtmlElementImpl(
    final this.childNodes,
  );

  @override
  Null get style => null;
}

class MetaElementImpl with MetaElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];
  final Map<String, String> attributes = {};

  MetaElementImpl();

  @override
  Null get style => null;

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

class BodyElementImpl with BodyElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;

  BodyElementImpl(
    final this.childNodes,
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

class ScriptElementImpl with ScriptElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];
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
  Null get style => null;
}

class LinkElementImpl with LinkElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];
  @override
  final String? href;
  @override
  final String? rel;

  LinkElementImpl({
    required final this.href,
    required final this.rel,
  });

  @override
  Null get style => null;
}

class TitleElementImpl with TitleElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];
  @override
  final String? text;

  TitleElementImpl({
    required final this.text,
  });

  @override
  Null get style => null;
}

class StyleElementImpl with StyleElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;

  StyleElementImpl(
    final this.childNodes,
  );

  @override
  Null get style => null;
}

class ParagraphElementImpl with ParagraphElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;

  ParagraphElementImpl(
    final this.childNodes,
  );

  @override
  Null get style => null;
}

class ImageElementImpl with ImageElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];
  @override
  final String? alt;
  @override
  final String? src;

  ImageElementImpl({
    required final this.alt,
    required final this.src,
  });

  @override
  Null get style => null;
}

class DivElementImpl with DivElementMixin implements DivElement {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;

  DivElementImpl.make({
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  Null get style => null;
}

class DivElementEmptyImpl with DivElementMixin implements DivElement {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes = [];

  DivElementEmptyImpl();

  @override
  Null get style => null;
}

class AnchorElementImpl with AnchorElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String? href;
  @override
  final String? target;

  AnchorElementImpl({
    required final this.href,
    required final this.target,
    required final this.className,
    required final this.childNodes,
  });

  @override
  Null get style => null;
}

class HeadElementImpl with HeadElementMixin {
  @override
  String? className;
  @override
  String? id;
  @override
  final List<HtmlEntity> childNodes;

  HeadElementImpl(
    final this.childNodes,
  );

  @override
  Null get style => null;
}
