// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/codec.dart';
import 'package:hashlib_codecs/src/core/converter.dart';

const int _zero = 48;

class _BinaryEncoder extends Uint8Encoder {
  const _BinaryEncoder()
      : super(
          bits: 2,
          alphabet: const <int>[],
        );

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

class _BinaryDecoder extends Uint8Decoder {
  const _BinaryDecoder()
      : super(
          bits: 2,
          alphabet: const <int>[],
        );

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

class BinaryCodec extends Uint8Codec {
  @override
  final encoder = const _BinaryEncoder();

  @override
  final decoder = const _BinaryDecoder();

  /// Codec instance to encode and decode 8-bit integer sequence to Binary or
  /// Base-2 character sequence using the alphabet: `01`
  const BinaryCodec();
}
