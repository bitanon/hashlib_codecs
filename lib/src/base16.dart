// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base16.dart';
import 'core/whitespace.dart';

Base16Codec _codecFromParameters({
  bool upper = false,
}) {
  if (upper) {
    return Base16Codec.upper;
  } else {
    return Base16Codec.lower;
  }
}

/// Converts 8-bit integer sequence to 4-bit Base-16 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - If [upper] is true, the uppercase standard alphabet is used.
/// - [codec] is the [Base16Codec] to use. It is derived from the other
///   parameters if not provided.
String toHex(
  List<int> input, {
  Base16Codec? codec,
  bool upper = false,
}) {
  codec ??= _codecFromParameters(upper: upper);
  var out = codec.encoder.convert(input);
  return String.fromCharCodes(out);
}

/// Converts 8-bit integer sequence to Base-16 and returns the ASCII bytes.
///
/// This is the same as [toHex] but returns the encoded characters as a
/// [Uint8List] of ASCII codes, skipping the intermediate [String].
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - If [upper] is true, the uppercase standard alphabet is used.
/// - [codec] is the [Base16Codec] to use. It is derived from the other
///   parameters if not provided.
Uint8List toHexBytes(
  List<int> input, {
  Base16Codec? codec,
  bool upper = false,
}) {
  codec ??= _codecFromParameters(upper: upper);
  return codec.encoder.convert(input);
}

/// Converts 4-bit Base-16 character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid Base-16 (hexadecimal) string.
/// - If [ignoreWhitespace] is true, ASCII whitespace characters (space, tab,
///   line feed, vertical tab, form feed, and carriage return) in the [input]
///   are skipped instead of rejected. It is `false` by default.
/// - [codec] is the [Base16Codec] to use. It is derived from the other
///   parameters if not provided.
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters.
///
/// This implementation can handle both uppercase and lowercase alphabets. If a
/// partial string is detected, the following bits are assumed to be zeros.
Uint8List fromHex(
  String input, {
  Base16Codec? codec,
  bool ignoreWhitespace = false,
}) {
  codec ??= _codecFromParameters();
  List<int> data = input.codeUnits;
  if (ignoreWhitespace) {
    data = stripWhitespace(data);
  }
  return codec.decoder.convert(data);
}

/// Converts a Base-16 string to an 8-bit integer sequence, returning `null`
/// instead of throwing when the [input] is not valid.
///
/// This is the non-throwing counterpart of [fromHex]. See [fromHex] for the
/// meaning of [codec] and [ignoreWhitespace].
Uint8List? tryFromHex(
  String input, {
  Base16Codec? codec,
  bool ignoreWhitespace = false,
}) {
  try {
    return fromHex(input, codec: codec, ignoreWhitespace: ignoreWhitespace);
  } on FormatException {
    return null;
  }
}
