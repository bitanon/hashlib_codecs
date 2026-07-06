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
    required super.bits,
    required this.alphabet,
    this.padding,
  });

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
  Uint8List convert(List<int> encoded) {
    int i, x, y, p, n, l, sb;
    sb = bits;
    if (sb < 2 || sb > 64) {
      throw ArgumentError('The source bit length should be between 2 to 64');
    }

    var out = Uint8List((encoded.length * sb) >>> 3);

    // fuse the alphabet lookup with the bit regrouping to avoid building an
    // intermediate list per call
    p = n = l = 0;
    for (i = 0; i < encoded.length; ++i) {
      y = encoded[i];
      if (y == padding) break;
      if (y < 0 || y >= alphabet.length || (x = alphabet[y]) < 0) {
        throw FormatException('Invalid character $y at $i');
      }
      p = (p << sb) ^ x;
      n += sb;
      while (n >= 8) {
        n -= 8;
        out[l++] = p >>> n;
        p &= (1 << n) - 1;
      }
    }

    // conversion stops at the first padding character, but the rest of
    // the input must still be padding or alphabet characters
    for (; i < encoded.length; ++i) {
      y = encoded[i];
      if (y != padding) {
        throw FormatException('Invalid character $y at $i');
      }
    }

    // p > 0 means that there is a non-zero partial word remaining
    if (p > 0) {
      throw FormatException('Invalid length');
    }

    if (l < out.length) {
      return out.sublist(0, l);
    }
    return out;
  }
}
