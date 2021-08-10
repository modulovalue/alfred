import 'servet.dart';

/// Base class for [Servet]s that build routing trees.
///
/// [RouteServet]s contain [RouteServet]s.
abstract class RouteServet<DATA> implements Servet<RouteServet<DATA>> {
  R acceptRouteServet1<R, A>(
    final RouteServetVisitorOneArg<DATA, R, A> v,
    final A a,
  );
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
  R visitRouteServetLeaf(
    final LeafRouteServet<DATA> node,
    final A arg,
  );

  R visitRouteServetPoly(
    final PolyRouteServet<DATA> node,
    final A arg,
  );

  R visitRouteServetMono(
    final MonoRouteServet<DATA> node,
    final A arg,
  );
}
