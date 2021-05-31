import 'servet.dart';

/// Base class for [Servet]s that build routing trees.
///
/// [RouteServet]s contain [RouteServet]s.
abstract class RouteServet<DATA> implements Servet<RouteServet<DATA>> {
  R acceptRouteServet1<R, A>(RouteServetVisitorOneArg<DATA, R, A> v, A a);
}

/// Base class for [Servet]s that route to multiple routes.
abstract class PolyRouteServet<DATA> implements RouteServet<DATA>, PolyServet<RouteServet<DATA>> {}

/// A [RouteServet]s that maps to a single []
abstract class MonoRouteServet<DATA> implements RouteServet<DATA>, MonoServet<RouteServet<DATA>> {}

/// A [RouteServet]s that contains data.
abstract class LeafRouteServet<DATA> implements RouteServet<DATA>, LeafServet<RouteServet<DATA>> {
  DATA get data;
}

/// A one argument [RouteServet] visitor.
abstract class RouteServetVisitorOneArg<DATA, R, A> {
  R visitRouteServetLeaf(LeafRouteServet<DATA> node, A arg);

  R visitRouteServetPoly(PolyRouteServet<DATA> node, A arg);

  R visitRouteServetMono(MonoRouteServet<DATA> node, A arg);
}
