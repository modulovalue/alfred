import '../../../base/assets.dart';
import '../../../base/keys.dart';
import '../../../css/interface/css.dart';
import 'inherited_widget.dart';

abstract class BuildContext {
  Map<String, CssStyleDeclaration2> get styles;

  Assets get assets;

  BuildContext withInherited(InheritedWidget widget);

  Key createDefaultKey();

  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>();

  void setStyle(String className, CssStyleDeclaration2 css);
}
