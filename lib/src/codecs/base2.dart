// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/byte.dart';
import 'package:hashlib_codecs/src/core/codec.dart';

const int _zero = 0x30;

// ========================================================
// Base-2 Converters
// ========================================================

class _Base2Encoder extends ByteEncoder {
  const _Base2Encoder() : super(bits: 2);

  @override
  Iterable<int> convert(Iterable<int> input) sync* {
    for (int x in input) {
      yield _zero + ((x >>> 7) & 1);
      yield _zero + ((x >>> 6) & 1);
      yield _zero + ((x >>> 5) & 1);
      yield _zero + ((x >>> 4) & 1);
      yield _zero + ((x >>> 3) & 1);
      yield _zero + ((x >>> 2) & 1);
      yield _zero + ((x >>> 1) & 1);
      yield _zero + ((x) & 1);
    }
  }
}

class _Base2Decoder extends ByteDecoder {
  const _Base2Decoder() : super(bits: 2);

  @override
  Iterable<int> convert(Iterable<int> input) sync* {
    int p, n, x, y;
    p = n = 0;
    for (y in input) {
      x = y - _zero;
      if (x != 0 && x != 1) {
        throw FormatException('Invalid character $y');
      }
      if (n < 8) {
        p = (p << 1) | x;
        n++;
      } else {
        yield p;
        n = 1;
        p = x;
      }
    }
    if (n > 0) {
      yield p;
    }
  }
}

// ========================================================
// Base-2 Codec
// ========================================================

class Base2Codec extends HashlibCodec {
  @override
  final encoder = const _Base2Encoder();

  @override
  final decoder = const _Base2Decoder();

  const Base2Codec._();

  /// Codec instance to encode and decode 8-bit integer sequence to 2-bit
  /// Base-2 or Binary character sequence using the alphabet:
  /// ```
  /// 01
  /// ```
  static const Base2Codec standard = Base2Codec._();
}
