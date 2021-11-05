import '../base/text.dart';
import '../widget/widget.dart';
import 'click.dart';
import 'stateless.dart';
import 'text.dart';

class TextLink extends StatelessWidgetBase with NoCSSMixin {
  final String url;
  final String title;
  final TextStyle inactiveStyle;
  final TextStyle? activeStyle;
  final TextStyle? hoverStyle;

  TextLink({
    required final this.url,
    required final this.title,
    required final this.inactiveStyle,
    final this.activeStyle,
    final this.hoverStyle,
  });

  @override
  Widget build(
    final BuildContext context,
  ) =>
      Click(
        url: url,
        builder: (context, state) {
          TextStyle style;
          switch (state) {
            case ClickState.active:
              style = activeStyle ?? hoverStyle ?? inactiveStyle;
              break;
            case ClickState.hover:
              style = hoverStyle ?? activeStyle ?? inactiveStyle;
              break;
            case ClickState.inactive:
              style = inactiveStyle;
              break;
          }
          return Text(
            title,
            style: style,
          );
        },
      );
}
