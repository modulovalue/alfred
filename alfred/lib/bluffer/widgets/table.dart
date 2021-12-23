import '../html/html.dart';
import '../widget/widget.dart';
import 'stateless.dart';

class TableImpl with MultiRenderElementMixin, NoKeyMixin, NoCSSMixin {
  final String? clazz;
  @override
  final Iterable<TableRowImpl> children;

  const TableImpl({
    required final this.children,
    final this.clazz,
  });

  @override
  HtmlEntityElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlEntityElementImpl(
        element: HtmlElementCustomImpl(
          id: null,
          tag: "table",
          className: clazz,
          additionalAttributes: [],
          childNodes: [],
        ),
      );
}

class TableRowImpl with MultiRenderElementMixin, NoKeyMixin, NoCSSMixin {
  @override
  final Iterable<Widget> children;

  const TableRowImpl({
    required final this.children,
  });

  @override
  HtmlEntityElement renderHtml({
    required final BuildContext context,
  }) =>
      const HtmlEntityElementImpl(
        element: HtmlElementCustomImpl(
          id: null,
          className: null,
          tag: "tr",
          additionalAttributes: [],
          childNodes: [],
        ),
      );
}

abstract class TableRowContent with RenderElementMixin, NoKeyMixin, NoCSSMixin {
  const TableRowContent();

  R visit<R>({
    required final R Function(TableHeadImpl) head,
    required final R Function(TableDataImpl) data,
  });
}

class TableHeadImpl extends TableRowContent {
  final Widget child;

  const TableHeadImpl({
    required final this.child,
  });

  @override
  HtmlEntityElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlEntityElementImpl(
        element: HtmlElementCustomImpl(
          id: null,
          className: null,
          tag: "th",
          additionalAttributes: [],
          childNodes: [
            child.renderElement(
              context: context,
            ),
          ],
        ),
      );

  @override
  R visit<R>({
    required final R Function(TableHeadImpl p1) head,
    required final R Function(TableDataImpl p1) data,
  }) =>
      head(this);
}

class TableDataImpl extends TableRowContent {
  final Widget child;

  const TableDataImpl({
    required final this.child,
  });

  @override
  HtmlEntityElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlEntityElementImpl(
        element: HtmlElementCustomImpl(
          id: null,
          className: null,
          tag: "td",
          additionalAttributes: [],
          childNodes: [
            child.renderElement(
              context: context,
            ),
          ],
        ),
      );

  @override
  R visit<R>({
    required final R Function(TableHeadImpl p1) head,
    required final R Function(TableDataImpl p1) data,
  }) =>
      data(this);
}
