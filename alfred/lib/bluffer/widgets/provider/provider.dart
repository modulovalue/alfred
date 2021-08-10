import '../../base/keys.dart';
import '../stateless/stateless.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class Provider<T> extends StatelessWidget {
  final T Function(BuildContext context) create;
  final Widget child;

  const Provider({
    required final this.create,
    required final this.child,
    final Key? key,
  }) : super(key: key);

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
    required final this.child,
    required final this.value,
    final this.key,
  });
}
