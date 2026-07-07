// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:base_codecs/base_codecs.dart' as bc;
import 'package:convertlib/convertlib.dart';

import '_base.dart';

class HashlibHexEncode extends Benchmark {
  HashlibHexEncode(int size, int iter) : super('convertlib', size, iter);

  @override
  void run() {
    toHex(input);
  }
}

class BaseCodecsHexEncode extends Benchmark {
  Uint8List data = Uint8List(0);

  BaseCodecsHexEncode(int size, int iter) : super('base_codecs', size, iter);

  @override
  void setup() {
    data = Uint8List.fromList(input);
  }

  @override
  void run() {
    bc.base16Encode(data);
  }
}

class HashlibHexDecode extends Benchmark {
  String encoded = '';

  HashlibHexDecode(int size, int iter) : super('convertlib', size, iter);

  @override
  void setup() {
    encoded = toHex(input);
  }

  @override
  void run() {
    fromHex(encoded);
  }
}

class BaseCodecsHexDecode extends Benchmark {
  String encoded = '';

  BaseCodecsHexDecode(int size, int iter) : super('base_codecs', size, iter);

  @override
  void setup() {
    encoded = toHex(input);
  }

  @override
  void run() {
    bc.base16Decode(encoded);
  }
}

void main() {
  const size = 10 << 10;
  const iter = 100;
  print('--- Base-16 encoding (${formatSize(size)} x $iter) ---');
  HashlibHexEncode(size, iter).measureDiff([
    BaseCodecsHexEncode(size, iter),
  ]);
  print('');
  print('--- Base-16 decoding (${formatSize(size)} x $iter) ---');
  HashlibHexDecode(size, iter).measureDiff([
    BaseCodecsHexDecode(size, iter),
  ]);
}
