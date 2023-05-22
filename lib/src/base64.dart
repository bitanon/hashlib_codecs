// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base64.dart';

/// Codec instance to encode and decode 8-bit integer sequence to Base-64
/// character sequence using the alphabet described in
/// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
/// ```
/// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
/// ```
const base64 = B64Codec();

/// Same as [base64], but the encoder will use character `=` as padding,
/// which is appended at the end out the output to fill up any partial bytes.
const base64padded = B64Codec.padded();

/// Codec instance to encode and decode 8-bit integer sequence to a modified
/// Base64 character sequence that is both URL and filename safe using the
/// alphabet described in [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
/// ```
/// ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_
/// ```
const base64url = B64Codec.url();

/// Same as [base64url], but the encoder will use character `=` as padding,
/// which is appended at the end out the output to fill up any partial bytes.
const base64urlpadded = B64Codec.urlpadded();

/// Convert 8-bit integer seqence to Base-64 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
/// - If [padding] is true, the encoder will use character `=` as padding,
/// which is appended at the end out the output to fill up any partial bytes.
/// - If [url] is true, the encoder will use the URL/filename-safe alphabets
/// instead of the original one.
///
/// Based on the parameter values, the following codecs are used:
/// - [padding] is `true`, [url] is `true`: [base64urlpadded]
/// - [padding] is `true`, [url] is `false`: [base64padded]
/// - [padding] is `false`, [url] is `true`: [base64url]
/// - [padding] is `false`, [url] is `false`: [base64]
String toBase64(
  Iterable<int> input, {
  bool url = false,
  bool padding = true,
}) {
  var codec = url
      ? padding
          ? base64urlpadded
          : base64url
      : padding
          ? base64padded
          : base64;
  return String.fromCharCodes(codec.encoder.convert(input));
}

/// Convert Base-64 integer sequence to 8-bit integer sequence using the
/// [base64] codec.
///
/// Parameters:
/// - [input] should be a valid base-64 encoded string.
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters, and the
///   length is not valid for a base-64 encoded string.
///
/// This implementation can handle both the original and URL/filename-safe
/// alphabets. Any letters appearing after the first padding character is
/// observed are ignored. If a partial string is detected, the following bits
/// are assumed to be zeros.
Uint8List fromBase64(String input) {
  var out = base64.decoder.convert(input.codeUnits);
  return Uint8List.fromList(out.toList());
}
