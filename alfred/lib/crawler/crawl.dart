import 'dart:async';
import 'dart:collection';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

void main() {
  final crawler = Crawler(
    initialUrl: 'https://google.com/',
    userAgent: 'spidart',
  );
  crawler.crawl(
    pageLimit: 500,
  );
}

class Crawler {
  // TODO should this also include https?
  static final RegExp _insecureHttpValidUrl = RegExp(
    '("|\')http:\/\/(www.)?(\\w+?\.)+?\\w+?(\/[^"\']+?)*?("|\')',
  );
  static final RegExp _secureHttpValidUrl = RegExp(
    '("|\')https:\/\/(www.)?(\\w+?\.)+?\\w+?(\/[^"\']+?)*?("|\')',
  );

  /// The starting point of the crawl
  final String initialUrl;

  /// What identifies this particular crawler instance
  final String userAgent;

  /// Stores all content extracted from visited pages
  final List<Text> extractedText = [];

  /// Keeps track of all visited urls
  int totalVisited = 0;

  /// Indicates if the crawler should ignore urls starting with 'http'
  final bool allowInsecureHttp;

  /// Specifies a valid url match, based on whether insecure http is allowed or not
  final RegExp _validUrl;

  /// [initialUrl] - The root of the tree of pages / The first visited page
  Crawler({
    required final this.initialUrl,
    final this.userAgent = 'spidart',
    final this.allowInsecureHttp = false,
  }) : _validUrl = (() {
          if (allowInsecureHttp) {
            return _insecureHttpValidUrl;
          } else {
            return _secureHttpValidUrl;
          }
        }());

  /// Specifies a valid path match, disallowing links to files, scripts and images
  final RegExp _validPath = RegExp('"\/[^\.]+?"');

  Future<void> crawl({
    required final int pageLimit,
  }) async {
    if (pageLimit < 1) {
      throw Exception('The page limit must be strictly positive');
    } else {
      final registeredUrls = <String>{};
      final urlsToVisit = Queue<String>()..add(initialUrl);
      final robots = Robots(userAgent: userAgent);
      if (pageLimit == -1) {
        print('Crawling with no limit of pages...');
      } else {
        print('Crawling through a maximum of ' + pageLimit.toString() + ' pages...');
      }
      // While there are hosts to visit
      while (urlsToVisit.isNotEmpty) {
        // Keeps track of paths that have already been remembered, and therefore cannot be added to [pathsToVisit]
        final registeredPaths = <String>{};
        // The empty path is the root path which must be accessed first
        final pathsToVisit = Queue<String>()..add('/');
        final url = urlsToVisit.removeFirst();
        final host = getHostFromUrl(url);
        final scraper = WebScraper(host);
        await robots.readRobots(host);
        // The robots.txt file prohibits the crawler from visiting any of its paths
        if (!robots.disallowedAllPaths) {
          print('# ' + host);
          while (pathsToVisit.isNotEmpty && totalVisited != pageLimit) {
            final path = pathsToVisit.removeFirst();
            // If loading the page failed
            try {
              final webPageLoaded = await scraper.loadWebPage(path);
              if (webPageLoaded) {
                final content = scraper.getPageContent();
                final extractedPaths = <String>[];
                final extractedUrls = extractPattern(content, _validUrl).toList();
                // Catch any paths that were written as a complete url
                extractedPaths.addAll(
                  extractedUrls
                      .where((final url) => url.startsWith(host))
                      .map(getPathFromUrl)
                      .where(robots.isAllowedPath),
                );
                // Remove the caught paths from `extractedUrls`
                extractedUrls.removeWhere((final url) => url.startsWith(host));
                // Remember to visit a url only if it hasn't already been visited
                urlsToVisit.addAll(extractedUrls.where((final url) => !registeredUrls.contains(url)));
                // Remember unique hosts
                registeredUrls.addAll(extractedUrls.map((final url) => url));
                extractedPaths.addAll(extractPattern(content, _validPath));
                // Remember to visit a path only if it hasn't already been visited
                pathsToVisit.addAll(
                  extractedPaths.where(
                    (final path) => !registeredPaths.contains(path) && robots.isAllowedPath(path),
                  ),
                );
                // Remember unique paths
                registeredPaths.addAll(extractedPaths);
                extractedText.addAll(
                  content
                      .replaceAll(metadataTagsRegex, '')
                      .replaceAll(formattingTagsRegex, '')
                      .replaceAll(sectioningTagsRegex, '')
                      .replaceAll(formTagsRegex, '')
                      .replaceAll(irrelevantTagsRegex, '')
                      .split('  ')
                      .map((final textPiece) => Text(TextType.none, textPiece)),
                );
                totalVisited++;
                print(totalVisited.toString() + ' >> ' + host + path);
              } else {
                continue;
              }
            } on WebScraperException catch (e) {
              print(e.message);
              continue;
            }
          }
          if (totalVisited == pageLimit) {
            break;
          }
        }
      }
      print(
        'Crawl complete. Visited ' +
            totalVisited.toString() +
            ' pages, extracted ' +
            extractedText.length.toString() +
            ' pieces of text.',
      );
    }
  }
}

class Text {
  final TextType type;
  final String content;

  const Text(
    final this.type,
    final this.content,
  );
}

enum TextType {
  quote,
  paragraph,
  none,
}

/// Extract the parts of text that correspond with the pattern
Iterable<String> extractPattern(
  final String str,
  final Pattern pattern,
) =>
    pattern.allMatches(str).map((final m) => m.group(0)!.replaceAll('"', ''));

/// Remove path to leave just the hostname
String getHostFromUrl(
  final String url,
) =>
    url.split('/').sublist(0, 3).join('/');

/// Remove hostname to leave just the path
String getPathFromUrl(
  final String url,
) =>
    '/' + url.split('/').sublist(3).join('/');

/// Remove the final part of the path to leave just the parent directory
String getParentPath(
  final String url,
) {
  final parts = url.split('/');
  parts.removeLast();
  return parts.join('/') + '/';
}

/// Corresponds with the robots.txt file of a host
class Robots {
  /// This crawler's user agent
  final String userAgent;

  /// The complete routes the crawler *can* visit
  final List<String> allowedCompletePaths = [];

  /// The incomplete routes the crawler *can* visit
  final List<String> allowedIncompletePaths = [];

  /// The complete routes the crawler *cannot* visit
  final List<String> disallowedCompletePaths = [];

  /// The incomplete routes the crawler *cannot* visit
  final List<String> disallowedIncompletePaths = [];

  bool disallowedAllPaths = false;

  Robots({
    required final this.userAgent,
  });

  /// Reads and parses the robots.txt file of a host
  Future<void> readRobots(
    final String url,
  ) async {
    allowedCompletePaths.clear();
    allowedIncompletePaths.clear();
    disallowedCompletePaths.clear();
    disallowedIncompletePaths.clear();
    disallowedAllPaths = false;
    final scraper = WebScraper(url);
    await scraper.loadWebPage('/robots.txt');
    // Read the text content of the robots.txt file
    final content = scraper.getPageContent().replaceAll(RegExp('<\/?(html|head|body)>'), '');
    final lines = content.split('\n');
    // If there is any html code still left over, do not parse robots.txt
    if (!content.contains('<')) {
      // Only the key-value pairs relevant to this user-agent and * should be counted
      var parsingRelevantAllowances = false;
      for (final line in lines) {
        // Empty lines and comments should not be parsed
        if (line.trim().isNotEmpty && !line.startsWith('#')) {
          final pair = line.split(':');
          final key = pair[0].toLowerCase();
          final value = pair[1].trim();
          switch (key) {
            case 'user-agent':
              if (value == '*' || value == userAgent) {
                parsingRelevantAllowances = true;
              } else {
                parsingRelevantAllowances = false;
              }
              break;
            case 'allow':
              if (parsingRelevantAllowances) {
                if (value == '*') {
                  disallowedCompletePaths.clear();
                  disallowedIncompletePaths.clear();
                } else if (value.endsWith('*') || value.endsWith('[')) {
                  allowedIncompletePaths.add(getParentPath(value));
                } else {
                  allowedCompletePaths.add(value);
                }
              }
              break;
            case 'disallow':
              if (parsingRelevantAllowances) {
                // ignore: invariant_booleans
                if (value == '*') {
                  allowedCompletePaths.clear();
                  allowedIncompletePaths.clear();
                  disallowedAllPaths = true;
                } else if (value.endsWith('*') || value.endsWith('[')) {
                  disallowedIncompletePaths.add(getParentPath(value));
                } else {
                  disallowedCompletePaths.add(value);
                }
              }
              break;
            default:
              break;
          }
        }
      }
    }
  }

  /// Determines whether a path may be visited or not, taking into account allowed paths as well
  bool isAllowedPath(
    final String path,
  ) =>
      (!disallowedCompletePaths.contains(path) || allowedCompletePaths.contains(path)) &&
      // All entries listed under a disallowed path should be disregarded
      (!disallowedIncompletePaths.any((incompletePath) => path.startsWith(incompletePath)) ||
          allowedIncompletePaths.any((incompletePath) => path.startsWith(incompletePath)));
}

const List<String> metadataTags = [
  'head',
  'link',
  'meta',
];

const List<String> formattingTags = [
  'b',
  'i',
  's',
  'u',
  'span',
  'strong',
  'small',
  'mark',
  'em',
  'del',
  'ins',
  'sub',
  'sup'
];

const List<String> quotationTags = [
  'blockquote',
  'q',
  'abbr',
  'address',
  'cite',
  'bdo',
];

const List<String> sectioningTags = [
  'html',
  'main',
  'header',
  'body',
  'footer',
  'nav',
  'article',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'div',
  'hr',
  'li',
  'ol',
  'ul'
];

const List<String> paragraphTags = [
  'p',
  'pre',
];

const List<String> formTags = [
  'button',
  'datalist',
  'form',
  'fieldset',
  'label',
  'legend',
  'optgroup',
  'option',
  'select'
];

const List<String> irrelevantTags = [
  'area',
  'audio',
  'img',
  'map',
  'track',
  'video',
  'embed',
  'iframe',
  'object',
  'param',
  'source',
  'canvas',
  'noscript',
  'script',
  'code',
  'a',
  'address',
  'textarea'
];

final RegExp metadataTagsRegex = RegExp(
  '<(${metadataTags.join('|')}).+?<\/(${metadataTags.join('|')})>',
);
final RegExp formattingTagsRegex = RegExp(
  '<\/?(${formattingTags.join('|')})[^<>]*?>',
);
final RegExp sectioningTagsRegex = RegExp(
  '<\/?(${sectioningTags.join('|')})[^<>]*?>',
);
final RegExp formTagsRegex = RegExp(
  '<\/?(${formTags.join('|')})[^<>]*?>',
);
final RegExp irrelevantTagsRegex = RegExp(
  '<(${irrelevantTags.join('|')}).+?<\/(${irrelevantTags.join('|')})>',
  dotAll: true,
);

/// Validation Class containing all functions related to URL validation.
class Validation {
  static final RegExp _ipv6 = RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');
  static final RegExp _ipv4Maybe = RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');

  Validation();

  /// The isBaseURL function checks the base URLs like https://pub.dev.
  ValidationReturn isBaseURL(
    final String str,
  ) {
    // Protocols supported for web scraping includes http & https.
    const protocols = ['http', 'https'];
    dynamic protocol;
    List<dynamic> split;
    dynamic host;
    // Checking the protocol.
    split = str.split('://');
    if (split.length > 1) {
      protocol = _shift(split);
      if (protocols.contains(protocol) == false) {
        return const ValidationReturn(false, 'use [http/https] protocol');
      }
    } else {
      return const ValidationReturn(false, 'bring url to the format scheme:[//]domain; EXAMPLE: https://google.com');
    }
    // Checking the host.
    host = _removeUnnecessarySlash(_shift(split) as String);
    if (!_isIP(host as String) && !_isFQDN(host) && host != 'localhost') {
      return const ValidationReturn(false, 'URL should contain only domain without path');
    } else {
      return const ValidationReturn(true, 'ok');
    }
  }

  // Remove unnecessary '/' after domain.
  // Ex.: 'google.com////' will become 'google.com'.
  // Ex.: 'google.com//search//' will become 'google.com/search'.
  String _removeUnnecessarySlash(
    String str,
  ) {
    final s = str.split('/');
    if (s.length > 1) {
      final hostSlice = <String>[];
      s.forEach((String e) {
        if (e.isNotEmpty) {
          hostSlice.add(e);
        }
      });
      var newStr = '';
      var i = 0;
      hostSlice.forEach((String e) {
        if (i > 0) {
          newStr = newStr + '/' + e;
        } else {
          newStr += e;
        }
        i++;
      });
      // ignore: parameter_assignments
      str = newStr;
    }
    return str;
  }

  dynamic _shift(
    final List<dynamic> l,
  ) {
    if (l.isNotEmpty) {
      final dynamic first = l.first;
      l.removeAt(0);
      return first;
    }
    return null;
  }

  bool _isIP(
    final String str, [
    /*<String | int>*/ dynamic version,
  ]) {
    // ignore: parameter_assignments
    version = version.toString();
    if (version == 'null') {
      return _isIP(str, 4) || _isIP(str, 6);
    } else if (version == '4') {
      if (!_ipv4Maybe.hasMatch(str)) {
        return false;
      }
      final parts = str.split('.');
      parts.sort((a, b) => int.parse(a) - int.parse(b));
      return int.parse(parts[3]) <= 255;
    }
    return version == '6' && _ipv6.hasMatch(str);
  }

  bool _isFQDN(
    final String str, {
    final bool requireTld = true,
    final bool allowUnderscores = false,
  }) {
    final parts = str.split('.');
    if (requireTld) {
      final tld = parts.removeLast();
      if (parts.isEmpty || !RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
        return false;
      }
    }
    for (final part in parts) {
      if (allowUnderscores) {
        if (part.contains('__')) {
          return false;
        }
      }
      if (!RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
        return false;
      }
      if (part[0] == '-' || part[part.length - 1] == '-' || part.contains('---')) {
        return false;
      }
    }
    return true;
  }
}

/// ValidationReturn class provides the result of validation
/// including [isCorrect] and [description] for more details.
class ValidationReturn {
  final bool isCorrect;
  final String description;

  const ValidationReturn(
    final this.isCorrect,
    final this.description,
  );
}

/// WebScraper Main Class.
class WebScraper {
  // Parsed document from the response inside the try/catch of the loadWebPage() method.
  Document? _document;

  // Time elapsed in loading in milliseconds.
  int? timeElaspsed;

  // Base url of the website to be scrapped.
  String? baseUrl;

  /// Creates the web scraper instance.
  WebScraper([
    final String? baseUrl,
  ]) {
    if (baseUrl != null) {
      final v = Validation().isBaseURL(baseUrl);
      if (!v.isCorrect) {
        throw WebScraperException(v.description);
      }
      this.baseUrl = baseUrl;
    }
  }

  /// Loads the webpage into response object.
  Future<bool> loadWebPage(
    final String route,
  ) async {
    if (baseUrl != null && baseUrl != '') {
      final stopwatch = Stopwatch()..start();
      final client = Client();
      try {
        final _response = await client.get(Uri.parse(baseUrl! + route));
        // Calculating Time Elapsed using timer from dart:core.
        timeElaspsed = stopwatch.elapsed.inMilliseconds;
        stopwatch.stop();
        stopwatch.reset();
        // Parses the response body once it's retrieved to be used on the other methods.
        _document = parse(_response.body);
      } on Object catch (e) {
        throw WebScraperException(e.toString());
      }
      return true;
    }
    return false;
  }

  /// Loads the webpage URL into response object without requiring the two-step process of base + route.
  /// Unlike the the two-step process, the URL is NOT validated before being requested.
  Future<bool> loadFullURL(
    final String page,
  ) async {
    final client = Client();
    try {
      final _response = await client.get(Uri.parse(page));
      // Calculating Time Elapsed using timer from dart:core.
      // Parses the response body once it's retrieved to be used on the other methods.
      _document = parse(_response.body);
    } on Object catch (e) {
      throw WebScraperException(e.toString());
    }
    return true;
  }

  /// Loads a webpage that was previously loaded and stored as a String by using [getPageContent].
  /// This operation is synchronous and returns a true bool once the string has been loaded and is ready to
  /// be queried by either [getElement], [getElementTitle] or [getElementAttribute].
  bool loadFromString(
    final String responseBodyAsString,
  ) {
    try {
      // Parses the response body once it's retrieved to be used on the other methods.
      _document = parse(responseBodyAsString);
    } on Object catch (e) {
      throw WebScraperException(e.toString());
    }
    return true;
  }

  /// Returns the list of all data enclosed in script tags of the document.
  List<String> getAllScripts() {
    // The _document should not be null (loadWebPage must be called before getAllScripts).
    // ignore: prefer_asserts_with_message
    assert(_document != null);
    // Quering the list of elements by tag names.
    final scripts = _document!.getElementsByTagName('script');
    final result = <String>[];
    // Looping in all script tags of the document.
    for (final script in scripts) {
      /// Adds the data enclosed in script tags
      /// ex. if document contains <script> var a = 3; </script>
      /// var a = 3; will be added to result.
      result.add(script.text);
    }
    return result;
  }

  /// Returns Map between given variable names and list of their occurence in the script tags
  ///
  // ex. if document contains
  // <script> var a = 15; var b = 10; </script>
  // <script> var a = 9; </script>
  // method will return {a: ['var a = 15;', 'var a = 9;'], b: ['var b = 10;'] }.
  Map<String, dynamic> getScriptVariables(
    final List<String> variableNames,
  ) {
    // The _document should not be null (loadWebPage must be called before getScriptVariables).
    // ignore: prefer_asserts_with_message
    assert(_document != null);
    // Quering the list of elements by tag names.
    final scripts = _document!.getElementsByTagName('script');
    final result = <String, List<String>?>{};
    // Looping in all the script tags of the document.
    for (final script in scripts) {
      // Looping in all the variable names that are required to extract.
      for (final variableName in variableNames) {
        // Regular expression to get the variable names.
        final re = RegExp('$variableName *=.*?;(?=([^\"\']*\"[^\"\']*\")*[^\"\']*\$)', multiLine: true);
        //  Iterate all matches
        final matches = re.allMatches(script.text);
        matches.forEach((match) {
          // List for all the occurence of the variable name.
          var temp = result[variableName];
          if (result[variableName] == null) {
            temp = [];
          }
          temp!.add(script.text.substring(match.start, match.end));
          result[variableName] = temp;
        });
      }
    }
    // Returning final result i.e. Map of variable names with the list of their occurences.
    return result;
  }

  /// Returns webpage's html in string format.
  String getPageContent() {
    if (_document != null) {
      return _document!.outerHtml;
    } else {
      return throw const WebScraperException('ERROR: Webpage need to be loaded first, try calling loadWebPage');
    }
  }

  /// Returns List of elements titles found at specified address.
  /// Example address: "div.item > a.title" where item and title are class names of div and a tag respectively.
  /// For ease of access, when using Chrome inspection tool, right click the item you want to copy, then click "Inspect" and at the console, right click the highlighted item, right click and then click "Copy > Copy selector" and provide as String address parameter to this method.
  List<String> getElementTitle(
    final String address,
  ) {
    if (_document == null) {
      throw const WebScraperException('getElement cannot be called before loadWebPage');
    } else {
      // Using query selector to get a list of particular element.
      final elements = _document!.querySelectorAll(address);
      final elementData = <String>[];
      for (final element in elements) {
        // Checks if the element's text is null before adding it to the list.
        if (element.text.trim() != '') {
          elementData.add(element.text);
        }
      }
      return elementData;
    }
  }

  /// Returns List of elements' attributes found at specified address respecting the provided attribute requirement.
  ///
  /// Example address: "div.item > a.title" where item and title are class names of div and a tag respectively.
  /// For ease of access, when using Chrome inspection tool, right click the item you want to copy, then click "Inspect" and at the console, right click the highlighted item, right click and then click "Copy > Copy selector" and provide as String parameter to this method.
  /// Attributes are the bits of information between the HTML tags.
  /// For example in <div class="strong and bold" style="width: 100%;" title="Fierce!">
  /// The element would be "div.strong.and.bold" and the possible attributes to fetch would be EIHER "style" OR "title" returning with EITHER of the values "width: 100%;" OR "Fierce!" respectively.
  /// To retrieve multiple attributes at once from a single element, please use getElement() instead.
  List<dynamic> getElementAttribute(
    final String address,
    final String attrib,
  ) {
    // Attribs are the list of attributes required to extract from the html tag(s) ex. ['href', 'title'].
    if (_document == null) {
      throw const WebScraperException('getElement cannot be called before loadWebPage');
    } else {
      // Using query selector to get a list of particular element.
      final elements = _document!.querySelectorAll(address);
      // ignore: omit_local_variable_types
      final List<dynamic> elementData = <dynamic>[];
      for (final element in elements) {
        final attribData = <String, dynamic>{};
        attribData[attrib] = element.attributes[attrib];
        // Checks if the element's attribute is null before adding it to the list.
        if (attribData[attrib] != null) {
          elementData.add(attribData[attrib]);
        }
      }
      return elementData;
    }
  }

  /// Returns List of elements found at specified address.
  /// Example address: "div.item > a.title" where item and title are class names of div and a tag respectively.
  ///
  /// Sometimes the last address is not present consistently throughout the webpage. Use "extraAddress" to catch its attributes.
  /// Example extraAddress: "a"
  List<Map<String, dynamic>> getElement(
    final String address,
    final List<String> attribs, {
    final String? extraAddress,
  }) {
    // Attribs are the list of attributes required to extract from the html tag(s) ex. ['href', 'title'].
    if (_document == null) {
      throw const WebScraperException('getElement cannot be called before loadWebPage');
    } else {
      // Using query selector to get a list of particular element.
      final elements = _document!.querySelectorAll(address);
      // ignore: omit_local_variable_types
      final elementData = <Map<String, dynamic>>[];
      for (final element in elements) {
        final attribData = <String, dynamic>{};
        for (final attrib in attribs) {
          if (extraAddress != null) {
            final extraElement = element.querySelector(extraAddress);
            if (extraElement != null) {
              attribData[attrib] = extraElement.attributes[attrib];
            }
          } else {
            attribData[attrib] = element.attributes[attrib];
          }
        }
        elementData.add(
          <String, dynamic>{
            'title': element.text,
            'attributes': attribData,
          },
        );
      }
      return elementData;
    }
  }
}

/// WebScraperException throws exception with specified message.
class WebScraperException implements Exception {
  final String? message;

  const WebScraperException(
    final this.message,
  );
}
