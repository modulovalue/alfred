import 'dart:async';
// TODO remove this dependency?
// ignore: deprecated_member_use
import 'dart:cli';
import  'dart:convert';
// TODO remove this dependency?
import 'dart:io';

import '../base/basic_types.dart';
import '../base/border_radius.dart';
import '../base/color.dart';
import '../base/decoration.dart';
import '../base/edge_insets.dart';
import '../base/image.dart';
import '../base/keys.dart';
import '../base/locale.dart';
import '../base/media_query_data.dart';
import '../base/text.dart';
import '../html/html.dart';
import '../widget/widget.dart';


class Builder extends StatelessWidgetBase with NoCSSMixin {
  final Widget Function(BuildContext context) builder;

  Builder({
    required this.builder,
    final Key? key,
  }) : super(
    key: key,
  );

  @override
  Widget build(
      final BuildContext context,
      ) =>
      builder(context);
}

class Click with NoCSSMixin, RenderElementMixin implements Widget {
  final String url;
  final Widget Function(BuildContext context) builder;
  final bool newTab;
  @override
  final Key? key;

  const Click({
    required this.url,
    required this.builder,
    required this.newTab,
    this.key,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementAnchorImpl(
        attributes: [],
        href: resolveUrl(
          context: context,
          url: url,
          pathSeparator: Platform.pathSeparator,
        ),
        idClass: const IdClassImpl(
          id: null,
          className: 'click',
        ),
        target: () {
          if (newTab) {
            return '_blank';
          } else {
            return null;
          }
        }(),
        childNodes: [
          HtmlEntityElementImpl(
            element: builder(
              context,
            ).renderElement(
              context: context,
            ),
          ),
        ],
      );
}

class ConstrainedBox with CssStyleDeclarationNullMixin, RenderElementMixin implements Widget {
  /// The additional constraints to impose on the child.
  final BoxConstraints? constraints;
  final Widget? child;
  @override
  final Key? key;

  const ConstrainedBox({
    required this.child,
    this.constraints,
    this.key,
  });
  
  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      this;

  @override
  String? get css_margin {
    final _constraints = constraints;
    if (_constraints != null) {
      return 'auto';
    } else {
      return null;
    }
  }

  @override
  String? get css_maxHeight {
    final _constraints = constraints;
    if (_constraints != null) {
      return _constraints.maxHeight.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String? get css_maxWidth {
    final _constraints = constraints;
    if (_constraints != null) {
      return _constraints.maxWidth.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String? get css_minHeight {
    final _constraints = constraints;
    if (_constraints != null) {
      return _constraints.minHeight.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String? get css_minWidth {
    final _constraints = constraints;
    if (_constraints != null) {
      return _constraints.minWidth.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final rendered = child?.renderElement(
      context: context,
    );
    return rendered ??
        const HtmlElementDivImpl(
          attributes: [],
          idClass: null,
          childNodes: [],
        );
  }
}

class BoxConstraints {
  /// The minimum width that satisfies the constraints.
  final double minWidth;

  /// The maximum width that satisfies the constraints.
  ///
  /// Might be [double.infinity].
  final double maxWidth;

  /// The minimum height that satisfies the constraints.
  final double minHeight;

  /// The maximum height that satisfies the constraints.
  ///
  /// Might be [double.infinity].
  final double maxHeight;

  const BoxConstraints({
    required this.minWidth,
    required this.maxWidth,
    required this.minHeight,
    required this.maxHeight,
  });
}

class Container extends StatelessWidgetBase with NoCSSMixin {
  final Widget? child;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;

  const Container({
    this.child,
    this.width,
    this.height,
    this.decoration,
    this.constraints,
    this.padding,
    final Key? key,
  }) : super(
    key: key,
  );

  @override
  Widget build(
      final BuildContext context,
      ) =>
      SizedBox(
        width: width,
        height: height,
        child: _constrainedBox(
          _decoratedBox(
            _padding(child),
          ),
        ),
      );

  Widget? _padding(
      final Widget? child,
      ) {
    if (padding != null) {
      return Padding(
        child: child,
        padding: padding,
      );
    } else {
      return child;
    }
  }

  Widget? _decoratedBox(
      final Widget? child,
      ) {
    if (decoration != null) {
      return DecoratedBox(
        child: child,
        decoration: decoration,
      );
    } else {
      return child;
    }
  }

  Widget? _constrainedBox(
      final Widget? child,
      ) {
    if (constraints != null) {
      return ConstrainedBox(
        child: child,
        constraints: constraints,
      );
    } else {
      return child;
    }
  }
}

mixin CssStyleDeclarationNullMixin implements CssStyleDeclaration {
  @override
  String? get css_margin => null;

  @override
  String? get css_maxHeight => null;

  @override
  String? get css_maxWidth => null;

  @override
  String? get css_minHeight => null;

  @override
  String? get css_minWidth => null;

  @override
  String? get css_display => null;

  @override
  String? get css_backgroundColor => null;

  @override
  String? get css_backgroundImage => null;

  @override
  String? get css_backgroundPosition => null;

  @override
  String? get css_backgroundSize => null;

  @override
  String? get css_borderTopLeftRadius => null;

  @override
  String? get css_borderTopRightRadius => null;

  @override
  String? get css_borderBottomLeftRadius => null;

  @override
  String? get css_borderBottomRightRadius => null;

  @override
  String? get css_boxShadow => null;

  @override
  String? get css_flexDirection => null;

  @override
  String? get css_justifyContent => null;

  @override
  String? get css_alignItems => null;

  @override
  String? get css_flexGrow => null;

  @override
  String? get css_flexShrink => null;

  @override
  String? get css_flexBasis => null;

  @override
  String? get css_objectFit => null;

  @override
  String? get css_width => null;

  @override
  String? get css_height => null;

  @override
  String? get css_textAlign => null;

  @override
  String? get css_lineHeight => null;

  @override
  String? get css_fontSize => null;

  @override
  String? get css_color => null;

  @override
  String? get css_fontWeight => null;

  @override
  String? get css_fontFamily => null;

  @override
  String? get css_cursor => null;

  @override
  String? get css_padding => null;

  @override
  String? get css_border => null;

  @override
  String? get css_font => null;

  @override
  String? get css_verticalAlign => null;

  @override
  String? get css_listStyle => null;

  @override
  String? get css_quotes => null;

  @override
  String? get css_content => null;

  @override
  String? get css_borderCollapse => null;

  @override
  String? get css_spacing => null;

  @override
  String? get css_textDecoration => null;
}

class DecoratedBox with RenderElementMixin implements Widget {
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
    required this.decoration,
    required this.context,
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
    } else {
      return null;
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

class Column extends Flex {
  const Column({
    final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    final MainAxisSize mainAxisSize = MainAxisSize.min,
    final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    // VerticalDirection verticalDirection = VerticalDirection.down,
    final List<Widget> children = const <Widget>[],
    final Key? key,
  }) : super(
    key: key,
    direction: Axis.vertical,
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxisAlignment,
    children: children,
  );
}

class Row extends Flex {
  const Row({
    final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    final MainAxisSize mainAxisSize = MainAxisSize.min,
    final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    // VerticalDirection verticalDirection = VerticalDirection.down,
    final List<Widget> children = const <Widget>[],
    final Key? key,
  }) : super(
    key: key,
    direction: Axis.horizontal,
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxisAlignment,
    children: children,
  );
}

class Flex with CssStyleDeclarationNullMixin, MultiRenderElementMixin implements Widget {
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  @override
  final List<Widget> children;
  @override
  final Key? key;

  const Flex({
    required this.direction,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.children = const <Widget>[],
    this.key,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementDivImpl(
        attributes: [],
        idClass: null,
        childNodes: [
          for (final child in children)
            HtmlEntityElementImpl(
              element: child.renderHtml(
                context: context,
              ),
            ),
        ],
      );

  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      this;

  @override
  String get css_display => 'flex';

  @override
  String get css_flexDirection {
    if (direction == Axis.horizontal) {
      return 'row';
    } else {
      return 'column';
    }
  }

  @override
  String get css_justifyContent {
    switch (mainAxisSize) {
      case MainAxisSize.max:
        return 'stretch';
      case MainAxisSize.min:
        switch (mainAxisAlignment) {
          case MainAxisAlignment.end:
            return 'flex-end';
          case MainAxisAlignment.spaceAround:
            return 'space-around';
          case MainAxisAlignment.spaceBetween:
            return 'space-between';
          case MainAxisAlignment.spaceEvenly:
            return 'space-evenly';
          case MainAxisAlignment.center:
            return 'center';
          case MainAxisAlignment.start:
            return 'flex-start';
        }
    }
  }

  @override
  String get css_alignItems {
    switch (crossAxisAlignment) {
      case CrossAxisAlignment.end:
        return 'flex-end';
      case CrossAxisAlignment.baseline:
        return 'baseline';
      case CrossAxisAlignment.stretch:
        return 'stretch';
      case CrossAxisAlignment.center:
        return 'center';
      case CrossAxisAlignment.start:
        return 'flex-start';
    }
  }
}

class Flexible with CssStyleDeclarationNullMixin, RenderElementMixin implements Widget {
  final Widget child;

  /// The flex factor to use for this child
  ///
  /// If null or zero, the child is inflexible and determines its own size. If
  /// non-zero, the amount of space the child's can occupy in the main axis is
  /// determined by dividing the free space (after placing the inflexible
  /// children) according to the flex factors of the flexible children.
  final int flex;

  /// How a flexible child is inscribed into the available space.
  ///
  /// If [flex] is non-zero, the [fit] determines whether the child fills the
  /// space the parent makes available during layout. If the fit is
  /// [FlexFit.tight], the child is required to fill the available space. If the
  /// fit is [FlexFit.loose], the child can be at most as large as the available
  /// space (but is allowed to be smaller).
  final FlexFit fit;
  @override
  final Key? key;

  const Flexible({
    required this.child,
    this.flex = 1,
    this.fit = FlexFit.loose,
    this.key,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      child.renderElement(context: context);

  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      this;

  @override
  String? get css_flexBasis {
    switch (fit) {
      case FlexFit.tight:
        return '0';
      case FlexFit.loose:
        return null;
    }
  }

  @override
  String get css_flexGrow {
    switch (fit) {
      case FlexFit.tight:
        return flex.toString();
      case FlexFit.loose:
        return '0';
    }
  }

  @override
  String get css_flexShrink {
    switch (fit) {
      case FlexFit.tight:
        return '1';
      case FlexFit.loose:
        return flex.toString();
    }
  }
}

class Expanded extends Flexible {
  /// Creates a widget that expands a child of a [Row], [Column], or [Flex]
  /// so that the child fills the available space along the flex widget's
  /// main axis.
  const Expanded({
    required final Widget child,
    final int flex = 1,
    final Key? key,
  }) : super(
    key: key,
    flex: flex,
    fit: FlexFit.tight,
    child: child,
  );
}

/// How the child is inscribed into the available space.
///
/// See also:
///
///  * RenderFlex, the flex render object.
///  * [Column], [Row], and [Flex], the flex widgets.
///  * [Expanded], the widget equivalent of [tight].
///  * [Flexible], the widget equivalent of [loose].
enum FlexFit {
  /// The child is forced to fill the available space.
  ///
  /// The [Expanded] widget assigns this kind of [FlexFit] to its child.
  tight,

  /// The child can be at most as large as the available space (but is
  /// allowed to be smaller).
  ///
  /// The [Flexible] widget assigns this kind of [FlexFit] to its child.
  loose,
}

/// How the children should be placed along the main axis in a flex layout.
///
/// See also:
///
///  * [Column], [Row], and [Flex], the flex widgets.
///  * RenderFlex, the flex render object.
enum MainAxisAlignment {
  /// Place the children as close to the start of the main axis as possible.
  ///
  /// If this value is used in a horizontal direction, a TextDirection must be
  /// available to determine if the start is the left or the right.
  ///
  /// If this value is used in a vertical direction, a [VerticalDirection] must be
  /// available to determine if the start is the top or the bottom.
  start,

  /// Place the children as close to the end of the main axis as possible.
  ///
  /// If this value is used in a horizontal direction, a TextDirection must be
  /// available to determine if the end is the left or the right.
  ///
  /// If this value is used in a vertical direction, a [VerticalDirection] must be
  /// available to determine if the end is the top or the bottom.
  end,

  /// Place the children as close to the middle of the main axis as possible.
  center,

  /// Place the free space evenly between the children.
  spaceBetween,

  /// Place the free space evenly between the children as well as half of that
  /// space before and after the first and last child.
  spaceAround,

  /// Place the free space evenly between the children as well as before and
  /// after the first and last child.
  spaceEvenly,
}

/// How the children should be placed along the cross axis in a flex layout.
///
/// See also:
///
///  * [Column], [Row], and [Flex], the flex widgets.
///  * RenderFlex, the flex render object.
enum CrossAxisAlignment {
  /// Place the children with their start edge aligned with the start side of
  /// the cross axis.
  ///
  /// For example, in a column (a flex with a vertical axis) whose
  /// TextDirection is TextDirection.ltr, this aligns the left edge of the
  /// children along the left edge of the column.
  ///
  /// If this value is used in a horizontal direction, a TextDirection must be
  /// available to determine if the start is the left or the right.
  ///
  /// If this value is used in a vertical direction, a [VerticalDirection] must be
  /// available to determine if the start is the top or the bottom.
  start,

  /// Place the children as close to the end of the cross axis as possible.
  ///
  /// For example, in a column (a flex with a vertical axis) whose
  /// TextDirection is TextDirection.ltr, this aligns the right edge of the
  /// children along the right edge of the column.
  ///
  /// If this value is used in a horizontal direction, a TextDirection must be
  /// available to determine if the end is the left or the right.
  ///
  /// If this value is used in a vertical direction, a [VerticalDirection] must be
  /// available to determine if the end is the top or the bottom.
  end,

  /// Place the children so that their centers align with the middle of the
  /// cross axis.
  ///
  /// This is the default cross-axis alignment.
  center,

  /// Require the children to fill the cross axis.
  ///
  /// This causes the constraints passed to the children to be tight in the
  /// cross axis.
  stretch,

  /// Place the children along the cross axis such that their baselines match.
  ///
  /// If the main axis is vertical, then this value is treated like [start]
  /// (since baselines are always horizontal).
  baseline,
}

/// How much space should be occupied in the main axis.
///
/// During a flex layout, available space along the main axis is allocated to
/// children. After allocating space, there might be some remaining free space.
/// This value controls whether to maximize or minimize the amount of free
/// space, subject to the incoming layout constraints.
///
/// See also:
///
///  * [Column], [Row], and [Flex], the flex widgets.
///  * [Expanded] and [Flexible], the widgets that controls a flex widgets'
///    children's flex.
///  * RenderFlex, the flex render object.
///  * [MainAxisAlignment], which controls how the free space is distributed.
enum MainAxisSize {
  /// Minimize the amount of free space along the main axis, subject to the
  /// incoming layout constraints.
  ///
  /// If the incoming layout constraints have a large enough
  /// BoxConstraints.minWidth or BoxConstraints.minHeight, there might still
  /// be a non-zero amount of free space.
  ///
  /// If the incoming layout constraints are unbounded, and any children have a
  /// non-zero FlexParentData.flex and a [FlexFit.tight] fit (as applied by
  /// [Expanded]), the RenderFlex will assert, because there would be infinite
  /// remaining free space and boxes cannot be given infinite size.
  min,

  /// Maximize the amount of free space along the main axis, subject to the
  /// incoming layout constraints.
  ///
  /// If the incoming layout constraints have a small enough
  /// BoxConstraints.maxWidth or BoxConstraints.maxHeight, there might still
  /// be no free space.
  ///
  /// If the incoming layout constraints are unbounded, the RenderFlex will
  /// assert, because there would be infinite remaining free space and boxes
  /// cannot be given infinite size.
  max,
}

class TextLink extends StatelessWidgetBase with NoCSSMixin {
  final String url;
  final String title;
  final TextStyle inactiveStyle;
  final TextStyle? activeStyle;
  final TextStyle? hoverStyle;

  TextLink({
    required this.url,
    required this.title,
    required this.inactiveStyle,
    this.activeStyle,
    this.hoverStyle,
  });

  @override
  Widget build(
      final BuildContext context,
      ) =>
      Click(
        newTab: false,
        url: url,
        builder: (context) {
          TextStyle style;
          // switch (state) {
          //   case ClickState.active:
          style = activeStyle ?? hoverStyle ?? inactiveStyle;
          // break;
          // case ClickState.hover:
          //   style = hoverStyle ?? activeStyle ?? inactiveStyle;
          //   break;
          // case ClickState.inactive:
          //   style = inactiveStyle;
          //   break;
          // }
          return Text(
            title,
            style: style,
          );
        },
      );
}

class Image with CssStyleDeclarationNullMixin, RenderElementMixin implements Widget {
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
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      this;

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

class Localizations extends StatelessWidgetBase with NoCSSMixin {
  /// Create a widget from which localizations (like translated strings) can be obtained.
  const Localizations({
    required this.locale,
    required this.delegates,
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  /// The resources returned by [Localizations.of] will be specific to this locale.
  final Locale locale;

  /// This list collectively defines the localized resources objects that can
  /// be retrieved with [Localizations.of].
  final List<LocalizationsDelegate<dynamic>> delegates;

  /// The locale of the Localizations widget for the widget tree that
  /// corresponds to [BuildContext] `context`.
  ///
  /// If no [Localizations] widget is in scope then the [Localizations.localeOf]
  /// method will throw an exception, unless the `nullOk` argument is set to
  /// true, in which case it returns null.
  static Locale? localeOf(
      final BuildContext context, {
        final bool nullOk = false,
      }) {
    final scope = context.dependOnInheritedWidgetOfExactType<_LocalizationsScope>();
    if (nullOk && scope == null) {
      return null;
    }
    assert(scope != null, 'a Localizations ancestor was not found');
    return scope!.locale;
  }

  /// Returns the localized resources object of the given `type` for the widget
  /// tree that corresponds to the given `context`.
  ///
  /// Returns null if no resources object of the given `type` exists within
  /// the given `context`.
  ///
  /// This method is typically used by a static factory method on the `type`
  /// class. For example Flutter's MaterialLocalizations class looks up Material
  /// resources with a method defined like this:
  ///
  /// ```dart
  /// static MaterialLocalizations of(BuildContext context) {
  ///    return Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
  /// }
  /// ```
  static T of<T>(
      final BuildContext context,
      final Type type,
      ) {
    final scope = context.dependOnInheritedWidgetOfExactType<_LocalizationsScope>();
    final dynamic value = scope?.typeToResources[T];
    if (value is T) {
      return value;
    } else {
      throw Exception("Expected value to be of type " + T.toString());
    }
  }

  @override
  Widget build(
      final BuildContext context,
      ) {
    final typeToResources = <Type, dynamic>{};
    for (final delegate in delegates) {
      final loaded = delegate.load(locale);
      final value = loaded.then(
            (final dynamic a) {
          if (a is Type) {
            return a;
          } else {
            throw Exception("Expected " + a.toString() + " to be of type Type.");
          }
        },
      );
      // ignore: deprecated_member_use
      typeToResources[delegate.type] = waitFor(value);
    }
    return _LocalizationsScope(
      child: child,
      typeToResources: typeToResources,
      locale: locale,
    );
  }
}

abstract class LocalizationsDelegate<RESOURCE> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const LocalizationsDelegate();

  /// Whether resources for the given locale can be loaded by this delegate.
  ///
  /// Return true if the instance of `T` loaded by this delegate's [load]
  /// method supports the given `locale`'s language.
  bool isSupported(
      final Locale locale,
      );

  /// Start loading the resources for `locale`. The returned future completes
  /// when the resources have finished loading.
  ///
  /// It's assumed that this method will return an object that contains
  /// a collection of related resources (typically defined with one method per
  /// resource). The object will be retrieved with [Localizations.of].
  Future<RESOURCE> load(
      final Locale locale,
      );

  /// The type of the object returned by the [load] method, T by default.
  ///
  /// This type is used to retrieve the object "loaded" by this
  /// [LocalizationsDelegate] from the [Localizations] inherited widget.
  /// For example the object loaded by `LocalizationsDelegate<Foo>` would
  /// be retrieved with:
  /// ```dart
  /// Foo foo = Localizations.of<Foo>(context, Foo);
  /// ```
  ///
  /// It's rarely necessary to override this getter.
  Type get type => RESOURCE;

  @override
  String toString() => '$runtimeType[$type]';
}

class _LocalizationsScope with InheritedWidgetMixin {
  /// The resources returned by [Localizations.of] will be specific to this locale.
  final Locale locale;
  final Map<Type, dynamic> typeToResources;
  @override
  final Widget child;
  @override
  final Key? key = null;

  const _LocalizationsScope({
    required this.locale,
    required this.typeToResources,
    required this.child,
  });
}

class Padding with CssStyleDeclarationNullMixin, RenderElementMixin implements Widget {
  final Widget? child;
  final EdgeInsets? padding;
  @override
  final Key? key;

  const Padding({
    this.child,
    this.padding,
    this.key,
  });

  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      this;

  @override
  String get css_display => "flex";

  @override
  String? get css_margin {
    final _padding = padding;
    if (_padding != null) {
      return _padding.top.toString() +
          'px ' +
          _padding.right.toString() +
          'px ' +
          _padding.bottom.toString() +
          'px ' +
          _padding.left.toString() +
          'px';
    } else {
      return null;
    }
  }

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    if (child == null) {
      return const HtmlElementDivImpl(
        attributes: [],
        idClass: null,
        childNodes: [],
      );
    } else {
      return child!.renderElement(
        context: context,
      );
    }
  }
}

class Provider<T> extends StatelessWidgetBase with NoCSSMixin {
  final T Function(BuildContext context) create;
  final Widget child;

  const Provider({
    required this.create,
    required this.child,
    final Key? key,
  }) : super(
    key: key,
  );

  static T? of<T>(
      final BuildContext context,
      ) =>
      ValueProvider.of<T>(context);

  @override
  Widget build(
      final BuildContext context,
      ) =>
      ValueProvider<T>(
        value: create(context),
        child: child,
      );
}

class ValueProvider<T> with InheritedWidgetMixin {
  final T value;
  @override
  final Key? key;
  @override
  final Widget child;

  static T? of<T>(
      final BuildContext context,
      ) {
    final provider = context.dependOnInheritedWidgetOfExactType<ValueProvider<T>>();
    assert(provider != null, "Couldn't find a value provider for the value $T");
    return provider!.value;
  }

  const ValueProvider({
    required this.child,
    required this.value,
    this.key,
  });
}

class SizedBox with CssStyleDeclarationNullMixin, RenderElementMixin implements Widget {
  final Widget? child;
  final double? width;
  final double? height;
  @override
  final Key? key;

  const SizedBox({
    this.child,
    this.width,
    this.height,
    this.key,
  });

  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      this;

  @override
  String? get css_flexShrink => "0";

  @override
  String? get css_width {
    final _width = width;
    if (_width != null) {
      return _width.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String? get css_height {
    final _height = height;
    if (_height != null) {
      return _height.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    if (child == null) {
      return const HtmlElementDivImpl(
        attributes: [],
        idClass: null,
        childNodes: [],
      );
    } else {
      return child!.renderElement(
        context: context,
      );
    }
  }
}

abstract class StatelessWidget implements Widget {
  Widget build(
      final BuildContext context,
      );
}

abstract class StatelessWidgetBase with RenderElementMixin implements StatelessWidget {
  @override
  final Key? key;

  const StatelessWidgetBase({
    this.key,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final built = build(
      context,
    );
    return built.renderElement(
      context: context,
    );
  }
}

mixin RenderElementMixin implements Widget {
  @override
  HtmlElement renderElement({
    required final BuildContext context,
  }) =>
      renderWidget(
        child: this,
        context: context,
      );
}

mixin MultiRenderElementMixin implements Widget {
  Iterable<Widget> get children;

  @override
  HtmlElement renderElement({
    required final BuildContext context,
  }) =>
      renderWidget(
        child: this,
        context: context,
      );
}

mixin NoCSSMixin implements Widget {
  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      null;
}

mixin NoKeyMixin implements Widget {
  @override
  Key? get key => null;
}

class RawHtml with RenderElementMixin {
  final String html;

  const RawHtml(this.html);

  @override
  Key? get key => null;

  @override
  CssStyleDeclaration? renderCss({
    required BuildContext context,
  }) {
    return null;
  }

  @override
  HtmlElement renderHtml({
    required BuildContext context,
  }) {
    return HtmlElementRawImpl(
      html: html,
    );
  }
}
class Text with RenderElementMixin {
  @override
  final Key? key;

  /// The text to display.
  ///
  /// This will be null if a textSpan is provided instead.
  final String data;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's "inherit" property is true, the style will be merged with
  /// the closest enclosing DefaultTextStyle. Otherwise, the style will
  /// replace the closest enclosing DefaultTextStyle.
  final TextStyle? style;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [data] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient Directionality, if any.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  ///
  /// See RenderParagraph.locale for more information.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool? softWrap;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  ///
  /// The value given to the constructor as textScaleFactor. If null, will
  /// use the MediaQueryData.textScaleFactor obtained from the ambient
  /// MediaQuery, or 1.0 if there is no MediaQuery in scope.
  final double? textScaleFactor;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  ///
  /// If this is null, but there is an ambient DefaultTextStyle that specifies
  /// an explicit number for its DefaultTextStyle.maxLines, then the
  /// DefaultTextStyle value will take precedence. You can use a RichText
  /// widget directly to entirely override the DefaultTextStyle.
  final int? maxLines;

  /// Creates a text widget.
  ///
  /// If the [style] argument is null, the text will use the style from the
  /// closest enclosing DefaultTextStyle.
  ///
  /// The [data] parameter must not be null.
  const Text(
      this.data, {
        this.style,
        this.strutStyle,
        this.textAlign,
        this.textDirection,
        this.locale,
        this.softWrap,
        this.overflow,
        this.textScaleFactor,
        this.maxLines,
        this.key,
      });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final splitLineIterable = LineSplitter.split(data);
    final lines = splitLineIterable.toList();
    return HtmlElementCustomImpl(
      idClass: null,
      tag: "p",
      attributes: [],
      childNodes: [
        if (lines.isNotEmpty)
          HtmlEntityNodeImpl(
            text: lines.first,
          ),
        if (lines.length > 1)
          for (final line in lines.skip(1)) ...[
            const HtmlEntityElementImpl(
              element: HtmlElementBrImpl(
                idClass: null,
              ),
            ),
            HtmlEntityNodeImpl(
              text: line,
            ),
          ],
      ],
    );
  }

  @override
  CssStyleDeclaration renderCss({
    required final BuildContext context,
  }) =>
      _TextCSS(
        text: this,
        textStyles: () {
          final _style = style;
          final themeData = Theme.of(context);
          final textTheme = themeData!.text;
          final _themeStyle = textTheme.paragraph;
          if (_style == null) {
            return _themeStyle;
          } else {
            return _themeStyle.merge(_style);
          }
        }(),
      );
}

class _TextCSS with CssStyleDeclarationNullMixin {
  final Text text;
  final TextStyle textStyles;

  const _TextCSS({
    required this.text,
    required this.textStyles,
  });

  @override
  String? get css_textAlign {
    if (text.textAlign != null) {
      switch (text.textAlign!) {
        case TextAlign.end:
        // TODO should respect text direction.
          return 'right';
        case TextAlign.right:
          return 'right';
        case TextAlign.center:
          return 'center';
        case TextAlign.left:
          return 'left';
        case TextAlign.justify:
        // TODO is this correct?
          return 'left';
        case TextAlign.start:
        // TODO should respect text direction.
          return 'left';
      }
    } else {
      return null;
    }
  }

  @override
  String? get css_lineHeight {
    if (textStyles.height != null) {
      return textStyles.height.toString();
    } else {
      return null;
    }
  }

  @override
  String get css_display => 'flex';

  @override
  String get css_fontSize => (textStyles.fontSize ?? 12).toString();

  @override
  String get css_color => (textStyles.color ?? const Color(0xFF000000)).toCss();

  @override
  String? get css_fontWeight => const <int, String>{
    0: '100',
    1: '200',
    2: '300',
    3: '400',
    4: '500',
    5: '600',
    6: '700',
    7: '800',
    8: '900',
  }[textStyles.fontWeight?.index ?? FontWeight.w400.index];

  @override
  String get css_fontFamily => <String>[
    if (textStyles.fontFamily != null) //
      "'" + textStyles.fontFamily! + "'",
    if (textStyles.fontFamilyFallback != null) //
      ...textStyles.fontFamilyFallback!
  ].join(', ');
}

class TableImpl with MultiRenderElementMixin, NoKeyMixin, NoCSSMixin {
  final String? clazz;
  @override
  final Iterable<TableRowImpl> children;

  const TableImpl({
    required this.children,
    this.clazz,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: IdClassImpl(
          id: null,
          className: clazz,
        ),
        tag: "table",
        attributes: [],
        childNodes: [
          for (final child in children)
            HtmlEntityElementImpl(
              element: child.renderHtml(
                context: context,
              ),
            ),
        ],
      );
}

class TableRowImpl with MultiRenderElementMixin, NoKeyMixin, NoCSSMixin {
  @override
  final Iterable<Widget> children;

  const TableRowImpl({
    required this.children,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: null,
        tag: "tr",
        attributes: [],
        childNodes: [
          for (final child in children)
            HtmlEntityElementImpl(
              element: child.renderHtml(
                context: context,
              ),
            ),
        ],
      );
}

abstract class TableRowContent with RenderElementMixin, NoKeyMixin, NoCSSMixin {
  const TableRowContent();

  R visit<R>({
    required final R Function(TableHeadImpl) head,
    required final R Function(TableDataImpl) data,
  });
}

class TableHeadImpl extends TableRowContent {
  final Widget child;

  const TableHeadImpl({
    required this.child,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: null,
        tag: "th",
        attributes: [],
        childNodes: [
          HtmlEntityElementImpl(
            element: child.renderElement(
              context: context,
            ),
          ),
        ],
      );

  @override
  R visit<R>({
    required final R Function(TableHeadImpl p1) head,
    required final R Function(TableDataImpl p1) data,
  }) =>
      head(this);
}

class TableDataImpl extends TableRowContent {
  final Widget child;

  const TableDataImpl({
    required this.child,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: null,
        tag: "td",
        attributes: [],
        childNodes: [
          HtmlEntityElementImpl(
            element: child.renderElement(
              context: context,
            ),
          ),
        ],
      );

  @override
  R visit<R>({
    required final R Function(TableHeadImpl p1) head,
    required final R Function(TableDataImpl p1) data,
  }) =>
      data(this);
}

class Theme extends StatelessWidgetBase with NoCSSMixin {
  final ThemeData? data;
  final Widget child;

  const Theme({
    required this.child,
    this.data,
    final Key? key,
  }) : super(
    key: key,
  );

  static ThemeData? of(
    final BuildContext context,
  ) =>
      Provider.of<ThemeData>(context);

  @override
  Widget build(
    final BuildContext context,
  ) =>
      ValueProvider<ThemeData>(
        value: data ?? ThemeData.base(context),
        child: child,
      );
}

class ThemeData {
  final ThemeTextData text;

  const ThemeData({
    required this.text,
  });

  static ThemeData base(
    final BuildContext context,
  ) {
    final size = MediaQuery.of(context)!.size;
    return ThemeData(
      text: ThemeTextData(
        paragraph: ThemeDataDefaults.paragraph(size: size),
        header1: ThemeDataDefaults.header1(size: size),
        header2: ThemeDataDefaults.header2(size: size),
        header3: ThemeDataDefaults.header3(size: size),
        activeLink: ThemeDataDefaults.activeLink(size: size),
        inactiveLink: ThemeDataDefaults.inactiveLink(size: size),
        hoverLink: ThemeDataDefaults.hoverLink(size: size),
      ),
    );
  }
}

class ThemeTextData {
  final TextStyle paragraph;
  final TextStyle header1;
  final TextStyle header2;
  final TextStyle header3;
  final TextStyle inactiveLink;
  final TextStyle activeLink;
  final TextStyle hoverLink;

  const ThemeTextData({
    required this.paragraph,
    required this.header1,
    required this.header2,
    required this.header3,
    required this.inactiveLink,
    required this.activeLink,
    required this.hoverLink,
  });
}

abstract class ThemeDataDefaults {
  static TextStyle paragraph({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultParagraphFontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle header1({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultHeader1FontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle header2({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultHeader2FontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle header3({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultHeader3FontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle activeLink({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultParagraphFontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle inactiveLink({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultParagraphFontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: ['sans-serif'],
      );

  static TextStyle hoverLink({
    required final MediaSize size,
    final String? fontFamily,
  }) =>
      TextStyle(
        color: const Color(0xFF000000),
        fontSize: defaultParagraphFontSize(size),
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: ['sans-serif'],
      );

  static double defaultParagraphFontSize(
      final MediaSize size,
      ) {
    switch (size) {
      case MediaSize.xsmall:
        return 9;
      case MediaSize.small:
        return 10;
      case MediaSize.medium:
        return 12;
      case MediaSize.large:
        return 12;
      case MediaSize.xlarge:
        return 12;
    }
  }

  static double defaultHeader1FontSize(
      final MediaSize size,
      ) {
    switch (size) {
      case MediaSize.xsmall:
        return 18;
      case MediaSize.small:
        return 24;
      case MediaSize.medium:
        return 32;
      case MediaSize.large:
        return 32;
      case MediaSize.xlarge:
        return 32;
    }
  }

  static double defaultHeader2FontSize(
      final MediaSize size,
      ) {
    switch (size) {
      case MediaSize.xsmall:
        return 14;
      case MediaSize.small:
        return 18;
      case MediaSize.medium:
        return 24;
      case MediaSize.large:
        return 24;
      case MediaSize.xlarge:
        return 24;
    }
  }

  static double defaultHeader3FontSize(
      final MediaSize size,
      ) {
    switch (size) {
      case MediaSize.xsmall:
        return 10;
      case MediaSize.small:
        return 12;
      case MediaSize.medium:
        return 24;
      case MediaSize.large:
        return 24;
      case MediaSize.xlarge:
        return 24;
    }
  }
}
