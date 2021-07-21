import '../../base/image.dart';
import '../../base/keys.dart';
import '../../css/builder.dart';
import '../../css/css.dart';
import '../../html/html.dart';
import '../../html/html_impl.dart';
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
  CssStyleDeclaration renderCss(
    final BuildContext context,
  ) =>
      CssStyleDeclaration2Impl(
        css_display: "flex",
        css_width: () {
          if (width != null) {
            return width.toString() + 'px';
          } else {
            return null;
          }
        }(),
        css_height: () {
          if (height != null) {
            return height.toString() + 'px';
          } else {
            return null;
          }
        }(),
        css_objectFit: () {
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
  HtmlElement renderHtml(
    final BuildContext context,
  ) =>
      ImageElementImpl(
        src: resolveUrl(context, image.url),
        alt: () {
          if (semanticsLabel != null) {
            return semanticsLabel;
          } else {
            return null;
          }
        }(),
      );

  @override
  HtmlElement render(
    final BuildContext context,
  ) =>
      renderWidget(this, context);
}
