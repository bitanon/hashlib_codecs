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

const _base32EncodingRfc4648 = [
  0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, //
  0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50,
  0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
  0x59, 0x5a, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
];

const _base32EncodingRfc4648Lower = [
  0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, //
  0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70,
  0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
  0x79, 0x7a, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
];

const _base32DecodingRfc4648 = [
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, //
  __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
  __, __, __, __, __, __, __, __, __, __, __, __, 26, 27, 28, 29, 30, 31, __,
  __, __, __, __, __, __, __, __, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, __, __, __, __,
  __, __, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16,
  17, 18, 19, 20, 21, 22, 23, 24, 25, __, __, __, __, __, __, __, __, __, __,
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
  /// Base-32 character sequence using the alphabet:
  /// ```
  /// abcdefghijklmnopqrstuvwxyz234567
  /// ```
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
  /// Base-32 character sequence using the alphabet described in
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZ234567
  /// ```
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
}
