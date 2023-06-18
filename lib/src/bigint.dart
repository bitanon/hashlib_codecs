// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/bigint.dart';

/// Converts 8-bit integer sequence to [BigInt].
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - [endian] is the order of the input bytes.
///
/// Throws:
/// - [FormatException] when the [input] is empty.
BigInt toBigInt(Iterable<int> input, {Endian endian = Endian.little}) {
  var codec = endian == Endian.little ? BigIntCodec.little : BigIntCodec.big;
  return codec.encoder.convert(input);
}

/// Converts a [BigInt] to 8-bit integer sequence.
///
/// Parameters:
/// - [input] is a non-negative [BigInt]
/// - [endian] determines the order of the output bytes.
///
/// Raises:
/// - [FormatException] when the [input] is negative.
Uint8List fromBigInt(BigInt input, {Endian endian = Endian.little}) {
  var codec = endian == Endian.little ? BigIntCodec.little : BigIntCodec.big;
  var out = codec.decoder.convert(input);
  return Uint8List.fromList(out.toList());
}
