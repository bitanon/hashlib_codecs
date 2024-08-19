// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'decoder.dart';
import 'encoder.dart';

abstract class ByteEncoder extends BitEncoder {
  final int bits;

  /// Creates a new [ByteEncoder] instance.
  ///
  /// Parameters:
  /// - [bits] is bit-length of a single word in the output
  const ByteEncoder({
    required this.bits,
  });

  @override
  final int source = 8;

  @override
  int get target => bits;

  @override
  Uint8List convert(List<int> input);
}

abstract class ByteDecoder extends BitDecoder {
  final int bits;

  /// Creates a new [ByteDecoder] instance.
  ///
  /// Parameters:
  /// - [bits] is bit-length of a single word in the output
  const ByteDecoder({
    required this.bits,
  });

  @override
  int get source => bits;

  @override
  final int target = 8;

  @override
  Uint8List convert(List<int> encoded);
}
