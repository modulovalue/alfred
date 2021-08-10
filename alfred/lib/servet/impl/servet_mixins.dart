import '../interface/servet.dart';

/// A [LeafServet] mixin that visits its visitor.
mixin LeafServetVisitorMixin<TYPE> implements LeafServet<TYPE> {
  @override
  R acceptServet1<R, A>(
    final ServetVisitorOneArg<TYPE, R, A> v,
    final A a,
  ) =>
      v.visitServetLeaf(this, a);
}

/// A [PolyServet] mixin that visits its visitor.
mixin PolyServetVisitorMixin<TYPE> implements PolyServet<TYPE> {
  @override
  R acceptServet1<R, A>(
    final ServetVisitorOneArg<TYPE, R, A> v,
    final A a,
  ) =>
      v.visitServetPoly(this, a);
}

/// A [MonoServet] mixin that visits its visitor.
mixin MonoServetVisitorMixin<TYPE> implements MonoServet<TYPE> {
  @override
  R acceptServet1<R, A>(
    final ServetVisitorOneArg<TYPE, R, A> v,
    final A a,
  ) =>
      v.visitServetMono(this, a);
}
