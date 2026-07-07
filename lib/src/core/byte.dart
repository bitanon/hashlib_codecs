// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'decoder.dart';
import 'encoder.dart';

/// A [BitEncoder] whose input words are 8-bit bytes.
///
/// Fixes [source] to 8 and exposes the output word size through [bits], so a
/// subclass only chooses that width (e.g. 4 for Base-16, 5 for Base-32, 6 for
/// Base-64).
abstract class ByteEncoder extends BitEncoder {
  /// The bit-length of a single word in the encoded output.
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

/// A [BitDecoder] whose output words are 8-bit bytes.
///
/// Fixes [target] to 8 and exposes the input word size through [bits], so a
/// subclass only chooses that width (e.g. 4 for Base-16, 5 for Base-32, 6 for
/// Base-64).
abstract class ByteDecoder extends BitDecoder {
  /// The bit-length of a single word in the encoded input.
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
