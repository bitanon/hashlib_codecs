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
/// **NOTE:**, This implementation is a bit-wise encoding of the input bytes.
/// To get the numeric representation of the [input] in binary:
/// ```dart
/// toBigInt(input).toRadixString(8)
/// ```
String toOctal(
  List<int> input, {
  Base8Codec codec = Base8Codec.standard,
}) {
  var out = codec.encoder.convert(input);
  return String.fromCharCodes(out);
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
/// **NOTE:**, This implementation is a bit-wise decoding of the input bytes.
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
