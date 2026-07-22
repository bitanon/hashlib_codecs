// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

/// Compares [a] and [b] for equality in constant time.
///
/// Returns true only if both have the same length and every element is equal.
/// The comparison does not exit early on the first mismatching element, so its
/// running time depends only on the length of the inputs and not on where they
/// differ. This makes it safe for comparing secrets such as MACs and message
/// digests, where an early return would leak how many leading bytes matched.
///
/// The length of the inputs is not treated as secret: a length mismatch returns
/// false immediately. This is the only early return, and it branches only on
/// the public lengths — never on the contents. Once the lengths match, every
/// element is folded into an accumulator with no data-dependent branch, so the
/// running time depends only on the length.
///
/// Parameters:
/// - [a] and [b] are the byte sequences to compare.
bool constantTimeEquals(List<int> a, List<int> b) {
  int n = a.length;
  if (n != b.length) {
    return false;
  }
  int diff = 0;
  for (int i = 0; i < n; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
