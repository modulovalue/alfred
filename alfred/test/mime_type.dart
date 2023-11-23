// ignore_for_file: discarded_futures

import 'dart:convert';
import 'dart:io';

import 'package:alfred/base/mime.dart';
import 'package:test/test.dart';

void main() {
  final result = <String>[];
  for (final file in [
    'Franklin D. Roosevelt.dart',
    'Harry S.Truman.html',
    'Dwight D. Eisenhower.c',
    'John F. Kennedy.css',
    'Lyndon B. Johnson.json',
    'Richard Nixon.mp3',
    'Gerald Ford.cpp',
    'Jimmy Carter.java',
    'Ronald Reagan.jar',
    'George H. W. Bush.doc',
    'Bill Clinton.odt',
    'George W. Bush.pdf',
    'Barack Obama.spreadsheets',
    'Donald Trump.txt',
    'no such extension.abcde',
    'no extension 1.',
    'no extension 2',
    r'c:\filepath.dart',
    '..Hello.dart'
  ]) {
    result.add(
      'mime type for "' + file + '" is "' + mime(file).toString() + '"',
    );
  }
  for (final ext in [
    '123',
    'zmm',
    'abcde',
  ]) {
    result.add(
      'mime type for extension "' + ext + '" is "' + mimeFromExtension(ext).toString() + '"',
    );
  }
  for (final mime in [
    'Franklin D. Roosevelt.dart',
    'audio/x-mpeg',
    'application/rtf',
  ]) {
    result.add(
      'extension for mime "' + mime + '" is "' + extensionFromMime(mime).toString() + '"',
    );
  }
  group("mime type", () {
    test("test", () {
      expect(
        result,
        [
          'mime type for "Franklin D. Roosevelt.dart" is "text/x-dart"',
          'mime type for "Harry S.Truman.html" is "text/html"',
          'mime type for "Dwight D. Eisenhower.c" is "text/x-c"',
          'mime type for "John F. Kennedy.css" is "text/css"',
          'mime type for "Lyndon B. Johnson.json" is "application/json"',
          'mime type for "Richard Nixon.mp3" is "audio/mpeg"',
          'mime type for "Gerald Ford.cpp" is "text/x-c"',
          'mime type for "Jimmy Carter.java" is "text/x-java-source"',
          'mime type for "Ronald Reagan.jar" is "application/java-archive"',
          'mime type for "George H. W. Bush.doc" is "application/msword"',
          'mime type for "Bill Clinton.odt" is "application/vnd.oasis.opendocument.text"',
          'mime type for "George W. Bush.pdf" is "application/pdf"',
          'mime type for "Barack Obama.spreadsheets" is "application/vnd.google-apps.spreadsheet"',
          'mime type for "Donald Trump.txt" is "text/plain"',
          'mime type for "no such extension.abcde" is "null"',
          'mime type for "no extension 1." is "null"',
          'mime type for "no extension 2" is "null"',
          'mime type for "c:\\filepath.dart" is "text/x-dart"',
          'mime type for "..Hello.dart" is "text/x-dart"',
          'mime type for extension "123" is "application/vnd.lotus-1-2-3"',
          'mime type for extension "zmm" is "application/vnd.handheld-entertainment+xml"',
          'mime type for extension "abcde" is "null"',
          'extension for mime "Franklin D. Roosevelt.dart" is "null"',
          'extension for mime "audio/x-mpeg" is "mpa"',
          'extension for mime "application/rtf" is "rtf"'
        ],
      );
    });
  });
}

// TODO load apache mime types and use them to test existing mime types.
// ignore: unused_element
void _parseBodyStr(
  final String bodyStr,
) {
  const URL = 'https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types';
  String bodyStr = '';
  final client = HttpClient();
  client
      .getUrl(
        Uri.parse(URL),
      )
      .then(
        (final request) => request.close(),
      )
      .then((final response) {
    // Process the response.
    utf8.decoder.bind(response).listen(
      (final bodyChunk) => bodyStr += bodyChunk,
      onDone: () {
        final lineExp = RegExp(
          r'^([\w-]+/[\w+.-]+)((?:\s+[\w-]+)*)$',
          multiLine: true,
        );
        final extensionExp = RegExp(r'\s+');
        final matches = lineExp.allMatches(bodyStr);
        for (final m in matches) {
          final mimeType = m.group(1)!;
          final extensions = m.group(2)!.trimLeft().split(extensionExp);
          // print('mimeType : $mimeType, extensions = $extensions');
          for (final extension in extensions) {
            mimeMap.addAll({extension: mimeType});
          }
        }
        final sortedKeys = mimeMap.keys.toList()..sort();
        final sortedMimeMap = <String, String>{};
        for (final key in sortedKeys) {
          sortedMimeMap[key] = mimeMap[key]!;
        }
        final keys = sortedMimeMap.keys;
        for (final key in keys) {
          if (key == keys.last) {
            print("  '" + key + "': '" + sortedMimeMap[key]! + "'");
          } else {
            print("  '" + key + "': '" + sortedMimeMap[key]! + "',");
          }
        }
      },
    );
  });
}
