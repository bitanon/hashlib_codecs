// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import '../core/alphabet.dart';
import '../core/codec.dart';

// ========================================================
// Base-32 Alphabets
// ========================================================

const int _padding = 0x3d;

// ignore: constant_identifier_names
const int __ = -1;

// RFC-4648
const _base32EncodingRfc4648 = [
  0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, //
  0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50,
  0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
  0x59, 0x5a, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
];

// RFC-4648 Lowercase
const _base32EncodingRfc4648Lower = [
  0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, //
  0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70,
  0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
  0x79, 0x7a, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
];

// RFC-4648 and Lowercase Reversed
const _base32DecodingRfc4648 = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, 26, 27, 28, 29, 30, 31, __,
  __, __, __, __, __, __, __, __, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, __, __, __, __,
  __, __, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16,
  17, 18, 19, 20, 21, 22, 23, 24, 25, __, __, __, __, __, __, __, __, __, __,
];

// Base32Hex Uppercase
const _base32EncodingHexUpper = [
  0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, //
  0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46,
  0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e,
  0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56,
];

// Base32Hex Lowercase
const _base32EncodingHexLower = [
  0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, //
  0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66,
  0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e,
  0x6f, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76,
];

// Base32Hex Uppercase + Lowercase Reversed
const _base32DecodingHex = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, 00, 01, 02, 03, 04, 05, 06, 07, 08,
  09, __, __, __, __, __, __, __, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, __, __, __, __, __, __, __, __,
  __, __, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
  27, 28, 29, 30, 31, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
];

// Crockford's Base32
const _base32EncodingCrockford = [
  0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, //
  0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46,
  0x47, 0x48, 0x4a, 0x4b, 0x4d, 0x4e, 0x50, 0x51,
  0x52, 0x53, 0x54, 0x56, 0x57, 0x58, 0x59, 0x5a,
];

// Crockford's Base32 Reversed
//
// Case-insensitive, and per the Crockford spec the ambiguous letters decode to
// digits: I/i/L/l -> 1 and O/o -> 0. The letter U/u is not decoded.
const _base32DecodingCrockford = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, 00, 01, 02, 03, 04, 05, 06, 07, 08,
  09, __, __, __, __, __, __, __, 10, 11, 12, 13, 14, 15, 16, 17, 01, 18, 19,
  01, 20, 21, 00, 22, 23, 24, 25, 26, __, 27, 28, 29, 30, 31, __, __, __, __,
  __, __, 10, 11, 12, 13, 14, 15, 16, 17, 01, 18, 19, 01, 20, 21, 00, 22, 23,
  24, 25, 26, __, 27, 28, 29, 30, 31, __, __, __, __, __, __, __, __, __, __,
];

// GeoHash's Base32
const _base32EncodingGeoHash = [
  0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, //
  0x38, 0x39, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
  0x68, 0x6a, 0x6b, 0x6d, 0x6e, 0x70, 0x71, 0x72,
  0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a,
];

// GeoHash's Base32 Reversed
const _base32DecodingGeoHash = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, 00, 01, 02, 03, 04, 05, 06, 07, 08,
  09, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, 10, 11, 12, 13, 14, 15, 16, __, 17, 18, __, 19, 20, __, 21, 22,
  23, 24, 25, 26, 27, 28, 29, 30, 31, __, __, __, __, __, __, __, __, __, __,
];

// Z Base32
const _base32EncodingZ = [
  0x79, 0x62, 0x6e, 0x64, 0x72, 0x66, 0x67, 0x38, //
  0x65, 0x6a, 0x6b, 0x6d, 0x63, 0x70, 0x71, 0x78,
  0x6f, 0x74, 0x31, 0x75, 0x77, 0x69, 0x73, 0x7a,
  0x61, 0x33, 0x34, 0x35, 0x68, 0x37, 0x36, 0x39,
];

// Z Base32 Reversed
const _base32DecodingZ = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, 18, __, 25, 26, 27, 30, 29, 07,
  31, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, 24, 01, 12, 03, 08, 05, 06, 28, 21, 09, 10, __, 11, 02, 16, 13, 14,
  04, 22, 17, 19, __, 20, 15, 00, 23, __, __, __, __, __, __, __, __, __, __,
];

// WordSafe Base32
const _base32EncodingWordSafe = [
  0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, //
  0x43, 0x46, 0x47, 0x48, 0x4a, 0x4d, 0x50, 0x51,
  0x52, 0x56, 0x57, 0x58, 0x63, 0x66, 0x67, 0x68,
  0x6a, 0x6d, 0x70, 0x71, 0x72, 0x76, 0x77, 0x78,
];

// WordSafe Base32 Reversed
const _base32DecodingWordSafe = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, 00, 01, 02, 03, 04, 05, 06,
  07, __, __, __, __, __, __, __, __, __, 08, __, __, 09, 10, 11, __, 12, __,
  __, 13, __, __, 14, 15, 16, __, __, __, 17, 18, 19, __, __, __, __, __, __,
  __, __, __, __, 20, __, __, 21, 22, 23, __, 24, __, __, 25, __, __, 26, 27,
  28, __, __, __, 29, 30, 31, __, __, __, __, __, __, __, __, __, __, __, __,
];

// ========================================================
// Base-32 Encoder
// ========================================================

/// A specialized single-pass [AlphabetEncoder] for Base-32.
///
/// Processes the input 5 bytes at a time into 8 characters, writing directly
/// into a single correctly-sized (and, if applicable, padded) output buffer.
/// This avoids the multiple regroup/lookup/pad passes of the generic engine.
///
/// Every intermediate value stays within 8 bits and every result within 5 bits,
/// so no 40-bit accumulator is used and the code is safe on the JavaScript
/// platform (where `<<` operates on 32-bit integers).
class Base32Encoder extends AlphabetEncoder {
  /// Creates a new [Base32Encoder] instance.
  ///
  /// Parameters:
  /// - The [alphabet] maps each 5-bit word to its output character.
  /// - If [padding] is not null, the output is padded with it to a multiple of
  ///   8 characters.
  const Base32Encoder({
    required super.alphabet,
    super.padding,
  }) : super(bits: 5);

  @override
  Uint8List convert(List<int> input) {
    const tailChars = [0, 2, 4, 5, 7];
    final table = alphabet;
    final pad = padding;
    int n = input.length;
    int full = n ~/ 5;
    int rem = n - full * 5;

    int outLen;
    if (pad != null) {
      outLen = (full + (rem == 0 ? 0 : 1)) << 3;
    } else {
      outLen = (full << 3) + tailChars[rem];
    }
    var out = Uint8List(outLen);

    int i = 0, j = 0, b0, b1, b2, b3, b4;
    for (int g = 0; g < full; ++g) {
      b0 = input[i++] & 0xFF;
      b1 = input[i++] & 0xFF;
      b2 = input[i++] & 0xFF;
      b3 = input[i++] & 0xFF;
      b4 = input[i++] & 0xFF;
      out[j++] = table[b0 >> 3];
      out[j++] = table[((b0 & 0x7) << 2) | (b1 >> 6)];
      out[j++] = table[(b1 >> 1) & 0x1F];
      out[j++] = table[((b1 & 0x1) << 4) | (b2 >> 4)];
      out[j++] = table[((b2 & 0xF) << 1) | (b3 >> 7)];
      out[j++] = table[(b3 >> 2) & 0x1F];
      out[j++] = table[((b3 & 0x3) << 3) | (b4 >> 5)];
      out[j++] = table[b4 & 0x1F];
    }

    if (rem > 0) {
      b0 = input[i] & 0xFF;
      b1 = rem > 1 ? input[i + 1] & 0xFF : 0;
      b2 = rem > 2 ? input[i + 2] & 0xFF : 0;
      b3 = rem > 3 ? input[i + 3] & 0xFF : 0;
      out[j++] = table[b0 >> 3];
      out[j++] = table[((b0 & 0x7) << 2) | (b1 >> 6)];
      if (rem >= 2) {
        out[j++] = table[(b1 >> 1) & 0x1F];
        out[j++] = table[((b1 & 0x1) << 4) | (b2 >> 4)];
      }
      if (rem >= 3) {
        out[j++] = table[((b2 & 0xF) << 1) | (b3 >> 7)];
      }
      if (rem >= 4) {
        out[j++] = table[(b3 >> 2) & 0x1F];
        out[j++] = table[(b3 & 0x3) << 3];
      }
      if (pad != null) {
        while (j < outLen) {
          out[j++] = pad;
        }
      }
    }

    return out;
  }
}

// ========================================================
// Base-32 Decoder
// ========================================================

/// A specialized [AlphabetDecoder] for Base-32.
///
/// Strips trailing padding once, then decodes complete 8-character groups into
/// 5 bytes with straight-line code, leaving only the final partial group to the
/// bit-accumulator. This keeps the hot path free of the generic decoder's
/// per-character inner loop and padding bookkeeping.
///
/// Every intermediate value stays within 8 bits, so it is safe on the
/// JavaScript platform (where `<<` operates on 32-bit integers).
class Base32Decoder extends AlphabetDecoder {
  /// Creates a new [Base32Decoder] instance.
  ///
  /// Parameters:
  /// - The [alphabet] maps each input character to its 5-bit word.
  /// - If [padding] is not null, trailing occurrences of it are stripped before
  ///   decoding.
  const Base32Decoder({
    required super.alphabet,
    super.padding,
  }) : super(bits: 5);

  @override
  Uint8List convert(List<int> encoded, {bool ignoreWhitespace = false}) {
    // The fast path below decodes fixed 8-character groups, so it cannot skip
    // interspersed whitespace. Defer that case to the generic bit-accumulator,
    // which tolerates whitespace anywhere without an intermediate buffer.
    if (ignoreWhitespace) {
      return super.convert(encoded, ignoreWhitespace: true);
    }

    final table = alphabet;
    final pad = padding;
    final tlen = table.length;
    int len = encoded.length;

    // Padding is only valid as a trailing suffix, strip it here. A padding
    // character anywhere else is rejected as an invalid character.
    if (pad != null) {
      while (len > 0 && encoded[len - 1] == pad) {
        len--;
      }
    }

    int i = 0, l = 0;
    int y0, y1, y2, y3, y4, y5, y6, y7;
    int c0, c1, c2, c3, c4, c5, c6, c7;

    var out = Uint8List((len * 5) >> 3);

    // Fast path: complete 8-character groups into 5 bytes.
    int fastEnd = len - (len & 7);
    while (i < fastEnd) {
      y0 = encoded[i];
      y1 = encoded[i + 1];
      y2 = encoded[i + 2];
      y3 = encoded[i + 3];
      y4 = encoded[i + 4];
      y5 = encoded[i + 5];
      y6 = encoded[i + 6];
      y7 = encoded[i + 7];
      if (y0 < 0 ||
          y1 < 0 ||
          y2 < 0 ||
          y3 < 0 ||
          y4 < 0 ||
          y5 < 0 ||
          y6 < 0 ||
          y7 < 0 ||
          y0 >= tlen ||
          y1 >= tlen ||
          y2 >= tlen ||
          y3 >= tlen ||
          y4 >= tlen ||
          y5 >= tlen ||
          y6 >= tlen ||
          y7 >= tlen) {
        break; // invalid character
      }
      c0 = table[y0];
      c1 = table[y1];
      c2 = table[y2];
      c3 = table[y3];
      c4 = table[y4];
      c5 = table[y5];
      c6 = table[y6];
      c7 = table[y7];
      if (c0 < 0 ||
          c1 < 0 ||
          c2 < 0 ||
          c3 < 0 ||
          c4 < 0 ||
          c5 < 0 ||
          c6 < 0 ||
          c7 < 0) {
        break; // invalid character
      }
      out[l++] = (c0 << 3) | (c1 >> 2);
      out[l++] = ((c1 & 0x3) << 6) | (c2 << 1) | (c3 >> 4);
      out[l++] = ((c3 & 0xF) << 4) | (c4 >> 1);
      out[l++] = ((c4 & 0x1) << 7) | (c5 << 2) | (c6 >> 3);
      out[l++] = ((c6 & 0x7) << 5) | c7;
      i += 8;
    }

    // Tail: the final partial group (and any group the fast path rejected).
    // No padding remains, so this only regroups bits and validates characters.
    int p = 0, n = 0, x, y;
    for (; i < len; ++i) {
      y = encoded[i];
      if (y < 0 || y >= tlen || (x = table[y]) < 0) {
        throw FormatException('Invalid character $y at $i');
      }
      p = (p << 5) ^ x;
      n += 5;
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
// Base-32 Codec
// ========================================================

/// Encodes and decodes 8-bit byte sequences as Base-32 text.
///
/// Several alphabets are available as `static const` instances: [standard] and
/// [standardNoPadding] (RFC 4648), [lowercase] and [lowercaseNoPadding], [hex]
/// and [hexLower] (base32hex), [crockford], [geohash], [z] (z-base-32), and
/// [wordSafe].
class Base32Codec extends IterableCodec {
  @override
  final Base32Encoder encoder;

  @override
  final Base32Decoder decoder;

  const Base32Codec._({
    required this.encoder,
    required this.decoder,
  });

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet described in
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZ234567
  /// ```
  ///
  /// It is padded with `=`
  static const Base32Codec standard = Base32Codec._(
    encoder: Base32Encoder(
      padding: _padding,
      alphabet: _base32EncodingRfc4648,
    ),
    decoder: Base32Decoder(
      padding: _padding,
      alphabet: _base32DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet described in
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZ234567
  /// ```
  ///
  /// This algorithm is a variant of the [standard] from the
  /// [RFC-4648](https://datatracker.ietf.org/doc/html/rfc4648)
  /// that does not append any padding characters to the output.
  ///
  /// It is not padded.
  static const Base32Codec standardNoPadding = Base32Codec._(
    encoder: Base32Encoder(
      alphabet: _base32EncodingRfc4648,
    ),
    decoder: Base32Decoder(
      alphabet: _base32DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet:
  /// ```
  /// abcdefghijklmnopqrstuvwxyz234567
  /// ```
  ///
  /// This alphabet is a variant of the standard alphabet from
  /// [RFC-4648](https://datatracker.ietf.org/doc/html/rfc4648)
  /// using the lowercase characters.
  ///
  /// It is padded with `=`
  static const Base32Codec lowercase = Base32Codec._(
    encoder: Base32Encoder(
      padding: _padding,
      alphabet: _base32EncodingRfc4648Lower,
    ),
    decoder: Base32Decoder(
      padding: _padding,
      alphabet: _base32DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet:
  /// ```
  /// abcdefghijklmnopqrstuvwxyz234567
  /// ```
  ///
  /// This algorithm is a variant of the [lowercase] that does
  /// not append any padding characters to the output.
  ///
  /// It is not padded.
  static const Base32Codec lowercaseNoPadding = Base32Codec._(
    encoder: Base32Encoder(
      alphabet: _base32EncodingRfc4648Lower,
    ),
    decoder: Base32Decoder(
      alphabet: _base32DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet of
  /// [base32hex](https://en.wikipedia.org/wiki/Base32#base32hex):
  /// ```
  /// 0123456789ABCDEFGHIJKLMNOPQRSTUV
  /// ```
  ///
  /// It is padded with `=`
  static const Base32Codec hex = Base32Codec._(
    encoder: Base32Encoder(
      padding: _padding,
      alphabet: _base32EncodingHexUpper,
    ),
    decoder: Base32Decoder(
      padding: _padding,
      alphabet: _base32DecodingHex,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet of lowercase
  /// [base32hex](https://en.wikipedia.org/wiki/Base32#base32hex):
  /// ```
  /// 0123456789abcdefghijklmnopqrstuv
  /// ```
  ///
  /// It is padded with `=`
  static const Base32Codec hexLower = Base32Codec._(
    encoder: Base32Encoder(
      padding: _padding,
      alphabet: _base32EncodingHexLower,
    ),
    decoder: Base32Decoder(
      padding: _padding,
      alphabet: _base32DecodingHex,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet of
  /// [Crockford's Base32](https://en.wikipedia.org/wiki/Base32#Crockford's_Base32):
  /// ```
  /// 0123456789ABCDEFGHJKMNPQRSTVWXYZ
  /// ```
  ///
  /// This alphabet uses additional characters for a mod-37 checksum, and avoid
  /// the character U to reduce the likelihood of accidental obscenity.
  ///
  /// Decoding is case-insensitive and, following the specification, accepts the
  /// ambiguous letters as digits: `I`, `i`, `L`, `l` decode as `1`, and `O`,
  /// `o` decode as `0`. The letter `U`/`u` is not part of the alphabet.
  ///
  /// It is not padded.
  static const Base32Codec crockford = Base32Codec._(
    encoder: Base32Encoder(
      alphabet: _base32EncodingCrockford,
    ),
    decoder: Base32Decoder(
      alphabet: _base32DecodingCrockford,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet of
  /// [Geohash's Base32](https://en.wikipedia.org/wiki/Base32#Geohash):
  /// ```
  /// 0123456789bcdefghjkmnpqrstuvwxyz
  /// ```
  ///
  /// This is used by the Geohash algorithm to represent latitude and
  /// longitude values in one (bit-interlaced) positive integer.
  ///
  /// It is padded with `=`
  static const Base32Codec geohash = Base32Codec._(
    encoder: Base32Encoder(
      padding: _padding,
      alphabet: _base32EncodingGeoHash,
    ),
    decoder: Base32Decoder(
      padding: _padding,
      alphabet: _base32DecodingGeoHash,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet of
  /// [z-base-32](https://en.wikipedia.org/wiki/Base32#z-base-32):
  /// ```
  /// ybndrfg8ejkmcpqxot1uwisza345h769
  /// ```
  ///
  /// The alphabet designed in a way so that the easier characters occur
  /// more frequently, thus making it more human readable.
  ///
  /// It is not padded.
  static const Base32Codec z = Base32Codec._(
    encoder: Base32Encoder(
      alphabet: _base32EncodingZ,
    ),
    decoder: Base32Decoder(
      alphabet: _base32DecodingZ,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the
  /// [Word-safe alphabet](https://en.wikipedia.org/wiki/Base32#Word-safe_alphabet):
  /// ```
  /// 23456789CFGHJMPQRVWXcfghjmpqrvwx
  /// ```
  ///
  /// That alphabet uses 8 numeric digits and 24 case-sensitive letter digits
  /// chosen to avoid accidentally forming words.
  ///
  /// It is padded with `=`
  static const Base32Codec wordSafe = Base32Codec._(
    encoder: Base32Encoder(
      padding: _padding,
      alphabet: _base32EncodingWordSafe,
    ),
    decoder: Base32Decoder(
      padding: _padding,
      alphabet: _base32DecodingWordSafe,
    ),
  );
}
