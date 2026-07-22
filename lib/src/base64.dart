// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base64.dart';

Base64Codec _codecFromParameters({
  bool url = false,
  bool padding = false,
}) {
  if (url && padding) {
    return Base64Codec.urlSafe;
  } else if (url) {
    return Base64Codec.urlSafeNoPadding;
  } else if (padding) {
    return Base64Codec.standard;
  } else {
    return Base64Codec.standardNoPadding;
  }
}

const _codecsWithPadding = {
  Base64Codec.standard,
  Base64Codec.urlSafe,
};

/// Converts 8-bit integer sequence to 6-bit Base-64 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
/// - If [url] is true, URL and Filename-safe alphabet is used.
/// - If [padding] is true, the output will have padding characters.
/// - [codec] is the [Base64Codec] to use. It is derived from the other
///   parameters if not provided.
String toBase64(
  List<int> input, {
  Base64Codec? codec,
  bool url = false,
  bool padding = true,
}) {
  codec ??= _codecFromParameters(
    url: url,
    padding: padding,
  );
  Iterable<int> out = codec.encoder.convert(input);
  if (!padding && _codecsWithPadding.contains(codec)) {
    out = out.takeWhile((x) => x != codec!.encoder.padding);
  }
  return String.fromCharCodes(out);
}

/// Converts 8-bit integer sequence to Base-64 and returns the ASCII bytes.
///
/// This is the same as [toBase64] but returns the encoded characters as a
/// [Uint8List] of ASCII codes, skipping the intermediate [String].
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
/// - If [url] is true, URL and Filename-safe alphabet is used.
/// - If [padding] is true, the output will have padding characters.
/// - [codec] is the [Base64Codec] to use. It is derived from the other
///   parameters if not provided.
Uint8List toBase64Bytes(
  List<int> input, {
  Base64Codec? codec,
  bool url = false,
  bool padding = true,
}) {
  codec ??= _codecFromParameters(
    url: url,
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

/// Converts 6-bit Base-64 character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid base-64 encoded string.
/// - If [padding] is true, the [input] may contain padding characters, which
///   are ignored during decoding.
/// - [codec] is the [Base64Codec] to use. It is derived from the other
///   parameters if not provided.
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters, and the
///   length is not valid for a base-64 encoded string.
///
/// This implementation can handle both the original and URL/filename-safe
/// alphabets. Any letters appearing after the first padding character is
/// observed are ignored. If a partial string is detected, the following bits
/// are assumed to be zeros.
Uint8List fromBase64(
  String input, {
  Base64Codec? codec,
  bool padding = true,
}) {
  codec ??= _codecFromParameters(padding: padding);
  return codec.decoder.convert(input.codeUnits);
}

/// Converts a Base-64 string to an 8-bit integer sequence, returning `null`
/// instead of throwing when the [input] is not valid.
///
/// This is the non-throwing counterpart of [fromBase64]. See [fromBase64] for
/// the meaning of [codec] and [padding].
Uint8List? tryFromBase64(
  String input, {
  Base64Codec? codec,
  bool padding = true,
}) {
  try {
    return fromBase64(input, codec: codec, padding: padding);
  } on FormatException {
    return null;
  }
}
