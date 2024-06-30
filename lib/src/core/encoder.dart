// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

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
  Iterable<int> convert(Iterable<int> input) {
    int x, p, s, t, l, n, sb, tb;
    sb = source;
    tb = target;
    if (sb < 2 || sb > 64) {
      throw ArgumentError('The source bit length should be between 2 to 64');
    }
    if (tb < 2 || tb > 64) {
      throw ArgumentError('The target bit length should be between 2 to 64');
    }

    List<int> list = input is List<int> ? input : List<int>.of(input);
    l = list.length * sb;
    n = l ~/ tb;
    if (n * tb < l) n++;
    var out = Uint8List(n);

    // generate words from the input bits
    p = n = l = t = 0;
    s = 1 << (sb - 1);
    s = s ^ (s - 1);
    for (x in list) {
      p = (p << sb) ^ (x & s);
      t = (t << sb) ^ s;
      n += sb;
      while (n >= tb) {
        n -= tb;
        out[l++] = p >>> n;
        t >>>= tb;
        p &= t;
      }
    }

    // n > 0 means that there is a partial word remaining.
    if (n > 0) {
      // pad the word with 0 on the right to make the final word
      out[l++] = p << (tb - n);
    }

    return out;
  }
}
