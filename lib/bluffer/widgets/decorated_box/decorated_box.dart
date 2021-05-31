import '../../base/border_radius.dart';
import '../../base/decoration.dart';
import '../../base/image.dart';
import '../../base/keys.dart';
import '../../css/impl/builder.dart';
import '../../css/interface/css.dart';
import '../../html/impl/html.dart';
import '../../html/interface/html.dart';
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
    this.child,
    this.decoration,
    this.key,
  });

  @override
  CssStyleDeclaration2 renderCss(BuildContext context) {
    final style = CssStyleDeclaration2BuilderImpl();
    style.display = 'flex';
    if (decoration?.color != null) {
      final _color = decoration!.color!.toCss();
      style.backgroundColor = _color;
    } else if (decoration?.image != null) {
      style.backgroundImage = 'url(' + resolveUrl(context, decoration!.image!.image.url) + ')';
    }
    if (decoration != null) {
      if (decoration!.image?.fit != null) {
        style.backgroundPosition = 'center';
        switch (decoration!.image!.fit!) {
          case BoxFit.cover:
            style.backgroundSize = 'cover';
            break;
          case BoxFit.fill:
            style.backgroundSize = 'fill';
            break;
          case BoxFit.none:
            style.backgroundSize = 'none';
            break;
          case BoxFit.scaleDown:
            style.backgroundSize = 'scale-down';
            break;
          case BoxFit.contain:
            style.backgroundSize = 'contain';
            break;
        }
      }
      final borderRadius = decoration!.borderRadius;
      if (borderRadius is BorderRadius) {
        style.borderTopLeftRadius = '${borderRadius.topLeft.x}px';
        style.borderTopRightRadius = '${borderRadius.topRight.x}px';
        style.borderBottomLeftRadius = '${borderRadius.bottomLeft.x}px';
        style.borderBottomRightRadius = '${borderRadius.bottomRight.x}px';
      }
      if (decoration!.boxShadow.isNotEmpty) {
        final shadow = decoration!.boxShadow.first;
        final shadowColor = shadow.color.toCss();
        style.boxShadow = '${shadow.offset.dx}px ${shadow.offset}px ${shadow.blurRadius}px ${shadow.spreadRadius}px ${shadowColor};';
      }
    }
    return style;
  }

  @override
  HtmlElement2 renderHtml(BuildContext context) {
    final result = DivElement2Impl();
    if (child != null) {
      result.childNodes.add(Expanded(child: child!).render(context));
    }
    return result;
  }

  @override
  HtmlElement2 render(BuildContext context) => renderWidget(this, context);
}
