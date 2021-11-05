import '../base/assets.dart';
import '../base/keys.dart';
import '../css/css.dart';
import 'widget.dart';

class BuildContextImpl implements BuildContext {
  static int lastKeyIndex = 0;
  final Map<Type, InheritedWidget> _inheritedWidgets = {};
  @override
  final Map<String, CssStyleDeclaration> styles;
  @override
  final Assets assets;

  BuildContextImpl({
    required final this.assets,
    required final this.styles,
  });

  @override
  BuildContext withInherited(
    final InheritedWidget widget,
  ) =>
      BuildContextImpl(
        styles: styles,
        assets: assets,
      )
        .._inheritedWidgets.addAll(_inheritedWidgets)
        .._inheritedWidgets[widget.runtimeType] = widget;

  @override
  Key createDefaultKey() => KeyImpl('_w' + (lastKeyIndex++).toString());

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() {
    if (_inheritedWidgets.containsKey(T)) {
      final atT = _inheritedWidgets[T];
      if (atT is T?) {
        return atT;
      } else {
        assert(false, 'Invalid type, no inherited widget for $T found but found ' + atT.toString());
        return null;
      }
    } else {
      assert(false, 'No inherited widget with type $T found in tree');
      return null;
    }
  }

  @override
  void setStyle(
    final String className,
    final CssStyleDeclaration css,
  ) =>
      styles[className] = css;
}
