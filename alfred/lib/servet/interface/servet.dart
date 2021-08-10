/// A [Servet] is a server widget.
abstract class Servet<TYPE> {
  R acceptServet1<R, A>(
    final ServetVisitorOneArg<TYPE, R, A> v,
    final A a,
  );
}

/// A [Servet] without any children.
abstract class LeafServet<TYPE> implements Servet<TYPE> {}

/// A [Servet] with many children.
abstract class PolyServet<TYPE> implements Servet<TYPE> {
  int get length;

  TYPE elementAt(final int index);
}

/// A [Servet] with one child.
abstract class MonoServet<TYPE> implements Servet<TYPE> {
  TYPE get child;
}

/// A one argument [Servet] visitor.
abstract class ServetVisitorOneArg<TYPE, R, A> {
  R visitServetLeaf(
    final LeafServet<TYPE> node,
    final A arg,
  );

  R visitServetPoly(
    final PolyServet<TYPE> node,
    final A arg,
  );

  R visitServetMono(
    final MonoServet<TYPE> node,
    final A arg,
  );
}
