import '../../../base/assets.dart';
import '../../../base/keys.dart';
import '../../../css/interface/css.dart';
import 'inherited_widget.dart';

abstract class BuildContext {
  Map<String, CssStyleDeclaration2> get styles;

  Assets get assets;

  BuildContext withInherited(
    final InheritedWidget widget,
  );

  Key createDefaultKey();

  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>();

  void setStyle(
    final String className,
    final CssStyleDeclaration2 css,
  );
}