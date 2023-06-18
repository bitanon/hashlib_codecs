// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' show Codec;
import 'dart:typed_data';

import 'converter.dart';

/// Base class for encoding from and to 8-bit integer sequence
abstract class ByteCodec extends Codec<Iterable<int>, Iterable<int>> {
  /// Creates a new [ByteCodec] instance.
  const ByteCodec();

  @override
  BitConverter get encoder;

  @override
  BitConverter get decoder;

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
