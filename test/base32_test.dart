import 'package:base32/base32.dart' as base32;
import 'package:base32/encodings.dart';
import 'package:base_codecs/base_codecs.dart' as base_codecs;
import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

import './utils.dart';

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
          expect(
            () => fromBase32("Error!"),
            throwsA(isA<FormatException>().having(
                (e) => e.message, 'message', 'Invalid character 33 at 5')),
          );
        });
        test('"-10"', () {
          expect(
            () => fromBase32("-10"),
            throwsA(isA<FormatException>().having(
                (e) => e.message, 'message', 'Invalid character 45 at 0')),
          );
        });
        test('"s*mething"', () {
          expect(
            () => fromBase32("s*mething"),
            throwsA(isA<FormatException>().having(
                (e) => e.message, 'message', 'Invalid character 42 at 1')),
          );
        });
        // Digits 0, 1, 8 and 9 are not part of the RFC 4648 base32 alphabet.
        test('"01" (digit 0 = code 48)', () {
          expect(
            () => fromBase32("01"),
            throwsA(isA<FormatException>().having(
                (e) => e.message, 'message', 'Invalid character 48 at 0')),
          );
        });
        test('"89" (digit 8 = code 56)', () {
          expect(
            () => fromBase32("89"),
            throwsA(isA<FormatException>().having(
                (e) => e.message, 'message', 'Invalid character 56 at 0')),
          );
        });
      });
      group('with invalid length', () {
        // All valid alphabet characters, but the number of characters leaves a
        // non-zero partial word, so decoding reaches the length check. Base-32
        // packs 8 characters into 5 bytes; a tail of 1, 3, or 6 characters
        // (in any group) can never form a whole number of bytes.
        test('"B" (1 char)', () {
          expect(
            () => fromBase32("B"),
            throwsA(isA<FormatException>().having((e) => e.message, 'message',
                'Invalid length or non-zero trailing bits')),
          );
        });
        test('"MZX" (3 chars)', () {
          expect(
            () => fromBase32("MZX"),
            throwsA(isA<FormatException>().having((e) => e.message, 'message',
                'Invalid length or non-zero trailing bits')),
          );
        });
        test('"MZXW6Y" (6 chars)', () {
          expect(
            () => fromBase32("MZXW6Y"),
            throwsA(isA<FormatException>().having((e) => e.message, 'message',
                'Invalid length or non-zero trailing bits')),
          );
        });
        test('"MZXW6YTBO" (full group + 1)', () {
          expect(
            () => fromBase32("MZXW6YTBO"),
            throwsA(isA<FormatException>().having((e) => e.message, 'message',
                'Invalid length or non-zero trailing bits')),
          );
        });
        test('"MZXW6YTBOI2" (full group + 3)', () {
          expect(
            () => fromBase32("MZXW6YTBOI2"),
            throwsA(isA<FormatException>().having((e) => e.message, 'message',
                'Invalid length or non-zero trailing bits')),
          );
        });
        test('"MZXW6YTBOI2XX2" (full group + 6)', () {
          expect(
            () => fromBase32("MZXW6YTBOI2XX2"),
            throwsA(isA<FormatException>().having((e) => e.message, 'message',
                'Invalid length or non-zero trailing bits')),
          );
        });
      });
    });

    // RFC 4648 §10 provides these test vectors for the base32hex (extended
    // hex) alphabet. Reached via `Base32Codec.hex`.
    // https://datatracker.ietf.org/doc/html/rfc4648#section-10
    group('base32-hex RFC 4648 §10 vectors', () {
      // Each entry: input ASCII string -> padded base32hex encoding.
      const vectors = <String, String>{
        '': '',
        'f': 'CO======',
        'fo': 'CPNG====',
        'foo': 'CPNMU===',
        'foob': 'CPNMUOG=',
        'fooba': 'CPNMUOJ1',
        'foobar': 'CPNMUOJ1E8======',
      };
      group('encoding (with padding)', () {
        vectors.forEach((input, expected) {
          test('"$input" -> "$expected"', () {
            var a = toBase32(input.codeUnits, codec: Base32Codec.hex);
            expect(a, equals(expected));
          });
        });
      });
      group('encoding (no padding)', () {
        vectors.forEach((input, expected) {
          var unpadded = expected.replaceAll('=', '');
          test('"$input" -> "$unpadded"', () {
            var a = toBase32(
              input.codeUnits,
              codec: Base32Codec.hex,
              padding: false,
            );
            expect(a, equals(unpadded));
          });
        });
      });
      group('decoding (with padding)', () {
        vectors.forEach((input, expected) {
          test('"$expected" -> "$input"', () {
            var a = fromBase32(expected, codec: Base32Codec.hex);
            expect(a, equals(input.codeUnits));
          });
        });
      });
      group('decoding (no padding)', () {
        vectors.forEach((input, expected) {
          var unpadded = expected.replaceAll('=', '');
          test('"$unpadded" -> "$input"', () {
            var a = fromBase32(unpadded, codec: Base32Codec.hex);
            expect(a, equals(input.codeUnits));
          });
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

    // Crockford decoding is case-insensitive and, per the specification,
    // substitutes the ambiguous letters (I/i/L/l -> 1 and O/o -> 0); U/u is not
    // part of the alphabet. The external oracle is `package:base_codecs`'
    // `base32Crockford`, which applies the same rules.
    // https://www.crockford.com/base32.html
    group('crockford decode (spec-compliant, vs base_codecs)', () {
      test('encoding matches base_codecs', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var ours = toBase32(b, codec: Base32Codec.crockford);
          expect(ours, base_codecs.base32CrockfordEncode(b), reason: '$i');
        }
      });
      test('decoding uppercase matches base_codecs', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var s = toBase32(b, codec: Base32Codec.crockford);
          expect(fromBase32(s, codec: Base32Codec.crockford),
              base_codecs.base32CrockfordDecode(s),
              reason: '$i');
        }
      });
      test('decoding lowercase matches base_codecs', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var s = toBase32(b, codec: Base32Codec.crockford).toLowerCase();
          expect(fromBase32(s, codec: Base32Codec.crockford),
              base_codecs.base32CrockfordDecode(s),
              reason: '$i');
        }
      });
      test('ambiguous letters I/i/L/l -> 1 and O/o -> 0', () {
        // "foo" encodes to "CSQPY"; lowercase must decode identically.
        expect(fromBase32('csqpy', codec: Base32Codec.crockford),
            equals('foo'.codeUnits));
        // Every spelling of the ambiguous symbols matches the reference.
        for (final s in ['10', '1O', 'IO', 'io', 'i0', 'L0', 'lo']) {
          expect(fromBase32(s, codec: Base32Codec.crockford),
              base_codecs.base32CrockfordDecode(s),
              reason: s);
        }
      });
      test('U and u are rejected', () {
        expect(() => fromBase32('U0', codec: Base32Codec.crockford),
            throwsFormatException);
        expect(() => fromBase32('u0', codec: Base32Codec.crockford),
            throwsFormatException);
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

    group('decoding with ignoreWhitespace', () {
      test('every ASCII whitespace character is skipped', () {
        // MZXW6YTBOI====== = "foobar" (RFC 4648 test vector), whitespace
        // laced through the characters and the trailing padding.
        var laced = ' MZ\tXW\n6Y TB\r\nOI==\f==\v==';
        expect(
          fromBase32(laced, ignoreWhitespace: true),
          equals('foobar'.codeUnits),
        );
        expect(() => fromBase32(laced), throwsFormatException);
      });
      test('line-wrapped input matches strict decoding of clean input', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b);
          var laced = StringBuffer();
          for (int j = 0; j < r.length; ++j) {
            laced.write(r[j]);
            if (j % 8 == 7) laced.write('\r\n');
          }
          expect(
            fromBase32(laced.toString(), ignoreWhitespace: true),
            equals(fromBase32(r)),
            reason: 'length $i',
          );
        }
      });
      test('empty and whitespace-only input decode to empty output', () {
        expect(fromBase32('', ignoreWhitespace: true), equals([]));
        expect(fromBase32(' \t\r\n', ignoreWhitespace: true), equals([]));
      });
      test('codec overrides: base32hex and crockford', () {
        // CPNMUOJ1E8====== = "foobar" in base32hex (RFC 4648 test vector)
        expect(
          fromBase32('CPNM UOJ1\nE8==\t====', // rearranged whitespace
              codec: Base32Codec.hex,
              ignoreWhitespace: true),
          equals('foobar'.codeUnits),
        );
        var b = [0x1F, 0x2E, 0x3D, 0x4C, 0x5B];
        var crock = toBase32(b, codec: Base32Codec.crockford);
        expect(
          fromBase32('$crock\n',
              codec: Base32Codec.crockford, ignoreWhitespace: true),
          equals(b),
        );
      });
      test('invalid characters still throw, with original position', () {
        expect(
          () => fromBase32('MZXW\n!YTB', ignoreWhitespace: true),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Invalid character 33 at 5')),
        );
      });
      test('non-ASCII whitespace is not skipped', () {
        expect(
          () => fromBase32('MZXW\u00A06YTB', ignoreWhitespace: true),
          throwsFormatException,
        );
      });
      test('invalid length still throws', () {
        expect(
          () => fromBase32('MZXW6YTBO\n', ignoreWhitespace: true),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid length or non-zero trailing bits')),
        );
      });
      test('tryFromBase32 honors the flag', () {
        expect(tryFromBase32('MZXW\n6YTB'), isNull);
        expect(
          tryFromBase32('MZXW\n6YTB', ignoreWhitespace: true),
          equals('foobar'.codeUnits.sublist(0, 5)),
        );
      });
      test('clean input decodes byte-identical to strict decoding', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = toBase32(b);
          expect(
            fromBase32(r, ignoreWhitespace: true),
            equals(fromBase32(r)),
            reason: 'length $i',
          );
        }
      });
    });
  });
}
