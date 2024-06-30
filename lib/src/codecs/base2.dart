// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:hashlib_codecs/src/core/byte.dart';
import 'package:hashlib_codecs/src/core/codec.dart';

const int _zero = 0x30;

// ========================================================
// Base-2 Converters
// ========================================================

class _Base2Encoder extends ByteEncoder {
  const _Base2Encoder() : super(bits: 2);

  @override
  Iterable<int> convert(Iterable<int> input) {
    int i, p, x;
    List<int> list = input is List<int> ? input : List.of(input);
    var result = Uint8List(list.length << 3);
    for (i = p = 0; p < list.length; p++, i += 8) {
      x = list[p];
      result[i] = _zero + ((x >>> 7) & 1);
      result[i + 1] = _zero + ((x >>> 6) & 1);
      result[i + 2] = _zero + ((x >>> 5) & 1);
      result[i + 3] = _zero + ((x >>> 4) & 1);
      result[i + 4] = _zero + ((x >>> 3) & 1);
      result[i + 5] = _zero + ((x >>> 2) & 1);
      result[i + 6] = _zero + ((x >>> 1) & 1);
      result[i + 7] = _zero + ((x) & 1);
    }
    return result;
  }
}

class _Base2Decoder extends ByteDecoder {
  const _Base2Decoder() : super(bits: 2);

  @override
  Iterable<int> convert(Iterable<int> input) {
    List<int> out = <int>[];
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
        out.add(p);
        n = 1;
        p = x;
      }
    }
    if (n > 0) {
      out.add(p);
    }
    return out;
  }
}

// ========================================================
// Base-2 Codec
// ========================================================

class Base2Codec extends IterableCodec {
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
