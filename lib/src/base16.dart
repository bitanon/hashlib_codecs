// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base16.dart';

/// Codec instance to encode and decode 8-bit integer sequence to Base-16
/// or Hexadecimal character sequence using the alphabet described in
/// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
/// ```
/// 0123456789ABCDEF
/// ```
const base16 = B16Codec();

/// Codec instance to encode and decode 8-bit integer sequence to Base-16
/// or Hexadecimal character sequence using the lowercase alphabet:
/// ```
/// 0123456789abcdef
/// ```
const base16lower = B16Codec.lower();

/// Converts 8-bit integer seqence to Hexadecimal character sequence.
///
/// Parameters:
/// - If [upper] is true, the string will be in uppercase alphabets.
///
/// Based on the parameter values, the following codecs are used:
/// - [upper] is `true`: [base16]
/// - [upper] is `false`: [base16lower]
String toHex(Iterable<int> input, {bool upper = false}) {
  var codec = upper ? base16 : base16lower;
  var out = codec.encoder.convert(input);
  return String.fromCharCodes(out);
}

/// Converts Base-16 integer sequence to 8-bit integer sequence using the
/// [base16] codec.
///
/// This implementation can handle both uppercase and lowercase alphabets. If a
/// partial string is detected, the following bits are assumed to be zeros.
Uint8List fromHex(String input) {
  var out = base16.decoder.convert(input.codeUnits);
  return Uint8List.fromList(out.toList());
}
