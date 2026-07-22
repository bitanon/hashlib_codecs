// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import '../core/alphabet.dart';
import '../core/codec.dart';

// ========================================================
// Base-64 Alphabets
// ========================================================

const int _padding = 0x3d;

// ignore: constant_identifier_names
const int __ = -1;

const _base64EncodingRfc4648 = [
  0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, //
  0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50,
  0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
  0x59, 0x5a, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66,
  0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e,
  0x6f, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76,
  0x77, 0x78, 0x79, 0x7a, 0x30, 0x31, 0x32, 0x33,
  0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x2b, 0x2f,
];
const _base64EncodingRfc4648UrlSafe = [
  0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, //
  0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50,
  0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
  0x59, 0x5a, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66,
  0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e,
  0x6f, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76,
  0x77, 0x78, 0x79, 0x7a, 0x30, 0x31, 0x32, 0x33,
  0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x2d, 0x5f,
];
const _base64DecodingRfc4648 = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, 62, __, 62, __, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60,
  61, __, __, __, __, __, __, __, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, __, __, __, __,
  63, __, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
  43, 44, 45, 46, 47, 48, 49, 50, 51, __, __, __, __, __, __, __, __, __, __,
];

const _base64EncodingBcrypt = [
  0x2e, 0x2f, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, //
  0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e,
  0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56,
  0x57, 0x58, 0x59, 0x5a, 0x61, 0x62, 0x63, 0x64,
  0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c,
  0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73, 0x74,
  0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x30, 0x31,
  0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
];
const _base64DecodingBcrypt = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, 00, 01, 54, 55, 56, 57, 58, 59, 60, 61, 62,
  63, __, __, __, __, __, __, __, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12,
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, __, __, __, __,
  __, __, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44,
  45, 46, 47, 48, 49, 50, 51, 52, 53, __, __, __, __, __, __, __, __, __, __,
];

// ========================================================
// Base-64 Encoder
// ========================================================

/// A specialized single-pass [AlphabetEncoder] for Base-64.
///
/// Processes the input 3 bytes at a time into 4 characters, writing directly
/// into a single correctly-sized (and, if applicable, padded) output buffer.
/// This avoids the multiple regroup/lookup/pad passes of the generic engine.
class Base64Encoder extends AlphabetEncoder {
  /// Creates a new [Base64Encoder] instance.
  ///
  /// Parameters:
  /// - The [alphabet] maps each 6-bit word to its output character.
  /// - If [padding] is not null, the output is padded with it to a multiple of
  ///   4 characters.
  const Base64Encoder({
    required super.alphabet,
    super.padding,
  }) : super(bits: 6);

  @override
  Uint8List convert(List<int> input) {
    final table = alphabet;
    final pad = padding;
    int n = input.length;
    int full = n ~/ 3;
    int rem = n - full * 3;

    int outLen;
    if (pad != null) {
      outLen = (full + (rem == 0 ? 0 : 1)) << 2;
    } else {
      outLen = (full << 2) + (rem == 0 ? 0 : rem + 1);
    }
    var out = Uint8List(outLen);

    int i = 0, j = 0, b0, b1, b2;
    for (int g = 0; g < full; ++g) {
      b0 = input[i++] & 0xFF;
      b1 = input[i++] & 0xFF;
      b2 = input[i++] & 0xFF;
      out[j++] = table[b0 >> 2];
      out[j++] = table[((b0 & 0x3) << 4) | (b1 >> 4)];
      out[j++] = table[((b1 & 0xF) << 2) | (b2 >> 6)];
      out[j++] = table[b2 & 0x3F];
    }

    if (rem == 1) {
      b0 = input[i] & 0xFF;
      out[j++] = table[b0 >> 2];
      out[j++] = table[(b0 & 0x3) << 4];
      if (pad != null) {
        out[j++] = pad;
        out[j++] = pad;
      }
    } else if (rem == 2) {
      b0 = input[i] & 0xFF;
      b1 = input[i + 1] & 0xFF;
      out[j++] = table[b0 >> 2];
      out[j++] = table[((b0 & 0x3) << 4) | (b1 >> 4)];
      out[j++] = table[(b1 & 0xF) << 2];
      if (pad != null) {
        out[j++] = pad;
      }
    }

    return out;
  }
}

// ========================================================
// Base-64 Decoder
// ========================================================

/// A specialized [AlphabetDecoder] for Base-64.
///
/// Strips trailing padding once, then decodes complete 4-character groups into
/// 3 bytes with straight-line code, leaving only the final partial group to the
/// bit-accumulator. This keeps the hot path free of the generic decoder's
/// per-character inner loop and padding bookkeeping.
///
/// Every intermediate value stays within 8 bits, so it is safe on the
/// JavaScript platform.
class Base64Decoder extends AlphabetDecoder {
  /// Creates a new [Base64Decoder] instance.
  ///
  /// Parameters:
  /// - The [alphabet] maps each input character to its 6-bit word.
  /// - If [padding] is not null, trailing occurrences of it are stripped before
  ///   decoding.
  const Base64Decoder({
    required super.alphabet,
    super.padding,
  }) : super(bits: 6);

  @override
  Uint8List convert(List<int> encoded) {
    final table = alphabet;
    final pad = padding;
    final tlen = table.length;
    int len = encoded.length;

    // Padding is only valid as a trailing suffix, strip it here. A padding
    // character anywhere else is rejected as an invalid character.
    // decode table maps it to -1).
    if (pad != null) {
      while (len > 0 && encoded[len - 1] == pad) {
        len--;
      }
    }

    int i = 0, l = 0;
    int y0, y1, y2, y3, c0, c1, c2, c3;

    var out = Uint8List((len * 6) >> 3);

    // Fast path: complete 4-character groups into 3 bytes.
    int fastEnd = len - (len & 3);
    while (i < fastEnd) {
      y0 = encoded[i];
      y1 = encoded[i + 1];
      y2 = encoded[i + 2];
      y3 = encoded[i + 3];
      if (y0 < 0 ||
          y1 < 0 ||
          y2 < 0 ||
          y3 < 0 ||
          y0 >= tlen ||
          y1 >= tlen ||
          y2 >= tlen ||
          y3 >= tlen) {
        break;
      }
      c0 = table[y0];
      c1 = table[y1];
      c2 = table[y2];
      c3 = table[y3];
      if (c0 < 0 || c1 < 0 || c2 < 0 || c3 < 0) {
        break;
      }
      out[l++] = (c0 << 2) | (c1 >> 4);
      out[l++] = ((c1 & 0xF) << 4) | (c2 >> 2);
      out[l++] = ((c2 & 0x3) << 6) | c3;
      i += 4;
    }

    // Tail: the final partial group (and any group the fast path rejected).
    // No padding remains, so this only regroups bits and validates characters.
    int p = 0, n = 0, x, y;
    for (; i < len; ++i) {
      y = encoded[i];
      if (y < 0 || y >= tlen || (x = table[y]) < 0) {
        throw FormatException('Invalid character $y at $i');
      }
      p = (p << 6) ^ x;
      n += 6;
      while (n >= 8) {
        n -= 8;
        out[l++] = p >>> n;
        p &= (1 << n) - 1;
      }
    }

    // A non-zero partial word means the input was not a valid length.
    if (p > 0) {
      throw FormatException('Invalid length or non-zero trailing bits');
    }

    return out;
  }
}

// ========================================================
// Base-64 Codec
// ========================================================

/// Encodes and decodes 8-bit byte sequences as Base-64 text.
///
/// Several alphabets are available as `static const` instances: [standard] and
/// [standardNoPadding] (RFC 4648), [urlSafe] and [urlSafeNoPadding], and
/// [bcrypt].
class Base64Codec extends IterableCodec {
  @override
  final Base64Encoder encoder;

  @override
  final Base64Decoder decoder;

  const Base64Codec._({
    required this.encoder,
    required this.decoder,
  });

  /// Codec instance to encode and decode 8-bit integer sequence to 6-bit
  /// Base-64 character sequence using the alphabet described in
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
  /// ```
  ///
  /// It is padded with `=`
  static const Base64Codec standard = Base64Codec._(
    encoder: Base64Encoder(
      padding: _padding,
      alphabet: _base64EncodingRfc4648,
    ),
    decoder: Base64Decoder(
      padding: _padding,
      alphabet: _base64DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 6-bit
  /// Base-64 character sequence using the alphabet described in
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
  /// ```
  ///
  /// It is not padded.
  static const Base64Codec standardNoPadding = Base64Codec._(
    encoder: Base64Encoder(
      alphabet: _base64EncodingRfc4648,
    ),
    decoder: Base64Decoder(
      alphabet: _base64DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 6-bit
  /// Base-64 character sequence using the alphabet described in
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html) considering the
  /// URL and filename safety:
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_
  /// ```
  ///
  /// It is padded with `=`
  static const Base64Codec urlSafe = Base64Codec._(
    encoder: Base64Encoder(
      padding: _padding,
      alphabet: _base64EncodingRfc4648UrlSafe,
    ),
    decoder: Base64Decoder(
      padding: _padding,
      alphabet: _base64DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 6-bit
  /// Base-64 character sequence using the alphabet described in
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html) considering the
  /// URL and filename safety:
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_
  /// ```
  ///
  /// It is not padded.
  static const Base64Codec urlSafeNoPadding = Base64Codec._(
    encoder: Base64Encoder(
      alphabet: _base64EncodingRfc4648UrlSafe,
    ),
    decoder: Base64Decoder(
      alphabet: _base64DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 6-bit
  /// Base-64 character sequence using the alphabet described in
  /// [Bcrypt](https://en.wikipedia.org/wiki/Bcrypt#base64_encoding_alphabet):
  /// ```
  /// ./ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789
  /// ```
  ///
  /// It is not padded.
  static const Base64Codec bcrypt = Base64Codec._(
    encoder: Base64Encoder(
      alphabet: _base64EncodingBcrypt,
    ),
    decoder: Base64Decoder(
      alphabet: _base64DecodingBcrypt,
    ),
  );
}
