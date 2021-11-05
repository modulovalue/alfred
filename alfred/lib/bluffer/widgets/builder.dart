import '../base/keys.dart';
import '../widget/widget.dart';
import 'stateless.dart';

class Builder extends StatelessWidgetBase with NoCSSMixin {
  final Widget Function(BuildContext context) builder;

  Builder({
    required final this.builder,
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
