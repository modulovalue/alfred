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
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    var result = child;
    if (padding != null) {
      result = Padding(
        child: result,
        padding: padding,
      );
    }
    if (decoration != null) {
      result = DecoratedBox(
        child: result,
        decoration: decoration,
      );
    }
    if (constraints != null) {
      result = ConstrainedBox(
        child: result,
        constraints: constraints,
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: result,
    );
  }
}
