import '../interface/type_handler.dart';

mixin TypeHandlerShouldHandleMixin<T> implements TypeHandler<T> {
  @override
  bool shouldHandle(dynamic item) => item is T;
}
