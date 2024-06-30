// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'decoder.dart';
import 'encoder.dart';

class AlphabetEncoder extends BitEncoder {
  final int bits;
  final List<int> alphabet;

  @override
  final int source = 8;

  /// The padding character.
  ///
  /// The output array will be padded with this character to make the length
  /// of the array to be divisible by [source].
  final int? padding;

  /// Creates a new [AlphabetEncoder] instance.
  ///
  /// Parameters:
  /// - [bits] is bit-length of a single word in the output
  /// - The [alphabet] contains mapping from input word to output word.
  /// - The output array will be padded with the [padding] to make the length of
  ///   the array to be divisible by [source].
  const AlphabetEncoder({
    required this.bits,
    required this.alphabet,
    this.padding,
  });

  @override
  int get target => bits;

  @override
  Iterable<int> convert(Iterable<int> input) {
    var out = super.convert(input).map((x) => alphabet[x]).toList();
    int l = out.length * target;
    if (padding != null) {
      for (; (l & 7) != 0; l += target) {
        out.add(padding!);
      }
    }
    return out;
  }
}

class AlphabetDecoder extends BitDecoder {
  final int bits;
  final List<int> alphabet;

  @override
  final int target = 8;

  /// The padding character.
  ///
  /// The conversion will stop immediately upon encountering this character.
  final int? padding;

  /// Creates a new [AlphabetDecoder] instance.
  ///
  /// Parameters:
  /// - [bits] is bit-length of a single word in the output
  /// - The [alphabet] contains mapping from input word to output word.
  /// - If [padding] is not null, conversion will stop immediately upon
  ///   encountering this character.
  const AlphabetDecoder({
    required this.bits,
    required this.alphabet,
    this.padding,
  });

  @override
  int get source => bits;

  @override
  Iterable<int> convert(Iterable<int> encoded) {
    int x;
    return super.convert(encoded.map((y) {
      if (y == padding) return -1;
      if (y < 0 || y >= alphabet.length || (x = alphabet[y]) < 0) {
        throw FormatException('Invalid character $y');
      }
      return x;
    }));
  }
}
