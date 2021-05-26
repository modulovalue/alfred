import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'mixin.dart';

class TypeHandlerSerializableImpl with TypeHandlerShouldHandleMixin<dynamic> {
  const TypeHandlerSerializableImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    dynamic value,
  ) {
    try {
      // ignore: avoid_dynamic_calls
      final dynamic toJsonCall = value.toJson;
      if (toJsonCall != null) {
        // ignore: avoid_dynamic_calls
        res.write(jsonEncode(toJsonCall()));
        return res.close();
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (!e.toString().contains('has no instance getter')) {
        rethrow;
      }
    }
    try {
      // ignore: avoid_dynamic_calls
      final dynamic toJSONCall = value.toJSON;
      if (toJSONCall != null) {
        // ignore: avoid_dynamic_calls
        res.write(jsonEncode(toJSONCall()));
        return res.close();
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (!e.toString().contains('has no instance getter')) {
        rethrow;
      }
    }
    return false;
  }
}
