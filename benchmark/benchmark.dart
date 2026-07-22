// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:io';

import '_base.dart';
import 'base16.dart' as base16;
import 'base2.dart' as base2;
import 'base32.dart' as base32;
import 'base64.dart' as base64;
import 'base8.dart' as base8;
import 'bigint.dart' as bigint;
import 'utf8.dart' as utf8;

RandomAccessFile? raf;

void dump(String message) {
  raf?.writeStringSync('$message\n');
  stdout.writeln(message);
}

// ---------------------------------------------------------------------
// Codec benchmark groups
// ---------------------------------------------------------------------

/// The encoders for [size]. In every group convertlib is listed first, so it
/// is the baseline used for the ratios in a cell.
Map<String, List<Benchmark>> buildEncoders(int size) {
  return {
    "Base-2": [
      base2.ConvertlibBinaryEncode(size),
    ],
    "Base-8": [
      base8.ConvertlibOctalEncode(size),
    ],
    "Base-16": [
      base16.ConvertlibHexEncode(size),
      base16.BaseCodecsHexEncode(size),
    ],
    "Base-32": [
      base32.ConvertlibBase32Encode(size),
      base32.BaseCodecsBase32Encode(size),
      base32.Base32PackageEncode(size),
    ],
    "Base-64": [
      base64.ConvertlibBase64Encode(size),
      base64.ConvertBase64Encode(size),
    ],
    "UTF-8": [
      utf8.ConvertlibUtf8Encode(size),
      utf8.DartConvertUtf8Encode(size),
    ],
  };
}

/// The decoders for [size], mirroring [buildEncoders].
Map<String, List<Benchmark>> buildDecoders(int size) {
  return {
    "Base-2": [
      base2.ConvertlibBinaryDecode(size),
    ],
    "Base-8": [
      base8.ConvertlibOctalDecode(size),
    ],
    "Base-16": [
      base16.ConvertlibHexDecode(size),
      base16.BaseCodecsHexDecode(size),
    ],
    "Base-32": [
      base32.ConvertlibBase32Decode(size),
      base32.BaseCodecsBase32Decode(size),
      base32.Base32PackageDecode(size),
    ],
    "Base-64": [
      base64.ConvertlibBase64Decode(size),
      base64.ConvertBase64Decode(size),
    ],
    "UTF-8": [
      utf8.ConvertlibUtf8Decode(size),
      utf8.DartConvertUtf8Decode(size),
    ],
  };
}

/// The BigInt conversions for [size] bytes. BigInt arithmetic is superlinear,
/// so this group is measured over smaller payloads than the codec groups.
Map<String, List<Benchmark>> buildBigInt(int size) {
  return {
    "bytes → BigInt": [
      bigint.ConvertlibBigIntEncode(size),
    ],
    "BigInt → bytes": [
      bigint.ConvertlibBigIntDecode(size),
    ],
  };
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

/// A fixed-[width] block-character bar for [speed] relative to [best], giving
/// each cell a proportional visual next to its number. A nonzero speed always
/// fills at least one block so it stays visible.
String buildBar(double speed, double best, [int width = 16]) {
  var filled = best <= 0 ? 0 : (speed / best * width).round();
  if (filled < 1) filled = 1;
  if (filled > width) filled = width;
  var full = '█' * filled + '░' * (width - filled);
  return '<code>$full</code>';
}

/// Renders one benchmark cell: a proportional bar, the speed, a medal when it
/// is the fastest ([best]) in this column, and for non-[baseline] rows, the
/// speed ratio against convertlib's [mine].
String formatCell(Measurement result, double best, double mine, bool baseline) {
  var icon = '';

  var speed = result.speedString;
  if (result.speed == best) {
    icon = '&#127775;';
    speed = '<b>$speed</b>';
  }

  var compare = '';
  if (!baseline) {
    if (mine > result.speed) {
      icon = '&#128315;'; // slow
      compare = formatDecimal(mine / result.speed);
    } else if (mine < result.speed) {
      icon = '&#128314;'; // fast
      compare = formatDecimal(result.speed / mine);
    }
    if (compare.isNotEmpty) {
      compare += 'x';
    }
  }

  var line1 = buildBar(result.speed, best);
  var line2 = '<small>$speed $icon$compare</small>'.trim();
  return '$line1 <br> $line2';
}

/// Prints one HTML comparison table. Rows are `(codec, library)` pairs - the
/// codec name spans its libraries with `rowspan` - with one data column per
/// entry in [columns], built by [build] for that column. convertlib is listed
/// first in each row group and is the baseline for the ratios.
Future<void> measureTable(
  List<String> columns,
  Map<String, List<Benchmark>> Function(int column) build,
) async {
  var maps = [for (var i = 0; i < columns.length; i++) build(i)];

  dump('<table>');
  dump('<thead>');
  dump('  <tr>');
  dump('    <th>Codec</th>');
  dump('    <th>Library</th>');
  for (final col in columns) {
    dump('    <th>$col</th>');
  }
  dump('  </tr>');
  dump('</thead>');
  dump('<tbody>');

  for (var name in maps.first.keys) {
    // measure every (library, column) and find the fastest library per column
    var results = <List<Measurement>>[];
    var best = <double>[];
    for (var map in maps) {
      var row = <Measurement>[];
      var top = 0.0;
      for (var benchmark in map[name]!) {
        var result = await measure(benchmark);
        row.add(result);
        if (result.speed > top) top = result.speed;
      }
      results.add(row);
      best.add(top);
    }

    // one row per library; the codec name spans them via rowspan
    var libraries = maps.first[name]!;
    for (var li = 0; li < libraries.length; li++) {
      dump('  <tr>');
      if (li == 0) {
        var span = libraries.length > 1 ? ' rowspan="${libraries.length}"' : '';
        dump('    <td$span>$name</td>');
      }
      dump('    <td>${libraries[li].name}</td>');
      for (var ci = 0; ci < maps.length; ci++) {
        var mine = results[ci].first.speed;
        var cell = formatCell(results[ci][li], best[ci], mine, li == 0);
        dump('    <td>$cell</td>');
      }
      dump('  </tr>');
    }
  }
  dump('</tbody>');
  dump('</table>');
  dump('');
}

Future<void> measureSection(
  String title,
  List<int> columns,
  String Function(int column) header,
  Map<String, List<Benchmark>> Function(int column) build,
) async {
  dump('### $title');
  dump('');
  await measureTable(
    [for (var column in columns) header(column)],
    (i) => build(columns[i]),
  );
  dump('');
}

// ---------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------

final messageSizes = [1 << 20, 1 << 10, 1 << 5];
final bigintSizes = [1 << 12, 1 << 8, 1 << 5];
String sizeHeader(int size) => '${formatSize(size)} message';

void dumpHeaders() {
  dump("## 🚀 Benchmarks");
  dump('');
  dump("### Libraries");
  dump('');
  dump("- **Convertlib** : https://pub.dev/packages/convertlib");
  dump("- **Base Codecs** : https://pub.dev/packages/base_codecs");
  dump("- **Base32** : https://pub.dev/packages/base32");
  dump(
      "- **Dart Convert** : https://api.dart.dev/stable/dart-convert/dart-convert-library.html");
  dump('');
  dump("> UTF-8 throughput is measured per source code point, not per byte.");
  dump('');
}

void main(List<String> args) async {
  if (args.isNotEmpty) {
    try {
      stdout.writeln('Opening output file: ${args[0]}');
      raf = File(args[0]).openSync(mode: FileMode.writeOnly);
    } catch (err) {
      stderr.writeln(err);
    }
    stdout.writeln('----------------------------------------');
  }

  dumpHeaders();
  raf?.flushSync();

  await measureSection(
    'Encoding',
    messageSizes,
    sizeHeader,
    buildEncoders,
  );
  raf?.flushSync();

  await measureSection(
    'Decoding',
    messageSizes,
    sizeHeader,
    buildDecoders,
  );
  raf?.flushSync();

  await measureSection(
    'BigInt',
    bigintSizes,
    sizeHeader,
    buildBigInt,
  );
  raf?.flushSync();

  raf?.closeSync();
}
