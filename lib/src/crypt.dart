// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'codecs/crypt/crypt.dart';

export 'codecs/crypt/crypt.dart';

/// An instance of [CryptFormat] for encoding and decoding hash algorithm output
/// with [PHC string format][phc]
///
/// [phc]: https://github.com/C2SP/C2SP/blob/main/phc-strings.md
const crypt = CryptFormat();

/// Encodes [input] into a PHC / Modular Crypt Format string.
///
/// Parameters:
/// - [input] is the [CryptData] to serialize.
///
/// Throws:
/// - [ArgumentError] if any field of [input] is invalid.
String toCrypt(CryptData input) {
  return crypt.encoder.convert(input);
}

/// Decodes a PHC / Modular Crypt Format string into [CryptData].
///
/// Parameters:
/// - [input] is the crypt string to parse.
///
/// Throws:
/// - [FormatException] if [input] is not a well-formed crypt string.
/// - [ArgumentError] if a parsed field is invalid.
CryptData fromCrypt(String input) {
  return crypt.decoder.convert(input);
}
