// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:base32/base32.dart' as base32;
import 'package:base32/encodings.dart';
import 'package:base_codecs/base_codecs.dart' as base_codecs;
import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Test base32', () {
    // source: https://github.com/daegalus/dart-base32
    test('parameter overrides', () {
      var s = 'foobar';
      var r = 'MZXW6YTBOI======';
      var np = 'MZXW6YTBOI';
      var a = toBase32(s.codeUnits);
      expect(a, equals(r));
      a = toBase32(
        s.codeUnits,
        codec: Base32Codec.standard,
        padding: false,
      );
      expect(a, equals(np));
      a = toBase32(
        s.codeUnits,
        codec: Base32Codec.standard,
        lower: true,
      );
      expect(a, equals(r));
      a = toBase32(
        s.codeUnits,
        codec: Base32Codec.standard,
        padding: false,
        lower: true,
      );
      expect(a, equals(np));
    });

    group('encoding <-> decoding', () {
      test('standard', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b);
          expect(r.toUpperCase(), equals(r), reason: 'length $i');
          var a = fromBase32(r);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('lowercase', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, lower: true);
          expect(r.toLowerCase(), equals(r), reason: 'length $i');
          var a = fromBase32(r);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('standard no padding', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, padding: false);
          expect(r.toUpperCase(), equals(r), reason: 'length $i');
          expect(r, isNot(endsWith('=')), reason: 'length $i');
          var a = fromBase32(r);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('hex uppercase', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, codec: Base32Codec.hex);
          var a = fromBase32(r, codec: Base32Codec.hex);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('hex lowercase', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, codec: Base32Codec.hexLower);
          var a = fromBase32(r, codec: Base32Codec.hexLower);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('crockford', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, codec: Base32Codec.crockford);
          expect(r, isNot(endsWith('=')), reason: 'length $i');
          var a = fromBase32(r, codec: Base32Codec.crockford);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('geohash', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, codec: Base32Codec.geohash);
          expect(r.toLowerCase(), equals(r), reason: 'length $i');
          var a = fromBase32(r, codec: Base32Codec.geohash);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('geohash no padding', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, codec: Base32Codec.geohash, padding: false);
          expect(r, isNot(endsWith('=')), reason: 'length $i');
          var a = fromBase32(r, codec: Base32Codec.geohash);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('word-safe', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, codec: Base32Codec.wordSafe);
          var a = fromBase32(r, codec: Base32Codec.wordSafe);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('word-safe no padding', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, codec: Base32Codec.wordSafe, padding: false);
          expect(r, isNot(endsWith('=')), reason: 'length $i');
          var a = fromBase32(r, codec: Base32Codec.wordSafe);
          expect(a, equals(b), reason: 'length $i');
        }
      });
      test('z-base-32', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b, codec: Base32Codec.z);
          expect(r, isNot(endsWith('=')), reason: 'length $i');
          var a = fromBase32(r, codec: Base32Codec.z);
          expect(a, equals(b), reason: 'length $i');
        }
      });
    });

    group('encoding', () {
      group('no padding', () {
        test('"" -> ""', () {
          var s = '';
          var a = toBase32(s.codeUnits, padding: false);
          expect(a, equals(''));
        });
        test('f -> MY', () {
          var s = 'f';
          var a = toBase32(s.codeUnits, padding: false);
          expect(a, equals('MY'));
        });
        test('fo -> MZXQ', () {
          var s = 'fo';
          var a = toBase32(s.codeUnits, padding: false);
          expect(a, equals('MZXQ'));
        });
        test('foo -> MZXW6', () {
          var s = 'foo';
          var a = toBase32(s.codeUnits, padding: false);
          expect(a, equals('MZXW6'));
        });
        test('foob -> MZXW6YQ', () {
          var s = 'foob';
          var a = toBase32(s.codeUnits, padding: false);
          expect(a, equals('MZXW6YQ'));
        });
        test('fooba -> MZXW6YTB', () {
          var s = 'fooba';
          var a = toBase32(s.codeUnits, padding: false);
          expect(a, equals('MZXW6YTB'));
        });
        test('foobar -> MZXW6YTBOI', () {
          var s = 'foobar';
          var a = toBase32(s.codeUnits, padding: false);
          expect(a, equals('MZXW6YTBOI'));
        });
        test('[0, 0, 0] => AAAAA', () {
          var inp = [0, 0, 0];
          var out = "AAAAA";
          var act = toBase32(inp, padding: false);
          expect(act, equals(out));
        });
        test('48656c6c6f21deadbeef -> JBSWY3DPEHPK3PXP', () {
          var encoded = fromHex('48656c6c6f21deadbeef');
          var actual = toBase32(encoded, padding: false);
          expect(actual, equals('JBSWY3DPEHPK3PXP'));
        });
        test('48656c6c6f21deadbe -> JBSWY3DPEHPK3PQ', () {
          var encoded = fromHex('48656c6c6f21deadbe');
          var actual = toBase32(encoded, padding: false);
          expect(actual, equals('JBSWY3DPEHPK3PQ'));
        });
        test('foobar --lower--> mzxw6ytboi', () {
          var text = 'foobar';
          var actual = toBase32(text.codeUnits, padding: false, lower: true);
          expect(actual, equals('mzxw6ytboi'));
        });
        test('48656c6c6f21deadbeef --lower--> jbswy3dpehpk3pxp', () {
          var text = fromHex('48656c6c6f21deadbeef');
          var actual = toBase32(text, padding: false, lower: true);
          expect(actual, equals('jbswy3dpehpk3pxp'));
        });
      });
      group('with padding', () {
        test('f -> MY======', () {
          var s = 'f';
          var r = 'MY======';
          expect(toBase32(s.codeUnits), equals(r));
        });
        test('fo -> MZXQ====', () {
          var s = 'fo';
          var r = 'MZXQ====';
          expect(toBase32(s.codeUnits), equals(r));
        });
        test('foo -> MZXW6===', () {
          var s = 'foo';
          var r = 'MZXW6===';
          expect(toBase32(s.codeUnits), equals(r));
        });
        test('foob -> MZXW6YQ=', () {
          var s = 'foob';
          var r = 'MZXW6YQ=';
          expect(toBase32(s.codeUnits), equals(r));
        });
        test('foobar -> MZXW6YTBOI======', () {
          var s = 'foobar';
          var r = 'MZXW6YTBOI======';
          expect(toBase32(s.codeUnits), equals(r));
        });
        test('48656c6c6f21deadbe -> JBSWY3DPEHPK3PQ=', () {
          var s = String.fromCharCodes(fromHex('48656c6c6f21deadbe'));
          var r = 'JBSWY3DPEHPK3PQ=';
          expect(toBase32(s.codeUnits), equals(r));
        });
        test('[0, 0, 0] => AAAAA===', () {
          var inp = [0, 0, 0];
          var out = "AAAAA===";
          expect(toBase32(inp), equals(out));
        });
      });
    });

    group('decoding', () {
      group('no padding', () {
        test('"" -> ""', () {
          var s = '';
          expect(fromBase32(''), equals(s.codeUnits));
        });
        test('MY -> f', () {
          var s = 'f';
          expect(fromBase32('MY'), equals(s.codeUnits));
        });
        test('MZXQ -> fo', () {
          var s = 'fo';
          expect(fromBase32('MZXQ'), equals(s.codeUnits));
        });
        test('MZXW6 -> foo', () {
          var s = 'foo';
          expect(fromBase32('MZXW6'), equals(s.codeUnits));
        });
        test('MZXW6YQ -> foob', () {
          var s = 'foob';
          expect(fromBase32('MZXW6YQ'), equals(s.codeUnits));
        });
        test('MZXW6YTB -> fooba', () {
          var s = 'fooba';
          expect(fromBase32('MZXW6YTB'), equals(s.codeUnits));
        });
        test('MZXW6YTBOI -> foobar', () {
          var s = 'foobar';
          expect(fromBase32('MZXW6YTBOI'), equals(s.codeUnits));
        });
        test('JBSWY3DPEHPK3PXP -> 48656c6c6f21deadbeef', () {
          var decoded = fromBase32('JBSWY3DPEHPK3PXP');
          expect(toHex(decoded), equals('48656c6c6f21deadbeef'));
        });
        test('JBSWY3DPEHPK3PQ -> 48656c6c6f21deadbe', () {
          var decoded = fromBase32('JBSWY3DPEHPK3PQ');
          expect(toHex(decoded), equals('48656c6c6f21deadbe'));
        });
        test('mzxw6ytboi -> foobar', () {
          var s = 'foobar';
          expect(fromBase32('mzxw6ytboi'), equals(s.codeUnits));
        });
        test('jbswy3dpehpk3pxp -> 48656c6c6f21deadbeef', () {
          var decoded = fromBase32('jbswy3dpehpk3pxp');
          expect(toHex(decoded), equals('48656c6c6f21deadbeef'));
        });
        test('jbswy3dpehpk3pq -> 48656c6c6f21deadbe', () {
          var decoded = fromBase32('jbswy3dpehpk3pq');
          expect(toHex(decoded), equals('48656c6c6f21deadbe'));
        });
      });
      group('with padding', () {
        test('MY====== -> f', () {
          var s = 'MY======';
          var r = 'f';
          expect(fromBase32(s), equals(r.codeUnits));
        });
        test('MZXQ==== -> fo', () {
          var s = 'MZXQ====';
          var r = 'fo';
          expect(fromBase32(s), equals(r.codeUnits));
        });
        test('MZXW6=== -> foo', () {
          var s = 'MZXW6===';
          var r = 'foo';
          expect(fromBase32(s), equals(r.codeUnits));
        });
        test('MZXW6YQ= -> foob', () {
          var s = 'MZXW6YQ=';
          var r = 'foob';
          expect(fromBase32(s), equals(r.codeUnits));
        });
        test('MZXW6YTBOI====== -> foobar', () {
          var s = 'MZXW6YTBOI======';
          var r = 'foobar';
          expect(fromBase32(s), equals(r.codeUnits));
        });
        test('JBSWY3DPEHPK3PQ= -> 48656c6c6f21deadbe', () {
          var s = 'JBSWY3DPEHPK3PQ=';
          var r = String.fromCharCodes(fromHex('48656c6c6f21deadbe'));
          expect(fromBase32(s), equals(r.codeUnits));
        });
        test('AAAA => [0, 0, 0]', () {
          var inp = [0, 0, 0];
          var out = "AAAAA===";
          expect(fromBase32(out), equals(inp));
        });
      });
      group(' with invalid chars', () {
        test('"Error!"', () {
          expect(() => fromBase32("Error!"), throwsFormatException);
        });
        test('"-10"', () {
          expect(() => fromBase32("-10"), throwsFormatException);
        });
        test('"s*mething"', () {
          expect(() => fromBase32("s*mething"), throwsFormatException);
        });
      });
      group('with invalid length', () {
        test('"1"', () {
          expect(() => fromBase32("1"), throwsFormatException);
        });
        test('"12"', () {
          expect(() => fromBase32("12"), throwsFormatException);
        });
        test('"123"', () {
          expect(() => fromBase32("123"), throwsFormatException);
        });
        test('"1234"', () {
          expect(() => fromBase32("1234"), throwsFormatException);
        });
        test('"12345"', () {
          expect(() => fromBase32("12345"), throwsFormatException);
        });
        test('"123456"', () {
          expect(() => fromBase32("123456"), throwsFormatException);
        });
        test('"1234567"', () {
          expect(() => fromBase32("1234567"), throwsFormatException);
        });
        test('"123456789"', () {
          expect(() => fromBase32("123456789"), throwsFormatException);
        });
        test('"1234567890"', () {
          expect(() => fromBase32("1234567890"), throwsFormatException);
        });
        test('"12345678901"', () {
          expect(() => fromBase32("12345678901"), throwsFormatException);
        });
        test('"123456789012"', () {
          expect(() => fromBase32("123456789012"), throwsFormatException);
        });
        test('"1234567890123"', () {
          expect(() => fromBase32("1234567890123"), throwsFormatException);
        });
        test('"12345678901234"', () {
          expect(() => fromBase32("12345678901234"), throwsFormatException);
        });
        test('"123456789012345"', () {
          expect(() => fromBase32("123456789012345"), throwsFormatException);
        });
      });
    });

    group('compare against package: base_codecs', () {
      test('encoding', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var hashlib = toBase32(b);
          var other = base_codecs.base32RfcEncode(b);
          expect(hashlib, other, reason: 'length $i');
        }
      });
      test('decoding (uppercase)', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var h = toBase32(b);
          var hashlib = fromBase32(h);
          var other = base_codecs.base32RfcDecode(h);
          expect(hashlib, other, reason: 'length $i');
        }
      });
      test('decoding (lowercase)', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var h = toBase32(b, lower: true);
          var hashlib = fromBase32(h);
          var other = base_codecs.base32RfcDecode(h);
          expect(hashlib, other, reason: 'length $i');
        }
      });
    });

    group('compare against package: base32', () {
      test('encoding (uppercase)', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var hashlib = toBase32(b);
          var other = base32.base32.encodeString(String.fromCharCodes(b));
          expect(hashlib, other, reason: 'length $i');
        }
      });
      test('encoding (lowercase)', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var hashlib = toBase32(b, lower: true);
          var other = base32.base32.encodeString(String.fromCharCodes(b),
              encoding: Encoding.nonStandardRFC4648Lower);
          expect(hashlib, other, reason: 'length $i');
        }
      });
      test('decoding (uppercase)', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var h = toBase32(b);
          var hashlib = fromBase32(h);
          var other = base32.base32.decode(h);
          expect(hashlib, other, reason: 'length $i');
        }
      });
      test('decoding (lowercase)', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var h = toBase32(b, lower: true);
          var hashlib = fromBase32(h);
          var other = base32.base32.decode(
            h,
            encoding: Encoding.nonStandardRFC4648Lower,
          );
          expect(hashlib, other, reason: 'length $i');
        }
      });
    });
  });
}
