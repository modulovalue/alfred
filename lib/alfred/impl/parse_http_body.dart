import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart' as m;

import '../interface/parse_http_body.dart';

class HttpBodyHandlerImpl extends StreamTransformerBase<HttpRequest, HttpRequestBody<dynamic>> implements HttpBodyHandler {
  final Encoding defaultEncoding;

  /// Create a new [HttpBodyHandler] to be used with a [Stream]<[HttpRequest]>,
  /// e.g. a [HttpServer].
  ///
  /// If the page is served using different encoding than UTF-8, set
  /// [defaultEncoding] accordingly. This is required for parsing
  /// `multipart/form-data` content correctly. See the class comment
  /// for more information on `multipart/form-data`.
  const HttpBodyHandlerImpl(
    final this.defaultEncoding,
  );

  /// Process and parse an incoming [HttpRequest].
  ///
  /// The returned [HttpRequestBody] contains a `response` field for accessing the [HttpResponse].
  ///
  /// See [new HttpBodyHandler] for more info on [defaultEncoding].
  static Future<HttpRequestBody<dynamic>> processRequest(
    final HttpRequest request, {
    final Encoding defaultEncoding = utf8,
  }) async {
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
  static Future<HttpClientResponseBody<dynamic>> processResponse(
    final HttpClientResponse response, {
    final Encoding defaultEncoding = utf8,
  }) async {
    final body = await _process(response, response.headers, defaultEncoding);
    return HttpClientResponseBodyImpl<dynamic>._(response, body);
  }

  @override
  Stream<HttpRequestBody<dynamic>> bind(
    final Stream<HttpRequest> stream,
  ) {
    var pending = 0;
    var closed = false;
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (final request, final sink) async {
          pending++;
          try {
            final body = await processRequest(request, defaultEncoding: defaultEncoding);
            sink.add(body);
            // ignore: avoid_catches_without_on_clauses
          } catch (e, st) {
            sink.addError(e, st);
          } finally {
            pending--;
            if (closed && pending == 0) sink.close();
          }
        },
        handleDone: (final sink) {
          closed = true;
          if (pending == 0) {
            sink.close();
          }
        },
      ),
    );
  }
}

class HttpBodyImpl<T> implements HttpBody<T> {
  @override
  final String type;

  @override
  final T body;

  const HttpBodyImpl._(
    final this.type,
    final this.body,
  );
}

class HttpClientResponseBodyImpl<T> implements HttpClientResponseBody<T> {
  @override
  final HttpClientResponse response;

  final HttpBody<T> _body;

  const HttpClientResponseBodyImpl._(
    final this.response,
    final this._body,
  );

  @override
  T get body => _body.body;

  @override
  String get type => _body.type;
}

class HttpRequestBodyImpl<T> implements HttpRequestBody<T> {
  @override
  final HttpRequest request;
  final HttpBody<T> _body;

  const HttpRequestBodyImpl._(
    final this.request,
    final this._body,
  );

  @override
  T get body => _body.body;

  @override
  String get type => _body.type;
}

class HttpBodyFileUploadImpl<T> implements HttpBodyFileUpload<T> {
  @override
  final String filename;
  @override
  final ContentType? contentType;
  @override
  final T content;

  const HttpBodyFileUploadImpl._(
    final this.contentType,
    final this.filename,
    final this.content,
  );
}

Future<HttpBody<dynamic>> _process(
  final Stream<List<int>> stream,
  final HttpHeaders headers,
  final Encoding defaultEncoding,
) async {
  Future<HttpBody<Uint8List>> asBinary() async {
    final builder = await stream.fold<BytesBuilder>(BytesBuilder(), (builder, data) => builder..add(data));
    return HttpBodyImpl._('binary', builder.takeBytes());
  }

  if (headers.contentType == null) {
    return asBinary();
  } else {
    final contentType = headers.contentType!;
    Future<HttpBody<String>> asText(
      final Encoding defaultEncoding,
    ) async {
      Encoding? encoding;
      final charset = contentType.charset;
      if (charset != null) {
        encoding = Encoding.getByName(charset);
      }
      encoding ??= defaultEncoding;
      final dynamic buffer = await encoding.decoder.bind(stream).fold<dynamic>(
            // ignore: avoid_dynamic_calls
            StringBuffer(), (final dynamic buffer, final data) => buffer..write(data),
          );
      return HttpBodyImpl._('text', buffer.toString());
    }

    Future<HttpBody<Map<String, dynamic>>> asFormData() async {
      final values = await m.MimeMultipartTransformer(contentType.parameters['boundary']!).bind(stream).map(
        (final part) async {
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

  /// The values which indicate that no encoding was performed.
  ///
  /// https://www.w3.org/Protocols/rfc1341/5_Content-Transfer-Encoding.html
  static const List<String> _transparentEncodings = ['7bit', '8bit', 'binary'];

  /// Parse a MimeMultipart and return a [HttpMultipartFormData].
  ///
  /// If the `Content-Disposition` header is missing or invalid, an
  /// [HttpException] is thrown.
  ///
  /// If the MimeMultipart is identified as text, and the `Content-Type`
  /// header is missing, the data is decoded using [defaultEncoding]. See more
  /// information in the
  /// [HTML5 spec](http://dev.w3.org/html5/spec-preview/
  /// constraints.html#multipart-form-data).
  static HttpMultipartFormData parse(
    final m.MimeMultipart multipart, {
    final Encoding defaultEncoding = utf8,
  }) {
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
    } else {
      if (encoding != null && !_transparentEncodings.contains(encoding.value.toLowerCase())) {
        // TODO(ajohnsen): Support BASE64, etc.
        throw HttpException('Unsupported contentTransferEncoding: '
            '${encoding.value}');
      } else {
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
        return HttpMultipartFormData._(
          contentType,
          disposition,
          encoding,
          multipart,
          stream,
          isText,
        );
      }
    }
  }

  final m.MimeMultipart _mimeMultipart;

  final Stream<dynamic> _stream;

  HttpMultipartFormData._(
    final this.contentType,
    final this.contentDisposition,
    final this.contentTransferEncoding,
    final this._mimeMultipart,
    final this._stream,
    final this.isText,
  );

  @override
  StreamSubscription<dynamic> listen(
    final void Function(dynamic)? onData, {
    final void Function()? onDone,
    final Function? onError,
    final bool? cancelOnError,
  }) =>
      _stream.listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);

  /// Returns the value for the header named [name].
  ///
  /// If there is no header with the provided name, `null` will be returned.
  ///
  /// Use this method to index other headers available in the original
  /// MimeMultipart.
  String? value(
    final String name,
  ) =>
      _mimeMultipart.headers[name];
}
