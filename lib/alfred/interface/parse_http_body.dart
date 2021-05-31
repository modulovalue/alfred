import 'dart:async';
import 'dart:io';

/// A handler for processing and collecting HTTP message data in to an
/// [HttpBody].
///
/// The content body is parsed, depending on the `Content-Type` header field.
/// When the full body is read and parsed the body content is made available.
/// The class can be used to process both server requests and client responses.
///
/// The following content types are recognized:
///
/// - text/*
/// - application/json
/// - application/x-www-form-urlencoded
/// - multipart/form-data
///
/// For content type `text/*` the body is decoded into a string. The
/// 'charset' parameter of the content type specifies the encoding
/// used for decoding. If no 'charset' is present the default encoding
/// of ISO-8859-1 is used.
///
/// For content type `application/json` the body is decoded into a
/// string which is then parsed as JSON. The resulting body is a
/// [Map].  The 'charset' parameter of the content type specifies the
/// encoding used for decoding. If no 'charset' is present the default
/// encoding of UTF-8 is used.
///
/// For content type `application/x-www-form-urlencoded` the body is a
/// query string which is then split according to the rules for
/// splitting a query string. The resulting body is a `Map<String,
/// String>`.  If the same name is present several times in the query
/// string, then the last value seen for this name will be in the
/// resulting map. The encoding US-ASCII is always used for decoding
/// the body.
///
/// For content type `multipart/form-data` the body is parsed into
/// it's different fields. The resulting body is a `Map<String,
/// dynamic>`, where the value is a [String] for normal fields and a
/// [HttpBodyFileUpload] instance for file upload fields. If the same
/// name is present several times, then the last value seen for this
/// name will be in the resulting map.
///
/// When using content type `multipart/form-data` the encoding of
/// fields with [String] values is determined by the browser sending
/// the HTTP request with the form data. The encoding is specified
/// either by the attribute `accept-charset` on the HTML form, or by
/// the content type of the web page containing the form. If the HTML
/// form has an `accept-charset` attribute the browser will use the
/// encoding specified there. If the HTML form has no `accept-charset`
/// attribute the browser determines the encoding from the content
/// type of the web page containing the form. Using a content type of
/// `text/html; charset=utf-8` for the page and setting
/// `accept-charset` on the HTML form to `utf-8` is recommended as the
/// default for [HttpBodyHandler] is UTF-8. It is important to get
/// these encoding values right, as the actual `multipart/form-data`
/// HTTP request sent by the browser does _not_ contain any
/// information on the encoding. If something else than UTF-8 is used
/// `defaultEncoding` needs to be set in the [HttpBodyHandler]
/// constructor and calls to processRequest and processResponse.
///
/// For all other content types the body will be treated as
/// uninterpreted binary data. The resulting body will be of type
/// `List<int>`.
///
/// To use with the [HttpServer] for request messages, [HttpBodyHandler] can be
/// used as either a [StreamTransformer] or as a per-request handler (see
/// processRequest).
///
/// ```dart
/// HttpServer server = ...
/// server.transform(HttpBodyHandler())
///     .listen((HttpRequestBody body) {
///       ...
///     });
/// ```
///
/// To use with the [HttpClient] for response messages, [HttpBodyHandler] can be
/// used as a per-request handler (see processResponse).
///
/// ```dart
/// HttpClient client = ...
/// var request = await client.get(...);
/// var response = await request.close();
/// var body = HttpBodyHandler.processResponse(response);
/// ```
abstract class HttpBodyHandler implements StreamTransformerBase<HttpRequest, HttpRequestBody<dynamic>> {}

/// A HTTP content body produced by [HttpBodyHandler] for either [HttpRequest]
/// or [HttpClientResponse].
abstract class HttpBody<T> {
  /// A high-level type value, that reflects how the body was parsed, e.g.
  /// "text", "binary" and "json".
  String get type;

  /// The content of the body with a type depending on [type].
  T get body;
}

/// The body of a [HttpClientResponse].
///
/// Headers can be read through the original [response].
abstract class HttpClientResponseBody<T> implements HttpBody<T> {
  /// The wrapped response.
  HttpClientResponse get response;
}

/// The body of a [HttpRequest].
///
/// Headers can be read, and a response can be sent, through [request].
abstract class HttpRequestBody<T> implements HttpBody<T> {
  /// The wrapped request.
  ///
  /// Note that the [HttpRequest] is already drained, so the
  /// `Stream` methods cannot be used.
  HttpRequest get request;
}

/// A wrapper around a file upload.
abstract class HttpBodyFileUpload<T> {
  /// The filename of the uploaded file.
  String get filename;

  /// The [ContentType] of the uploaded file.
  ///
  /// For `text/*` and `application/json` the [content] field will a String.
  ContentType? get contentType;

  /// The content of the file.
  ///
  /// Either a [String] or a [List<int>].
  T get content;
}
