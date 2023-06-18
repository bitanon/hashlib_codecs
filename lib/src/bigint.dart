// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/bigint.dart';

BigIntCodec _codecFromParameters({
  bool bigEndian = false,
}) {
  if (bigEndian) {
    return BigIntCodec.big;
  } else {
    return BigIntCodec.little;
  }
}

/// Converts 8-bit integer sequence to [BigInt].
///
/// Parameters:
/// - [input] is a sequence of 8-bit integers.
/// - If [bigEndian] is true, the [input] bytes are treated as big-endian order
///   giving the first byte the most significant value, otherwise the bytes are
///   treated as little-endian order, giving the first byte the least
///   significant value.
/// - [codec] is the [BigIntCodec] to use. It is derived from the other
///   parameters if not provided.
///
/// Throws:
/// - [FormatException] when the [input] is empty.
BigInt toBigInt(
  Iterable<int> input, {
  BigIntCodec? codec,
  bool bigEndian = false,
}) {
  codec ??= _codecFromParameters(bigEndian: bigEndian);
  return codec.encoder.convert(input);
}

/// Converts a [BigInt] to 8-bit integer sequence.
///
/// Parameters:
/// - [input] is a non-negative [BigInt].
/// - If [bigEndian] is true, the [input] bytes are treated as big-endian order
///   giving the first byte the most significant value, otherwise the bytes are
///   treated as little-endian order, giving the first byte the least
///   significant value.
/// - [codec] is the [BigIntCodec] to use. It is derived from the other
///   parameters if not provided.
///
/// Raises:
/// - [FormatException] when the [input] is negative.
Uint8List fromBigInt(
  BigInt input, {
  BigIntCodec? codec,
  bool bigEndian = false,
}) {
  codec ??= _codecFromParameters(bigEndian: bigEndian);
  var out = codec.decoder.convert(input);
  return Uint8List.fromList(out.toList());
}
