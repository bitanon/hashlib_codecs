// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:hashlib_codecs/src/core/byte.dart';
import 'package:hashlib_codecs/src/core/codec.dart';

const int _zero = 0x30;

extension on List<int> {
  @pragma('vm:prefer-inline')
  int enc(int n) =>
      (this[n - 1] & 0xFF) ^
      ((this[n - 2] & 0xFF) << 8) ^
      ((this[n - 3] & 0xFF) << 16);

  @pragma('vm:prefer-inline')
  int dec(int p) {
    int x = (this[p] & 0xFF) - _zero;
    if (x < 0 || x > 7) {
      throw FormatException('Invalid character at $p');
    }
    return x;
  }
}

// ========================================================
// Base-8 Encoder & Decoder
// ========================================================

class _Base8Encoder extends ByteEncoder {
  const _Base8Encoder() : super(bits: 3);

  @override
  Uint8List convert(List<int> input) {
    int p, x, n, nb;
    n = input.length;
    nb = n << 3;
    p = nb ~/ 3;
    if ((3 * p) != nb) p++;
    var out = Uint8List(p);

    for (; n >= 3; n -= 3, p -= 8) {
      x = input.enc(n);
      out[p - 1] = _zero + ((x) & 7);
      out[p - 2] = _zero + ((x >>> 3) & 7);
      out[p - 3] = _zero + ((x >>> 6) & 7);
      out[p - 4] = _zero + ((x >>> 9) & 7);
      out[p - 5] = _zero + ((x >>> 12) & 7);
      out[p - 6] = _zero + ((x >>> 15) & 7);
      out[p - 7] = _zero + ((x >>> 18) & 7);
      out[p - 8] = _zero + ((x >>> 21) & 7);
    }

    if (n == 2) {
      x = (input[1] & 0xFF) ^ ((input[0] & 0xFF) << 8);
      out[p - 1] = _zero + ((x) & 7);
      out[p - 2] = _zero + ((x >>> 3) & 7);
      out[p - 3] = _zero + ((x >>> 6) & 7);
      out[p - 4] = _zero + ((x >>> 9) & 7);
      out[p - 5] = _zero + ((x >>> 12) & 7);
      out[p - 6] = _zero + ((x >>> 15) & 7);
    } else if (n == 1) {
      x = input[0] & 0xFF;
      out[p - 1] = _zero + ((x) & 7);
      out[p - 2] = _zero + ((x >>> 3) & 7);
      out[p - 3] = _zero + ((x >>> 6) & 7);
    }

    return out;
  }
}

class _Base8Decoder extends ByteDecoder {
  const _Base8Decoder() : super(bits: 3);

  @override
  Uint8List convert(List<int> encoded) {
    int i, p, x, n, z;

    n = encoded.length;
    p = 3 * (n >>> 3);
    x = n & 7;
    z = 0;
    if (x > 0) {
      for (i = 0; i < x; i++) {
        z = (z << 3) ^ encoded.dec(i);
      }
      p++;
      if (x > 3 || z > 0xFF) p++;
      if (z > 0xFFFF) p++;
    }
    var out = Uint8List(p);

    for (; n >= 8; n -= 8, p -= 3) {
      x = encoded.dec(n - 1) ^
          (encoded.dec(n - 2) << 3) ^
          (encoded.dec(n - 3) << 6) ^
          (encoded.dec(n - 4) << 9) ^
          (encoded.dec(n - 5) << 12) ^
          (encoded.dec(n - 6) << 15) ^
          (encoded.dec(n - 7) << 18) ^
          (encoded.dec(n - 8) << 21);
      out[p - 1] = x;
      out[p - 2] = x >>> 8;
      out[p - 3] = x >>> 16;
    }

    if (z > 0) {
      out[p - 1] = z;
      if (z > 0xFF) {
        out[p - 2] = z >>> 8;
        if (z > 0xFFFF) {
          out[p - 3] = z >>> 16;
        }
      }
    }

    return out;
  }
}

// ========================================================
// Base-8 Codec
// ========================================================

class Base8Codec extends IterableCodec {
  @override
  final ByteEncoder encoder;

  @override
  final ByteDecoder decoder;

  const Base8Codec._({
    required this.encoder,
    required this.decoder,
  });

  /// Codec instance to encode and decode 8-bit integer sequence to 3-bit
  /// Base-8 or Octal character sequence using the alphabet:
  /// ```
  /// 012345678
  /// ```
  static const Base8Codec standard = Base8Codec._(
    encoder: _Base8Encoder(),
    decoder: _Base8Decoder(),
  );
}
