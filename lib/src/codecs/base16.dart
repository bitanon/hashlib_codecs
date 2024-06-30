// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:hashlib_codecs/src/core/byte.dart';
import 'package:hashlib_codecs/src/core/codec.dart';

// ========================================================
// Base-16 Encoder and Decoder
// ========================================================

const int _zero = 0x30;
const int _bigA = 0x41;
const int _smallA = 0x61;

class _Base16Encoder extends ByteEncoder {
  final int startCode;

  const _Base16Encoder._(this.startCode) : super(bits: 4);

  static const upper = _Base16Encoder._(_bigA - 10);
  static const lower = _Base16Encoder._(_smallA - 10);

  @override
  Iterable<int> convert(Iterable<int> input) {
    int i, p, x, a, b;
    List<int> list = input is List<int> ? input : List.of(input);
    var result = Uint8List(list.length << 1);
    for (i = p = 0; p < list.length; p++, i += 2) {
      x = list[p];
      a = (x >>> 4) & 0xF;
      b = x & 0xF;
      a += a < 10 ? _zero : startCode;
      b += b < 10 ? _zero : startCode;
      result[i] = a;
      result[i + 1] = b;
    }
    return result;
  }
}

class _Base16Decoder extends ByteDecoder {
  const _Base16Decoder() : super(bits: 4);

  @override
  Iterable<int> convert(Iterable<int> input) {
    bool t;
    int p, x, y;
    p = 0;
    t = false;
    List<int> out = <int>[];
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
        out.add((p << 4) | x);
        p = 0;
        t = false;
      } else {
        p = x;
        t = true;
      }
    }
    if (t) {
      out.add(p);
    }
    return out;
  }
}

// ========================================================
// Base-16 Codec
// ========================================================

class Base16Codec extends IterableCodec {
  @override
  final ByteEncoder encoder;

  @override
  final ByteDecoder decoder;

  const Base16Codec._({
    required this.encoder,
    required this.decoder,
  });

  /// Codec instance to encode and decode 8-bit integer sequence to 4-bit
  /// Base-16 or Hexadecimal character sequence using the alphabet:
  /// ```
  /// 0123456789ABCDEF
  /// ```
  static const Base16Codec upper = Base16Codec._(
    encoder: _Base16Encoder.upper,
    decoder: _Base16Decoder(),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 4-bit
  /// Base-16 or Hexadecimal character sequence using the alphabet:
  /// ```
  /// 0123456789abcdef
  /// ```
  static const Base16Codec lower = Base16Codec._(
    encoder: _Base16Encoder.lower,
    decoder: _Base16Decoder(),
  );
}
