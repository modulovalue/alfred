import '../../../base/assets.dart';
import '../../../base/keys.dart';
import '../../../css/interface/css.dart';
import '../interface/build_context.dart';
import '../interface/inherited_widget.dart';

class BuildContextImpl implements BuildContext {
  static int lastKeyIndex = 0;
  final Map<Type, InheritedWidget> _inheritedWidgets = {};
  @override
  final Map<String, CssStyleDeclaration2> styles;
  @override
  final Assets assets;

  BuildContextImpl({
    required this.assets,
    Map<String, CssStyleDeclaration2>? styles,
  }) : styles = styles ?? <String, CssStyleDeclaration2>{};

  @override
  BuildContext withInherited(InheritedWidget widget) => BuildContextImpl(
        styles: styles,
        assets: assets,
      )
        .._inheritedWidgets.addAll(_inheritedWidgets)
        .._inheritedWidgets[widget.runtimeType] = widget;

  @override
  Key createDefaultKey() => KeyImpl('_w${lastKeyIndex++}');

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() {
    assert(
      _inheritedWidgets.containsKey(T),
      'No inherited widget with type $T found in tree',
    );
    return _inheritedWidgets[T] as T?;
  }

  @override
  void setStyle(String className, CssStyleDeclaration2 css) => styles[className] = css;
}
