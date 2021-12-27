import 'package:three_dart/parser/calculator.dart';
import 'package:three_dart/parser/diff.dart';
import 'package:three_dart/parser/grammar.dart';
import 'package:three_dart/parser/parser.dart';
import 'package:three_dart/parser/simple.dart';
import 'package:three_dart/parser/tokenizer.dart';

// TODO fix test
void main() {
  final test = TestTool();
  test.run(
    (final args) {
      args.log('diff00');
      args.checkDiff(['cat'], ['cat'], [' cat']);
      args.checkDiff(['cat'], ['dog'], ['-cat', '+dog']);
      args.checkDiff(['A', 'G', 'T', 'A', 'C', 'G', 'C', 'A'], ['T', 'A', 'T', 'G', 'C'],
          ['-A', '-G', ' T', ' A', '-C', '+T', ' G', ' C', '-A']);
      args.checkDiff(['cat', 'dog'], ['cat', 'horse'], [' cat', '-dog', '+horse']);
      args.checkDiff(['cat', 'dog'], ['cat', 'horse', 'dog'], [' cat', '+horse', ' dog']);
      args.checkDiff(['cat', 'dog', 'pig'], ['cat', 'horse', 'dog'], [' cat', '+horse', ' dog', '-pig']);
      args.checkDiff(['mike', 'ted', 'mark', 'jim'], ['ted', 'mark', 'bob', 'bill'],
          ['-mike', ' ted', ' mark', '-jim', '+bob', '+bill']);
      args.checkDiff(['k', 'i', 't', 't', 'e', 'n'], ['s', 'i', 't', 't', 'i', 'n', 'g'],
          ['-k', '+s', ' i', ' t', ' t', '-e', '+i', ' n', '+g']);
      args.checkDiff(['s', 'a', 't', 'u', 'r', 'd', 'a', 'y'], ['s', 'u', 'n', 'd', 'a', 'y'],
          [' s', '-a', '-t', ' u', '-r', '+n', ' d', ' a', ' y']);
      args.checkDiff(['s', 'a', 't', 'x', 'r', 'd', 'a', 'y'], ['s', 'u', 'n', 'd', 'a', 'y'],
          [' s', '-a', '-t', '-x', '-r', '+u', '+n', ' d', ' a', ' y']);
      args.checkDiff([
        'func A() int {',
        '  return 10',
        '}',
        '',
        'func C() int {',
        '  return 12',
        '}'
      ], [
        'func A() int {',
        '  return 10',
        '}',
        '',
        'func B() int {',
        '  return 11',
        '}',
        '',
        'func C() int {',
        '  return 12',
        '}'
      ], [
        ' func A() int {',
        '   return 10',
        ' }',
        ' ',
        '+func B() int {',
        '+  return 11',
        '+}',
        '+',
        ' func C() int {',
        '   return 12',
        ' }'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('grammar00');
      final gram = Grammar();
      gram.start("defSet");
      gram.newRule("defSet").addTerm("defSet").addTerm("def");
      gram.newRule("defSet");
      gram.newRule("def").addTerm("stateDef").addTerm("defBody");
      gram.newRule("stateDef").addToken("closeAngle");
      gram.newRule("stateDef");
      gram.newRule("defBody").addTerm("stateOrTokenID");
      gram
          .newRule("defBody")
          .addTerm("defBody")
          .addToken("colon")
          .addToken("arrow")
          .addTerm("stateOrTokenID");
      gram.newRule("stateOrTokenID").addTerm("stateID");
      gram.newRule("stateOrTokenID").addTerm("tokenID");
      gram.newRule("stateID").addToken("openParen").addToken("id").addToken("closeParen");
      gram.newRule("tokenID").addToken("openBracket").addToken("id").addToken("closeBracket");
      args.checkGrammar(gram, [
        '> <defSet>',
        '<defSet> → <defSet> <def>',
        '<defSet> → ',
        '<def> → <stateDef> <defBody>',
        '<stateDef> → [closeAngle]',
        '<stateDef> → ',
        '<defBody> → <stateOrTokenID>',
        '<defBody> → <defBody> [colon] [arrow] <stateOrTokenID>',
        '<stateOrTokenID> → <stateID>',
        '<stateOrTokenID> → <tokenID>',
        '<stateID> → [openParen] [id] [closeParen]',
        '<tokenID> → [openBracket] [id] [closeBracket]'
      ]);
      args.checkTermFirst(gram, 'defSet', ['[closeAngle]', '[openParen]', '[openBracket]']);
      args.checkTermFollow(gram, 'defSet', ['[closeAngle]', '[openParen]', '[openBracket]']);
      args.checkTermFirst(gram, 'def', ['[closeAngle]', '[openParen]', '[openBracket]']);
      args.checkTermFollow(gram, 'def', ['[closeAngle]', '[openParen]', '[openBracket]']);
      args.checkTermFirst(gram, 'stateDef', ['[closeAngle]', '[openParen]', '[openBracket]']);
      args.checkTermFollow(gram, 'stateDef', ['[openParen]', '[openBracket]']);
      args.checkTermFirst(gram, 'defBody', ['[openParen]', '[openBracket]']);
      args.checkTermFollow(gram, 'defBody', ['[closeAngle]', '[openParen]', '[openBracket]', '[colon]']);
      args.checkTermFirst(gram, 'stateOrTokenID', ['[openParen]', '[openBracket]']);
      args.checkTermFollow(
          gram, 'stateOrTokenID', ['[closeAngle]', '[openParen]', '[openBracket]', '[colon]']);
      args.checkTermFirst(gram, 'stateID', ['[openParen]']);
      args.checkTermFollow(gram, 'stateID', ['[closeAngle]', '[openParen]', '[openBracket]', '[colon]']);
      args.checkTermFirst(gram, 'tokenID', ['[openBracket]']);
      args.checkTermFollow(gram, 'tokenID', ['[closeAngle]', '[openParen]', '[openBracket]', '[colon]']);
    },
  );
  test.run(
    (final args) {
      args.log('grammar01');
      final gram = Grammar();
      final rule0 = gram.newRule('E');
      final rule1 = gram.newRule('E').addTerm("E").addToken("+").addTerm("E");
      final rule2 = gram.newRule('E').addTerm("E").addToken("+").addTerm("E").addTrigger('add');
      final rule3 = gram.newRule('E').addTerm("E").addToken("+").addTrigger('add').addTerm("E");
      final rule4 = gram.newRule('E').addTrigger('add').addTerm("E").addToken("+").addTerm("E");
      args.checkRuleString(rule0, -1, '<E> → ');
      args.checkRuleString(rule0, 0, '<E> → •');
      args.checkRuleString(rule0, 1, '<E> → ');
      args.checkRuleString(rule1, -1, '<E> → <E> [+] <E>');
      args.checkRuleString(rule1, 0, '<E> → • <E> [+] <E>');
      args.checkRuleString(rule1, 1, '<E> → <E> • [+] <E>');
      args.checkRuleString(rule1, 2, '<E> → <E> [+] • <E>');
      args.checkRuleString(rule1, 3, '<E> → <E> [+] <E> •');
      args.checkRuleString(rule1, 4, '<E> → <E> [+] <E>');
      args.checkRuleString(rule2, -1, '<E> → <E> [+] <E> {add}');
      args.checkRuleString(rule2, 0, '<E> → • <E> [+] <E> {add}');
      args.checkRuleString(rule2, 1, '<E> → <E> • [+] <E> {add}');
      args.checkRuleString(rule2, 2, '<E> → <E> [+] • <E> {add}');
      args.checkRuleString(rule2, 3, '<E> → <E> [+] <E> • {add}');
      args.checkRuleString(rule2, 4, '<E> → <E> [+] <E> {add}');
      args.checkRuleString(rule3, -1, '<E> → <E> [+] {add} <E>');
      args.checkRuleString(rule3, 0, '<E> → • <E> [+] {add} <E>');
      args.checkRuleString(rule3, 1, '<E> → <E> • [+] {add} <E>');
      args.checkRuleString(rule3, 2, '<E> → <E> [+] • {add} <E>');
      args.checkRuleString(rule3, 3, '<E> → <E> [+] {add} <E> •');
      args.checkRuleString(rule3, 4, '<E> → <E> [+] {add} <E>');
      args.checkRuleString(rule4, -1, '<E> → {add} <E> [+] <E>');
      args.checkRuleString(rule4, 0, '<E> → • {add} <E> [+] <E>');
      args.checkRuleString(rule4, 1, '<E> → {add} <E> • [+] <E>');
      args.checkRuleString(rule4, 2, '<E> → {add} <E> [+] • <E>');
      args.checkRuleString(rule4, 3, '<E> → {add} <E> [+] <E> •');
      args.checkRuleString(rule4, 4, '<E> → {add} <E> [+] <E>');
    },
  );
  test.run(
    (final args) {
      args.log('tokenizer00');
      final Tokenizer tok = Tokenizer();
      tok.start("start");
      tok.join("start", "id").addRange("a", "z");
      tok.join("id", "id").addRange("a", "z");
      tok.join("start", "add").addSet("+");
      tok.join("start", "mul").addSet("*");
      tok.join("start", "open").addSet("(");
      tok.join("start", "close").addSet(")");
      tok.join("start", "space").addSet(" ");
      tok.join("space", "space").addSet(" ");
      tok.setToken("add", "[add]");
      tok.setToken("mul", "[mul]");
      tok.setToken("open", "[open]");
      tok.setToken("close", "[close]");
      tok.setToken("id", "[id]");
      tok.setToken("space", "[space]").consume();
      args.checkTok(tok, "hello world", ['[id]:5:"hello"', '[id]:11:"world"']);
      args.checkTok(
          tok, "a + b * c", ['[id]:1:"a"', '[add]:3:"+"', '[id]:5:"b"', '[mul]:7:"*"', '[id]:9:"c"']);
      args.checkTok(
          tok, "(a + b)", ['[open]:1:"("', '[id]:2:"a"', '[add]:4:"+"', '[id]:6:"b"', '[close]:7:")"']);
      args.checkTok(tok, "a + (b * c) + d", [
        '[id]:1:"a"',
        '[add]:3:"+"',
        '[open]:5:"("',
        '[id]:6:"b"',
        '[mul]:8:"*"',
        '[id]:10:"c"',
        '[close]:11:")"',
        '[add]:13:"+"',
        '[id]:15:"d"'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('tokenizer01');
      final Tokenizer tok = Tokenizer();
      tok.start("start");
      //         .--a--(a1)--b--(b1)[ab]--c--(c2)--d--(d2)--f--(f1)[abcdf]
      // start--{---c--(c1)--d--(d1)[cd]
      //         '--e--(e1)[e]
      tok.join("start", "(a1)").addSet("a");
      tok.join("(a1)", "(b1)").addSet("b");
      tok.join("(b1)", "(c2)").addSet("c");
      tok.join("(c2)", "(d2)").addSet("d");
      tok.join("(d2)", "(f1)").addSet("f");
      tok.join("start", "(c1)").addSet("c");
      tok.join("(c1)", "(d1)").addSet("d");
      tok.join("start", "(e1)").addSet("e");
      tok.setToken("(b1)", "[ab]");
      tok.setToken("(d1)", "[cd]");
      tok.setToken("(f1)", "[abcdf]");
      tok.setToken("(e1)", "[e]");
      args.checkTok(tok, "abcde", ['[ab]:2:"ab"', '[cd]:4:"cd"', '[e]:5:"e"']);
    },
  );
  test.run(
    (final args) {
      args.log('parser00');
      final Tokenizer tok = Tokenizer();
      tok.start("start");
      tok.join("start", "(").addSet("(");
      tok.join("start", ")").addSet(")");
      tok.join("start", "+").addSet("+");
      tok.join("start", "num").addRange("0", "9");
      tok.join("num", "num").addRange("0", "9");
      tok.setToken("(", "(");
      tok.setToken(")", ")");
      tok.setToken("+", "+");
      tok.setToken("num", "n");
      // 1. E → T
      // 2. E → ( E )
      // 3. T → n
      // 4. T → + T
      // 5. T → T + n
      final Grammar grammar = Grammar();
      grammar.start("E");
      grammar.newRule("E").addTerm("T");
      grammar.newRule("E").addToken("(").addTerm("E").addToken(")");
      grammar.newRule("T").addToken("n");
      grammar.newRule("T").addToken("+").addTerm("T");
      grammar.newRule("T").addTerm("T").addToken("+").addToken("n");
      final Parser parser = Parser.fromGrammar(grammar, tok);
      args.checkParser(parser, ["103"], ['─<E>', '  └─<T>', '     └─[n:3:"103"]']);
      args.checkParser(
          parser, ["+2"], ['─<E>', '  └─<T>', '     ├─[+:1:"+"]', '     └─<T>', '        └─[n:2:"2"]']);
      args.checkParser(parser, ["3+4"],
          ['─<E>', '  └─<T>', '     ├─<T>', '     │  └─[n:1:"3"]', '     ├─[+:2:"+"]', '     └─[n:3:"4"]']);
      args.checkParser(parser, [
        "((42+6))"
      ], [
        '─<E>',
        '  ├─[(:1:"("]',
        '  ├─<E>',
        '  │  ├─[(:2:"("]',
        '  │  ├─<E>',
        '  │  │  └─<T>',
        '  │  │     ├─<T>',
        '  │  │     │  └─[n:4:"42"]',
        '  │  │     ├─[+:5:"+"]',
        '  │  │     └─[n:6:"6"]',
        '  │  └─[):7:")"]',
        '  └─[):8:")"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('parser01');
      final Tokenizer tok = Tokenizer();
      tok.start("start");
      tok.join("start", "(").addSet("(");
      tok.join("start", ")").addSet(")");
      tok.setToken("(", "(");
      tok.setToken(")", ")");
      // 1. X → ( X )
      // 2. X → ( )
      final Grammar grammar = Grammar();
      grammar.start("X");
      grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
      grammar.newRule("X").addToken("(").addToken(")");
      final Parser parser = Parser.fromGrammar(grammar, tok);
      args.checkParser(parser, ["()"], ['─<X>', '  ├─[(:1:"("]', '  └─[):2:")"]']);
      args.checkParser(parser, [
        "((()))"
      ], [
        '─<X>',
        '  ├─[(:1:"("]',
        '  ├─<X>',
        '  │  ├─[(:2:"("]',
        '  │  ├─<X>',
        '  │  │  ├─[(:3:"("]',
        '  │  │  └─[):4:")"]',
        '  │  └─[):5:")"]',
        '  └─[):6:")"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('parser02');
      final Tokenizer tok = Tokenizer();
      tok.start("start");
      tok.join("start", "(").addSet("(");
      tok.join("start", ")").addSet(")");
      tok.setToken("(", "(");
      tok.setToken(")", ")");
      // 1. X → ( X )
      // 2. X → 𝜀
      final Grammar grammar = Grammar();
      grammar.start("X");
      grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
      grammar.newRule("X");
      final Parser parser = Parser.fromGrammar(grammar, tok);
      args.checkParser(parser, [""], ['─<X>']);
      args.checkParser(parser, ["()"], ['─<X>', '  ├─[(:1:"("]', '  ├─<X>', '  └─[):2:")"]']);
      args.checkParser(parser, [
        "((()))"
      ], [
        '─<X>',
        '  ├─[(:1:"("]',
        '  ├─<X>',
        '  │  ├─[(:2:"("]',
        '  │  ├─<X>',
        '  │  │  ├─[(:3:"("]',
        '  │  │  ├─<X>',
        '  │  │  └─[):4:")"]',
        '  │  └─[):5:")"]',
        '  └─[):6:")"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('parser03');
      final Tokenizer tok = Tokenizer();
      tok.start("start");
      tok.join("start", "a").addSet("a");
      tok.join("start", "b").addSet("b");
      tok.join("start", "d").addSet("d");
      tok.setToken("a", "a");
      tok.setToken("b", "b");
      tok.setToken("d", "d");
      // 1. S → b A d S
      // 2. S → 𝜀
      // 3. A → a A
      // 4. A → 𝜀
      final Grammar grammar = Grammar();
      grammar.start("S");
      grammar.newRule("S").addToken("b").addTerm("A").addToken("d").addTerm("S");
      grammar.newRule("S");
      grammar.newRule("A").addToken("a").addTerm("A");
      grammar.newRule("A");
      final Parser parser = Parser.fromGrammar(grammar, tok);
      args.checkParser(parser, ["bd"], ['─<S>', '  ├─[b:1:"b"]', '  ├─<A>', '  ├─[d:2:"d"]', '  └─<S>']);
      args.checkParser(parser, ["bad"],
          ['─<S>', '  ├─[b:1:"b"]', '  ├─<A>', '  │  ├─[a:2:"a"]', '  │  └─<A>', '  ├─[d:3:"d"]', '  └─<S>']);
      args.checkParser(parser, [
        "bdbadbd"
      ], [
        '─<S>',
        '  ├─[b:1:"b"]',
        '  ├─<A>',
        '  ├─[d:2:"d"]',
        '  └─<S>',
        '     ├─[b:3:"b"]',
        '     ├─<A>',
        '     │  ├─[a:4:"a"]',
        '     │  └─<A>',
        '     ├─[d:5:"d"]',
        '     └─<S>',
        '        ├─[b:6:"b"]',
        '        ├─<A>',
        '        ├─[d:7:"d"]',
        '        └─<S>'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('parser04');
      final tok = Tokenizer();
      tok.start("start");
      tok.join("start", "id").addRange("a", "z");
      tok.join("id", "id").addRange("a", "z");
      tok.join("start", "add").addSet("+");
      tok.join("start", "mul").addSet("*");
      tok.join("start", "open").addSet("(");
      tok.join("start", "close").addSet(")");
      tok.join("start", "start")
        ..addSet(" ")
        ..consume = true;
      tok.setToken("add", "+");
      tok.setToken("mul", "*");
      tok.setToken("open", "(");
      tok.setToken("close", ")");
      tok.setToken("id", "id");
      // 1. E → E + E
      // 2. E → E * E
      // 3. E → ( E )
      // 4. E → id
      final grammar = Grammar();
      grammar.start("E");
      grammar.newRule("E").addTerm("E").addToken("+").addTerm("E");
      grammar.newRule("E").addTerm("E").addToken("*").addTerm("E");
      grammar.newRule("E").addToken("(").addTerm("E").addToken(")");
      grammar.newRule("E").addToken("id");
      Parser parser = Parser.fromGrammar(grammar, tok);
      // Test serializing and deserializing too.
      final data = parser.serialize().toString();
      parser = Parser.deserialize(Deserializer(data));
      args.checkParser(parser, ["a"], ['─<E>', '  └─[id:1:"a"]']);
      args.checkParser(parser, [
        "(a + b)"
      ], [
        '─<E>',
        '  ├─[(:1:"("]',
        '  ├─<E>',
        '  │  ├─<E>',
        '  │  │  └─[id:2:"a"]',
        '  │  ├─[+:4:"+"]',
        '  │  └─<E>',
        '  │     └─[id:6:"b"]',
        '  └─[):7:")"]'
      ]);
      args.checkParser(parser, [
        "a + b * c"
      ], [
        '─<E>',
        '  ├─<E>',
        '  │  └─[id:1:"a"]',
        '  ├─[+:3:"+"]',
        '  └─<E>',
        '     ├─<E>',
        '     │  └─[id:5:"b"]',
        '     ├─[*:7:"*"]',
        '     └─<E>',
        '        └─[id:9:"c"]'
      ]);
      args.checkParser(parser, [
        "a + (b * c) + d"
      ], [
        '─<E>',
        '  ├─<E>',
        '  │  └─[id:1:"a"]',
        '  ├─[+:3:"+"]',
        '  └─<E>',
        '     ├─<E>',
        '     │  ├─[(:5:"("]',
        '     │  ├─<E>',
        '     │  │  ├─<E>',
        '     │  │  │  └─[id:6:"b"]',
        '     │  │  ├─[*:8:"*"]',
        '     │  │  └─<E>',
        '     │  │     └─[id:10:"c"]',
        '     │  └─[):11:")"]',
        '     ├─[+:13:"+"]',
        '     └─<E>',
        '        └─[id:15:"d"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('parser05');
      final tok = Tokenizer();
      tok.start("start");
      tok.join("start", "a").addSet("a");
      tok.setToken("a", "a");
      final grammar = Grammar();
      grammar.start("E");
      grammar.newRule("E");
      grammar.newRule("E").addTerm("E").addTerm("T");
      grammar.newRule("T").addToken("a");
      final parser = Parser.fromGrammar(grammar, tok);
      args.checkParser(parser, [
        "aaa"
      ], [
        '─<E>',
        '  ├─<E>',
        '  │  ├─<E>',
        '  │  │  ├─<E>',
        '  │  │  └─<T>',
        '  │  │     └─[a:1:"a"]',
        '  │  └─<T>',
        '  │     └─[a:2:"a"]',
        '  └─<T>',
        '     └─[a:3:"a"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('parser06');
      final Tokenizer tok = Tokenizer();
      tok.start("start");
      tok.joinToToken("start", "*").addSet("*");
      final Grammar grammar = Grammar();
      grammar.start("E");
      grammar.newRule("E");
      grammar.newRule("E").addTerm("T").addTerm("E");
      grammar.newRule("T").addToken("*");
      args.checkParserBuildError(grammar, tok, [
        'Exception: Errors while building parser:',
        'state 0:',
        '  <startTerm> → • <E> [eofToken]',
        '  <E> → •',
        '  <E> → • <T> <E>',
        '  <T> → • [*]',
        '  <E>: goto state 1',
        '  <T>: goto state 2',
        '  [*]: goto state 3',
        'state 1:',
        '  <startTerm> → <E> • [eofToken]',
        'state 2:',
        '  <E> → <T> • <E>',
        '  <E> → •',
        '  <E> → • <T> <E>',
        '  <T> → • [*]',
        '  <E>: goto state 4',
        '  <T>: goto state 2',
        '  [*]: goto state 3',
        'state 3:',
        '  <T> → [*] •',
        'state 4:',
        '  <E> → <T> <E> •',
        '',
        'Infinite goto loop found in term T between the state(s) [2].'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('loader00');
      final Parser parser = Loader.getParser();
      args.checkParser(parser, [
        "()"
      ], [
        'Unexpected item, closeParen:2:")", in state 5. Expected: id.',
        'Unexpected item, eofToken:-1:"eofToken", in state 5. Expected: id.'
      ]);
      args.checkParser(parser, ["(Start)"],
          ['Unexpected item, eofToken:-1:"eofToken", in state 84. Expected: colon, arrow, semicolon.']);
      args.checkParser(parser, [
        "> (Start);"
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─[closeAngle:1:">"]',
        '  │  ├─<stateID>',
        '  │  │  ├─[openParen:3:"("]',
        '  │  │  ├─[id:8:"Start"]',
        '  │  │  ├─[closeParen:9:")"]',
        '  │  │  └─{new.state}',
        '  │  ├─{start.state}',
        '  │  └─<def.state.optional>',
        '  └─[semicolon:10:";"]'
      ]);
      args.checkParser(parser, [
        "> (Start): * => (Any);"
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─[closeAngle:1:">"]',
        '  │  ├─<stateID>',
        '  │  │  ├─[openParen:3:"("]',
        '  │  │  ├─[id:8:"Start"]',
        '  │  │  ├─[closeParen:9:")"]',
        '  │  │  └─{new.state}',
        '  │  ├─{start.state}',
        '  │  └─<def.state.optional>',
        '  │     └─<def.state>',
        '  │        ├─[colon:10:":"]',
        '  │        ├─<matcher.start>',
        '  │        │  ├─[any:12:"*"]',
        '  │        │  └─{match.any}',
        '  │        ├─[arrow:15:"=>"]',
        '  │        ├─<stateID>',
        '  │        │  ├─[openParen:17:"("]',
        '  │        │  ├─[id:20:"Any"]',
        '  │        │  ├─[closeParen:21:")"]',
        '  │        │  └─{new.state}',
        '  │        ├─{join.state}',
        '  │        └─<def.state.optional>',
        '  └─[semicolon:22:";"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('loader01');
      final parser = Loader.getParser();
      args.checkParser(parser, [
        "(O): 'ab' => (AB): 'cde' => (CDE);"
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<stateID>',
        '  │  │  ├─[openParen:1:"("]',
        '  │  │  ├─[id:2:"O"]',
        '  │  │  ├─[closeParen:3:")"]',
        '  │  │  └─{new.state}',
        '  │  └─<def.state>',
        '  │     ├─[colon:4:":"]',
        '  │     ├─<matcher.start>',
        '  │     │  └─<matcher>',
        '  │     │     └─<charSetRange>',
        '  │     │        ├─[string:9:"ab"]',
        '  │     │        └─{match.set}',
        '  │     ├─[arrow:12:"=>"]',
        '  │     ├─<stateID>',
        '  │     │  ├─[openParen:14:"("]',
        '  │     │  ├─[id:16:"AB"]',
        '  │     │  ├─[closeParen:17:")"]',
        '  │     │  └─{new.state}',
        '  │     ├─{join.state}',
        '  │     └─<def.state.optional>',
        '  │        └─<def.state>',
        '  │           ├─[colon:18:":"]',
        '  │           ├─<matcher.start>',
        '  │           │  └─<matcher>',
        '  │           │     └─<charSetRange>',
        '  │           │        ├─[string:24:"cde"]',
        '  │           │        └─{match.set}',
        '  │           ├─[arrow:27:"=>"]',
        '  │           ├─<stateID>',
        '  │           │  ├─[openParen:29:"("]',
        '  │           │  ├─[id:32:"CDE"]',
        '  │           │  ├─[closeParen:33:")"]',
        '  │           │  └─{new.state}',
        '  │           ├─{join.state}',
        '  │           └─<def.state.optional>',
        '  └─[semicolon:34:";"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('loader02');
      final parser = Loader.getParser();
      args.checkParser(parser, [
        "(A)=>[A];",
        "(B)=>[B];"
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  │  ├─<def.set>',
        '  │  ├─<def>',
        '  │  │  ├─{new.def}',
        '  │  │  ├─<stateID>',
        '  │  │  │  ├─[openParen:1:"("]',
        '  │  │  │  ├─[id:2:"A"]',
        '  │  │  │  ├─[closeParen:3:")"]',
        '  │  │  │  └─{new.state}',
        '  │  │  └─<def.state>',
        '  │  │     ├─[arrow:5:"=>"]',
        '  │  │     ├─<tokenStateID>',
        '  │  │     │  ├─[openBracket:6:"["]',
        '  │  │     │  ├─[id:7:"A"]',
        '  │  │     │  ├─[closeBracket:8:"]"]',
        '  │  │     │  └─{new.token.state}',
        '  │  │     ├─{assign.token}',
        '  │  │     └─<def.token.optional>',
        '  │  └─[semicolon:9:";"]',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<stateID>',
        '  │  │  ├─[openParen:11:"("]',
        '  │  │  ├─[id:12:"B"]',
        '  │  │  ├─[closeParen:13:")"]',
        '  │  │  └─{new.state}',
        '  │  └─<def.state>',
        '  │     ├─[arrow:15:"=>"]',
        '  │     ├─<tokenStateID>',
        '  │     │  ├─[openBracket:16:"["]',
        '  │     │  ├─[id:17:"B"]',
        '  │     │  ├─[closeBracket:18:"]"]',
        '  │     │  └─{new.token.state}',
        '  │     ├─{assign.token}',
        '  │     └─<def.token.optional>',
        '  └─[semicolon:19:";"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('loader03');
      final Parser parser = Loader.getParser();
      args.checkParser(parser, [
        "(A): ^'a', 'c'..'f', !'abcd' => [D];"
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<stateID>',
        '  │  │  ├─[openParen:1:"("]',
        '  │  │  ├─[id:2:"A"]',
        '  │  │  ├─[closeParen:3:")"]',
        '  │  │  └─{new.state}',
        '  │  └─<def.state>',
        '  │     ├─[colon:4:":"]',
        '  │     ├─<matcher.start>',
        '  │     │  ├─[consume:6:"^"]',
        '  │     │  ├─<matcher>',
        '  │     │  │  ├─<matcher>',
        '  │     │  │  │  ├─<matcher>',
        '  │     │  │  │  │  └─<charSetRange>',
        '  │     │  │  │  │     ├─[string:9:"a"]',
        '  │     │  │  │  │     └─{match.set}',
        '  │     │  │  │  ├─[comma:10:","]',
        '  │     │  │  │  └─<charSetRange>',
        '  │     │  │  │     ├─[string:14:"c"]',
        '  │     │  │  │     ├─[range:16:".."]',
        '  │     │  │  │     ├─[string:19:"f"]',
        '  │     │  │  │     └─{match.range}',
        '  │     │  │  ├─[comma:20:","]',
        '  │     │  │  └─<charSetRange>',
        '  │     │  │     ├─[not:22:"!"]',
        '  │     │  │     ├─[string:28:"abcd"]',
        '  │     │  │     └─{match.set.not}',
        '  │     │  └─{match.consume}',
        '  │     ├─[arrow:31:"=>"]',
        '  │     ├─<tokenStateID>',
        '  │     │  ├─[openBracket:33:"["]',
        '  │     │  ├─[id:34:"D"]',
        '  │     │  ├─[closeBracket:35:"]"]',
        '  │     │  └─{new.token.state}',
        '  │     ├─{join.token}',
        '  │     └─<def.token.optional>',
        '  └─[semicolon:36:";"]'
      ]);
      args.checkParser(parser, [
        "(A): 'a\\x0A\\u00C2' => [D];"
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<stateID>',
        '  │  │  ├─[openParen:1:"("]',
        '  │  │  ├─[id:2:"A"]',
        '  │  │  ├─[closeParen:3:")"]',
        '  │  │  └─{new.state}',
        '  │  └─<def.state>',
        '  │     ├─[colon:4:":"]',
        '  │     ├─<matcher.start>',
        '  │     │  └─<matcher>',
        '  │     │     └─<charSetRange>',
        '  │     │        ├─[string:18:"a\\x0A\\u00C2"]',
        '  │     │        └─{match.set}',
        '  │     ├─[arrow:21:"=>"]',
        '  │     ├─<tokenStateID>',
        '  │     │  ├─[openBracket:23:"["]',
        '  │     │  ├─[id:24:"D"]',
        '  │     │  ├─[closeBracket:25:"]"]',
        '  │     │  └─{new.token.state}',
        '  │     ├─{join.token}',
        '  │     └─<def.token.optional>',
        '  └─[semicolon:26:";"]'
      ]);
      args.checkParser(parser, [
        "(A): !('a'..'z', '0'..'9') => [D];"
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<stateID>',
        '  │  │  ├─[openParen:1:"("]',
        '  │  │  ├─[id:2:"A"]',
        '  │  │  ├─[closeParen:3:")"]',
        '  │  │  └─{new.state}',
        '  │  └─<def.state>',
        '  │     ├─[colon:4:":"]',
        '  │     ├─<matcher.start>',
        '  │     │  └─<matcher>',
        '  │     │     └─<charSetRange>',
        '  │     │        ├─[not:6:"!"]',
        '  │     │        ├─[openParen:7:"("]',
        '  │     │        ├─{not.group.start}',
        '  │     │        ├─<matcher>',
        '  │     │        │  ├─<matcher>',
        '  │     │        │  │  └─<charSetRange>',
        '  │     │        │  │     ├─[string:10:"a"]',
        '  │     │        │  │     ├─[range:12:".."]',
        '  │     │        │  │     ├─[string:15:"z"]',
        '  │     │        │  │     └─{match.range}',
        '  │     │        │  ├─[comma:16:","]',
        '  │     │        │  └─<charSetRange>',
        '  │     │        │     ├─[string:20:"0"]',
        '  │     │        │     ├─[range:22:".."]',
        '  │     │        │     ├─[string:25:"9"]',
        '  │     │        │     └─{match.range}',
        '  │     │        ├─[closeParen:26:")"]',
        '  │     │        └─{not.group.end}',
        '  │     ├─[arrow:29:"=>"]',
        '  │     ├─<tokenStateID>',
        '  │     │  ├─[openBracket:31:"["]',
        '  │     │  ├─[id:32:"D"]',
        '  │     │  ├─[closeBracket:33:"]"]',
        '  │     │  └─{new.token.state}',
        '  │     ├─{join.token}',
        '  │     └─<def.token.optional>',
        '  └─[semicolon:34:";"]'
      ]);
    },
  );
  test.run(
    (final TestArgs args) {
      args.log('loader04');
      final Parser parser = Loader.getParser();
      args.checkParser(parser, [
        "(A) => (D);"
      ], [
        'Unexpected item, openParen:8:"(", in state 43. Expected: openBracket, consume.',
        'Unexpected item, id:9:"D", in state 43. Expected: openBracket, consume.',
        'Unexpected item, closeParen:10:")", in state 43. Expected: openBracket, consume.',
        'Unexpected item, semicolon:11:";", in state 43. Expected: openBracket, consume.',
        'Unexpected item, eofToken:-1:"eofToken", in state 43. Expected: openBracket, consume.'
      ]);
      args.checkParser(parser, [
        "> [D];"
      ], [
        'Unexpected item, openBracket:3:"[", in state 3. Expected: openParen, openAngle.',
        'Unexpected item, id:4:"D", in state 3. Expected: openParen, openAngle.',
        'Unexpected item, closeBracket:5:"]", in state 3. Expected: openParen, openAngle.',
        'Unexpected item, semicolon:6:";", in state 3. Expected: openParen, openAngle.',
        'Unexpected item, eofToken:-1:"eofToken", in state 3. Expected: openParen, openAngle.'
      ]);
      args.checkParser(parser, [
        "(A) => ^[D];"
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<stateID>',
        '  │  │  ├─[openParen:1:"("]',
        '  │  │  ├─[id:2:"A"]',
        '  │  │  ├─[closeParen:3:")"]',
        '  │  │  └─{new.state}',
        '  │  └─<def.state>',
        '  │     ├─[arrow:6:"=>"]',
        '  │     ├─<tokenStateID>',
        '  │     │  ├─[consume:8:"^"]',
        '  │     │  ├─[openBracket:9:"["]',
        '  │     │  ├─[id:10:"D"]',
        '  │     │  ├─[closeBracket:11:"]"]',
        '  │     │  └─{new.token.consume}',
        '  │     ├─{assign.token}',
        '  │     └─<def.token.optional>',
        '  └─[semicolon:12:";"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('loader05');
      final Parser parser = Loader.getParser();
      args.checkParser(parser, [
        '[A]: "where" => [D];'
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<tokenStateID>',
        '  │  │  ├─[openBracket:1:"["]',
        '  │  │  ├─[id:2:"A"]',
        '  │  │  ├─[closeBracket:3:"]"]',
        '  │  │  └─{new.token.state}',
        '  │  └─<def.token>',
        '  │     ├─[colon:4:":"]',
        '  │     ├─<replaceText>',
        '  │     │  ├─[string:12:"where"]',
        '  │     │  └─{add.replace.text}',
        '  │     ├─[arrow:15:"=>"]',
        '  │     ├─<tokenStateID>',
        '  │     │  ├─[openBracket:17:"["]',
        '  │     │  ├─[id:18:"D"]',
        '  │     │  ├─[closeBracket:19:"]"]',
        '  │     │  └─{new.token.state}',
        '  │     └─{replace.token}',
        '  └─[semicolon:20:";"]'
      ]);
      args.checkParser(parser, [
        '[A]: "is", "as", "if" => [D];'
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<tokenStateID>',
        '  │  │  ├─[openBracket:1:"["]',
        '  │  │  ├─[id:2:"A"]',
        '  │  │  ├─[closeBracket:3:"]"]',
        '  │  │  └─{new.token.state}',
        '  │  └─<def.token>',
        '  │     ├─[colon:4:":"]',
        '  │     ├─<replaceText>',
        '  │     │  ├─<replaceText>',
        '  │     │  │  ├─<replaceText>',
        '  │     │  │  │  ├─[string:9:"is"]',
        '  │     │  │  │  └─{add.replace.text}',
        '  │     │  │  ├─[comma:10:","]',
        '  │     │  │  ├─[string:15:"as"]',
        '  │     │  │  └─{add.replace.text}',
        '  │     │  ├─[comma:16:","]',
        '  │     │  ├─[string:21:"if"]',
        '  │     │  └─{add.replace.text}',
        '  │     ├─[arrow:24:"=>"]',
        '  │     ├─<tokenStateID>',
        '  │     │  ├─[openBracket:26:"["]',
        '  │     │  ├─[id:27:"D"]',
        '  │     │  ├─[closeBracket:28:"]"]',
        '  │     │  └─{new.token.state}',
        '  │     └─{replace.token}',
        '  └─[semicolon:29:";"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('loader06');
      final parser = Loader.getParser();
      args.checkParser(parser, [
        '> <apple>;'
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─[closeAngle:1:">"]',
        '  │  ├─<termID>',
        '  │  │  ├─[openAngle:3:"<"]',
        '  │  │  ├─[id:8:"apple"]',
        '  │  │  ├─[closeAngle:9:">"]',
        '  │  │  └─{new.term}',
        '  │  ├─{start.term}',
        '  │  └─<start.rule.optional>',
        '  └─[semicolon:10:";"]'
      ]);
      args.checkParser(parser, [
        '> <apple> := _;'
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─[closeAngle:1:">"]',
        '  │  ├─<termID>',
        '  │  │  ├─[openAngle:3:"<"]',
        '  │  │  ├─[id:8:"apple"]',
        '  │  │  ├─[closeAngle:9:">"]',
        '  │  │  └─{new.term}',
        '  │  ├─{start.term}',
        '  │  └─<start.rule.optional>',
        '  │     ├─[assign:12:":="]',
        '  │     ├─{start.rule}',
        '  │     ├─<start.rule>',
        '  │     │  └─[lambda:14:"_"]',
        '  │     └─<next.rule.optional>',
        '  └─[semicolon:15:";"]'
      ]);
      args.checkParser(parser, [
        '<apple> := _;'
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<termID>',
        '  │  │  ├─[openAngle:1:"<"]',
        '  │  │  ├─[id:6:"apple"]',
        '  │  │  ├─[closeAngle:7:">"]',
        '  │  │  └─{new.term}',
        '  │  ├─[assign:10:":="]',
        '  │  ├─{start.rule}',
        '  │  ├─<start.rule>',
        '  │  │  └─[lambda:12:"_"]',
        '  │  └─<next.rule.optional>',
        '  └─[semicolon:13:";"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('loader07');
      final Parser parser = Loader.getParser();
      args.checkParser(parser, [
        '<A> := [B] <C> [D] {E};'
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<termID>',
        '  │  │  ├─[openAngle:1:"<"]',
        '  │  │  ├─[id:2:"A"]',
        '  │  │  ├─[closeAngle:3:">"]',
        '  │  │  └─{new.term}',
        '  │  ├─[assign:6:":="]',
        '  │  ├─{start.rule}',
        '  │  ├─<start.rule>',
        '  │  │  ├─<tokenItemID>',
        '  │  │  │  ├─[openBracket:8:"["]',
        '  │  │  │  ├─[id:9:"B"]',
        '  │  │  │  ├─[closeBracket:10:"]"]',
        '  │  │  │  └─{new.token.item}',
        '  │  │  ├─{item.token}',
        '  │  │  └─<rule.item>',
        '  │  │     ├─<rule.item>',
        '  │  │     │  ├─<rule.item>',
        '  │  │     │  │  ├─<rule.item>',
        '  │  │     │  │  ├─<termID>',
        '  │  │     │  │  │  ├─[openAngle:12:"<"]',
        '  │  │     │  │  │  ├─[id:13:"C"]',
        '  │  │     │  │  │  ├─[closeAngle:14:">"]',
        '  │  │     │  │  │  └─{new.term}',
        '  │  │     │  │  └─{item.term}',
        '  │  │     │  ├─<tokenItemID>',
        '  │  │     │  │  ├─[openBracket:16:"["]',
        '  │  │     │  │  ├─[id:17:"D"]',
        '  │  │     │  │  ├─[closeBracket:18:"]"]',
        '  │  │     │  │  └─{new.token.item}',
        '  │  │     │  └─{item.token}',
        '  │  │     ├─<triggerID>',
        '  │  │     │  ├─[openCurly:20:"{"]',
        '  │  │     │  ├─[id:21:"E"]',
        '  │  │     │  ├─[closeCurly:22:"}"]',
        '  │  │     │  └─{new.trigger}',
        '  │  │     └─{item.trigger}',
        '  │  └─<next.rule.optional>',
        '  └─[semicolon:23:";"]'
      ]);
      args.checkParser(parser, [
        '<A> := _ | <B> | [C];'
      ], [
        '─<def.set>',
        '  ├─<def.set>',
        '  ├─<def>',
        '  │  ├─{new.def}',
        '  │  ├─<termID>',
        '  │  │  ├─[openAngle:1:"<"]',
        '  │  │  ├─[id:2:"A"]',
        '  │  │  ├─[closeAngle:3:">"]',
        '  │  │  └─{new.term}',
        '  │  ├─[assign:6:":="]',
        '  │  ├─{start.rule}',
        '  │  ├─<start.rule>',
        '  │  │  └─[lambda:8:"_"]',
        '  │  └─<next.rule.optional>',
        '  │     ├─<next.rule.optional>',
        '  │     │  ├─<next.rule.optional>',
        '  │     │  ├─[or:10:"|"]',
        '  │     │  ├─{start.rule}',
        '  │     │  └─<start.rule>',
        '  │     │     ├─<termID>',
        '  │     │     │  ├─[openAngle:12:"<"]',
        '  │     │     │  ├─[id:13:"B"]',
        '  │     │     │  ├─[closeAngle:14:">"]',
        '  │     │     │  └─{new.term}',
        '  │     │     ├─{item.term}',
        '  │     │     └─<rule.item>',
        '  │     ├─[or:16:"|"]',
        '  │     ├─{start.rule}',
        '  │     └─<start.rule>',
        '  │        ├─<tokenItemID>',
        '  │        │  ├─[openBracket:18:"["]',
        '  │        │  ├─[id:19:"C"]',
        '  │        │  ├─[closeBracket:20:"]"]',
        '  │        │  └─{new.token.item}',
        '  │        ├─{item.token}',
        '  │        └─<rule.item>',
        '  └─[semicolon:21:";"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('loader08');
      final Parser parser = Parser.fromDefinition([
        "> (Start): '0'..'9' => (Num): '0'..'9' => [Num];",
        "(Start): 'a'..'z', 'A'..'Z' => (Var): 'a'..'z', 'A'..'Z', '0'..'9' => [Var];",
        "(Start): '*' => [Mul];",
        "(Start): '+' => [Add];",
        "(Start): '-' => [Sub];",
        "(Start): '/' => [Div];",
        "(Start): '(' => [Open];",
        "(Start): ')' => [Close];",
        "(Start): ' ' => (Whitespace): ' ' => ^[Whitespace];",
        "> <Expression> := <Expression> [Add] <Term> | <Expression> [Sub] <Term> | <Term>;",
        "<Term> := <Term> [Mul] <Factor> | <Term> [Div] <Factor> | <Factor>;",
        "<Factor> := [Open] <Expression> [Close] | [Num] | [Var];"
      ].join('\n'));
      args.checkParser(parser, [
        '4 + 3 * pi'
      ], [
        '─<Expression>',
        '  ├─<Expression>',
        '  │  └─<Term>',
        '  │     └─<Factor>',
        '  │        └─[Num:1:"4"]',
        '  ├─[Add:3:"+"]',
        '  └─<Term>',
        '     ├─<Term>',
        '     │  └─<Factor>',
        '     │     └─[Num:5:"3"]',
        '     ├─[Mul:7:"*"]',
        '     └─<Factor>',
        '        └─[Var:10:"pi"]'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('loader09');
      final Parser parser = Parser.fromDefinition([
        "> (Start): '\\n' => (First): '\\t' => (Second): '\\x0A' => (Third): '\\u000A' => (Forth): '\\\\' => [Symbol];",
        "(Start): ' ' => (Whitespace): ' ' => ^[Whitespace];",
        "> <E> := [Symbol];",
        "<E> := <E> [Symbol];"
      ].join('\n'));
      args.checkParser(parser, ['\n\t\n\n\\'], ['─<E>', '  └─[Symbol:5:"\\n\\t\\n\\n\\"]']);
    },
  );
  test.run(
    (final args) {
      args.log('calc00');
      final calc = Calculator();
      args.checkCalc(calc, '', ['no result']);
      args.checkCalc(calc, '42', ['42']);
      args.checkCalc(calc, '2 * 3', ['6']);
      args.checkCalc(calc, '2 + 3', ['5']);
      args.checkCalc(calc, '2 * 3 + 5', ['11']);
      args.checkCalc(calc, '2 * (3 + 5)', ['16']);
      args.checkCalc(calc, '(2 * 3) + 5', ['11']);
      args.checkCalc(calc, '(2 * (3 + 5))', ['16']);
      args.checkCalc(calc, '2*5 + 5*2', ['20']);
      args.checkCalc(calc, '12 - 5', ['7']);
      args.checkCalc(calc, '12 + -5', ['7']);
      args.checkCalc(calc, '2*6 - 5', ['7']);
      args.checkCalc(calc, '2*2*3 + 5*(-1)', ['7']);
      args.checkCalc(calc, '2*2*3 + 5*(-1)', ['7']);
      args.checkCalc(calc, '2**3', ['8']);
      args.checkCalc(calc, '1100b', ['12']);
      args.checkCalc(calc, '0xF00A', ['61450']);
      args.checkCalc(calc, '77o', ['63']);
      args.checkCalc(calc, '42d', ['42']);
    },
  );
  test.run(
    (final args) {
      args.log('calc01');
      final calc = Calculator();
      args.checkCalc(calc, '3.14', ['3.14']);
      args.checkCalc(calc, '314e-2', ['3.14']);
      args.checkCalc(calc, '314.0e-2', ['3.14']);
      args.checkCalc(calc, '31.4e-1', ['3.14']);
      args.checkCalc(calc, '0.0314e2', ['3.14']);
      args.checkCalc(calc, '0.0314e+2', ['3.14']);
      args.checkCalc(calc, '2.0 * 3', ['6.0']);
      args.checkCalc(calc, '2 * 3.0', ['6.0']);
      args.checkCalc(calc, '2.0 * 3.0', ['6.0']);
      args.checkCalc(calc, 'real(2) * 3', ['6.0']);
      args.checkCalc(calc, '2.0 - 3', ['-1.0']);
      args.checkCalc(calc, '2.0 ** 3', ['8.0']);
    },
  );
  test.run(
    (final args) {
      args.log('calc02');
      final calc = Calculator();
      args.checkCalc(calc, 'min(2, 4, 3)', ['2']);
      args.checkCalc(calc, 'max(2, 4, 3)', ['4']);
      args.checkCalc(calc, 'sum(2, 4, 3)', ['9']);
      args.checkCalc(calc, 'avg(2, 4, 3)', ['3.0']);
      args.checkCalc(calc, 'min(2+4, 4-2, 1*3)', ['2']);
      args.checkCalc(calc, 'floor(3.5)', ['3']);
      args.checkCalc(calc, 'round(3.5)', ['4']);
      args.checkCalc(calc, 'ceil(3.5)', ['4']);
    },
  );
  test.run(
    (final args) {
      args.log('calc03');
      final calc = Calculator();
      args.checkCalc(
          calc, 'square(11)', ['Errors in calculator input:', 'Exception: No function called square found.']);
      calc.addFunc("square", (List<Object?> list) {
        if (list.length != 1) throw Exception('Square may one and only one input.');
        final Variant v = Variant(list[0]);
        if (v.implicitInt) return v.asInt * v.asInt;
        if (v.implicitReal) return v.asReal * v.asReal;
        throw Exception("May only square an int or real number but got $v.");
      });
      args.checkCalc(calc, 'square(11)', ['121']);
      args.checkCalc(calc, 'square(-4.33)', ['18.7489']);
      args.checkCalc(calc, 'square("cat")', [
        'Errors in calculator input:',
        'Exception: May only square an int or real number but got String(cat).'
      ]);
    },
  );
  test.run(
    (final args) {
      args.log('calc04');
      final calc = Calculator();
      args.checkCalc(calc, '"cat" + "9"', ['cat9']);
      args.checkCalc(calc, '"cat" + string(9)', ['cat9']);
      args.checkCalc(calc, '"cat" + string(6 + int("3"))', ['cat9']);
      args.checkCalc(calc, 'bin(42)', ['101010b']);
      args.checkCalc(calc, 'oct(42)', ['52o']);
      args.checkCalc(calc, 'hex(42)', ['0x2A']);
      args.checkCalc(calc, 'upper("CAT-cat")', ['CAT-CAT']);
      args.checkCalc(calc, 'lower("CAT-cat")', ['cat-cat']);
      args.checkCalc(calc, 'sub("catch", 0, 3)', ['cat']);
      args.checkCalc(calc, 'sub("catch", 1, 3)', ['at']);
      args.checkCalc(calc, 'sub("catch", 3, 1)',
          ['Errors in calculator input:', 'RangeError (end): Invalid value: Not in inclusive range 3..5: 1']);
      args.checkCalc(calc, 'len("catch")', ['5']);
      args.checkCalc(calc, 'len("cat")', ['3']);
      args.checkCalc(calc, 'len("\\"")', ['1']);
      args.checkCalc(calc, 'len("")', ['0']);
      args.checkCalc(calc, 'bool("tr"+"ue")', ['true']);
    },
  );
  test.run(
    (final args) {
      args.log('calc05');
      final calc = Calculator();
      args.checkCalc(calc, 'hex(0xFF00 & 0xF0F0)', ['0xF000']);
      args.checkCalc(calc, 'hex(0xFF00 | 0xF0F0)', ['0xFFF0']);
      args.checkCalc(calc, 'hex(0xFF00 ^ 0xF0F0)', ['0xFF0']);
      args.checkCalc(calc, 'hex(~0xFF00 & 0x0FF0)', ['0xF0']);
      args.checkCalc(calc, '!true', ['false']);
      args.checkCalc(calc, '!false', ['true']);
      args.checkCalc(calc, 'true & true', ['true']);
      args.checkCalc(calc, 'true & false', ['false']);
      args.checkCalc(calc, 'false & true', ['false']);
      args.checkCalc(calc, 'false & false', ['false']);
      args.checkCalc(calc, 'true | true', ['true']);
      args.checkCalc(calc, 'true | false', ['true']);
      args.checkCalc(calc, 'false | true', ['true']);
      args.checkCalc(calc, 'false | false', ['false']);
      args.checkCalc(calc, 'true ^ true', ['false']);
      args.checkCalc(calc, 'true ^ false', ['true']);
      args.checkCalc(calc, 'false ^ true', ['true']);
      args.checkCalc(calc, 'false ^ false', ['false']);
    },
  );
  test.run(
    (final args) {
      args.log('calc06');
      final calc = Calculator();
      args.checkCalc(calc, '10 == 3', ['false']);
      args.checkCalc(calc, '3 == 3', ['true']);
      args.checkCalc(calc, '10 != 3', ['true']);
      args.checkCalc(calc, '3 != 3', ['false']);
      args.checkCalc(calc, '10 < 3', ['false']);
      args.checkCalc(calc, '3 < 3', ['false']);
      args.checkCalc(calc, '3 <= 3', ['true']);
      args.checkCalc(calc, '3 <= 10', ['true']);
      args.checkCalc(calc, '10 <= 3', ['false']);
      args.checkCalc(calc, '2 < 3', ['true']);
      args.checkCalc(calc, '10 > 3', ['true']);
      args.checkCalc(calc, '3 > 3', ['false']);
      args.checkCalc(calc, '3 >= 3', ['true']);
      args.checkCalc(calc, '10 >= 3', ['true']);
      args.checkCalc(calc, '3 >= 10', ['false']);
      args.checkCalc(calc, '3 > 2', ['true']);
      args.checkCalc(calc, '3 == 3.0', ['true']);
      args.checkCalc(calc, '"3" == 3', ['false']);
      args.checkCalc(calc, '"3" == string(3)', ['true']);
      args.checkCalc(calc, 'true == false', ['false']);
      args.checkCalc(calc, 'true != false', ['true']);
    },
  );
  test.run(
    (final args) {
      args.log('calc07');
      final calc = Calculator();
      args.checkCalc(calc, '(3 == 2) | (4 < 10)', ['true']);
      args.checkCalc(calc, 'x := 4+5; y := 9; x == y; x+y', ['true, 18']);
      args.checkCalc(calc, 'x', ['9']);
      args.checkCalc(calc, 'z', ['Errors in calculator input:', 'Exception: No constant called z found.']);
      calc.setVar("z", true);
      args.checkCalc(calc, 'z', ['true']);
      args.checkCalc(calc, 'e', ['2.718281828459045']);
      args.checkCalc(calc, 'pi', ['3.141592653589793']);
      args.checkCalc(calc, 'cos(pi)', ['-1.0']);
    },
  );
  test.run(
    (final args) {
      args.log('calc08');
      final calc = Calculator();
      args.checkCalc(calc, 'padLeft("Hello", 12)', ['       Hello']);
      args.checkCalc(calc, 'padRight("Hello", 12)', ['Hello       ']);
      args.checkCalc(calc, 'padLeft("Hello", 12, "-")', ['-------Hello']);
      args.checkCalc(calc, 'padRight("Hello", 12, "-")', ['Hello-------']);
      args.checkCalc(calc, 'trim("   Hello   ")', ['Hello']);
      args.checkCalc(calc, 'trimLeft("   Hello   ")', ['Hello   ']);
      args.checkCalc(calc, 'trimRight("   Hello   ")', ['   Hello']);
      args.checkCalc(
        calc,
        'trim(str(1))',
        ['Errors in calculator input:', 'Exception: No function called str found.'],
      );
    },
  );
  test.printResult();
}

/// The arguments passed into a test.
class TestArgs {
  bool _failed = false;
  final StringBuffer _buf = StringBuffer();

  /// Creates a new test argument.
  TestArgs();

  /// Indicates if the test has failed or not.
  bool get failed => _failed;

  /// Gets the buffered log for this test.
  @override
  String toString() => _buf.toString();

  /// Writes an output to the test log.
  void log(
    final String msg,
  ) =>
      _buf.writeln(msg);

  /// Indicates an error occurred.
  void error(
    final String msg,
  ) {
    _buf.writeln('Error: ' + msg);
    _failed = true;
  }

  /// Checks if the given rule's string method.
  void checkRuleString(
    final Rule rule,
    final int index,
    final String exp,
  ) {
    final result = rule.toString(index);
    if (exp != result) {
      error(
        'The rule did not return the expected string:' +
            '\n  Index:    ' +
            index.toString() +
            '\n  Expected: ' +
            exp +
            '\n  Result:   ' +
            result,
      );
    }
  }

  /// Checks if the given lines diff as expected.
  void checkDiff(
    final List<String> a,
    final List<String> b,
    final List<String> exp,
  ) {
    final result = plusMinusParts(a, b).join('|');
    final expStr = exp.join('|');
    if (expStr != result) {
      error(
        'The diff did not return the expected result:' +
            '\n  A Input:  [' +
            a.join("|") +
            ']' +
            '\n  B Input:  [' +
            b.join("|") +
            ']' +
            '\n  Expected: [' +
            expStr +
            ']' +
            '\n  Result:   [' +
            result +
            ']',
      );
    }
  }

  /// Checks the grammar results.
  void checkGrammar(
    final Grammar grammar,
    final List<String> expected,
  ) {
    final exp = expected.join('\n');
    final result = grammar.toString().trim();
    if (exp != result) {
      String diff = plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n        ');
      this.error(
        'The grammar string did not match the expected results:' + '\n  Diff: ' + diff,
      );
    }
  }

  /// Checks the grammar term's first tokens results.
  void checkTermFirst(
    final Grammar grammar,
    final String token,
    final List<String> expected,
  ) {
    final exp = expected.join('\n');
    final firsts = grammar.term(token).determineFirsts();
    final result = firsts.join('\n');
    if (exp != result) {
      String diff = plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n         ');
      this.error(
        'The grammar term firsts did not match the expected results:' +
            '\n  Token: ' +
            token +
            '\n  Diff:  ' +
            diff,
      );
    }
  }

  /// Checks the grammar term's follow tokens results.
  void checkTermFollow(
    final Grammar grammar,
    final String token,
    final List<String> expected,
  ) {
    final exp = expected.join('\n');
    final firsts = grammar.term(token).determineFollows();
    final result = firsts.join('\n');
    if (exp != result) {
      String diff = plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n         ');
      this.error(
        'The grammar term follows did not match the expected results:' +
            '\n  Token: ' +
            token +
            '\n  Diff:  ' +
            diff,
      );
    }
  }

  /// Checks the tokenizer results.
  void checkTok(
    final Tokenizer tok,
    final String input,
    final List<String> expected,
  ) {
    final resultBuf = StringBuffer();
    for (final token in tok.tokenize(input)) {
      resultBuf.writeln(token.toString());
    }
    final exp = expected.join('\n');
    final result = resultBuf.toString().trim();
    if (exp != result) {
      String diff = plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n         ');
      this.error(
        'The input did not match the expected results:' + '\n  Input: ' + input + '\n  Diff:  ' + diff,
      );
    }
  }

  /// Checks the parser will parse the given input.
  void checkParser(
    final Parser parser,
    final List<String> input,
    final List<String> expected,
  ) {
    final parseResult = parser.parse(input.join('\n'));
    final exp = expected.join('\n');
    final result = parseResult.toString();
    if (exp != result) {
      String diff = plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n        ');
      this.error(
        'The parsed input did not result in the expected result tree:' + '\n  Diff: ' + diff,
      );
    }
  }

  /// Checks that an expected error from the parser builder.
  void checkParserBuildError(
    final Grammar grammar,
    final Tokenizer tokenizer,
    final List<String> expected,
  ) {
    final exp = expected.join('\n');
    try {
      Parser.fromGrammar(
        grammar,
        tokenizer,
      );
      this.error(
        'Expected an exception from parser builder but got none:' + '\n  Expected: ' + exp,
      );
    } on Object catch (err) {
      final result = '$err'.trimRight();
      if (exp != result) {
        String diff = plusMinusLines(exp, result);
        diff = diff.trimRight().replaceAll('\n', '\n        ');
        this.error('Got a different error from the parser builder than expected:' + '\n  Diff: ' + diff);
      }
    }
  }

  /// Checks that the given input to the given calculator will result in the expected lines on the stack.
  void checkCalc(
    final Calculator calc,
    final String input,
    final List<String> expected,
  ) {
    calc.clear();
    calc.calculate(input);
    final result = calc.stackToString;
    final exp = expected.join('\n');
    if (exp != result) {
      String diff = plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n        ');
      this.error(
        'Got a different result from the calculator than expected:' + '\n  Diff: ' + diff,
      );
    }
  }
}

/// The main tool for testing.
class TestTool {
  bool _failed = false;

  /// Creates a new testing tool.
  TestTool();

  /// prints the results of all the tests.
  void printResult() => print(
        () {
          if (_failed) {
            return 'FAILED';
          } else {
            return 'PASSED';
          }
        }(),
      );

  /// Runs a test given the test function.
  void run(
    final dynamic Function(TestArgs args) test,
  ) {
    final args = TestArgs();
    test(args);
    if (args.failed) {
      print(
        args.toString() + 'Test failed',
      );
      this._failed = true;
    }
  }
}
