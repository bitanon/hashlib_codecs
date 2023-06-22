// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/alphabet.dart';
import 'package:hashlib_codecs/src/core/codec.dart';

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
const _base32DecodingCrockford = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, 00, 01, 02, 03, 04, 05, 06, 07, 08,
  09, __, __, __, __, __, __, __, 10, 11, 12, 13, 14, 15, 16, 17, __, 18, 19,
  __, 20, 21, __, 22, 23, 24, 25, 26, __, 27, 28, 29, 30, 31, __, __, __, __,
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
  0x79, 0x62, 0x6e, 0x64, 0x72, 0x66, 0x67, 0x38, //
  0x65, 0x6a, 0x6b, 0x6d, 0x63, 0x70, 0x71, 0x78,
  0x6f, 0x74, 0x31, 0x75, 0x77, 0x69, 0x73, 0x7a,
  0x61, 0x33, 0x34, 0x35, 0x68, 0x37, 0x36, 0x39,
];

// WordSafe Base32 Reversed
const _base32DecodingWordSafe = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, 18, __, 25, 26, 27, 30, 29, 07,
  31, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, 24, 01, 12, 03, 08, 05, 06, 28, 21, 09, 10, __, 11, 02, 16, 13, 14,
  04, 22, 17, 19, __, 20, 15, 00, 23, __, __, __, __, __, __, __, __, __, __,
];

// ========================================================
// Base-32 Codec
// ========================================================

class Base32Codec extends HashlibCodec {
  @override
  final AlphabetEncoder encoder;

  @override
  final AlphabetDecoder decoder;

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
    encoder: AlphabetEncoder(
      bits: 5,
      padding: _padding,
      alphabet: _base32EncodingRfc4648,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
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
    encoder: AlphabetEncoder(
      bits: 5,
      alphabet: _base32EncodingRfc4648,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
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
    encoder: AlphabetEncoder(
      bits: 5,
      padding: _padding,
      alphabet: _base32EncodingRfc4648Lower,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
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
    encoder: AlphabetEncoder(
      bits: 5,
      alphabet: _base32EncodingRfc4648Lower,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
      alphabet: _base32DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 5-bit
  /// Base-32 character sequence using the alphabet of
  /// [base32hex](https://en.wikipedia.org/wiki/Base32#base32hex):
  /// :
  /// ```
  /// 0123456789ABCDEFGHIJKLMNOPQRSTUV
  /// ```
  ///
  /// It is padded with `=`
  static const Base32Codec hex = Base32Codec._(
    encoder: AlphabetEncoder(
      bits: 5,
      padding: _padding,
      alphabet: _base32EncodingHexUpper,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
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
    encoder: AlphabetEncoder(
      bits: 5,
      padding: _padding,
      alphabet: _base32EncodingHexLower,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
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
  /// It is not padded.
  static const Base32Codec crockford = Base32Codec._(
    encoder: AlphabetEncoder(
      bits: 5,
      alphabet: _base32EncodingCrockford,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
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
    encoder: AlphabetEncoder(
      bits: 5,
      padding: _padding,
      alphabet: _base32EncodingGeoHash,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
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
    encoder: AlphabetEncoder(
      bits: 5,
      alphabet: _base32EncodingZ,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
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
  /// That alphabet uses 8 numeric digits and 12 case-sensitive letter digits
  /// chosen to avoid accidentally forming words.
  ///
  /// It is padded with `=`
  static const Base32Codec wordSafe = Base32Codec._(
    encoder: AlphabetEncoder(
      bits: 5,
      padding: _padding,
      alphabet: _base32EncodingWordSafe,
    ),
    decoder: AlphabetDecoder(
      bits: 5,
      padding: _padding,
      alphabet: _base32DecodingWordSafe,
    ),
  );
}
