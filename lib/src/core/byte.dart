// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'decoder.dart';
import 'encoder.dart';

class ByteEncoder extends BitEncoder {
  final int bits;

  @override
  final int source = 8;

  /// Creates a new [ByteEncoder] instance.
  ///
  /// Parameters:
  /// - [bits] is bit-length of a single word in the output
  const ByteEncoder({
    required this.bits,
  });

  @override
  int get target => bits;
}

class ByteDecoder extends BitDecoder {
  final int bits;

  @override
  final int target = 8;

  /// Creates a new [ByteDecoder] instance.
  ///
  /// Parameters:
  /// - [bits] is bit-length of a single word in the output
  const ByteDecoder({
    required this.bits,
  });

  @override
  int get source => bits;
}
