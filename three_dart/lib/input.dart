import 'dart:async';
import 'dart:html' as html;

import 'collections.dart';
import 'core.dart';
import 'events.dart';
import 'math.dart';

/// The user input object for changing HTML Element events
/// into 3Dart events for user input.
class UserInput {
  final html.Element _elem;
  KeyInput? _key;
  MouseInput? _mouse;
  LockedMouseInput? _locked;
  TouchInput? _touch;
  bool _focused;
  bool _lockOnClick;
  bool _pointerLocked;
  html.MouseEvent? _msEventOnLock;
  final List<StreamSubscription<Object>> _eventStreams;
  final double _wheelScalar;

  /// Creates a new user input for the given [_elem].
  UserInput(
    final this._elem,
  )   : this._key = null,
        this._mouse = null,
        this._locked = null,
        this._touch = null,
        this._focused = false,
        this._lockOnClick = false,
        this._pointerLocked = false,
        this._msEventOnLock = null,
        this._eventStreams = [],
        this._wheelScalar = (() {
          if (Environment.browser == Browser.firefox) {
            return 1.0 / 6.0;
          } else {
            return 1.0 / 180.0;
          }
        }()) {
    this._eventStreams.add(html.document.onContextMenu.listen(this._onContentMenu));
    this._eventStreams.add(this._elem.onFocus.listen(this._onFocus));
    this._eventStreams.add(this._elem.onBlur.listen(this._onBlur));
    this._eventStreams.add(html.document.onKeyUp.listen(this._onKeyUp));
    this._eventStreams.add(html.document.onKeyDown.listen(this._onKeyDown));
    this._eventStreams.add(this._elem.onMouseDown.listen(this._onMouseDown));
    this._eventStreams.add(this._elem.onMouseUp.listen(this._onMouseUp));
    this._eventStreams.add(this._elem.onMouseMove.listen(this._onMouseMove));
    this._eventStreams.add(this._elem.onMouseWheel.listen(this._onMouseWheel));
    this._eventStreams.add(html.document.onMouseMove.listen(this._onDocMouseMove));
    this._eventStreams.add(html.document.onMouseUp.listen(this._onDocMouseUp));
    this._eventStreams.add(html.document.onPointerLockChange.listen(this._onPointerLockChanged));
    this._eventStreams.add(this._elem.onTouchStart.listen(this._onTouchStart));
    this._eventStreams.add(this._elem.onTouchEnd.listen(this._onTouchEnd));
    this._eventStreams.add(this._elem.onTouchMove.listen(this._onTouchMove));
  }

  /// Disposes the user input.
  void dispose() {
    for (final stream in this._eventStreams) {
      stream.cancel();
    }
    this._eventStreams.clear();
    if (this._pointerLocked) {
      this._pointerLocked = false;
      html.document.exitPointerLock();
    }
  }

  /// Key handler for the user keyboard input.
  KeyInput get key => this._key ??= KeyInput._();

  /// Mouse handler for the user mouse input.
  MouseInput get mouse => this._mouse ??= MouseInput._(this);

  /// Locked mouse handler for the user locked mouse input.
  LockedMouseInput get locked => this._locked ??= LockedMouseInput._(this);

  /// Touch pad handler for the user touch or mobile input.
  TouchInput get touch => this._touch ??= TouchInput._(this);

  /// Gets or sets if the mouse should lock the pointer on click.
  bool get lockOnClick => this._lockOnClick;

  set lockOnClick(
    final bool enable,
  ) {
    this._lockOnClick = enable;
  }

  /// Determines if this element is focused.
  bool get hasFocus => this._focused;

  // Indicates if the mouse is locked.
  bool get pointerLocked => this._pointerLocked;

  /// Determines the rectangle for the client of the element being watched.
  Region2 get clientRect => Region2(0.0, 0.0, this._elem.client.width.toDouble(), this._elem.client.height.toDouble());

  /// Converts the html key into the 3Dart key.
  Key _convertKey(
    final html.KeyboardEvent kEvent,
  ) =>
      Key(kEvent.keyCode, ctrl: kEvent.ctrlKey || kEvent.metaKey, alt: kEvent.altKey, shift: kEvent.shiftKey);

  /// Sets the modifier keys for a mouse event.
  void _setMouseModifiers(
    final html.MouseEvent msEvent,
  ) {
    this.key._mods = Modifiers(msEvent.ctrlKey || msEvent.metaKey, msEvent.altKey, msEvent.shiftKey);
  }

  /// Sets the modifier keys for a touch event.
  void _setTouchModifiers(
    final html.TouchEvent? tEvent,
  ) {
    if (tEvent == null) {
      this.key._mods = Modifiers.none();
    } else {
      final ctrl = (tEvent.ctrlKey ?? false) || (tEvent.metaKey ?? false);
      this.key._mods = Modifiers(ctrl, tEvent.altKey ?? false, tEvent.shiftKey ?? false);
    }
  }

  /// Gets the raw mouse point relative to the client rectangle in pixels.
  Point2 _rawPoint(
    final html.MouseEvent? msEvent,
  ) {
    if (msEvent == null) {
      return Point2.zero;
    } else {
      final rect = this._elem.getBoundingClientRect();
      return Point2((msEvent.page.x - rect.left).toDouble(), (msEvent.page.y - rect.top).toDouble());
    }
  }

  /// Gets the raw movement on the client in delta pixels.
  Vector2 _rawMove(
    final html.MouseEvent? msEvent,
  ) {
    if (msEvent == null) {
      return Vector2.zero;
    } else {
      return Vector2(msEvent.movement.x.toDouble(), msEvent.movement.y.toDouble());
    }
  }

  /// Gets the raw touch points relative to the client rectangle in pixels.
  List<Point2> _rawTouchPoints(
    final html.TouchEvent? tEvent,
  ) {
    if (tEvent == null) {
      return [];
    } else {
      final rect = this._elem.getBoundingClientRect();
      final pnts = <Point2>[];
      for (final touch in tEvent.touches ?? <html.Touch>[]) {
        pnts.add(Point2((touch.page.x - rect.left).toDouble(), (touch.page.y - rect.top).toDouble()));
      }
      return pnts;
    }
  }

  /// Converts the html button into the 3Dart button.
  Button _convertButton(
    final html.MouseEvent? msEvent,
  ) {
    if (msEvent == null) {
      return Button(0);
    } else {
      return Button(
        msEvent.buttons ?? 0,
        ctrl: msEvent.ctrlKey || msEvent.metaKey,
        alt: msEvent.altKey,
        shift: msEvent.shiftKey,
      );
    }
  }

  /// Determines if the given mouse location is contained in the canvas.
  bool _mouseContained(
    final html.MouseEvent msEvent,
  ) {
    final rect = this._elem.getBoundingClientRect();
    final x = msEvent.page.x - rect.left;
    if (x < 0) {
      return false;
    } else {
      final y = msEvent.page.y - rect.top;
      if (y < 0) {
        return false;
      } else {
        return (x < rect.width) && (y < rect.height);
      }
    }
  }

  /// Handles focus of the canvas.
  void _onFocus(
    final html.Event _,
  ) =>
      this._focused = true;

  /// Handles blur (focus lost) of the canvas.
  void _onBlur(
    final html.Event _,
  ) =>
      this._focused = false;

  /// Handles cancelling the content menu for the canvas.
  void _onContentMenu(
    final html.MouseEvent msEvent,
  ) {
    if (this.hasFocus && this._mouseContained(msEvent)) {
      msEvent.preventDefault();
    }
  }

  /// Handles a keyboard key being released.
  void _onKeyUp(
    final html.KeyboardEvent kEvent,
  ) {
    if (this.hasFocus) {
      final key = this._convertKey(kEvent);
      if (this.key.performUp(key)) {
        kEvent.preventDefault();
      }
    }
  }

  /// Handles a keyboard key being pressed.
  void _onKeyDown(
    final html.KeyboardEvent kEvent,
  ) {
    if (this.hasFocus) {
      final key = this._convertKey(kEvent);
      if (this.key.performDown(key)) {
        kEvent.preventDefault();
      }
    }
  }

  /// Handles the mouse down in canvas event.
  void _onMouseDown(
    final html.MouseEvent msEvent,
  ) {
    this._elem.focus();
    this._focused = true; // This is here because focus/blur doesn't work right now.
    this._setMouseModifiers(msEvent);
    if (this._pointerLocked) {
      final button = this._convertButton(msEvent);
      final vec = this._rawMove(msEvent);
      if (this.locked.performDown(button, vec)) {
        msEvent.preventDefault();
      }
      return;
    }
    if (this._lockOnClick) {
      this._msEventOnLock = msEvent;
      this._elem.requestPointerLock();
      return;
    }
    final button = this._convertButton(msEvent);
    final pnt = this._rawPoint(msEvent);
    if (this.mouse.performDown(button, pnt)) {
      msEvent.preventDefault();
    }
  }

  /// Handles the mouse up in canvas event.
  void _onMouseUp(
    final html.MouseEvent msEvent,
  ) {
    this._setMouseModifiers(msEvent);
    final button = this._convertButton(msEvent);
    if (this._pointerLocked) {
      final vec = this._rawMove(msEvent);
      if (this.locked.performUp(button, vec)) {
        msEvent.preventDefault();
      }
      return;
    }
    if (this._lockOnClick) {
      return;
    }
    final pnt = this._rawPoint(msEvent);
    if (this.mouse.performUp(button, pnt)) {
      msEvent.preventDefault();
    }
  }

  /// Handles the mouse up outside the canvas event
  /// when the mouse was pressed while over the canvas.
  void _onDocMouseUp(
    final html.MouseEvent msEvent,
  ) {
    if (!this._mouseContained(msEvent)) {
      this._setMouseModifiers(msEvent);
      final button = this._convertButton(msEvent);
      if (this._pointerLocked) {
        final vec = this._rawMove(msEvent);
        if (this.locked.performUp(button, vec)) {
          msEvent.preventDefault();
        }
        return;
      }
      if (this._lockOnClick) {
        return;
      }
      final pnt = this._rawPoint(msEvent);
      if (this.mouse.performUp(button, pnt)) {
        msEvent.preventDefault();
      }
    }
  }

  /// Handles the mouse move on the canvas event.
  void _onMouseMove(
    final html.MouseEvent msEvent,
  ) {
    this._setMouseModifiers(msEvent);
    final button = this._convertButton(msEvent);
    if (this._pointerLocked) {
      final vec = this._rawMove(msEvent);
      if (this.locked.performMove(button, vec)) {
        msEvent.preventDefault();
      }
      return;
    }
    if (!this._lockOnClick) {
      final pnt = this._rawPoint(msEvent);
      if (this.mouse.performMove(button, pnt)) {
        msEvent.preventDefault();
      }
    }
  }

  /// Handles the mouse move off the canvas event
  /// when the mouse was pressed while over the canvas.
  void _onDocMouseMove(
    final html.MouseEvent msEvent,
  ) {
    if (!this._mouseContained(msEvent)) {
      this._setMouseModifiers(msEvent);
      final button = this._convertButton(msEvent);
      if (this._pointerLocked) {
        final vec = this._rawMove(msEvent);
        if (this.locked.performMove(button, vec)) {
          msEvent.preventDefault();
        }
        return;
      }
      if (this._lockOnClick) {
        return;
      }
      final pnt = this._rawPoint(msEvent);
      if (this.mouse.performMove(button, pnt)) {
        msEvent.preventDefault();
      }
    }
  }

  /// Handles the mouse wheel being moved over the canvas.
  void _onMouseWheel(
    final html.WheelEvent msEvent,
  ) {
    this._setMouseModifiers(msEvent);
    final wheel = Vector2(msEvent.deltaX.toDouble(), msEvent.deltaY.toDouble()) * this._wheelScalar;
    if (this._pointerLocked) {
      if (this.locked.performWheel(wheel)) {
        msEvent.preventDefault();
      }
      return;
    }
    if (this._lockOnClick) {
      return;
    }
    final pnt = this._rawPoint(msEvent);
    if (this.mouse.performWheel(wheel, pnt)) {
      msEvent.preventDefault();
    }
  }

  /// Handles the mouse lock and unlock on the canvas.
  void _onPointerLockChanged(
    final html.Event _,
  ) {
    final locked = html.document.pointerLockElement == this._elem;
    if (locked != this._pointerLocked) {
      this._pointerLocked = locked;
      final button = this._convertButton(this._msEventOnLock);
      final pnt = this._rawPoint(this._msEventOnLock);
      this.locked._onLockChanged(button, pnt, locked);
    }
  }

  // Handles touch screen point presses starting on the canvas.
  void _onTouchStart(
    final html.TouchEvent tEvent,
  ) {
    this._elem.focus();
    this._focused = true; // TODO: Fix focus. This is here because focus/blur doesn't work right now.
    this._setTouchModifiers(tEvent);
    final pnts = this._rawTouchPoints(tEvent);
    if (this.touch.performStart(pnts)) tEvent.preventDefault();
  }

  // Handles touch screen point presses ending.
  void _onTouchEnd(
    final html.TouchEvent tEvent,
  ) {
    this._setTouchModifiers(tEvent);
    final pnts = this._rawTouchPoints(tEvent);
    if (this.touch.performEnd(pnts)) {
      tEvent.preventDefault();
    }
  }

  // Handles touch screen points moving.
  void _onTouchMove(
    final html.TouchEvent tEvent,
  ) {
    this._setTouchModifiers(tEvent);
    final pnts = this._rawTouchPoints(tEvent);
    if (this.touch.performMove(pnts)) {
      tEvent.preventDefault();
    }
  }
}

/// The touch screen user input object for changing HTML Element events
/// into 3Dart events for user input.
class TouchInput {
  /// The reference to the owner object.
  final UserInput _input;

  /// The event to emit when a touch has started.
  Event? _start;

  /// The event to emit when a touch has ended.
  Event? _end;

  /// The event to emit when the mouse is moved.
  Event? _move;

  /// The point, in pixels, in which the mouse button was last pressed or released.
  Point2 _startPnt;

  /// The point, in pixels, of the last mouse event.
  Point2 _prevPnt;

  /// The time in which the mouse button was last pressed or released.
  DateTime _startTime;

  /// The time of the last mouse event.
  DateTime _prevTime;

  /// Creates a new user input for the given [_input].
  TouchInput._(
    final this._input,
  )   : this._start = null,
        this._end = null,
        this._move = null,
        this._startPnt = Point2.zero,
        this._prevPnt = Point2.zero,
        this._startTime = DateTime.now(),
        this._prevTime = DateTime.now();

  /// Gets the locked mouse arguments.
  /// If [setStart] is true then the start point and time are set.
  TouchEventArgs _getMouseArgs(
    final List<Point2> pnts,
    final bool setStart,
  ) {
    final curTime = DateTime.now();
    final Point2 pnt;
    if (pnts.isNotEmpty) {
      pnt = pnts[0];
    } else {
      pnt = Point2.zero;
    }
    final args = TouchEventArgs(
      this,
      pnts,
      this._input.clientRect,
      this._startPnt,
      this._prevPnt,
      pnt,
      this._startTime,
      this._prevTime,
      curTime,
    );
    if (setStart) {
      this._startTime = curTime;
      this._startPnt = pnt;
    }
    this._prevTime = curTime;
    this._prevPnt = pnt;
    return args;
  }

  // Performs a touch screen touch start.
  // Returns true if any events were called, false if none were called.
  bool performStart(
    final List<Point2> pnts,
  ) {
    if (this._start == null) {
      return false;
    }
    this._start?.emit(this._getMouseArgs(pnts, true));
    return true;
  }

  // Performs a touch screen touch end.
  // Returns true if any events were called, false if none were called.
  bool performEnd(
    final List<Point2> pnts,
  ) {
    if (this._end == null) return false;
    this._end?.emit(this._getMouseArgs(pnts, true));
    return true;
  }

  // Performs a touch screen touch movement.
  // Returns true if any events were called, false if none were called.
  bool performMove(
    final List<Point2> pnts,
  ) {
    if (this._move == null) {
      return false;
    }
    this._move?.emit(this._getMouseArgs(pnts, false));
    return true;
  }

  /// The mouse start event.
  Event get start => this._start ??= Event();

  /// The mouse up event.
  Event get end => this._end ??= Event();

  /// The mouse move event.
  Event get move => this._move ??= Event();
}

/// A touch event argument.
class TouchEventArgs extends PointEventArgs {
  /// All the touched points.
  final List<Point2> points;

  /// The point, in pixels, at which the mouse button was last pressed or released.
  final Point2 startRawPoint;

  /// The point, in pixels, of the last mouse event.
  final Point2 previousRawPoint;

  /// The start time at which the mouse button was last pressed or released.
  final DateTime startTime;

  /// The time of the last mouse event.
  final DateTime previousTime;

  /// Creates a touch event argument.
  TouchEventArgs(
    final Object sender,
    final this.points,
    final Region2 size,
    final this.startRawPoint,
    final this.previousRawPoint,
    final Point2 rawPoint,
    final this.startTime,
    final this.previousTime,
    final DateTime currentTime,
  ) : super(sender, size, rawPoint, currentTime);

  /// The start point adjusted into the region.
  Point2 get adjustedStartPoint => this.size.adjustPoint(this.startRawPoint);

  /// The previous point adjusted into the region.
  Point2 get adjustedPreviousPoint => this.size.adjustPoint(this.previousRawPoint);

  /// The change, in pixels, between the previous point and this point.
  Vector2 get rawDelta => this.previousRawPoint.vectorTo(this.rawPoint);

  /// The change, in pixels, between the start point and this point.
  Vector2 get rawOffset => this.startRawPoint.vectorTo(this.rawPoint);

  /// The change from the previous point and this point adjusted into the region.
  Vector2 get adjustedDelta => this.size.adjustVector(this.rawDelta);

  /// The change from the start point and this point adjusted into the region.
  Vector2 get adjustedOffset => this.size.adjustVector(this.rawOffset);

  /// The change in time, in seconds, from the previous time to this time.
  double get dt => this.currentTime.difference(this.previousTime).inMilliseconds * 0.001;

  /// The change in time, in seconds, from the start time to this time.
  double get dtTotal => this.currentTime.difference(this.startTime).inMilliseconds * 0.001;
}

/// The event argument for event's with information about a point on a region.
class PointEventArgs extends EventArgs {
  /// The size of the canvas or region.
  /// This is used to adjust the raw points into the region's normalized space.
  final Region2 size;

  /// The raw point, in pixels, on the region.
  final Point2 rawPoint;

  /// The current wall time that the event started on.
  final DateTime currentTime;

  /// Creates a new point event argument.
  PointEventArgs(
    final Object sender,
    final this.size,
    final this.rawPoint,
    final this.currentTime,
  ) : super(
          sender,
        );

  /// The adjusted point normalized to the region.
  Point2 get adjustedPoint => this.size.adjustPoint(this.rawPoint);
}

/// The mouse wheel event argument.
class MouseWheelEventArgs extends PointEventArgs {
  /// The amount the wheel has changed, typically only the y axis has changed.
  final Vector2 wheel;

  /// Creates a mouse wheel event argument.
  MouseWheelEventArgs(
    final Object sender,
    final Region2 size,
    final Point2 rawPoint,
    final DateTime currentTime,
    final this.wheel,
  ) : super(sender, size, rawPoint, currentTime);
}

/// The user mouse input object for changing HTML Element events
/// into 3Dart events for user mouse input.
class MouseInput {
  /// The reference to the owner object.
  final UserInput _input;

  /// The event to emit when the mouse button is pressed.
  Event? _down;

  /// The event to emit when the mouse button is released.
  Event? _up;

  /// The event to emit when the mouse is moved.
  Event? _move;

  /// The event to emit when the mouse wheel is moved.
  Event? _wheel;

  /// Indicates if the mouse buttons which are pressed or not.
  int _buttons;

  /// The point, in pixels, in which the mouse button was last pressed or released.
  Point2 _startPnt;

  /// The point, in pixels, of the last mouse event.
  Point2 _prevPnt;

  /// The time in which the mouse button was last pressed or released.
  DateTime _startTime;

  /// The time of the last mouse event.
  DateTime _prevTime;

  /// The horizontal mouse wheel movement sensitivity.
  double _whSensitivity;

  /// The vertical mouse wheel movement sensitivity.
  double _wvSensitivity;

  /// Creates a new user mouse input.
  MouseInput._(
    final this._input,
  )   : this._down = null,
        this._up = null,
        this._move = null,
        this._wheel = null,
        this._buttons = 0,
        this._startPnt = Point2.zero,
        this._prevPnt = Point2.zero,
        this._startTime = DateTime.now(),
        this._prevTime = DateTime.now(),
        this._whSensitivity = 1.0,
        this._wvSensitivity = 1.0;

  /// Gets the mouse arguments.
  /// If [setStart] is true then the start point and time are set.
  MouseEventArgs _getMouseArgs(
    final Button button,
    final Point2 pnt,
    final bool setStart,
  ) {
    final curTime = DateTime.now();
    final args = MouseEventArgs(
      this,
      button,
      this._input.clientRect,
      this._startPnt,
      this._prevPnt,
      pnt,
      this._startTime,
      this._prevTime,
      curTime,
    );
    if (setStart) {
      this._startTime = curTime;
      this._startPnt = pnt;
    }
    this._prevTime = curTime;
    this._prevPnt = pnt;
    return args;
  }

  // Performs a mouse press down event.
  // This also sets the button code currently pressed.
  // Returns true if any events were called, false if none were called.
  bool performDown(Button button, Point2 pnt) {
    this._buttons = button.code;
    if (this._down == null) return false;
    this._down?.emit(this._getMouseArgs(button, pnt, true));
    return true;
  }

  // Performs a mouse press up event.
  // This also unsets the button code currently pressed.
  // Returns true if any events were called, false if none were called.
  bool performUp(Button button, Point2 pnt) {
    this._buttons &= ~button.code;
    if (this._up == null) return false;
    this._up?.emit(this._getMouseArgs(button, pnt, true));
    return true;
  }

  // Performs a mouse move event.
  // Returns true if any events were called, false if none were called.
  bool performMove(Button button, Point2 pnt) {
    if (this._move == null) return false;
    this._move?.emit(this._getMouseArgs(button, pnt, false));
    return true;
  }

  // Performs a mouse wheel event.
  // Returns true if any events were called, false if none were called.
  bool performWheel(Vector2 wheel, Point2 pnt) {
    if (this._wheel == null) return false;
    this._wheel?.emit(MouseWheelEventArgs(this, this._input.clientRect, pnt, DateTime.now(),
        Vector2(wheel.dx * this._whSensitivity, wheel.dy * this._wvSensitivity)));
    return true;
  }

  /// The horizontal mouse wheel movement sensitivity.
  double get wheelHorizontalSensitivity => this._whSensitivity;

  set wheelHorizontalSensitivity(double sensitivity) => this._whSensitivity = sensitivity;

  /// The vertical mouse wheel movement sensitivity.
  double get wheelVerticalSensitivity => this._wvSensitivity;

  set wheelVerticalSensitivity(double sensitivity) => this._wvSensitivity = sensitivity;

  /// The mouse down event.
  Event get down => this._down ??= Event();

  /// The mouse up event.
  Event get up => this._up ??= Event();

  /// The mouse move event.
  Event get move => this._move ??= Event();

  /// The mouse wheel move event.
  Event get wheel => this._wheel ??= Event();

  /// Indicates the mouse buttons which are currently pressed.
  int get buttons => this._buttons;
}

/// A mouse event argument.
class MouseEventArgs extends PointEventArgs {
  /// The mouse buttons which are pressed, false otherwise.
  final Button button;

  /// The point, in pixels, at which the mouse button was last pressed or released.
  final Point2 startRawPoint;

  /// The point, in pixels, of the last mouse event.
  final Point2 previousRawPoint;

  /// The start time at which the mouse button was last pressed or released.
  final DateTime startTime;

  /// The time of the last mouse event.
  final DateTime previousTime;

  /// Creates a mouse event argument.
  MouseEventArgs(Object sender, this.button, Region2 size, this.startRawPoint, this.previousRawPoint, Point2 rawPoint,
      this.startTime, this.previousTime, DateTime currentTime)
      : super(sender, size, rawPoint, currentTime);

  /// The start point adjusted into the region.
  Point2 get adjustedStartPoint => this.size.adjustPoint(this.startRawPoint);

  /// The previous point adjusted into the region.
  Point2 get adjustedPreviousPoint => this.size.adjustPoint(this.previousRawPoint);

  /// The change, in pixels, between the previous point and this point.
  Vector2 get rawDelta => this.previousRawPoint.vectorTo(this.rawPoint);

  /// The change, in pixels, between the start point and this point.
  Vector2 get rawOffset => this.startRawPoint.vectorTo(this.rawPoint);

  /// The change from the previous point and this point adjusted into the region.
  Vector2 get adjustedDelta => this.size.adjustVector(this.rawDelta);

  /// The change from the start point and this point adjusted into the region.
  Vector2 get adjustedOffset => this.size.adjustVector(this.rawOffset);

  /// The change in time, in seconds, from the previous time to this time.
  double get dt => this.currentTime.difference(this.previousTime).inMilliseconds * 0.001;

  /// The change in time, in seconds, from the start time to this time.
  double get dtTotal => this.currentTime.difference(this.startTime).inMilliseconds * 0.001;
}

/// The modifiers on the keyboard.
class Modifiers {
  /// Indicates the control or meta key pressed.
  final bool ctrl;

  /// Indicates the alt key pressed.
  final bool alt;

  /// Indicates the shift key pressed.
  final bool shift;

  /// Creates a new modifier's group.
  const Modifiers(
    final this.ctrl,
    final this.alt,
    final this.shift,
  );

  /// Creates a new modifier with nothing set yet.
  factory Modifiers.none() => const Modifiers(false, false, false);

  /// Creates a new control or meta key pressed modifier.
  factory Modifiers.ctrlKey() => const Modifiers(true, false, false);

  /// Creates a new alt key pressed modifier.
  factory Modifiers.altKey() => const Modifiers(false, true, false);

  /// Creates a new shirt key pressed modifier.
  factory Modifiers.shiftKey() => const Modifiers(false, false, true);

  /// Checks the equality of these modifiers to the given object.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Modifiers) return false;
    if (this.ctrl != other.ctrl) return false;
    if (this.alt != other.alt) return false;
    if (this.shift != other.shift) return false;
    return true;
  }

  @override
  int get hashCode => alt.hashCode ^ ctrl.hashCode ^ shift.hashCode;

  /// Gets the string for the the modifiers.
  /// Will be an empty string if no modifiers are true.
  @override
  String toString() {
    final parts = <String>[];
    if (this.ctrl) parts.add('Ctrl');
    if (this.alt) parts.add('Alt');
    if (this.shift) parts.add('Shift');
    return parts.join('+');
  }
}

/// The user input object for changing HTML Element events
/// into 3Dart events for user input.
class LockedMouseInput {
  /// The reference to the owner object.
  final UserInput _input;

  /// The event to emit when the mouse button is pressed.
  Event? _down;

  /// The event to emit when the mouse button is released.
  Event? _up;

  /// The event to emit when the mouse is moved.
  Event? _move;

  /// The event to emit when the mouse wheel is moved.
  Event? _wheel;

  /// The event to emit when the mouse is locked or unlocked.
  Event? _lockChanged;

  /// Indicates if the mouse buttons which are pressed or not.
  int _buttons;

  /// The point, in pixels, of the last mouse event.
  Point2 _prevPnt;

  /// The time in which the mouse button was last pressed or released.
  DateTime _startTime;

  /// The time of the last mouse event.
  DateTime _prevTime;

  /// The horizontal mouse movement sensitivity.
  double _hSensitivity;

  /// The vertical mouse movement sensitivity.
  double _vSensitivity;

  /// The horizontal mouse wheel movement sensitivity.
  double _whSensitivity;

  /// The vertical mouse wheel movement sensitivity.
  double _wvSensitivity;

  LockedMouseInput._(this._input)
      : this._down = null,
        this._up = null,
        this._move = null,
        this._wheel = null,
        this._lockChanged = null,
        this._buttons = 0,
        this._prevPnt = Point2.zero,
        this._startTime = DateTime.now(),
        this._prevTime = DateTime.now(),
        this._hSensitivity = 1.0,
        this._vSensitivity = 1.0,
        this._whSensitivity = 1.0,
        this._wvSensitivity = 1.0;

  /// Indicates the mouse buttons which are currently pressed.
  int get buttons => this._buttons;

  /// Gets the locked mouse arguments.
  MouseEventArgs _getMouseArgs(Button button, Vector2 vec) {
    final curTime = DateTime.now();
    final pnt = this._prevPnt + Point2(vec.dx * this._hSensitivity, vec.dy * this._vSensitivity);
    final args = MouseEventArgs(this, button, this._input.clientRect, Point2.zero, this._prevPnt, pnt, this._startTime,
        this._prevTime, curTime);
    this._prevTime = curTime;
    this._prevPnt = pnt;
    return args;
  }

  // Performs a locked mouse press down event.
  // This also sets the button code currently pressed.
  // Returns true if any events were called, false if none were called.
  bool performDown(Button button, Vector2 vec) {
    this._buttons = button.code;
    if (this._down == null) return false;
    this._down?.emit(this._getMouseArgs(button, vec));
    return true;
  }

  // Performs a locked mouse press up event.
  // This also unsets the button code currently pressed.
  // Returns true if any events were called, false if none were called.
  bool performUp(Button button, Vector2 vec) {
    this._buttons &= ~button.code;
    if (this._up == null) return false;
    this._up?.emit(this._getMouseArgs(button, vec));
    return true;
  }

  // Performs a locked mouse movement event.
  // Returns true if any events were called, false if none were called.
  bool performMove(Button button, Vector2 vec) {
    if (this._move == null) return false;
    this._move?.emit(this._getMouseArgs(button, vec));
    return true;
  }

  // Performs a locked mouse wheel event.
  // Returns true if any events were called, false if none were called.
  bool performWheel(Vector2 wheel) {
    if (this._wheel == null) return false;
    this._wheel?.emit(MouseWheelEventArgs(this, this._input.clientRect, this._prevPnt, DateTime.now(),
        Vector2(wheel.dx * this._whSensitivity, wheel.dy * this._wvSensitivity)));
    return true;
  }

  /// Handles the mouse lock and unlock on the canvas.
  void _onLockChanged(Button button, Point2 pnt, bool locked) {
    if (this._lockChanged == null) return;
    final curTime = DateTime.now();
    this._lockChanged?.emit(LockedEventArgs(this, locked, button, this._input.clientRect, pnt, curTime));
    this._startTime = curTime;
    this._prevPnt = Point2.zero;
  }

  /// The horizontal mouse movement sensitivity.
  double get horizontalSensitivity => this._hSensitivity;

  set horizontalSensitivity(double sensitivity) => this._hSensitivity = sensitivity;

  /// The vertical mouse movement sensitivity.
  double get verticalSensitivity => this._vSensitivity;

  set verticalSensitivity(double sensitivity) => this._vSensitivity = sensitivity;

  /// The horizontal mouse wheel movement sensitivity.
  double get wheelHorizontalSensitivity => this._whSensitivity;

  set wheelHorizontalSensitivity(double sensitivity) => this._whSensitivity = sensitivity;

  /// The vertical mouse wheel movement sensitivity.
  double get wheelVerticalSensitivity => this._wvSensitivity;

  set wheelVerticalSensitivity(double sensitivity) => this._wvSensitivity = sensitivity;

  /// The mouse down event.
  Event get down => this._down ??= Event();

  /// The mouse up event.
  Event get up => this._up ??= Event();

  /// The mouse move event.
  Event get move => this._move ??= Event();

  /// The mouse wheel move event.
  Event get wheel => this._wheel ??= Event();

  /// The mouse has been locked or unlocked.
  Event get lockChanged => this._lockChanged ??= Event();
}

/// A locked mouse movement event argument.
class LockedEventArgs extends PointEventArgs {
  /// True if the mouse is now locked, false otherwise.
  final bool locked;

  /// The mouse buttons which are pressed, false otherwise.
  final Button button;

  /// Creates a mouse point lock/unlock event argument.
  LockedEventArgs(Object sender, this.locked, this.button, Region2 size, Point2 rawPoint, DateTime currentTime)
      : super(sender, size, rawPoint, currentTime);
}

/// The keyboard input object for changing HTML Element events
/// into 3Dart events for user input.
class KeyInput {
  /// The event to emit when a key is released.
  Event? _up;

  /// The event to emit when a key is pressed.
  Event? _down;

  /// Indicates the modifiers which have been pressed.
  Modifiers _mods;

  /// The set of key codes which are currently pressed.
  final Set<int> _pressed;

  /// Creates a new user input.
  KeyInput._()
      : this._up = null,
        this._down = null,
        this._mods = Modifiers.none(),
        this._pressed = <int>{};

  /// Programmatically performs the key up event.
  bool performUp(Key key) {
    this._mods = key.modifiers;
    this._pressed.add(key.code);
    return this._up?.emit(KeyEventArgs(this, key)) ?? false;
  }

  /// Programmatically performs the key down event.
  bool performDown(Key key) {
    this._mods = key.modifiers;
    this._pressed.remove(key.code);
    return this._down?.emit(KeyEventArgs(this, key)) ?? false;
  }

  /// The keyboard key released event.
  Event get up => this._up ??= Event();

  /// The keyboard key pressed event.
  Event get down => this._down ??= Event();

  /// The set of key codes which are currently pressed.
  Set<int> get pressed => this._pressed;

  /// Indicates if the modifier keys currently pressed.
  Modifiers get modifiers => this._mods;

  /// Indicates if the control or meta key is currently pressed.
  bool get ctrl => this._mods.ctrl;

  /// Indicates if the alt key is currently pressed.
  bool get alt => this._mods.alt;

  /// Indicates if the shift key is currently pressed.
  bool get shift => this._mods.shift;
}

/// A group of keyboard keys for user interactions.
class KeyGroup extends Collection<Key> implements Interactable, Changeable {
  Event? _changed;
  UserInput? _input;
  bool _pressed;
  Event? _keyUp;
  Event? _keyDown;

  /// Creates a new user key group.
  KeyGroup()
      : this._changed = null,
        this._input = null,
        this._pressed = false,
        this._keyUp = null,
        this._keyDown = null {
    this.setHandlers(
      onPreaddHndl: this._onPreadd,
      onAddedHndl: this._onAdded,
      onRemovedHndl: this._onRemoved,
    );
  }

  /// Emits when the group has changed.
  @override
  Event get changed => this._changed ??= Event();

  /// Emits when one of the contained keys is pressed.
  Event get keyUp => this._keyUp ??= Event();

  /// Emits when one of the contained keys is released.
  Event get keyDown => this._keyDown ??= Event();

  /// Adds a key to this collection.
  void addKey(int key, {bool ctrl = false, bool alt = false, bool shift = false}) =>
      this.add(Key(key, ctrl: ctrl, alt: alt, shift: shift));

  /// Handles emitting a change.
  void _onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Indicated if a contained key is pressed.
  bool get pressed => this._pressed;

  /// Forces the key release signal.
  /// Returns true if released, false if not pressed.
  bool release() {
    if (!this._pressed) return false;
    this._pressed = false;
    this._keyUp?.emit();
    return true;
  }

  /// Handles a key being added to make sure there are no repeats.
  bool _onPreadd(Iterable<Key> keys) {
    for (final key in keys) {
      if (this.contains(key)) return false;
    }
    return true;
  }

  /// Handles a new key being added.
  void _onAdded(int index, Iterable<Key> items) => this._onChanged(ItemsAddedEventArgs<Key>(this, index, items));

  /// Handles a key bring removed.
  void _onRemoved(int index, Iterable<Key> items) => this._onChanged(ItemsRemovedEventArgs<Key>(this, index, items));

  /// Handles a key bring pressed.
  void _onKeyDown(EventArgs args) {
    if (!this._pressed && (args is KeyEventArgs)) {
      if (this.contains(args.key)) {
        this._pressed = true;
        this._keyDown?.emit(args);
      }
    }
  }

  /// Handles a key bring released.
  void _onKeyUp(EventArgs args) {
    if (this._pressed && (args is KeyEventArgs)) {
      if (this.contains(args.key)) {
        this._pressed = false;
        this._keyUp?.emit(args);
      }
    }
  }

  /// Attaches this object onto the given [UserInput].
  /// Returns true if this object is attached, false otherwise.
  @override
  bool attach(UserInput? input) {
    if (input == null) return false;
    if (this._input != null) return false;
    this._input = input;
    input.key..down.add(this._onKeyDown)..up.add(this._onKeyUp);
    return true;
  }

  /// Detaches this object from it's attached [UserInput].
  @override
  void detach() {
    final input = this._input;
    if (input != null) {
      input.key..down.remove(this._onKeyDown)..up.remove(this._onKeyUp);
      this._input = null;
    }
  }
}

/// The key event arguments for events from the keyboard.
class KeyEventArgs extends EventArgs {
  /// The key which was pressed or released.
  final Key key;

  /// Creates a new key event argument.
  KeyEventArgs(Object sender, this.key) : super(sender);
}

/// A keyboard key press or release value with modifiers.
class Key {
  static const int none = 0;
  static const int backspace = 8;
  static const int tab = 9;
  static const int enter = 13;
  static const int spacebar = 32;
  static const int leftArrow = 37;
  static const int upArrow = 38;
  static const int rightArrow = 39;
  static const int downArrow = 40;
  static const int backSlash = 120;
  static const int semicolon = 186;
  static const int equal = 187;
  static const int comma = 188;
  static const int minus = 189;
  static const int period = 190;
  static const int slash = 191;
  static const int backQuote = 192;
  static const int bracketLeft = 219;
  static const int bracketRight = 221;
  static const int quote = 222;

  static const int keyF1 = 112;
  static const int keyF2 = 113;
  static const int keyF3 = 114;
  static const int keyF4 = 115;
  static const int keyF5 = 116;
  static const int keyF6 = 117;
  static const int keyF7 = 118;
  static const int keyF8 = 119;
  static const int keyF9 = 120;
  static const int keyF10 = 121;
  static const int keyF11 = 122;
  static const int keyF12 = 123;

  static const int keyA = 65;
  static const int keyB = 66;
  static const int keyC = 67;
  static const int keyD = 68;
  static const int keyE = 69;
  static const int keyF = 70;
  static const int keyG = 71;
  static const int keyH = 72;
  static const int keyI = 73;
  static const int keyJ = 74;
  static const int keyK = 75;
  static const int keyL = 76;
  static const int keyM = 77;
  static const int keyN = 78;
  static const int keyO = 79;
  static const int keyP = 80;
  static const int keyQ = 81;
  static const int keyR = 82;
  static const int keyS = 83;
  static const int keyT = 84;
  static const int keyU = 85;
  static const int keyV = 86;
  static const int keyW = 87;
  static const int keyX = 88;
  static const int keyY = 89;
  static const int keyZ = 90;

  static const int key0 = 48;
  static const int key1 = 49;
  static const int key2 = 50;
  static const int key3 = 51;
  static const int key4 = 52;
  static const int key5 = 53;
  static const int key6 = 54;
  static const int key7 = 55;
  static const int key8 = 56;
  static const int key9 = 57;

  /// The key code for the pressed or released value.
  final int code;

  /// The key modifiers.
  final Modifiers modifiers;

  /// The control key modifier.
  bool get ctrl => this.modifiers.ctrl;

  /// The alternate key modifier.
  bool get alt => this.modifiers.alt;

  /// The shift key modifier.
  bool get shift => this.modifiers.shift;

  /// Creates a new key.
  factory Key(int code, {bool ctrl = false, bool alt = false, bool shift = false}) =>
      Key.fromMod(code, Modifiers(ctrl, alt, shift));

  /// Creates a new key with the given modifiers.
  Key.fromMod(this.code, this.modifiers);

  /// Checks the equality of this key to the given object.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Key) return false;
    final key = other;
    if (this.code != key.code) return false;
    if (this.modifiers != key.modifiers) return false;
    return true;
  }

  @override
  int get hashCode => code.hashCode ^ modifiers.hashCode;

  /// The string for this key.
  @override
  String toString() => "${this.modifiers}${this.code}";
}

/// The interface for an object which can attach to the 3Dart user input.
abstract class Interactable {
  /// Attaches this object onto the given [UserInput].
  /// Returns true if this object is attached, false otherwise.
  bool attach(UserInput? input);

  /// Detaches this object from it's attached [UserInput].
  void detach();
}

/// A mouse button press or release value with modifiers.
class Button {
  static const int none = 0;
  static const int left = 1;
  static const int right = 2;
  static const int middle = 4;
  static const int fourth = 8;
  static const int fifth = 16;

  /// The mouse button code for the pressed or released value.
  final int code;

  /// Determines if the given code exists in this button code.
  bool has(int code) => this.code & code == code;

  /// The key modifiers.
  final Modifiers modifiers;

  /// The control key modifier.
  bool get ctrl => this.modifiers.ctrl;

  /// The alternate key modifier.
  bool get alt => this.modifiers.alt;

  /// The shift key modifier.
  bool get shift => this.modifiers.shift;

  /// Creates a new mouse button.
  factory Button(int code, {bool ctrl = false, bool alt = false, bool shift = false}) =>
      Button.fromMod(code, Modifiers(ctrl, alt, shift));

  /// Creates a new mouse button with the given modifiers.
  Button.fromMod(this.code, this.modifiers);

  /// Checks the equality of this mouse button to the given object.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Button) return false;
    final key = other;
    if (this.code != key.code) return false;
    if (this.modifiers != key.modifiers) return false;
    return true;
  }

  @override
  int get hashCode => code.hashCode ^ modifiers.hashCode;

  /// The string for this mouse button.
  @override
  String toString() => "${this.modifiers}${this.code}";
}
