// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:base_codecs/base_codecs.dart' as bc;
import 'package:convertlib/convertlib.dart';

import '_base.dart';

class ConvertlibHexEncode extends SyncBenchmark {
  final Uint8List input;

  ConvertlibHexEncode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void run() {
    toHex(input);
  }
}

class BaseCodecsHexEncode extends SyncBenchmark {
  final Uint8List input;

  BaseCodecsHexEncode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('base_codecs', size);

  @override
  void run() {
    bc.base16Encode(input);
  }
}

class ConvertlibHexDecode extends SyncBenchmark {
  final Uint8List input;
  String encoded = '';

  ConvertlibHexDecode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void setup() {
    encoded = toHex(input);
  }

  @override
  void run() {
    fromHex(encoded);
  }
}

class BaseCodecsHexDecode extends SyncBenchmark {
  final Uint8List input;
  String encoded = '';

  BaseCodecsHexDecode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('base_codecs', size);

  @override
  void setup() {
    encoded = toHex(input);
  }

  @override
  void run() {
    bc.base16Decode(encoded);
  }
}

void main() async {
  print('--------- Base-16 ----------');
  for (var size in [1 << 20, 1 << 10, 1 << 5]) {
    print('---- encode: ${formatSize(size)} ----');
    await ConvertlibHexEncode(size).measureDiff([
      BaseCodecsHexEncode(size),
    ]);
    print('---- decode: ${formatSize(size)} ----');
    await ConvertlibHexDecode(size).measureDiff([
      BaseCodecsHexDecode(size),
    ]);
    print('');
  }
}
