// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:convertlib/convertlib.dart';

import '_base.dart';

class ConvertlibOctalEncode extends SyncBenchmark {
  final Uint8List input;

  ConvertlibOctalEncode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void run() {
    toOctal(input);
  }
}

class ConvertlibOctalDecode extends SyncBenchmark {
  final Uint8List input;
  String encoded = '';

  ConvertlibOctalDecode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void setup() {
    encoded = toOctal(input);
  }

  @override
  void run() {
    fromOctal(encoded);
  }
}

void main() async {
  print('--------- Base-8 (Octal) ----------');
  for (var size in [1 << 20, 1 << 10, 1 << 5]) {
    print('---- encode: ${formatSize(size)} ----');
    await ConvertlibOctalEncode(size).measureRate();
    print('---- decode: ${formatSize(size)} ----');
    await ConvertlibOctalDecode(size).measureRate();
    print('');
  }
}
