// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import '../core/codec.dart';
import '../core/bit.dart';

/*
  Char. number range  | UTF-8 octet sequence
  --------------------+------------------------------------
  0000 0000-0000 007F | 0xxxxxxx
  0000 0080-0000 07FF | 110xxxxx 10xxxxxx
  0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
  0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
*/

// ========================================================
// UTF-8 Encoder and Decoder
// ========================================================

/// Encodes a sequence of Unicode code points into a UTF-8 octet sequence.
///
/// Each code point in `U+0000..U+10FFFF` is emitted as 1 to 4 octets, and any
/// UTF-16 surrogate pair in the input is combined into a single 4-octet
/// sequence. Based on [RFC-3629][rfc].
///
/// [rfc]: https://datatracker.ietf.org/doc/html/rfc3629
class UTF8Encoder extends BitEncoder {
  /// Creates a new [UTF8Encoder] instance.
  const UTF8Encoder();

  @override
  int get source => 32;

  @override
  int get target => 8;

  @override
  Uint8List convert(List<int> input) {
    int len = input.length;
    int l = 0, p = 0, x, y, c;
    var out = Uint8List(len << 2);
    while (p < len) {
      x = input[p];
      // Case: negative code
      if (x < 0) {
        throw FormatException('Negative code $x at $p');
      }
      // Case: Exceeds range
      else if (x > 0x0010FFFF) {
        throw FormatException('Invalid code $x at $p');
      }
      // Case: 1-byte ASCII run
      else if (x <= 0x7F) {
        out[l++] = x;
        p++;
      }
      // Case: 2-byte
      else if (x <= 0x7FF) {
        out[l++] = 0xC0 | (x >>> 6);
        out[l++] = 0x80 | (x & 0x3F);
        p++;
      }
      // Case: 3-byte (rest of the Basic Multilingual Plane, sans surrogates)
      else if (x <= 0xFFFF && (x < 0xD800 || x > 0xDFFF)) {
        out[l++] = 0xE0 | (x >>> 12);
        out[l++] = 0x80 | ((x >>> 6) & 0x3F);
        out[l++] = 0x80 | (x & 0x3F);
        p++;
      }
      // Case: 4-byte from a UTF-16 high surrogate paired with a low surrogate
      else if (x <= 0xDBFF) {
        p++;
        if (p >= len) {
          throw FormatException('Unpaired high surrogate $x at ${p - 1}');
        }
        y = input[p];
        if (y < 0xDC00 || y > 0xDFFF) {
          throw FormatException('Invalid surrogate pair ($x, $y) at $p');
        }
        c = 0x10000 + (((x - 0xD800) << 10) | (y - 0xDC00));
        out[l++] = 0xF0 | (c >>> 18);
        out[l++] = 0x80 | ((c >>> 12) & 0x3F);
        out[l++] = 0x80 | ((c >>> 6) & 0x3F);
        out[l++] = 0x80 | (c & 0x3F);
        p++;
      }
      // Case: unpaired low surrogate
      else if (x <= 0xDFFF) {
        throw FormatException('Unpaired low surrogate $x at $p');
      }
      // Case: 4-byte from a scalar code point in U+10000..U+10FFFF
      else {
        out[l++] = 0xF0 | (x >>> 18);
        out[l++] = 0x80 | ((x >>> 12) & 0x3F);
        out[l++] = 0x80 | ((x >>> 6) & 0x3F);
        out[l++] = 0x80 | (x & 0x3F);
        p++;
      }
    }

    if (l == out.length) {
      return out;
    }
    return out.sublist(0, l);
  }

  /// Encodes the UTF-16 code units of [input] into a UTF-8 octet sequence.
  @pragma('vm:prefer-inline')
  Uint8List encode(String input) => convert(input.codeUnits);
}

/// Decodes a UTF-8 octet sequence back into a sequence of Unicode code points.
///
/// Each 1 to 4 octet UTF-8 sequence is decoded into a single code point in
/// `U+0000..U+10FFFF`. Based on [RFC-3629][rfc].
///
/// [rfc]: https://datatracker.ietf.org/doc/html/rfc3629
class UTF8Decoder extends BitDecoder {
  /// Creates a new [UTF8Decoder] instance.
  const UTF8Decoder();

  @override
  int get source => 8;

  @override
  int get target => 32;

  @override
  List<int> convert(List<int> encoded) {
    var bytes = encoded is Uint8List ? encoded : Uint8List.fromList(encoded);
    int len = bytes.length;
    var out = Uint32List(len);

    int x, n = 0, p = 0;
    while (p < len) {
      x = bytes[p];
      // Case: 1-byte ASCII run
      if (x <= 0x7F) {
        out[n++] = x;
        p++;
      }
      // Case: 2-bytes
      else if ((x & 0xE0) == 0xC0) {
        out[n++] = _decode2(bytes, len, p, x);
        p += 2;
      }
      // Case: 3-bytes UTF-16
      else if ((x & 0xF0) == 0xE0) {
        out[n++] = _decode3(bytes, len, p, x);
        p += 3;
      }
      // Case: 4-byte UTF-16 surrogate pair
      else if ((x & 0xF8) == 0xF0) {
        out[n++] = _decode4(bytes, len, p, x);
        p += 4;
      }
      // Case: 5 or more bytes
      else {
        throw FormatException('Invalid code $x at $p');
      }
    }
    if (n == len) {
      return out;
    }
    return out.sublist(0, n);
  }

  /// Decodes a valid UTF-8 octet sequence in [input] directly to a [String].
  ///
  /// This is a faster equivalent of `String.fromCharCodes(convert(...))`
  /// that emits UTF-16 code units in a single pass. Throws a [FormatException]
  /// if [input] is not a valid UTF-8 octet sequence.
  String decode(Uint8List input) {
    int len = input.length;
    if (len == 0) return '';

    int x, y, n = 0, p = 0;
    var units = Uint16List(len);
    while (p < len) {
      x = input[p];
      // Case: 1-byte ASCII run
      if (x <= 0x7F) {
        units[n++] = x;
        p++;
      }
      // Case: 2-bytes
      else if ((x & 0xE0) == 0xC0) {
        units[n++] = _decode2(input, len, p, x);
        p += 2;
      }
      // Case: 3-bytes
      else if ((x & 0xF0) == 0xE0) {
        units[n++] = _decode3(input, len, p, x);
        p += 3;
      }
      // Case: 4-bytes UTF-16 surrogate pair
      else if ((x & 0xF8) == 0xF0) {
        y = _decode4(input, len, p, x) - 0x10000;
        units[n++] = 0xD800 | (y >> 10);
        units[n++] = 0xDC00 | (y & 0x3FF);
        p += 4;
      }
      // Case: 5 or more bytes
      else {
        throw FormatException('Invalid code $x at $p');
      }
    }
    return String.fromCharCodes(units, 0, n);
  }

  // Decodes the 2-byte sequence with lead byte [x] at index [p] of [b], and
  // returns the scalar value. Throws [FormatException] on a malformed sequence.
  @pragma('vm:prefer-inline')
  static int _decode2(Uint8List b, int len, int p, int x) {
    int y, z;
    if (x < 0xC2) {
      throw FormatException('Overlong 2-byte sequence at $p');
    }

    p++;
    if (p >= len) {
      throw FormatException('Insufficient input');
    }
    z = b[p];
    if ((z & 0xC0) != 0x80) {
      throw FormatException('Invalid continuation byte $z at $p');
    }
    y = ((x & 0x1F) << 6) | (z & 0x3F);

    return y;
  }

  // Decodes the 3-byte sequence with lead byte [x] at index [p] of [b], and
  // returns the scalar value. Throws [FormatException] on a malformed sequence.
  @pragma('vm:prefer-inline')
  static int _decode3(Uint8List b, int len, int p, int x) {
    int y, z;

    p++;
    if (p >= len) {
      throw FormatException('Insufficient input');
    }
    z = b[p];
    if ((z & 0xC0) != 0x80) {
      throw FormatException('Invalid continuation byte $z at $p');
    } else if (x == 0xE0 && z < 0xA0) {
      throw FormatException('Overlong 3-byte sequence at ${p - 1}');
    }
    y = (x & 0xF) << 12;
    y |= (z & 0x3F) << 6;

    p++;
    if (p >= len) {
      throw FormatException('Insufficient input');
    }
    z = b[p];
    if ((z & 0xC0) != 0x80) {
      throw FormatException('Invalid continuation byte $z at $p');
    }
    y |= z & 0x3F;
    if (y >= 0xD800 && y <= 0xDFFF) {
      throw FormatException('Invalid surrogate $y at ${p - 2}');
    }

    return y;
  }

  // Decodes the 4-byte sequence with lead byte [x] at index [p] of [b], and
  // returns the scalar value. Throws [FormatException] on a malformed sequence.
  @pragma('vm:prefer-inline')
  static int _decode4(Uint8List b, int len, int p, int x) {
    int y, z;
    if (x > 0xF4) {
      throw FormatException('Invalid 4-byte lead $x at $p');
    }

    p++;
    if (p >= len) {
      throw FormatException('Insufficient input');
    }
    z = b[p];
    if ((z & 0xC0) != 0x80) {
      throw FormatException('Invalid continuation byte $z at $p');
    } else if (x == 0xF0 && z < 0x90) {
      throw FormatException('Overlong 4-byte sequence at ${p - 1}');
    }
    y = (x & 0x7) << 18;
    y |= (z & 0x3F) << 12;

    p++;
    if (p >= len) {
      throw FormatException('Insufficient input');
    }
    z = b[p];
    if ((z & 0xC0) != 0x80) {
      throw FormatException('Invalid continuation byte $z at $p');
    }
    y |= (z & 0x3F) << 6;

    p++;
    if (p >= len) {
      throw FormatException('Insufficient input');
    }
    z = b[p];
    if ((z & 0xC0) != 0x80) {
      throw FormatException('Invalid continuation byte $z at $p');
    }
    y |= z & 0x3F;
    if (y > 0x0010FFFF) {
      throw FormatException('Above U+10FFFF at $p');
    }

    return y;
  }
}

// ========================================================
// UTF-8 Codec
// ========================================================

/// Encodes UTF-16 code units into a UTF-8 octet sequence and decodes UTF-8
/// octets back into code points.
///
/// Based on [RFC-3629](https://datatracker.ietf.org/doc/html/rfc3629). See
/// [standard] for the codec instance.
class UTF8Codec extends IterableCodec {
  @override
  final UTF8Encoder encoder;

  @override
  final UTF8Decoder decoder;

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
    encoder: UTF8Encoder(),
    decoder: UTF8Decoder(),
  );
}
