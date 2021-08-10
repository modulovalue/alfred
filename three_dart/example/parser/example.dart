import 'dart:io' as io;

import 'package:three_dart/parser/calculator.dart';

void main() {
  final calc = Calculator();
  print('Enter in an equation and press enter to calculate the result.');
  print('Type "exit" to exit. See documentation for more information.');
  for (;;) {
    io.stdout.write("> ");
    final String input = io.stdin.readLineSync() ?? '';
    if (input.toLowerCase() == 'exit') {
      break;
    } else {
      calc.clear();
      calc.calculate(input);
      print(calc.stackToString);
    }
  }
}
