// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:hashlib_codecs/src/core/byte.dart';
import 'package:hashlib_codecs/src/core/codec.dart';

const int _zero = 0x30;
const int _bigA = 0x41;
const int _smallA = 0x61;

extension on List<int> {
  @pragma('vm:prefer-inline')
  int dec(int p) {
    int x = this[p] & 0xFF;
    if (x >= _smallA) {
      x -= _smallA - 10;
    } else if (x >= _bigA) {
      x -= _bigA - 10;
    } else {
      x -= _zero;
    }
    if (x < 0 || x > 15) {
      throw FormatException('Invalid character at $p');
    }
    return x;
  }
}

// ========================================================
// Base-16 Encoder and Decoder
// ========================================================

class _Base16Encoder extends ByteEncoder {
  final int startCode;

  const _Base16Encoder._(this.startCode) : super(bits: 4);

  static const upper = _Base16Encoder._(_bigA - 10);
  static const lower = _Base16Encoder._(_smallA - 10);

  @override
  Uint8List convert(List<int> input) {
    int i, p, x, a, b;
    var out = Uint8List(input.length << 1);
    for (i = p = 0; p < input.length; p++, i += 2) {
      x = input[p];
      a = (x >>> 4) & 0xF;
      b = x & 0xF;
      a += a < 10 ? _zero : startCode;
      b += b < 10 ? _zero : startCode;
      out[i] = a;
      out[i + 1] = b;
    }
    return out;
  }
}

class _Base16Decoder extends ByteDecoder {
  const _Base16Decoder() : super(bits: 4);

  @override
  Uint8List convert(List<int> encoded) {
    int p, n;

    n = encoded.length;
    p = (n >>> 1) + (n & 1);
    var out = Uint8List(p);

    for (p--; n >= 2; n -= 2, p--) {
      out[p] = encoded.dec(n - 1) ^ //
          (encoded.dec(n - 2) << 4);
    }

    if (n == 1) {
      out[p] = encoded.dec(0);
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
