import 'dart:async' as async;

/// The method signature for event handlers.
/// The [args] are any additional information about the event.
typedef EventHandler = void Function(EventArgs args);

/// The collection of handles which can be called when some action has occurred.
///
/// This is similar to an [async.Stream] except it is lighter weight and
/// allows event handlers to be fired synchronized in a specific order.
class Event {
  /// The list of the event handlers to call when this event is emitted.
  List<EventHandler>? _hndls;

  /// The list of the event handlers to call only once when this event is emitted.
  List<EventHandler>? _onceHndls;

  /// The pending argument from the first emit while the event is suspended.
  EventArgs? _pendingArgs;

  /// Indicates if the event is suspended or not.
  int _suspended;

  /// Constructs a new event.
  Event()
      : this._hndls = null,
        this._onceHndls = null,
        this._pendingArgs = null,
        this._suspended = 0;

  /// Indicates that there are no handlers attached to this events.
  bool get isEmpty => (this._hndls?.isEmpty ?? true) && (this._onceHndls?.isEmpty ?? true);

  /// Adds a new event handler to be called by this event when an action has occurred.
  void add(EventHandler hndl) => (this._hndls ??= []).add(hndl);

  /// Adds a new event handler to be called by this event when an action has occurred.
  /// This event is only called once and then removed.
  void once(EventHandler hndl) => (this._onceHndls ??= []).add(hndl);

  /// Removes the first instance of the event handler from this event.
  /// True is returned if the handler is found, false if not found.
  bool remove(EventHandler hndl) {
    bool removed = false;
    if (this._hndls?.contains(hndl) ?? false) removed = (this._hndls?.remove(hndl) ?? false) || removed;
    if (this._onceHndls?.contains(hndl) ?? false) removed = (this._onceHndls?.remove(hndl) ?? false) || removed;
    return removed;
  }

  /// Emits this event to all the attached event handlers.
  ///
  /// The [args] will be submitted to each event handler.
  /// The event will not be emitted if it is currently suspended.
  /// The method will return after all event handlers has returned.
  /// Returns true if any handler could be emitted even if suspended, false if empty.
  bool emit([EventArgs? args]) {
    if (this.isEmpty) return false;
    final args2 = args ?? EventArgs(null);
    if (this.suspended) {
      if (!this.pending) this._pendingArgs = args2;
      return true;
    }
    final hndls = this._hndls;
    if (hndls != null) {
      // Create a copy so that if this event is modified
      // inside of it's handler it doesn't cause a problem.
      final copy = List<EventHandler>.from(hndls);
      copy.forEach((EventHandler hndl) {
        if (args2.propagate) hndl(args2);
      });
    }
    final onceHndls = this._onceHndls;
    if (onceHndls != null) {
      final lastOnce = onceHndls;
      this._onceHndls = [];
      lastOnce.forEach((EventHandler hndl) {
        if (args2.propagate) hndl(args2);
      });
    }
    return true;
  }

  /// Puts a future into the main event loop to emit this event.
  ///
  /// The [args] will be submitted to each event handler.
  /// This is not effected by the suspended flag.
  /// The future is returned.
  async.Future<void> asyncEmit([
    EventArgs? args,
  ]) =>
      async.Future<void>(() => this.emit(args));

  /// Suspends this event or increases the level of suspension.
  void suspend() {
    this._suspended++;
  }

  /// True if this event is suspended, false otherwise.
  bool get suspended => this._suspended > 0;

  /// True if an emit was called while suspended and that emit is pending.
  bool get pending => this._pendingArgs != null;

  /// The arguments of the first emit called while suspended.
  ///
  /// The pending argument is used once the event is resumed.
  EventArgs? get pendingArgs => this._pendingArgs;

  set pendingArgs(EventArgs? args) => this._pendingArgs = args;

  /// Resumes the event or removes a level of suspension.
  ///
  /// If an argument is pending and [emitPending] is true then
  /// the event is emitted with that pending argument.
  /// If [force] is set to true then the level of suspension is
  /// ignored an the event is immediately set to no longer suspended.
  void resume({bool force = false, bool emitPending = true}) {
    if (this.suspended) {
      if (force) {
        this._suspended = 0;
      } else {
        this._suspended--;
      }
      if ((!this.suspended) && emitPending && pending) {
        final args = this._pendingArgs;
        this._pendingArgs = null;
        this.emit(args);
      }
    }
  }
}

/// The event argument for carrying an event's additional information.
class EventArgs {
  /// The sender of the event.
  final Object? sender;

  /// Indicates if the event should be passed onto the next event handler (true),
  /// or stopped being handled (false).
  bool propagate;

  /// Creates a new event argument.
  EventArgs(this.sender) : this.propagate = true;
}

/// The event argument for event's when items are added to a collection.
class ItemsAddedEventArgs<T> extends EventArgs {
  /// The index that the items were inserted at.
  final int index;

  /// The list of items which were added.
  final Iterable<T> added;

  /// Creates an items added event argument.
  ItemsAddedEventArgs(Object sender, this.index, this.added) : super(sender);
}

/// The event argument for event's when items removed from a collection.
class ItemsRemovedEventArgs<T> extends EventArgs {
  /// The index that the items were taken from.
  final int index;

  /// The list of items which were removed.
  final Iterable<T> removed;

  /// Creates an items removed event argument.
  ItemsRemovedEventArgs(Object sender, this.index, this.removed) : super(sender);
}

/// The event argument for event's with information about entities changing.
class ValueChangedEventArgs<T> extends EventArgs {
  /// The name of the value which was changed in the sender.
  final String name;

  /// The previous value (or null) of the value before it was changed.
  final T previous;

  /// The current value that the value was just changed to.
  final T value;

  /// Creates an entity event argument.
  ValueChangedEventArgs(Object sender, this.name, this.previous, this.value) : super(sender);

  /// The string for this event argument.
  @override
  String toString() => "ValueChanged: $name, $previous => $value";
}

/// The interface for a Changeable.
abstract class Changeable {
  /// Emits when the object has changed.
  ///
  /// On change typically indicates a new render is needed.
  Event get changed;
}
