// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'byte.dart';
import 'decoder.dart';

class AlphabetEncoder extends ByteEncoder {
  final List<int> alphabet;

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
    required int bits,
    required this.alphabet,
    this.padding,
  }) : super(bits: bits);

  @override
  int get target => bits;

  @override
  Uint8List convert(List<int> input) {
    int i, n;
    var encoded = super.convert(input) as Uint8List;
    n = encoded.length;
    for (i = 0; i < n; ++i) {
      encoded[i] = alphabet[encoded[i]];
    }
    if (padding == null) {
      return encoded;
    }

    n = encoded.length;
    for (i = n * target; (i & 7) != 0; i += target) {
      n++;
    }
    var out = Uint8List(n);
    for (i = 0; i < encoded.length; ++i) {
      out[i] = encoded[i];
    }
    for (; i < n; ++i) {
      out[i] = padding!;
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
  List<int> convert(List<int> encoded) {
    int x;
    return super.convert(encoded.map((y) {
      if (y == padding) return -1;
      if (y < 0 || y >= alphabet.length || (x = alphabet[y]) < 0) {
        throw FormatException('Invalid character $y');
      }
      return x;
    }).toList());
  }
}
