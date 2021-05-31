/// A [Servet] is a server widget.
abstract class Servet<TYPE> {
  R acceptServet1<R, A>(ServetVisitorOneArg<TYPE, R, A> v, A a);
}

/// A [Servet] without any children.
abstract class LeafServet<TYPE> implements Servet<TYPE> {}

/// A [Servet] with many children.
abstract class PolyServet<TYPE> implements Servet<TYPE> {
  int get length;

  TYPE elementAt(int index);
}

/// A [Servet] with one child.
abstract class MonoServet<TYPE> implements Servet<TYPE> {
  TYPE get child;
}

/// A one argument [Servet] visitor.
abstract class ServetVisitorOneArg<TYPE, R, A> {
  R visitServetLeaf(LeafServet<TYPE> node, A arg);

  R visitServetPoly(PolyServet<TYPE> node, A arg);

  R visitServetMono(MonoServet<TYPE> node, A arg);
}
