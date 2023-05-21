// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base2.dart';

/// Codec instance to encode and decode 8-bit integer sequence to Base-2 or
/// Binary character sequence using the alphabet: `01`
const base2 = BinaryCodec();

/// Converts 8-bit integer seqence to Binary character sequence.
String toBinary(Iterable<int> input) {
  var out = base2.encoder.convert(input);
  return String.fromCharCodes(out);
}

/// Converts Binary integer sequence to 8-bit integer sequence using the [base2]
/// codec.
///
/// If a partial string is detected, the following bits are assumed to be zeros.
Uint8List fromBinary(String input) {
  var out = base2.decoder.convert(input.codeUnits);
  return Uint8List.fromList(out.toList());
}
