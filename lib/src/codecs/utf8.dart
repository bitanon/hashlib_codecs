// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/hashlib_codecs.dart';

/*
  Char. number range  | UTF-8 octet sequence
  --------------------+------------------------------------
  0000 0000-0000 007F | 0xxxxxxx
  0000 0080-0000 07FF | 110xxxxx 10xxxxxx
  0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
  0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
*/

const int _range1 = 0x0000007F;
const int _range2 = 0x000007FF;
const int _range3 = 0x0000FFFF;
const int _range4 = 0x0010FFFF;

// ========================================================
// UTF-8 Encoder and Decoder
// ========================================================

class _UTF8Encoder extends BitEncoder {
  const _UTF8Encoder();

  @override
  int get source => 32;

  @override
  int get target => 8;

  @override
  Iterable<int> convert(Iterable<int> input) {
    List<int> out = <int>[];
    List<int> list = input is List<int> ? input : List.of(input);
    for (int x in list) {
      if (x <= _range1) {
        out.add(x & 0x7F);
      } else if (x <= _range2) {
        out.add(0xC0 | ((x >>> 6) & 0x1F));
        out.add(0x80 | (x & 0x3F));
      } else if (x <= _range3) {
        out.add(0xE0 | ((x >>> 12) & 0xF));
        out.add(0x80 | ((x >>> 6) & 0x3F));
        out.add(0x80 | (x & 0x3F));
      } else if (x <= _range4) {
        out.add(0xF0 | ((x >>> 18) & 0x7));
        out.add(0x80 | ((x >>> 12) & 0x3F));
        out.add(0x80 | ((x >>> 6) & 0x3F));
        out.add(0x80 | (x & 0x3F));
      } else {
        throw FormatException('Invalid character $x');
      }
    }
    return out;
  }
}

class _UTF8Decoder extends BitDecoder {
  const _UTF8Decoder();

  @override
  int get source => 8;

  @override
  int get target => 32;

  @override
  Iterable<int> convert(Iterable<int> input) {
    List<int> out = <int>[];
    List<int> list = input is List<int> ? input : List.of(input);
    for (int x, y, p = 0; p < list.length; ++p) {
      x = list[p];
      if (x <= 0x7F) {
        out.add(x);
      } else if (x & 0xE0 == 0xC0) {
        y = (x & 0x1F) << 6;
        x = _validatePartial(list, ++p);
        y |= x;
        out.add(y);
      } else if (x & 0xF0 == 0xE0) {
        y = (x & 0xF) << 12;
        x = _validatePartial(list, ++p);
        y |= (x & 0x3F) << 6;
        x = _validatePartial(list, ++p);
        y |= x & 0x3F;
        out.add(y);
      } else if (x & 0xF8 == 0xF0) {
        y = (x & 0x7) << 18;
        x = _validatePartial(list, ++p);
        y |= (x & 0x3F) << 12;
        x = _validatePartial(list, ++p);
        y |= (x & 0x3F) << 6;
        x = _validatePartial(list, ++p);
        y |= x & 0x3F;
        out.add(y);
      } else {
        throw FormatException('Invalid character $x');
      }
    }
    return out;
  }

  @pragma('vm:prefer-inline')
  static int _validatePartial(List<int> list, int x) {
    if (x >= list.length) {
      throw FormatException('Insufficient input');
    }
    x = list[x];
    if (x & 0xC0 != 0x80) {
      throw FormatException('Invalid character $x');
    }
    return x & 0x3F;
  }
}

// ========================================================
// UTF-8 Codec
// ========================================================

class UTF8Codec extends IterableCodec {
  @override
  final BitEncoder encoder;

  @override
  final BitDecoder decoder;

  const UTF8Codec._({
    required this.encoder,
    required this.decoder,
  });

  /// Codec instance to encode and decode UTF-8 character code units to 8-bit
  /// UTF-8 octet sequence.
  ///
  /// This implementation is based on [RFC-3629][rfc]
  ///
  /// [rfc]: https://datatracker.ietf.org/doc/html/rfc3629
  static const UTF8Codec standard = UTF8Codec._(
    encoder: _UTF8Encoder(),
    decoder: _UTF8Decoder(),
  );
}
