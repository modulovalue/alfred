import '../../base/keys.dart';
import '../stateless/stateless.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class Provider<T> extends StatelessWidget {
  final T Function(BuildContext context) create;
  final Widget child;

  const Provider({
    required this.create,
    required this.child,
    Key? key,
  }) : super(key: key);

  static T? of<T>(
    BuildContext context,
  ) =>
      ValueProvider.of<T>(context);

  @override
  Widget build(
    BuildContext context,
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

  static T? of<T>(BuildContext context) {
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
