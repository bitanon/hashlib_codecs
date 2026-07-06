// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'package:hashlib_codecs/hashlib_codecs.dart';

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

class HashlibUtf8Encode extends Benchmark {
  String text = '';

  HashlibUtf8Encode(int size, int iter) : super('hashlib_codecs', size, iter);

  @override
  void setup() {
    text = makeText(size);
  }

  @override
  void run() {
    toUtf8(text);
  }
}

class ConvertUtf8Encode extends Benchmark {
  String text = '';

  ConvertUtf8Encode(int size, int iter) : super('dart:convert', size, iter);

  @override
  void setup() {
    text = makeText(size);
  }

  @override
  void run() {
    cvt.utf8.encode(text);
  }
}

class HashlibUtf8Decode extends Benchmark {
  Uint8List encoded = Uint8List(0);

  HashlibUtf8Decode(int size, int iter) : super('hashlib_codecs', size, iter);

  @override
  void setup() {
    encoded = Uint8List.fromList(cvt.utf8.encode(makeText(size)));
  }

  @override
  void run() {
    fromUtf8(encoded);
  }
}

class ConvertUtf8Decode extends Benchmark {
  Uint8List encoded = Uint8List(0);

  ConvertUtf8Decode(int size, int iter) : super('dart:convert', size, iter);

  @override
  void setup() {
    encoded = Uint8List.fromList(cvt.utf8.encode(makeText(size)));
  }

  @override
  void run() {
    cvt.utf8.decode(encoded);
  }
}

void main() {
  const size = 10 << 10; // code points; ~2.5x that in bytes
  const iter = 100;
  print('--- UTF-8 encoding (${formatSize(size)} chars x $iter) ---');
  HashlibUtf8Encode(size, iter).measureDiff([
    ConvertUtf8Encode(size, iter),
  ]);
  print('');
  print('--- UTF-8 decoding (${formatSize(size)} chars x $iter) ---');
  HashlibUtf8Decode(size, iter).measureDiff([
    ConvertUtf8Decode(size, iter),
  ]);
}
