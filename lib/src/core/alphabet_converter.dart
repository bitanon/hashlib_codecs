// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'bit_converter.dart';

class AlphabetEncoder extends BitEncoder {
  final int bits;
  final int? padding;
  final List<int> alphabet;

  @override
  final int source = 8;

  @override
  int get target => bits;

  /// Creates a new [AlphabetEncoder] instance.
  const AlphabetEncoder({
    required this.bits,
    required this.alphabet,
    this.padding,
  }) : super(noPadding: padding == null);

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  ///
  /// When the [padding] is not nll, the output array will be padded with the
  /// [padding] to make the length of the array to be divisible by [source].
  @override
  Iterable<int> convert(Iterable<int> input) {
    return super.convert(input).map((x) => x == -1 ? padding! : alphabet[x]);
  }
}

class AlphabetDecoder extends BitDecoder {
  final int bits;
  final int? padding;
  final List<int> alphabet;

  @override
  int get source => bits;

  @override
  final int target = 8;

  /// Creates a new [AlphabetDecoder] instance.
  const AlphabetDecoder({
    required this.bits,
    required this.alphabet,
    this.padding,
  }) : super(noPadding: padding == null);

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  ///
  /// When the [padding] is not null, the converter will stop and return the
  /// output at the first occurence of [padding].
  ///
  /// If the [input] is exhausted leaving a partial bit at the end, a
  /// [FormatException] will be thrown.
  @override
  Iterable<int> convert(Iterable<int> input) {
    int x;
    return super.convert(input.map((y) {
      if (y == padding) return -1;
      if (y < 0 || y >= alphabet.length || (x = alphabet[y]) < 0) {
        throw FormatException('Invalid character $y');
      }
      return x;
    }));
  }
}
