// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codec.dart';

/// A generic encoder that repacks a bit stream into fixed-width words.
///
/// Treats the input as a continuous stream of [source]-bit words (most
/// significant bit first) and regroups the bits into [target]-bit words,
/// right-padding a trailing partial word with zero bits. Both [source] and
/// [target] must be in the range 2 to 64.
///
/// This is the shared engine behind the fixed-width base codecs.
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
  List<int> convert(covariant List<int> input) {
    final sb = source;
    final tb = target;
    if (sb < 2 || sb > 64) {
      throw ArgumentError.value(source, 'source', 'should be between 2 to 64');
    }
    if (tb < 2 || tb > 64) {
      throw ArgumentError.value(target, 'target', 'should be between 2 to 64');
    }

    int p, s, t, l, n;
    l = input.length * sb;
    n = l ~/ tb;
    if (n * tb < l) n++;
    var out = Uint8List(n);

    // generate words from the input bits
    p = n = l = t = 0;
    s = 1 << (sb - 1);
    s = s ^ (s - 1);
    for (final x in input) {
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

/// A generic decoder that repacks a bit stream into fixed-width words.
///
/// Treats the encoded input as a continuous stream of [source]-bit words (most
/// significant bit first) and regroups the bits into [target]-bit words. A
/// negative value, or a value wider than [source] bits, marks the end of the
/// input. A leftover non-zero partial word throws a [FormatException]. Both
/// [source] and [target] must be in the range 2 to 64.
///
/// This is the shared engine behind the fixed-width base codecs.
abstract class BitDecoder extends BitConverter {
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
  List<int> convert(covariant List<int> encoded) {
    final sb = source;
    final tb = target;
    if (sb < 2 || sb > 64) {
      throw ArgumentError.value(source, 'source', 'should be between 2 to 64');
    }
    if (tb < 2 || tb > 64) {
      throw ArgumentError.value(target, 'target', 'should be between 2 to 64');
    }

    int p, s, t, l, n;
    l = encoded.length * sb;
    var out = Uint8List(l ~/ tb);

    // generate words from the input bits
    p = n = t = l = 0;
    s = 1 << (sb - 1);
    s = s ^ (s - 1);
    for (final x in encoded) {
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

    if (l < out.length) {
      return out.sublist(0, l);
    }
    return out;
  }
}
