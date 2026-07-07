// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:base32/base32.dart' as b32;
import 'package:base_codecs/base_codecs.dart' as bc;
import 'package:convertlib/convertlib.dart';

import '_base.dart';

class HashlibBase32Encode extends Benchmark {
  HashlibBase32Encode(int size, int iter) : super('convertlib', size, iter);

  @override
  void run() {
    toBase32(input);
  }
}

class BaseCodecsBase32Encode extends Benchmark {
  Uint8List data = Uint8List(0);

  BaseCodecsBase32Encode(int size, int iter) : super('base_codecs', size, iter);

  @override
  void setup() {
    data = Uint8List.fromList(input);
  }

  @override
  void run() {
    bc.base32RfcEncode(data);
  }
}

class Base32PackageEncode extends Benchmark {
  Uint8List data = Uint8List(0);

  Base32PackageEncode(int size, int iter) : super('base32', size, iter);

  @override
  void setup() {
    data = Uint8List.fromList(input);
  }

  @override
  void run() {
    b32.base32.encode(data);
  }
}

class HashlibBase32Decode extends Benchmark {
  String encoded = '';

  HashlibBase32Decode(int size, int iter) : super('convertlib', size, iter);

  @override
  void setup() {
    encoded = toBase32(input);
  }

  @override
  void run() {
    fromBase32(encoded);
  }
}

class BaseCodecsBase32Decode extends Benchmark {
  String encoded = '';

  BaseCodecsBase32Decode(int size, int iter) : super('base_codecs', size, iter);

  @override
  void setup() {
    encoded = toBase32(input);
  }

  @override
  void run() {
    bc.base32RfcDecode(encoded);
  }
}

class Base32PackageDecode extends Benchmark {
  String encoded = '';

  Base32PackageDecode(int size, int iter) : super('base32', size, iter);

  @override
  void setup() {
    encoded = toBase32(input);
  }

  @override
  void run() {
    b32.base32.decode(encoded);
  }
}

void main() {
  const size = 10 << 10;
  const iter = 100;
  print('--- Base-32 encoding (${formatSize(size)} x $iter) ---');
  HashlibBase32Encode(size, iter).measureDiff([
    BaseCodecsBase32Encode(size, iter),
    Base32PackageEncode(size, iter),
  ]);
  print('');
  print('--- Base-32 decoding (${formatSize(size)} x $iter) ---');
  HashlibBase32Decode(size, iter).measureDiff([
    BaseCodecsBase32Decode(size, iter),
    Base32PackageDecode(size, iter),
  ]);
}
