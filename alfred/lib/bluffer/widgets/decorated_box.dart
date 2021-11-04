// TODO get rid of this dependency.
import 'dart:io';

import '../base/border_radius.dart';
import '../base/decoration.dart';
import '../base/image.dart';
import '../base/keys.dart';
import '../css/css.dart';
import '../html/html.dart';
import '../html/html_impl.dart';
import 'flex.dart';
import 'widget/impl/resolve_url.dart';
import 'widget/impl/widget_mixin.dart';
import 'widget/interface/widget.dart';

class DecoratedBox implements Widget {
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
      CssStyleDeclaration2Impl(
        css_display: "flex",
        css_backgroundColor: () {
          if (decoration?.color != null) {
            final _color = decoration!.color!.toCss();
            return _color;
          } else if (decoration?.image != null) {
            final resolvedUrl = resolveUrl(
              context: context,
              url: decoration!.image!.image.url,
              pathSeparator: Platform.pathSeparator,
            );
            return 'url(' + resolvedUrl + ')';
          }
        }(),
        css_backgroundPosition: () {
          if (decoration != null) {
            if (decoration!.image?.fit != null) {
              return 'center';
            } else {
              return null;
            }
          } else {
            return null;
          }
        }(),
        css_backgroundSize: () {
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
        }(),
        css_boxShadow: () {
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
        }(),
        css_borderTopLeftRadius: () {
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
        }(),
        css_borderBottomLeftRadius: () {
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
        }(),
        css_borderBottomRightRadius: () {
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
        }(),
        css_borderTopRightRadius: () {
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
        }(),
      );

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final _child = child;
    return DivElementImpl(
      childNodes: [
        if (_child != null)
          () {
            final expanded = Expanded(child: _child);
            return expanded.renderElement(context: context);
          }(),
      ],
    );
  }

  @override
  HtmlElement renderElement({
    required final BuildContext context,
  }) =>
      renderWidget(
        child: this,
        context: context,
      );
}
