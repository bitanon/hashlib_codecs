// Splices the freshly generated BENCHMARK.md into README.md verbatim.
//
// Everything between the `<!-- file: BENCHMARK.md -->` and
// `<!-- end BENCHMARK.md -->` markers is replaced with the full content of
// BENCHMARK.md, so the README benchmark section stays byte-for-byte identical
// to BENCHMARK.md after every benchmark run.
//
// Run with: dart run tool/sync_benchmark_readme.dart

import 'dart:io';

const startMarker = '<!-- file: BENCHMARK.md -->';
const endMarker = '<!-- end BENCHMARK.md -->';

void main() {
  final readmeFile = File('README.md');
  final benchFile = File('BENCHMARK.md');

  if (!readmeFile.existsSync()) {
    stderr.writeln('sync_benchmark_readme: README.md not found');
    exitCode = 1;
    return;
  }
  if (!benchFile.existsSync()) {
    stderr.writeln('sync_benchmark_readme: BENCHMARK.md not found');
    exitCode = 1;
    return;
  }

  final benchBody = benchFile.readAsLinesSync();

  final lines = readmeFile.readAsStringSync().split('\n');
  final output = <String>[];
  var skipping = false;
  var replaced = false;

  for (final line in lines) {
    if (line == startMarker) {
      output.add(line);
      output.addAll(benchBody);
      skipping = true;
      replaced = true;
      continue;
    }
    if (line == endMarker) {
      output.add(line);
      skipping = false;
      continue;
    }
    if (!skipping) output.add(line);
  }

  if (!replaced) {
    stderr.writeln('sync_benchmark_readme: "$startMarker" marker not found '
        'in README.md');
    exitCode = 1;
    return;
  }
  if (skipping) {
    stderr.writeln('sync_benchmark_readme: "$endMarker" marker not found '
        'in README.md');
    exitCode = 1;
    return;
  }

  readmeFile.writeAsStringSync(output.join('\n'));
  stdout.writeln('sync_benchmark_readme: README.md benchmark section updated');
}
