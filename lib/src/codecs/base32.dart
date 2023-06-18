// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/codec.dart';
import 'package:hashlib_codecs/src/core/alphabet_converter.dart';

// ignore: constant_identifier_names
const int __ = -1;

const _base32Encoding = [
  0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, //
  0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50,
  0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
  0x59, 0x5a, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
];

const _base32lowerEncoding = [
  0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, //
  0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70,
  0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
  0x79, 0x7a, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
];

const _base32Decoding = [
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

class Base32Codec extends ByteCodec {
  @override
  final AlphabetEncoder encoder;

  @override
  final decoder = const AlphabetDecoder(
    bits: 5,
    padding: 61,
    alphabet: _base32Decoding,
  );

  /// Codec instance to encode and decode 8-bit integer sequence to Base-32
  /// character sequence using the uppercase alphabet.
  const Base32Codec()
      : encoder = const AlphabetEncoder(
          bits: 5,
          alphabet: _base32Encoding,
        );

  /// Codec instance to encode and decode 8-bit integer sequence to Base-32
  /// character sequence using the uppercase alphabet with padding.
  const Base32Codec.padded()
      : encoder = const AlphabetEncoder(
          bits: 5,
          padding: 61,
          alphabet: _base32Encoding,
        );

  /// Codec instance to encode and decode 8-bit integer sequence to Base-32
  /// character sequence using the lowercase alphabet.
  const Base32Codec.lower()
      : encoder = const AlphabetEncoder(
          bits: 5,
          alphabet: _base32lowerEncoding,
        );

  /// Codec instance to encode and decode 8-bit integer sequence to Base-32
  /// character sequence using the lowercase alphabet with padding.
  const Base32Codec.paddedlower()
      : encoder = const AlphabetEncoder(
          bits: 5,
          padding: 61,
          alphabet: _base32lowerEncoding,
        );
}
