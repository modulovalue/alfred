import 'dart:io';

import '../interface/store.dart';

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
  RequestStore update(HttpRequest request, RequestStore Function() storeFactory) => data[request] ??= storeFactory();
}

// TODO use typed registry pattern?

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
