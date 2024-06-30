// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/byte.dart';
import 'package:hashlib_codecs/src/core/codec.dart';

// ========================================================
// Base-8 Encoder and Decoder
// ========================================================

const _zero = 0x30;

class _Base8Encoder extends ByteEncoder {
  const _Base8Encoder() : super(bits: 3);

  @override
  Iterable<int> convert(Iterable<int> input) {
    return super.convert(input).map((y) => y + _zero);
  }
}

class _Base8Decoder extends ByteDecoder {
  const _Base8Decoder() : super(bits: 3);

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
