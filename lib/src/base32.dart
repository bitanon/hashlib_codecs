// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base32.dart';

const int _padding = 0x3d;

/// Supported alphabets for Base-32 conversion
enum Base32Alphabet {
  /// The alphabet from [RFC-4648](https://www.ietf.org/rfc/rfc4648.html):
  /// ```
  /// ABCDEFGHIJKLMNOPQRSTUVWXYZ2345678
  /// ```
  rfc,

  /// Alias of [Base32Alphabet.rfc]
  uppercase,

  /// The lowercase alphabet from the [Base32Alphabet.rfc]:
  /// ```
  /// abcdefghijklmnopqrstuvwxyz234567
  /// ```
  lower,
}

extension on Base32Alphabet {
  Base32Codec get codec {
    switch (this) {
      case Base32Alphabet.rfc:
      case Base32Alphabet.uppercase:
        return Base32Codec.rfc;
      case Base32Alphabet.lower:
        return Base32Codec.rfcLower;
    }
  }
}

/// Converts 8-bit integer sequence to 5-bit Base-32 character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
/// - [alphabet] configures the alphabet to use. DefaultL: [Base32Alphabet.rfc].
/// - If [padding] is true, the encoder will use character `=` as padding,
///   which is appended at the end out the output to fill up any partial bytes.
String toBase32(
  Iterable<int> input, {
  bool padding = true,
  Base32Alphabet alphabet = Base32Alphabet.rfc,
}) {
  var out = alphabet.codec.encoder.convert(
    input,
    padding ? _padding : null,
  );
  return String.fromCharCodes(out);
}

/// Converts 5-bit Base-32 character sequence to 8-bit integer sequence.
///
/// Parameters:
/// - [input] should be a valid base-32 encoded string.
/// - [alphabet] configures the alphabet to use. DefaultL: [Base32Alphabet.rfc].
/// - If [padding] is true, the decoder will use character `=` as padding and
///   stop when encountering it, otherwise it will be treated as an invalid
///   character and [FormatException] will be thrown.
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
  bool padding = true,
  Base32Alphabet alphabet = Base32Alphabet.rfc,
}) {
  var out = alphabet.codec.decoder.convert(
    input.codeUnits,
    padding ? _padding : null,
  );
  return Uint8List.fromList(out.toList());
}
