// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' show Codec, Converter;
import 'dart:typed_data';

import 'decoder.dart';
import 'encoder.dart';

/// Base class for encoding from and to 8-bit integer sequence
abstract class HashlibCodec extends Codec<Iterable<int>, Iterable<int>> {
  /// Creates a new [HashlibCodec] instance.
  const HashlibCodec();

  @override
  BitEncoder get encoder;

  @override
  BitDecoder get decoder;

  /// Encodes an [input] string using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> encodeString(String input) => encode(input.codeUnits);

  /// Decodes an [encoded] string using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> decodeString(String encoded) => decode(encoded.codeUnits);

  /// Encodes an [input] buffer using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> encodeBuffer(ByteBuffer input) => encode(input.asUint8List());

  /// Decodess an [encoded] buffer using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> decodeBuffer(ByteBuffer encoded) =>
      decode(encoded.asUint8List());
}

/// Base class for bit-wise encoder and decoder implementation
abstract class HashlibConverter
    extends Converter<Iterable<int>, Iterable<int>> {
  /// Creates a new [HashlibConverter] instance.
  const HashlibConverter();

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
  Iterable<int> convert(Iterable<int> input);
}
