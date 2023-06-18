// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base64.dart';

/// Supported alphabets for Base-32 conversion
enum Base64Alphabet {
  /// The alphabet from [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZ
  /// abcdefghijklmnopqrstuvwxyz
  /// 0123456789+/
  /// ```
  rfc,

  /// URL and filename safe alphabet from
  /// [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZ
  /// abcdefghijklmnopqrstuvwxyz
  /// 0123456789-_
  /// ```
  urlSafe,
}

extension on Base64Alphabet {
  Base64Codec get codec {
    switch (this) {
      case Base64Alphabet.rfc:
        return Base64Codec.rfc;
      case Base64Alphabet.urlSafe:
        return Base64Codec.urlSafe;
    }
  }
}

/// Converts 8-bit integer sequence to 6-bit Base-64 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
/// - [alphabet] configures the alphabet to use. DefaultL: [Base32Alphabet.rfc].
/// - If [padding] is true, the encoder will use character `=` as padding,
/// which is appended at the end out the output to fill up any partial bytes.
String toBase64(
  Iterable<int> input, {
  bool padding = true,
  Base64Alphabet alphabet = Base64Alphabet.rfc,
}) {
  var encoder = alphabet.codec.encoder;
  var out = encoder.convert(input);
  if (!padding) {
    out = out.takeWhile((value) => value != encoder.padding);
  }
  return String.fromCharCodes(out);
}

/// Converts 6-bit Base-64 character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid base-64 encoded string.
/// - [alphabet] configures the alphabet to use. DefaultL: [Base32Alphabet.rfc].
/// - If [padding] is true, the decoder will use character `=` as padding and
///   stop when encountering it, otherwise it will be treated as an invalid
///   character and [FormatException] will be thrown.
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
  bool padding = true,
  Base64Alphabet alphabet = Base64Alphabet.rfc,
}) {
  var out = alphabet.codec.decoder.convert(input.codeUnits);
  return Uint8List.fromList(out.toList());
}
