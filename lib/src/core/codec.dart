// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' show Codec, Converter;
import 'dart:typed_data';

import 'bit.dart';

/// Base class for encoding from and to 8-bit integer sequence
abstract class IterableCodec extends Codec<Iterable<int>, Iterable<int>> {
  /// Creates a new [IterableCodec] instance.
  const IterableCodec();

  @override
  BitEncoder get encoder;

  @override
  BitDecoder get decoder;

  /// Encodes an [input] buffer using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> encodeBuffer(covariant ByteBuffer input) =>
      encode(input.asUint8List());

  /// Decodes an [encoded] buffer using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> decodeBuffer(covariant ByteBuffer encoded) =>
      decode(encoded.asUint8List());
}

/// Base class for bit-wise encoder and decoder implementation
abstract class BitConverter extends Converter<Iterable<int>, Iterable<int>> {
  /// Creates a new [BitConverter] instance.
  const BitConverter();

  /// The bit-length of the input array elements.
  /// The value should be between 2 to 64.
  int get source;

  /// The bit-length of the output array elements.
  /// The value should be between 2 to 64.
  int get target;

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  @override
  Iterable<int> convert(covariant Iterable<int> input);
}
