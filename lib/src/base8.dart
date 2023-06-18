// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base8.dart';

/// Codec instance to encode and decode 8-bit integer sequence to Base-8
/// or Octal character sequence using the alphabet: `01234567`
const base8 = Base8Codec();

/// Converts 8-bit integer seqence to Base-8 or Octal character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
String toOctal(Iterable<int> input) {
  var out = base8.encoder.convert(input);
  return String.fromCharCodes(out);
}

/// Converts Base-8 or Octal character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid octal/base-8 encoded string.
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters.
Uint8List fromOctal(String input) {
  var out = base8.decoder.convert(input.codeUnits);
  return Uint8List.fromList(out.toList());
}
