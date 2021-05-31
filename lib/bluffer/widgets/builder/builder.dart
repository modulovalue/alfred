import '../../base/keys.dart';
import '../stateless/stateless.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class Builder extends StatelessWidget {
  final Widget Function(BuildContext context) builder;

  Builder({
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => builder(context);
}
