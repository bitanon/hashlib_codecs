// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

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
  // TODO: sync is slow. use typed list
  @override
  Iterable<int> convert(Iterable<int> encoded) {
    int x, p, s, t, l, n, sb, tb;
    sb = source;
    tb = target;
    if (sb < 2 || sb > 64) {
      throw ArgumentError('The source bit length should be between 2 to 64');
    }
    if (tb < 2 || tb > 64) {
      throw ArgumentError('The target bit length should be between 2 to 64');
    }

    List<int> list = encoded is List<int> ? encoded : List<int>.of(encoded);
    l = list.length * sb;
    var out = Uint8List(l ~/ tb);

    // generate words from the input bits
    p = n = t = l = 0;
    s = 1 << (sb - 1);
    s = s ^ (s - 1);
    for (x in list) {
      if (x < 0 || x > s) break;
      p = (p << sb) ^ x;
      t = (t << sb) ^ s;
      n += sb;
      while (n >= tb) {
        n -= tb;
        out[l++] = p >>> n;
        t >>>= tb;
        p &= t;
      }
    }

    // p > 0 means that there is a non-zero partial word remaining
    if (p > 0) {
      throw FormatException('Invalid length');
    }

    return Uint8List.view(out.buffer, 0, l);
  }
}
