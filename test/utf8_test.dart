import 'dart:convert';

import 'package:convertlib/src/codecs/utf8.dart';
import 'package:convertlib/src/utf8.dart';
import 'package:test/test.dart';

import './utils.dart';

void main() {
  group('utf8 test', () {
    test('ππππππππ', () {
      var test = r"ππππππππ";
      var actual = Utf8Encoder().convert(test);
      var mine = toUtf8(test);
      expect(mine, equals(actual));
      var decoded = fromUtf8(mine);
      expect(decoded, equals(test));
    });

    test('encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomCodePoints(i);
        var test = String.fromCharCodes(b);
        var actual = Utf8Encoder().convert(test);
        var mine = toUtf8(test);
        expect(mine, equals(actual), reason: 'Encoding: #$i');
        var decoded = fromUtf8(mine);
        expect(decoded, equals(test), reason: 'Decoding: #$i');
      }
    });

    test('2-byte sequences where continuation payload bits are zero', () {
      // Regression for a missing `& 0x3F` in the 2-byte decoder path:
      // C4 80 must decode to U+0100, not U+0180. Expected values verified
      // against RFC-3629 and `dart:convert`.
      expect(fromUtf8([0xC4, 0x80]), String.fromCharCodes([0x100]));
      expect(toUtf8(String.fromCharCodes([0x100])), [0xC4, 0x80]);
      // Cover both sides of every flag-bit boundary in the 2-byte range.
      for (var cp in [0x80, 0xA9, 0xFF, 0x100, 0x141, 0x180, 0x7C0, 0x7FF]) {
        var s = String.fromCharCodes([cp]);
        var enc = Utf8Encoder().convert(s);
        expect(toUtf8(s), equals(enc), reason: 'U+${cp.toRadixString(16)}');
        expect(fromUtf8(enc), equals(s), reason: 'U+${cp.toRadixString(16)}');
      }
    });

    test('ASCII characters', () {
      var test = "Hello, World!";
      var actual = Utf8Encoder().convert(test);
      var mine = toUtf8(test);
      expect(mine, equals(actual));
      var decoded = fromUtf8(mine);
      expect(decoded, equals(test));
    });

    test('2-byte UTF-8 characters', () {
      var test = "éüçñ";
      var actual = Utf8Encoder().convert(test);
      var mine = toUtf8(test);
      expect(mine, equals(actual));
      var decoded = fromUtf8(mine);
      expect(decoded, equals(test));
    });

    test('3-byte UTF-8 characters', () {
      var test = "हिन्दी中文";
      var actual = Utf8Encoder().convert(test);
      var mine = toUtf8(test);
      expect(mine, equals(actual));
      var decoded = fromUtf8(mine);
      expect(decoded, equals(test));
    });

    test('4-byte UTF-8 characters (emoji)', () {
      var test = "😀💡🦄";
      var actual = Utf8Encoder().convert(test);
      var mine = toUtf8(test);
      expect(mine, equals(actual));
      var decoded = fromUtf8(mine);
      expect(decoded, equals(test));
    });

    test('Maximum valid code point (0x10FFFF) encodes/decodes correctly', () {
      var test = String.fromCharCodes([0x10FFFF]);
      var actual = Utf8Encoder().convert(test);
      var mine = toUtf8(test);
      expect(mine, equals(actual));
      var decoded = fromUtf8(mine);
      expect(decoded, equals(test));
    });

    test('Boundary values for each UTF-8 range', () {
      var codePoints = [0x7F, 0x80, 0x7FF, 0x800, 0xFFFF, 0x10000, 0x10FFFF];
      for (var cp in codePoints) {
        var test = String.fromCharCodes([cp]);
        var actual = Utf8Encoder().convert(test);
        var mine = toUtf8(test);
        expect(mine, equals(actual), reason: 'Encoding: $cp');
        var decoded = fromUtf8(mine);
        expect(decoded, equals(test), reason: 'Decoding: $cp');
      }
    });

    test('Empty string', () {
      var test = "";
      var actual = Utf8Encoder().convert(test);
      var mine = toUtf8(test);
      expect(mine, equals(actual));
      var decoded = fromUtf8(mine);
      expect(decoded, equals(test));
    });

    test('Surrogate pairs are encoded/decoded correctly', () {
      // Dart uses UTF-16, so surrogate pairs for emoji
      var test = String.fromCharCodes([0xD83D, 0xDE00]); // 😀
      var actual = Utf8Encoder().convert(test);
      var mine = toUtf8(test);
      expect(mine, equals(actual));
      var decoded = fromUtf8(mine);
      expect(decoded, equals(test));
    });

    group("Encoder", () {
      final encoder = UTF8Codec.standard.encoder;

      test('encoder source', () {
        expect(encoder.source, 32);
      });

      test('encoder target', () {
        expect(encoder.target, 8);
      });

      test('Negative code unit throws FormatException', () {
        expect(() => encoder.convert([-1]), throwsFormatException);
      });

      test('with unpaired low surrogate', () {
        expect(() => encoder.convert([0xDC00]), throwsFormatException);
      });

      test('with unpaired high surrogate', () {
        expect(() => encoder.convert([0xD801]), throwsFormatException);
      });

      test('with invalid surrogate pair with low value', () {
        expect(() => encoder.convert([0xD805, 0xDB00]), throwsFormatException);
      });

      test('with invalid surrogate pair with high value', () {
        expect(() => encoder.convert([0xD805, 0xEFFF]), throwsFormatException);
      });

      test('with value exceeding range', () {
        expect(() => encoder.convert([0x110000]), throwsFormatException);
      });

      test('with empty input for decoder returns empty list', () {
        expect(encoder.convert([]), isEmpty);
      });
    });

    group('Decoder', () {
      final decoder = UTF8Codec.standard.decoder;

      test('source', () {
        expect(decoder.source, 8);
      });

      test('target', () {
        expect(decoder.target, 32);
      });

      test('convert decodes pure ASCII to code points', () {
        // Exercises the ASCII branch and the `n == len` fast return.
        expect(decoder.convert('AB'.codeUnits), equals([0x41, 0x42]));
      });

      test('convert decodes mixed multi-byte sequences to code points', () {
        // "A" (1) + "é" (2) + "中" (3) + "😀" (4); the output is shorter than
        // the input, exercising the `sublist(0, n)` return.
        expect(decoder.convert(toUtf8('Aé中😀')),
            equals([0x41, 0xE9, 0x4E2D, 0x1F600]));
      });

      test(
          'convert with insufficient input after the first 4-byte '
          'continuation', () {
        expect(() => decoder.convert([0xF0, 0x90]), throwsFormatException);
      });

      test('with insufficient input for 2-byte sequence', () {
        expect(() => decoder.convert([0xC2]), throwsFormatException);
      });

      test('with invalid continuation byte at 1 for 2-byte sequence', () {
        expect(() => decoder.convert([0xC2, 0xC2]), throwsFormatException);
      });

      test('with insufficient input for 3-byte sequence', () {
        expect(() => decoder.convert([0xE1, 0x80]), throwsFormatException);
      });

      test('with invalid continuation byte at 1 for 3-byte sequence', () {
        expect(
            () => decoder.convert([0xE1, 0x41, 0x80]), throwsFormatException);
      });

      test('with invalid continuation byte at 2 for 3-byte sequence', () {
        expect(
            () => decoder.convert([0xE1, 0x80, 0x41]), throwsFormatException);
      });

      test('with overlong 3-byte sequence', () {
        expect(
            () => decoder.convert([0xE0, 0x80, 0xAF]), throwsFormatException);
      });

      test('with invalid surrogate for 3-byte', () {
        expect(
            () => decoder.convert([0xED, 0xA1, 0x80]), throwsFormatException);
      });

      test('with insufficient input for 4-byte sequence', () {
        expect(
            () => decoder.convert([0xF0, 0x90, 0x80]), throwsFormatException);
      });

      test('with invalid 4-byte lead', () {
        expect(() => decoder.convert([0xF5, 0x80, 0x80, 0x80]),
            throwsFormatException);
      });

      test('with overlong 4-byte sequence', () {
        expect(() => decoder.convert([0xF0, 0x8F, 0x80, 0x80]),
            throwsFormatException);
      });

      test('with invalid continuation byte at 1 for 4-byte sequence', () {
        expect(() => decoder.convert([0xF0, 0x41, 0x80, 0x80]),
            throwsFormatException);
      });

      test('with invalid continuation byte at 2 for 4-byte sequence', () {
        expect(() => decoder.convert([0xF0, 0x90, 0x41, 0x80]),
            throwsFormatException);
      });

      test('with invalid continuation byte at 3 for 4-byte sequence', () {
        expect(() => decoder.convert([0xF0, 0x90, 0x80, 0x41]),
            throwsFormatException);
      });

      test('with value above U+10FFFF', () {
        expect(() => decoder.convert([0xF4, 0x90, 0x80, 0x80]),
            throwsFormatException);
      });

      test('with invalid UTF-8 sequence throws FormatException', () {
        // Invalid continuation byte (should start with 10xxxxxx)
        var invalid = [0xC2, 0x41];
        expect(() => decoder.convert(invalid), throwsFormatException);
      });

      test('with overlong encoding is rejected', () {
        // Overlong encoding for ASCII 'A' (should be 0x41, not 0xC1 0x81)
        var overlong = [0xC1, 0x81];
        expect(() => decoder.convert(overlong), throwsFormatException);
      });

      test('with code points above Unicode range are rejected', () {
        // 0x11FFFF is above valid Unicode range
        var invalid = [0xF4, 0x90, 0x80, 0x80];
        expect(() => decoder.convert(invalid), throwsFormatException);
      });

      test('with 5 or more bytes', () {
        expect(() => decoder.convert([0xF8]), throwsFormatException);
      });
    });

    group('decodeToString', () {
      // Mirrors the Decoder malformed-input tests through `fromUtf8`, which
      // uses `decodeToString` instead of `convert`. Each bad sequence is
      // placed both in the bulk region (surrounded by ASCII, so a full
      // 4-byte read is in range) and at the very end (the checked tail).
      const ascii = [0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48];
      final badSequences = {
        'truncated 2-byte sequence': [0xC2],
        'invalid continuation byte for 2-byte sequence': [0xC2, 0xC2],
        'overlong 2-byte sequence': [0xC1, 0x81],
        'lone continuation byte': [0x80],
        'truncated 3-byte sequence': [0xE1, 0x80],
        'invalid continuation byte at 1 for 3-byte sequence': [
          0xE1, 0x41, 0x80, //
        ],
        'invalid continuation byte at 2 for 3-byte sequence': [
          0xE1, 0x80, 0x41, //
        ],
        'overlong 3-byte sequence': [0xE0, 0x80, 0xAF],
        'surrogate in 3-byte sequence': [0xED, 0xA1, 0x80],
        'truncated 4-byte sequence': [0xF0, 0x90, 0x80],
        'invalid 4-byte lead': [0xF5, 0x80, 0x80, 0x80],
        'overlong 4-byte sequence': [0xF0, 0x8F, 0x80, 0x80],
        'invalid continuation byte at 1 for 4-byte sequence': [
          0xF0, 0x41, 0x80, 0x80, //
        ],
        'invalid continuation byte at 2 for 4-byte sequence': [
          0xF0, 0x90, 0x41, 0x80, //
        ],
        'invalid continuation byte at 3 for 4-byte sequence': [
          0xF0, 0x90, 0x80, 0x41, //
        ],
        'above U+10FFFF': [0xF4, 0x90, 0x80, 0x80],
        '5 or more byte lead': [0xF8],
      };
      badSequences.forEach((name, seq) {
        test('$name in bulk region', () {
          var input = [...ascii, ...seq, ...ascii];
          expect(() => fromUtf8(input), throwsFormatException);
        });
        test('$name at the tail', () {
          var input = [...ascii, ...seq];
          expect(() => fromUtf8(input), throwsFormatException);
        });
      });

      test('multi-byte sequences crossing the bulk/tail boundary', () {
        for (int pad = 0; pad < 8; pad++) {
          var text = '${'a' * pad}😀é中';
          expect(fromUtf8(toUtf8(text)), equals(text), reason: 'pad: $pad');
        }
      });

      test('long input beyond the scratch buffer', () {
        var codes = List<int>.generate(
          10000,
          (i) => [0x41 + (i % 26), 0xE9, 0x4E00, 0x1F600][i & 3],
        );
        var text = String.fromCharCodes(codes);
        expect(fromUtf8(toUtf8(text)), equals(text));
        expect(toUtf8(text), equals(Utf8Encoder().convert(text)));
      });

      test('long pure-ASCII input', () {
        var text = 'z' * 10000;
        expect(fromUtf8(toUtf8(text)), equals(text));
      });

      test('codec decodeToString decodes to a String', () {
        // Exercises the `UTF8Codec.decodeToString` convenience method.
        var text = 'Aé中😀';
        expect(UTF8Codec.standard.decodeToString(toUtf8(text)), equals(text));
      });
    });

    group('encodeString', () {
      // Mirrors the Encoder surrogate tests through `toUtf8`, which uses
      // `encodeString` instead of `convert`.
      test('unpaired low surrogate throws', () {
        var text = String.fromCharCodes([0x41, 0xDC00, 0x42]);
        expect(() => toUtf8(text), throwsFormatException);
      });

      test('unpaired high surrogate in the middle throws', () {
        var text = String.fromCharCodes([0x41, 0xD801, 0x42]);
        expect(() => toUtf8(text), throwsFormatException);
      });

      test('unpaired high surrogate at the end throws', () {
        var text = String.fromCharCodes([0x41, 0xD801]);
        expect(() => toUtf8(text), throwsFormatException);
      });

      test('invalid surrogate pair with low value throws', () {
        var text = String.fromCharCodes([0xD805, 0xDB00]);
        expect(() => toUtf8(text), throwsFormatException);
      });

      test('invalid surrogate pair with high value throws', () {
        var text = String.fromCharCodes([0xD805, 0xEFFF]);
        expect(() => toUtf8(text), throwsFormatException);
      });

      test('codec encodeString matches encoder convert', () {
        for (int i = 0; i < 100; ++i) {
          var text = String.fromCharCodes(randomCodePoints(i));
          expect(UTF8Codec.standard.encodeString(text),
              equals(UTF8Codec.standard.encoder.convert(text.codeUnits)),
              reason: '#$i');
        }
      });
    });
  });
}
