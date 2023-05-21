// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/core/codec.dart';
import 'package:hashlib_codecs/src/core/converter.dart';

const _base64Encoding = [
  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, //
  84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106,
  107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121,
  122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47
];

const _base64urlEncoding = [
  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, //
  84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106,
  107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121,
  122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 45, 95
];

const _base64Decoding = [
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, 62, -2, 62, -2, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60,
  61, -2, -2, -2, -1, -2, -2, -2, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, 63, -2, 26,
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45,
  46, 47, 48, 49, 50, 51
];

class B64Codec extends Uint8Codec {
  @override
  final Uint8Encoder encoder;

  @override
  final decoder = const Uint8Decoder(
    bits: 6,
    alphabet: _base64Decoding,
  );

  /// Codec instance to encode and decode 8-bit integer sequence to 6-bit Base64
  /// character sequence.
  const B64Codec()
      : encoder = const Uint8Encoder(
          bits: 6,
          alphabet: _base64Encoding,
        );

  /// Codec instance to encode and decode 8-bit integer sequence to a modified
  /// 6-bit Base64 character sequence that is both URL and filename safe.
  const B64Codec.url()
      : encoder = const Uint8Encoder(
          bits: 6,
          alphabet: _base64urlEncoding,
        );

  /// Creates a constructor where the encoder will use character `=` as padding,
  /// which is appended at the end out the output to fill up any partial bytes.
  const B64Codec.padded()
      : encoder = const Uint8Encoder(
          bits: 6,
          padding: 61,
          alphabet: _base64Encoding,
        );

  /// Codec instance where the encoder will use character `=` as padding,
  /// which is appended at the end out the output to fill up any partial bytes.
  const B64Codec.urlpadded()
      : encoder = const Uint8Encoder(
          bits: 6,
          padding: 61,
          alphabet: _base64urlEncoding,
        );
}
