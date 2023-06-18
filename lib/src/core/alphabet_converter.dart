// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'bit_converter.dart';

class AlphabetEncoder extends BitEncoder {
  final int bits;
  final int? _padding;
  final List<int> alphabet;

  /// Creates a new [AlphabetEncoder] instance.
  const AlphabetEncoder({
    int? padding,
    required this.bits,
    required this.alphabet,
  }) : _padding = padding;

  @override
  final int source = 8;

  @override
  int get target => bits;

  @override
  int? get padding => _padding == null ? null : -1;

  @override
  Iterable<int> convert(Iterable<int> input) {
    return super
        .convert(input)
        .map((x) => x == padding ? _padding! : alphabet[x]);
  }
}

class AlphabetDecoder extends BitDecoder {
  final int bits;
  final int? _padding;
  final List<int> alphabet;

  /// Creates a new [AlphabetDecoder] instance.
  const AlphabetDecoder({
    int? padding,
    required this.bits,
    required this.alphabet,
  }) : _padding = padding;

  @override
  int get source => bits;

  @override
  final int target = 8;

  @override
  int? get padding => -1;

  @override
  Iterable<int> convert(Iterable<int> input) {
    int x;
    return super.convert(input.map((y) {
      if (y == _padding) return -1;
      if (y >= alphabet.length || (x = alphabet[y]) < 0) {
        throw FormatException('Invalid character $y');
      }
      return x;
    }));
  }
}
