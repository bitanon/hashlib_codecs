// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/bigint.dart';

/// Codec instance to encode and decode [BigInt] to byte sequence in
/// big-endian order.
const bigintBE = BigIntCodec.big();

/// Codec instance to encode and decode [BigInt] to byte sequence in
/// little-endian order.
const bigintLE = BigIntCodec.little();

/// Converts a byte sequence to [BigInt]. It will raise [FormatException] if
/// the [input] is empty.
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - [endian] is the order of the input bytes.
///
/// Throws:
/// - [FormatException] when the [input] is empty
BigInt toBigInt(Iterable<int> input, {Endian endian = Endian.little}) {
  var codec = endian == Endian.little ? bigintLE : bigintBE;
  return codec.encoder.convert(input);
}

/// Converts a [BigInt] to byte sequence. It will raise [FormatException] if
/// the [input] is negative.
///
/// Parameters:
/// - [input] is a non-negative [BigInt]
/// - [endian] determines the order of the output bytes.
///
/// Throws:
/// - [FormatException] when the [input] is negative.
Uint8List fromBigInt(BigInt input, {Endian endian = Endian.little}) {
  var codec = endian == Endian.little ? bigintLE : bigintBE;
  return Uint8List.fromList(codec.decoder.convert(input).toList());
}
