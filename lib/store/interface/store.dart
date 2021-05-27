import 'dart:io';

/// Data structure to keep all request-related data
abstract class StorePluginData {
  /// Used within [Alfred] to remove request-related data after
  /// the request has been resolved.
  void storePluginOnDoneHandler(HttpRequest req, HttpResponse res);

  RequestStore? get(HttpRequest request);

  RequestStore update(HttpRequest request, RequestStore Function() storeFactory);

  List<HttpRequest> allKeys();
}

/// Key-Value-Store for reading and writing request-related data
abstract class RequestStore {
  /// Stores a [value] associated with a specified [key].
  ///
  /// Example:
  /// ```dart
  /// req.store.set('foo', Foo());
  /// ```
  void set(String key, dynamic value);

  /// Returns the stored value that has been associated with the specified [key].
  /// Returns `null` if no value has been written.
  ///
  /// Example:
  /// ```dart
  /// var foo = req.store.get<Foo>('foo');
  /// ```
  T get<T>(String key);
}
