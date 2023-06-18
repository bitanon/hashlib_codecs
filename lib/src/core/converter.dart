// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' show Converter;

// ========================================================
// Base Converter for encoding and decoding
// ========================================================

/// Base class for bit-wise encoder and decoder implementation
abstract class BitConverter extends Converter<Iterable<int>, Iterable<int>> {
  /// Creates a new [BitConverter] instance.
  const BitConverter();

  /// The bit-length of the input array elements.
  /// The value should be between 2 to 64.
  int get source;

  /// The bit-length of the output array elements.
  /// The value should be between 2 to 64.
  int get target;

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  @override
  Iterable<int> convert(Iterable<int> input);
}

// ========================================================
// Encoder and Decoder for orbitrary bits
// ========================================================

abstract class BitEncoder extends BitConverter {
  /// Creates a new [BitEncoder] instance.
  const BitEncoder();

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  ///
  /// After consuming all of input sequence, if there are some non-zero partial
  /// word remains, 0 will be padded on the right to make the final word.
  @override
  Iterable<int> convert(Iterable<int> input) sync* {
    if (source < 2 || source > 64) {
      throw ArgumentError('The source bit length should be between 2 to 64');
    }
    if (target < 2 || target > 64) {
      throw ArgumentError('The target bit length should be between 2 to 64');
    }

    int x, p, n, s, t;
    p = n = t = 0;

    // s = (2^source) - 1
    s = 1 << (source - 1);
    s = s ^ (s - 1);

    // generate words from the input bits
    for (x in input) {
      p = (p << source) ^ (x & s);
      t = (t << source) ^ s;
      n += source;
      while (n >= target) {
        n -= target;
        yield p >>> n;
        t >>>= target;
        p &= t;
      }
    }

    // n > 0 means that there is a partial word remaining.
    if (n > 0) {
      // pad the word with 0 on the right to make the final word
      yield p << (target - n);
    }
  }
}

abstract class BitDecoder extends BitConverter {
  /// Creates a new [BitDecoder] instance.
  const BitDecoder();

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  ///
  /// If the [input] array contains negative numbers or numbers having more than
  /// the [source] bits, it will be treated as the end of the input sequence.
  ///
  /// After consuming all of input sequence, if there are some non-zero partial
  /// word remains, it will throw [FormatException].
  @override
  Iterable<int> convert(Iterable<int> input) sync* {
    if (source < 2 || source > 64) {
      throw ArgumentError('The source bit length should be between 2 to 64');
    }
    if (target < 2 || target > 64) {
      throw ArgumentError('The target bit length should be between 2 to 64');
    }

    int x, p, n, s, t;
    p = n = t = 0;

    // s = (2^source) - 1
    s = 1 << (source - 1);
    s = s ^ (s - 1);

    // generate words from the input bits
    for (x in input) {
      if (x < 0 || x > s) break;
      p = (p << source) ^ x;
      t = (t << source) ^ s;
      n += source;
      while (n >= target) {
        n -= target;
        yield p >>> n;
        t >>>= target;
        p &= t;
      }
    }

    // p > 0 means that there is a non-zero partial word remaining
    if (p > 0) {
      throw FormatException('Invalid length');
    }
  }
}

// ========================================================
// Encoder and Decoder for 8-bit integer sequence
// ========================================================

abstract class ByteEncoder extends BitEncoder {
  @override
  final int source = 8;

  /// Creates a new [ByteEncoder] instance.
  const ByteEncoder();
}

abstract class ByteDecoder extends BitDecoder {
  @override
  final int target = 8;

  /// Creates a new [ByteDecoder] instance.
  const ByteDecoder();
}

// ========================================================
// Encoder and Decoder with an Alphabet for mapping
// ========================================================

class AlphabetEncoder extends ByteEncoder {
  final int bits;
  final List<int> alphabet;

  /// The padding character.
  ///
  /// The output array will be padding with this character to make the length
  /// of the array to be divisible by [source].
  final int? padding;

  /// Creates a new [AlphabetEncoder] instance.
  const AlphabetEncoder({
    required this.bits,
    required this.alphabet,
    this.padding,
  });

  @override
  int get target => bits;

  @override
  Iterable<int> convert(Iterable<int> input) sync* {
    int p, l = 0;
    for (final x in super.convert(input)) {
      yield alphabet[x];
      l += target;
    }
    if (padding != null) {
      p = padding!;
      for (; (l & 7) != 0; l += target) {
        yield p;
      }
    }
  }
}

class AlphabetDecoder extends ByteDecoder {
  final int bits;
  final List<int> alphabet;

  /// The padding character.
  ///
  /// The conversion will stop immediately upon encountering this character.
  final int? padding;

  /// Creates a new [AlphabetDecoder] instance.
  const AlphabetDecoder({
    required this.bits,
    required this.alphabet,
    this.padding,
  });

  @override
  int get source => bits;

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
