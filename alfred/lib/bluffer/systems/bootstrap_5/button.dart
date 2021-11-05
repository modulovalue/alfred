import '../../html/html.dart';
import '../../html/html_impl.dart';
import '../../widget/widget.dart';
import '../../widgets/stateless.dart';

// TODO action (open link, execute, others)
// TODO more from https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-buttons.php
class BootstrapButton with RenderElementMixin, NoCSSMixin, NoKeyMixin {
  final String text;
  final BootstrapButtonType type;

  const BootstrapButton({
    required final this.text,
    final this.type = BootstrapButtonType.primary,
  });

  @override
  HtmlElement<HtmlElement> renderHtml({
    required final BuildContext context,
  }) =>
      CustomElementImpl(
        tag: "button",
        additionalAttributes: [
          'type="button"',
          'class="btn btn-' +
              _serializeBootstrapButtonType(
                type: type,
              ) +
              '"',
        ],
        childNodes: [
          RawTextElementImpl(
            text,
          ),
        ],
      );
}

// TODO action.
class BootstrapOutlineButton with RenderElementMixin, NoCSSMixin, NoKeyMixin {
  final String text;
  final BootstrapOutlineButtonType type;

  const BootstrapOutlineButton({
    required final this.text,
    final this.type = BootstrapOutlineButtonType.primary,
  });

  @override
  HtmlElement<HtmlElement> renderHtml({
    required final BuildContext context,
  }) =>
      CustomElementImpl(
        tag: "button",
        additionalAttributes: [
          'type="button"',
          'class="btn btn-outline-' +
              _serializeBootstrapOutlineButtonType(
                type: type,
              ) +
              '"',
        ],
        childNodes: [
          RawTextElementImpl(
            text,
          ),
        ],
      );
}

// TODO have a sum type for the types and share a subset between normal and outline.

String _serializeBootstrapButtonType({
  required final BootstrapButtonType type,
}) {
  switch (type) {
    case BootstrapButtonType.primary:
      return "primary";
    case BootstrapButtonType.secondary:
      return "secondary";
    case BootstrapButtonType.success:
      return "success";
    case BootstrapButtonType.danger:
      return "danger";
    case BootstrapButtonType.warning:
      return "warning";
    case BootstrapButtonType.info:
      return "info";
    case BootstrapButtonType.dark:
      return "dark";
    case BootstrapButtonType.light:
      return "light";
    case BootstrapButtonType.link:
      return "link";
  }
}

String _serializeBootstrapOutlineButtonType({
  required final BootstrapOutlineButtonType type,
}) {
  switch (type) {
    case BootstrapOutlineButtonType.primary:
      return "primary";
    case BootstrapOutlineButtonType.secondary:
      return "secondary";
    case BootstrapOutlineButtonType.success:
      return "success";
    case BootstrapOutlineButtonType.danger:
      return "danger";
    case BootstrapOutlineButtonType.warning:
      return "warning";
    case BootstrapOutlineButtonType.info:
      return "info";
    case BootstrapOutlineButtonType.dark:
      return "dark";
  }
}

enum BootstrapButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  dark,
  light,
  link,
}

enum BootstrapOutlineButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  dark,
}
