import '../base/keys.dart';
import 'stateless.dart';
import 'widget/interface/build_context.dart';
import 'widget/interface/widget.dart';

class Builder extends StatelessWidget {
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
