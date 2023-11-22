import 'package:alfred/bluffer/publish/publish.dart';
import 'package:alfred/bluffer/systems/flutter.dart';
import 'package:test/test.dart';

void main() {
  group("bluffer tests", () {
    test("smoketest", () {
      expect(
        single_page(
          builder: (final context) => const TableImpl(
            children: [
              TableRowImpl(
                children: [
                  TableHeadImpl(
                    child: Text("A"),
                  ),
                  TableHeadImpl(
                    child: Text("B"),
                  ),
                  TableHeadImpl(
                    child: Text("C"),
                  ),
                ],
              ),
              TableRowImpl(
                children: [
                  TableDataImpl(
                    child: Text("1"),
                  ),
                  TableDataImpl(
                    child: Text("2"),
                  ),
                  TableDataImpl(
                    child: Text("3"),
                  ),
                ],
              ),
              TableRowImpl(
                children: [
                  TableDataImpl(
                    child: Text("a"),
                  ),
                  TableDataImpl(
                    child: Text("b"),
                  ),
                  TableDataImpl(
                    child: Text("c"),
                  ),
                ],
              ),
            ],
          ),
        ),
        '<table><tr><th><p class="_w0">A</p></th>\n'
        '<th><p class="_w1">B</p></th>\n'
        '<th><p class="_w2">C</p></th></tr>\n'
        '<tr><td><p class="_w3">1</p></td>\n'
        '<td><p class="_w4">2</p></td>\n'
        '<td><p class="_w5">3</p></td></tr>\n'
        '<tr><td><p class="_w6">a</p></td>\n'
        '<td><p class="_w7">b</p></td>\n'
        '<td><p class="_w8">c</p></td></tr></table>',
      );
    });
    test("smoketest2", () {
      expect(
        single_page(
          builder: (final context) => const Row(
            children: [
              Text("a"),
              Text("b"),
            ],
          ),
        ),
        '<div><p>a</p>\n'
        '<p>b</p></div>'
      );
    });
  });
}
