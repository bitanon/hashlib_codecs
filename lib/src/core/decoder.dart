// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'codec.dart';

abstract class BitDecoder extends HashlibConverter {
  /// Creates a new [BitDecoder] instance.
  const BitDecoder();

  /// Converts [encoded] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [encoded] array will be treated
  /// as a sequence of bits to convert.
  ///
  /// If the [encoded] array contains negative numbers or numbers having more than
  /// the [source] bits, it will be treated as the end of the input sequence.
  ///
  /// After consuming all of input sequence, if there are some non-zero partial
  /// word remains, it will throw [FormatException].
  @override
  Iterable<int> convert(Iterable<int> encoded) sync* {
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
    for (x in encoded) {
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
