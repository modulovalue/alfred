// TODO remove this dependency.
import 'dart:io';

import '../base/border_radius.dart';
import '../base/decoration.dart';
import '../base/image.dart';
import '../base/keys.dart';
import '../html/html.dart';
import '../widget/resolve_url.dart';
import '../widget/widget.dart';
import 'css_null.dart';
import 'flex.dart';
import 'stateless.dart';

class DecoratedBox with RenderElementMixin implements Widget {
  final Widget? child;
  final BoxDecoration? decoration;
  @override
  final Key? key;

  const DecoratedBox({
    final this.child,
    final this.decoration,
    final this.key,
  });

  @override
  CssStyleDeclaration renderCss({
    required final BuildContext context,
  }) =>
      _DecoratedBoxCSS(
        decoration: decoration,
        context: context,
      );

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final _child = child;
    return HtmlElementDivImpl(
      attributes: [],
      idClass: null,
      childNodes: [
        if (_child != null)
          HtmlEntityElementImpl(
            element: Expanded(
              child: _child,
            ).renderElement(
              context: context,
            ),
          ),
      ],
    );
  }
}

class _DecoratedBoxCSS with CssStyleDeclarationNullMixin {
  final BoxDecoration? decoration;
  final BuildContext context;

  const _DecoratedBoxCSS({
    required final this.decoration,
    required final this.context,
  });

  @override
  String get css_display => "flex";

  @override
  String? get css_backgroundColor {
    final _image = decoration?.image;
    if (decoration?.color != null) {
      final _color = decoration!.color!.toCss();
      return _color;
    } else if (_image != null) {
      final resolvedUrl = resolveUrl(
        context: context,
        url: _image.image.url,
        pathSeparator: Platform.pathSeparator,
      );
      return 'url(' + resolvedUrl + ')';
    }
  }

  @override
  String? get css_backgroundPosition {
    if (decoration != null) {
      if (decoration!.image?.fit != null) {
        return 'center';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  String? get css_backgroundSize {
    final _decoration = decoration;
    if (_decoration != null) {
      final _image = _decoration.image;
      if (_image != null) {
        final _fit = _image.fit;
        if (_fit != null) {
          switch (_fit) {
            case BoxFit.cover:
              return 'cover';
            case BoxFit.fill:
              return 'fill';
            case BoxFit.none:
              return 'none';
            case BoxFit.scaleDown:
              return 'scale-down';
            case BoxFit.contain:
              return 'contain';
          }
        } else {
          return null;
        }
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  String? get css_boxShadow {
    final _decoration = decoration;
    if (_decoration != null) {
      final _boxShadow = _decoration.boxShadow;
      if (_boxShadow.isNotEmpty) {
        final shadow = _boxShadow.first;
        final shadowColor = shadow.color.toCss();
        return shadow.offset.dx.toString() +
            'px ' +
            shadow.offset.dy.toString() +
            'px ' +
            shadow.blurRadius.toString() +
            'px ' +
            shadow.spreadRadius.toString() +
            'px ' +
            shadowColor.toString() +
            ';';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  String? get css_borderTopLeftRadius {
    final _decoration = decoration;
    if (_decoration != null) {
      final borderRadius = _decoration.borderRadius;
      if (borderRadius is BorderRadius) {
        return borderRadius.topLeft.x.toString() + 'px';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  String? get css_borderBottomLeftRadius {
    final _decoration = decoration;
    if (_decoration != null) {
      final borderRadius = _decoration.borderRadius;
      if (borderRadius is BorderRadius) {
        return borderRadius.bottomLeft.x.toString() + 'px';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  String? get css_borderBottomRightRadius {
    final _decoration = decoration;
    if (_decoration != null) {
      final borderRadius = _decoration.borderRadius;
      if (borderRadius is BorderRadius) {
        return borderRadius.bottomRight.x.toString() + 'px';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  String? get css_borderTopRightRadius {
    final _decoration = decoration;
    if (_decoration != null) {
      final borderRadius = _decoration.borderRadius;
      if (borderRadius is BorderRadius) {
        return borderRadius.topRight.x.toString() + 'px';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
