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
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: IdClassImpl(
          id: null,
          className: clazz,
        ),
        tag: "table",
        attributes: [],
        childNodes: [
          for (final child in children)
            HtmlEntityElementImpl(
              element: child.renderHtml(
                context: context,
              ),
            ),
        ],
      );
}

class TableRowImpl with MultiRenderElementMixin, NoKeyMixin, NoCSSMixin {
  @override
  final Iterable<Widget> children;

  const TableRowImpl({
    required final this.children,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: null,
        tag: "tr",
        attributes: [],
        childNodes: [
          for (final child in children)
            HtmlEntityElementImpl(
              element: child.renderHtml(
                context: context,
              ),
            ),
        ],
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
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: null,
        tag: "th",
        attributes: [],
        childNodes: [
          HtmlEntityElementImpl(
            element: child.renderElement(
              context: context,
            ),
          ),
        ],
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
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: null,
        tag: "td",
        attributes: [],
        childNodes: [
          HtmlEntityElementImpl(
            element: child.renderElement(
              context: context,
            ),
          ),
        ],
      );

  @override
  R visit<R>({
    required final R Function(TableHeadImpl p1) head,
    required final R Function(TableDataImpl p1) data,
  }) =>
      data(this);
}
