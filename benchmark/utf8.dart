// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'package:convertlib/convertlib.dart';

import '_base.dart';

/// Deterministic text mixing 1, 2, 3, and 4-byte UTF-8 sequences.
String makeText(int length) {
  var codes = List<int>.generate(length, (i) {
    switch (i & 3) {
      case 0:
        return 0x41 + (i % 26); // 1-byte: A-Z
      case 1:
        return 0x100 + (i % 0x600); // 2-byte: Latin extended and beyond
      case 2:
        return 0x4E00 + (i % 0x1000); // 3-byte: CJK
      default:
        return 0x1F300 + (i % 0x100); // 4-byte: emoji
    }
  });
  return String.fromCharCodes(codes);
}

class ConvertlibUtf8Encode extends SyncBenchmark {
  final String text;

  ConvertlibUtf8Encode(int size)
      : text = makeText(size),
        super('convertlib', size);

  @override
  void run() {
    toUtf8(text);
  }
}

class ConvertUtf8Encode extends SyncBenchmark {
  final String text;

  ConvertUtf8Encode(int size)
      : text = makeText(size),
        super('dart:convert', size);

  @override
  void run() {
    cvt.utf8.encode(text);
  }
}

class ConvertlibUtf8Decode extends SyncBenchmark {
  final Uint8List encoded;

  ConvertlibUtf8Decode(int size)
      : encoded = Uint8List.fromList(cvt.utf8.encode(makeText(size))),
        super('convertlib', size);

  @override
  void run() {
    fromUtf8(encoded);
  }
}

class ConvertUtf8Decode extends SyncBenchmark {
  final Uint8List encoded;

  ConvertUtf8Decode(int size)
      : encoded = Uint8List.fromList(cvt.utf8.encode(makeText(size))),
        super('dart:convert', size);

  @override
  void run() {
    cvt.utf8.decode(encoded);
  }
}

void main() async {
  // Size counts source code points; throughput is reported per code point.
  print('--------- UTF-8 ----------');
  for (var size in [1 << 20, 1 << 10, 1 << 5]) {
    print('---- encode: ${formatSize(size)} chars ----');
    await ConvertlibUtf8Encode(size).measureDiff([
      ConvertUtf8Encode(size),
    ]);
    print('---- decode: ${formatSize(size)} chars ----');
    await ConvertlibUtf8Decode(size).measureDiff([
      ConvertUtf8Decode(size),
    ]);
    print('');
  }
}
