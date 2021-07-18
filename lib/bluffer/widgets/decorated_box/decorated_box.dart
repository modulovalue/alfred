import '../../base/border_radius.dart';
import '../../base/decoration.dart';
import '../../base/image.dart';
import '../../base/keys.dart';
import '../../css/builder.dart';
import '../../css/css.dart';
import '../../html/html.dart';
import '../../html/html_impl.dart';
import '../flex/flex.dart';
import '../widget/impl/resolve_url.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

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
  CssStyleDeclaration renderCss(
    final BuildContext context,
  ) =>
      CssStyleDeclaration2Impl(
        css_display: "flex",
        css_backgroundColor: () {
          if (decoration?.color != null) {
            final _color = decoration!.color!.toCss();
            return _color;
          } else if (decoration?.image != null) {
            return 'url(' + resolveUrl(context, decoration!.image!.image.url) + ')';
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
          if (decoration != null) {
            if (decoration!.image?.fit != null) {
              switch (decoration!.image!.fit!) {
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
        }(),
        css_boxShadow: () {
          if (decoration != null) {
            if (decoration!.boxShadow.isNotEmpty) {
              final shadow = decoration!.boxShadow.first;
              final shadowColor = shadow.color.toCss();
              return '${shadow.offset.dx}px ${shadow.offset}px ${shadow.blurRadius}px ${shadow.spreadRadius}px ${shadowColor};';
            } else {
              return null;
            }
          } else {
            return null;
          }
        }(),
        css_borderTopLeftRadius: () {
          if (decoration != null) {
            final borderRadius = decoration!.borderRadius;
            if (borderRadius is BorderRadius) {
              return '${borderRadius.topLeft.x}px';
            } else {
              return null;
            }
          } else {
            return null;
          }
        }(),
        css_borderBottomLeftRadius: () {
          if (decoration != null) {
            final borderRadius = decoration!.borderRadius;
            if (borderRadius is BorderRadius) {
              return '${borderRadius.bottomLeft.x}px';
            } else {
              return null;
            }
          } else {
            return null;
          }
        }(),
        css_borderBottomRightRadius: () {
          if (decoration != null) {
            final borderRadius = decoration!.borderRadius;
            if (borderRadius is BorderRadius) {
              return '${borderRadius.bottomRight.x}px';
            } else {
              return null;
            }
          } else {
            return null;
          }
        }(),
        css_borderTopRightRadius: () {
          if (decoration != null) {
            final borderRadius = decoration!.borderRadius;
            if (borderRadius is BorderRadius) {
              return '${borderRadius.topRight.x}px';
            } else {
              return null;
            }
          } else {
            return null;
          }
        }(),
      );

  @override
  HtmlElement2 renderHtml(
    final BuildContext context,
  ) {
    final result = DivElement2Impl.empty();
    if (child != null) {
      result.childNodes.add(Expanded(child: child!).render(context));
    }
    return result;
  }

  @override
  HtmlElement2 render(
    final BuildContext context,
  ) =>
      renderWidget(this, context);
}
