// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base32.dart';

/// Codec instance to encode and decode 8-bit integer sequence to Base-32
/// character sequence using the alphabet described in
/// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
/// ```
/// ABCDEFGHIJKLMNOPQRSTUVWXYZ234567
/// ```
const base32 = B32Codec();

/// Same as [base32], but the encoder will use character `=` as padding,
/// which is appended at the end out the output to fill up any partial bytes.
const base32padded = B32Codec.padded();

/// Codec instance to encode and decode 8-bit integer sequence to Base-32
/// character sequence using the lowercase alphabets:
/// ```
/// abcdefghijklmnopqrstuvwxyz234567
/// ```
const base32lower = B32Codec.lower();

/// Same as [base32lower], but the encoder will use character `=` as padding,
/// which is appended at the end out the output to fill up any partial bytes.
const base32paddedlower = B32Codec.paddedlower();

/// Converts 8-bit integer seqence to Base-32 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
/// - If [padding] is true, the encoder will use character `=` as padding,
/// which is appended at the end out the output to fill up any partial bytes.
/// - If [lower] is true, the default lower case alphabets will be used.
///
/// Based on the parameter values, the following codecs are used:
/// - [padding] is `true`, [lower] is `true`: [base32paddedlower]
/// - [padding] is `true`, [lower] is `false`: [base32padded]
/// - [padding] is `false`, [lower] is `true`: [base32lower]
/// - [padding] is `false`, [lower] is `false`: [base32]
String toBase32(
  Iterable<int> input, {
  bool lower = false,
  bool padding = true,
}) {
  var codec = lower
      ? padding
          ? base32paddedlower
          : base32lower
      : padding
          ? base32padded
          : base32;
  return String.fromCharCodes(codec.encoder.convert(input));
}

/// Converts Base-32 integer sequence to 8-bit integer sequence using the
/// [base32] codec.
///
/// Parameters:
/// - [input] should be a valid base-32 encoded string.
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters, and the
///   length is not valid for a base-32 encoded string.
///
/// This implementation can handle both uppercase and lowercase alphabets. Any
/// letters appearing after the first padding character is observed are ignored.
/// If a partial string is detected, the following bits are assumed to be zeros.
Uint8List fromBase32(String input) {
  var out = base32.decoder.convert(input.codeUnits);
  return Uint8List.fromList(out.toList());
}
