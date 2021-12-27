import '../base/basic_types.dart';
import '../base/keys.dart';
import '../html/html.dart';
import '../widget/widget.dart';
import 'css_null.dart';
import 'stateless.dart';

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

class Flex with CssStyleDeclarationNullMixin, WidgetSelfCSS, MultiRenderElementMixin implements Widget {
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  @override
  final List<Widget> children;
  @override
  final Key? key;

  const Flex({
    required final this.direction,
    final this.mainAxisAlignment = MainAxisAlignment.start,
    final this.mainAxisSize = MainAxisSize.max,
    final this.crossAxisAlignment = CrossAxisAlignment.center,
    final this.children = const <Widget>[],
    final this.key,
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

class Flexible with CssStyleDeclarationNullMixin, WidgetSelfCSS, RenderElementMixin implements Widget {
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
    required final this.child,
    final this.flex = 1,
    final this.fit = FlexFit.loose,
    final this.key,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      child.renderElement(context: context);

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
