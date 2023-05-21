// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert';

import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Test base64', () {
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
      expect(toBase64(inp, padding: false), equals(out));
    });
    test('decoding no padding AAAAAA => [0, 0, 0, 0]', () {
      var inp = [0, 0, 0, 0];
      var out = "AAAAAA";
      expect(fromBase64(out), equals(inp));
    });
    test('encoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64Encode(b).replaceAll('=', '');
        expect(toBase64(b, padding: false), r, reason: 'length $i');
      }
    });
    test('decoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64Encode(b).replaceAll('=', '');
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64Encode(b);
        expect(toBase64(b, padding: true), r, reason: 'length $i');
      }
    });
    test('decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64Encode(b);
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
        var r = toBase64(b, padding: true);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    group('decoding with invalid chars', () {
      test('Hashlib!', () {
        expect(() => fromBase64("Hashlib!"), throwsFormatException);
      });
      test('-10', () {
        expect(() => fromBase64(" 10"), throwsFormatException);
      });
      test('s*mething', () {
        expect(() => fromBase64("s*mething"), throwsFormatException);
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
