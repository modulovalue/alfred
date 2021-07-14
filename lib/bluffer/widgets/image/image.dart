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
    required final this.image,
    final this.key,
    final this.fit = BoxFit.cover,
    final this.width,
    final this.height,
    final this.semanticsLabel,
  });

  Image.network(
    final String url, {
    final BoxFit fit = BoxFit.cover,
    final double? width,
    final double? height,
    final String? semanticsLabel,
    final Key? key,
  }) : this(
          key: key,
          fit: fit,
          width: width,
          height: height,
          semanticsLabel: semanticsLabel,
          image: ImageProvider.network(url),
        );

  Image.asset(
    final String name, {
    final BoxFit fit = BoxFit.cover,
    final double? width,
    final double? height,
    final String? semanticsLabel,
    final Key? key,
  }) : this(
          key: key,
          fit: fit,
          width: width,
          height: height,
          semanticsLabel: semanticsLabel,
          image: ImageProvider.asset(name),
        );

  @override
  CssStyleDeclaration2 renderCss(
    final BuildContext context,
  ) =>
      CssStyleDeclaration2BuilderImpl.build(
        display: "flex",
        width: () {
          if (width != null) {
            return '${width}px';
          } else {
            return null;
          }
        }(),
        height: () {
          if (height != null) {
            return '${height}px';
          } else {
            return null;
          }
        }(),
        objectFit: () {
          switch (fit) {
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
        }(),
      );

  @override
  HtmlElement2 renderHtml(
    final BuildContext context,
  ) {
    final result = ImageElement2Impl();
    result.src = resolveUrl(context, image.url);
    if (semanticsLabel != null) {
      result.alt = semanticsLabel;
    }
    return result;
  }

  @override
  HtmlElement2 render(
    final BuildContext context,
  ) =>
      renderWidget(this, context);
}