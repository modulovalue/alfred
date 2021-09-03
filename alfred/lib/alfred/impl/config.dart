import '../interface/alfred.dart';

class ServerConfigImpl implements ServerConfig {
  @override
  final String bindIp;
  @override
  final bool shared;
  @override
  final int port;
  @override
  final int simultaneousProcessing;
  @override
  final Duration idleTimeout;

  const ServerConfigImpl({
    required final this.bindIp,
    required final this.shared,
    required final this.port,
    required final this.simultaneousProcessing,
    required final this.idleTimeout,
  });
}

class ServerConfigDefault implements ServerConfig {
  static const String defaultBindIp = '0.0.0.0';
  static const int defaultPort = 80;
  static const int defaultSimultaneousProcessing = 50;
  static const bool defaultShared = true;
  static const Duration defaultIdleTimeout = Duration(seconds: 1);

  const ServerConfigDefault();

  @override
  String get bindIp => defaultBindIp;

  @override
  int get port => defaultPort;

  @override
  bool get shared => defaultShared;

  @override
  int get simultaneousProcessing => defaultSimultaneousProcessing;

  @override
  Duration get idleTimeout => defaultIdleTimeout;
}

class ServerConfigDefaultWithPort implements ServerConfig {
  @override
  final int port;

  const ServerConfigDefaultWithPort({
    required final this.port,
  });

  @override
  String get bindIp => ServerConfigDefault.defaultBindIp;

  @override
  bool get shared => ServerConfigDefault.defaultShared;

  @override
  int get simultaneousProcessing => ServerConfigDefault.defaultSimultaneousProcessing;

  @override
  Duration get idleTimeout => ServerConfigDefault.defaultIdleTimeout;
}
