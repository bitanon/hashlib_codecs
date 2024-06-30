// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' show Codec, Converter;

const int _zero = 0x30;
const int _smallA = 0x61;

typedef BigIntEncoder = Converter<Iterable<int>, BigInt>;
typedef BigIntDecoder = Converter<BigInt, Iterable<int>>;

// ========================================================
// LSB First Encoder and Decoder
// ========================================================

class _BigIntLSBFirstEncoder extends BigIntEncoder {
  const _BigIntLSBFirstEncoder();

  @override
  BigInt convert(Iterable<int> input) {
    int a, b, i, j;
    List<int> out = <int>[];
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

class _BigIntLSBFirstDecoder extends BigIntDecoder {
  const _BigIntLSBFirstDecoder();

  @override
  Iterable<int> convert(BigInt input) {
    if (input.isNegative) {
      throw FormatException('Negative numbers are not supported');
    }
    if (input == BigInt.zero) {
      return [0];
    }
    int i, a, b;
    List<int> out = <int>[];
    var bytes = input.toRadixString(16).codeUnits;
    for (i = bytes.length - 2; i >= 0; i -= 2) {
      a = bytes[i];
      b = bytes[i + 1];
      a -= a < _smallA ? _zero : _smallA - 10;
      b -= b < _smallA ? _zero : _smallA - 10;
      out.add((a << 4) | b);
    }
    if (i == -1) {
      a = bytes[0];
      a -= a < _smallA ? _zero : _smallA - 10;
      out.add(a);
    }
    return out;
  }
}

// ========================================================
// MSB First Encoder and Decoder
// ========================================================

class _BigIntMSBFirstEncoder extends BigIntEncoder {
  const _BigIntMSBFirstEncoder();

  @override
  BigInt convert(Iterable<int> input) {
    int a, b;
    List<int> out = <int>[];
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

class _BigIntMSBFirstDecoder extends BigIntDecoder {
  const _BigIntMSBFirstDecoder();

  @override
  Iterable<int> convert(BigInt input) {
    if (input.isNegative) {
      throw FormatException('Negative numbers are not supported');
    }
    if (input == BigInt.zero) {
      return [0];
    }
    int i, a, b, n;
    List<int> out = <int>[];
    var bytes = input.toRadixString(16).codeUnits;
    n = bytes.length;
    i = 1;
    if (n & 1 == 1) {
      a = bytes[0];
      a -= a < _smallA ? _zero : _smallA - 10;
      out.add(a);
      i++;
    }
    for (; i < n; i += 2) {
      a = bytes[i - 1];
      b = bytes[i];
      a -= a < _smallA ? _zero : _smallA - 10;
      b -= b < _smallA ? _zero : _smallA - 10;
      out.add((a << 4) | b);
    }
    return out;
  }
}

// ========================================================
// BigInt Codec
// ========================================================

class BigIntCodec extends Codec<Iterable<int>, BigInt> {
  @override
  final BigIntEncoder encoder;

  @override
  final BigIntDecoder decoder;

  const BigIntCodec._({
    required this.encoder,
    required this.decoder,
  });

  /// Codec instance to encode and decode 8-bit integer sequence to [BigInt]
  /// number treating the input bytes in big-endian order.
  static const BigIntCodec msbFirst = BigIntCodec._(
    encoder: _BigIntMSBFirstEncoder(),
    decoder: _BigIntMSBFirstDecoder(),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to [BigInt]
  /// number treating the input bytes in little-endian order.
  static const BigIntCodec lsbFirst = BigIntCodec._(
    encoder: _BigIntLSBFirstEncoder(),
    decoder: _BigIntLSBFirstDecoder(),
  );
}
