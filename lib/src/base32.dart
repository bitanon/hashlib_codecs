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
/// - If [padding] is true, the output will have padding characters.
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

/// Converts 8-bit integer sequence to Base-32 and returns the ASCII bytes.
///
/// This is the same as [toBase32] but returns the encoded characters as a
/// [Uint8List] of ASCII codes, skipping the intermediate [String].
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
/// - If [lower] is true, the [Base32Codec.lowercase] alphabet is used.
/// - If [padding] is true, the output will have padding characters.
/// - [codec] is the [Base32Codec] to use. It is derived from the other
///   parameters if not provided.
Uint8List toBase32Bytes(
  List<int> input, {
  Base32Codec? codec,
  bool lower = false,
  bool padding = true,
}) {
  codec ??= _codecFromParameters(
    lower: lower,
    padding: padding,
  );
  Uint8List out = codec.encoder.convert(input);
  if (!padding && _codecsWithPadding.contains(codec)) {
    out = Uint8List.fromList(
      out.takeWhile((x) => x != codec!.encoder.padding).toList(),
    );
  }
  return out;
}

/// Converts 5-bit Base-32 character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid base-32 encoded string.
/// - If [padding] is true, the [input] may contain padding characters, which
///   are ignored during decoding.
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
  return codec.decoder.convert(input.codeUnits);
}

/// Converts a Base-32 string to an 8-bit integer sequence, returning `null`
/// instead of throwing when the [input] is not valid.
///
/// This is the non-throwing counterpart of [fromBase32]. See [fromBase32] for
/// the meaning of [codec] and [padding].
Uint8List? tryFromBase32(
  String input, {
  Base32Codec? codec,
  bool padding = true,
}) {
  try {
    return fromBase32(input, codec: codec, padding: padding);
  } on FormatException {
    return null;
  }
}
