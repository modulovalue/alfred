import 'dart:async';
import 'dart:convert';

// TODO centralize this dependency
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart' as m;

import '../../base/header.dart';
import '../../base/http_status_code.dart';
import '../interface/parse_http_body.dart';
import '../interface/serve_context.dart';
import 'content_type.dart';

/// Process and parse an incoming [HttpRequest].
///
/// The returned [HttpRequestBody] contains a `response` field for accessing the [HttpResponse].
///
/// See [new HttpBodyHandler] for more info on [defaultEncoding].
Future<HttpRequestBody<dynamic>> processRequest(
  final AlfredRequest request,
  final AlfredResponse response, {
  final Encoding defaultEncoding = utf8,
}) async {
  try {
    final body = await _process(
      stream: request.stream,
      headers: request.headers,
      defaultEncoding: defaultEncoding,
    );
    return HttpRequestBodyImpl<dynamic>._(
      request,
      body,
    );
  } on Object catch (_) {
    // Try to send BAD_REQUEST response.
    response.setStatusCode(httpStatusBadRequest400);
    await response.close();
    rethrow;
  }
}

/// Process and parse an incoming [HttpClientResponse].
///
/// See [new HttpBodyHandler] for more info on [defaultEncoding].
Future<HttpClientResponseBody<dynamic>> processResponse(
  final HttpClientResponse response, {
  final Encoding defaultEncoding = utf8,
}) async {
  final body = await _process(
    stream: response,
    headers: response.headers,
    defaultEncoding: defaultEncoding,
  );
  return HttpClientResponseBodyImpl<dynamic>(
    response: response,
    httpBody: body,
  );
}

class HttpBodyHandlerImpl extends StreamTransformerBase<AlfredRequest, HttpRequestBody<dynamic>>
    implements HttpBodyHandler<dynamic> {
  final Encoding defaultEncoding;

  @override
  StreamTransformerBase<AlfredRequest, HttpRequestBody<dynamic>> get handler => this;

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

  @override
  Stream<HttpRequestBody<dynamic>> bind(
    final Stream<AlfredRequest> stream,
  ) {
    var pending = 0;
    var closed = false;
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (final AlfredRequest request, final sink) async {
          pending++;
          try {
            final body = await processRequest(
              request,
              request.response,
              defaultEncoding: defaultEncoding,
            );
            sink.add(body);
          } on Object catch (e, st) {
            sink.addError(e, st);
          } finally {
            pending--;
            if (closed && pending == 0) {
              sink.close();
            }
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

  const HttpBodyImpl({
    required final this.type,
    required final this.body,
  });
}

class HttpClientResponseBodyImpl<T> implements HttpClientResponseBody<T> {
  @override
  final HttpClientResponse response;

  @override
  final HttpBody<T> httpBody;

  const HttpClientResponseBodyImpl({
    required final this.response,
    required final this.httpBody,
  });
}

class HttpRequestBodyImpl<T> implements HttpRequestBody<T> {
  @override
  final AlfredRequest request;
  @override
  final HttpBody<T> httpBody;

  const HttpRequestBodyImpl._(
    final this.request,
    final this.httpBody,
  );
}

class HttpBodyFileUploadImpl<T> implements HttpBodyFileUpload<T> {
  @override
  final String filename;
  @override
  final AlfredContentType? contentType;
  @override
  final T content;

  const HttpBodyFileUploadImpl._({
    required final this.contentType,
    required final this.filename,
    required final this.content,
  });
}

Future<HttpBody<Object?>> _process({
  required final Stream<List<int>> stream,
  required final HttpHeaders headers,
  required final Encoding defaultEncoding,
}) async {
  Future<HttpBody<Uint8List>> asBinary() async {
    final builder = await stream.fold<BytesBuilder>(
      BytesBuilder(),
      (final builder, final data) => builder..add(data),
    );
    return HttpBodyImpl(
      type: 'binary',
      body: builder.takeBytes(),
    );
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
      return HttpBodyImpl(
        type: 'text',
        body: buffer.toString(),
      );
    }

    Future<HttpBody<Map<String, dynamic>>> asFormData() async {
      final values = await m.MimeMultipartTransformer(contentType.parameters['boundary']!).bind(stream).map(
        (final part) async {
          final multipart = parseHttpMultipartFormData(
            part,
            defaultEncoding: defaultEncoding,
          );
          Future<dynamic> make() async {
            if (multipart.isText) {
              final buffer = StringBuffer();
              // ignore: prefer_foreach
              await for (final dynamic val in multipart) {
                buffer.write(val);
              }
              return buffer.toString();
            } else {
              final builder = BytesBuilder();
              await for (final val in multipart) {
                if (val is List<int>) {
                  return builder.add(val);
                } else {
                  throw Exception("Expected d to be a list of integers.");
                }
              }
              return builder.takeBytes();
            }
          }

          final dynamic dataFirst = await make();
          final filename = multipart.contentDisposition.parameters['filename'];
          if (filename != null) {
            final _contentType = multipart.contentType;
            return <dynamic>[
              multipart.contentDisposition.parameters['name'],
              HttpBodyFileUploadImpl<dynamic>._(
                contentType: () {
                  if (_contentType != null) {
                    return AlfredContentTypeImpl(
                      primaryType: _contentType.primaryType,
                      subType: _contentType.subType,
                    );
                  } else {
                    return null;
                  }
                }(),
                filename: filename,
                content: dataFirst,
              ),
            ];
          } else {
            return <dynamic>[
              multipart.contentDisposition.parameters['name'],
              dataFirst,
            ];
          }
        },
      ).toList();
      final parts = await Future.wait<List<dynamic>>(values);
      final body = <String, dynamic>{
        for (final part in parts) //
          () {
            final dynamic firstPart = part[0];
            if (firstPart is String) {
              return firstPart;
            } else {
              throw Exception("Expected first part to be of type String.");
            }
          }(): part[1], // Override existing entries.
      };
      return HttpBodyImpl(
        type: 'form',
        body: body,
      );
    }

    switch (contentType.primaryType) {
      case 'text':
        return asText(defaultEncoding);
      case 'application':
        switch (contentType.subType) {
          case 'json':
            final body = await asText(utf8);
            return HttpBodyImpl(
              type: 'json',
              body: jsonDecode(body.body),
            );
          case 'x-www-form-urlencoded':
            final body = await asText(ascii);
            final map = Uri.splitQueryString(
              body.body,
              encoding: defaultEncoding,
            );
            final result = <dynamic, dynamic>{};
            for (final key in map.keys) {
              result[key] = map[key];
            }
            return HttpBodyImpl(
              type: 'form',
              body: result,
            );
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

  final m.MimeMultipart mimeMultipart;

  final Stream<dynamic> stream;

  HttpMultipartFormData({
    required final this.contentType,
    required final this.contentDisposition,
    required final this.contentTransferEncoding,
    required final this.mimeMultipart,
    required final this.stream,
    required final this.isText,
  });

  @override
  StreamSubscription<dynamic> listen(
    final void Function(dynamic)? onData, {
    final void Function()? onDone,
    final Function? onError,
    final bool? cancelOnError,
  }) =>
      stream.listen(
        onData,
        onDone: onDone,
        onError: onError,
        cancelOnError: cancelOnError,
      );

  /// Returns the value for the header named [name].
  ///
  /// If there is no header with the provided name, `null` will be returned.
  ///
  /// Use this method to index other headers available in the original
  /// MimeMultipart.
  String? value(
    final String name,
  ) =>
      mimeMultipart.headers[name];
}

/// The values which indicate that no encoding was performed.
///
/// https://www.w3.org/Protocols/rfc1341/5_Content-Transfer-Encoding.html
const List<String> _transparentEncodings = ['7bit', '8bit', 'binary'];

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
HttpMultipartFormData parseHttpMultipartFormData(
  final m.MimeMultipart multipart, {
  final Encoding defaultEncoding = utf8,
}) {
  ContentType? contentType;
  HeaderValue? encoding;
  HeaderValue? disposition;
  for (final key in multipart.headers.keys) {
    switch (key) {
      case httpHeaderContentType:
        contentType = ContentType.parse(
          multipart.headers[key]!,
        );
        break;
      case 'content-transfer-encoding':
        encoding = HeaderValue.parse(
          multipart.headers[key]!,
        );
        break;
      case 'content-disposition':
        disposition = HeaderValue.parse(
          multipart.headers[key]!,
          preserveBackslash: true,
        );
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
      throw HttpException('Unsupported contentTransferEncoding: ' + encoding.value);
    } else {
      Stream<dynamic> stream = multipart;
      final isText =
          contentType == null || contentType.primaryType == 'text' || contentType.mimeType == 'application/json';
      if (isText) {
        Encoding? encoding;
        if (contentType?.charset != null) {
          encoding = Encoding.getByName(contentType!.charset);
        }
        encoding ??= defaultEncoding;
        stream = stream.transform<dynamic>(encoding.decoder);
      }
      return HttpMultipartFormData(
        contentType: contentType,
        contentDisposition: disposition,
        contentTransferEncoding: encoding,
        mimeMultipart: multipart,
        stream: stream,
        isText: isText,
      );
    }
  }
}
