// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:hashlib_codecs/src/core/byte.dart';
import 'package:hashlib_codecs/src/core/codec.dart';

const int _zero = 0x30;

extension on List<int> {
  @pragma('vm:prefer-inline')
  int dec(int p) {
    int x = this[p] - _zero;
    if (x != 0 && x != 1) {
      throw FormatException('Invalid character at $p');
    }
    return x;
  }
}

// ========================================================
// Base-2 Encoder & Decoder
// ========================================================

class _Base2Encoder extends ByteEncoder {
  const _Base2Encoder() : super(bits: 2);

  @override
  Uint8List convert(List<int> input) {
    int i, p, x, n;
    n = input.length;
    var out = Uint8List(n << 3);

    for (i = p = 0; i < n; i++, p += 8) {
      x = input[i];
      out[p] = _zero + ((x >>> 7) & 1);
      out[p + 1] = _zero + ((x >>> 6) & 1);
      out[p + 2] = _zero + ((x >>> 5) & 1);
      out[p + 3] = _zero + ((x >>> 4) & 1);
      out[p + 4] = _zero + ((x >>> 3) & 1);
      out[p + 5] = _zero + ((x >>> 2) & 1);
      out[p + 6] = _zero + ((x >>> 1) & 1);
      out[p + 7] = _zero + ((x) & 1);
    }

    return out;
  }
}

class _Base2Decoder extends ByteDecoder {
  const _Base2Decoder() : super(bits: 2);

  @override
  Uint8List convert(List<int> encoded) {
    int i, p, n, x;

    n = encoded.length;
    p = (n + ((8 - (n & 7)) & 7)) >>> 3;
    var out = Uint8List(p);

    for (p--; n >= 8; n -= 8, p--) {
      out[p] = encoded.dec(n - 1) ^
          (encoded.dec(n - 2) << 1) ^
          (encoded.dec(n - 3) << 2) ^
          (encoded.dec(n - 4) << 3) ^
          (encoded.dec(n - 5) << 4) ^
          (encoded.dec(n - 6) << 5) ^
          (encoded.dec(n - 7) << 6) ^
          (encoded.dec(n - 8) << 7);
    }

    if (n > 0) {
      x = 0;
      for (i = n; i > 0; i--) {
        x = (x << 1) ^ encoded.dec(n - i);
      }
      out[p] = x;
    }

    return out;
  }
}

// ========================================================
// Base-2 Codec
// ========================================================

class Base2Codec extends IterableCodec {
  @override
  final ByteEncoder encoder;

  @override
  final ByteDecoder decoder;

  const Base2Codec._({
    required this.encoder,
    required this.decoder,
  });

  /// Codec instance to encode and decode 8-bit integer sequence to 2-bit
  /// Base-2 or Binary character sequence using the alphabet:
  /// ```
  /// 01
  /// ```
  static const Base2Codec standard = Base2Codec._(
    encoder: _Base2Encoder(),
    decoder: _Base2Decoder(),
  );
}
