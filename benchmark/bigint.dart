// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:convertlib/convertlib.dart';

import '_base.dart';

/// A big-endian byte pattern that avoids leading zeros so the round-trip
/// preserves [size] bytes in both directions.
Uint8List makeBytes(int size) {
  return Uint8List.fromList(
    List.generate(size, (i) => 0x80 | (i & 0x7f)),
  );
}

class ConvertlibBigIntEncode extends SyncBenchmark {
  final Uint8List input;

  ConvertlibBigIntEncode(int size)
      : input = makeBytes(size),
        super('convertlib', size);

  @override
  void run() {
    toBigInt(input);
  }
}

class ConvertlibBigIntDecode extends SyncBenchmark {
  final Uint8List input;
  BigInt value = BigInt.zero;

  ConvertlibBigIntDecode(int size)
      : input = makeBytes(size),
        super('convertlib', size);

  @override
  void setup() {
    value = toBigInt(input);
  }

  @override
  void run() {
    fromBigInt(value);
  }
}

void main() async {
  print('--------- BigInt ----------');
  for (var size in [1 << 16, 1 << 10, 1 << 5]) {
    print('---- bytes -> BigInt: ${formatSize(size)} ----');
    await ConvertlibBigIntEncode(size).measureRate();
    print('---- BigInt -> bytes: ${formatSize(size)} ----');
    await ConvertlibBigIntDecode(size).measureRate();
    print('');
  }
}
