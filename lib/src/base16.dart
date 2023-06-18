// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base16.dart';

/// Converts 8-bit integer sequence to 4-bit Base-16 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - If [upper] is true, the output will be in uppercase. Default: `false`.
///
/// Based on the parameter values, the following codecs are used:
/// - [upper] is `true`: [Base16Codec.upper]
/// - [upper] is `false`: [Base16Codec.lower]
String toHex(Iterable<int> input, {bool upper = false}) {
  var codec = upper ? Base16Codec.upper : Base16Codec.lower;
  var out = codec.encoder.convert(input);
  return String.fromCharCodes(out);
}

/// Converts 4-bit Base-16 character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid Base-16 (hexadecimal) string.
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters.
///
/// This implementation can handle both uppercase and lowercase alphabets. If a
/// partial string is detected, the following bits are assumed to be zeros.
Uint8List fromHex(String input) {
  var out = Base16Codec.upper.decoder.convert(input.codeUnits);
  return Uint8List.fromList(out.toList());
}
