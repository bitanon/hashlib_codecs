// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'byte.dart';

/// A [ByteEncoder] that maps each output word to a character code through an
/// [alphabet] lookup table, optionally appending a [padding] character.
///
/// This backs the alphabet-based codecs such as Base-32 and Base-64.
class AlphabetEncoder extends ByteEncoder {
  /// The lookup table mapping each output word value to its character code.
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
    final table = alphabet;
    final pad = padding;
    final tb = target;
    final len = input.length;
    if (tb < 2 || tb > 64) {
      throw ArgumentError.value(target, 'target', 'should be between 2 to 64');
    }

    // number of output words = ceil(total input bits / tb)
    int n = len << 3;
    int outLen = (n + tb - 1) ~/ tb;
    if (pad != null) {
      final low = tb & -tb;
      final period = low < 8 ? 8 ~/ low : 1;
      outLen = ((outLen + period - 1) ~/ period) * period;
    }
    var out = Uint8List(outLen);

    // regroup the input bytes and map each word through the alphabet
    int i, p, l;
    p = n = l = 0;
    for (i = 0; i < len; ++i) {
      p = (p << 8) | (input[i] & 0xFF);
      n += 8;
      while (n >= tb) {
        n -= tb;
        out[l++] = table[p >>> n];
        p &= (1 << n) - 1;
      }
    }

    // if a partial word remains, left-align it, zero-padding the low bits
    if (n > 0) {
      out[l++] = table[p << (tb - n)];
    }

    // fill the remaining slots with the padding character
    if (pad != null) {
      while (l < outLen) {
        out[l++] = pad;
      }
    }

    return out;
  }
}

/// A [ByteDecoder] that maps each input character code to its word value through
/// an [alphabet] lookup table before regrouping the bits.
///
/// This backs the alphabet-based codecs such as Base-32 and Base-64.
class AlphabetDecoder extends ByteDecoder {
  /// The reverse lookup table mapping a character code to its word value, with
  /// `-1` for character codes that are not part of the alphabet.
  final List<int> alphabet;

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
    required super.bits,
    required this.alphabet,
    this.padding,
  });

  @override
  int get source => bits;

  @override
  Uint8List convert(List<int> encoded) {
    final table = alphabet;
    final tlen = table.length;
    final pad = padding;
    final len = encoded.length;
    final sb = source;
    if (sb < 2 || sb > 64) {
      throw ArgumentError.value(source, 'source', 'should be between 2 to 64');
    }

    int i, x, y, p, n, l;
    var out = Uint8List((len * sb) >>> 3);

    p = n = l = 0;
    for (i = 0; i < len; ++i) {
      y = encoded[i];
      if (y == pad) break;
      if (y < 0 || y >= tlen || (x = table[y]) < 0) {
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

    for (; i < len; ++i) {
      y = encoded[i];
      if (y != pad) {
        throw FormatException('Invalid character $y at $i');
      }
    }
    if (p > 0) {
      throw FormatException('Invalid length or non-zero trailing bits');
    }
    if (l < out.length) {
      return out.sublist(0, l);
    }
    return out;
  }
}
