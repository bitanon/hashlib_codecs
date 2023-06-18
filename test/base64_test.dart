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
        noPadding: true,
      );
      expect(act, equals(out));
      act = toBase64(
        inp,
        codec: Base64Codec.standard,
        urlSafe: true,
      );
      expect(act, equals(out));
      act = toBase64(
        inp,
        codec: Base64Codec.standard,
        noPadding: true,
        urlSafe: true,
      );
      expect(act, equals(out));
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
      var act = toBase64(inp, noPadding: true);
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
        var a = toBase64(b, noPadding: true);
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
        var r = toBase64(b, noPadding: true);
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
