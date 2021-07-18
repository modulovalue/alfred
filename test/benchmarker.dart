import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';
import 'package:queue/queue.dart';

// TODO repair this and have a comparison against a version without queue.
Future<void> main() async {
  final pdfUri = Uri.parse('http://localhost:3000/files/dummy.pdf');
  final stopwatch = Stopwatch()..start();
  final queue = Queue(parallel: 500);
  for (var i = 0; i < 10000; i++) {
    unawaited(
      queue.add(
        () => http.get(pdfUri),
      ),
    );
  }
  await queue.onComplete;
  print(stopwatch.elapsed);
}
