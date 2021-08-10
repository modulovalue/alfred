import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:three_dart/core/core.dart';
import 'package:three_dart/parser/tokenizer.dart';

/// Prints an FPS output for the given TreeDart object ot the console.
void showFPS(
  final ThreeDart td,
) =>
    Timer.periodic(
      const Duration(milliseconds: 5000),
      (final time) {
        final String fps = td.fps.toStringAsFixed(2);
        if (fps != "0.00") print("$fps fps");
      },
    );

typedef Texture2DSelectedHndl = void Function(
  String fileName,
);

/// A radio button group for selecting a texture.
class Texture2DGroup {
  /// The name of the element for the radio button group.
  String _elemId;

  /// Indicates if the group should be kept in the URL.
  bool _keepInURL;

  /// The element to fill with radio buttons.
  Element _elem;

  /// The handler to change the selected texture.
  Texture2DSelectedHndl _hndl;

  /// Creates a new radio button group for selecting a texture.
  factory Texture2DGroup(String elemId, Texture2DSelectedHndl hndl, [bool keepInURL = true]) {
    final Element? elem = document.getElementById(elemId);
    if (elem == null) throw Exception('Failed to find $elemId for Texture2DGroup');
    return Texture2DGroup._(elemId, hndl, keepInURL, elem);
  }

  /// Creates a new radio button group for selecting a texture.
  Texture2DGroup._(
    this._elemId,
    this._hndl,
    this._keepInURL,
    this._elem,
  );

  /// Adds a new texture radio button.
  void add(String fileName, [bool checkedByDefault = false]) {
    final ImageElement imgElem = ImageElement()
      // ignore: unsafe_html
      ..src = fileName
      ..width = 64
      ..height = 64
      ..style.border = 'solid 2px white';
    final int index = this._elem.children.length;
    imgElem.onClick.listen((_) {
      this._elem.children.forEach((Element elem) {
        if (elem is ImageElement) elem.style.border = 'solid 2px white';
      });
      imgElem.style.border = 'solid 2px black';
      this._hndl(fileName);
      this._updateUrl(index);
    });
    this._elem.children.add(imgElem);
    this._elem.children.add(BRElement());
    bool itemIsChecked = false;
    final String? urlText = Uri.base.queryParameters[this._elemId];
    if (urlText == null) {
      itemIsChecked = checkedByDefault;
      this._updateUrl(index);
    } else {
      final int selectedIndex = int.parse(urlText);
      itemIsChecked = selectedIndex == index;
    }
    if (itemIsChecked) imgElem.click();
  }

  /// Updates the URL for changes in the radio group.
  void _updateUrl(int index) {
    if (!this._keepInURL) return;
    final Uri current = Uri.base;
    final Map<String, String> parameters = Map<String, String>.from(current.queryParameters);
    parameters[this._elemId] = '$index';
    final Uri newUrl = current.replace(queryParameters: parameters);
    window.history.replaceState('', '', newUrl.toString());
  }
}

/// The shell page is a tool for creating pages quickly and
/// easily which will have a consistent look and feel.
class ShellPage {
  DivElement _page;
  Tokenizer? _parTokenizer;

  /// Creates a new shell page with an optional [title].
  factory ShellPage([String title = "", bool showTopTitle = true]) {
    final BodyElement? body = document.body;
    if (body == null) throw Exception('The html document body was null.');
    final DivElement scrollTop = DivElement()..className = "scrollTop";
    body.append(scrollTop);
    final DivElement scrollPage = DivElement()..className = "scrollPage";
    body.append(scrollPage);
    final DivElement pageCenter = DivElement()..className = "pageCenter";
    scrollPage.append(pageCenter);
    if (title.isNotEmpty) {
      document.title = title;
      if (showTopTitle) {
        final DivElement titleElem = DivElement()
          ..className = "pageTitle"
          ..text = title;
        pageCenter.append(titleElem);
      }
    }
    final page = DivElement();
    pageCenter.append(page);
    document.onScroll.listen((Event e) {
      Timer.run(() {
        final int offset = document.documentElement?.scrollTop ?? 0;
        scrollTop.style.top = "${-0.01 * offset}px";
      });
    });
    return ShellPage._(page);
  }

  /// Creates a new shell page.
  ShellPage._(
    final this._page,
  );

  /// The page element to append new data to.
  DivElement get page => this._page;

  /// Adds a section header with the give [text] into the page.
  /// The [level] defines its weight where it is 0, largest to 4, smallest.
  /// The optional [id] is a custom link identifier for this header,
  /// if left blank the id will be auto-generated.
  void addHeader(int level, String text, [String id = ""]) {
    // ignore: parameter_assignments
    level = level.clamp(0, 4);
    // ignore: parameter_assignments
    if (id.isEmpty) id = Uri.encodeFull(text);
    final DivElement textHeaderElem = DivElement()
      ..className = "textHeader"
      ..id = id
      ..style.fontSize = "${28 - level * 3}px";
    final AnchorElement anchor = AnchorElement()
      // ignore: unsafe_html
      ..href = "#$id"
      ..text = text;
    textHeaderElem.append(anchor);
    this._page.append(textHeaderElem);
  }

  /// Adds a div element with an identifier for outputting custom output to.
  void addDiv(String id, [String className = "codePar"]) {
    final DivElement div = DivElement()
      ..className = className
      ..id = id;
    this._page.append(div);
  }

  /// Adds a paragraph to the page. The body of the paragraph
  /// can be split across several lines as several entries into the list.
  /// If the text is wrapped by asterisks the text will be bolded.
  /// If the text is wrapped by underscores the text will be italic.
  /// If the text is wrapped by back ticks the text will be syled like code.
  /// If the text has square brackets around the text it will be a link.
  /// The link can have a custom location after a vertical bar.
  void addPar(List<String> text) {
    final tok = this._setupParTokenizer();
    final DivElement parElem = DivElement()..className = "textPar";
    for (final Token token in tok.tokenize(text.join())) {
      switch (token.name) {
        case "Bold":
          final DivElement textElem = DivElement()
            ..className = "boldPar"
            ..text = token.text;
          parElem.append(textElem);
          break;
        case "Italic":
          final DivElement textElem = DivElement()
            ..className = "italicPar"
            ..text = token.text;
          parElem.append(textElem);
          break;
        case "Code":
          final DivElement textElem = DivElement()
            ..className = "codePar"
            ..text = token.text;
          parElem.append(textElem);
          break;
        case "Link":
          if (token.text.contains("|")) {
            final List<String> parts = token.text.split("|");
            final AnchorElement anchor = AnchorElement()
              ..className = "linkPar"
              // ignore: unsafe_html
              ..href = parts[1]
              ..text = parts[0];
            parElem.append(anchor);
          } else {
            final String id = Uri.encodeFull(token.text);
            final AnchorElement anchor = AnchorElement()
              ..className = "linkPar"
              // ignore: unsafe_html
              ..href = "#${id}"
              ..text = token.text;
            parElem.append(anchor);
          }
          break;
        case "Other":
          final DivElement textElem = DivElement()
            ..className = "normalPar"
            ..text = token.text;
          parElem.append(textElem);
          break;
      }
    }
    this._page.append(parElem);
  }

  /// Gets the code parser for the given [lang].
  CodeParser getCodeParser(String lang) {
    // Full list of parsers, add more as needed.
    final List<CodeParser?> parsers = [DartParser(), GLSLParser(), HTMLParser()];
    final CodeParser? parser = parsers.firstWhere((CodeParser? parser) => parser?.name == lang);
    if (parser != null) return parser;
    return PlainParser();
  }

  /// Adds a code box with the given [title] to the page.
  /// The given [lang] is the language to color the code with.
  /// Currently it supports HTML, Dart, GLSL, and other.
  /// The [lines] are the lines of the code for the box.
  /// If any line starts with a + or - then a diff is shown.
  /// The [firstLineNo] is the offset for the first line number.
  void addCode(String title, String lang, int firstLineNo, List<String> lines) {
    final List<int> diff = [];
    bool showDiff = false;
    for (int i = 0; i < lines.length; ++i) {
      final String line = lines[i];
      if (line.startsWith("+")) {
        lines[i] = line.substring(1);
        diff.add(1);
        showDiff = true;
      } else if (line.startsWith("-")) {
        lines[i] = line.substring(1);
        diff.add(-1);
        showDiff = true;
      } else {
        diff.add(0);
      }
    }
    final CodeParser colorCode = this.getCodeParser(lang);
    colorCode.parse(lines);
    final DivElement codeTableScroll = DivElement()..className = "codeTableScroll";
    final TableElement codeTable = TableElement()..className = "codeTable";
    codeTableScroll.append(codeTable);
    this._page.append(codeTableScroll);
    final String id = Uri.encodeFull(title);
    final TableRowElement headerElem = TableRowElement()..className = "headerRow";
    final TableCellElement headerCellElem = TableCellElement()
      ..className = "headerCell"
      ..colSpan = () {
        if (showDiff) {
          return 3;
        } else {
          return 2;
        }
      }();
    final tableHeaderElem = DivElement()
      ..className = "tableHeader"
      ..id = id;
    final anchor = AnchorElement()
      // ignore: unsafe_html
      ..href = "#" + id
      ..text = title;
    tableHeaderElem.append(anchor);
    headerCellElem.append(tableHeaderElem);
    headerElem.append(headerCellElem);
    codeTable.append(headerElem);
    if (showDiff) {
      int lineNoSub = firstLineNo, lineNoAdd = firstLineNo;
      for (int i = 0; i < colorCode.lineList.length; ++i) {
        final List<DivElement> line = colorCode.lineList[i];
        final TableRowElement rowElem = TableRowElement()..className = "codeTableRow";
        final TableCellElement cell1Elem = TableCellElement()..className = "codeLineNums codeLineLight";
        final TableCellElement cell2Elem = TableCellElement()..className = "codeLineNums";
        final int value = diff[i];
        if (value == 0) {
          lineNoSub++;
          lineNoAdd++;
          cell1Elem.text = "$lineNoSub";
          cell2Elem.text = "$lineNoAdd";
        } else if (value > 0) {
          rowElem.className = "codeTableRow codeLineLightGreen";
          cell1Elem.className = "codeLineNums codeLineGreen codeLineCenter";
          cell2Elem.className = "codeLineNums codeLineGreen";
          lineNoAdd++;
          cell1Elem.text = "+";
          cell2Elem.text = "$lineNoAdd";
        } else if (value < 0) {
          rowElem.className = "codeTableRow codeLineLightRed";
          cell1Elem.className = "codeLineNums codeLineRed";
          cell2Elem.className = "codeLineNums codeLineRed codeLineCenter";
          lineNoSub++;
          cell1Elem.text = "$lineNoSub";
          cell2Elem.text = "-";
        }
        final TableCellElement cell3Elem = TableCellElement()..className = "codeLineText";
        // ignore: prefer_foreach
        for (final partElem in line) {
          cell3Elem.append(partElem);
        }
        rowElem.append(cell1Elem);
        rowElem.append(cell2Elem);
        rowElem.append(cell3Elem);
        codeTable.append(rowElem);
      }
    } else {
      int lineNo = firstLineNo;
      for (final List<DivElement> line in colorCode.lineList) {
        final TableRowElement rowElem = TableRowElement()..className = "codeTableRow";
        final TableCellElement cell1Elem = TableCellElement()
          ..className = "codeLineNums"
          ..text = "${lineNo + 1}";
        final TableCellElement cell2Elem = TableCellElement()..className = "codeLineText";
        // ignore: prefer_foreach
        for (final DivElement partElem in line) {
          cell2Elem.append(partElem);
        }
        rowElem.append(cell1Elem);
        rowElem.append(cell2Elem);
        codeTable.append(rowElem);
        lineNo++;
      }
    }
  }

  /// Adds an image to the page with the given [id].
  void addImage(String id, String path, [String link = ""]) {
    final DivElement pageImageElem = DivElement()
      ..className = "pageImage"
      ..id = id;
    // ignore: unsafe_html
    final AnchorElement anchor = AnchorElement()..href = "#$id";
    // ignore: unsafe_html
    final ImageElement image = ImageElement()..src = path;
    anchor.append(image);
    if (link.isNotEmpty) {
      final AnchorElement hrefAnchor = AnchorElement()
        ..className = "linkPar"
        // ignore: unsafe_html
        ..href = link;
      hrefAnchor.append(anchor);
      pageImageElem.append(hrefAnchor);
    } else {
      pageImageElem.append(anchor);
    }
    this._page.append(pageImageElem);
  }

  /// Adds a canvas to the page with the given [id]
  /// which can be used to host a three_dart
  void addCanvas(String id) {
    final CanvasElement canvas = CanvasElement()
      ..className = "pageCanvas"
      ..id = id;
    this._page.append(canvas);
  }

  /// Adds a large canvas to the page with the given [id]
  /// which can be used to host a three_dart
  void addLargeCanvas(String id) {
    final canvas = CanvasElement()
      ..className = "pageLargeCanvas"
      ..id = id;
    this._page.append(canvas);
  }

  /// Adds an FPS output for the given TreeDart object.
  void addFPS(ThreeDart td) {
    final textElem = DivElement()
      ..text = "0.00 fps"
      ..className = "fps";
    this._page.append(textElem);
    Timer.periodic(const Duration(milliseconds: 5000), (final time) {
      final fps = td.fps.toStringAsFixed(2);
      textElem.text = "$fps fps";
    });
  }

  /// Adds the given element into the page.
  void addElem(Element elem) {
    final elemContainer = DivElement();
    elemContainer.append(elem);
    final endPage = DivElement();
    endPage.style
      ..display = "block"
      ..clear = "both";
    elemContainer.append(endPage);
    this._page.append(elemContainer);
  }

  /// Adds a set of controls, side by side.
  void addControlBoxes(List<String> ids) {
    final table = TableElement()..id = "shellTable";
    table.style
      ..width = "100%"
      ..padding = "0px"
      ..marginLeft = "auto"
      ..marginRight = "auto";
    this._page.append(table);
    final bottomRow = table.addRow();
    bottomRow.addCell().style
      ..textAlign = "center"
      ..verticalAlign = "top"
      ..marginLeft = "auto"
      ..marginRight = "auto";
    for (int i = 0; i < ids.length; i++) {
      final ctrlBlock = DivElement()
        ..id = ids[i]
        ..style.textAlign = "left"
        ..style.verticalAlign = "top";
      final cell = bottomRow.addCell();
      cell.style
        ..textAlign = "center"
        ..verticalAlign = "top"
        ..marginLeft = "auto"
        ..marginRight = "auto";
      cell.append(ctrlBlock);
    }
  }

  /// Constructs the paragraph tokenizer if the tokenizer hasn't been setup yet.
  /// The paragraph tokenizer breaks up a paragraph to label tokens for
  /// bold, italic, code, links, and normal.
  ///
  /// - For bold text use: `*Bold Text*`
  /// - For italic text use: `_Italic Text_`
  /// - For a link use: `[Title|URL]`
  ///   (The URL is optional for links internal to the page)
  /// - For code use: "`Code`"
  ///   (This code is not color coded and for short snippets like identifiers)
  Tokenizer _setupParTokenizer() {
    Tokenizer? tok = this._parTokenizer;
    if (tok != null) return tok;
    tok = Tokenizer();
    tok.start("Start");
    tok.join("Start", "Bold")
      ..addSet("*")
      ..consume = true;
    tok.join("Bold", "Bold").addNot().addSet("*");
    tok.join("Bold", "BoldEnd")
      ..addSet("*")
      ..consume = true;
    tok.join("Start", "Italic")
      ..addSet("_")
      ..consume = true;
    tok.join("Italic", "Italic").addNot().addSet("_");
    tok.join("Italic", "ItalicEnd")
      ..addSet("_")
      ..consume = true;
    tok.join("Start", "Code")
      ..addSet("`")
      ..consume = true;
    tok.join("Code", "Code").addNot().addSet("`");
    tok.join("Code", "CodeEnd")
      ..addSet("`")
      ..consume = true;
    tok.join("Start", "LinkHead")
      ..addSet("[")
      ..consume = true;
    tok.join("LinkHead", "LinkTail").addSet("|");
    tok.join("LinkHead", "LinkEnd")
      ..addSet("]")
      ..consume = true;
    tok.join("LinkHead", "LinkHead").addNot().addSet("|]");
    tok.join("LinkTail", "LinkEnd")
      ..addSet("]")
      ..consume = true;
    tok.join("LinkTail", "LinkTail").addNot().addSet("|]");
    tok.join("Start", "Other").addAll();
    tok.join("Other", "Other").addNot().addSet("*_`[");
    tok.setToken("BoldEnd", "Bold");
    tok.setToken("ItalicEnd", "Italic");
    tok.setToken("CodeEnd", "Code");
    tok.setToken("LinkEnd", "Link");
    tok.setToken("Other", "Other");
    this._parTokenizer = tok;
    return tok;
  }
}

/// A parser for coloring plain code.
class PlainParser extends CodeParser {
  /// Creates a new plain parser.
  PlainParser() : super._("plain");

  /// Adds color for the given plain code.
  @override
  void parse(List<String> lines) {
    this._lineList = [];
    final String code = lines.join("\n");
    this.addLineParts(code, "#111");
  }

  /// Implmented but has no effect for the plain parser.
  @override
  void processToken(Token token) {
    // Do Nothing
  }

  /// Implmented but has no effect for the plain parser.
  @override
  Tokenizer? createTokenizer() {
    // Do Nothing
    return null;
  }
}

/// The handler called when the selection is changed.
typedef radioSelectedHndl = void Function();

/// A group of radio buttons.
class RadioGroup {
  /// The name of the element for the radio button group.
  String _elemId;

  /// Indicates if the group should be kept in the URL.
  bool _keepInURL;

  /// The element to fill with radio buttons.
  Element _elem;

  /// Creates a new radio button group in the element with the given [elemId] name.
  factory RadioGroup(String elemId, [bool keepInURL = true]) {
    final Element? elem = document.getElementById(elemId);
    if (elem == null) throw Exception('Failed to find $elemId for RadioGroup');
    return RadioGroup._(elemId, keepInURL, elem);
  }

  /// Creates a new radio button group.
  RadioGroup._(this._elemId, this._keepInURL, this._elem);

  /// Adds a new radio button to this group.
  void add(String text, radioSelectedHndl hndl, [bool selectedByDefault = false]) {
    // ignore: unnecessary_null_comparison
    if (this._elem == null) return;
    bool itemIsChecked = false;
    final String? selectedItem = Uri.base.queryParameters[this._elemId];
    if (selectedItem == null) {
      if (selectedByDefault) {
        itemIsChecked = true;
        hndl();
        this._updateUrl(text);
      }
    } else if (selectedItem == text) {
      itemIsChecked = true;
      hndl();
    }
    final LabelElement label = LabelElement()..style.whiteSpace = 'nowrap';
    this._elem.children.add(label);
    final RadioButtonInputElement checkBox = RadioButtonInputElement()
      ..checked = itemIsChecked
      ..name = this._elemId;
    checkBox.onChange.listen((_) {
      if (checkBox.checked ?? false) {
        hndl();
        this._updateUrl(text);
      }
    });
    label.children.add(checkBox);
    final SpanElement span = SpanElement()..text = text;
    label.children.add(span);
    this._elem.children.add(BRElement());
  }

  /// Updates the URL for changes in the radio group.
  void _updateUrl(String text) {
    if (!this._keepInURL) return;
    final Uri current = Uri.base;
    final Map<String, String> parameters = Map<String, String>.from(current.queryParameters);
    parameters[this._elemId] = text;
    final Uri newUrl = current.replace(queryParameters: parameters);
    window.history.replaceState('', '', newUrl.toString());
  }
}

/// A parser for coloring HTML code.
class HTMLParser extends CodeParser {
  /// Creates a new HTML parser.
  HTMLParser() : super._("html");

  /// Parses HTML code.
  @override
  void processToken(Token token) {
    switch (token.name) {
      case "Attr":
        this.addLineParts(token.text, "#911");
        this.addLineParts("=", "#111");
        break;
      case "Id":
        this.addLineParts(token.text, "#111");
        break;
      case "Other":
        this.addLineParts(token.text, "#111");
        break;
      case "Reserved":
        this.addLineParts(token.text, "#119");
        break;
      case "String":
        this.addLineParts(token.text, "#171");
        break;
      case "Symbol":
        this.addLineParts(token.text, "#616");
        break;
    }
  }

  /// Constructs the HTML code tokenizer.
  /// The HTML code tokenizer breaks up code to
  /// label tokens to color the code appropriately.
  @override
  Tokenizer? createTokenizer() {
    final Tokenizer tok = Tokenizer();
    tok.start("Start");
    tok.join("Start", "Id")
      ..addSet("_")
      ..addRange("a", "z")
      ..addRange("A", "Z");
    tok.join("Id", "Id")
      ..addSet("_")
      ..addRange("0", "9")
      ..addRange("a", "z")
      ..addRange("A", "Z");
    tok.join("Id", "Attr")
      ..addSet("=")
      ..consume = true;
    tok.join("Start", "Sym").addSet("</\\-!>=");
    tok.join("Sym", "Sym").addSet("</\\-!>=");
    tok.join("Start", "OpenStr").addSet("\"");
    tok.join("OpenStr", "CloseStr").addSet("\"");
    tok.join("OpenStr", "EscStr").addSet("\\");
    tok.join("EscStr", "OpenStr").addSet("\"");
    tok.join("OpenStr", "OpenStr").addAll();
    tok.join("Start", "Other").addAll();
    tok.join("Other", "Other").addNot()
      ..addSet("</\\-!>=_\"")
      ..addRange("a", "z")
      ..addRange("A", "Z");
    tok.setToken("Sym", "Symbol");
    tok.setToken("CloseStr", "String");
    tok
        .setToken("Id", "Id")
        .replace("Reserved", ["DOCTYPE", "html", "head", "meta", "link", "title", "body", "script"]);
    tok.setToken("Attr", "Attr");
    tok.setToken("Other", "Other");
    return tok;
  }
}

/// A parser for coloring GLSL code.
class GLSLParser extends CodeParser {
  /// Creates a new GLSL parser.
  GLSLParser() : super._("glsl");

  /// Parses GLSL code.
  @override
  void processToken(Token token) {
    switch (token.name) {
      case "Builtin":
        this.addLineParts(token.text, "#411");
        break;
      case "Comment":
        this.addLineParts(token.text, "#777");
        break;
      case "Id":
        this.addLineParts(token.text, "#111");
        break;
      case "Num":
        this.addLineParts(token.text, "#191");
        break;
      case "Preprocess":
        this.addLineParts(token.text, "#737");
        break;
      case "Reserved":
        this.addLineParts(token.text, "#119");
        break;
      case "Symbol":
        this.addLineParts(token.text, "#611");
        break;
      case "Type":
        this.addLineParts(token.text, "#171");
        break;
      case "Whitespace":
        this.addLineParts(token.text, "#111");
        break;
    }
  }

  /// Constructs the HTML code tokenizer.
  /// The HTML code tokenizer breaks up code to
  /// label tokens to color the code appropriately.
  @override
  Tokenizer? createTokenizer() {
    final Tokenizer tok = Tokenizer();
    tok.start("Start");
    tok.join("Start", "Id")
      ..addSet("_")
      ..addRange("a", "z")
      ..addRange("A", "Z");
    tok.join("Id", "Id")
      ..addSet("_")
      ..addRange("0", "9")
      ..addRange("a", "z")
      ..addRange("A", "Z");
    tok.join("Start", "Int").addRange("0", "9");
    tok.join("Int", "Int").addRange("0", "9");
    tok.join("Int", "FloatDot").addSet(".");
    tok.join("FloatDot", "Float").addRange("0", "9");
    tok.join("Float", "Float").addRange("0", "9");
    tok.join("Start", "Sym").addSet("<>{}()[]\\-+*%!&|=.,?:;");
    tok.join("Sym", "Sym").addSet("<>{}()[]\\-+*%!&|=.,?:;");
    tok.join("Start", "Slash").addSet("/");
    tok.join("Slash", "Comment").addSet("/");
    tok.join("Slash", "Sym").addAll();
    tok.join("Comment", "EndComment").addSet("\n");
    tok.join("Comment", "Comment").addNot().addSet("\n");
    tok.join("Start", "Preprocess").addSet("#");
    tok.join("Preprocess", "Preprocess").addNot().addSet("\n");
    tok.join("Preprocess", "EndPreprocess").addSet("\n");
    tok.join("Start", "Whitespace").addSet(" \n\t");
    tok.join("Whitespace", "Whitespace").addSet(" \n\t");
    tok.setToken("Int", "Num");
    tok.setToken("Float", "Num");
    tok.setToken("Sym", "Symbol");
    tok.setToken("EndComment", "Comment");
    tok.setToken("EndPreprocess", "Preprocess");
    tok.setToken("Whitespace", "Whitespace");
    tok.setToken("Id", "Id")
      ..replace("Type", [
        "float",
        "double",
        "int",
        "void",
        "bool",
        "true",
        "false",
        "mat2",
        "mat3",
        "mat4",
        "dmat2",
        "dmat3",
        "dmat4",
        "mat2x2",
        "mat2x3",
        "mat2x4",
        "dmat2x2",
        "dmat2x3",
        "dmat2x4",
        "mat3x2",
        "mat3x3",
        "mat3x4",
        "dmat3x2",
        "dmat3x3",
        "dmat3x4",
        "mat4x2",
        "mat4x3",
        "mat4x4",
        "dmat4x2",
        "dmat4x3",
        "dmat4x4",
        "vec2",
        "vec3",
        "vec4",
        "ivec2",
        "ivec3",
        "ivec4",
        "bvec2",
        "bvec3",
        "bvec4",
        "dvec2",
        "dvec3",
        "dvec4",
        "uint",
        "uvec2",
        "uvec3",
        "uvec4",
        "sampler1D",
        "sampler2D",
        "sampler3D",
        "samplerCube",
        "sampler1DShadow",
        "sampler2DShadow",
        "samplerCubeShadow",
        "sampler1DArray",
        "sampler2DArray",
        "sampler1DArrayShadow",
        "sampler2DArrayShadow",
        "isampler1D",
        "isampler2D",
        "isampler3D",
        "isamplerCube",
        "isampler1DArray",
        "isampler2DArray",
        "usampler1D",
        "usampler2D",
        "usampler3D",
        "usamplerCube",
        "usampler1DArray",
        "usampler2DArray",
        "sampler2DRect",
        "sampler2DRectShadow",
        "isampler2DRect",
        "usampler2DRect",
        "samplerBuffer",
        "isamplerBuffer",
        "usamplerBuffer",
        "sampler2DMS",
        "isampler2DMS",
        "usampler2DMS",
        "sampler2DMSArray",
        "isampler2DMSArray",
        "usampler2DMSArray",
        "samplerCubeArray",
        "samplerCubeArrayShadow",
        "isamplerCubeArray",
        "usamplerCubeArray"
      ])
      ..replace("Reserved", [
        "attribute",
        "break",
        "case",
        "centroid",
        "const",
        "continue",
        "default",
        "discard",
        "do",
        "else",
        "flat",
        "for",
        "highp",
        "if",
        "in",
        "inout",
        "invariant",
        "layout",
        "lowp",
        "mediump",
        "noperspective",
        "out",
        "patch",
        "precision",
        "return",
        "sample",
        "smooth",
        "struct",
        "subroutine",
        "switch",
        "uniform",
        "varying",
        "while"
      ])
      ..replace("Builtin", ["gl_FragColor", "gl_Position"]);
    return tok;
  }
}

/// A parser for coloring Dart code.
class DartParser extends CodeParser {
  /// Creates a new Dart parser.
  DartParser() : super._("dart");

  /// Parses Dart code.
  @override
  void processToken(Token token) {
    switch (token.name) {
      case "Class":
        this.addLineParts(token.text, "#551");
        break;
      case "Comment":
        this.addLineParts(token.text, "#777");
        break;
      case "Id":
        this.addLineParts(token.text, "#111");
        break;
      case "Num":
        this.addLineParts(token.text, "#191");
        break;
      case "Reserved":
        this.addLineParts(token.text, "#119");
        break;
      case "String":
        this.addLineParts(token.text, "#171");
        break;
      case "Symbol":
        this.addLineParts(token.text, "#616");
        break;
      case "Type":
        this.addLineParts(token.text, "#B11");
        break;
      case "Whitespace":
        this.addLineParts(token.text, "#111");
        break;
    }
  }

  /// Constructs the Dart code tokenizer.
  /// The Dart code tokenizer breaks up code to
  /// label tokens to color the code appropriately.
  @override
  Tokenizer? createTokenizer() {
    final Tokenizer tok = Tokenizer();
    tok.start("Start");
    tok.join("Start", "Id")
      ..addSet("_")
      ..addRange("a", "z")
      ..addRange("A", "Z");
    tok.join("Id", "Id")
      ..addSet("_")
      ..addRange("0", "9")
      ..addRange("a", "z")
      ..addRange("A", "Z");
    tok.join("Start", "Int").addRange("0", "9");
    tok.join("Int", "Int").addRange("0", "9");
    tok.join("Int", "FloatDot").addSet(".");
    tok.join("FloatDot", "Float").addRange("0", "9");
    tok.join("Float", "Float").addRange("0", "9");
    tok.join("Start", "Sym").addSet("<>{}()\\-+*%!&|=.,?:;");
    tok.join("Sym", "Sym").addSet("<>{}()\\-+*%!&|=.,?:;");
    tok.join("Start", "OpenDoubleStr").addSet("\"");
    tok.join("OpenDoubleStr", "CloseDoubleStr").addSet("\"");
    tok.join("OpenDoubleStr", "EscDoubleStr").addSet("\\");
    tok.join("EscDoubleStr", "OpenDoubleStr").addSet("\"");
    tok.join("OpenDoubleStr", "OpenDoubleStr").addAll();
    tok.join("Start", "OpenSingleStr").addSet("'");
    tok.join("OpenSingleStr", "CloseSingleStr").addSet("'");
    tok.join("OpenSingleStr", "EscSingleStr").addSet("\\");
    tok.join("EscSingleStr", "OpenSingleStr").addSet("'");
    tok.join("OpenSingleStr", "OpenSingleStr").addAll();
    tok.join("Start", "Slash").addSet("/");
    tok.join("Slash", "Comment").addSet("/");
    tok.join("Comment", "EndComment").addSet("\n");
    tok.join("Comment", "Comment").addNot().addSet("\n");
    tok.join("Slash", "MLComment").addSet("*");
    tok.join("MLComment", "MLCStar").addSet("*");
    tok.join("MLCStar", "MLComment").addNot().addSet("*");
    tok.join("MLCStar", "EndComment").addSet("/");
    tok.join("Start", "Whitespace").addSet(" \n\t");
    tok.join("Whitespace", "Whitespace").addSet(" \n\t");
    tok.setToken("Int", "Num");
    tok.setToken("Float", "Num");
    tok.setToken("Sym", "Symbol");
    tok.setToken("CloseDoubleStr", "String");
    tok.setToken("CloseSingleStr", "String");
    tok.setToken("EndComment", "Comment");
    tok.setToken("Whitespace", "Whitespace");
    tok.setToken("Id", "Id")
      ..replace("Class", [
        "Constant",
        "Depth",
        "Entity",
        "EntityPass",
        "Math",
        "Matrix4",
        "Movers",
        "Rotator",
        "Scenes",
        "Shapes",
        "Techniques",
        "three_dart"
      ])
      ..replace("Type", [
        "bool",
        "double",
        "dynamic",
        "false",
        "int",
        "List",
        "Map",
        "null",
        "num",
        "Object",
        "String",
        "this",
        "true",
        "var",
        "void"
      ])
      ..replace("Reserved", [
        "abstract",
        "as",
        "assert",
        "async",
        "await",
        "break",
        "case",
        "catch",
        "class",
        "continue",
        "const",
        "default",
        "deferred",
        "do",
        "else",
        "enum",
        "export",
        "extends",
        "external",
        "factory",
        "final",
        "finally",
        "for",
        "get",
        "if",
        "implements",
        "import",
        "in",
        "is",
        "library",
        "new",
        "operator",
        "part",
        "rethrow",
        "return",
        "set",
        "static",
        "super",
        "switch",
        "sync",
        "throw",
        "try",
        "typedef",
        "with",
        "while",
        "yield"
      ]);
    return tok;
  }
}

/// An abstract class for parsing code into colored lines of code.
abstract class CodeParser {
  final String _name;
  HtmlEscape? _escape;
  Tokenizer? _tokenizer;
  List<List<DivElement>> _lineList = [];

  /// Constructs a new code parser.
  /// The lowercase [name] of the type of code to parse, e.g. html, dart, or glsl
  CodeParser._(this._name) {
    this._escape = const HtmlEscape(HtmlEscapeMode.element);
    this._tokenizer = null;
    this._lineList = [];
  }

  /// The name of type of code this parser can parse.
  String get name => this._name;

  /// The parsed and colored code grouped by lines.
  List<List<DivElement>> get lineList => _lineList;

  /// Escapes the given [text] for html.
  String _escapeText(String text) => this._escape?.convert(text).replaceAll(" ", "&nbsp;") ?? text;

  /// Adds line parts to the list of code lines, the [lineList].
  /// The given [code] to add as lines in the given [color].
  void addLineParts(String code, String color) {
    if (this._lineList.isEmpty) this._lineList.add([]);
    final List<String> lines = code.split("\n");
    bool first = true;
    for (final String line in lines) {
      if (first) {
        first = false;
      } else {
        this._lineList.add([]);
      }
      final DivElement partElem = DivElement()
        ..className = "codePart"
        ..innerHtml = this._escapeText(line)
        ..style.color = color;
      this._lineList.last.add(partElem);
    }
  }

  /// Parses the given lines into colored code.
  /// This clears the previously parsed lines.
  void parse(List<String> lines) {
    this._lineList = [];
    final String code = lines.join("\n");
    var tok = this._tokenizer;
    if (tok == null) {
      tok = this.createTokenizer();
      this._tokenizer = tok;
    }
    if (tok != null) {
      // ignore: prefer_foreach
      for (final Token token in tok.tokenize(code)) {
        this.processToken(token);
      }
    }
  }

  /// Processes a token during a parse.
  /// This needs to be implemented by the inheriting class.
  void processToken(Token token);

  /// Creates the tokenizer to parse the code with.
  /// This needs to be implemented by the inheriting class.
  Tokenizer? createTokenizer();
}

/// The handler called when the selection is changed.
typedef checkSelectedHndl = void Function(bool selected);

/// A group of check boxes.
class CheckGroup {
  /// The name of the element for the check group.
  String _elemId;

  /// Indicates if the group should be kept in the URL.
  bool _keepInURL;

  /// The element to fill with check boxes.
  Element _elem;

  /// The list of checkbox elements;
  final List<CheckboxInputElement> _checks = [];

  /// Creates a new check box group in the element with the given [elemId] name.
  factory CheckGroup(String elemId, [bool keepInURL = true]) {
    final Element? elem = document.getElementById(elemId);
    if (elem == null) throw Exception('Failed to find $elemId for CheckGroup');
    return CheckGroup._(elemId, keepInURL, elem);
  }

  /// Creates a new check box group in the element.
  CheckGroup._(this._elemId, this._keepInURL, this._elem);

  /// Adds a new check box to this group and the method to call when the check box is changed.
  void add(String text, checkSelectedHndl hndl, [bool checkedByDefault = false]) {
    bool urlNeedsUpdate = false;
    final int index = this._checks.length;
    final String? selectedItems = Uri.base.queryParameters[this._elemId];
    bool itemIsChecked;
    if ((selectedItems == null) || (selectedItems.length <= index)) {
      itemIsChecked = checkedByDefault;
      urlNeedsUpdate = true;
    } else {
      itemIsChecked = selectedItems[index] == '1';
    }
    hndl(itemIsChecked);
    final LabelElement label = LabelElement()..style.whiteSpace = 'nowrap';
    this._elem.children.add(label);
    final CheckboxInputElement checkBox = CheckboxInputElement()..checked = itemIsChecked;
    checkBox.onChange.listen((_) {
      final checked = checkBox.checked ?? false;
      hndl(checked);
      this._updateUrl(index, checked);
    });
    label.children.add(checkBox);
    final SpanElement span = SpanElement()..text = text;
    label.children.add(span);
    this._elem.children.add(BRElement());
    this._checks.add(checkBox);
    if (urlNeedsUpdate) this._updateUrl(index, itemIsChecked);
  }

  /// Updates the URL for changes in the check boxes.
  void _updateUrl(int index, bool checked) {
    if (!this._keepInURL) return;
    String selectedItems = Uri.base.queryParameters[this._elemId] ?? '';
    if (selectedItems.length < index) selectedItems = selectedItems.padRight(index - selectedItems.length + 1, '0');
    String result = '';
    if (index > 0) result += selectedItems.substring(0, index);
    result += (){
      if (checked) {
        return '1';
      } else {
        return '0';
      }
    }();
    if (index + 1 < selectedItems.length) result += selectedItems.substring(index + 1);
    final Uri current = Uri.base;
    final Map<String, String> parameters = Map<String, String>.from(current.queryParameters);
    parameters[this._elemId] = result;
    final Uri newUrl = current.replace(queryParameters: parameters);
    window.history.replaceState('', '', newUrl.toString());
  }
}

/// The handler called when a button is clicked.
typedef buttonClickedHndl = void Function();

/// A group of buttons.
class ButtonGroup {
  /// The element to fill with buttons.
  Element _elem;

  /// The list of button elements;
  final List<ButtonElement> _buttons = [];

  /// Creates a new button group in the element with the given [elemId] name.
  factory ButtonGroup(String elemId) {
    final Element? elem = document.getElementById(elemId);
    if (elem == null) throw Exception('Failed to find $elemId for ButtonGroup');
    return ButtonGroup._(elem);
  }

  ButtonGroup._(this._elem);

  /// Adds a new button to this group and the method to call when the button is clicked.
  void add(String innerHtml, buttonClickedHndl hndl) {
    final ButtonElement button = ButtonElement()
      ..style.whiteSpace = 'nowrap'
      ..innerHtml = innerHtml
      ..onClick.listen((_) => hndl());
    this._elem.children.add(button);
    this._elem.children.add(BRElement());
    this._buttons.add(button);
  }
}
