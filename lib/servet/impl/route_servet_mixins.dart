import '../interface/route_servets.dart';
import '../interface/servet.dart';

/// A [LeafRouteServet] mixin that visits its visitor.
mixin LeafRouteServetVisitorMixin<TYPE> implements LeafRouteServet<TYPE> {
  @override
  R acceptRouteServet1<R, A>(RouteServetVisitorOneArg<TYPE, R, A> v, A a) => v.visitRouteServetLeaf(this, a);
}

/// A [PolyRouteServet] mixin that visits its visitor.
mixin PolyRouteServetVisitorMixin<TYPE> implements PolyRouteServet<TYPE> {
  @override
  R acceptRouteServet1<R, A>(RouteServetVisitorOneArg<TYPE, R, A> v, A a) => v.visitRouteServetPoly(this, a);
}

/// A [MonoRouteServet] mixin that visits its visitor.
mixin MonoRouteServetVisitorMixin<TYPE> implements MonoRouteServet<TYPE> {
  @override
  R acceptRouteServet1<R, A>(RouteServetVisitorOneArg<TYPE, R, A> v, A a) => v.visitRouteServetMono(this, a);
}

/// A [PolyServet] that is backed by a child list.
mixin PolyRouteServetListMixin<DATA> implements PolyRouteServet<DATA> {
  List<RouteServet<DATA>> get children;

  @override
  int get length => children.length;

  @override
  RouteServet<DATA> elementAt(int index) => children.elementAt(index);
}
