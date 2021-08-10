import 'dart:math' as math;

import 'parse_tree.dart' as _parsetree;
import 'parser.dart' as __parser;

// # Petite Parser Calculator
//
// The calculator uses the petite parser to create a simple mathematical language.
//
// - [Examples](#examples)
// - [Literals](#literals)
//   - [Implicit Conversions](#implicit-conversions)
// - [Constants](#constants)
// - [Functions](#functions)
//   - [Explicit Casts](#explicit-casts)
//   - [Formatting](#formatting)
//   - [Trigonometry](#trigonometry)
//   - [Logarithms](#logarithms)
//   - [Basic Math](#basic-math)
// - [Operators](#operators)
//   - [Unary Operators](#unary-operators)
//   - [Binary Operators](#binary-operators)
//   - [Comparing Operators](#comparing-operators)
//   - [Order of Operators](#order-of-operators)
//
// ## Examples
//
// | Input                          | Result                    |
// |--------------------------------|---------------------------|
// | `10 * 4 + 6`                   | `46`                      |
// | `10 * (-4 + 6)**2.0`           | `40.0`                    |
// | `cos(1.5*pi)`                  | `-1.8369701987210297e-16` |
// | `min(4, 8, 15, 16, 23, 42)`    | `4`                       |
// | `0x00FF & 0xAAAA`              | `170`                     |
// | `hex(0x00FF & 0xAAAA)`         | `0xAA`                    |
// | `int(string(12) + string(34))` | `1234`                    |
// | `x := 4; y := x + 2; x*y`      | `24`                      |
// | `1 + 1; 2 + 2; 3 + 3;`         | `2, 4, 6`                 |
// | `upper(sub("Hello", 1, 3))`    | `EL`                      |
//
// ## Literals
//
// - **Binary** numbers are made up of `0` and `1`'s followed by a `b`. For example `1011b`.
// - **Octal** numbers are made up of `0` to `7`'s followed by a `o`. For example `137o`.
// - **Decimal** numbers are made up of `0` to `9`'s, optionally followed by a `d`. For example `42`.
// - **Hexadecimal** numbers are made up of `0` to `9` and `a` to `f`'s preceded by a `0x`. For example `0x00FF`.
// - **Boolean** is either `true` and `false`.
// - **Real** numbers are decimals numbers with either a decimal point or exponent in it.
//   For example `0.01`, `12e-3`, and `1.1e2`.
// - **String** literals are quoted letters. It can have escaped characters for quotations (`\"`), newlines (`\n`), tabs (`\t`), ascii (`\x0A`) with two hex digits, and Unicode (`\u000A`) with four hex digits. For example `""`, `"abc"`, `"\n"`, and `"\x0A"`.
//
// ### Implicit Conversions
//
// - Booleans can be implicitly converted to and integer or real as 0 and 1.
// - Integers can be implicitly converted into reals.
//
// ## Constants
//
// These are the built-in constants. Additional constants may be added as needed.
//
// - `pi`: This is a real with the value for pi.
// - `e`: This is a real with the value for e.
// - `true`: This is a Boolean for true.
// - `false`: This is a Boolean for false.
//
// ## Functions
//
// These are the built-in functions. Additional functions may be added as needed.
//
// ### Explicit Casts
//
// - `bool`: Converts the value to Boolean, e.g `bool(1)`.
// - `int`: Converts the value to integer, e.g `int(123)`.
// - `real`: Converts the value to real, e.g `real(123)`.
// - `string`: Converts the value to string, e.g. `string(123)`.
//   If the value is an integer or real, the result is as decimal number string.
//
// ### Formatting
//
// - `bin`: Formats an integer as a binary number string.
// - `oct`: Formats an integer as an octal number string.
// - `hex`: Formats an integer as a hexadecimal number string.
// - `sub`: Gets the substring of a string given an integer start and stop, e.g. `sub("hello", 2, 4)`.
// - `upper`: Gets the upper case of a string.
// - `lower`: Gets the lower case of a string.
// - `len`: Returns the length of a string.
// - `padLeft`: Pads the string on the left side with an optional string
//           until the string's length is equal to a specified length,
//           e.g. `padLeft("hello", 3)` and `padLeft("hello", 3, "-")`.
//           If not specified, the string will be padded with spaces.
// - `padRight`: Pads the string on the right side with an optional string
//           until the string's length is equal to a specified length,
//           e.g. `padRight("hello", 3)` and `padRight("hello", 3, "-")`.
//           If not specified, the string will be padded with spaces.
// - `trim`: Trims all whitespace from the left and right of a string.
// - `trimLeft`: Trims all whitespace from the left of a string.
// - `trimRight`: Trims all whitespace from the right of a string.
//
// ### Trigonometry
//
// - `sin`: Works on one number to get the sine.
// - `cos`: Works on one number to get the cosine.
// - `tan`: Works on one number to get the tangent.
// - `acos`: Works on one number to get the arc cosine.
// - `asin`: Works on one number to get the arc sine.
// - `atan`: Works on one number to get the arc tangent.
// - `atan2`: Works on two numbers to get the arc tangent given `y` and `x` as `atan(y/x)`.
//
// ### Logarithms
//
// - `log`: Works on two numbers to get the log given `a` and `b` as `log(a)/log(b)`.
// - `log2`: Works on one number to get the log base 2.
// - `log10`: Works on one number to get the log base 10.
// - `ln`: Works on one number to get the natural log.
//
// ### Basic Math
//
// - `abs`: Works on one number to get the absolute value, e.g. `abs(5)`.
// - `ceil`: Works on one real to get the ceiling (rounded up) value. Returns integers unchanged.
// - `floor`: Works on one real to get the floor (rounded down) value. Returns integers unchanged.
// - `round`: Works on one real to round the value. Returns integers unchanged.
// - `sqrt`: Works on one number to get the square root.
// - `rand`: Takes no arguments and will return a random real number between 0 and 1.
// - `avg`: Works on one or more numbers to get the average of all the numbers.
//     If all the numbers are integers then the result will be an integer, e.g. `avg(4.5, 3.3, 12.0)`.
// - `max`: Works on one or more numbers to get the maximum of all the numbers.
//     If all the numbers are integers then the result will be an integer, e.g. `max(4.5, 3.3, 12.0)`.
// - `min`: Works on one or more numbers to get the minimum of all the numbers.
//     If all the numbers are integers then the result will be an integer, e.g. `max(4.5, 3.3, 12.0)`.
// - `sum`: Works on one or more numbers to get the summation of all the numbers.
//     If all the numbers are integers then the result will be an integer, e.g. `sum(4.5, 3.3, 12.0)`.
//
// ## Operators
//
// These are the operators to use for mathematics. Mathematical expressions can be separated by `;`,
// e.g. `5*2; 1+2`
// Parentheses, `(` and `)`, can be used to perform part of the equation first, e.g. `4 * (2 + 3)`.
//
// ### Unary Operators
//
// - `+`: As an unary it has no effect on a number because it simply visually asserts the sign, e.g. `+4`.
// - `-`: As an unary for a number it will negate the number, e.g. `-4`.
// - `~`: This gets bitwise NOT the value of an integer, e.g. `~10`.
// - `!`: This gets the NOT the a Boolean value.
//
// ### Binary Operators
//
// - `+`: This will add them together two numbers, e.g. `2+4`. If both numbers are integers then an integer is returned.
//     This can also be used between two strings to concatenate them, e.g. `"ab" + "cd"`.
//     If used between two Booleans it will OR them.
// - `-`: This will subtract the number right from the number left, e.g. `45-11`. If both numbers are integers then an integer
//     is returned. If used between two Booleans it will imply (`!a|b`) them.
// - `*`: This will multiplying two numbers together. If both numbers are integers then an integer is returned.
// - `**`: This gets the power of the left raised to the right. If both numbers are integers then an integer is returned.
// - `/`: This divides the left number from the right number. If both numbers are integers then a truncated integer is returned.
// - `&`: This performs a bitwise ANDing of two integers or two Booleans.
// - `|`: This performs a bitwise ORing of two integers or two Booleans.
// - `^`: This performs a bitwise XORing of two integers or two Booleans.
// - `:=`: This assigns a value to a variable, e.g. `x := 5; y := x + 2`.
//   When a variable is assigned it is removed from the stack so will not be outputted.
//
// ### Comparing Operators
//
// - `==`: This checks the equality of two values and returns a Boolean with the result.
//     The values are compared if they are the same kind or can be implicitly cast to the same kind, otherwise false is returned.
// - `!=`: This checks the inequality of two values and returns a Boolean with the result.
//     The values are compared if they are the same kind or can be implicitly cast to the same kind, otherwise true is returned.
// - `>`: This checks if the left number is greater than the right number.
// - `>=`: This checks if the left number is greater than or equal to the right number.
// - `<`: This checks if the left number is less than the right number.
// - `<=`: This checks if the left number is less than or equal to the right number.
//
// ### Order of Operators
//
// This is the order of operations so that `2 * 3 + 4` and `4 + 3 * 2` will be multiplied first
// then added resulting in `10` for both and not `14` unless parentheses are used, e.g. `2 * (3 + 4)`.
// These are in order of highest to lowest priority. When values have the same priority they will
// be executed right to left.
//
// - `:=`
// - `|`
// - `&`
// - `==`, `!=`, `<`, `<=`, `>`, `>=`
// - `+` (binary), `-` (binary)
// - `*`, `\`
// - `()`, `^`, `**`, `-` (unary), `+` (unary), `!`, `~`
/// This is the signature for functions which can be called by the calculator.
///
/// DO NOT implement functions which my give access to gain control over a website or application.
typedef CalcFunc = Object? Function(List<Object?> args);

/// An implementation of a simple calculator language.
///
/// This is useful for allowing a text field with higher mathematic control
/// without exposing exploits via a full language input.
///
/// This is also an example of how to use petite parser to construct
/// a simple interpreted language.
class Calculator {
  static __parser.Parser? _parser;

  /// Loads the parser used by the calculator.
  ///
  /// This is done in a static method since to load the language
  /// from a file it has to be done asynchronously.
  static void loadParser() => _parser ??= __parser.Parser.fromDefinition(language);

  final Map<String, _parsetree.TriggerHandle> _handles = {};
  final List<Object?> _stack = [];
  final Map<String, Object?> _consts = {};
  final Map<String, Object?> _vars = {};
  final _CalcFuncs _funcs = _CalcFuncs();

  // Creates a new calculator instance.
  Calculator() {
    this._handles.addAll({
      'Add': this._handleAdd,
      'And': this._handleAnd,
      'Assign': this._handleAssign,
      'Binary': this._handleBinary,
      'Call': this._handleCall,
      'Decimal': this._handleDecimal,
      'Divide': this._handleDivide,
      'Equal': this._handleEqual,
      'GreaterEqual': this._handleGreaterEqual,
      'GreaterThan': this._handleGreaterThan,
      'Hexadecimal': this._handleHexadecimal,
      'Id': this._handleId,
      'Invert': this._handleInvert,
      'LessEqual': this._handleLessEqual,
      'LessThan': this._handleLessThan,
      'Multiply': this._handleMultiply,
      'Negate': this._handleNegate,
      'Not': this._handleNot,
      'NotEqual': this._handleNotEqual,
      'Octal': this._handleOctal,
      'Or': this._handleOr,
      'Power': this._handlePower,
      'PushVar': this._handlePushVar,
      'Real': this._handleReal,
      'StartCall': this._handleStartCall,
      'String': this._handleString,
      'Subtract': this._handleSubtract,
      'Xor': this._handleXor
    });
    this._consts.addAll({"pi": math.pi, "e": math.e, "true": true, "false": false});
  }

  /// This parses the given calculation input and
  /// returns the results so that the input can be run multiple
  /// times without having to reparse the program.
  __parser.Result? parse(String input) {
    if (input.isEmpty) return null;
    loadParser();

    try {
      return _parser?.parse(input);
    } on Object catch (err) {
      return __parser.Result(['Errors in calculator input:\n' + err.toString()], null);
    }
  }

  /// This uses the pre-parsed input to calculate the result.
  /// This is useful when wanting to rerun the same code multiple
  /// times without having to reparse the program.
  void calculateNode(_parsetree.TreeNode? tree) {
    try {
      if (tree != null) tree.process(this._handles);
    } on Object catch (err) {
      this._stack.clear();
      this.push('Errors in calculator input:\n' + err.toString());
    }
  }

  /// This parses the given calculation input and
  /// puts the result on the top of the stack.
  void calculate(String input) {
    final __parser.Result? result = this.parse(input);
    if (result != null) {
      if (result.errors.isNotEmpty) {
        this._stack.clear();
        this.push('Errors in calculator input:\n  ' + result.errors.join('\n  '));
        return;
      }
      this.calculateNode(result.tree);
    }
  }

  /// Get a string showing all the values in the stack.
  String get stackToString {
    if (this._stack.isEmpty) return 'no result';
    final List<String> parts = [];
    for (final Object? val in this._stack) {
      parts.add('${val}');
    }
    return parts.join(', ');
  }

  /// Adds a new function that can be called by the language.
  /// Set to null to remove a function.
  void addFunc(String name, CalcFunc hndl) => this._funcs.addFunc(name, hndl);

  /// Adds a new constant value into the language.
  /// Set to null to remove the constant.
  void addConstant(String name, Object? value) {
    if (value == null) {
      this._consts.remove(name);
    } else {
      this._consts[name] = value;
    }
  }

  /// Sets the value of a variable.
  /// Set to null to remove the variable.
  void setVar(String name, Object? value) {
    if (value == null) {
      this._vars.remove(name);
    } else {
      this._vars[name] = value;
    }
  }

  /// Indicates if the stack is empty or not.
  bool get stackEmpty => this._stack.isEmpty;

  /// Clears all the values from the stack.
  void clear() => this._stack.clear();

  /// Removes the top value from the stack.
  Object? pop() => this._stack.removeLast();

  /// Pushes a value onto the stack.
  void push(Object? value) => this._stack.add(value);

  /// Handles calculating the sum of the top two items off of the stack.
  void _handleAdd(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt + right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal + right.asReal);
    } else if (left.implicitStr && right.implicitStr) {
      this.push(left.asStr + right.asStr);
    } else {
      throw Exception('Can not Add $left to $right.');
    }
  }

  /// Handles ANDing the top two items off the stack.
  void _handleAnd(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool && right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt & right.asInt);
    } else {
      throw Exception('Can not And $left with $right.');
    }
  }

  /// Handles assigning an variable to the top value off of the stack.
  void _handleAssign(_parsetree.TriggerArgs args) {
    final Object? right = this.pop();
    final Variant left = Variant(this.pop());
    if (!left.isStr) throw Exception('Can not Assign $right to $left.');
    final String text = left.asStr;
    if (this._consts.containsKey(text)) throw Exception('Can not Assign $right to the constant $left.');
    this._vars[text] = right;
  }

  /// Handles adding a binary integer value from the input tokens.
  void _handleBinary(_parsetree.TriggerArgs args) {
    String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    text = text.substring(0, text.length - 1); // remove 'b'
    this.push(int.parse(text, radix: 2));
  }

  /// Handles calling a function, taking it's parameters off the stack.
  void _handleCall(_parsetree.TriggerArgs args) {
    final List<Object?> methodArgs = [];
    Object? val = this.pop();
    while (val is! CalcFunc) {
      methodArgs.insert(0, val);
      val = this.pop();
    }
    this.push(val.call(methodArgs));
  }

  /// Handles adding a decimal integer value from the input tokens.
  void _handleDecimal(_parsetree.TriggerArgs args) {
    String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    if (text.endsWith('d')) text = text.substring(0, text.length - 1);
    this.push(int.parse(text, radix: 10));
  }

  /// Handles dividing the top two items on the stack.
  void _handleDivide(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt ~/ right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal / right.asReal);
    } else {
      throw Exception('Can not Divide $left with $right.');
    }
  }

  /// Handles checking if the two top items on the stack are equal.
  void _handleEqual(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool == right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt == right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal == right.asReal);
    } else if (left.implicitStr && right.implicitStr) {
      this.push(left.asStr == right.asStr);
    } else {
      this.push(false);
    }
  }

  /// Handles checking if the two top items on the stack are greater than or equal.
  void _handleGreaterEqual(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt >= right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal >= right.asReal);
    } else {
      throw Exception('Can not Greater Than or Equals $left and $right.');
    }
  }

  /// Handles checking if the two top items on the stack are greater than.
  void _handleGreaterThan(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt > right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal > right.asReal);
    } else {
      throw Exception('Can not Greater Than $left and $right.');
    }
  }

  /// Handles looking up a constant or variable value.
  void _handleId(_parsetree.TriggerArgs args) {
    final String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    if (this._consts.containsKey(text)) {
      this._stack.add(this._consts[text]);
      return;
    }
    if (this._vars.containsKey(text)) {
      this._stack.add(this._vars[text]);
      return;
    }
    throw Exception('No constant called $text found.');
  }

  /// Handles inverting the top value on the stack.
  void _handleInvert(_parsetree.TriggerArgs args) {
    final Variant top = Variant(this.pop());
    if (top.isInt) {
      this.push(~top.asInt);
    } else {
      throw Exception('Can not Invert $top.');
    }
  }

  /// Handles checking if the two top items on the stack are less than or equal.
  void _handleLessEqual(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt <= right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal <= right.asReal);
    } else {
      throw Exception('Can not Less Than or Equals $left and $right.');
    }
  }

  /// Handles checking if the two top items on the stack are less than.
  void _handleLessThan(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt < right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal < right.asReal);
    } else {
      throw Exception('Can not Less Than $left and $right.');
    }
  }

  /// Handles adding a hexadecimal integer value from the input tokens.
  void _handleHexadecimal(_parsetree.TriggerArgs args) {
    String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    text = text.substring(2); // remove '0x'
    this.push(int.parse(text, radix: 16));
  }

  /// Handles calculating the multiplies of the top two items off of the stack.
  void _handleMultiply(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt * right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal * right.asReal);
    } else {
      throw Exception('Can not Multiply $left to $right.');
    }
  }

  /// Handles negating the an integer or real value.
  void _handleNegate(_parsetree.TriggerArgs args) {
    final Variant top = Variant(this.pop());
    if (top.isInt) {
      this.push(-top.asInt);
    } else if (top.isReal) {
      this.push(-top.asReal);
    } else {
      throw Exception('Can not Negate $top.');
    }
  }

  /// Handles NOTing the Boolean values at the top of the the stack.
  void _handleNot(_parsetree.TriggerArgs args) {
    final Variant top = Variant(this.pop());
    if (top.isBool) {
      this.push(!top.asBool);
    } else {
      throw Exception('Can not Not $top.');
    }
  }

  /// Handles checking if the two top items on the stack are not equal.
  void _handleNotEqual(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool != right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt != right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal != right.asReal);
    } else if (left.implicitStr && right.implicitStr) {
      this.push(left.asStr != right.asStr);
    } else {
      this.push(true);
    }
  }

  /// Handles adding a octal integer value from the input tokens.
  void _handleOctal(_parsetree.TriggerArgs args) {
    String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    text = text.substring(0, text.length - 1); // remove 'o'
    this.push(int.parse(text, radix: 8));
  }

  /// Handles ORing the Boolean values at the top of the the stack.
  void _handleOr(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool || right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt | right.asInt);
    } else {
      throw Exception('Can not Or $left to $right.');
    }
  }

  /// Handles calculating the power of the top two values on the stack.
  void _handlePower(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(math.pow(left.asInt, right.asInt).toInt());
    } else if (left.implicitReal && right.implicitReal) {
      this.push(math.pow(left.asReal, right.asReal));
    } else {
      throw Exception('Can not Power $left and $right.');
    }
  }

  /// Handles push an ID value from the input tokens
  /// which will be used later as a variable name.
  void _handlePushVar(_parsetree.TriggerArgs args) {
    final String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    this.push(text);
  }

  /// Handles adding a real value from the input tokens.
  void _handleReal(_parsetree.TriggerArgs args) {
    final String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    this.push(double.parse(text));
  }

  /// Handles starting a function call.
  void _handleStartCall(_parsetree.TriggerArgs args) {
    final String text = args.recent(1)?.text.toLowerCase() ?? '';
    args.tokens.clear();
    final CalcFunc? func = this._funcs.findFunc(text);
    if (func == null) throw Exception('No function called $text found.');
    this.push(func);
  }

  /// Handles adding a string value from the input tokens.
  void _handleString(_parsetree.TriggerArgs args) {
    final String text = args.recent(1)?.text ?? '';
    args.tokens.clear();
    this.push(__parser.Loader.unescapeString(text));
  }

  /// Handles calculating the difference of the top two items off of the stack.
  void _handleSubtract(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt - right.asInt);
    } else if (left.implicitReal && right.implicitReal) {
      this.push(left.asReal - right.asReal);
    } else {
      throw Exception('Can not Subtract $left to $right.');
    }
  }

  /// Handles XORing the Boolean values at the top of the the stack.
  void _handleXor(_parsetree.TriggerArgs args) {
    final Variant right = Variant(this.pop());
    final Variant left = Variant(this.pop());
    if (left.implicitBool && right.implicitBool) {
      this.push(left.asBool ^ right.asBool);
    } else if (left.implicitInt && right.implicitInt) {
      this.push(left.asInt ^ right.asInt);
    } else {
      throw Exception('Can not Multiply $left to $right.');
    }
  }
}

/// Variant is a wrapper of values off the stack with helper methods
/// for casting and testing the implicit casting of a value.
class Variant {
  /// This is the wrapped value.
  final Object? value;

  /// Wraps the given value into a new Variant.
  Variant(this.value);

  /// Gets the string for this value.
  @override
  String toString() => '${value.runtimeType}($value)';

  /// Indicates if this value is a Boolean value.
  bool get isBool => value is bool;

  /// Indicates if this value is an integer value.
  bool get isInt => value is int;

  /// Indicates if this value is a real value.
  bool get isReal => value is double;

  /// Indicates if this value is a string value.
  bool get isStr => value is String;

  /// Indicates if the given value can be implicitly cast to a Boolean value.
  bool get implicitBool => isBool;

  /// Indicates if the given value can be implicitly cast to an integer value.
  bool get implicitInt => isBool || isInt;

  /// Indicates if the given value can be implicitly cast to a real value.
  bool get implicitReal => isBool || isInt || isReal;

  /// Indicates if the given value can be implicitly cast to a string value.
  bool get implicitStr => isStr;

  /// Casts this value to a Boolean.
  bool get asBool {
    if (isStr) {
      // ignore: cast_nullable_to_non_nullable
      final String val = (value as String).toLowerCase();
      return (val.isNotEmpty) && (val != '0') && (val != 'false');
    }
    // ignore: cast_nullable_to_non_nullable
    if (isInt) return (value as int) != 0;
    // ignore: cast_nullable_to_non_nullable
    if (isReal) return (value as double) != 0;
    // ignore: cast_nullable_to_non_nullable
    if (isBool) return value as bool;
    throw Exception('May not cast ${value} to Boolean.');
  }

  /// Casts this value to an integer.
  int get asInt {
    // ignore: cast_nullable_to_non_nullable
    if (isStr) return int.parse(value as String);
    // ignore: cast_nullable_to_non_nullable
    if (isInt) return value as int;
    // ignore: cast_nullable_to_non_nullable
    if (isReal) return (value as double).toInt();
    // ignore: cast_nullable_to_non_nullable
    if (isBool) return (value as bool) ? 1 : 0;
    throw Exception('May not cast ${value} to int.');
  }

  /// Casts this value to a real.
  double get asReal {
    // ignore: cast_nullable_to_non_nullable
    if (isStr) return double.parse(value as String);
    // ignore: cast_nullable_to_non_nullable
    if (isInt) return (value as int).toDouble();
    // ignore: cast_nullable_to_non_nullable
    if (isReal) return value as double;
    // ignore: cast_nullable_to_non_nullable
    if (isBool) return (value as bool) ? 1.0 : 0.0;
    throw Exception('May not cast ${value} to real.');
  }

  /// Casts this value to a string.
  String get asStr {
    // ignore: cast_nullable_to_non_nullable
    if (isStr) return value as String;
    // ignore: cast_nullable_to_non_nullable
    if (isInt) return (value as int).toString();
    // ignore: cast_nullable_to_non_nullable
    if (isReal) return (value as double).toString();
    // ignore: cast_nullable_to_non_nullable
    if (isBool) return (value as bool).toString();
    throw Exception('May not cast ${value} to string.');
  }
}

const String language = '''

# Petite Parser Example
# Calculator Language Definition

> (Start);

(Start):    '0'      => (Int.Zero);
(Int.Zero): '0'..'1' => (Int.Bin);
(Int.Zero): '2'..'7' => (Int.Oct);
(Int.Zero): '8'..'7' => (Int.Dec);
(Int.Zero): 'x'      => (Int.Hex.Start);
(Int.Zero): '.'      => (Real.Start);
(Int.Zero): 'e'      => (Exp.Start);
(Int.Zero): 'b' => [Binary];
(Int.Zero): 'o' => [Octal];
(Int.Zero): 'd' => [Decimal];
(Int.Zero) => [Decimal];

(Start):   '1'      => (Int.Bin);
(Int.Bin): '0'..'1' => (Int.Bin);
(Int.Bin): '2'..'7' => (Int.Oct);
(Int.Bin): '8'..'9' => (Int.Dec);
(Int.Bin): '.' => (Real.Start);
(Int.Bin): 'e' => (Exp.Start);
(Int.Bin): 'b' => [Binary];
(Int.Bin): 'o' => [Octal];
(Int.Bin): 'd' => [Decimal];
(Int.Bin) => [Decimal];

(Start):   '2'..'7' => (Int.Oct);
(Int.Oct): '0'..'7' => (Int.Oct);
(Int.Oct): '8'..'9' => (Int.Dec);
(Int.Oct): '.' => (Real.Start);
(Int.Oct): 'e' => (Exp.Start);
(Int.Oct): 'o' => [Octal];
(Int.Oct): 'd' => [Decimal];
(Int.Oct) => [Decimal];

(Start):   '8'..'9' => (Int.Dec);
(Int.Dec): '0'..'9' => (Int.Dec);
(Int.Dec): '.' => (Real.Start);
(Int.Dec): 'e' => (Exp.Start);
(Int.Dec): 'd' => [Decimal];
(Int.Dec) => [Decimal];

(Int.Hex.Start): '0'..'9', 'a'..'f', 'A'..'F' => (Int.Hex);
(Int.Hex): '0'..'9', 'a'..'f', 'A'..'F' => (Int.Hex);
(Int.Hex) => [Hexadecimal];

(Real.Start): '0'..'9' => (Real);
(Real): '0'..'9' => (Real);
(Real): 'e' => (Exp.Start);
(Real) => [Real];

(Exp.Start): '0'..'9' => (Exp);
(Exp.Start): '-', '+' => (Exp.Sign);
(Exp.Sign):  '0'..'9' => (Exp);
(Exp):       '0'..'9' => (Exp);
(Exp) => [Real];

(Start): 'a'..'z', 'A'..'Z', '_' => (Id);
(Id):    'a'..'z', 'A'..'Z', '0'..'9', '_' => [Id];

(Start): '*' => [Mul];
(Mul):   '*' => [Power];
(Start): '/' => [Div];
(Start): '+' => [Pos];
(Start): '-' => [Negate];
(Start): '^' => [Xor];
(Start): '~' => [Invert];
(Start): '&' => [And];
(Start): '|' => [Or];
(Start): '!' => [Not];
(Not):   '=' => [NotEqual];
(Start):       '>' => [GreaterThan];
(GreaterThan): '=' => [GreaterEqual];
(Start):       '<' => [LessThan];
(LessThan):    '=' => [LessEqual];
(Start): '=' => (Equal.Start): '=' => [Equal];
(Start): '(' => [Open];
(Start): ')' => [Close];
(Start): ',' => [Comma];
(Start): ';' => [Separator];
(Start): ':' => (Colon): '=' => [Assign];
(Start): ' ' => (Whitespace): ' ' => ^[Whitespace];

(Start): ^'"' => (Str.Body);
(Str.Body): ^'"' => [String];
(Str.Body): '\\\\' => (Str.Escape);
(Str.Escape): '\\\\"nrt' => (Str.Body);
(Str.Escape): 'x' => (Str.Hex1): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Hex2): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Body);
(Str.Escape): 'u' => (Str.Uni1): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Uni2): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Uni3);
(Str.Uni3): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Uni4): '0'..'9', 'a'..'z', 'A'..'Z' => (Str.Body);
(Str.Body): * => (Str.Body);

> <Program>;

<Program> := <Blocks>
    | <Blocks> [Separator];

<Blocks> := <Block>
    | <Blocks> [Separator] <Block>;

<Block> := <Expression.Or>
    | [Id] {PushVar} [Assign] <Expression.Or> {Assign};

<Expression.Or> := <Expression.And>
    | <Expression.Or> [Or]  <Expression.And> {Or};

<Expression.And> := <Expression.Comp>
    | <Expression.And> [And] <Expression.Comp> {And};

<Expression.Comp> := <Expression>
    | <Expression.Comp> [NotEqual]     <Expression> {NotEqual}
    | <Expression.Comp> [GreaterThan]  <Expression> {GreaterThan}
    | <Expression.Comp> [GreaterEqual] <Expression> {GreaterEqual}
    | <Expression.Comp> [LessThan]     <Expression> {LessThan}
    | <Expression.Comp> [LessEqual]    <Expression> {LessEqual}
    | <Expression.Comp> [Equal]        <Expression> {Equal};

<Expression> := <Term>
    | <Expression> [Pos] <Term> {Add}
    | <Expression> [Negate] <Term> {Subtract};

<Term> := <Factor>
    | <Term> [Mul] <Factor> {Multiply}
    | <Term> [Div] <Factor> {Divide};

<Factor> := <Value>
    | [Open] <Expression.Or> [Close]
    | <Factor> [Xor] <Value> {Xor}
    | <Factor> [Power] <Value> {Power}
    | [Negate] <Value> {Negate}
    | [Not] <Value> {Not}
    | [Pos] <Value>
    | [Invert] <Value> {Invert}
    | [Id] {StartCall} [Open] <Args> [Close] {Call};

<Value> := [Id] {Id}
    | [Binary] {Binary}
    | [Octal] {Octal}
    | [Decimal] {Decimal}
    | [Hexadecimal] {Hexadecimal}
    | [Real] {Real}
    | [String] {String};

<Args> := _
    | <Expression.Or>
    | <Args> [Comma] <Expression.Or>;

''';

/// This is a collection of functions for the calculator.
class _CalcFuncs {
  final Map<String, CalcFunc> _funcs = {};
  final math.Random _rand = math.Random(0);

  /// Creates a new collection of calculator function.
  _CalcFuncs() {
    this._funcs.addAll({
      'abs': this._funcAbs,
      'acos': this._funcAcos,
      'asin': this._funcAsin,
      'atan': this._funcAtan,
      'atan2': this._funcAtan2,
      'avg': this._funcAvg,
      'bin': this._funcBin,
      'bool': this._funcBool,
      'ceil': this._funcCeil,
      'cos': this._funcCos,
      'floor': this._funcFloor,
      'hex': this._funcHex,
      'int': this._funcInt,
      'len': this._funcLen,
      'log': this._funcLog,
      'log2': this._funcLog2,
      'log10': this._funcLog10,
      'lower': this._funcLower,
      'ln': this._funcLn,
      'max': this._funcMax,
      'min': this._funcMin,
      'oct': this._funcOct,
      'padleft': this._funcPadLeft,
      'padright': this._funcPadRight,
      'rand': this._funcRand,
      'real': this._funcReal,
      'round': this._funcRound,
      'sin': this._funcSin,
      'sqrt': this._funcSqrt,
      'string': this._funcString,
      'sub': this._funcSub,
      'sum': this._funcSum,
      'tan': this._funcTan,
      'trim': this._funcTrim,
      'trimleft': this._funcTrimLeft,
      'trimright': this._funcTrimRight,
      'upper': this._funcUpper
    });
  }

  /// Adds a new function that can be called by the language.
  /// Set to null to remove a function.
  void addFunc(String name, CalcFunc? hndl) {
    if (hndl == null) {
      this._funcs.remove(name);
    } else {
      this._funcs[name] = hndl;
    }
  }

  /// Finds the function with the given name.
  CalcFunc? findFunc(String name) => this._funcs[name];

  /// This checks that the specified number of arguments has been given.
  void _argCount(String name, List<Object?> args, int count) {
    if (args.length != count) {
      throw Exception('The function $name requires $count arguments but got ${args.length}.');
    }
  }

  /// This function gets the absolute value of the given integer or real.
  Object _funcAbs(List<Object?> args) {
    this._argCount('abs', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.abs();
    if (arg.implicitReal) return arg.asReal.abs();
    throw Exception('Can not use $arg in either abs(int) or abs(real).');
  }

  /// This function gets the arccosine of the given real.
  Object _funcAcos(List<Object?> args) {
    this._argCount('acos', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.acos(arg.asReal);
    throw Exception('Can not use $arg in acos(real).');
  }

  /// This function gets the arcsine of the given real.
  Object _funcAsin(List<Object?> args) {
    this._argCount('asin', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.asin(arg.asReal);
    throw Exception('Can not use $arg in asin(real).');
  }

  /// This function gets the arctangent of the given real.
  Object _funcAtan(List<Object?> args) {
    this._argCount('atan', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.atan(arg.asReal);
    throw Exception('Can not use $arg in atan(real).');
  }

  /// This function gets the arctangent of the two given reals.
  Object _funcAtan2(List<Object?> args) {
    this._argCount('atan2', args, 2);
    final Variant left = Variant(args[0]);
    final Variant right = Variant(args[1]);
    if (left.implicitReal && right.implicitReal) return math.atan2(left.asReal, right.asReal);
    throw Exception('Can not use $left and $right in atan2(real, real).');
  }

  /// This function gets the average of one or more reals.
  Object _funcAvg(List<Object?> args) {
    if (args.isEmpty) throw Exception('The function avg requires at least one argument.');
    double sum = 0.0;
    for (final Object? arg in args) {
      final Variant value = Variant(arg);
      if (value.implicitReal) {
        sum += value.asReal;
      } else {
        throw Exception('Can not use $arg in avg(real, real, ...).');
      }
    }
    return sum / args.length;
  }

  /// This function gets the binary formatted integer as a string.
  Object _funcBin(List<Object?> args) {
    this._argCount('bin', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(2) + "b";
    throw Exception('Can not use $arg to bin(int).');
  }

  /// This function casts the given value into a Boolean value.
  Object _funcBool(List<Object?> args) {
    this._argCount('bool', args, 1);
    final Variant arg = Variant(args[0]);
    return arg.asBool;
  }

  /// This function gets the ceiling of the given real.
  Object _funcCeil(List<Object?> args) {
    this._argCount('ceil', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.ceil();
    throw Exception('Can not use $arg to ceil(real) or already an int.');
  }

  /// This function gets the cosine of the given real.
  Object _funcCos(List<Object?> args) {
    this._argCount('cos', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.cos(arg.asReal);
    throw Exception('Can not use $arg in cos(real).');
  }

  /// This function gets the floor of the given real.
  Object _funcFloor(List<Object?> args) {
    this._argCount('floor', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.floor();
    throw Exception('Can not use $arg to floor(real) or already an int.');
  }

  /// This function gets the hexadecimal formatted integer as a string.
  Object _funcHex(List<Object?> args) {
    this._argCount('hex', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitInt) return "0x" + arg.asInt.toRadixString(16).toUpperCase();
    throw Exception('Can not use $arg to hex(int).');
  }

  /// This function casts the given value into an integer value.
  Object _funcInt(List<Object?> args) {
    this._argCount('int', args, 1);
    final Variant arg = Variant(args[0]);
    return arg.asInt;
  }

  /// This function gets the length of a string.
  Object _funcLen(List<Object?> args) {
    this._argCount('len', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitStr) return arg.asStr.length;
    throw Exception('Can not use $arg to len(string).');
  }

  /// This function gets the log of the given real with the base of another real.
  Object _funcLog(List<Object?> args) {
    this._argCount('log', args, 2);
    final Variant left = Variant(args[0]);
    final Variant right = Variant(args[1]);
    if (left.implicitReal && right.implicitReal) return math.log(left.asReal) / math.log(right.asReal);
    throw Exception('Can not use $left and $right in log(real, real).');
  }

  /// This function gets the log base 2 of the given real.
  Object _funcLog2(List<Object?> args) {
    this._argCount('log2', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.log(arg.asReal) / math.ln2;
    throw Exception('Can not use $arg in log2(real).');
  }

  /// This function gets the log base 10 of the given real.
  Object _funcLog10(List<Object?> args) {
    this._argCount('log10', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.log(arg.asReal) / math.ln10;
    throw Exception('Can not use $arg in log10(real).');
  }

  /// This function gets the lower case of the given string.
  Object _funcLower(List<Object?> args) {
    this._argCount('lower', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitStr) return arg.asStr.toLowerCase();
    throw Exception('Can not use $arg in lower(string).');
  }

  /// This function gets the natural log of the given real.
  Object _funcLn(List<Object?> args) {
    this._argCount('ln', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.log(arg.asReal);
    throw Exception('Can not use $arg in ln(real).');
  }

  /// This function gets the maximum value of one or more integers or reals.
  Object _funcMax(List<Object?> args) {
    if (args.isEmpty) throw Exception('The function max requires at least one argument.');
    bool allInt = true;
    for (final Object? arg in args) {
      final Variant value = Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw Exception('Can not use $arg in max(real, real, ...) or max(int, int, ...).');
    }

    if (allInt) {
      int value = Variant(args[0]).asInt;
      for (final Object? arg in args) {
        value = math.max(value, Variant(arg).asInt);
      }
      return value;
    } else {
      double value = Variant(args[0]).asReal;
      for (final Object? arg in args) {
        value = math.max(value, Variant(arg).asReal);
      }
      return value;
    }
  }

  /// This function gets the minimum value of one or more integers or reals.
  Object _funcMin(List<Object?> args) {
    if (args.isEmpty) throw Exception('The function min requires at least one argument.');
    bool allInt = true;
    for (final Object? arg in args) {
      final Variant value = Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw Exception('Can not use $arg in min(real, real, ...) or min(int, int, ...).');
    }

    if (allInt) {
      int value = Variant(args[0]).asInt;
      for (final Object? arg in args) {
        value = math.min(value, Variant(arg).asInt);
      }
      return value;
    } else {
      double value = Variant(args[0]).asReal;
      for (final Object? arg in args) {
        value = math.min(value, Variant(arg).asReal);
      }
      return value;
    }
  }

  /// This function gets the octal formatted integer as a string.
  Object _funcOct(List<Object?> args) {
    this._argCount('oct', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(8) + "o";
    throw Exception('Can not use $arg to oct(int).');
  }

  /// This function pads the string on the left side with an optional character
  /// until the string's length is equal to a specified length.
  Object _funcPadLeft(List<Object?> args) {
    if (args.length < 2 || args.length > 3) {
      throw Exception('The function padLeft requires 2 or 3 arguments but got ${args.length}.');
    }
    final Variant arg0 = Variant(args[0]);
    final Variant arg1 = Variant(args[1]);
    final Variant arg2 = Variant((args.length == 3) ? args[2] : " ");
    if (arg0.implicitStr && arg1.implicitInt && arg2.implicitStr) return arg0.asStr.padLeft(arg1.asInt, arg2.asStr);
    throw Exception('Can not use $arg0, $arg1, and $arg2 in padLeft(string, int, [string]).');
  }

  /// This function pads the string on the right side with an optional character
  /// until the string's length is equal to a specified length.
  Object _funcPadRight(List<Object?> args) {
    if (args.length < 2 || args.length > 3) {
      throw Exception('The function padRight requires 2 or 3 arguments but got ${args.length}.');
    }
    final Variant arg0 = Variant(args[0]);
    final Variant arg1 = Variant(args[1]);
    final Variant arg2 = Variant((args.length == 3) ? args[2] : " ");
    if (arg0.implicitStr && arg1.implicitInt && arg2.implicitStr) return arg0.asStr.padRight(arg1.asInt, arg2.asStr);
    throw Exception('Can not use $arg0, $arg1, and $arg2 in padRight(string, int, [string]).');
  }

  /// This function puts a random number onto the stack.
  Object _funcRand(List<Object?> args) {
    this._argCount('rand', args, 0);
    return this._rand.nextDouble();
  }

  /// This function casts the given value into a real value.
  Object _funcReal(List<Object?> args) {
    this._argCount('real', args, 1);
    final Variant arg = Variant(args[0]);
    return arg.asReal;
  }

  /// This function gets the round of the given real.
  Object _funcRound(List<Object?> args) {
    this._argCount('round', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.round();
    throw Exception('Can not use $arg in round(real).');
  }

  /// This function gets the sine of the given real.
  Object _funcSin(List<Object?> args) {
    this._argCount('sin', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.sin(arg.asReal);
    throw Exception('Can not use $arg in sin(real).');
  }

  /// This function gets the square root of the given real.
  Object _funcSqrt(List<Object?> args) {
    this._argCount('sqrt', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.sqrt(arg.asReal);
    throw Exception('Can not use $arg in sqrt(real).');
  }

  /// This function casts the given value into a string value.
  Object _funcString(List<Object?> args) {
    this._argCount('string', args, 1);
    final Variant arg = Variant(args[0]);
    return arg.asStr;
  }

  /// This function gets a substring for a given string with a start and stop integer.
  Object _funcSub(List<Object?> args) {
    this._argCount('sub', args, 3);
    final Variant arg0 = Variant(args[0]);
    final Variant arg1 = Variant(args[1]);
    final Variant arg2 = Variant(args[2]);
    if (arg0.implicitStr && arg1.implicitInt && arg2.implicitInt) return arg0.asStr.substring(arg1.asInt, arg2.asInt);
    throw Exception('Can not use $arg0, $arg1, and $arg2 in sub(string, int, int).');
  }

  /// This function gets the sum of zero or more integers or reals.
  Object _funcSum(List<Object?> args) {
    bool allInt = true;
    for (final Object? arg in args) {
      final Variant value = Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw Exception('Can not use $arg in sum(real, real, ...) or sum(int, int, ...).');
    }

    if (allInt) {
      int value = 0;
      for (final Object? arg in args) {
        value += Variant(arg).asInt;
      }
      return value;
    } else {
      double value = 0.0;
      for (final Object? arg in args) {
        value += Variant(arg).asReal;
      }
      return value;
    }
  }

  /// This function gets the tangent of the given real.
  Object _funcTan(List<Object?> args) {
    this._argCount('tan', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitReal) return math.tan(arg.asReal);
    throw Exception('Can not use $arg in tan(real).');
  }

  /// This function trims the left and right of a string.
  Object _funcTrim(List<Object?> args) {
    this._argCount('trim', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitStr) return arg.asStr.trim();
    throw Exception('Can not use $arg in trim(string).');
  }

  /// This function trims the left of a string.
  Object _funcTrimLeft(List<Object?> args) {
    this._argCount('trimLeft', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitStr) return arg.asStr.trimLeft();
    throw Exception('Can not use $arg in trimLeft(string).');
  }

  /// This function trims the right of a string.
  Object _funcTrimRight(List<Object?> args) {
    this._argCount('trimRight', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitStr) return arg.asStr.trimRight();
    throw Exception('Can not use $arg in trimRight(string).');
  }

  /// This function gets the upper case of the given string.
  Object _funcUpper(List<Object?> args) {
    this._argCount('upper', args, 1);
    final Variant arg = Variant(args[0]);
    if (arg.implicitStr) return arg.asStr.toUpperCase();
    throw Exception('Can not use $arg in upper(string).');
  }
}
