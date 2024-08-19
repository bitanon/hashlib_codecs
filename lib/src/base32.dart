// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base32.dart';

Base32Codec _codecFromParameters({
  bool lower = false,
  bool padding = false,
}) {
  if (lower && padding) {
    return Base32Codec.lowercase;
  } else if (lower) {
    return Base32Codec.lowercaseNoPadding;
  } else if (padding) {
    return Base32Codec.standard;
  } else {
    return Base32Codec.standardNoPadding;
  }
}

const _codecsWithPadding = {
  Base32Codec.standard,
  Base32Codec.lowercase,
  Base32Codec.hex,
  Base32Codec.hexLower,
  Base32Codec.geohash,
  Base32Codec.wordSafe,
};

/// Converts 8-bit integer sequence to 5-bit Base-32 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
/// - If [lower] is true, the [Base32Codec.lowercase] alphabet is used.
/// - If [padding] is true, the output will not have padding characters.
/// - [codec] is the [Base32Codec] to use. It is derived from the other
///   parameters if not provided.
String toBase32(
  List<int> input, {
  Base32Codec? codec,
  bool lower = false,
  bool padding = true,
}) {
  codec ??= _codecFromParameters(
    lower: lower,
    padding: padding,
  );
  Iterable<int> out = codec.encoder.convert(input);
  if (!padding && _codecsWithPadding.contains(codec)) {
    out = out.takeWhile((x) => x != codec!.encoder.padding);
  }
  return String.fromCharCodes(out);
}

/// Converts 5-bit Base-32 character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid base-32 encoded string.
/// - If [padding] is true, the output will not have padding characters.
/// - [codec] is the [Base32Codec] to use. It is derived from the other
///   parameters if not provided.
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters, and the
///   length is not valid for a base-32 encoded string.
///
/// This implementation can handle both uppercase and lowercase alphabets. Any
/// letters appearing after the first padding character is observed are ignored.
/// If a partial string is detected, the following bits are assumed to be zeros.
Uint8List fromBase32(
  String input, {
  Base32Codec? codec,
  bool padding = true,
}) {
  codec ??= _codecFromParameters(padding: padding);
  var out = codec.decoder.convert(input.codeUnits);
  return Uint8List.fromList(out);
}
