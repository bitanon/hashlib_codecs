// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' show Codec, Converter;

const int _zero = 48;
const int _smallA = 97;

class _BigIntLittleEndianEncoder extends Converter<Iterable<int>, BigInt> {
  const _BigIntLittleEndianEncoder();

  @override
  BigInt convert(Iterable<int> input) {
    int a, b, i, j;
    var out = <int>[];
    for (int x in input) {
      a = (x >>> 4) & 0xF;
      b = x & 0xF;
      a += a < 10 ? _zero : _smallA - 10;
      b += b < 10 ? _zero : _smallA - 10;
      out.add(b);
      out.add(a);
    }
    if (out.isEmpty) {
      throw FormatException('Empty input');
    }
    for (j = out.length - 1; j > 0; j--) {
      if (out[j] != _zero) break;
    }
    var hex = out.take(j + 1);
    for (i = 0; i < j; i++, j--) {
      a = out[i];
      out[i] = out[j];
      out[j] = a;
    }
    return BigInt.parse(String.fromCharCodes(hex), radix: 16);
  }
}

class _BigIntBigEndianEncoder extends Converter<Iterable<int>, BigInt> {
  const _BigIntBigEndianEncoder();

  @override
  BigInt convert(Iterable<int> input) {
    int a, b;
    var out = <int>[];
    for (int x in input) {
      a = (x >>> 4) & 0xF;
      b = x & 0xF;
      a += a < 10 ? _zero : _smallA - 10;
      b += b < 10 ? _zero : _smallA - 10;
      out.add(a);
      out.add(b);
    }
    if (out.isEmpty) {
      throw FormatException('Empty input');
    }
    return BigInt.parse(String.fromCharCodes(out), radix: 16);
  }
}

class _BigIntLittleEndianDecoder extends Converter<BigInt, Iterable<int>> {
  const _BigIntLittleEndianDecoder();

  @override
  Iterable<int> convert(BigInt input) sync* {
    if (input.isNegative) {
      throw FormatException('Negative numbers are not supported');
    }
    if (input == BigInt.zero) {
      yield 0;
      return;
    }
    int i, a, b;
    var bytes = input.toRadixString(16).codeUnits;
    for (i = bytes.length - 2; i >= 0; i -= 2) {
      a = bytes[i];
      b = bytes[i + 1];
      a -= a < _smallA ? _zero : _smallA - 10;
      b -= b < _smallA ? _zero : _smallA - 10;
      yield (a << 4) | b;
    }
    if (i == -1) {
      a = bytes[0];
      a -= a < _smallA ? _zero : _smallA - 10;
      yield a;
    }
  }
}

class _BigIntBigEndianDecoder extends Converter<BigInt, Iterable<int>> {
  const _BigIntBigEndianDecoder();

  @override
  Iterable<int> convert(BigInt input) sync* {
    if (input.isNegative) {
      throw FormatException('Negative numbers are not supported');
    }
    if (input == BigInt.zero) {
      yield 0;
      return;
    }
    int i, a, b, n;
    var bytes = input.toRadixString(16).codeUnits;
    n = bytes.length;
    i = 1;
    if (n & 1 == 1) {
      a = bytes[0];
      a -= a < _smallA ? _zero : _smallA - 10;
      yield a;
      i++;
    }
    for (; i < n; i += 2) {
      a = bytes[i - 1];
      b = bytes[i];
      a -= a < _smallA ? _zero : _smallA - 10;
      b -= b < _smallA ? _zero : _smallA - 10;
      yield (a << 4) | b;
    }
  }
}

class BigIntCodec extends Codec<Iterable<int>, BigInt> {
  @override
  final Converter<Iterable<int>, BigInt> encoder;

  @override
  final Converter<BigInt, Iterable<int>> decoder;

  /// Codec instance to encode and decode [BigInt] to byte sequence in
  /// big-endian order.
  const BigIntCodec.big()
      : encoder = const _BigIntBigEndianEncoder(),
        decoder = const _BigIntBigEndianDecoder();

  /// Codec instance to encode and decode [BigInt] to byte sequence in
  /// little-endian order.
  const BigIntCodec.little()
      : encoder = const _BigIntLittleEndianEncoder(),
        decoder = const _BigIntLittleEndianDecoder();
}
