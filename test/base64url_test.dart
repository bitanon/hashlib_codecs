import 'dart:convert';

import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

import './utils.dart';

void main() {
  group('Test base64url', () {
    test('encoding', () {
      var b = [0, 0, 0];
      var a = toBase64(b, url: true);
      expect(a, equals("AAAA"));
    });
    test('encoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var m = base64UrlEncode(b).replaceAll('=', '');
        var a = toBase64(b, padding: false, url: true);
        expect(a, equals(m), reason: 'length $i');
      }
    });
    test('decoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64UrlEncode(b).replaceAll('=', '');
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var m = base64UrlEncode(b);
        var a = toBase64(b, url: true);
        expect(a, equals(m), reason: 'length $i');
      }
    });
    test('decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64UrlEncode(b);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding <-> decoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64(b, padding: false, url: true);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding <-> decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64(b, url: true);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    group('RFC 4648 known-answer vectors', () {
      // RFC 4648 Section 10 "foobar" test vectors. The RFC gives no separate
      // table for the URL-safe alphabet because the "foobar" family never
      // produces `+` or `/`, so URL-safe output equals the Base64 output.
      // Input is the ASCII string passed as `input.codeUnits`.
      const vectors = <List<String>>[
        // [input, padded, unpadded]
        ['', '', ''],
        ['f', 'Zg==', 'Zg'],
        ['fo', 'Zm8=', 'Zm8'],
        ['foo', 'Zm9v', 'Zm9v'],
        ['foob', 'Zm9vYg==', 'Zm9vYg'],
        ['fooba', 'Zm9vYmE=', 'Zm9vYmE'],
        ['foobar', 'Zm9vYmFy', 'Zm9vYmFy'],
      ];
      for (var v in vectors) {
        var input = v[0];
        var padded = v[1];
        var unpadded = v[2];
        test('encoding "$input" => "$padded" (padded)', () {
          expect(toBase64(input.codeUnits, url: true), equals(padded));
        });
        test('encoding "$input" => "$unpadded" (no padding)', () {
          expect(toBase64(input.codeUnits, url: true, padding: false),
              equals(unpadded));
        });
        test('decoding "$padded" => "$input" (padded)', () {
          expect(fromBase64(padded), equals(input.codeUnits));
        });
        test('decoding "$unpadded" => "$input" (no padding)', () {
          expect(fromBase64(unpadded), equals(input.codeUnits));
        });
      }
    });
    group('URL-safe distinguishing characters (- and _)', () {
      // The "foobar" family never emits `+` or `/`, so it cannot exercise the
      // URL-safe alphabet's distinguishing characters `-` (index 62) and `_`
      // (index 63). These inputs produce `+`/`/` in standard Base64 and must
      // produce `-`/`_` in URL-safe Base64. The external oracle is
      // `dart:convert`'s `base64Url`.
      const inputs = <List<int>>[
        [0xFF, 0xFF, 0xFF], // standard "////" -> url-safe "____"
        [0xFB, 0xF0], // standard "+/A=" -> url-safe "-_A="
        [0x03, 0xEF, 0xFF], // standard "A+//" -> url-safe "A-__"
      ];
      for (var b in inputs) {
        test('encoding $b matches dart:convert base64Url', () {
          var expected = base64Url.encode(b);
          expect(toBase64(b, url: true), equals(expected));
          // The URL-safe output must contain `-`/`_`, never `+`/`/`.
          expect(toBase64(b, url: true), isNot(contains('+')));
          expect(toBase64(b, url: true), isNot(contains('/')));
        });
        test('decoding url-safe of $b round-trips', () {
          var urlStr = base64Url.encode(b);
          expect(fromBase64(urlStr), equals(b));
        });
      }
    });
  });
}
