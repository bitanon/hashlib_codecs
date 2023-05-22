// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/base2.dart';

/// Codec instance to encode and decode 8-bit integer sequence to Base-2 or
/// Binary character sequence using the alphabet: `01`
const base2 = BinaryCodec();

/// Converts 8-bit integer seqence to Binary character sequence.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers
///
/// **Note that**, this implementation is a byte-wise encoding of the input
/// array. You can use `toBigInt` to obtain actual binary representation in
/// either little-endian or big-endian order from the [input].
String toBinary(Iterable<int> input) {
  var out = base2.encoder.convert(input);
  return String.fromCharCodes(out);
}

/// Converts Binary integer sequence to 8-bit integer sequence using the [base2]
/// codec.
///
/// Parameters:
/// - [input] should be a valid binary/base-2 encoded string.
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters.
///
/// If a partial string is detected, the following bits are assumed to be zeros.
Uint8List fromBinary(String input) {
  var out = base2.decoder.convert(input.codeUnits);
  return Uint8List.fromList(out.toList());
}
