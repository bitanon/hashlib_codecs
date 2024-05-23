// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'codecs/crypt.dart';

export 'codecs/crypt.dart';

/// An instance of [CryptFormat] for encoding and decoding hash algorithm output
/// with [PHC string format][phc]
///
/// [phc]: https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md
const crypt = CryptFormat();

/// Encodes a hash algorithm output to string following PHC string format.
String toCrypt(CryptData input) {
  return crypt.encoder.convert(input);
}

/// Decodes a string to an hash algorithm config following PHC string format.
CryptData fromCrypt(String input) {
  return crypt.decoder.convert(input);
}
