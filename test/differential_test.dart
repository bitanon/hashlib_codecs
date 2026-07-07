// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

// Differential tests: every property here checks convertlib against an
// expected value produced OUTSIDE this package — `dart:convert`, the
// `base_codecs` and `base32` packages, integer arithmetic, or an alphabet
// string from the governing spec (RFC-4648, RFC-3629, or the Wikipedia
// Base32/Base64 articles). Round-trip checks alone cannot catch a codec that
// is consistently wrong (e.g. a miscopied alphabet table); these can.

import 'dart:convert' as cvt;
import 'dart:math';
import 'dart:typed_data';

import 'package:base32/base32.dart' as b32pkg;
import 'package:base_codecs/base_codecs.dart' as bc;
import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

// Fixed seed keeps failures reproducible; bump [rounds] for deeper sweeps.
const int seed = 1;
const int rounds = 500;

final rng = Random(seed);

Uint8List rndBytes(int n) =>
    Uint8List.fromList(List.generate(n, (_) => rng.nextInt(256)));

/// Random valid code points across the full range, surrogates excluded.
List<int> rndCodePoints(int n) => List.generate(n, (_) {
      for (;;) {
        var c = rng.nextInt(0x110000);
        if (c < 0xD800 || c > 0xDFFF) return c;
      }
    });

String hexRef(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('differential (seed=$seed)', () {
    test('hex vs toRadixString', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        var expected = hexRef(b);
        expect(toHex(b), expected, reason: 'round=$i input=$b');
        expect(fromHex(expected), b, reason: 'round=$i');
      }
    });

    test('base64 vs dart:convert', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        expect(toBase64(b), cvt.base64.encode(b), reason: 'round=$i input=$b');
        expect(toBase64(b, url: true), cvt.base64Url.encode(b),
            reason: 'round=$i input=$b');
        expect(fromBase64(cvt.base64.encode(b)), b, reason: 'round=$i');
      }
    });

    test('base32 vs base_codecs and package:base32', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        expect(toBase32(b), bc.base32RfcEncode(b), reason: 'round=$i input=$b');
        expect(toBase32(b), b32pkg.base32.encode(Uint8List.fromList(b)),
            reason: 'round=$i input=$b');
        expect(fromBase32(bc.base32RfcEncode(b)), b, reason: 'round=$i');
      }
    });

    test('base32hex vs base_codecs', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        expect(toBase32(b, codec: Base32Codec.hex), bc.base32RfcHexEncode(b),
            reason: 'round=$i input=$b');
      }
    });

    test('crockford vs base_codecs', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        expect(toBase32(b, codec: Base32Codec.crockford),
            bc.base32CrockfordEncode(b),
            reason: 'round=$i input=$b');
      }
    });

    test('utf8 vs dart:convert over the full code-point range', () {
      for (int i = 0; i < rounds; ++i) {
        var s = String.fromCharCodes(rndCodePoints(rng.nextInt(33)));
        var ref = cvt.utf8.encode(s);
        expect(toUtf8(s), ref, reason: 'round=$i cps=${s.runes}');
        expect(fromUtf8(ref), s, reason: 'round=$i cps=${s.runes}');
      }
    });

    test('utf8 decoder agrees with dart:convert on random bytes', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(17));
        String? ref;
        try {
          ref = cvt.utf8.decode(b); // allowMalformed: false
        } on FormatException {
          ref = null;
        }
        if (ref != null) {
          expect(fromUtf8(b), ref, reason: 'round=$i input=$b');
        } else {
          expect(() => fromUtf8(b), throwsFormatException,
              reason: 'round=$i input=$b');
        }
      }
    });

    test('bigint vs BigInt.parse on hex', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(1 + rng.nextInt(64));
        var expected = BigInt.parse(hexRef(b), radix: 16);
        expect(toBigInt(b, msbFirst: true), expected,
            reason: 'round=$i input=$b');
        expect(toBigInt(b.reversed.toList()), expected,
            reason: 'round=$i input=$b');
      }
    });
  });

  group('alphabet strings match the governing spec', () {
    // Encoding each word value once yields the alphabet in order. Expected
    // strings: RFC-4648 for standard/hex variants; Wikipedia "Base32" for
    // crockford, geohash, z-base-32, word-safe; RFC-4648 and the OpenBSD
    // bcrypt alphabet for Base64. Keep these in sync with README.md.
    String alpha32(Base32Codec c) => String.fromCharCodes(
        List.generate(32, (v) => c.encoder.convert([v << 3])[0]));
    String alpha64(Base64Codec c) => String.fromCharCodes(
        List.generate(64, (v) => c.encoder.convert([v << 2])[0]));

    test('base32 standard', () {
      expect(alpha32(Base32Codec.standard), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567');
    });
    test('base32 lowercase', () {
      expect(
          alpha32(Base32Codec.lowercase), 'abcdefghijklmnopqrstuvwxyz234567');
    });
    test('base32 hex', () {
      expect(alpha32(Base32Codec.hex), '0123456789ABCDEFGHIJKLMNOPQRSTUV');
    });
    test('base32 hexLower', () {
      expect(alpha32(Base32Codec.hexLower), '0123456789abcdefghijklmnopqrstuv');
    });
    test('base32 crockford', () {
      expect(
          alpha32(Base32Codec.crockford), '0123456789ABCDEFGHJKMNPQRSTVWXYZ');
    });
    test('base32 geohash', () {
      expect(alpha32(Base32Codec.geohash), '0123456789bcdefghjkmnpqrstuvwxyz');
    });
    test('base32 z-base-32', () {
      expect(alpha32(Base32Codec.z), 'ybndrfg8ejkmcpqxot1uwisza345h769');
    });
    test('base32 word-safe', () {
      expect(alpha32(Base32Codec.wordSafe), '23456789CFGHJMPQRVWXcfghjmpqrvwx');
    });
    test('base64 standard', () {
      expect(
          alpha64(Base64Codec.standard),
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
          'abcdefghijklmnopqrstuvwxyz0123456789+/');
    });
    test('base64 urlSafe', () {
      expect(
          alpha64(Base64Codec.urlSafe),
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
          'abcdefghijklmnopqrstuvwxyz0123456789-_');
    });
    test('base64 bcrypt', () {
      expect(
          alpha64(Base64Codec.bcrypt),
          './ABCDEFGHIJKLMNOPQRSTUVWXYZ'
          'abcdefghijklmnopqrstuvwxyz0123456789');
    });
  });

  group('word-safe base32 known answers', () {
    // Regression: the word-safe tables used to be a copy of z-base-32.
    // Vectors generated by mapping RFC-4648 base32 output through the
    // word-safe alphabet from Wikipedia "Base32" (word-safe[i] = value i).
    test('empty', () {
      expect(toBase32([], codec: Base32Codec.wordSafe), '');
    });
    test('single zero byte', () {
      // 0x00 -> values [0, 0] -> "22", padded to 8 chars
      expect(toBase32([0], codec: Base32Codec.wordSafe), '22======');
      expect(fromBase32('22======', codec: Base32Codec.wordSafe), [0]);
    });
    test('0xFF', () {
      // 0xFF -> values [31, 28] -> "xr", padded to 8 chars
      expect(toBase32([0xFF], codec: Base32Codec.wordSafe), 'xr======');
      expect(fromBase32('xr======', codec: Base32Codec.wordSafe), [0xFF]);
    });
  });
}
