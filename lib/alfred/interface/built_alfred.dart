import 'dart:io';

abstract class BuiltAlfred {
  /// HttpServer instance from the dart:io library
  ///
  /// If there is anything the app can't do, you can do it through here.
  HttpServer get server;

  /// Close the server and clean up any resources.
  ///
  /// Call this if you are shutting down the server
  /// but continuing to run the app.
  Future<dynamic> close({bool force});

  int get port;

  String get boundIp;
}
