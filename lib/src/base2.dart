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
/// **NOTE:**, This implementation is a bit-wise encoding of the input bytes.
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
/// **NOTE:**, This implementation is a bit-wise decoding of the input bytes.
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
