import '../../html/html.dart';
import '../../widget/widget.dart';
import '../../widgets/stateless.dart';
import '../../widgets/table.dart';

/// https://getbootstrap.com/docs/5.0/content/tables/
class BootstrapTable with RenderElementMixin, NoKeyMixin, NoCSSMixin {
  final Iterable<TableRowImpl> children;

  const BootstrapTable({
    required final this.children,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
        HtmlElementDivImpl(
          attributes: [],
          idClass: const IdClassImpl(
            id: null,
            className: "table-responsive",
          ),
          childNodes: [
            HtmlEntityElementImpl(
              element: TableImpl(
                children: children,
                clazz: "table table-sm table-striped",
              ).renderElement(
                context: context,
              ),
            ),
          ],
      );
}
