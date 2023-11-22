import 'package:alfred/bluffer/base/text.dart';
import 'package:alfred/bluffer/publish/publish.dart';
import 'package:alfred/bluffer/systems/flutter.dart';
import 'package:alfred/bluffer/widget/widget.dart';

void main() {
  print(
    const Row(
      children: [
        Text("a", textAlign: TextAlign.start),
        Text("b"),
      ],
    ).renderCss(
      context: BuildContextImpl(assets: const AssetsDefaultSinglePageImpl(), styles: {}),
    ),
  );
  print(
    single_page(
      builder: (final context) => const Row(
        children: [
          Text("a", textAlign: TextAlign.start),
          Text("b"),
        ],
      ),
    ),
  );
}
