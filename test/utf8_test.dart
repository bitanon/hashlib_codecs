import 'dart:convert';
import 'dart:typed_data';

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
      expect(
        fromUtf8(Uint8List.fromList([0xC4, 0x80])),
        String.fromCharCodes([0x100]),
      );
      expect(
        toUtf8(String.fromCharCodes([0x100])),
        [0xC4, 0x80],
      );
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
        expect(
          () => encoder.convert([-1]),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Negative code -1 at 0')),
        );
      });

      test('with unpaired low surrogate', () {
        expect(
          () => encoder.convert([0xDC00]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Unpaired low surrogate 56320 at 0')),
        );
      });

      test('with unpaired high surrogate', () {
        expect(
          () => encoder.convert([0xD801]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Unpaired high surrogate 55297 at 0')),
        );
      });

      test('with invalid surrogate pair with low value', () {
        expect(
          () => encoder.convert([0xD805, 0xDB00]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid surrogate pair (55301, 56064) at 1')),
        );
      });

      test('with invalid surrogate pair with high value', () {
        expect(
          () => encoder.convert([0xD805, 0xEFFF]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid surrogate pair (55301, 61439) at 1')),
        );
      });

      test('with value exceeding range', () {
        expect(
          () => encoder.convert([0x110000]),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Invalid code 1114112 at 0')),
        );
      });

      test('with empty input for decoder returns empty list', () {
        expect(encoder.convert([]), isEmpty);
      });

      // Regression: the 3-byte branch used to lack an upper bound, so a scalar
      // code point >= U+10000 fed to `convert` (a documented `source: 32`
      // input) was force-fit into 3 bytes and produced invalid UTF-8 (e.g.
      // U+1F600 emitted the byte 0xFF). The 4-byte path was only reachable via
      // a UTF-16 surrogate pair, never a scalar astral value. The external
      // oracle here is `dart:convert`'s `utf8.encode`.
      group('scalar code point >= U+10000 uses the 4-byte form', () {
        const scalars = <int>[
          0x10000, // first 4-byte scalar
          0x1F600, // 😀, whose broken output contained the invalid byte 0xFF
          0x1D11E, // 𝄞 musical symbol G clef
          0x10FFFF, // last valid code point
        ];
        for (final cp in scalars) {
          test('U+${cp.toRadixString(16)}', () {
            final expected = utf8.encode(String.fromCharCode(cp));
            expect(encoder.convert([cp]), equals(expected));
            // And it must round-trip back to the same scalar.
            expect(
              UTF8Codec.standard.decoder.convert(encoder.convert([cp])),
              equals([cp]),
            );
          });
        }
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
        expect(
          () => decoder.convert([0xF0, 0x90]),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Insufficient input')),
        );
      });

      test('with insufficient input for 2-byte sequence', () {
        expect(
          () => decoder.convert([0xC2]),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Insufficient input')),
        );
      });

      test('with invalid continuation byte at 1 for 2-byte sequence', () {
        expect(
          () => decoder.convert([0xC2, 0xC2]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid continuation byte 194 at 1')),
        );
      });

      test('with insufficient input for 3-byte sequence', () {
        expect(
          () => decoder.convert([0xE1, 0x80]),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Insufficient input')),
        );
      });

      test('with invalid continuation byte at 1 for 3-byte sequence', () {
        expect(
          () => decoder.convert([0xE1, 0x41, 0x80]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid continuation byte 65 at 1')),
        );
      });

      test('with invalid continuation byte at 2 for 3-byte sequence', () {
        expect(
          () => decoder.convert([0xE1, 0x80, 0x41]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid continuation byte 65 at 2')),
        );
      });

      test('with overlong 3-byte sequence', () {
        expect(
          () => decoder.convert([0xE0, 0x80, 0xAF]),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Overlong 3-byte sequence at 0')),
        );
      });

      test('with invalid surrogate for 3-byte', () {
        expect(
          () => decoder.convert([0xED, 0xA1, 0x80]),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Invalid surrogate 55360 at 0')),
        );
      });

      test('with insufficient input for 4-byte sequence', () {
        expect(
          () => decoder.convert([0xF0, 0x90, 0x80]),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Insufficient input')),
        );
      });

      test('with invalid 4-byte lead', () {
        expect(
          () => decoder.convert([0xF5, 0x80, 0x80, 0x80]),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Invalid 4-byte lead 245 at 0')),
        );
      });

      test('with overlong 4-byte sequence', () {
        expect(
          () => decoder.convert([0xF0, 0x8F, 0x80, 0x80]),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Overlong 4-byte sequence at 0')),
        );
      });

      test('with invalid continuation byte at 1 for 4-byte sequence', () {
        expect(
          () => decoder.convert([0xF0, 0x41, 0x80, 0x80]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid continuation byte 65 at 1')),
        );
      });

      test('with invalid continuation byte at 2 for 4-byte sequence', () {
        expect(
          () => decoder.convert([0xF0, 0x90, 0x41, 0x80]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid continuation byte 65 at 2')),
        );
      });

      test('with invalid continuation byte at 3 for 4-byte sequence', () {
        expect(
          () => decoder.convert([0xF0, 0x90, 0x80, 0x41]),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid continuation byte 65 at 3')),
        );
      });

      test('with value above U+10FFFF', () {
        expect(
          () => decoder.convert([0xF4, 0x90, 0x80, 0x80]),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Above U+10FFFF at 3')),
        );
      });

      test('with invalid UTF-8 sequence throws FormatException', () {
        // Invalid continuation byte (should start with 10xxxxxx)
        var invalid = [0xC2, 0x41];
        expect(
          () => decoder.convert(invalid),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid continuation byte 65 at 1')),
        );
      });

      test('with overlong encoding is rejected', () {
        // Overlong encoding for ASCII 'A' (should be 0x41, not 0xC1 0x81)
        var overlong = [0xC1, 0x81];
        expect(
          () => decoder.convert(overlong),
          throwsA(isA<FormatException>().having(
              (e) => e.message, 'message', 'Overlong 2-byte sequence at 0')),
        );
      });

      test('with code points above Unicode range are rejected', () {
        // 0x11FFFF is above valid Unicode range
        var invalid = [0xF4, 0x90, 0x80, 0x80];
        expect(
          () => decoder.convert(invalid),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Above U+10FFFF at 3')),
        );
      });

      test('with 5 or more bytes', () {
        expect(
          () => decoder.convert([0xF8]),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Invalid code 248 at 0')),
        );
      });
    });

    group('decodeToString', () {
      // Mirrors the Decoder malformed-input tests through `fromUtf8`, which
      // uses `decodeToString` instead of `convert`. Each bad sequence is
      // placed both in the bulk region (surrounded by ASCII, so a full
      // 4-byte read is in range) and at the very end (the checked tail).
      const ascii = [0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48];
      // The bad sequence starts at index 8 (after the ASCII prefix). In the
      // bulk region a trailing ASCII byte follows, so a truncated multi-byte
      // sequence reports the following ASCII byte as an invalid continuation;
      // at the tail the same sequence runs out of input instead.
      final badSequences = {
        'truncated 2-byte sequence': _BadSeq(
          [0xC2],
          'Invalid continuation byte 65 at 9',
          'Insufficient input',
        ),
        'invalid continuation byte for 2-byte sequence': _BadSeq(
          [0xC2, 0xC2],
          'Invalid continuation byte 194 at 9',
          'Invalid continuation byte 194 at 9',
        ),
        'overlong 2-byte sequence': _BadSeq(
          [0xC1, 0x81],
          'Overlong 2-byte sequence at 8',
          'Overlong 2-byte sequence at 8',
        ),
        'lone continuation byte': _BadSeq(
          [0x80],
          'Invalid code 128 at 8',
          'Invalid code 128 at 8',
        ),
        'truncated 3-byte sequence': _BadSeq(
          [0xE1, 0x80],
          'Invalid continuation byte 65 at 10',
          'Insufficient input',
        ),
        'invalid continuation byte at 1 for 3-byte sequence': _BadSeq(
          [0xE1, 0x41, 0x80],
          'Invalid continuation byte 65 at 9',
          'Invalid continuation byte 65 at 9',
        ),
        'invalid continuation byte at 2 for 3-byte sequence': _BadSeq(
          [0xE1, 0x80, 0x41],
          'Invalid continuation byte 65 at 10',
          'Invalid continuation byte 65 at 10',
        ),
        'overlong 3-byte sequence': _BadSeq(
          [0xE0, 0x80, 0xAF],
          'Overlong 3-byte sequence at 8',
          'Overlong 3-byte sequence at 8',
        ),
        'surrogate in 3-byte sequence': _BadSeq(
          [0xED, 0xA1, 0x80],
          'Invalid surrogate 55360 at 8',
          'Invalid surrogate 55360 at 8',
        ),
        'truncated 4-byte sequence': _BadSeq(
          [0xF0, 0x90, 0x80],
          'Invalid continuation byte 65 at 11',
          'Insufficient input',
        ),
        'invalid 4-byte lead': _BadSeq(
          [0xF5, 0x80, 0x80, 0x80],
          'Invalid 4-byte lead 245 at 8',
          'Invalid 4-byte lead 245 at 8',
        ),
        'overlong 4-byte sequence': _BadSeq(
          [0xF0, 0x8F, 0x80, 0x80],
          'Overlong 4-byte sequence at 8',
          'Overlong 4-byte sequence at 8',
        ),
        'invalid continuation byte at 1 for 4-byte sequence': _BadSeq(
          [0xF0, 0x41, 0x80, 0x80],
          'Invalid continuation byte 65 at 9',
          'Invalid continuation byte 65 at 9',
        ),
        'invalid continuation byte at 2 for 4-byte sequence': _BadSeq(
          [0xF0, 0x90, 0x41, 0x80],
          'Invalid continuation byte 65 at 10',
          'Invalid continuation byte 65 at 10',
        ),
        'invalid continuation byte at 3 for 4-byte sequence': _BadSeq(
          [0xF0, 0x90, 0x80, 0x41],
          'Invalid continuation byte 65 at 11',
          'Invalid continuation byte 65 at 11',
        ),
        'above U+10FFFF': _BadSeq(
          [0xF4, 0x90, 0x80, 0x80],
          'Above U+10FFFF at 11',
          'Above U+10FFFF at 11',
        ),
        '5 or more byte lead': _BadSeq(
          [0xF8],
          'Invalid code 248 at 8',
          'Invalid code 248 at 8',
        ),
      };
      badSequences.forEach((name, bad) {
        test('$name in bulk region', () {
          var input = [...ascii, ...bad.seq, ...ascii];
          expect(
            () => fromUtf8(Uint8List.fromList(input)),
            throwsA(isA<FormatException>()
                .having((e) => e.message, 'message', bad.bulkMessage)),
          );
        });
        test('$name at the tail', () {
          var input = [...ascii, ...bad.seq];
          expect(
            () => fromUtf8(Uint8List.fromList(input)),
            throwsA(isA<FormatException>()
                .having((e) => e.message, 'message', bad.tailMessage)),
          );
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
        expect(UTF8Codec.standard.decoder.decode(toUtf8(text)), equals(text));
      });
    });

    group('encodeString', () {
      // Mirrors the Encoder surrogate tests through `toUtf8`, which uses
      // `encodeString` instead of `convert`.
      test('unpaired low surrogate throws', () {
        var text = String.fromCharCodes([0x41, 0xDC00, 0x42]);
        expect(
          () => toUtf8(text),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Unpaired low surrogate 56320 at 1')),
        );
      });

      test('unpaired high surrogate in the middle throws', () {
        var text = String.fromCharCodes([0x41, 0xD801, 0x42]);
        expect(
          () => toUtf8(text),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid surrogate pair (55297, 66) at 2')),
        );
      });

      test('unpaired high surrogate at the end throws', () {
        var text = String.fromCharCodes([0x41, 0xD801]);
        expect(
          () => toUtf8(text),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Unpaired high surrogate 55297 at 1')),
        );
      });

      test('invalid surrogate pair with low value throws', () {
        var text = String.fromCharCodes([0xD805, 0xDB00]);
        expect(
          () => toUtf8(text),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid surrogate pair (55301, 56064) at 1')),
        );
      });

      test('invalid surrogate pair with high value throws', () {
        var text = String.fromCharCodes([0xD805, 0xEFFF]);
        expect(
          () => toUtf8(text),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              'Invalid surrogate pair (55301, 61439) at 1')),
        );
      });

      test('codec encodeString matches encoder convert', () {
        for (int i = 0; i < 100; ++i) {
          var text = String.fromCharCodes(randomCodePoints(i));
          expect(UTF8Codec.standard.encoder.encode(text),
              equals(UTF8Codec.standard.encoder.convert(text.codeUnits)),
              reason: '#$i');
        }
      });
    });

    group('RFC 3629 & Kuhn stress-test vectors', () {
      // Canonical known-answer vectors. Valid encodings are taken from
      // RFC 3629 (https://www.rfc-editor.org/rfc/rfc3629) and Markus Kuhn's
      // UTF-8 decoder capability and stress test
      // (https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt). The
      // expected byte sequences are the canonical UTF-8 encodings; the
      // malformed sequences below MUST be rejected.

      // Well-known single-character encodings (code point -> canonical bytes).
      final validVectors = <String, List<int>>{
        'U+0024 DOLLAR SIGN': [0x24],
        'U+00A3 POUND SIGN': [0xC2, 0xA3],
        'U+20AC EURO SIGN': [0xE2, 0x82, 0xAC],
        'U+0939 DEVANAGARI LETTER HA': [0xE0, 0xA4, 0xB9],
        'U+D55C HANGUL SYLLABLE HAN': [0xED, 0x95, 0x9C],
        'U+10348 GOTHIC LETTER HWAIR': [0xF0, 0x90, 0x8D, 0x88],
      };
      final validCodePoints = <String, int>{
        'U+0024 DOLLAR SIGN': 0x24,
        'U+00A3 POUND SIGN': 0xA3,
        'U+20AC EURO SIGN': 0x20AC,
        'U+0939 DEVANAGARI LETTER HA': 0x0939,
        'U+D55C HANGUL SYLLABLE HAN': 0xD55C,
        'U+10348 GOTHIC LETTER HWAIR': 0x10348,
      };
      validVectors.forEach((name, bytes) {
        test('$name encodes to canonical bytes', () {
          var text = String.fromCharCodes([validCodePoints[name]!]);
          expect(toUtf8(text), equals(bytes));
        });
        test('$name decodes from canonical bytes', () {
          expect(
            fromUtf8(Uint8List.fromList(bytes)),
            equals(String.fromCharCodes([validCodePoints[name]!])),
          );
        });
      });

      test('Kuhn "κόσμε" round-trips against canonical bytes', () {
        // κ U+03BA, ό U+1F79, σ U+03C3, μ U+03BC, ε U+03B5.
        const codePoints = [0x03BA, 0x1F79, 0x03C3, 0x03BC, 0x03B5];
        const bytes = [
          0xCE, 0xBA, //
          0xE1, 0xBD, 0xB9, //
          0xCF, 0x83, //
          0xCE, 0xBC, //
          0xCE, 0xB5,
        ];
        var text = String.fromCharCodes(codePoints);
        expect(toUtf8(text), equals(bytes));
        expect(fromUtf8(Uint8List.fromList(bytes)), equals(text));
      });

      // RFC 3629 sequence-length boundaries: the first and last code point of
      // each of the four UTF-8 sequence lengths, with explicit byte vectors.
      final boundaryVectors = <String, List<int>>{
        'U+0000 (first 1-byte)': [0x00],
        'U+007F (last 1-byte)': [0x7F],
        'U+0080 (first 2-byte)': [0xC2, 0x80],
        'U+07FF (last 2-byte)': [0xDF, 0xBF],
        'U+0800 (first 3-byte)': [0xE0, 0xA0, 0x80],
        'U+FFFF (last 3-byte)': [0xEF, 0xBF, 0xBF],
        'U+10000 (first 4-byte)': [0xF0, 0x90, 0x80, 0x80],
        'U+10FFFF (last 4-byte)': [0xF4, 0x8F, 0xBF, 0xBF],
      };
      final boundaryCodePoints = <String, int>{
        'U+0000 (first 1-byte)': 0x0000,
        'U+007F (last 1-byte)': 0x007F,
        'U+0080 (first 2-byte)': 0x0080,
        'U+07FF (last 2-byte)': 0x07FF,
        'U+0800 (first 3-byte)': 0x0800,
        'U+FFFF (last 3-byte)': 0xFFFF,
        'U+10000 (first 4-byte)': 0x10000,
        'U+10FFFF (last 4-byte)': 0x10FFFF,
      };
      boundaryVectors.forEach((name, bytes) {
        test('$name has canonical byte encoding', () {
          var text = String.fromCharCodes([boundaryCodePoints[name]!]);
          expect(toUtf8(text), equals(bytes));
          expect(
            fromUtf8(Uint8List.fromList(bytes)),
            equals(text),
          );
        });
      });

      // Malformed sequences from Kuhn's stress test that MUST be rejected.
      // [0xE0,0x80,0xAF] (overlong '/') is omitted here as it is already
      // asserted verbatim in the Decoder / decodeToString groups.
      final malformed = <String, List<int>>{
        "overlong 2-byte '/' (0xC0 0xAF)": [0xC0, 0xAF],
        "overlong 4-byte '/' (0xF0 0x80 0x80 0xAF)": [0xF0, 0x80, 0x80, 0xAF],
        'overlong NUL (0xC0 0x80)': [0xC0, 0x80],
        'lone 2-byte start byte (0xC0)': [0xC0],
        'lone 3-byte start byte (0xE0)': [0xE0],
        'lone 4-byte start byte (0xF0)': [0xF0],
        'max overlong 2-byte (0xC1 0xBF)': [0xC1, 0xBF],
        'max overlong 3-byte (0xE0 0x9F 0xBF)': [0xE0, 0x9F, 0xBF],
        'max overlong 4-byte (0xF0 0x8F 0xBF 0xBF)': [0xF0, 0x8F, 0xBF, 0xBF],
        'UTF-16 surrogate U+D800 (0xED 0xA0 0x80)': [0xED, 0xA0, 0x80],
        'UTF-16 surrogate U+DFFF (0xED 0xBF 0xBF)': [0xED, 0xBF, 0xBF],
      };
      malformed.forEach((name, bytes) {
        test('$name is rejected', () {
          expect(
            () => fromUtf8(Uint8List.fromList(bytes)),
            throwsA(isA<FormatException>()),
          );
        });
      });
    });
  });
}

/// A malformed UTF-8 byte sequence together with the exact [FormatException]
/// message it should produce when placed in the bulk region (followed by more
/// bytes) versus at the tail of the input.
class _BadSeq {
  final List<int> seq;
  final String bulkMessage;
  final String tailMessage;
  const _BadSeq(this.seq, this.bulkMessage, this.tailMessage);
}
