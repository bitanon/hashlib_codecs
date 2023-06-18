// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/bigint.dart';

BigIntCodec _codecFromParameters({
  bool msbFirst = false,
}) {
  if (msbFirst) {
    return BigIntCodec.msbFirst;
  } else {
    return BigIntCodec.lsbFirst;
  }
}

/// Converts 8-bit integer sequence to [BigInt].
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - If [msbFirst] is true, [input] bytes are read in big-endian order giving
///   the first byte the most significant value, otherwise the bytes are read as
///   little-endian order, giving the first byte the least significant value.
/// - [codec] is the [BigIntCodec] to use. It is derived from the other
///   parameters if not provided.
///
/// Throws:
/// - [FormatException] when the [input] is empty.
BigInt toBigInt(
  Iterable<int> input, {
  BigIntCodec? codec,
  bool msbFirst = false,
}) {
  codec ??= _codecFromParameters(msbFirst: msbFirst);
  return codec.encoder.convert(input);
}

/// Converts a [BigInt] to 8-bit integer sequence.
///
/// Parameters:
/// - [input] is a non-negative [BigInt].
/// - If [msbFirst] is true, [input] bytes are read in big-endian order giving
///   the first byte the most significant value, otherwise the bytes are read as
///   little-endian order, giving the first byte the least significant value.
/// - [codec] is the [BigIntCodec] to use. It is derived from the other
///   parameters if not provided.
///
/// Raises:
/// - [FormatException] when the [input] is negative.
Uint8List fromBigInt(
  BigInt input, {
  BigIntCodec? codec,
  bool msbFirst = false,
}) {
  codec ??= _codecFromParameters(msbFirst: msbFirst);
  var out = codec.decoder.convert(input);
  return Uint8List.fromList(out.toList());
}
