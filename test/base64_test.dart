// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' as cvt;

import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

import 'utils.dart';

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
    group('decoding with invalid chars', () {
      test('Hashlib!', () {
        try {
          fromBase64("Hashlib!");
          throw Exception('No error thrown');
        } on FormatException catch (err) {
          expect(err.message, equals("Invalid character 33"));
        }
      });
      test('a.10', () {
        try {
          fromBase64("a.10");
          throw Exception('No error thrown');
        } on FormatException catch (err) {
          expect(err.message, equals("Invalid character 46"));
        }
      });
      test('s*methings', () {
        try {
          fromBase64("s*methings");
          throw Exception('No error thrown');
        } on FormatException catch (err) {
          expect(err.message, equals("Invalid character 42"));
        }
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
    group('decoding with invalid length', () {
      test('H', () {
        expect(() => fromBase64("H"), throwsFormatException);
      });
      test('Ha', () {
        expect(() => fromBase64("Ha"), throwsFormatException);
      });
      test('HaB', () {
        expect(() => fromBase64("HaB"), throwsFormatException);
      });
      test('Hashl', () {
        expect(() => fromBase64("Hashl"), throwsFormatException);
      });
      test('Hashli', () {
        expect(() => fromBase64("Hashli"), throwsFormatException);
      });
      test('Hashlib', () {
        expect(() => fromBase64("Hashlib"), throwsFormatException);
      });
    });
  });
}
