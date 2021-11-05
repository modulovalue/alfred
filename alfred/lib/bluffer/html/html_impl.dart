import '../css/css.dart';
import 'html.dart';
import 'html_mixin.dart';

class BRElementImpl with HtmlElementMixin<BRElementImpl> {
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
  Iterable<String> get additionalAttributes => const [];

  @override
  String get tag => "br";
}

class HtmlHtmlElementImpl with HtmlElementMixin<HtmlHtmlElementImpl> {
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
  Iterable<String> get additionalAttributes => const [];

  @override
  String get tag => "html";
}

class MetaElementImpl with HtmlElementMixin<MetaElementImpl> {
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
  Iterable<String> get additionalAttributes {
    final _attributes = <String>[];
    attributes.forEach(
      (final key, final value) => _attributes.add(
        key + '="' + value + '"',
      ),
    );
    return _attributes;
  }

  @override
  String get tag => "meta";
}

class BodyElementImpl with HtmlElementMixin<BodyElementImpl> {
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
  Null get style => null;

  @override
  Iterable<String> get additionalAttributes => const [];

  @override
  String get tag => "body";
}

class CustomElementImpl with HtmlElementMixin<CustomElementImpl> {
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

abstract class ScriptElement<SELF extends ScriptElement<SELF>> implements HtmlElement<SELF> {
  bool? get async;

  bool? get defer;

  String? get src;

  String? get content;
}

// TODO support integrity
// TODO support crossorigin
// TODO support rel
class ScriptElementImpl with HtmlElementMixin<ScriptElementImpl> implements ScriptElement<ScriptElementImpl> {
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

  const ScriptElementImpl({
    required final this.childNodes,
    final this.async,
    final this.defer,
    final this.src,
    final this.content,
    final this.className,
    final this.id,
  });

  @override
  Null get style => null;

  @override
  Iterable<String> get additionalAttributes sync* {
    final _src = src;
    if (_src != null) {
      yield 'src="' + _src + '"';
    }
    final _async = async;
    if (_async != null) {
      yield 'async="' + _async.toString() + '"';
    }
    final _defer = defer;
    if (_defer != null) {
      yield 'defer="' + _defer.toString() + '"';
    }
  }

  @override
  String get tag => "script";
}

class LinkElementImpl with HtmlElementMixin<LinkElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final String? href;
  final String? rel;

  LinkElementImpl({
    required final this.href,
    required final this.rel,
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  Null get style => null;

  @override
  Iterable<String> get additionalAttributes sync* {
    final _href = href;
    if (_href != null) {
      yield 'href="' + _href + '"';
    }
    final _rel = rel;
    if (_rel != null) {
      yield 'rel="' + _rel + '"';
    }
  }

  @override
  String get tag => "link";
}

class TitleElementImpl with HtmlElementMixin<TitleElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  final String? text;

  TitleElementImpl({
    required final this.text,
    final this.className,
    final this.id,
  });

  @override
  Iterable<HtmlEntity> get childNodes sync* {
    yield RawTextElementImpl(
      text ?? "",
    );
  }

  @override
  Null get style => null;

  @override
  Iterable<String> get additionalAttributes => const [];

  @override
  String get tag => "title";
}

// TODO find a way to remove the is check for this element where this element is is'ed
class StyleElementImpl with HtmlElementMixin<StyleElementImpl> {
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
  Null get style => null;

  @override
  Iterable<String> get additionalAttributes => [];

  @override
  String get tag => "style";
}

class ImageElementImpl with HtmlElementMixin<ImageElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final String? alt;
  final String? src;

  ImageElementImpl({
    required final this.alt,
    required final this.src,
    required final this.childNodes,
    final this.className,
    final this.id,
  });

  @override
  Null get style => null;

  @override
  Iterable<String> get additionalAttributes sync* {
    final _src = src;
    if (_src != null) {
      yield 'src="' + _src + '"';
    }
    final _alt = alt;
    if (_alt != null) {
      yield 'alt="' + _alt + '"';
    }
  }

  @override
  String get tag => "img";
}

class DivElementImpl with HtmlElementMixin<DivElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final Iterable<MapEntry<String, String>> otherAdditionalAttributes;

  const DivElementImpl({
    required final this.childNodes,
    final this.otherAdditionalAttributes = const [],
    final this.className,
    final this.id,
  });

  @override
  Null get style => null;

  @override
  Iterable<String> get additionalAttributes sync* {
    for (final a in otherAdditionalAttributes) {
      yield a.key + '="' + a.value + '"';
    }
  }

  @override
  String get tag => "div";
}

class AnchorElementImpl with HtmlElementMixin<AnchorElementImpl> {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final String? href;
  final String? target;
  final Iterable<MapEntry<String, String>> otherAdditionalAttributes;

  const AnchorElementImpl({
    required final this.href,
    required final this.childNodes,
    final this.target,
    final this.className,
    final this.id,
    final this.otherAdditionalAttributes = const [],
  });

  @override
  Null get style => null;

  @override
  Iterable<String> get additionalAttributes sync* {
    final _href = href;
    if (_href != null) {
      yield 'href="' + _href + '"';
    }
    final _target = target;
    if (_target != null) {
      yield 'target="' + _target + '"';
    }
    for (final a in otherAdditionalAttributes) {
      yield a.key + '="' + a.value + '"';
    }
  }

  @override
  String get tag => "a";
}

class HeadElementImpl with HtmlElementMixin<HeadElementImpl> {
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
  Null get style => null;

  @override
  Iterable<String> get additionalAttributes => const [];

  @override
  String get tag => "head";
}
