// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart' as m;

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
/// constructor and calls to [processRequest] and [processResponse].
///
/// For all other content types the body will be treated as
/// uninterpreted binary data. The resulting body will be of type
/// `List<int>`.
///
/// To use with the [HttpServer] for request messages, [HttpBodyHandler] can be
/// used as either a [StreamTransformer] or as a per-request handler (see
/// [processRequest]).
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
/// used as a per-request handler (see [processResponse]).
///
/// ```dart
/// HttpClient client = ...
/// var request = await client.get(...);
/// var response = await request.close();
/// var body = HttpBodyHandler.processResponse(response);
/// ```
class HttpBodyHandler extends StreamTransformerBase<HttpRequest, HttpRequestBody<dynamic>> {
  final Encoding _defaultEncoding;

  /// Create a new [HttpBodyHandler] to be used with a [Stream]<[HttpRequest]>,
  /// e.g. a [HttpServer].
  ///
  /// If the page is served using different encoding than UTF-8, set
  /// [defaultEncoding] accordingly. This is required for parsing
  /// `multipart/form-data` content correctly. See the class comment
  /// for more information on `multipart/form-data`.
  const HttpBodyHandler({
    Encoding defaultEncoding = utf8,
  }) : _defaultEncoding = defaultEncoding;

  /// Process and parse an incoming [HttpRequest].
  ///
  /// The returned [HttpRequestBody] contains a `response` field for accessing
  /// the [HttpResponse].
  ///
  /// See [new HttpBodyHandler] for more info on [defaultEncoding].
  static Future<HttpRequestBody<dynamic>> processRequest(HttpRequest request, {Encoding defaultEncoding = utf8}) async {
    try {
      final body = await _process(request, request.headers, defaultEncoding);
      return HttpRequestBodyImpl<dynamic>._(request, body);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // Try to send BAD_REQUEST response.
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      rethrow;
    }
  }

  /// Process and parse an incoming [HttpClientResponse].
  ///
  /// See [new HttpBodyHandler] for more info on [defaultEncoding].
  static Future<HttpClientResponseBody<dynamic>> processResponse(HttpClientResponse response, {Encoding defaultEncoding = utf8}) async {
    final body = await _process(response, response.headers, defaultEncoding);
    return HttpClientResponseBodyImpl<dynamic>._(response, body);
  }

  @override
  Stream<HttpRequestBody<dynamic>> bind(Stream<HttpRequest> stream) {
    var pending = 0;
    var closed = false;
    return stream.transform(StreamTransformer.fromHandlers(handleData: (request, sink) async {
      pending++;
      try {
        final body = await processRequest(request, defaultEncoding: _defaultEncoding);
        sink.add(body);
        // ignore: avoid_catches_without_on_clauses
      } catch (e, st) {
        sink.addError(e, st);
      } finally {
        pending--;
        if (closed && pending == 0) sink.close();
      }
    }, handleDone: (sink) {
      closed = true;
      if (pending == 0) sink.close();
    }));
  }
}

/// A HTTP content body produced by [HttpBodyHandler] for either [HttpRequest]
/// or [HttpClientResponse].
abstract class HttpBody<T> {
  /// A high-level type value, that reflects how the body was parsed, e.g.
  /// "text", "binary" and "json".
  String get type;

  /// The content of the body with a type depending on [type].
  T get body;
}

class HttpBodyImpl<T> implements HttpBody<T> {
  @override
  final String type;

  @override
  final T body;

  const HttpBodyImpl._(this.type, this.body);
}

/// The body of a [HttpClientResponse].
///
/// Headers can be read through the original [response].
abstract class HttpClientResponseBody<T> implements HttpBody<T> {
  /// The wrapped response.
  HttpClientResponse get response;
}

/// The body of a [HttpClientResponse].
///
/// Headers can be read through the original [response].
class HttpClientResponseBodyImpl<T> implements HttpClientResponseBody<T> {
  @override
  final HttpClientResponse response;

  final HttpBody<T> _body;

  const HttpClientResponseBodyImpl._(this.response, this._body);

  @override
  T get body => _body.body;

  @override
  String get type => _body.type;
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

/// The body of a [HttpRequest].
///
/// Headers can be read, and a response can be sent, through [request].
class HttpRequestBodyImpl<T> implements HttpRequestBody<T> {
  @override
  final HttpRequest request;
  final HttpBody<T> _body;

  const HttpRequestBodyImpl._(this.request, this._body);

  @override
  T get body => _body.body;

  @override
  String get type => _body.type;
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

class HttpBodyFileUploadImpl<T> implements HttpBodyFileUpload<T> {
  @override
  final String filename;
  @override
  final ContentType? contentType;
  @override
  final T content;

  const HttpBodyFileUploadImpl._(this.contentType, this.filename, this.content);
}

Future<HttpBody<dynamic>> _process(
  Stream<List<int>> stream,
  HttpHeaders headers,
  Encoding defaultEncoding,
) async {
  Future<HttpBody<Uint8List>> asBinary() async {
    final builder = await stream.fold<BytesBuilder>(BytesBuilder(), (builder, data) => builder..add(data));
    return HttpBodyImpl._('binary', builder.takeBytes());
  }

  if (headers.contentType == null) {
    return asBinary();
  } else {
    final contentType = headers.contentType!;
    Future<HttpBody<String>> asText(Encoding defaultEncoding) async {
      Encoding? encoding;
      final charset = contentType.charset;
      if (charset != null) {
        encoding = Encoding.getByName(charset);
      }
      encoding ??= defaultEncoding;
      final dynamic buffer = await encoding.decoder.bind(stream).fold<dynamic>(
            // ignore: avoid_dynamic_calls
            StringBuffer(), (dynamic buffer, data) => buffer..write(data),
          );
      return HttpBodyImpl._('text', buffer.toString());
    }

    Future<HttpBody<Map<String, dynamic>>> asFormData() async {
      final values = await m.MimeMultipartTransformer(contentType.parameters['boundary']!).bind(stream).map(
        (part) async {
          final multipart = HttpMultipartFormData.parse(part, defaultEncoding: defaultEncoding);
          dynamic data;
          if (multipart.isText) {
            final buffer = await multipart.fold<StringBuffer>(StringBuffer(), (b, dynamic s) => b..write(s));
            data = buffer.toString();
          } else {
            final buffer = await multipart.fold<BytesBuilder>(BytesBuilder(), (b, dynamic d) => b..add(d as List<int>));
            data = buffer.takeBytes();
          }
          final filename = multipart.contentDisposition.parameters['filename'];
          if (filename != null) {
            data = HttpBodyFileUploadImpl<dynamic>._(multipart.contentType, filename, data);
          }
          return <dynamic>[
            multipart.contentDisposition.parameters['name'],
            data,
          ];
        },
      ).toList();
      final parts = await Future.wait<List<dynamic>>(values);
      return HttpBodyImpl._(
        'form',
        <String, dynamic>{
          for (final part in parts) part[0] as String: part[1], // Override existing entries.
        },
      );
    }

    switch (contentType.primaryType) {
      case 'text':
        return asText(defaultEncoding);
      case 'application':
        switch (contentType.subType) {
          case 'json':
            final body = await asText(utf8);
            return HttpBodyImpl<dynamic>._('json', jsonDecode(body.body));
          case 'x-www-form-urlencoded':
            final body = await asText(ascii);
            final map = Uri.splitQueryString(body.body, encoding: defaultEncoding);
            final result = <dynamic, dynamic>{};
            for (final key in map.keys) {
              result[key] = map[key];
            }
            return HttpBodyImpl<dynamic>._('form', result);
          default:
            break;
        }
        break;
      case 'multipart':
        switch (contentType.subType) {
          case 'form-data':
            return asFormData();
          default:
            break;
        }
        break;
      default:
        break;
    }
    return asBinary();
  }
}

/// The data in a `multipart/form-data` part.
///
/// ## Example
///
/// ```dart
/// HttpServer server = ...;
/// server.listen((request) {
///   var boundary = request.headers.contentType.parameters['boundary'];
///   request
///       .transform(MimeMultipartTransformer(boundary))
///       .map(HttpMultipartFormData.parse)
///       .map((HttpMultipartFormData formData) {
///         // form data object available here.
///       });
/// ```
///
/// [HttpMultipartFormData] is a Stream, serving either bytes or decoded
/// Strings. Use [isText] or [isBinary] to see what type of data is provided.
class HttpMultipartFormData extends Stream<dynamic> {
  /// The parsed `Content-Type` header value.
  ///
  /// `null` if not present.
  final ContentType? contentType;

  /// The parsed `Content-Disposition` header value.
  ///
  /// This field is always present. Use this to extract e.g. name (form field
  /// name) and filename (client provided name of uploaded file) parameters.
  final HeaderValue contentDisposition;

  /// The parsed `Content-Transfer-Encoding` header value.
  ///
  /// This field is used to determine how to decode the data. Returns `null`
  /// if not present.
  final HeaderValue? contentTransferEncoding;

  /// Whether the data is decoded as [String].
  final bool isText;

  /// Whether the data is raw bytes.
  bool get isBinary => !isText;

  /// The values which indicate that no incoding was performed.
  ///
  /// https://www.w3.org/Protocols/rfc1341/5_Content-Transfer-Encoding.html
  static const _transparentEncodings = ['7bit', '8bit', 'binary'];

  /// Parse a [MimeMultipart] and return a [HttpMultipartFormData].
  ///
  /// If the `Content-Disposition` header is missing or invalid, an
  /// [HttpException] is thrown.
  ///
  /// If the [MimeMultipart] is identified as text, and the `Content-Type`
  /// header is missing, the data is decoded using [defaultEncoding]. See more
  /// information in the
  /// [HTML5 spec](http://dev.w3.org/html5/spec-preview/
  /// constraints.html#multipart-form-data).
  static HttpMultipartFormData parse(m.MimeMultipart multipart, {Encoding defaultEncoding = utf8}) {
    ContentType? contentType;
    HeaderValue? encoding;
    HeaderValue? disposition;
    for (final key in multipart.headers.keys) {
      switch (key) {
        case 'content-type':
          contentType = ContentType.parse(multipart.headers[key]!);
          break;
        case 'content-transfer-encoding':
          encoding = HeaderValue.parse(multipart.headers[key]!);
          break;
        case 'content-disposition':
          disposition = HeaderValue.parse(multipart.headers[key]!, preserveBackslash: true);
          break;
        default:
          break;
      }
    }
    if (disposition == null) {
      throw const HttpException("Mime Multipart doesn't contain a Content-Disposition header value");
    }
    if (encoding != null && !_transparentEncodings.contains(encoding.value.toLowerCase())) {
      // TODO(ajohnsen): Support BASE64, etc.
      throw HttpException('Unsupported contentTransferEncoding: '
          '${encoding.value}');
    }

    Stream<dynamic> stream = multipart;
    final isText = contentType == null || contentType.primaryType == 'text' || contentType.mimeType == 'application/json';
    if (isText) {
      Encoding? encoding;
      if (contentType?.charset != null) {
        encoding = Encoding.getByName(contentType!.charset);
      }
      encoding ??= defaultEncoding;
      stream = stream.transform<dynamic>(encoding.decoder);
    }
    return HttpMultipartFormData._(contentType, disposition, encoding, multipart, stream, isText);
  }

  final m.MimeMultipart _mimeMultipart;

  final Stream<dynamic> _stream;

  HttpMultipartFormData._(
    this.contentType,
    this.contentDisposition,
    this.contentTransferEncoding,
    this._mimeMultipart,
    this._stream,
    this.isText,
  );

  @override
  StreamSubscription<dynamic> listen(
    void Function(dynamic)? onData, {
    void Function()? onDone,
    Function? onError,
    bool? cancelOnError,
  }) =>
      _stream.listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);

  /// Returns the value for the header named [name].
  ///
  /// If there is no header with the provided name, `null` will be returned.
  ///
  /// Use this method to index other headers available in the original
  /// [MimeMultipart].
  String? value(String name) => _mimeMultipart.headers[name];
}
