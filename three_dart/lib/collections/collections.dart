import '../events/events.dart';
import '../math/math.dart';

/// A collection of objects.
class Collection<T> implements Iterable<T> {
  /// The list of all the items.
  List<T> _list;

  /// The handler method for before adding items to this collection.
  bool Function(Iterable<T> added)? _onPreaddHndl;

  /// The handler method for added items to this collection.
  void Function(int index, Iterable<T> items)? _onAddedHndl;

  /// The handler method for remvoed items to this collection.
  void Function(int index, Iterable<T> items)? _onRemovedHndl;

  /// Constructs a new collection.
  Collection()
      : _list = [],
        _onPreaddHndl = null,
        _onAddedHndl = null,
        _onRemovedHndl = null;

  /// Sets the handlers for this collection.
  ///
  /// This method should be protected (if dart had protected methods).
  /// Do not call this method unless calling from an inheriting or including
  /// class otherwise unexpected errors may occur.
  void setHandlers({
    final bool Function(Iterable<T> added)? onPreaddHndl,
    final void Function(int index, Iterable<T> items)? onAddedHndl,
    final void Function(int index, Iterable<T> items)? onRemovedHndl,
  }) {
    _onPreaddHndl = onPreaddHndl;
    _onAddedHndl = onAddedHndl;
    _onRemovedHndl = onRemovedHndl;
  }

  /// Is called when one or more items are about to be added to this collection.
  bool _onPreadd(
    final Iterable<T> items,
  ) =>
      _onPreaddHndl?.call(items) ?? true;

  /// Is called when one or more items are added to this collection.
  void _onAdded(
    final int index,
    final Iterable<T> added,
  ) =>
      _onAddedHndl?.call(index, added);

  /// Is called when one or more items are removed from this collection.
  void _onRemoved(
    final int index,
    final Iterable<T> removed,
  ) =>
      _onRemovedHndl?.call(index, removed);

  /// Gets the first item in the list.
  @override
  T get first => _list.first;

  /// Gets the last item in the list.
  @override
  T get last => _list.last;

  /// Checks that this iterable has only one element, and returns that element.
  @override
  T get single => _list.single;

  /// Determines if the collection is empty.
  @override
  bool get isEmpty => _list.isEmpty;

  /// Determines if the collection is not empty.
  @override
  bool get isNotEmpty => _list.isNotEmpty;

  /// The number of items in the collection.
  @override
  int get length => _list.length;

  /// Returns a new [Iterator] that allows iterating this collection.
  @override
  Iterator<T> get iterator => _list.iterator;

  /// Checks whether any item in this collection satisfies the given [hndl].
  @override
  bool any(
    final bool Function(T item) hndl,
  ) =>
      _list.any(hndl);

  /// Provides a view of this iterable as an iterable of [T2] instances.
  @override
  Iterable<T2> cast<T2>() => _list.cast<T2>();

  /// Indicates if the given [item] is contained.
  @override
  bool contains(
    final Object? item,
  ) =>
      _list.contains(item);

  /// Gets the item at the given index.
  @override
  T elementAt(
    final int index,
  ) =>
      _list.elementAt(index);

  /// Check if every item in this collection satisfies the given [hndl].
  @override
  bool every(
    final bool Function(T item) hndl,
  ) =>
      _list.every(hndl);

  /// Expands each element of this Iterable into zero or more elements.
  @override
  Iterable<T2> expand<T2>(
    final Iterable<T2> Function(T element) hndl,
  ) =>
      _list.expand<T2>(hndl);

  /// Returns the first element that satisfies the given predicate test.
  @override
  T firstWhere(
    final bool Function(T element) test, {
    final T Function()? orElse,
  }) =>
      _list.firstWhere(test, orElse: orElse);

  /// Reduces a collection to a single value by iteratively
  /// combining each element of the collection with an existing value
  @override
  T2 fold<T2>(
    final T2 initialValue,
    final T2 Function(T2 previousValue, T element) combine,
  ) =>
      _list.fold<T2>(
        initialValue,
        combine,
      );

  /// Returns the lazy concatenation of this iterable and [other].
  @override
  Iterable<T> followedBy(
    final Iterable<T> other,
  ) =>
      _list.followedBy(other);

  /// Calls the given function handler, [hndl], for each item.
  @override
  void forEach(
    final void Function(T item) hndl,
  ) =>
      _list.forEach(hndl);

  /// Converts each element to a String and concatenates the strings.
  @override
  String join([
    final String separator = "",
  ]) =>
      _list.join(separator);

  /// Returns the last element that satisfies the given predicate test.
  @override
  T lastWhere(
    final bool Function(T element) test, {
    final T Function()? orElse,
  }) =>
      _list.lastWhere(test, orElse: orElse);

  /// Returns a new lazy Iterable with elements that are created by calling
  /// [hndl] on each element of this Iterable in iteration order.
  @override
  Iterable<T2> map<T2>(
    final T2 Function(T e) hndl,
  ) =>
      _list.map<T2>(hndl);

  /// Reduces a collection to a single value by iteratively combining
  /// elements of the collection using the provided function.
  @override
  T reduce(
    final T Function(T value, T element) combine,
  ) =>
      _list.reduce(combine);

  /// Returns the single element that satisfies test.
  @override
  T singleWhere(
    final bool Function(T element) test, {
    final T Function()? orElse,
  }) =>
      _list.singleWhere(test, orElse: orElse);

  /// Returns an Iterable that provides all but the first count elements.
  @override
  Iterable<T> skip(
    final int count,
  ) =>
      _list.skip(count);

  /// Returns an Iterable that skips leading elements while test is satisfied.
  @override
  Iterable<T> skipWhile(
    final bool Function(T value) test,
  ) =>
      _list.skipWhile(test);

  /// Returns a lazy iterable of the count first elements of this iterable.
  @override
  Iterable<T> take(
    final int count,
  ) =>
      _list.take(count);

  /// Returns a lazy iterable of the leading elements satisfying test.
  @override
  Iterable<T> takeWhile(
    final bool Function(T value) test,
  ) =>
      _list.takeWhile(test);

  /// Creates a List containing the elements of this Iterable.
  @override
  List<T> toList({
    final bool growable = true,
  }) =>
      _list.toList(growable: growable);

  /// Creates a Set containing the same elements as this iterable.
  @override
  Set<T> toSet() => _list.toSet();

  /// Returns a new lazy Iterable with all elements that satisfy the predicate test.
  @override
  Iterable<T> where(
    final bool Function(T element) test,
  ) =>
      _list.where(test);

  /// Gets the index of the given [item].
  /// The optional [start] is the index to start looking at.
  int indexOf(
    final T item, [
    final int start = 0,
  ]) =>
      _list.indexOf(item, start);

  /// Adds the given [item] to this collection.
  void add(
    final T item,
  ) {
    if (_onPreadd([item])) {
      final index = _list.length;
      _list.add(item);
      _onAdded(index, [item]);
    }
  }

  /// Adds the given [items] to this collection.
  void addAll(
    final Iterable<T> items,
  ) {
    if (_onPreadd(items)) {
      final index = _list.length;
      _list.addAll(items);
      _onAdded(index, items);
    }
  }

  /// Inserts the given [item] into the given [index].
  void insert(
    final int index,
    final T item,
  ) {
    if (_onPreadd([item])) {
      _list.insert(index, item);
      _onAdded(index, [item]);
    }
  }

  /// Inserts all the [items] at the given [index].
  void insertAll(
    final int index,
    final Iterable<T> items,
  ) {
    if (_onPreadd(items)) {
      _list.insertAll(index, items);
      _onAdded(index, items);
    }
  }

  /// Gets the item at the given [index].
  T operator [](
    final int index,
  ) =>
      _list[index];

  /// Sets the item at the at given index.
  void operator []=(
    final int index,
    final T item,
  ) {
    final older = _list[index];
    if ((older != item) && _onPreadd([item])) {
      _list[index] = item;
      _onRemoved(index, [older]);
      _onAdded(index, [item]);
    }
  }

  /// Removed the first instance of the given [item] from this collection.
  /// True is returned if the item was found and removed, false if not found.
  bool remove(
    final T item,
  ) {
    final index = _list.indexOf(item);
    if (index > 0) {
      removeAt(index);
      return true;
    } else {
      return false;
    }
  }

  /// Removes all instances of the given [item] from the list.
  int removeAll(
    final T item,
  ) {
    int count = 0;
    while (remove(item)) {
      count++;
    }
    return count;
  }

  /// Removes the item at the given [index] in this collection.
  /// The removed item is returned or null if out-of-bounds.
  T removeAt(
    final int index,
  ) {
    if ((index < 0) || (index >= _list.length)) {
      return null as T;
    } else {
      final item = _list.removeAt(index);
      _onRemoved(index, [item]);
      return item;
    }
  }

  /// Removes the given range from the list.
  List<T> removeRange(
    final int index,
    final int length,
  ) {
    final items = _list.sublist(index, index + length);
    if (items.isNotEmpty) {
      _list.removeRange(index, index + length);
      _onRemoved(index, items);
    }
    return items;
  }

  /// Returns a new lazy [Iterable] with all elements that have type [T].
  @override
  Iterable<U> whereType<U>() => _list.whereType();

  /// Removes all the items.
  void clear() {
    if (_list.isNotEmpty) {
      final items = _list;
      _list = [];
      _onRemoved(0, items);
    }
  }
}

/// A stack of matrix 4x4s.
class Matrix4Stack implements Changeable {
  /// The list storing the stack.
  final List<Matrix4> _mat;

  /// The event indicating the stack has changed.
  Event? _changed;

  /// Creates a new matrix stack.
  Matrix4Stack()
      : _mat = [],
        _changed = null;

  /// Clears the stack.
  void clear() {
    _mat.clear();
    _onChanged();
  }

  /// The length of the stack.
  int get length => _mat.length;

  /// The event emitted when the stack has changed.
  @override
  Event get changed => _changed ??= Event();

  /// Handles changes to the stack.
  void _onChanged([
    final EventArgs? args,
  ]) =>
      _changed?.emit(args);

  /// The current matrix on the top of the stack.
  /// Returns the identity matrix if the stack is empty.
  Matrix4 get matrix {
    if (_mat.isNotEmpty) {
      return _mat.last;
    } else {
      return Matrix4.identity;
    }
  }

  /// Pushes a new matrix onto the stack.
  /// If null is pushed the identity matrix will be put on the top of the stack.
  void push(
    final Matrix4? mat,
  ) {
    if (mat == null) {
      _mat.add(Matrix4.identity);
    } else {
      _mat.add(mat);
    }
    _onChanged();
  }

  /// Pushes a new matrix onto the stack which is the multiple of this and the given [mat].
  /// If null is pushed the current top of the stack will be pushed on the top
  /// of the stack as if multiplies by the identity.
  void pushMul(
    final Matrix4? mat,
  ) {
    if (mat == null) {
      _mat.add(matrix);
    } else {
      _mat.add(mat * matrix);
    }
    _onChanged();
  }

  /// Pops the top matrix from the stack.
  void pop() {
    if (_mat.isNotEmpty) {
      _mat.removeLast();
      _onChanged();
    }
  }
}
