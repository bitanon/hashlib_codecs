// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' show Codec, Converter;
import 'dart:typed_data';

const int _zero = 0x30;
const int _smallA = 0x61;

/// A converter that encodes an 8-bit integer sequence into a [BigInt].
typedef BigIntEncoder = Converter<Iterable<int>, BigInt>;

/// A converter that decodes a [BigInt] back into an 8-bit integer sequence.
typedef BigIntDecoder = Converter<BigInt, Uint8List>;

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
  Uint8List convert(BigInt input) {
    if (input.isNegative) {
      throw FormatException('Negative numbers are not supported');
    }
    if (input == BigInt.zero) {
      return Uint8List(1);
    }
    var hex = input.toRadixString(16).codeUnits;
    int h = hex.length;
    var out = Uint8List((h + 1) >> 1);
    int i, a, b, k = 0;
    for (i = h - 2; i >= 0; i -= 2) {
      a = hex[i];
      b = hex[i + 1];
      a -= a < _smallA ? _zero : _smallA - 10;
      b -= b < _smallA ? _zero : _smallA - 10;
      out[k++] = (a << 4) | b;
    }
    if (i == -1) {
      a = hex[0];
      a -= a < _smallA ? _zero : _smallA - 10;
      out[k++] = a;
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
  Uint8List convert(BigInt input) {
    if (input.isNegative) {
      throw FormatException('Negative numbers are not supported');
    }
    if (input == BigInt.zero) {
      return Uint8List(1);
    }
    var hex = input.toRadixString(16).codeUnits;
    int n = hex.length;
    var out = Uint8List((n + 1) >> 1);
    int i = 1, a, b, k = 0;
    if (n & 1 == 1) {
      a = hex[0];
      a -= a < _smallA ? _zero : _smallA - 10;
      out[k++] = a;
      i++;
    }
    for (; i < n; i += 2) {
      a = hex[i - 1];
      b = hex[i];
      a -= a < _smallA ? _zero : _smallA - 10;
      b -= b < _smallA ? _zero : _smallA - 10;
      out[k++] = (a << 4) | b;
    }
    return out;
  }
}

// ========================================================
// BigInt Codec
// ========================================================

/// Encodes an 8-bit byte sequence into a non-negative [BigInt] and decodes it
/// back into bytes.
///
/// See [msbFirst] (big-endian) and [lsbFirst] (little-endian) for the two byte
/// orderings.
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
