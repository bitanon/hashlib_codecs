// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'codec.dart';

abstract class BitEncoder extends BitConverter {
  // Whether to skip adding -1 at the end
  final bool noPadding;

  /// Creates a new [BitEncoder] instance.
  const BitEncoder({
    this.noPadding = true,
  });

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  ///
  /// When the [noPadding] is true, the output array will be padded with the
  /// `-1` to make the length of the array to be divisible by [source].
  @override
  Iterable<int> convert(Iterable<int> input) sync* {
    int x, p, n, s, t, l;
    p = n = l = t = 0;
    s = (1 << source) - 1;
    for (x in input) {
      p = (p << source) ^ (x & s);
      t = (t << source) ^ s;
      n += source;
      while (n >= target) {
        n -= target;
        l += target;
        yield p >>> n;
        t >>>= target;
        p &= t;
      }
    }
    if (n > 0) {
      l += target;
      yield p << (target - n);
    }
    if (!noPadding) {
      for (; (l & 7) != 0; l += target) {
        yield -1;
      }
    }
  }
}

abstract class BitDecoder extends BitConverter {
  // Whether to continue when -1 is detected
  final bool noPadding;

  /// Creates a new [BitDecoder] instance.
  const BitDecoder({
    this.noPadding = true,
  });

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  ///
  /// When the [noPadding] is true, the converter will stop and return the
  /// output at the first occurence of `-1`.
  ///
  /// If the [input] is exhausted leaving a partial bit at the end, a
  /// [FormatException] will be thrown.
  @override
  Iterable<int> convert(Iterable<int> input) sync* {
    int x, p, n, s, t;
    p = n = t = 0;
    s = (1 << source) - 1;
    for (x in input) {
      if (x == -1 && !noPadding) return;
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
    if (p > 0) {
      throw FormatException('Invalid length');
    }
  }
}
