import 'dart:convert' as cvt;

import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

import './utils.dart';

void main() {
  group('Test base64', () {
    test('parameter overrides', () {
      var inp = [0x3, 0xF1];
      var out = "A/E=";
      var npo = "A/E";
      var act = toBase64(inp);
      expect(act, equals(out));
      act = toBase64(
        inp,
        codec: Base64Codec.standard,
      );
      expect(act, equals(out));
      act = toBase64(
        inp,
        codec: Base64Codec.standard,
        padding: false,
      );
      expect(act, equals(npo));
      act = toBase64(
        inp,
        codec: Base64Codec.standard,
        url: true,
      );
      expect(act, equals(out));
      act = toBase64(
        inp,
        codec: Base64Codec.standard,
        padding: false,
        url: true,
      );
      expect(act, equals(npo));
    });
    test('encoding [0, 0, 0, 0] => AAAAAA==', () {
      var inp = [0, 0, 0, 0];
      var out = "AAAAAA==";
      expect(toBase64(inp), equals(out));
    });
    test('decoding AAAAAA== => [0, 0, 0, 0]', () {
      var inp = [0, 0, 0, 0];
      var out = "AAAAAA==";
      expect(fromBase64(out), equals(inp));
    });
    test('encoding no padding [0, 0, 0, 0] => AAAAAA', () {
      var inp = [0, 0, 0, 0];
      var out = "AAAAAA";
      var act = toBase64(inp, padding: false);
      expect(act, equals(out));
    });
    test('decoding no padding AAAAAA => [0, 0, 0, 0]', () {
      var inp = [0, 0, 0, 0];
      var out = "AAAAAA";
      expect(fromBase64(out), equals(inp));
    });
    test('encoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = cvt.base64Encode(b).replaceAll('=', '');
        var a = toBase64(b, padding: false);
        expect(a, r, reason: 'length $i');
      }
    });
    test('decoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = cvt.base64Encode(b).replaceAll('=', '');
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = cvt.base64Encode(b);
        expect(toBase64(b), r, reason: 'length $i');
      }
    });
    test('decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = cvt.base64Encode(b);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding <-> decoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64(b, padding: false);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding <-> decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64(b);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('[bcrypt] encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64(b, codec: Base64Codec.bcrypt);
        var a = fromBase64(r, codec: Base64Codec.bcrypt);
        expect(a, equals(b), reason: 'length $i');
      }
    });
    group('cross-alphabet decode leniency', () {
      // The standard and URL-safe codecs share one RFC-4648 decode table that
      // maps both `+`/`/` and `-`/`_`, so either alphabet decodes with either
      // codec. Expected bytes come from `dart:convert` (external oracle), not
      // from re-encoding with our own codec.
      test('standard codec decodes URL-safe (- and _) input', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var urlStr = cvt.base64Url.encode(b);
          expect(fromBase64(urlStr), equals(b), reason: 'length $i');
        }
      });
      test('URL-safe codec decodes standard (+ and /) input', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var stdStr = cvt.base64.encode(b);
          expect(fromBase64(stdStr, codec: Base64Codec.urlSafe), equals(b),
              reason: 'length $i');
        }
      });
      test('standard codec decodes "____" (URL-safe alphabet)', () {
        // [0xFF, 0xFF, 0xFF] encodes to "////" (standard) / "____" (url-safe).
        expect(fromBase64('____'), equals([0xFF, 0xFF, 0xFF]));
      });
      test('URL-safe codec decodes "////" (standard alphabet)', () {
        expect(fromBase64('////', codec: Base64Codec.urlSafe),
            equals([0xFF, 0xFF, 0xFF]));
      });
    });
    group('decoding with invalid chars', () {
      test('Hashlib!', () {
        expect(
          () => fromBase64("Hashlib!"),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Invalid character 33 at 7')),
        );
      });
      test('a.10', () {
        expect(
          () => fromBase64("a.10"),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Invalid character 46 at 1')),
        );
      });
      test('s*methings', () {
        expect(
          () => fromBase64("s*methings"),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Invalid character 42 at 1')),
        );
      });
    });
    test("decoding with PHC string format B64 (16 bytes)", () {
      var inp = "gZiV/M1gPc22ElAH/Jh1Hw";
      var out = fromBase64(inp, padding: false);
      var res = toBase64(out, padding: false);
      expect(res, inp);
      // String "CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno"
    });
    test("decoding with PHC string format B64 (32 bytes)", () {
      var inp = "CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno";
      var out = fromBase64(inp, padding: false);
      var res = toBase64(out, padding: false);
      expect(res, inp);
    });
    group('RFC 4648 known-answer vectors', () {
      // RFC 4648 Section 10 "foobar" test vectors for Base64 (standard
      // alphabet). Input is the ASCII string passed as `input.codeUnits`.
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
          expect(toBase64(input.codeUnits), equals(padded));
        });
        test('encoding "$input" => "$unpadded" (no padding)', () {
          expect(toBase64(input.codeUnits, padding: false), equals(unpadded));
        });
        test('decoding "$padded" => "$input" (padded)', () {
          expect(fromBase64(padded), equals(input.codeUnits));
        });
        test('decoding "$unpadded" => "$input" (no padding)', () {
          expect(fromBase64(unpadded), equals(input.codeUnits));
        });
      }
    });
    group('decoding with invalid length', () {
      test('H', () {
        expect(
          () => fromBase64("H"),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid length or non-zero trailing bits')),
        );
      });
      test('Ha', () {
        expect(
          () => fromBase64("Ha"),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid length or non-zero trailing bits')),
        );
      });
      test('HaB', () {
        expect(
          () => fromBase64("HaB"),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid length or non-zero trailing bits')),
        );
      });
      test('Hashl', () {
        expect(
          () => fromBase64("Hashl"),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid length or non-zero trailing bits')),
        );
      });
      test('Hashli', () {
        expect(
          () => fromBase64("Hashli"),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid length or non-zero trailing bits')),
        );
      });
      test('Hashlib', () {
        expect(
          () => fromBase64("Hashlib"),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid length or non-zero trailing bits')),
        );
      });
    });
  });
}
