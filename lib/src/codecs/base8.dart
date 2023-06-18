// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/codec.dart';
import 'package:hashlib_codecs/src/core/bit_converter.dart';

const _zero = 0x30;

// ========================================================
// Base-8 Converters
// ========================================================

class _Base8Encoder extends BitEncoder {
  const _Base8Encoder();

  @override
  final int source = 8;

  @override
  final int target = 3;

  @override
  Iterable<int> convert(Iterable<int> input) {
    return super.convert(input).map((y) => y + _zero);
  }
}

class _Base8Decoder extends BitDecoder {
  const _Base8Decoder();

  @override
  final int source = 3;

  @override
  final int target = 8;

  @override
  Iterable<int> convert(Iterable<int> input) {
    int x;
    return super.convert(input.map((y) {
      x = y - _zero;
      if (x < 0 || x > 7) {
        throw FormatException('Invalid character $y');
      }
      return x;
    }));
  }
}

// ========================================================
// Base-8 Codec
// ========================================================

class Base8Codec extends ByteCodec {
  @override
  final encoder = const _Base8Encoder();

  @override
  final decoder = const _Base8Decoder();

  /// Codec instance to encode and decode 8-bit integer sequence to 3-bit Base-8
  /// or Octal character sequence using the alphabet `012345678`.
  const Base8Codec();
}
