// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'codec.dart';

abstract class BitEncoder extends HashlibConverter {
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
