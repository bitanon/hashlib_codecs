// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' show Codec, Converter;
import 'dart:typed_data';

abstract class BitConverter extends Converter<Iterable<int>, Iterable<int>> {
  /// Creates a new [BitConverter] instance.
  const BitConverter();

  /// The bit-length of the input array elements.
  int get source;

  /// The bit-length of the output array elements.
  int get target;

  /// The final elements that may appear at the end.
  int? get padding => null;

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  @override
  Iterable<int> convert(Iterable<int> input);
}

abstract class ByteCodec extends Codec<Iterable<int>, Iterable<int>> {
  const ByteCodec();

  @override
  BitConverter get encoder;

  @override
  BitConverter get decoder;

  /// Encodes an [input] string using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> encodeString(String input) {
    return encoder.convert(input.codeUnits);
  }

  /// Decodes an [input] string using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> decodeString(String input) {
    return decoder.convert(input.codeUnits);
  }

  /// Encodes an [input] buffer using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> encodeBuffer(ByteBuffer buffer) {
    return encoder.convert(buffer.asUint8List());
  }

  /// Decodess an [input] buffer using this codec
  @pragma('vm:prefer-inline')
  Iterable<int> decodeBuffer(ByteBuffer buffer) {
    return decoder.convert(buffer.asUint8List());
  }

  /// Encodes an [input] using this codec and returns string
  @pragma('vm:prefer-inline')
  String encodeToString(Iterable<int> input) {
    return String.fromCharCodes(encoder.convert(input));
  }

  /// Decodes an [input] using this codec and returns string
  @pragma('vm:prefer-inline')
  String decodeToString(Iterable<int> input) {
    return String.fromCharCodes(decoder.convert(input));
  }

  /// Encodes an [input] string using this codec and returns string
  @pragma('vm:prefer-inline')
  String encodeStringToString(String input) {
    return String.fromCharCodes(encoder.convert(input.codeUnits));
  }

  /// Decodes an [input] string using this codec and returns string
  @pragma('vm:prefer-inline')
  String decodeStringToString(String input) {
    return String.fromCharCodes(decoder.convert(input.codeUnits));
  }

  /// Encodes an [input] buffer using this codec and returns string
  @pragma('vm:prefer-inline')
  String encodeBufferToString(ByteBuffer buffer) {
    return String.fromCharCodes(encoder.convert(buffer.asUint8List()));
  }

  /// Decodes an [input] buffer using this codec and returns string
  @pragma('vm:prefer-inline')
  String decodeBufferToString(ByteBuffer buffer) {
    return String.fromCharCodes(decoder.convert(buffer.asUint8List()));
  }
}
