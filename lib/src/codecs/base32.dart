// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/codec.dart';
import 'package:hashlib_codecs/src/core/converter.dart';

const _base32Encoding = [
  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, //
  84, 85, 86, 87, 88, 89, 90, 50, 51, 52, 53, 54, 55
];

const _base32lowerEncoding = [
  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, //
  112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 50, 51, 52, 53, 54, 55
];

const _base32Decoding = [
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 26, 27, 28, 29, 30, 31, -2,
  -2, -2, -2, -2, -1, -2, -2, -2, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2, -2, 0, 1,
  2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
  23, 24, 25
];

class B32Codec extends Uint8Codec {
  @override
  final Uint8Encoder encoder;

  @override
  final decoder = const Uint8Decoder(
    bits: 5,
    alphabet: _base32Decoding,
  );

  /// Codec instance to encode and decode 8-bit integer sequence to Base-32
  /// character sequence using the uppercase alphabet.
  const B32Codec()
      : encoder = const Uint8Encoder(
          bits: 5,
          alphabet: _base32Encoding,
        );

  /// Codec instance to encode and decode 8-bit integer sequence to Base-32
  /// character sequence using the uppercase alphabet with padding.
  const B32Codec.padded()
      : encoder = const Uint8Encoder(
          bits: 5,
          padding: 61,
          alphabet: _base32Encoding,
        );

  /// Codec instance to encode and decode 8-bit integer sequence to Base-32
  /// character sequence using the lowercase alphabet.
  const B32Codec.lower()
      : encoder = const Uint8Encoder(
          bits: 5,
          alphabet: _base32lowerEncoding,
        );

  /// Codec instance to encode and decode 8-bit integer sequence to Base-32
  /// character sequence using the lowercase alphabet with padding.
  const B32Codec.paddedlower()
      : encoder = const Uint8Encoder(
          bits: 5,
          padding: 61,
          alphabet: _base32lowerEncoding,
        );
}
