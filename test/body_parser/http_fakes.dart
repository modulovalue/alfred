import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = HashMap<String, List<String>>();

  @override
  List<String>? operator [](String key) => _headers[key];

  @override
  int get contentLength => int.parse(_headers[HttpHeaders.contentLengthHeader]![0]);

  @override
  DateTime? get ifModifiedSince {
    final values = _headers[HttpHeaders.ifModifiedSinceHeader];
    if (values != null) {
      try {
        return HttpDate.parse(values[0]);
      } on Exception {
        return null;
      }
    }
    return null;
  }

  @override
  set ifModifiedSince(DateTime? ifModifiedSince) {
    ArgumentError.checkNotNull(ifModifiedSince);
    // Format "ifModifiedSince" header with date in Greenwich Mean Time (GMT).
    final formatted = HttpDate.format(ifModifiedSince!.toUtc());
    _set(HttpHeaders.ifModifiedSinceHeader, formatted);
  }

  @override
  ContentType? contentType;

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    if (preserveHeaderCase) {
      throw ArgumentError('preserveHeaderCase not supported');
    } else {
      final _name = name.toLowerCase();
      _headers.remove(_name);
      _addAll(_name, value);
    }
  }

  @override
  String? value(String name) {
    final _name = name.toLowerCase();
    final values = _headers[_name];
    if (values == null) {
      return null;
    } else {
      if (values.length > 1) {
        throw HttpException('More than one value for header $_name');
      } else {
        return values[0];
      }
    }
  }

  @override
  String toString() => '$runtimeType : $_headers';

  // [name] must be a lower-case version of the name.
  void _add(String name, Object value) {
    if (name == HttpHeaders.ifModifiedSinceHeader) {
      if (value is DateTime) {
        ifModifiedSince = value;
      } else if (value is String) {
        _set(HttpHeaders.ifModifiedSinceHeader, value);
      } else {
        throw HttpException('Unexpected type for header named $name');
      }
    } else {
      _addValue(name, value);
    }
  }

  void _addAll(String name, Object value) {
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        _add(name, value[i] as Object);
      }
    } else {
      _add(name, value);
    }
  }

  void _addValue(String name, Object value) {
    var values = _headers[name];
    if (values == null) {
      values = <String>[];
      _headers[name] = values;
    }
    if (value is DateTime) {
      values.add(HttpDate.format(value));
    } else {
      values.add(value.toString());
    }
  }

  void _set(String name, String value) {
    assert(name == name.toLowerCase(), "$name must be canonicalized to its lowercase version.");
    _headers[name] = [value];
  }

  /*
   * Implemented to remove editor warnings
   */
  @override
  dynamic noSuchMethod(Invocation invocation) {
    print([invocation.memberName, invocation.isGetter, invocation.isSetter, invocation.isMethod, invocation.isAccessor]);
    return super.noSuchMethod(invocation);
  }
}

class FakeHttpRequest extends StreamView<Uint8List> implements HttpRequest {
  @override
  final Uri uri;
  @override
  // ignore: close_sinks, just for tests, doesn't need to be closed.
  final FakeHttpResponse response = FakeHttpResponse();
  @override
  final HttpHeaders headers = FakeHttpHeaders();
  @override
  final String method = 'GET';
  final bool followRedirects;

  FakeHttpRequest(
    this.uri, {
    required Stream<Uint8List> data,
    this.followRedirects = true,
    DateTime? ifModifiedSince,
  }) : super(data) {
    if (ifModifiedSince != null) {
      headers.ifModifiedSince = ifModifiedSince;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpResponse implements HttpResponse {
  @override
  final HttpHeaders headers = FakeHttpHeaders();
  final Completer<dynamic> _completer = Completer<dynamic>();
  final List<int> _buffer = <int>[];
  String? _reasonPhrase;
  late final Future<dynamic> _doneFuture;

  FakeHttpResponse() {
    _doneFuture = _completer.future.whenComplete(() {
      // ignore: prefer_asserts_with_message
      assert(!_isDone);
      _isDone = true;
    });
  }

  bool _isDone = false;

  @override
  int statusCode = HttpStatus.ok;

  @override
  String get reasonPhrase => _findReasonPhrase(statusCode)!;

  @override
  set reasonPhrase(String value) {
    _reasonPhrase = value;
  }

  @override
  Future<dynamic> get done => _doneFuture;

  @override
  Future<dynamic> close() {
    _completer.complete();
    return _doneFuture;
  }

  @override
  void add(List<int> data) {
    _buffer.addAll(data);
  }

  @override
  void addError(dynamic error, [StackTrace? stackTrace]) {
    // doesn't seem to be hit...hmm...
  }

  @override
  Future<dynamic> redirect(Uri location, {int status = HttpStatus.movedTemporarily}) {
    statusCode = status;
    headers.set(HttpHeaders.locationHeader, location.toString());
    return close();
  }

  @override
  void write(Object? obj) => add(utf8.encode(obj.toString()));

  /*
   * Implemented to remove editor warnings
   */
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  String get fakeContent => utf8.decode(_buffer);

  List<int> get fakeContentBinary => _buffer;

  bool get fakeDone => _isDone;

  // Copied from SDK http_impl.dart @ 845 on 2014-01-05
  // TODO: file an SDK bug to expose this on HttpStatus in some way
  String? _findReasonPhrase(int statusCode) {
    if (_reasonPhrase != null) {
      return _reasonPhrase;
    }

    switch (statusCode) {
      case HttpStatus.notFound:
        return 'Not Found';
      default:
        return 'Status $statusCode';
    }
  }
}
