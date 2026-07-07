// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'package:convertlib/convertlib.dart';

import '_base.dart';

class ConvertlibBase64Encode extends SyncBenchmark {
  final Uint8List input;

  ConvertlibBase64Encode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void run() {
    toBase64(input);
  }
}

class ConvertBase64Encode extends SyncBenchmark {
  final Uint8List input;

  ConvertBase64Encode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('dart:convert', size);

  @override
  void run() {
    cvt.base64.encode(input);
  }
}

class ConvertlibBase64Decode extends SyncBenchmark {
  final Uint8List input;
  String encoded = '';

  ConvertlibBase64Decode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void setup() {
    encoded = toBase64(input);
  }

  @override
  void run() {
    fromBase64(encoded);
  }
}

class ConvertBase64Decode extends SyncBenchmark {
  final Uint8List input;
  String encoded = '';

  ConvertBase64Decode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('dart:convert', size);

  @override
  void setup() {
    encoded = toBase64(input);
  }

  @override
  void run() {
    cvt.base64.decode(encoded);
  }
}

void main() async {
  print('--------- Base-64 ----------');
  for (var size in [1 << 20, 1 << 10, 1 << 5]) {
    print('---- encode: ${formatSize(size)} ----');
    await ConvertlibBase64Encode(size).measureDiff([
      ConvertBase64Encode(size),
    ]);
    print('---- decode: ${formatSize(size)} ----');
    await ConvertlibBase64Decode(size).measureDiff([
      ConvertBase64Decode(size),
    ]);
    print('');
  }
}
