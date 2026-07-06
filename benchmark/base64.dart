// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' as cvt;

import 'package:hashlib_codecs/hashlib_codecs.dart';

import '_base.dart';

class HashlibBase64Encode extends Benchmark {
  HashlibBase64Encode(int size, int iter) : super('hashlib_codecs', size, iter);

  @override
  void run() {
    toBase64(input);
  }
}

class ConvertBase64Encode extends Benchmark {
  ConvertBase64Encode(int size, int iter) : super('dart:convert', size, iter);

  @override
  void run() {
    cvt.base64.encode(input);
  }
}

class HashlibBase64Decode extends Benchmark {
  String encoded = '';

  HashlibBase64Decode(int size, int iter) : super('hashlib_codecs', size, iter);

  @override
  void setup() {
    encoded = toBase64(input);
  }

  @override
  void run() {
    fromBase64(encoded);
  }
}

class ConvertBase64Decode extends Benchmark {
  String encoded = '';

  ConvertBase64Decode(int size, int iter) : super('dart:convert', size, iter);

  @override
  void setup() {
    encoded = toBase64(input);
  }

  @override
  void run() {
    cvt.base64.decode(encoded);
  }
}

void main() {
  const size = 10 << 10;
  const iter = 100;
  print('--- Base-64 encoding (${formatSize(size)} x $iter) ---');
  HashlibBase64Encode(size, iter).measureDiff([
    ConvertBase64Encode(size, iter),
  ]);
  print('');
  print('--- Base-64 decoding (${formatSize(size)} x $iter) ---');
  HashlibBase64Decode(size, iter).measureDiff([
    ConvertBase64Decode(size, iter),
  ]);
}
