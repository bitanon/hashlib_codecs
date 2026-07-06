import 'dart:convert';

import 'package:hashlib_codecs/src/codecs/utf8.dart';
import 'package:hashlib_codecs/src/utf8.dart';
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

      test('encoder with unpaired low surrogate', () {
        expect(() => encoder.convert([0xDC00]), throwsFormatException);
      });

      test('encoder with unpaired high surrogate', () {
        expect(() => encoder.convert([0xD801]), throwsFormatException);
      });

      test('encoder with invalid surrogate pair with low value', () {
        expect(() => encoder.convert([0xD805, 0xDB00]), throwsFormatException);
      });

      test('encoder with invalid surrogate pair with high value', () {
        expect(() => encoder.convert([0xD805, 0xEFFF]), throwsFormatException);
      });

      test('encoder with value exceeding range', () {
        expect(() => encoder.convert([0x110000]), throwsFormatException);
      });

      test('Empty input for decoder returns empty list', () {
        expect(encoder.convert([]), isEmpty);
      });
    });

    group('Decoder', () {
      final decoder = UTF8Codec.standard.decoder;

      test('decoder source', () {
        expect(decoder.source, 8);
      });

      test('decoder target', () {
        expect(decoder.target, 32);
      });

      test('Insufficient input for 2-byte sequence', () {
        expect(() => decoder.convert([0xC2]), throwsFormatException);
      });

      test('Invalid continuation byte at 1 for 2-byte sequence', () {
        expect(() => decoder.convert([0xC2, 0xC2]), throwsFormatException);
      });

      test('Insufficient input for 3-byte sequence', () {
        expect(() => decoder.convert([0xE1, 0x80]), throwsFormatException);
      });

      test('Invalid continuation byte at 1 for 3-byte sequence', () {
        expect(
            () => decoder.convert([0xE1, 0x41, 0x80]), throwsFormatException);
      });

      test('Invalid continuation byte at 2 for 3-byte sequence', () {
        expect(
            () => decoder.convert([0xE1, 0x80, 0x41]), throwsFormatException);
      });

      test('Overlong 3-byte sequence', () {
        expect(
            () => decoder.convert([0xE0, 0x80, 0xAF]), throwsFormatException);
      });

      test('Invalid surrogate for 3-byte', () {
        expect(
            () => decoder.convert([0xED, 0xA1, 0x80]), throwsFormatException);
      });

      test('Insufficient input for 4-byte sequence', () {
        expect(
            () => decoder.convert([0xF0, 0x90, 0x80]), throwsFormatException);
      });

      test('Invalid 4-byte lead', () {
        expect(() => decoder.convert([0xF5, 0x80, 0x80, 0x80]),
            throwsFormatException);
      });

      test('Overlong 4-byte sequence', () {
        expect(() => decoder.convert([0xF0, 0x8F, 0x80, 0x80]),
            throwsFormatException);
      });

      test('Invalid continuation byte at 1 for 4-byte sequence', () {
        expect(() => decoder.convert([0xF0, 0x41, 0x80, 0x80]),
            throwsFormatException);
      });

      test('Invalid continuation byte at 2 for 4-byte sequence', () {
        expect(() => decoder.convert([0xF0, 0x90, 0x41, 0x80]),
            throwsFormatException);
      });

      test('Invalid continuation byte at 3 for 4-byte sequence', () {
        expect(() => decoder.convert([0xF0, 0x90, 0x80, 0x41]),
            throwsFormatException);
      });

      test('Above U+10FFFF', () {
        expect(() => decoder.convert([0xF4, 0x90, 0x80, 0x80]),
            throwsFormatException);
      });

      test('Invalid UTF-8 sequence throws FormatException', () {
        // Invalid continuation byte (should start with 10xxxxxx)
        var invalid = [0xC2, 0x41];
        expect(() => decoder.convert(invalid), throwsFormatException);
      });

      test('Overlong encoding is rejected', () {
        // Overlong encoding for ASCII 'A' (should be 0x41, not 0xC1 0x81)
        var overlong = [0xC1, 0x81];
        expect(() => decoder.convert(overlong), throwsFormatException);
      });

      test('Code points above Unicode range are rejected', () {
        // 0x11FFFF is above valid Unicode range
        var invalid = [0xF4, 0x90, 0x80, 0x80];
        expect(() => decoder.convert(invalid), throwsFormatException);
      });

      test('5 or more bytes', () {
        expect(() => decoder.convert([0xF8]), throwsFormatException);
      });
    });
  });
}
