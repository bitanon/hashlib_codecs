// Generates the forward (encode) and reverse (decode) alphabet lookup tables
// used by the codecs.
//
// Run with: dart run tool/alphabet_maker.dart

import 'dart:io';

void show(List<String> list, int n) {
  var cc = 0;
  for (var x in list) {
    if (cc % n == 0) {
      stdout.write("\n  ");
    }
    stdout.write("$x, ");
    cc++;
  }
  stdout.write("\n");
}

// Builds a reverse (decode) table mapping a character code to its word value.
//
// Each string in [merge] maps its characters to their positions; later strings
// override earlier ones (used to fold a lowercase alphabet onto the same
// values for a case-insensitive decoder). The optional [alias] map assigns
// extra character-code -> value entries after the merge, for substitutions such
// as Crockford's `I/i/L/l -> 1` and `O/o -> 0`.
void rev(List<String> merge, [Map<String, int> alias = const {}]) {
  var v = <int>[];
  void put(int c, int value) {
    while (c >= v.length) {
      v.addAll(List.filled(19, -1));
    }
    v[c] = value;
  }

  for (var s in merge) {
    var chars = s.codeUnits;
    for (var i = 0; i < chars.length; i++) {
      put(chars[i], i);
    }
  }
  alias.forEach((ch, value) => put(ch.codeUnitAt(0), value));
  show([
    for (var x in v) x < 0 ? "__" : x.toString().padLeft(2, "0"),
  ], 19);
}

void fwd(String s) {
  show([
    for (var x in s.codeUnits) "0x${x.toRadixString(16)}",
  ], 8);
}

void main() {
  // stdout.write("const _base32EncodingHexUpper = <int>[");
  // fwd("0123456789ABCDEFGHIJKLMNOPQRSTUV");
  // stdout.write("];\n");
  // stdout.write("const _base32EncodingHexLower = <int>[");
  // fwd("0123456789abcdefghijklmnopqrstuv");
  // stdout.write("];\n");
  // stdout.write("const _base32DecodingHex = <int>[");
  // rev(["0123456789ABCDEFGHIJKLMNOPQRSTUV", "0123456789abcdefghijklmnopqrstuv"]);
  // stdout.write("];\n");

  // stdout.write("const _base32EncodingCrockford = <int>[");
  // fwd("0123456789ABCDEFGHJKMNPQRSTVWXYZ");
  // stdout.write("];\n");
  // stdout.write("const _base32DecodingCrockford = <int>[");
  // rev(
  //   [
  //     "0123456789ABCDEFGHJKMNPQRSTVWXYZ",
  //     "0123456789abcdefghjkmnpqrstvwxyz",
  //   ],
  //   // Crockford decoders accept lowercase and substitute the ambiguous
  //   // letters: I/i/L/l -> 1 and O/o -> 0. The letter U is not decoded.
  //   {"I": 1, "i": 1, "L": 1, "l": 1, "O": 0, "o": 0},
  // );
  // stdout.write("];\n");

  // stdout.write("const _base32EncodingGeoHash = <int>[");
  // fwd("0123456789bcdefghjkmnpqrstuvwxyz");
  // stdout.write("];\n");
  // stdout.write("const _base32DecodingGeoHash = <int>[");
  // rev(["0123456789bcdefghjkmnpqrstuvwxyz"]);
  // stdout.write("];\n");

  // stdout.write("const _base32EncodingZ = <int>[");
  // fwd("ybndrfg8ejkmcpqxot1uwisza345h769");
  // stdout.write("];\n");
  // stdout.write("const _base32DecodingZ = <int>[");
  // rev(["ybndrfg8ejkmcpqxot1uwisza345h769"]);
  // stdout.write("];\n");

  // stdout.write("const _base32EncodingWordSafe = <int>[");
  // fwd("23456789CFGHJMPQRVWXcfghjmpqrvwx");
  // stdout.write("];\n");
  // stdout.write("const _base32DecodingWordSafe = <int>[");
  // rev(["23456789CFGHJMPQRVWXcfghjmpqrvwx"]);
  // stdout.write("];\n");

  stdout.write("const _base64EncodingBcrypt = <int>[");
  fwd("./ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789");
  stdout.write("];\n");
  stdout.write("const _base64DecodingBcrypt = <int>[");
  rev(["./ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"]);
  stdout.write("];\n");
}
