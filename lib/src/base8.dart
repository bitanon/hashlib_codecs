// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base8.dart';

/// Converts 8-bit integer sequence to 3-bit Base-8 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - [codec] is the [Base8Codec] to use. Default: [Base8Codec.standard].
///
/// **NOTE:** This implementation is a bit-wise encoding of the input bytes.
/// To get the numeric representation of the [input] in octal:
/// ```dart
/// toBigInt(input).toRadixString(8)
/// ```
String toOctal(
  List<int> input, {
  Base8Codec codec = Base8Codec.standard,
}) {
  return String.fromCharCodes(toOctalBytes(input, codec: codec));
}

/// Converts 8-bit integer sequence to Base-8 and returns the ASCII bytes.
///
/// This is the same as [toOctal] but returns the encoded characters as a
/// [Uint8List] of ASCII codes, skipping the intermediate [String].
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - [codec] is the [Base8Codec] to use. Default: [Base8Codec.standard].
Uint8List toOctalBytes(
  List<int> input, {
  Base8Codec codec = Base8Codec.standard,
}) {
  return codec.encoder.convert(input);
}

/// Converts 3-bit Base-8 character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid octal/base-8 encoded string.
/// - [codec] is the [Base8Codec] to use. Default: [Base8Codec.standard].
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters.
///
/// If a partial string is detected, the following bits are assumed to be zeros.
///
/// **NOTE:** This implementation is a bit-wise decoding of the input bytes.
/// To get the bytes from the numeric representation of the [input]:
/// ```dart
/// fromBigInt(BigInt.parse(input, radix: 8));
/// ```
Uint8List fromOctal(
  String input, {
  Base8Codec codec = Base8Codec.standard,
}) {
  return codec.decoder.convert(input.codeUnits);
}

/// Converts a Base-8 string to an 8-bit integer sequence, returning `null`
/// instead of throwing when the [input] is not valid.
///
/// This is the non-throwing counterpart of [fromOctal]. See [fromOctal] for the
/// meaning of [codec].
Uint8List? tryFromOctal(
  String input, {
  Base8Codec codec = Base8Codec.standard,
}) {
  try {
    return fromOctal(input, codec: codec);
  } on FormatException {
    return null;
  }
}
