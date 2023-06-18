// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'bit_converter.dart';

class AlphabetEncoder extends BitEncoder {
  final int bits;
  final List<int> alphabet;

  /// Creates a new [AlphabetEncoder] instance.
  const AlphabetEncoder({
    required this.bits,
    required this.alphabet,
  });

  @override
  final int source = 8;

  @override
  int get target => bits;

  @override
  Iterable<int> convert(Iterable<int> input, [int? padding]) {
    if (padding == null) {
      return super.convert(input).map((x) => alphabet[x]);
    } else {
      return super
          .convert(input, -1)
          .map((x) => x == -1 ? padding : alphabet[x]);
    }
  }
}

class AlphabetDecoder extends BitDecoder {
  final int bits;
  final List<int> alphabet;

  @override
  int get source => bits;

  @override
  final int target = 8;

  /// Creates a new [AlphabetDecoder] instance.
  const AlphabetDecoder({
    required this.bits,
    required this.alphabet,
  });

  @override
  Iterable<int> convert(Iterable<int> input, [int? padding]) {
    int x;
    if (padding == null) {
      return super.convert(input.map((y) {
        if (y < 0 || y >= alphabet.length || (x = alphabet[y]) < 0) {
          throw FormatException('Invalid character $y');
        }
        return x;
      }));
    } else {
      return super.convert(input.map((y) {
        if (y == padding) return -1;
        if (y < 0 || y >= alphabet.length || (x = alphabet[y]) < 0) {
          throw FormatException('Invalid character $y');
        }
        return x;
      }), -1);
    }
  }
}
