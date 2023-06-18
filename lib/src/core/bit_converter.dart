// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'codec.dart';

abstract class BitEncoder extends BitConverter {
  /// Creates a new [BitEncoder] instance.
  const BitEncoder();

  /// Converts [input] array of numbers with bit-length of [source] to an array
  /// of numbers with bit-length of [target]. The [input] array will be treated
  /// as a sequence of bits to convert.
  ///
  /// When the [padding] is not null, the output array will be padded with the
  /// [padding] to make the length of the array to be divisible by [source].
  @override
  Iterable<int> convert(Iterable<int> input, [int? padding]) sync* {
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
    if (padding != null) {
      for (; (l & 7) != 0; l += target) {
        yield padding;
      }
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
  /// When the [padding] is not null, the converter will stop and return the
  /// output at the first occurence of the [padding].
  ///
  /// If the [input] is exhausted leaving a partial bit at the end, a
  /// [FormatException] will be thrown.
  @override
  Iterable<int> convert(Iterable<int> input, [int? padding]) sync* {
    int x, p, n, s, t;
    p = n = t = 0;
    s = (1 << source) - 1;
    for (x in input) {
      if (x == padding) return;
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
