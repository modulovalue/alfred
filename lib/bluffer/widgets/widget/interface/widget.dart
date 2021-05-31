import '../../../base/keys.dart';
import '../../../css/interface/css.dart';
import '../../../html/interface/html.dart';
import 'base_widgets.dart';

abstract class Widget<KEY extends Key?, HTML extends HtmlElement2, CSS extends CssStyleDeclaration2?, RENDER extends HtmlElement2> //
    implements
        KeyWidget<KEY>,
        HtmlWidget<HTML>,
        CssWidget<CSS>,
        RenderWidget<RENDER> {}

