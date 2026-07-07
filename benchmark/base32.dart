// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:base32/base32.dart' as b32;
import 'package:base_codecs/base_codecs.dart' as bc;
import 'package:convertlib/convertlib.dart';

import '_base.dart';

class ConvertlibBase32Encode extends SyncBenchmark {
  final Uint8List input;

  ConvertlibBase32Encode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void run() {
    toBase32(input);
  }
}

class BaseCodecsBase32Encode extends SyncBenchmark {
  final Uint8List input;

  BaseCodecsBase32Encode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('base_codecs', size);

  @override
  void run() {
    bc.base32RfcEncode(input);
  }
}

class Base32PackageEncode extends SyncBenchmark {
  final Uint8List input;

  Base32PackageEncode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('base32', size);

  @override
  void run() {
    b32.base32.encode(input);
  }
}

class ConvertlibBase32Decode extends SyncBenchmark {
  final Uint8List input;
  String encoded = '';

  ConvertlibBase32Decode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('convertlib', size);

  @override
  void setup() {
    encoded = toBase32(input);
  }

  @override
  void run() {
    fromBase32(encoded);
  }
}

class BaseCodecsBase32Decode extends SyncBenchmark {
  final Uint8List input;
  String encoded = '';

  BaseCodecsBase32Decode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('base_codecs', size);

  @override
  void setup() {
    encoded = toBase32(input);
  }

  @override
  void run() {
    bc.base32RfcDecode(encoded);
  }
}

class Base32PackageDecode extends SyncBenchmark {
  final Uint8List input;
  String encoded = '';

  Base32PackageDecode(int size)
      : input = Uint8List.fromList(List.filled(size, 0x3f)),
        super('base32', size);

  @override
  void setup() {
    encoded = toBase32(input);
  }

  @override
  void run() {
    b32.base32.decode(encoded);
  }
}

void main() async {
  print('--------- Base-32 ----------');
  for (var size in [1 << 20, 1 << 10, 1 << 5]) {
    print('---- encode: ${formatSize(size)} ----');
    await ConvertlibBase32Encode(size).measureDiff([
      BaseCodecsBase32Encode(size),
      Base32PackageEncode(size),
    ]);
    print('---- decode: ${formatSize(size)} ----');
    await ConvertlibBase32Decode(size).measureDiff([
      BaseCodecsBase32Decode(size),
      Base32PackageDecode(size),
    ]);
    print('');
  }
}
