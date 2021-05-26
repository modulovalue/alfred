import 'dart:io';

import 'base.dart';

/// Data structure to keep all request-related data
abstract class StorePluginData {
  static late StorePluginData singleton = StorePluginDataImpl();

  /// Used within [Alfred] to remove request-related data after
  /// the request has been resolved.
  void storePluginOnDoneHandler(HttpRequest req, HttpResponse res);

  RequestStore? get(HttpRequest request);

  RequestStore update(HttpRequest request, RequestStore store);

  List<HttpRequest> allKeys();
}

class StorePluginDataImpl implements StorePluginData {
  final Map<HttpRequest, RequestStore> data;

  StorePluginDataImpl() : data = {}; // Not const because storePlugin data needs to be mutable.

  @override
  List<HttpRequest> allKeys() => data.keys.toList();

  @override
  void storePluginOnDoneHandler(
    HttpRequest req,
    HttpResponse res,
  ) =>
      data.remove(req);

  @override
  RequestStore? get(HttpRequest request) => data[request];

  @override
  RequestStore update(HttpRequest request, RequestStore store) => data[request] ??= store;
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

class RequestStoreImpl implements RequestStore {
  final Map<String, dynamic> _data;

  RequestStoreImpl() : _data = <String, dynamic>{};

  @override
  void set(String key, dynamic value) => _data[key] = value;

  @override
  T get<T>(String key) {
    assert(_data[key] is T, 'Store value for key $key does not match type $T');
    return _data[key] as T;
  }
}
