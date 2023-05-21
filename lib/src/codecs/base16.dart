// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/codec.dart';
import 'package:hashlib_codecs/src/core/converter.dart';

const int _zero = 48;
const int _bigA = 65;
const int _smallA = 97;

class _B16Encoder extends Uint8Encoder {
  final int startCode;

  const _B16Encoder._(this.startCode)
      : super(
          bits: 4,
          alphabet: const <int>[],
        );

  static const upper = _B16Encoder._(_bigA - 10);
  static const lower = _B16Encoder._(_smallA - 10);

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

class _B16Decoder extends Uint8Decoder {
  const _B16Decoder()
      : super(
          bits: 4,
          alphabet: const <int>[],
        );

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

class B16Codec extends Uint8Codec {
  @override
  final Uint8Encoder encoder;

  @override
  final decoder = const _B16Decoder();

  /// Codec instance to encode and decode 8-bit integer sequence to Base-16
  /// or Hexadecimal character sequence using the uppercase alphabet.
  const B16Codec() : encoder = _B16Encoder.upper;

  /// Codec instance to encode and decode 8-bit integer sequence to Base-16
  /// or Hexadecimal character sequence using the lowercase alphabet.
  const B16Codec.lower() : encoder = _B16Encoder.lower;
}
