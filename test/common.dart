import 'package:alfred/base.dart';

extension AlfredTestExtension on Alfred {
  Future<int> listenForTest() async {
    await listen(0);
    return server!.port;
  }
}
