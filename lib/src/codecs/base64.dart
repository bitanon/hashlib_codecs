// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/alphabet.dart';
import 'package:hashlib_codecs/src/core/codec.dart';

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

// ========================================================
// Base-64 Codec
// ========================================================

class Base64Codec extends HashlibCodec {
  @override
  final AlphabetEncoder encoder;

  @override
  final AlphabetDecoder decoder;

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
  static const Base64Codec standard = Base64Codec._(
    encoder: AlphabetEncoder(
      bits: 6,
      padding: _padding,
      alphabet: _base64EncodingRfc4648,
    ),
    decoder: AlphabetDecoder(
      bits: 6,
      padding: _padding,
      alphabet: _base64DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 6-bit
  /// Base-64 character sequence using the alphabet described in
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html), which is both URL and
  /// filename safe using:
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_
  /// ```
  static const Base64Codec urlSafe = Base64Codec._(
    encoder: AlphabetEncoder(
      bits: 6,
      padding: _padding,
      alphabet: _base64EncodingRfc4648UrlSafe,
    ),
    decoder: AlphabetDecoder(
      bits: 6,
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
  static const Base64Codec standardNoPadding = Base64Codec._(
    encoder: AlphabetEncoder(
      bits: 6,
      alphabet: _base64EncodingRfc4648,
    ),
    decoder: AlphabetDecoder(
      bits: 6,
      alphabet: _base64DecodingRfc4648,
    ),
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 6-bit
  /// Base-64 character sequence using the alphabet described in
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html), which is both URL and
  /// filename safe using:
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_
  /// ```
  static const Base64Codec urlSafeNoPadding = Base64Codec._(
    encoder: AlphabetEncoder(
      bits: 6,
      alphabet: _base64EncodingRfc4648UrlSafe,
    ),
    decoder: AlphabetDecoder(
      bits: 6,
      alphabet: _base64DecodingRfc4648,
    ),
  );
}
