// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/codec.dart';
import 'package:hashlib_codecs/src/core/bit_converter.dart';

const int _zero = 0x30;
const int _bigA = 0x41;
const int _smallA = 0x61;

// ========================================================
// Base-16 Converters
// ========================================================

class _Base16Encoder extends BitEncoder {
  final int startCode;

  const _Base16Encoder._(this.startCode);

  static const upper = _Base16Encoder._(_bigA - 10);
  static const lower = _Base16Encoder._(_smallA - 10);

  @override
  final int source = 8;

  @override
  final int target = 4;

  @override
  Iterable<int> convert(Iterable<int> input) sync* {
    int a, b;
    for (int x in input) {
      a = (x >>> 4) & 0xF;
      b = x & 0xF;
      a += a < 10 ? _zero : startCode;
      b += b < 10 ? _zero : startCode;
      yield a;
      yield b;
    }
  }
}

class _Base16Decoder extends BitDecoder {
  const _Base16Decoder();

  @override
  final int source = 4;

  @override
  final int target = 8;

  @override
  Iterable<int> convert(Iterable<int> input) sync* {
    bool t;
    int p, x, y;
    p = 0;
    t = false;
    for (y in input) {
      if (y >= _smallA) {
        x = y - _smallA + 10;
      } else if (y >= _bigA) {
        x = y - _bigA + 10;
      } else if (y >= _zero) {
        x = y - _zero;
      } else {
        x = -1;
      }
      if (x < 0 || x > 15) {
        throw FormatException('Invalid character $y');
      }
      if (t) {
        yield ((p << 4) | x);
        p = 0;
        t = false;
      } else {
        p = x;
        t = true;
      }
    }
    if (t) {
      yield p;
    }
  }
}

// ========================================================
// Base-16 Codec
// ========================================================

class Base16Codec extends ByteCodec {
  @override
  final BitEncoder encoder;

  @override
  final decoder = const _Base16Decoder();

  /// Codec instance to encode and decode 8-bit integer sequence to Base-16
  /// or Hexadecimal character sequence using the uppercase alphabet.
  const Base16Codec() : encoder = _Base16Encoder.upper;

  /// Codec instance to encode and decode 8-bit integer sequence to Base-16
  /// or Hexadecimal character sequence using the lowercase alphabet.
  const Base16Codec.lower() : encoder = _Base16Encoder.lower;
}
