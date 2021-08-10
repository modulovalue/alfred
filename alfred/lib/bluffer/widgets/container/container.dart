import '../../base/decoration.dart';
import '../../base/edge_insets.dart';
import '../../base/keys.dart';
import '../constrained_box/constrained_box.dart';
import '../decorated_box/decorated_box.dart';
import '../padding/padding.dart';
import '../sized_box/sized_box.dart';
import '../stateless/stateless.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class Container extends StatelessWidget {
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: _constrainedBox(
          _decoratedBox(
            _padding(child),
          ),
        ),
      );

  Widget? _padding(Widget? child) {
    if (padding != null) {
      return Padding(child: child, padding: padding);
    } else {
      return child;
    }
  }

  Widget? _decoratedBox(Widget? child) {
    if (decoration != null) {
      return DecoratedBox(child: child, decoration: decoration);
    } else {
      return child;
    }
  }

  Widget? _constrainedBox(Widget? child) {
    if (constraints != null) {
      return ConstrainedBox(child: child, constraints: constraints);
    } else {
      return child;
    }
  }
}
