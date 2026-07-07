// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:convertlib/convertlib.dart';

import '_base.dart';

class ConvertlibBinaryEncode extends SyncBenchmark {
  final Uint8List input;

  ConvertlibBinaryEncode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void run() {
    toBinary(input);
  }
}

class ConvertlibBinaryDecode extends SyncBenchmark {
  final Uint8List input;
  String encoded = '';

  ConvertlibBinaryDecode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void setup() {
    encoded = toBinary(input);
  }

  @override
  void run() {
    fromBinary(encoded);
  }
}

void main() async {
  print('--------- Base-2 (Binary) ----------');
  for (var size in [1 << 20, 1 << 10, 1 << 5]) {
    print('---- encode: ${formatSize(size)} ----');
    await ConvertlibBinaryEncode(size).measureRate();
    print('---- decode: ${formatSize(size)} ----');
    await ConvertlibBinaryDecode(size).measureRate();
    print('');
  }
}
