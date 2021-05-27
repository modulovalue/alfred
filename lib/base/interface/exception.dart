/// A base exception for this package.
abstract class AlfredException implements Exception {
  /// The response to send to the client
  Object? get response;

  /// The statusCode to send to the client
  int get statusCode;
}
