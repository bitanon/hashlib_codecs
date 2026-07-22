import 'dart:convert' as cvt;

import 'package:test/test.dart';
import 'package:convertlib/src/core/alphabet.dart';

final b64codes =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        .codeUnits;

final b32codes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'.codeUnits;

void main() {
  group('AlphabetEncoder / AlphabetDecoder', () {
    test('8-bit identity alphabet without padding', () {
      // bits = 8 so encoder should behave like identity before alphabet map
      final encodeAlphabet = List<int>.generate(256, (i) => i); // identity
      final enc = AlphabetEncoder(bits: 8, alphabet: encodeAlphabet);
      expect(enc.source, equals(8), reason: 'encoder source');
      expect(enc.target, equals(8), reason: 'encoder target');
      final data = List<int>.generate(256, (i) => i); // 0..255
      final out = enc.convert(data);
      expect(out, data);
      // Decode back
      final decodeAlphabet =
          List<int>.generate(256, (i) => i); // inverse (identity)
      final dec = AlphabetDecoder(bits: 8, alphabet: decodeAlphabet);
      expect(dec.source, equals(8), reason: 'decoder source');
      expect(dec.target, equals(8), reason: 'decoder source');
      final back = dec.convert(out);
      expect(back, data);
    });

    test('5-bit encoding with padding to full byte boundary', () {
      final bits = 5;
      final encodeAlphabet = List<int>.generate(32, (i) => i); // identity
      const pad = 255;
      final enc = AlphabetEncoder(
        bits: bits,
        alphabet: encodeAlphabet,
        padding: pad,
      );
      expect(enc.source, equals(8), reason: 'encoder source');
      expect(enc.target, equals(bits), reason: 'encoder target');
      final input = [0xAB]; // single byte
      final encoded = enc.convert(input);
      // Expect length padded so that length * bits is multiple of 8.
      expect((encoded.length * bits) % 8, 0);
      // Without padding we would have ceil(8/5)=2 symbols; padding extends to 8 symbols (like base32 style)
      expect(encoded.length, 8);
      // First two symbols are from data, remaining are padding
      for (int i = 2; i < encoded.length; i++) {
        expect(encoded[i], pad);
      }

      // Build decoder inverse alphabet (identity) with padding
      final decodeAlphabet = List<int>.generate(256, (i) => i < 32 ? i : -1);
      final dec = AlphabetDecoder(
        bits: bits,
        alphabet: decodeAlphabet,
        padding: pad,
      );
      expect(dec.source, equals(bits), reason: 'decoder source');
      expect(dec.target, equals(8), reason: 'decoder target');
      final decoded = dec.convert(encoded);
      expect(decoded, input);
    });

    test('Decoder stops at padding', () {
      final bits = 5;
      const pad = 200;
      final encodeAlphabet = List<int>.generate(32, (i) => i);
      final enc =
          AlphabetEncoder(bits: bits, alphabet: encodeAlphabet, padding: pad);
      final input = [1, 2, 3];
      final encoded = enc.convert(input);
      // Manually append extra data after padding that should be ignored
      final withJunk = [...encoded, pad, pad];
      final decodeAlphabet = List<int>.generate(256, (i) => i < 32 ? i : -1);
      final dec =
          AlphabetDecoder(bits: bits, alphabet: decodeAlphabet, padding: pad);
      final decoded = dec.convert(withJunk);
      expect(decoded, input);
    });

    test('Decoder throws for invalid bit size', () {
      expect(
        () => AlphabetDecoder(bits: 1, alphabet: [2]).convert([20, 40, 40, 24]),
        throwsA(isA<ArgumentError>()
            .having((e) => e.name, 'name', 'source')
            .having((e) => e.message, 'message', 'should be between 2 to 64')),
      );
      expect(
        () =>
            AlphabetDecoder(bits: 128, alphabet: [2]).convert([20, 40, 40, 24]),
        throwsA(isA<ArgumentError>()
            .having((e) => e.name, 'name', 'source')
            .having((e) => e.message, 'message', 'should be between 2 to 64')),
      );
    });

    test('Decoder throws on invalid character (out of range)', () {
      final dec = AlphabetDecoder(
        bits: 5,
        alphabet: List<int>.generate(32, (i) => i),
      );
      expect(
        () => dec.convert([40]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 40 at 0')),
      );
    });

    test('Decoder throws on invalid character (negative mapping)', () {
      // alphabet[y] < 0 triggers FormatException
      final badAlphabet = List<int>.generate(32, (i) => i == 10 ? -1 : i);
      final dec = AlphabetDecoder(bits: 5, alphabet: badAlphabet);
      expect(
        () => dec.convert([10]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 10 at 0')),
      );
    });

    test('Decoder throws for invalid character after padding', () {
      final dec = AlphabetDecoder(
        bits: 5,
        padding: 40,
        alphabet: List<int>.generate(32, (i) => i),
      );
      expect(
        () => dec.convert([20, 40, 39]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 39 at 2')),
      );
      expect(
        () => dec.convert([20, 40, 40, 24]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 24 at 3')),
      );
    });

    test('Decoder throws on non-zero partial word (invalid length)', () {
      // A single 5-bit symbol leaves 5 bits that cannot form a byte.
      final dec = AlphabetDecoder(
        bits: 5,
        alphabet: List<int>.generate(32, (i) => i),
      );
      expect(
        () => dec.convert([1]),
        throwsA(isA<FormatException>().having((e) => e.message, 'message',
            'Invalid length or non-zero trailing bits')),
      );
    });

    test('Base64 encode/decode (no padding)', () {
      final enc = AlphabetEncoder(
        bits: 6,
        alphabet: b64codes,
        padding: '='.codeUnitAt(0),
      );
      final input = 'Man'.codeUnits; // 3 bytes -> 4 chars, no padding
      final encoded = enc.convert(input);
      expect(String.fromCharCodes(encoded), 'TWFu');

      final decodeAlphabet = List<int>.filled(256, -1);
      for (var i = 0; i < b64codes.length; i++) {
        decodeAlphabet[b64codes[i]] = i;
      }
      final dec = AlphabetDecoder(
        bits: 6,
        alphabet: decodeAlphabet,
        padding: '='.codeUnitAt(0),
      );
      final decoded = dec.convert(encoded);
      expect(decoded, input);
    });

    test('Base64 encode/decode (single padding)', () {
      final pad = '='.codeUnitAt(0);
      final enc = AlphabetEncoder(bits: 6, alphabet: b64codes, padding: pad);
      final input = 'Ma'.codeUnits; // 2 bytes -> 3 data chars + 1 pad
      final encoded = enc.convert(input);
      expect(String.fromCharCodes(encoded), 'TWE=');

      final decodeAlphabet = List<int>.filled(256, -1);
      for (var i = 0; i < b64codes.length; i++) {
        decodeAlphabet[b64codes[i]] = i;
      }
      final dec =
          AlphabetDecoder(bits: 6, alphabet: decodeAlphabet, padding: pad);
      final decoded = dec.convert(encoded);
      expect(decoded, input);
    });

    test('Base64 encode/decode (double padding)', () {
      final pad = '='.codeUnitAt(0);
      final enc = AlphabetEncoder(bits: 6, alphabet: b64codes, padding: pad);
      final input = 'M'.codeUnits; // 1 byte -> 2 data chars + 2 pads
      final encoded = enc.convert(input);
      expect(String.fromCharCodes(encoded), 'TQ==');

      final decodeAlphabet = List<int>.filled(256, -1);
      for (var i = 0; i < b64codes.length; i++) {
        decodeAlphabet[b64codes[i]] = i;
      }
      final dec =
          AlphabetDecoder(bits: 6, alphabet: decodeAlphabet, padding: pad);
      final decoded = dec.convert(encoded);
      expect(decoded, input);
    });

    test('Base64 decoder rejects invalid character', () {
      final decodeAlphabet = List<int>.filled(256, -1);
      for (var i = 0; i < b64codes.length; i++) {
        decodeAlphabet[b64codes[i]] = i;
      }
      final dec = AlphabetDecoder(
        bits: 6,
        alphabet: decodeAlphabet,
        padding: '='.codeUnitAt(0),
      );
      expect(
        () => dec.convert('?'.codeUnits),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 63 at 0')),
      );
    });
  });

  group('AlphabetEncoder correctness (external oracle)', () {
    final pad = '='.codeUnitAt(0);

    // RFC 4648 test vectors (Section 10) - the expected values come from the
    // RFC, not from round-tripping our own output.
    test('base64 known-answer vectors (padded)', () {
      final enc = AlphabetEncoder(bits: 6, alphabet: b64codes, padding: pad);
      const vectors = {
        '': '',
        'f': 'Zg==',
        'fo': 'Zm8=',
        'foo': 'Zm9v',
        'foob': 'Zm9vYg==',
        'fooba': 'Zm9vYmE=',
        'foobar': 'Zm9vYmFy',
      };
      vectors.forEach((input, expected) {
        expect(
          String.fromCharCodes(enc.convert(input.codeUnits)),
          expected,
          reason: 'input "$input"',
        );
      });
    });

    test('base32 known-answer vectors (padded)', () {
      final enc = AlphabetEncoder(bits: 5, alphabet: b32codes, padding: pad);
      const vectors = {
        '': '',
        'f': 'MY======',
        'fo': 'MZXQ====',
        'foo': 'MZXW6===',
        'foob': 'MZXW6YQ=',
        'fooba': 'MZXW6YTB',
        'foobar': 'MZXW6YTBOI======',
      };
      vectors.forEach((input, expected) {
        expect(
          String.fromCharCodes(enc.convert(input.codeUnits)),
          expected,
          reason: 'input "$input"',
        );
      });
    });

    // Differential check against dart:convert over every length up to 120,
    // covering all `length % 3` remainder classes (0, 1, 2 -> 0, 1, 2 pads).
    test('base64 padded matches dart:convert across lengths 0..120', () {
      final enc = AlphabetEncoder(bits: 6, alphabet: b64codes, padding: pad);
      for (var len = 0; len <= 120; len++) {
        final data = List<int>.generate(len, (i) => (i * 37 + 11) & 0xFF);
        expect(
          String.fromCharCodes(enc.convert(data)),
          cvt.base64.encode(data),
          reason: 'length $len',
        );
      }
    });

    // The padding == null branch must emit exactly the unpadded output.
    test('base64 unpadded matches dart:convert (=stripped) across lengths', () {
      final enc = AlphabetEncoder(bits: 6, alphabet: b64codes);
      for (var len = 0; len <= 120; len++) {
        final data = List<int>.generate(len, (i) => (i * 29 + 5) & 0xFF);
        expect(
          String.fromCharCodes(enc.convert(data)),
          cvt.base64.encode(data).replaceAll('=', ''),
          reason: 'length $len',
        );
      }
    });

    test('Encoder throws for invalid bit size', () {
      expect(
        () => AlphabetEncoder(bits: 1, alphabet: [0, 1]).convert([0]),
        throwsA(isA<ArgumentError>()
            .having((e) => e.name, 'name', 'target')
            .having((e) => e.message, 'message', 'should be between 2 to 64')),
      );
      expect(
        () => AlphabetEncoder(bits: 128, alphabet: [0, 1]).convert([0]),
        throwsA(isA<ArgumentError>()
            .having((e) => e.name, 'name', 'target')
            .having((e) => e.message, 'message', 'should be between 2 to 64')),
      );
    });

    // The unpadded output length must equal ceil(len * 8 / bits) with no
    // padding character ever appended.
    test('base32 unpadded output length is exactly ceil(len*8/5)', () {
      final enc = AlphabetEncoder(bits: 5, alphabet: b32codes);
      for (var len = 0; len <= 40; len++) {
        final data = List<int>.generate(len, (i) => (i * 13 + 7) & 0xFF);
        final out = enc.convert(data);
        expect(out.length, (len * 8 + 4) ~/ 5, reason: 'length $len');
        expect(out.contains(pad), isFalse, reason: 'length $len has no pad');
      }
    });
  });

  group('AlphabetDecoder ignoreWhitespace', () {
    final pad = '='.codeUnitAt(0);
    final b64rev = () {
      final t = List<int>.filled(128, -1);
      for (var i = 0; i < b64codes.length; i++) {
        t[b64codes[i]] = i;
      }
      return t;
    }();
    final relaxed = AlphabetDecoder(
      bits: 6,
      alphabet: b64rev,
      padding: pad,
      ignoreWhitespace: true,
    );

    test('skips whitespace between characters', () {
      // TWFu = "Man" (RFC 4648)
      expect(relaxed.convert(' TW\tFu\r\n'.codeUnits), equals('Man'.codeUnits));
    });

    test('skips whitespace among trailing padding characters', () {
      // TQ== = "M" (RFC 4648)
      expect(relaxed.convert('TQ=\n= '.codeUnits), equals('M'.codeUnits));
    });

    test('strict decoder (default) still rejects whitespace', () {
      final strict = AlphabetDecoder(bits: 6, alphabet: b64rev, padding: pad);
      expect(strict.ignoreWhitespace, isFalse);
      expect(
        () => strict.convert('TWFu\n'.codeUnits),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 10 at 4')),
      );
    });

    test('invalid characters still throw before the padding', () {
      expect(
        () => relaxed.convert('TW\n?u'.codeUnits),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 63 at 3')),
      );
    });

    test('invalid characters still throw after the padding', () {
      expect(
        () => relaxed.convert('TQ==\n?'.codeUnits),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 63 at 5')),
      );
    });

    test('non-ASCII whitespace is rejected', () {
      expect(
        () => relaxed.convert('TWFu\u00A0'.codeUnits),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 160 at 4')),
      );
    });

    test('a whitespace character in the alphabet decodes as its value', () {
      // Alphabet membership takes precedence over whitespace skipping.
      final identity = List<int>.generate(256, (i) => i);
      final dec = AlphabetDecoder(
        bits: 8,
        alphabet: identity,
        ignoreWhitespace: true,
      );
      expect(dec.convert([0x20, 0x0A, 0x41]), equals([0x20, 0x0A, 0x41]));
    });

    test('output matches the strict decoder on clean input', () {
      final strict = AlphabetDecoder(bits: 6, alphabet: b64rev, padding: pad);
      final enc = AlphabetEncoder(bits: 6, alphabet: b64codes, padding: pad);
      for (var len = 0; len <= 60; len++) {
        final data = List<int>.generate(len, (i) => (i * 31 + 13) & 0xFF);
        final encoded = enc.convert(data);
        expect(
          relaxed.convert(encoded),
          equals(strict.convert(encoded)),
          reason: 'length $len',
        );
      }
    });
  });
}
