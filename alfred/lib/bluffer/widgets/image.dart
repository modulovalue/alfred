// TODO remove this dependency?
import 'dart:io';

import '../base/image.dart';
import '../base/keys.dart';
import '../html/html.dart';
import '../widget/resolve_url.dart';
import '../widget/widget.dart';
import 'css_null.dart';
import 'stateless.dart';

class Image with CssStyleDeclarationNullMixin, WidgetSelfCSS, RenderElementMixin implements Widget {
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
          image: ImageProvider.asset(
            name,
          ),
        );

  @override
  String? get css_display => "flex";

  @override
  String? get css_width {
    if (width != null) {
      return width.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String? get css_height {
    if (height != null) {
      return height.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String get css_objectFit {
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
  }

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementImageImpl(
        idClass: null,
        src: resolveUrl(
          context: context,
          url: image.url,
          pathSeparator: Platform.pathSeparator,
        ),
        childNodes: [],
        alt: () {
          if (semanticsLabel != null) {
            return semanticsLabel;
          } else {
            return null;
          }
        }(),
      );
}
