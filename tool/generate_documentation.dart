import 'dart:io';

void main() {
  process(File('tool/templates/README.md'), File('README.md'));
  Directory('tool/templates/documentation').listSync().forEach((file) {
    if (file.path.endsWith('.md')) {
      final name = file.path.split('/').last;
      process(file as File, File('documentation/$name'));
    }
  });
}

void process(File file, File to) {
  var lines = file.readAsLinesSync();
  lines = codeMacro(lines);
  to.writeAsStringSync(lines.join('\n'));
}

List<String> codeMacro(List<String> lines) {
  final result = <String>[];
  for (final line in lines) {
    if (line.trim().startsWith('@code')) {
      final path = line.substring(line.indexOf('@code') + '@code'.length).trim();
      final file = File(path);
      final extension = file.path.substring(file.path.lastIndexOf('.') + '.'.length);
      final code = file.readAsStringSync().trim().split('\n');
      result.add('```$extension');
      result.addAll(code);
      result.add('```');
    } else {
      result.add(line);
    }
  }
  return result;
}
