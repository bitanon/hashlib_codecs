// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

/// Returns a copy of [input] with every ASCII whitespace code unit removed.
///
/// The characters treated as whitespace are the space (`0x20`) and the C0
/// control range `0x09`..`0x0D`: horizontal tab (`\t`), line feed (`\n`),
/// vertical tab (`\v`), form feed (`\f`), and carriage return (`\r`). These are
/// the characters that line-wrapped encodings such as PEM and MIME insert into
/// otherwise valid Base-16/32/64 payloads.
///
/// Every other code unit is preserved exactly, including values above `0xFF`,
/// so that a subsequent decoder still rejects genuinely invalid characters. The
/// returned list is a plain `List<int>` (never a `Uint8List`) for the same
/// reason — a `Uint8List` would truncate wide code units and could mask an
/// invalid character as a valid one.
List<int> stripWhitespace(List<int> input) {
  final n = input.length;
  final out = List<int>.filled(n, 0);
  int i, j, c;
  j = 0;
  for (i = 0; i < n; ++i) {
    c = input[i];
    if (c == 0x20 || (c >= 0x09 && c <= 0x0D)) continue;
    out[j++] = c;
  }
  if (j == n) return out;
  return out.sublist(0, j);
}
