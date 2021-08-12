import 'package:test/test.dart';

void Function(T) texpect<T>(T a) => (final b) => expect(a, b);
