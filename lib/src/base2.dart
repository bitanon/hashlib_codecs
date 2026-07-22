// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base2.dart';

/// Converts 8-bit integer sequence to 2-bit Base-2 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - [codec] is the [Base2Codec] to use. Default: [Base2Codec.standard].
///
/// **NOTE:** This implementation is a bit-wise encoding of the input bytes.
/// To get the numeric representation of the [input] in binary:
/// ```dart
/// toBigInt(input).toRadixString(2)
/// ```
String toBinary(
  List<int> input, {
  Base2Codec codec = Base2Codec.standard,
}) {
  var out = codec.encoder.convert(input);
  return String.fromCharCodes(out);
}

/// Converts 8-bit integer sequence to Base-2 and returns the ASCII bytes.
///
/// This is the same as [toBinary] but returns the encoded characters as a
/// [Uint8List] of ASCII codes, skipping the intermediate [String].
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - [codec] is the [Base2Codec] to use. Default: [Base2Codec.standard].
Uint8List toBinaryBytes(
  List<int> input, {
  Base2Codec codec = Base2Codec.standard,
}) {
  return codec.encoder.convert(input);
}

/// Converts 2-bit Base-2 character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid binary/base-2 encoded string.
/// - [codec] is the [Base2Codec] to use. Default: [Base2Codec.standard].
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters.
///
/// If a partial string is detected, the following bits are assumed to be zeros.
///
/// **NOTE:** This implementation is a bit-wise decoding of the input bytes.
/// To get the bytes from the numeric representation of the [input]:
/// ```dart
/// fromBigInt(BigInt.parse(input, radix: 2));
/// ```
Uint8List fromBinary(
  String input, {
  Base2Codec codec = Base2Codec.standard,
}) {
  return codec.decoder.convert(input.codeUnits);
}

/// Converts a Base-2 string to an 8-bit integer sequence, returning `null`
/// instead of throwing when the [input] is not valid.
///
/// This is the non-throwing counterpart of [fromBinary]. See [fromBinary] for
/// the meaning of [codec].
Uint8List? tryFromBinary(
  String input, {
  Base2Codec codec = Base2Codec.standard,
}) {
  try {
    return fromBinary(input, codec: codec);
  } on FormatException {
    return null;
  }
}
