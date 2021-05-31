import '../../base/image.dart';
import '../../base/keys.dart';
import '../../css/impl/builder.dart';
import '../../css/interface/css.dart';
import '../../html/impl/html.dart';
import '../../html/interface/html.dart';
import '../widget/impl/resolve_url.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class Image implements Widget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticsLabel;
  @override
  final Key? key;

  const Image({
    required this.image,
    this.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.semanticsLabel,
  });

  Image.network(
    String url, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    String? semanticsLabel,
    Key? key,
  }) : this(
          key: key,
          fit: fit,
          width: width,
          height: height,
          semanticsLabel: semanticsLabel,
          image: ImageProvider.network(url),
        );

  Image.asset(
    String name, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    String? semanticsLabel,
    Key? key,
  }) : this(
          key: key,
          fit: fit,
          width: width,
          height: height,
          semanticsLabel: semanticsLabel,
          image: ImageProvider.asset(name),
        );

  @override
  CssStyleDeclaration2 renderCss(BuildContext context) {
    final style = CssStyleDeclaration2BuilderImpl();
    style.display = 'flex';
    if (width != null) style.width = '${width}px';
    if (height != null) style.height = '${height}px';
    switch (fit) {
      case BoxFit.cover:
        style.objectFit = 'cover';
        break;
      case BoxFit.fill:
        style.objectFit = 'fill';
        break;
      case BoxFit.none:
        style.objectFit = 'none';
        break;
      case BoxFit.scaleDown:
        style.objectFit = 'scale-down';
        break;
      case BoxFit.contain:
        style.objectFit = 'contain';
        break;
    }
    return style;
  }

  @override
  HtmlElement2 renderHtml(BuildContext context) {
    final result = ImageElement2Impl();
    result.src = resolveUrl(context, image.url);
    if (semanticsLabel != null) {
      result.alt = semanticsLabel;
    }
    return result;
  }

  @override
  HtmlElement2 render(BuildContext context) => renderWidget(this, context);
}
