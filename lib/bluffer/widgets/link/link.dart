import '../../base/text.dart';
import '../click/click.dart';
import '../stateless/stateless.dart';
import '../text/text.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class TextLink extends StatelessWidget {
  final String url;
  final String title;
  final TextStyle inactiveStyle;
  final TextStyle? activeStyle;
  final TextStyle? hoverStyle;

  TextLink({
    required this.url,
    required this.title,
    required this.inactiveStyle,
    this.activeStyle,
    this.hoverStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Click(
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
}
