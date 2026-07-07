// Generates the forward (encode) and reverse (decode) alphabet lookup tables
// used by the codecs. Dart port of tool/alphabet_maker.py.
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

void rev(List<String> merge) {
  var v = <int>[];
  for (var s in merge) {
    var chars = s.codeUnits;
    for (var i = 0; i < chars.length; i++) {
      var c = chars[i];
      while (c >= v.length) {
        v.addAll(List.filled(19, -1));
      }
      v[c] = i;
    }
  }
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
  // rev(["0123456789ABCDEFGHJKMNPQRSTVWXYZ"]);
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
