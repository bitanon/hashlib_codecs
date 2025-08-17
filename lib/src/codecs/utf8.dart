// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

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
  Uint8List convert(List<int> input) {
    List<int> out = <int>[];
    int len = input.length;
    for (int x, y, p = 0; p < len; ++p) {
      x = input[p];
      // check negative code
      if (x < 0) {
        throw FormatException('Negative code $x at $p');
      }
      // UTF-16 surrogate pairs
      if (x >= 0xD800 && x <= 0xDBFF) {
        if (p + 1 >= len) {
          throw FormatException('Unpaired high surrogate $x at $p');
        }
        y = input[++p];
        if (y < 0xDC00 || y > 0xDFFF) {
          throw FormatException('Invalid surrogate pair $x,$y at ${p - 1}');
        }
        x = 0x10000 + (((x - 0xD800) << 10) | (y - 0xDC00));
      } else if (x >= 0xDC00 && x <= 0xDFFF) {
        throw FormatException('Unpaired low surrogate $x at $p');
      }
      // extract bytes
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
        throw FormatException('Invalid code $x at $p');
      }
    }
    return Uint8List.fromList(out);
  }
}

class _UTF8Decoder extends BitDecoder {
  const _UTF8Decoder();

  @override
  int get source => 8;

  @override
  int get target => 32;

  @override
  List<int> convert(List<int> encoded) {
    List<int> out = <int>[];
    int len = encoded.length;
    for (int x, y, z, p = 0; p < len; ++p) {
      x = encoded[p];

      // Case: 1-byte
      if (x <= 0x7F) {
        out.add(x);
      }
      // Case: 2-bytes
      else if ((x & 0xE0) == 0xC0) {
        if (x < 0xC2) {
          throw FormatException('Overlong 2-byte sequence at $p');
        }
        if (p + 1 >= len) {
          throw FormatException('Insufficient input');
        }

        z = encoded[++p];
        if (((z & 0xC0) != 0x80)) {
          throw FormatException('Invalid continuation byte $z at $p');
        }

        y = ((x & 0x1F) << 6) | z;
        out.add(y);
      }
      // Case: 3-bytes
      else if ((x & 0xF0) == 0xE0) {
        if (p + 2 >= len) {
          throw FormatException('Insufficient input');
        }

        z = encoded[++p];
        if (((z & 0xC0) != 0x80)) {
          throw FormatException('Invalid continuation byte $z at $p');
        } else if (x == 0xE0 && z < 0xA0) {
          throw FormatException('Overlong 3-byte sequence at ${p - 1}');
        }

        y = (x & 0xF) << 12;
        y |= (z & 0x3F) << 6;

        z = encoded[++p];
        if (((z & 0xC0) != 0x80)) {
          throw FormatException('Invalid continuation byte $z at $p');
        }

        y |= z & 0x3F;
        if (y >= 0xD800 && y <= 0xDFFF) {
          throw FormatException('Invalid surrogate $y at ${p - 2}');
        }

        out.add(y);
      }
      // Case: 4-byte
      else if ((x & 0xF8) == 0xF0) {
        if (x > 0xF4) {
          throw FormatException('Invalid 4-byte lead $x at $p');
        }
        if (p + 3 >= len) {
          throw FormatException('Insufficient input');
        }

        z = encoded[++p];
        if (((z & 0xC0) != 0x80)) {
          throw FormatException('Invalid continuation byte $z at $p');
        } else if (x == 0xF0 && z < 0x90) {
          throw FormatException('Overlong 4-byte sequence at ${p - 1}');
        }

        y = (x & 0x7) << 18;
        y |= (z & 0x3F) << 12;

        z = encoded[++p];
        if (((z & 0xC0) != 0x80)) {
          throw FormatException('Invalid continuation byte $z at $p');
        }

        y |= (z & 0x3F) << 6;

        z = encoded[++p];
        if (((z & 0xC0) != 0x80)) {
          throw FormatException('Invalid continuation byte $z at $p');
        }

        y |= z & 0x3F;
        if (y > _range4) {
          throw FormatException('Above U+10FFFF at ${p - 3}');
        }

        out.add(y);
      }
      // Case: 5 or more bytes
      else {
        throw FormatException('Invalid code $x at $p');
      }
    }
    return out;
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
