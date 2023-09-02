// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'codecs/phc_sf.dart';

export 'codecs/phc_sf.dart';

/// An instance of [PHCSF] for encoding and decoding hash algorithm output with
/// [PHC string format](https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md)
const phcsf = PHCSF();

/// Encodes a hash algorithm output to string following PHC string format.
String toPHCSF(PHCSFData input) {
  return phcsf.encoder.convert(input);
}

/// Decodes a string to an hash algorithm config following PHC string format.
PHCSFData fromPHCSF(String input) {
  return phcsf.decoder.convert(input);
}
