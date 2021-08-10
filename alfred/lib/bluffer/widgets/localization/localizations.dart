import 'dart:async';
import 'dart:cli';

import '../../base/keys.dart';
import '../../base/locale.dart';
import '../stateless/stateless.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class Localizations extends StatelessWidget {
  /// Create a widget from which localizations (like translated strings) can be obtained.
  const Localizations({
    required this.locale,
    required final this.delegates,
    required final this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  /// The resources returned by [Localizations.of] will be specific to this locale.
  final Locale locale;

  /// This list collectively defines the localized resources objects that can
  /// be retrieved with [Localizations.of].
  final List<LocalizationsDelegate<dynamic>> delegates;

  /// The locale of the Localizations widget for the widget tree that
  /// corresponds to [BuildContext] `context`.
  ///
  /// If no [Localizations] widget is in scope then the [Localizations.localeOf]
  /// method will throw an exception, unless the `nullOk` argument is set to
  /// true, in which case it returns null.
  static Locale? localeOf(
    final BuildContext context, {
    final bool nullOk = false,
  }) {
    final scope = context.dependOnInheritedWidgetOfExactType<_LocalizationsScope>();
    if (nullOk && scope == null) {
      return null;
    }
    assert(scope != null, 'a Localizations ancestor was not found');
    return scope!.locale;
  }

  /// Returns the localized resources object of the given `type` for the widget
  /// tree that corresponds to the given `context`.
  ///
  /// Returns null if no resources object of the given `type` exists within
  /// the given `context`.
  ///
  /// This method is typically used by a static factory method on the `type`
  /// class. For example Flutter's MaterialLocalizations class looks up Material
  /// resources with a method defined like this:
  ///
  /// ```dart
  /// static MaterialLocalizations of(BuildContext context) {
  ///    return Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
  /// }
  /// ```
  static T of<T>(
    final BuildContext context,
    final Type type,
  ) {
    final scope = context.dependOnInheritedWidgetOfExactType<_LocalizationsScope>();
    final dynamic value = scope?.typeToResources[T];
    if (value is T) {
      return value;
    } else {
      throw Exception("Expected value to be of type " + T.toString());
    }
  }

  @override
  Widget build(
    final BuildContext context,
  ) {
    final typeToResources = <Type, dynamic>{};
    for (final delegate in delegates) {
      final loaded = delegate.load(locale);
      final value = loaded.then(
        (final dynamic a) {
          if (a is Type) {
            return a;
          } else {
            throw Exception("Expected " + a.toString() + " to be of type Type.");
          }
        },
      );
      typeToResources[delegate.type] = waitFor(value);
    }
    return _LocalizationsScope(
      child: child,
      typeToResources: typeToResources,
      locale: locale,
    );
  }
}

abstract class LocalizationsDelegate<RESOURCE> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const LocalizationsDelegate();

  /// Whether resources for the given locale can be loaded by this delegate.
  ///
  /// Return true if the instance of `T` loaded by this delegate's [load]
  /// method supports the given `locale`'s language.
  bool isSupported(
    final Locale locale,
  );

  /// Start loading the resources for `locale`. The returned future completes
  /// when the resources have finished loading.
  ///
  /// It's assumed that this method will return an object that contains
  /// a collection of related resources (typically defined with one method per
  /// resource). The object will be retrieved with [Localizations.of].
  Future<RESOURCE> load(
    final Locale locale,
  );

  /// The type of the object returned by the [load] method, T by default.
  ///
  /// This type is used to retrieve the object "loaded" by this
  /// [LocalizationsDelegate] from the [Localizations] inherited widget.
  /// For example the object loaded by `LocalizationsDelegate<Foo>` would
  /// be retrieved with:
  /// ```dart
  /// Foo foo = Localizations.of<Foo>(context, Foo);
  /// ```
  ///
  /// It's rarely necessary to override this getter.
  Type get type => RESOURCE;

  @override
  String toString() => '$runtimeType[$type]';
}

class _LocalizationsScope with InheritedWidgetMixin {
  /// The resources returned by [Localizations.of] will be specific to this locale.
  final Locale locale;
  final Map<Type, dynamic> typeToResources;
  @override
  final Widget child;
  @override
  final Key? key = null;

  const _LocalizationsScope({
    required final this.locale,
    required final this.typeToResources,
    required final this.child,
  });
}
