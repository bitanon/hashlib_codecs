import 'package:base_codecs/base_codecs.dart' as base_codecs;
import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

import './utils.dart';

void main() {
  group('Test base16', () {
    test('parameter overrides', () {
      var a = toHex([12]);
      expect(a, "0c");
      a = toHex(
        [12],
        codec: Base16Codec.upper,
      );
      expect(a, "0C");
      a = toHex(
        [12],
        codec: Base16Codec.lower,
        upper: true,
      );
      expect(a, "0c");
    });

    test('encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toHex(b);
        expect(fromHex(r), equals(b), reason: 'length $i');
      }
    });

    test('encoding <-> decoding uppercase', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toHex(b, upper: true);
        expect(fromHex(r), equals(b), reason: 'length $i');
      }
    });

    group("encoding", () {
      test('[] => empty string', () {
        expect(toHex([]), "");
      });
      test('[5] => 05', () {
        expect(toHex([5]), "05");
      });
      test('[12] => 0c', () {
        expect(toHex([12]), "0c");
      });
      test('[16] => 10', () {
        expect(toHex([16]), "10");
      });
      test('[0,0,0] => 000000 ', () {
        var inp = [0, 0, 0];
        var out = "000000";
        expect(toHex(inp), equals(out));
      });
      test('random', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var hex = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
          expect(toHex(b), hex, reason: 'length $i');
        }
      });
      group('buffer', () {
        var buf = [
          244, 11, 21, 63, 222, 56, 63, 111, 57, 64, 22, 56, 32, //
          55, 115, 178, 138, 230, 251
        ];
        var lowerHex = "f40b153fde383f6f39401638203773b28ae6fb";
        var upperHex = "F40B153FDE383F6F39401638203773B28AE6FB";
        test("lower", () {
          expect(toHex(buf), lowerHex);
        });
        test("upper", () {
          expect(toHex(buf, upper: true), upperHex);
        });
      });
    });

    group("decoding", () {
      test('empty string => []', () {
        expect(fromHex(""), <int>[]);
      });
      test('5 => [5]', () {
        expect(fromHex("5"), [5]);
      });
      test('c => [12]', () {
        expect(fromHex("c"), [12]);
      });
      test('0c => [12]', () {
        expect(fromHex("0c"), [12]);
      });
      test('00c => [0, 12]', () {
        expect(fromHex("00c"), [0, 12]);
      });
      test('000c => [0, 12]', () {
        expect(fromHex("000c"), [0, 12]);
      });
      test('0000c => [0, 0, 12]', () {
        expect(fromHex("0000c"), [0, 0, 12]);
      });
      test('000000 => [0,0,0]', () {
        var inp = [0, 0, 0];
        var out = "000000";
        expect(fromHex(out), equals(inp));
      });
      test('random', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var hex = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
          expect(fromHex(hex), equals(b), reason: 'length $i');
        }
      });

      group('buffer', () {
        var buf = [
          244, 11, 21, 63, 222, 56, 63, 111, 57, 64, 22, 56, 32, //
          55, 115, 178, 138, 230, 251
        ];
        var lowerHex = "f40b153fde383f6f39401638203773b28ae6fb";
        var upperHex = "F40B153FDE383F6F39401638203773B28AE6FB";
        test("lower", () {
          expect(fromHex(lowerHex), equals(buf));
        });
        test("upper", () {
          expect(fromHex(upperHex), equals(buf));
        });
      });
      group('with invalid chars', () {
        test('Error', () {
          expect(
            () => fromHex("Error"),
            throwsA(isA<FormatException>()
                .having((e) => e.message, 'message', 'Invalid character at 4')),
          );
        });
        test('-10', () {
          expect(
            () => fromHex("-10"),
            throwsA(isA<FormatException>()
                .having((e) => e.message, 'message', 'Invalid character at 0')),
          );
        });
        test('something', () {
          expect(
            () => fromHex("something"),
            throwsA(isA<FormatException>()
                .having((e) => e.message, 'message', 'Invalid character at 8')),
          );
        });
      });
    });

    group('RFC 4648 known-answer vectors', () {
      // RFC 4648 Section 10 "foobar" test vectors. The RFC shows Base16 in
      // UPPERCASE; our `toHex` defaults to lowercase, `upper: true` gives
      // uppercase. Input is the ASCII string passed as `input.codeUnits`.
      const vectors = <List<String>>[
        // [input, lower, upper]
        ['', '', ''],
        ['f', '66', '66'],
        ['fo', '666f', '666F'],
        ['foo', '666f6f', '666F6F'],
        ['foob', '666f6f62', '666F6F62'],
        ['fooba', '666f6f6261', '666F6F6261'],
        ['foobar', '666f6f626172', '666F6F626172'],
      ];
      for (var v in vectors) {
        var input = v[0];
        var lower = v[1];
        var upper = v[2];
        test('encoding "$input" => "$lower" (lower)', () {
          expect(toHex(input.codeUnits), equals(lower));
        });
        test('encoding "$input" => "$upper" (upper)', () {
          expect(toHex(input.codeUnits, upper: true), equals(upper));
        });
        test('decoding "$lower" => "$input" (lower)', () {
          expect(fromHex(lower), equals(input.codeUnits));
        });
        test('decoding "$upper" => "$input" (upper)', () {
          expect(fromHex(upper), equals(input.codeUnits));
        });
      }
    });

    group('compare against package: base_codecs', () {
      test('encoding', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var hashlib = toHex(b, upper: true);
          var base = base_codecs.base16.encode(b);
          expect(base, hashlib, reason: 'length $i');
        }
      });
      test('decoding (lowercase)', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var h = toHex(b);
          var hashlib = fromHex(h);
          var base = base_codecs.base16.decode(h);
          expect(base, hashlib, reason: 'length $i');
        }
      });
      test('decoding (uppercase)', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var h = toHex(b, upper: true);
          var hashlib = fromHex(h);
          var base = base_codecs.base16.decode(h);
          expect(base, hashlib, reason: 'length $i');
        }
      });
    });

    group('decoding with ignoreWhitespace', () {
      test('space-grouped byte pairs', () {
        // 48656c6c6f = "Hello" (ASCII)
        expect(
          fromHex('48 65 6c 6c 6f', ignoreWhitespace: true),
          equals('Hello'.codeUnits),
        );
        expect(() => fromHex('48 65 6c 6c 6f'), throwsFormatException);
      });
      test('every ASCII whitespace character is skipped', () {
        expect(
          fromHex('\t48\n65\v6C\f6c\r6F ', ignoreWhitespace: true),
          equals('Hello'.codeUnits),
        );
      });
      test('odd length input with whitespace', () {
        expect(fromHex('F 0F', ignoreWhitespace: true), equals([0xF, 0x0F]));
      });
      test('empty and whitespace-only input decode to empty output', () {
        expect(fromHex('', ignoreWhitespace: true), equals([]));
        expect(fromHex(' \t\r\n', ignoreWhitespace: true), equals([]));
      });
      test('codec override', () {
        expect(
          fromHex('48 65', codec: Base16Codec.upper, ignoreWhitespace: true),
          equals([0x48, 0x65]),
        );
      });
      test('invalid characters still throw', () {
        expect(
          () => fromHex('48 6g', ignoreWhitespace: true),
          throwsFormatException,
        );
      });
      test('non-ASCII whitespace is not skipped', () {
        expect(
          () => fromHex('48\u00A065', ignoreWhitespace: true),
          throwsFormatException,
        );
      });
      test('tryFromHex honors the flag', () {
        expect(tryFromHex('48 65'), isNull);
        expect(
          tryFromHex('48 65', ignoreWhitespace: true),
          equals([0x48, 0x65]),
        );
      });
      test('clean input decodes byte-identical to strict decoding', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var h = toHex(b);
          expect(
            fromHex(h, ignoreWhitespace: true),
            equals(fromHex(h)),
            reason: 'length $i',
          );
        }
      });
      test('hex-dump style input matches base_codecs of clean input', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var h = toHex(b, upper: true);
          var laced = StringBuffer();
          for (int j = 0; j < h.length; ++j) {
            laced.write(h[j]);
            if (j % 2 == 1) laced.write(j % 32 == 31 ? '\n' : ' ');
          }
          expect(
            fromHex(laced.toString(), ignoreWhitespace: true),
            equals(base_codecs.base16.decode(h)),
            reason: 'length $i',
          );
        }
      });
    });
  });
}
