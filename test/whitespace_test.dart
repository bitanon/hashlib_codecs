import 'dart:convert' as cvt;

import 'package:convertlib/convertlib.dart';
import 'package:convertlib/src/core/whitespace.dart';
import 'package:test/test.dart';

import './utils.dart';

/// The six ASCII whitespace characters the feature is documented to skip.
const _ws = [' ', '\t', '\n', '\v', '\f', '\r'];

/// Intersperse [s] with a rotating cycle of whitespace characters, so that
/// whitespace appears before, between, and after the significant characters.
String _lace(String s) {
  var sb = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    sb.write(_ws[i % _ws.length]);
    sb.write(s[i]);
  }
  sb.write(_ws[s.length % _ws.length]);
  return sb.toString();
}

void main() {
  group('stripWhitespace helper', () {
    test('removes each of the six ASCII whitespace characters', () {
      // 0x41 = 'A' on both sides of every whitespace code unit.
      final input = [
        0x41, 0x09, 0x41, 0x0A, 0x41, 0x0B, //
        0x41, 0x0C, 0x41, 0x0D, 0x41, 0x20, 0x41,
      ];
      expect(stripWhitespace(input),
          equals([0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41]));
    });
    test('preserves code units wider than a byte (no truncation)', () {
      // 0x141 & 0xFF == 0x41 ('A'); a Uint8List store would corrupt it into a
      // valid character. It must survive unchanged.
      expect(stripWhitespace([0x141, 0x20, 0x142]), equals([0x141, 0x142]));
    });
    test('returns the same instance when there is no whitespace', () {
      // A clean input must not be copied, so the flag costs no allocation.
      final input = [1, 2, 3, 0x100];
      expect(identical(stripWhitespace(input), input), isTrue);
    });
    test('an all-whitespace input becomes empty', () {
      expect(stripWhitespace([0x20, 0x09, 0x0A, 0x0D]), isEmpty);
    });
    test('does not strip near-whitespace controls (0x08, 0x0E)', () {
      expect(stripWhitespace([0x08, 0x0E]), equals([0x08, 0x0E]));
    });
  });

  group('Base-64 whitespace-tolerant decode', () {
    test('known answer: laced "SGVsbG8=" decodes to "Hello"', () {
      final expected = toUtf8('Hello');
      expect(fromBase64('S G V\ns\tbG8 =', ignoreWhitespace: true),
          equals(expected));
    });
    test('differential vs dart:convert on a PEM-style block', () {
      final expected = randomBytes(200);
      // Encode with dart:convert (the external oracle), then wrap at 64 columns
      // with CRLF the way a real PEM/MIME body is folded.
      final pem = cvt.base64.encode(expected);
      var wrapped = StringBuffer();
      for (int i = 0; i < pem.length; i += 64) {
        final end = i + 64 > pem.length ? pem.length : i + 64;
        wrapped.write(pem.substring(i, end));
        wrapped.write('\r\n');
      }
      expect(fromBase64(wrapped.toString(), ignoreWhitespace: true),
          equals(expected));
    });
    test('roundtrip with injected whitespace at every length 0..99', () {
      for (int len = 0; len < 100; ++len) {
        final data = randomBytes(len);
        final enc = toBase64(data);
        final out = fromBase64(_lace(enc), ignoreWhitespace: true);
        expect(out, equals(data), reason: 'length $len');
      }
    });
    test('whitespace-only input decodes to empty', () {
      expect(fromBase64(' \t\n\r', ignoreWhitespace: true), isEmpty);
    });
    test('default (strict) still rejects whitespace', () {
      expect(() => fromBase64('SGVs bG8='), throwsFormatException);
      expect(() => fromBase64('SGVs\nbG8='), throwsFormatException);
    });
    test('non-whitespace invalid characters still throw when tolerant', () {
      expect(() => fromBase64('SG!s', ignoreWhitespace: true),
          throwsFormatException);
    });
    test('tryFromBase64 honours the flag', () {
      expect(tryFromBase64('SGVs\nbG8='), isNull);
      expect(tryFromBase64('SGVs\nbG8=', ignoreWhitespace: true),
          equals(toUtf8('Hello')));
    });
  });

  group('Base-32 whitespace-tolerant decode', () {
    test('roundtrip with injected whitespace at every length 0..99', () {
      for (int len = 0; len < 100; ++len) {
        final data = randomBytes(len);
        final enc = toBase32(data);
        final out = fromBase32(_lace(enc), ignoreWhitespace: true);
        expect(out, equals(data), reason: 'length $len');
      }
    });
    test('default (strict) still rejects whitespace', () {
      final enc = toBase32([0x66, 0x6f, 0x6f]);
      expect(() => fromBase32(_lace(enc)), throwsFormatException);
    });
    test('tryFromBase32 honours the flag', () {
      final enc = _lace(toBase32([1, 2, 3]));
      expect(tryFromBase32(enc), isNull);
      expect(tryFromBase32(enc, ignoreWhitespace: true), equals([1, 2, 3]));
    });
  });

  group('Base-16 whitespace-tolerant decode', () {
    test('known answer: spaced hex pairs decode correctly', () {
      expect(fromHex('de ad\tbe\nef', ignoreWhitespace: true),
          equals([0xde, 0xad, 0xbe, 0xef]));
    });
    test('roundtrip with injected whitespace at every length 0..99', () {
      for (int len = 0; len < 100; ++len) {
        final data = randomBytes(len);
        final enc = toHex(data);
        final out = fromHex(_lace(enc), ignoreWhitespace: true);
        expect(out, equals(data), reason: 'length $len');
      }
    });
    test('default (strict) still rejects whitespace', () {
      expect(() => fromHex('de ad'), throwsFormatException);
    });
    test('tryFromHex honours the flag', () {
      expect(tryFromHex('de ad'), isNull);
      expect(tryFromHex('de ad', ignoreWhitespace: true), equals([0xde, 0xad]));
    });
  });
}
